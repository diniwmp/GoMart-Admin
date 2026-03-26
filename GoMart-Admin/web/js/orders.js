import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import {
  getFirestore, collection, getDocs, getDoc,
    doc, updateDoc, addDoc, query, orderBy, Timestamp
    } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db = getFirestore(app);

let allOrders = [];
let currentOrderId = null;

onAuthStateChanged(auth, (user) => {
if (!user) {
    window.location.href = "index.html";
} else {
    document.getElementById("adminEmail").textContent = user.email;
    loadOrders();
}
});

document.getElementById("logoutBtn").addEventListener("click", async (e) => {
e.preventDefault();
await signOut(auth);
window.location.href = "index.html";
});

async function loadOrders() {
const table = document.getElementById("ordersTable");
table.innerHTML = `<tr><td colspan="6" class="loading">Loading orders...</td></tr>`;

try {
    const snap = await getDocs(
            query(collection(db, "orders"), orderBy("orderDate", "desc"))
            );

    allOrders = [];
    snap.forEach(docSnap => {
        allOrders.push({id: docSnap.id, ...docSnap.data() });
        });

        updateStats();
        renderTable(allOrders);

    } catch (e) {
        console.error("Load orders error:", e);
        table.innerHTML = `<tr><td colspan="6" style="color:#ef4444;text-align:center;font-size:13px">Failed to load orders</td></tr>`;
    }
}

function updateStats() {
    document.getElementById("totalOrders").textContent = allOrders.length;
    document.getElementById("pendingOrders").textContent =
            allOrders.filter(o => (o.status || "").toLowerCase() === "pending").length;
    document.getElementById("processingOrders").textContent =
            allOrders.filter(o => (o.status || "").toLowerCase() === "processing").length;
    document.getElementById("deliveredOrders").textContent =
            allOrders.filter(o =>
                ["delivered", "paid"].includes((o.status || "").toLowerCase())
            ).length;
}

/**
 * Returns the address to display in the table/modal.
 * Logic mirrors the mobile app:
 *   - If billingAddress exists and has a non-empty address → use billingAddress
 *   - Otherwise → use shippingAddress
 */
function resolveDisplayAddress(order) {
    const hasBilling =
        order.billingAddress &&
        order.billingAddress.address &&
        order.billingAddress.address.trim() !== "";

    return hasBilling ? order.billingAddress : order.shippingAddress;
}

function renderTable(orders) {
    const table = document.getElementById("ordersTable");

    if (orders.length === 0) {
        table.innerHTML = `<tr><td colspan="6" class="empty-state">No orders found</td></tr>`;
        return;
    }

    table.innerHTML = "";
    orders.forEach(d => {
        const statusLower = (d.status || "pending").toLowerCase();
        const statusDisplay = statusLower.toUpperCase();

        const statusClass = {
            "pending": "s-pending",
            "delivered": "s-delivered",
            "processing": "s-processing",
            "cancelled": "s-cancelled",
            "paid": "s-paid"
        }[statusLower] || "s-pending";

        // Always show sender (payer) name/email from shippingAddress
        const customerName  = d.shippingAddress?.name  || "-";
        const customerEmail = d.shippingAddress?.email || "-";

        const date = d.orderDate?.seconds
                ? new Date(d.orderDate.seconds * 1000).toLocaleDateString()
                : "-";

        const amount = d.totalAmount
                ? `Rs. ${parseFloat(d.totalAmount).toFixed(2)}`
                : "-";

        table.innerHTML += `
            <tr>
                <td><span class="order-id">#${d.id.substring(0, 6).toUpperCase()}</span></td>
                <td>
                    <div class="customer-name">${customerName}</div>
                    <div class="customer-email">${customerEmail}</div>
                </td>
                <td><span class="order-amount">${amount}</span></td>
                <td><span class="status-pill ${statusClass}">${statusDisplay}</span></td>
                <td>${date}</td>
                <td>
                    <button class="btn-view" onclick="openOrderModal('${d.id}')">View</button>
                </td>
            </tr>`;
    });
}

window.filterOrders = function (status, btn) {
    document.querySelectorAll(".filter-btn")
            .forEach(b => b.classList.remove("active"));
    btn.classList.add("active");

    const filtered = status === "all"
            ? allOrders
            : allOrders.filter(o =>
                (o.status || "").toLowerCase() === status.toLowerCase());

    renderTable(filtered);
};

window.searchOrders = function () {
    const q = document.getElementById("searchInput").value.toLowerCase();
    const filtered = allOrders.filter(o => {
        const name = (o.shippingAddress?.name || "").toLowerCase();
        return name.includes(q);
    });
    renderTable(filtered);
};

window.openOrderModal = function (id) {
    const order = allOrders.find(o => o.id === id);
    if (!order) return;

    currentOrderId = id;

    document.getElementById("modalOrderId").textContent = `Order #${id.substring(0, 6).toUpperCase()}`;
    const date = order.orderDate?.seconds
            ? new Date(order.orderDate.seconds * 1000).toLocaleString()
            : "-";
    document.getElementById("modalOrderDate").textContent = date;

    // ── Sender / payer info always comes from shippingAddress ──
    document.getElementById("modalCustomerName").textContent    = order.shippingAddress?.name    || "-";
    document.getElementById("modalCustomerEmail").textContent   = order.shippingAddress?.email   || "-";
    document.getElementById("modalCustomerContact").textContent = order.shippingAddress?.contact || "-";

    // ── Delivery address: billing if present, else shipping ──
    const hasBilling =
        order.billingAddress &&
        order.billingAddress.address &&
        order.billingAddress.address.trim() !== "";

    const displayAddr = hasBilling ? order.billingAddress : order.shippingAddress;

    document.getElementById("modalAddress").textContent =
            displayAddr?.address || "-";

    // Show a clear label so admin knows whether this is
    // the buyer's own address or a different recipient
    if (hasBilling) {
        // Recipient / billing address
        const recipientName = order.billingAddress?.name || "";
        document.getElementById("modalAddressName").textContent =
                recipientName ? `Recipient: ${recipientName}` : "Recipient Address";
    } else {
        // Buyer's own saved address label (e.g. "Home", "Office")
        document.getElementById("modalAddressName").textContent =
                order.shippingAddress?.addressName || "-";
    }

    // ── Order items ──
    const itemsContainer = document.getElementById("modalItems");
    itemsContainer.innerHTML = "";

    if (order.orderItems && order.orderItems.length > 0) {
        order.orderItems.forEach(item => {
            const subtotal = (item.unitPrice * item.quantity).toFixed(2);
            itemsContainer.innerHTML += `
        <div class="item-row">
          <div>
            <div class="item-name">${item.productId || "Product"}</div>
            <div class="item-qty">Qty: ${item.quantity} × Rs. ${item.unitPrice}</div>
          </div>
          <div class="item-price">Rs. ${subtotal}</div>
        </div>`;
        });
    } else {
        itemsContainer.innerHTML = `<div style="font-size:13px;color:#94a3b8;padding:8px 0">No items found</div>`;
    }

    document.getElementById("modalTotal").textContent = order.totalAmount
            ? `Rs. ${parseFloat(order.totalAmount).toFixed(2)}`
            : "-";

    document.getElementById("modalStatusSelect").value = order.status || "pending";

    document.getElementById("orderModal").classList.add("show");
};

window.closeOrderModal = function () {
    document.getElementById("orderModal").classList.remove("show");
    currentOrderId = null;
};

window.updateOrderStatus = async function () {
    if (!currentOrderId) return;

    const newStatus = document.getElementById("modalStatusSelect").value;
    const order = allOrders.find(o => o.id === currentOrderId);
    if (!order) return;

    const btnUpdate = document.getElementById("btnUpdateStatus");
    if (btnUpdate) {
        btnUpdate.disabled = true;
        btnUpdate.textContent = "Updating...";
    }

    try {
        await updateDoc(doc(db, "orders", currentOrderId), {
            status: newStatus
        });
        if (order.userId && currentOrderId) {
            await saveInAppNotification(order.userId, newStatus, currentOrderId);
            await sendFcmNotification(order.userId, newStatus, currentOrderId);
        }

        order.status = newStatus;
        updateStats();
        renderTable(allOrders);

        const select = document.getElementById("modalStatusSelect");
        select.style.borderColor = "#22c55e";
        setTimeout(() => { select.style.borderColor = ""; }, 2000);

        showToast(`Order status updated to "${newStatus}"`);

    } catch (e) {
        console.error("Update status error:", e);
        showToast("Failed to update status", "error");
    } finally {
        if (btnUpdate) {
            btnUpdate.disabled = false;
            btnUpdate.textContent = "Update Status";
        }
    }
};

async function saveInAppNotification(userId, status, orderId) {
    const shortId = orderId.substring(0, 6).toUpperCase();
    const title   = getStatusTitle(status);
    const message = getStatusMessage(status, shortId);

    try {
        await addDoc(
                collection(db, "notifications", userId, "items"),
                {
                    title: title,
                    message: message,
                    type: "ORDER",
                    orderId: orderId,
                    isRead: false,
                    timestamp: Timestamp.now()
                }
        );
        console.log("Notification saved for:", userId);
    } catch (e) {
        console.error("Save failed:", e);
    }
}

async function sendFcmNotification(userId, status, orderId) {
    if (!orderId) { console.warn("No orderId provided, skipping FCM"); return; }

    try {
        const userSnap = await getDoc(doc(db, "users", userId));
        const fcmToken = userSnap.data()?.fcmToken;

        if (!fcmToken) { console.warn("No FCM token for user:", userId); return; }

        const shortId = orderId.substring(0, 6).toUpperCase();
        const title   = getStatusTitle(status);
        const message = getStatusMessage(status, shortId);

        const response = await fetch(
                "http://localhost:8080/GoMart-Admin/api/notifications/send",
                {
                    method: "POST",
                    headers: {"Content-Type": "application/json"},
                    body: JSON.stringify({ token: fcmToken, title, message, orderId, type: "ORDER" })
                }
        );

        if (response.ok) { console.log("FCM sent to:", userId); }
        else             { console.warn("FCM failed:", response.status); }

    } catch (e) {
        console.warn("FCM skipped:", e.message);
    }
}

function getStatusTitle(status) {
    const titles = {
        processing: "Order Processing",
        shipped:    "Order Shipped!",
        delivered:  "Order Delivered!",
        cancelled:  "Order Cancelled"
    };
    return titles[status] || "Order Update";
}

function getStatusMessage(status, shortId) {
    const messages = {
        processing: `Your order #${shortId} has been confirmed and is now being prepared by our team.`,
        shipped:    `Your order #${shortId} is on the way! Our delivery team has picked it up and is heading to your address.`,
        delivered:  `Your order #${shortId} has been successfully delivered. We hope you enjoy your groceries! Thank you for shopping with GoMart.`,
        cancelled:  `Your order #${shortId} has been cancelled. If you have any questions, please contact our support team.`
    };
    return messages[status] || `Your order #${shortId} status has been updated to ${status}.`;
}

function showToast(message, type = "success") {
    let toast = document.getElementById("adminToast");
    if (!toast) {
        toast = document.createElement("div");
        toast.id = "adminToast";
        toast.style.cssText = `
      position: fixed; bottom: 24px; right: 24px;
      padding: 12px 20px; border-radius: 8px;
      font-size: 14px; font-weight: 500;
      color: white; z-index: 9999;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      transition: opacity 0.3s;
    `;
        document.body.appendChild(toast);
    }

    toast.textContent    = message;
    toast.style.background = type === "error" ? "#ef4444" : "#22c55e";
    toast.style.opacity  = "1";
    toast.style.display  = "block";

    setTimeout(() => {
        toast.style.opacity = "0";
        setTimeout(() => { toast.style.display = "none"; }, 300);
    }, 3000);
}