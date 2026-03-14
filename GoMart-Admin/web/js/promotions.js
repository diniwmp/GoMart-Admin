import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, addDoc, getDocs, deleteDoc, doc, query, orderBy, Timestamp } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db = getFirestore(app);

let selectedType = "PROMO";

// ── Auth check ───────────────────────────────────────────
onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadNotifications();
  }
});

// ── Logout ───────────────────────────────────────────────
document.getElementById("logoutBtn").addEventListener("click", async (e) => {
  e.preventDefault();
  await signOut(auth);
  window.location.href = "index.html";
});

// ── Show alert ───────────────────────────────────────────
function showAlert(message, type = "success") {
  const el = document.getElementById("alertMsg");
  el.textContent = message;
  el.className = `alert-msg alert-${type}`;
  el.style.display = "block";
  setTimeout(() => { el.style.display = "none"; }, 3000);
}

// ── Type selector ────────────────────────────────────────
window.selectType = function (card, type) {
  document.querySelectorAll(".type-card").forEach(c => c.classList.remove("selected"));
  card.classList.add("selected");
  selectedType = type;

  // update preview icon
  const icons = { PROMO: "🏷", SALE: "💰", SYSTEM: "📢" };
  document.querySelector(".notif-icon").textContent = icons[type] || "📢";
};

// ── Live preview ─────────────────────────────────────────
window.updatePreview = function () {
  const title = document.getElementById("notifTitle").value;
  const message = document.getElementById("notifMessage").value;
  const preview = document.getElementById("promoPreview");

  if (title || message) {
    preview.style.display = "block";
    document.getElementById("previewTitle").textContent = title || "Title here";
    document.getElementById("previewMessage").textContent = message || "Message here";
  } else {
    preview.style.display = "none";
  }
};

// ── Send notification ────────────────────────────────────
window.sendNotification = async function () {
  const title = document.getElementById("notifTitle").value.trim();
  const message = document.getElementById("notifMessage").value.trim();
  const btn = document.getElementById("sendBtn");

  if (!title) { showAlert("Please enter a notification title.", "error"); return; }
  if (!message) { showAlert("Please enter a message.", "error"); return; }

  btn.disabled = true;
  btn.textContent = "Sending...";

  try {
    // write to notifications collection
    // matches Notification model exactly:
    // notifId, title, message, type, orderId, isRead, timestamp
    const docRef = await addDoc(collection(db, "notifications"), {
      title: title,
      message: message,
      type: selectedType,       // PROMO, SALE, SYSTEM
      orderId: "",              // empty for promo — not order related
      isRead: false,            // mobile app marks as read
      timestamp: Timestamp.now()
    });

    // store notifId same as document id
    await import("https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js")
      .then(({ updateDoc, doc: firestoreDoc }) => {
        return updateDoc(firestoreDoc(db, "notifications", docRef.id), {
          notifId: docRef.id
        });
      });

    showAlert(`Notification sent to all customers successfully!`);

    // reset form
    document.getElementById("notifTitle").value = "";
    document.getElementById("notifMessage").value = "";
    document.getElementById("promoPreview").style.display = "none";

    loadNotifications();

  } catch (e) {
    console.error("Send notification error:", e);
    showAlert("Failed to send notification. Try again.", "error");
  } finally {
    btn.disabled = false;
    btn.textContent = "✉ Send to All Customers";
  }
};

// ── Load notifications ───────────────────────────────────
async function loadNotifications() {
  const table = document.getElementById("notifTable");
  table.innerHTML = `<tr><td colspan="5" class="loading">Loading notifications...</td></tr>`;

  try {
    const snap = await getDocs(
      query(collection(db, "notifications"), orderBy("timestamp", "desc"))
    );

    // update stats
    const all = [];
    snap.forEach(d => all.push({ id: d.id, ...d.data() }));

    // only show PROMO, SALE, SYSTEM — not ORDER type
    const filtered = all.filter(n => n.type !== "ORDER");

    document.getElementById("totalSent").textContent = filtered.length;
    document.getElementById("promoCount").textContent = filtered.filter(n => n.type === "PROMO" || n.type === "SALE").length;
    document.getElementById("systemCount").textContent = filtered.filter(n => n.type === "SYSTEM").length;
    document.getElementById("notifCount").textContent = `(${filtered.length})`;

    if (filtered.length === 0) {
      table.innerHTML = `<tr><td colspan="5" class="empty-state">No notifications sent yet</td></tr>`;
      return;
    }

    table.innerHTML = "";
    filtered.forEach(n => {
      const time = n.timestamp?.seconds
        ? new Date(n.timestamp.seconds * 1000).toLocaleString()
        : "—";

      const typeClass = {
        PROMO: "t-promo",
        SALE: "t-sale",
        SYSTEM: "t-system"
      }[n.type] || "t-system";

      // truncate long messages
      const shortMsg = n.message?.length > 60
        ? n.message.substring(0, 60) + "..."
        : n.message;

      table.innerHTML += `
        <tr>
          <td style="font-weight:500">${n.title || "—"}</td>
          <td style="color:#64748b">${shortMsg || "—"}</td>
          <td><span class="type-badge ${typeClass}">${n.type}</span></td>
          <td style="font-size:12px;color:#64748b">${time}</td>
          <td>
            <button class="btn-delete" onclick="deleteNotification('${n.id}')">Delete</button>
          </td>
        </tr>`;
    });

  } catch (e) {
    console.error("Load notifications error:", e);
    table.innerHTML = `<tr><td colspan="5" style="color:#ef4444;text-align:center;font-size:13px">Failed to load notifications</td></tr>`;
  }
}

// ── Delete notification ──────────────────────────────────
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