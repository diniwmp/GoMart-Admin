import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut }
  from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import {
  getFirestore, collection, addDoc, getDocs, deleteDoc,
  doc, getDoc, query, orderBy, Timestamp
} from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db   = getFirestore(app);

const BACKEND_URL =
    "http://localhost:8080/GoMart-Admin/api/notifications/send";

let selectedType = "PROMO";

//  Auth 
onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadNotifications();
  }
});

document.getElementById("logoutBtn").addEventListener("click", async (e) => {
  e.preventDefault();
  await signOut(auth);
  window.location.href = "index.html";
});

//  Alert 
function showAlert(message, type = "success") {
  const el = document.getElementById("alertMsg");
  el.textContent = message;
  el.className   = "alert-msg alert-" + type;
  el.style.display = "block";
  setTimeout(() => { el.style.display = "none"; }, 3000);
}

//  Type selector 
window.selectType = function (card, type) {
  document.querySelectorAll(".type-card")
          .forEach(c => c.classList.remove("selected"));
  card.classList.add("selected");
  selectedType = type;
  const icons = { PROMO, SALE, SYSTEM};
  document.querySelector(".notif-icon").textContent =
      icons[type] ;
};

//  Live preview 
window.updatePreview = function () {
  const title   = document.getElementById("notifTitle").value;
  const message = document.getElementById("notifMessage").value;
  const preview = document.getElementById("promoPreview");
  if (title || message) {
    preview.style.display = "block";
    document.getElementById("previewTitle").textContent =
        title   || "Title here";
    document.getElementById("previewMessage").textContent =
        message || "Message here";
  } else {
    preview.style.display = "none";
  }
};

//  Send notification to ALL users 
window.sendNotification = async function () {
  const title   = document.getElementById("notifTitle").value.trim();
  const message = document.getElementById("notifMessage").value.trim();
  const btn     = document.getElementById("sendBtn");

  if (!title)   { showAlert("Please enter a title.",   "error"); return; }
  if (!message) { showAlert("Please enter a message.", "error"); return; }

  btn.disabled    = true;
  btn.textContent = "Sending...";

  try {
    const usersSnap = await getDocs(collection(db, "users"));

    let inAppCount = 0;
    let fcmCount   = 0;
    let fcmFailed  = 0;

    // Process each user
    const tasks = [];
    usersSnap.forEach(userDoc => {
      tasks.push(
        processUser(userDoc, title, message)
          .then(result => {
            inAppCount++;
            if (result.fcmSent) fcmCount++;
            else                fcmFailed++;
          })
      );
    });

    await Promise.all(tasks);

    showAlert(
      "Sent to " + inAppCount + " users. " +
      "Push notifications: " + fcmCount + " delivered, " +
      fcmFailed + " skipped (no token)."
    );

    document.getElementById("notifTitle").value   = "";
    document.getElementById("notifMessage").value = "";
    document.getElementById("promoPreview").style.display = "none";

    loadNotifications();

  } catch (e) {
    console.error("Send error:", e);
    showAlert("Failed to send. Try again.", "error");
  } finally {
    btn.disabled    = false;
    btn.textContent = "Send to All Customers";
  }
};

// Process one user: save in-app + send FCM 
async function processUser(userDoc, title, message) {
  const uid    = userDoc.id;
  const result = { fcmSent: false };

  // Save in-app notification to Firestore
  try {
    await addDoc(
      collection(db, "notifications", uid, "items"),
      {
        title:     title,
        message:   message,
        type:      selectedType,
        orderId:   "",
        isRead:    false,
        timestamp: Timestamp.now()
      }
    );
  } catch (e) {
    console.error("In-app save failed for " + uid + ":", e.message);
  }

  // Send FCM push notification via Java EE backend
  try {
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) return result; // no token — skip FCM

    const response = await fetch(BACKEND_URL, {
      method:  "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        token:   fcmToken,
        title:   title,
        message: message,
        orderId: "",
        type:    selectedType
      })
    });

    if (response.ok) {
      result.fcmSent = true;
      console.log("FCM sent to:", uid);
    } else {
      console.warn("FCM failed for " + uid + ":", response.status);
    }
  } catch (e) {
    // Don't block on FCM failure — in-app notification already saved
    console.warn("FCM skipped for " + uid + ":", e.message);
  }

  return result;
}

// Load sent notifications table 
async function loadNotifications() {
  const table = document.getElementById("notifTable");
  table.innerHTML =
    "<tr><td colspan='5' class='loading'>Loading notifications...</td></tr>";

  try {
  
    const snap = await getDocs(
      query(collection(db, "notifications"),
            orderBy("timestamp", "desc"))
    );

    const all = [];
    snap.forEach(d => all.push({ id: d.id, ...d.data() }));

    const filtered = all.filter(n => n.type !== "ORDER");

    document.getElementById("totalSent").textContent  = filtered.length;
    document.getElementById("promoCount").textContent =
        filtered.filter(n =>
            n.type === "PROMO" || n.type === "SALE").length;
    document.getElementById("systemCount").textContent =
        filtered.filter(n => n.type === "SYSTEM").length;
    document.getElementById("notifCount").textContent =
        "(" + filtered.length + ")";

    if (filtered.length === 0) {
      table.innerHTML =
        "<tr><td colspan='5' class='empty-state'>" +
        "No notifications sent yet</td></tr>";
      return;
    }

    table.innerHTML = "";
    filtered.forEach(n => {
      const time = n.timestamp?.seconds
        ? new Date(n.timestamp.seconds * 1000).toLocaleString()
        : "—";
      const typeClass = {
        PROMO:  "t-promo",
        SALE:   "t-sale",
        SYSTEM: "t-system"
      }[n.type] || "t-system";
      const shortMsg = n.message?.length > 60
        ? n.message.substring(0, 60) + "..."
        : (n.message || "—");

      table.innerHTML +=
        "<tr>" +
        "<td style='font-weight:500'>" + (n.title || "—") + "</td>" +
        "<td style='color:#64748b'>" + shortMsg + "</td>" +
        "<td><span class='type-badge " + typeClass + "'>" +
            n.type + "</span></td>" +
        "<td style='font-size:12px;color:#64748b'>" + time + "</td>" +
        "<td><button class='btn-delete' " +
            "onclick=\"deleteNotification('" + n.id + "')\">Delete</button>" +
        "</td></tr>";
    });

  } catch (e) {
    console.error("Load notifications error:", e);
    table.innerHTML =
      "<tr><td colspan='5' style='color:#ef4444;text-align:center;" +
      "font-size:13px'>Failed to load notifications</td></tr>";
  }
}

//  Delete notification 
window.deleteNotification = async function (id) {
  if (!confirm("Delete this notification?")) return;
  try {
    await deleteDoc(doc(db, "notifications", id));
    showAlert("Notification deleted.");
    loadNotifications();
  } catch (e) {
    console.error("Delete error:", e);
    showAlert("Failed to delete.", "error");
  }
};