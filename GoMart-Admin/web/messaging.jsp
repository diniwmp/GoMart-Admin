<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>GoMart Admin - Messages</title>
        <link rel="icon" type="image/png" href="images/logo.png" />
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
            }
            body {
                background: #f1f5f9;
                margin: 0;
                font-family: sans-serif;
                overflow: hidden;
            }

            .sidebar {
                width: 220px;
                min-height: 100vh;
                background: #1a2332;
                position: fixed;
                top: 0;
                left: 0;
                display: flex;
                flex-direction: column;
                z-index: 10;
            }
            .sidebar-logo {
                padding: 20px 16px;
                border-bottom: 1px solid rgba(255,255,255,0.08);
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .logo-text {
                color: #fff;
                font-size: 18px;
                font-weight: 600;
            }
            .logo-sub {
                color: rgba(255,255,255,0.35);
                font-size: 11px;
            }
            .nav-section {
                padding: 14px 16px 4px;
                font-size: 10px;
                color: rgba(255,255,255,0.3);
                text-transform: uppercase;
                letter-spacing: 0.08em;
            }
            .sidebar a {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 9px 14px;
                margin: 1px 8px;
                border-radius: 6px;
                color: rgba(255,255,255,0.65);
                text-decoration: none;
                font-size: 13px;
                transition: all 0.15s;
            }
            .sidebar a:hover, .sidebar a.active {
                background: rgba(34,197,94,0.15);
                color: #22c55e;
            }
            .sidebar-bottom {
                margin-top: auto;
                padding: 8px;
                border-top: 1px solid rgba(255,255,255,0.08);
            }

            .main-content {
                margin-left: 220px;
                height: 100vh;
                display: flex;
                flex-direction: column;
            }
            .topbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 20px 28px 16px;
                flex-shrink: 0;
            }
            .page-title {
                font-size: 20px;
                font-weight: 600;
                color: #1a2332;
                margin: 0;
            }
            .page-sub {
                font-size: 13px;
                color: #64748b;
                margin: 2px 0 0;
            }
            .admin-badge {
                display: flex;
                align-items: center;
                gap: 8px;
                background: #fff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 6px 14px 6px 8px;
            }
            .admin-avatar {
                width: 28px;
                height: 28px;
                border-radius: 50%;
                background: #22c55e20;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 11px;
                font-weight: 600;
                color: #22c55e;
            }
            .admin-name {
                font-size: 12px;
                font-weight: 500;
                color: #1a2332;
            }

            .chat-wrapper {
                display: flex;
                flex: 1;
                overflow: hidden;
                padding: 0 28px 28px;
                gap: 16px;
            }

            .user-list-panel {
                width: 300px;
                flex-shrink: 0;
                background: #fff;
                border-radius: 14px;
                border: 1px solid #e2e8f0;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }
            .user-list-header {
                padding: 16px;
                border-bottom: 1px solid #f1f5f9;
            }
            .user-list-title {
                font-size: 14px;
                font-weight: 600;
                color: #1a2332;
                margin: 0 0 10px;
            }
            .user-search {
                width: 100%;
                padding: 8px 12px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-size: 12px;
                outline: none;
                color: #1a2332;
            }
            .user-search:focus {
                border-color: #22c55e;
                box-shadow: 0 0 0 3px #22c55e20;
            }
            .user-list-body {
                flex: 1;
                overflow-y: auto;
            }
            .user-item {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 12px 16px;
                cursor: pointer;
                border-bottom: 1px solid #f8fafc;
                transition: background 0.12s;
            }
            .user-item:hover {
                background: #f8fafc;
            }
            .user-item.active {
                background: #f0fdf4;
                border-left: 3px solid #22c55e;
            }
            .user-avatar {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                background: #e2e8f0;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 14px;
                font-weight: 600;
                color: #475569;
                flex-shrink: 0;
            }
            .user-info {
                flex: 1;
                min-width: 0;
            }
            .user-name {
                font-size: 13px;
                font-weight: 600;
                color: #1a2332;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            .user-preview {
                font-size: 11px;
                color: #94a3b8;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                margin-top: 2px;
            }
            .user-time {
                font-size: 10px;
                color: #cbd5e1;
                flex-shrink: 0;
            }
            .user-list-empty {
                text-align: center;
                padding: 40px 20px;
                color: #94a3b8;
                font-size: 13px;
            }

            .chat-panel {
                flex: 1;
                background: #fff;
                border-radius: 14px;
                border: 1px solid #e2e8f0;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }
            .chat-header {
                padding: 14px 18px;
                border-bottom: 1px solid #f1f5f9;
                display: flex;
                align-items: center;
                gap: 12px;
                flex-shrink: 0;
            }
            .chat-header-avatar {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                background: #e2e8f0;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 15px;
                font-weight: 600;
                color: #475569;
            }
            .chat-header-name {
                font-size: 14px;
                font-weight: 600;
                color: #1a2332;
            }
            .chat-header-email {
                font-size: 11px;
                color: #94a3b8;
            }
            .chat-header-status {
                margin-left: auto;
                font-size: 11px;
                color: #22c55e;
                background: #f0fdf4;
                padding: 3px 10px;
                border-radius: 20px;
            }

            .chat-messages {
                flex: 1;
                overflow-y: auto;
                padding: 16px 18px;
                display: flex;
                flex-direction: column;
                gap: 8px;
                background: #fafbfc;
            }

            .msg-row {
                display: flex;
                align-items: flex-end;
                gap: 8px;
            }
            .msg-row.sent {
                flex-direction: row-reverse;
            }
            .msg-bubble-wrap {
                display: flex;
                flex-direction: column;
                max-width: 65%;
            }
            .msg-row.sent .msg-bubble-wrap {
                align-items: flex-end;
            }
            .msg-sender-label {
                font-size: 10px;
                color: #22c55e;
                font-weight: 600;
                margin-bottom: 3px;
            }
            .msg-bubble {
                padding: 9px 13px;
                border-radius: 16px;
                font-size: 13px;
                line-height: 1.5;
                word-break: break-word;
            }
            .msg-bubble.received {
                background: #fff;
                border: 1px solid #e2e8f0;
                color: #1a2332;
                border-bottom-left-radius: 4px;
            }
            .msg-bubble.sent {
                background: #22c55e;
                color: #fff;
                border-bottom-right-radius: 4px;
            }
            .msg-time {
                font-size: 10px;
                color: #cbd5e1;
                margin-top: 3px;
            }
            .msg-avatar-sm {
                width: 28px;
                height: 28px;
                border-radius: 50%;
                background: #e2e8f0;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 11px;
                font-weight: 600;
                color: #475569;
                flex-shrink: 0;
            }
            .msg-avatar-sm.admin {
                background: #22c55e20;
                color: #22c55e;
            }

            .chat-placeholder {
                flex: 1;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                color: #94a3b8;
                gap: 10px;
            }
            .chat-placeholder-icon {
                font-size: 40px;
                opacity: 0.4;
            }
            .chat-placeholder-text {
                font-size: 14px;
            }

            .chat-input-row {
                padding: 12px 18px;
                border-top: 1px solid #f1f5f9;
                display: flex;
                gap: 10px;
                align-items: flex-end;
                flex-shrink: 0;
            }
            .chat-input {
                flex: 1;
                border: 1px solid #e2e8f0;
                border-radius: 10px;
                padding: 10px 14px;
                font-size: 13px;
                outline: none;
                resize: none;
                line-height: 1.4;
                max-height: 120px;
                overflow-y: auto;
                color: #1a2332;
                font-family: sans-serif;
            }
            .chat-input:focus {
                border-color: #22c55e;
                box-shadow: 0 0 0 3px #22c55e20;
            }
            .chat-input:disabled {
                background: #f8fafc;
                cursor: not-allowed;
            }
            .btn-send {
                background: #22c55e;
                color: #fff;
                border: none;
                border-radius: 10px;
                width: 42px;
                height: 42px;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                flex-shrink: 0;
                font-size: 16px;
                transition: background 0.15s;
            }
            .btn-send:hover {
                background: #16a34a;
            }
            .btn-send:disabled {
                background: #86efac;
                cursor: not-allowed;
            }

            .loading-msg {
                text-align: center;
                color: #94a3b8;
                font-size: 12px;
                padding: 20px;
            }
            .user-list-body::-webkit-scrollbar, .chat-messages::-webkit-scrollbar {
                width: 4px;
            }
            .user-list-body::-webkit-scrollbar-thumb, .chat-messages::-webkit-scrollbar-thumb {
                background: #e2e8f0;
                border-radius: 4px;
            }
        </style>
    </head>
    <body>

        <!-- SIDEBAR -->
        <div class="sidebar">
            <div class="sidebar-logo">
                <img src="images/logo.png" alt="GoMart" width="34" height="34" style="border-radius:8px;object-fit:cover;">
                <div>
                    <div class="logo-text">GoMart</div>
                    <div class="logo-sub">Admin Panel</div>
                </div>
            </div>
            <div class="nav-section">Main</div>
            <a href="dashboard.jsp"><i class="fa-solid fa-gauge"></i> Dashboard</a>

            <div class="nav-section">Catalog</div>
            <a href="products.jsp"><i class="fa-solid fa-box"></i> Products</a>
            <a href="categories.jsp"><i class="fa-solid fa-layer-group"></i> Categories</a>
            <a href="brand.jsp" class="active"><i class="fa-solid fa-tags"></i> Brands</a>

            <div class="nav-section">Operations</div>
            <a href="orders.jsp"><i class="fa-solid fa-cart-shopping"></i> Orders</a>
            <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>
            <a href="delivery.jsp"><i class="fa-solid fa-truck"></i> Delivery</a>
            <a href="promotions.jsp"><i class="fa-solid fa-bullhorn"></i> Promotions</a>

            <div class="nav-section">System</div>
            <a href="customers.jsp"><i class="fa-solid fa-users"></i> Customers</a>
            <a href="messaging.jsp"><i class="fa-solid fa-envelope"></i> Messages</a>

            <!--  <a href="settings.jsp">&#9881; Settings</a>-->

            <div class="sidebar-bottom">
                <a href="index.html" id="logoutBtn"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>

        <!-- MAIN -->
        <div class="main-content">
            <div class="topbar">
                <div>
                    <p class="page-title">Messages</p>
                    <p class="page-sub">Chat with your customers</p>
                </div>
                <div class="admin-badge">
                    <div class="admin-avatar">AD</div>
                    <span class="admin-name" id="adminEmail">Admin</span>
                </div>
            </div>

            <div class="chat-wrapper">

                <!-- User List -->
                <div class="user-list-panel">
                    <div class="user-list-header">
                        <p class="user-list-title">Conversations</p>
                        <input type="text" class="user-search" id="userSearch" placeholder="Search customers...">
                    </div>
                    <div class="user-list-body" id="userListBody">
                        <div class="user-list-empty">Loading conversations...</div>
                    </div>
                </div>

                <!-- Chat Panel -->
                <div class="chat-panel">
                    <div class="chat-header" id="chatHeader" style="display:none">
                        <div class="chat-header-avatar" id="chatHeaderAvatar">?</div>
                        <div>
                            <div class="chat-header-name" id="chatHeaderName">—</div>
                            <div class="chat-header-email" id="chatHeaderEmail">—</div>
                        </div>
                        <div class="chat-header-status">● Active</div>
                    </div>

                    <div class="chat-messages" id="chatMessages">
                        <div class="chat-placeholder">
                            <div class="chat-placeholder-icon">&#9993;</div>
                            <div class="chat-placeholder-text">Select a conversation to start</div>
                        </div>
                    </div>

                    <div class="chat-input-row">
                        <textarea class="chat-input" id="chatInput" rows="1"
                                  placeholder="Select a conversation first..." disabled></textarea>
                        <button class="btn-send" id="sendBtn" disabled title="Send">&#9658;</button>
                    </div>
                </div>

            </div>
        </div>

        <!-- ── Single module script — no separate .js file needed ── -->
        <script type="module">
            import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js";
            import { getAuth, onAuthStateChanged, signOut }
            from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
            import { getFirestore, collection, doc, addDoc, onSnapshot, setDoc, serverTimestamp }
            from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

            // ── Firebase config — same as firebase-config.js ──────────────────────────
            // Import from your existing config file
            import { app } from "./js/firebase-config.js";

            const auth = getAuth(app);
            const db = getFirestore(app);

            const ADMIN_ID = "ADMIN";
            const ADMIN_NAME = "GoMart Support";

            // ── State ──────────────────────────────────────────────────────────────────
            let allUsers = [];
            let selectedUserId = null;
            let messagesUnsub = null;

            // ── DOM refs ───────────────────────────────────────────────────────────────
            const userListBody = document.getElementById("userListBody");
            const chatMessages = document.getElementById("chatMessages");
            const chatHeader = document.getElementById("chatHeader");
            const chatInput = document.getElementById("chatInput");
            const sendBtn = document.getElementById("sendBtn");
            const userSearch = document.getElementById("userSearch");

            // ── Auth ───────────────────────────────────────────────────────────────────
            onAuthStateChanged(auth, (user) => {
                if (!user) {
                    window.location.href = "index.html";
                    return;
                }
                document.getElementById("adminEmail").textContent = user.email;
                loadConversations();
            });

            document.getElementById("logoutBtn").addEventListener("click", async (e) => {
                e.preventDefault();
                await signOut(auth);
                window.location.href = "index.html";
            });

            // ── Load all chats ─────────────────────────────────────────────────────────
            function loadConversations() {
                userListBody.innerHTML = `<div class="user-list-empty">Loading...</div>`;

                onSnapshot(
                        collection(db, "chats"),
                        (snapshot) => {
                    allUsers = [];
                    snapshot.forEach((d) => {
                        const data = d.data();
                        allUsers.push({
                            id: d.id,
                            name: data.userName || data.name || "Unknown",
                            email: data.userEmail || data.email || "",
                            lastMessage: data.lastMessage || "",
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
                        (err) => {
                    console.error("Chats load error:", err);
                    userListBody.innerHTML =
                            '<div class="user-list-empty" style="color:#ef4444">Failed to load.<br><small>'
                            + err.message + "</small></div>";
                }
                );
            }

            // ── Render user list ───────────────────────────────────────────────────────
            function renderUserList(users) {
                if (users.length === 0) {
                    userListBody.innerHTML = `<div class="user-list-empty">No conversations yet</div>`;
                    return;
                }

                userListBody.innerHTML = "";

                users.forEach((u) => {
                    const initials = getInitials(u.name);
                    const time = u.lastTimestamp ? formatTime(u.lastTimestamp) : "";

                    const item = document.createElement("div");
                    item.className = "user-item" + (u.id === selectedUserId ? " active" : "");
                    item.innerHTML = '<div class="user-avatar">' + initials + "</div>"
                            + '<div class="user-info">'
                            + '<div class="user-name">' + esc(u.name) + "</div>"
                            + '<div class="user-preview">' + esc(u.lastMessage) + "</div>"
                            + "</div>"
                            + '<div class="user-time">' + time + "</div>";

                    // ── Attach click directly via addEventListener — no onclick attr needed
                    item.addEventListener("click", () => selectUser(u.id, item));
                    userListBody.appendChild(item);
                });
            }

            // ── Select user ────────────────────────────────────────────────────────────
            function selectUser(userId, el) {
                selectedUserId = userId;

                document.querySelectorAll(".user-item").forEach(i => i.classList.remove("active"));
                el.classList.add("active");

                const user = allUsers.find(u => u.id === userId);
                if (!user)
                    return;

                document.getElementById("chatHeaderAvatar").textContent = getInitials(user.name);
                document.getElementById("chatHeaderName").textContent = user.name;
                document.getElementById("chatHeaderEmail").textContent = user.email;
                chatHeader.style.display = "flex";

                chatInput.disabled = false;
                sendBtn.disabled = false;
                chatInput.placeholder = "Type a reply...";
                chatInput.focus();

                if (messagesUnsub) {
                    messagesUnsub();
                    messagesUnsub = null;
                }

                chatMessages.innerHTML = `<div class="loading-msg">Loading messages...</div>`;

                // ── Real-time listener, client-side sort (no index needed) ─────────────
                messagesUnsub = onSnapshot(
                        collection(db, "chats", userId, "messages"),
                        {includeMetadataChanges: false},
                        (snapshot) => {
                    const sorted = snapshot.docs.slice().sort((a, b) => {
                        return (a.data().timestamp?.seconds || 0) - (b.data().timestamp?.seconds || 0);
                    });
                    renderMessages(sorted);
                },
                        (err) => {
                    console.error("Messages error:", err);
                    chatMessages.innerHTML =
                            '<div class="loading-msg" style="color:#ef4444">Error: ' + err.message + "</div>";
                }
                );
            }

            // ── Render messages ────────────────────────────────────────────────────────
            function renderMessages(docs) {
                if (docs.length === 0) {
                    chatMessages.innerHTML = `
                <div class="chat-placeholder">
                  <div class="chat-placeholder-icon">&#9993;</div>
                  <div class="chat-placeholder-text">No messages yet</div>
                </div>`;
                    return;
                }

                chatMessages.innerHTML = docs.map((d) => {
                    const msg = d.data();
                    const isAdmin = msg.isAdmin === true
                            || msg.senderId === ADMIN_ID
                            || msg.senderId === "admin";
                    const time = msg.timestamp ? formatTime(msg.timestamp) : "";
                    const initials = isAdmin ? "G" : getInitials(msg.senderName || "?");

                    const rowClass = "msg-row" + (isAdmin ? " sent" : "");
                    const avatarClass = "msg-avatar-sm" + (isAdmin ? " admin" : "");
                    const bubbleClass = "msg-bubble" + (isAdmin ? " sent" : " received");
                    const senderLabel = !isAdmin
                            ? '<div class="msg-sender-label">' + esc(msg.senderName || "User") + "</div>"
                            : "";

                    return '<div class="' + rowClass + '">'
                            + '<div class="' + avatarClass + '">' + initials + "</div>"
                            + '<div class="msg-bubble-wrap">'
                            + senderLabel
                            + '<div class="' + bubbleClass + '">' + esc(msg.text || "") + "</div>"
                            + '<div class="msg-time">' + time + "</div>"
                            + "</div>"
                            + "</div>";
                }).join("");

                chatMessages.scrollTop = chatMessages.scrollHeight;
            }

            // ── Send admin reply ───────────────────────────────────────────────────────
            async function sendAdminMessage() {
                if (!selectedUserId)
                    return;
                const text = chatInput.value.trim();
                if (!text)
                    return;

                sendBtn.disabled = true;
                chatInput.disabled = true;

                try {
                    const now = serverTimestamp();

                    await addDoc(collection(db, "chats", selectedUserId, "messages"), {
                        text,
                        senderId: ADMIN_ID,
                        senderName: ADMIN_NAME,
                        isAdmin: true,
                        timestamp: now,
                    });

                    await setDoc(
                            doc(db, "chats", selectedUserId),
                            {lastMessage: text, lastTimestamp: now},
                            {merge: true}
                    );

                    chatInput.value = "";
                    chatInput.style.height = "auto";

                } catch (err) {
                    console.error("Send error:", err);
                    alert("Failed to send:\n" + err.message);
                } finally {
                    sendBtn.disabled = false;
                    chatInput.disabled = false;
                    chatInput.focus();
                }
            }

            // ── Wire up send button and Enter key here (same scope) ───────────────────
            sendBtn.addEventListener("click", sendAdminMessage);

            chatInput.addEventListener("keydown", (e) => {
                if (e.key === "Enter" && !e.shiftKey) {
                    e.preventDefault();
                    sendAdminMessage();
                }
            });

            chatInput.addEventListener("input", () => {
                chatInput.style.height = "auto";
                chatInput.style.height = Math.min(chatInput.scrollHeight, 120) + "px";
            });

            // ── Search ─────────────────────────────────────────────────────────────────
            userSearch.addEventListener("input", () => {
                const q = userSearch.value.toLowerCase();
                renderUserList(
                        allUsers.filter(u =>
                            u.name.toLowerCase().includes(q) || u.email.toLowerCase().includes(q)
                        )
                        );
            });

            // ── Helpers ────────────────────────────────────────────────────────────────
            function getInitials(name) {
                return (name || "?").split(" ").map(w => w[0]).join("").substring(0, 2).toUpperCase();
            }

            function formatTime(ts) {
                if (!ts)
                    return "";
                const date = ts.toDate ? ts.toDate() : new Date((ts.seconds || 0) * 1000);
                const diff = Date.now() - date.getTime();
                if (diff < 60_000)
                    return "Just now";
                if (diff < 3_600_000)
                    return Math.floor(diff / 60_000) + "m ago";
                if (diff < 86_400_000)
                    return date.toLocaleTimeString([], {hour: "2-digit", minute: "2-digit"});
                return date.toLocaleDateString([], {month: "short", day: "numeric"});
            }

            function esc(str) {
                return String(str)
                        .replace(/&/g, "&amp;").replace(/</g, "&lt;")
                        .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
            }
        </script>
    </body>
</html>
