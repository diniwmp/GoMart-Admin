import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut }
  from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import {
  getFirestore, collection, addDoc, getDocs,
  deleteDoc, doc, query, orderBy, Timestamp
} from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db   = getFirestore(app);

const BACKEND_URL =
    "http://localhost:8080/GoMart-Admin/api/notifications/send";

let selectedType = "PROMO";

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

function showAlert(message, type = "success") {
  const el = document.getElementById("alertMsg");
  el.textContent   = message;
  el.className     = "alert-msg alert-" + type;
  el.style.display = "block";
  setTimeout(() => { el.style.display = "none"; }, 3000);
}

window.selectType = function (card, type) {
  document.querySelectorAll(".type-card")
          .forEach(c => c.classList.remove("selected"));
  card.classList.add("selected");
  selectedType = type;
  
};

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
      "Push: " + fcmCount + " delivered, " +
      fcmFailed + " skipped."
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

async function processUser(userDoc, title, message) {
  const uid    = userDoc.id;
  const result = { fcmSent: false };

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

  try {
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) return result;

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
    } else {
      console.warn("FCM failed for " + uid + ":", response.status);
    }
  } catch (e) {
    console.warn("FCM skipped for " + uid + ":", e.message);
  }

  return result;
}


async function loadNotifications() {
  const table = document.getElementById("notifTable");
  table.innerHTML =
    "<tr><td colspan='5' class='loading'>Loading notifications...</td></tr>";

  try {
    const usersSnap = await getDocs(collection(db, "users"));
    if (usersSnap.empty) {
      showEmptyTable(table);
      return;
    }

    const allItems = [];
    const fetchTasks = [];

    usersSnap.forEach(userDoc => {
      const uid = userDoc.id;
      fetchTasks.push(
        getDocs(
          collection(db, "notifications", uid, "items")
        ).then(itemsSnap => {
          itemsSnap.forEach(d => {
            allItems.push({
              id:    d.id,
              ref:   d.ref,
              ...d.data()
            });
          });
        }).catch(e => {
          // Silently skip users with no notifications
          console.log("No notifications for user:", uid);
        })
      );
    });

    await Promise.all(fetchTasks);

    const filtered = allItems.filter(n =>
      n.type && n.type !== "ORDER"
    );

    
    const seen   = new Set();
    const unique = [];
    filtered.sort((a, b) =>
      (b.timestamp?.seconds || 0) - (a.timestamp?.seconds || 0)
    );
    filtered.forEach(n => {
      const key = (n.title   || "") + "|" +
                  (n.message || "") + "|" +
                  (n.timestamp?.seconds || "");
      if (!seen.has(key)) {
        seen.add(key);
        unique.push(n);
      }
    });

    document.getElementById("totalSent").textContent =
        unique.length;
    document.getElementById("promoCount").textContent =
        unique.filter(n =>
            n.type === "PROMO" || n.type === "SALE").length;
    document.getElementById("systemCount").textContent =
        unique.filter(n => n.type === "SYSTEM").length;
    document.getElementById("notifCount").textContent =
        "(" + unique.length + ")";

    if (unique.length === 0) {
      showEmptyTable(table);
      return;
    }

    table.innerHTML = "";
    unique.forEach(n => {
      const time = n.timestamp?.seconds
        ? new Date(n.timestamp.seconds * 1000).toLocaleString()
        : "—";
      const typeClass = {
        PROMO:  "t-promo",
        SALE:   "t-sale",
        SYSTEM: "t-system"
      }[n.type] || "t-system";
      const shortMsg = (n.message || "").length > 60
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

function showEmptyTable(table) {
  document.getElementById("totalSent").textContent   = "0";
  document.getElementById("promoCount").textContent  = "0";
  document.getElementById("systemCount").textContent = "0";
  document.getElementById("notifCount").textContent  = "(0)";
  table.innerHTML =
    "<tr><td colspan='5' class='empty-state'>" +
    "No notifications sent yet</td></tr>";
}

window.deleteNotification = async function (id) {
  Swal.fire({
    title: "Delete Notification?",
    text: "This removes it from all users.",
    icon: "warning",
    showCancelButton: true,
    confirmButtonColor: "#d33",
    cancelButtonColor: "#36E41B",
    confirmButtonText: "Yes, delete it!"
  }).then(async (result) => {
    if (!result.isConfirmed) return;
    try {
      const usersSnap = await getDocs(collection(db, "users"));
      const toDelete  = [];

      const lookupTasks = [];
      usersSnap.forEach(userDoc => {
        const uid = userDoc.id;
        lookupTasks.push(
          getDocs(collection(db, "notifications", uid, "items"))
            .then(itemsSnap => {
              itemsSnap.forEach(d => {
                if (d.id === id) toDelete.push(d.ref);
              });
            })
        );
      });

      await Promise.all(lookupTasks);
      await Promise.all(toDelete.map(ref => deleteDoc(ref)));

      Swal.fire("Deleted!", "Notification removed.", "success");
      loadNotifications();
    } catch (e) {
      console.error("Delete error:", e);
      Swal.fire("Error", "Failed to delete.", "error");
    }
  });
};