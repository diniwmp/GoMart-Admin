

import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut }
  from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import {
  getFirestore, collection, doc, addDoc, onSnapshot,
  query, serverTimestamp, updateDoc, setDoc
} from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db   = getFirestore(app);

const ADMIN_ID   = "ADMIN";
const ADMIN_NAME = "GoMart Support";

let allUsers       = [];
let selectedUserId = null;
let messagesUnsub  = null;

onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadUserConversations();
  }
});

document.getElementById("logoutBtn").addEventListener("click", async (e) => {
  e.preventDefault();
  await signOut(auth);
  window.location.href = "index.html";
});

function loadUserConversations() {
  const body = document.getElementById("userListBody");
  body.innerHTML = `<div class="user-list-empty">Loading...</div>`;

  onSnapshot(
    collection(db, "chats"),
    (snapshot) => {
      allUsers = [];

      snapshot.forEach((d) => {
        const data = d.data();
        allUsers.push({
          id:            d.id,
          name:          data.userName      || data.name  || "Unknown",
          email:         data.userEmail     || data.email || "",
          lastMessage:   data.lastMessage   || "",
          lastTimestamp: data.lastTimestamp || data.lastMessageTime || null,
        });
      });

      allUsers.sort((a, b) => {
        const ta = a.lastTimestamp?.seconds || 0;
        const tb = b.lastTimestamp?.seconds || 0;
        return tb - ta;
      });

      renderUserList(allUsers);
    },
    (error) => {
      console.error("Firestore chats error:", error);
      body.innerHTML = `
        <div class="user-list-empty" style="color:#ef4444">
          Failed to load.<br><small>${error.message}</small>
        </div>`;
    }
  );
}

function renderUserList(users) {
  const body = document.getElementById("userListBody");

  if (users.length === 0) {
    body.innerHTML = `<div class="user-list-empty">No conversations yet</div>`;
    return;
  }

  body.innerHTML = users.map((u) => {
    const initials = (u.name || "?")
      .split(" ").map(w => w[0]).join("").substring(0, 2).toUpperCase();
    const time     = u.lastTimestamp ? formatTime(u.lastTimestamp) : "";
    const isActive = u.id === selectedUserId;

    return `
      <div class="user-item ${isActive ? "active" : ""}"
           onclick="selectUser('${u.id}', this)">
        <div class="user-avatar">${initials}</div>
        <div class="user-info">
          <div class="user-name">${escHtml(u.name)}</div>
          <div class="user-preview">${escHtml(u.lastMessage)}</div>
        </div>
        <div class="user-time">${time}</div>
      </div>`;
  }).join("");
}

window.filterUsers = function () {
  const q = document.getElementById("userSearch").value.toLowerCase();
  const filtered = allUsers.filter(u =>
    u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q)
  );
  renderUserList(filtered);
};

window.selectUser = function (userId, el) {
  selectedUserId = userId;

  document.querySelectorAll(".user-item")
          .forEach(item => item.classList.remove("active"));
  if (el) el.classList.add("active");

  const user = allUsers.find(u => u.id === userId);
  if (!user) return;

  const initials = (user.name || "?")
    .split(" ").map(w => w[0]).join("").substring(0, 2).toUpperCase();
  document.getElementById("chatHeader").style.display     = "flex";
  document.getElementById("chatHeaderAvatar").textContent = initials;
  document.getElementById("chatHeaderName").textContent   = user.name;
  document.getElementById("chatHeaderEmail").textContent  = user.email;

  const input   = document.getElementById("chatInput");
  const sendBtn = document.getElementById("sendBtn");
  input.disabled    = false;
  sendBtn.disabled  = false;
  input.placeholder = "Type a reply...";
  input.focus();

  if (messagesUnsub) {
    messagesUnsub();
    messagesUnsub = null;
  }

  document.getElementById("chatMessages").innerHTML =
    `<div class="loading-msg">Loading messages...</div>`;

  messagesUnsub = onSnapshot(
    collection(db, "chats", userId, "messages"),
    { includeMetadataChanges: false },
    (snapshot) => {
      const sorted = snapshot.docs.slice().sort((a, b) => {
        const ta = a.data().timestamp?.seconds || 0;
        const tb = b.data().timestamp?.seconds || 0;
        return ta - tb;
      });
      renderMessages(sorted);
    },
    (error) => {
      console.error("Messages listener error:", error);
      document.getElementById("chatMessages").innerHTML =
        `<div class="loading-msg" style="color:#ef4444">
           Error: ${error.message}
         </div>`;
    }
  );
};

function renderMessages(docs) {
  const container = document.getElementById("chatMessages");

  if (docs.length === 0) {
    container.innerHTML = `
      <div class="chat-placeholder">
        <div class="chat-placeholder-icon">&#9993;</div>
        <div class="chat-placeholder-text">No messages yet</div>
      </div>`;
    return;
  }

  container.innerHTML = docs.map((d) => {
    const msg = d.data();

    const isAdmin = msg.isAdmin === true
                 || msg.senderId === ADMIN_ID        
                 || msg.senderId === "admin";       

    const time     = msg.timestamp ? formatTime(msg.timestamp) : "";
    const initials = isAdmin
      ? "G"
      : (msg.senderName || "?").split(" ").map(w => w[0])
          .join("").substring(0, 2).toUpperCase();

    return `
      <div class="msg-row ${isAdmin ? "sent" : ""}">
        <div class="msg-avatar-sm ${isAdmin ? "admin" : ""}">${initials}</div>
        <div class="msg-bubble-wrap">
          ${!isAdmin
            ? `<div class="msg-sender-label">${escHtml(msg.senderName || "User")}</div>`
            : ""}
          <div class="msg-bubble ${isAdmin ? "sent" : "received"}">
            ${escHtml(msg.text || "")}
          </div>
          <div class="msg-time">${time}</div>
        </div>
      </div>`;
  }).join("");

  container.scrollTop = container.scrollHeight;
}

window.sendAdminMessage = async function () {
  if (!selectedUserId) return;

  const input   = document.getElementById("chatInput");
  const sendBtn = document.getElementById("sendBtn");
  const text    = input.value.trim();
  if (!text) return;

  sendBtn.disabled = true;
  input.disabled   = true;

  try {
    const now = serverTimestamp();

    await addDoc(
      collection(db, "chats", selectedUserId, "messages"),
      {
        text:       text,
        senderId:   ADMIN_ID,
        senderName: ADMIN_NAME,
        isAdmin:    true,
        timestamp:  now,
      }
    );

    await setDoc(
      doc(db, "chats", selectedUserId),
      { lastMessage: text, lastTimestamp: now },
      { merge: true }
    );

    input.value        = "";
    input.style.height = "auto";

  } catch (err) {
    console.error("Send error:", err);
    alert("Failed to send:\n" + err.message);
  } finally {
    sendBtn.disabled = false;
    input.disabled   = false;
    input.focus();
  }
};

function formatTime(ts) {
  if (!ts) return "";
  const date = ts.toDate ? ts.toDate() : new Date((ts.seconds || 0) * 1000);
  const diff = Date.now() - date.getTime();
  if (diff < 60_000)     return "Just now";
  if (diff < 3_600_000)  return Math.floor(diff / 60_000) + "m ago";
  if (diff < 86_400_000) return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  return date.toLocaleDateString([], { month: "short", day: "numeric" });
}

function escHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}