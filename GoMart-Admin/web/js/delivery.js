import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut } 
  from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, getDocs, query, orderBy } 
  from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db = getFirestore(app);

let allOrders = [];

onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadDeliveries();
  }
});

document.getElementById("logoutBtn").addEventListener("click", async (e) => {
  e.preventDefault();
  await signOut(auth);
  window.location.href = "index.html";
});

async function loadDeliveries() {
  const table = document.getElementById("deliveryTable");
  table.innerHTML = `<tr><td colspan="5" class="loading">Loading deliveries...</td></tr>`;

  try {
    const snap = await getDocs(query(collection(db, "orders"), orderBy("orderDate", "desc")));
    allOrders = [];
    snap.forEach(d => allOrders.push({ id: d.id, ...d.data() }));

    updateStats();
    renderTable(allOrders);
  } catch (e) {
    console.error("Load error:", e);
    table.innerHTML = `<tr><td colspan="5" style="color:#ef4444;text-align:center;">Failed to load deliveries</td></tr>`;
  }
}

function updateStats() {
  const count = (status) =>
    allOrders.filter(o =>
      (o.status || "").toLowerCase() === status
    ).length;

  document.getElementById("totalDeliveries")
          .textContent = allOrders.length;

  document.getElementById("processingCount")
          .textContent = count("processing");

  document.getElementById("shippedCount")
          .textContent = count("shipped");

  document.getElementById("deliveredCount")
          .textContent = count("delivered");

  document.getElementById("cancelledCount")
          .textContent = count("cancelled");
}

function resolveDeliveryAddress(order) {
  const hasBilling = order.billingAddress && order.billingAddress.address && order.billingAddress.address.trim() !== "";
  return hasBilling ? order.billingAddress : order.shippingAddress;
}

function getStatusClass(status) {
  const classes = {
    pending: "s-pending",
    processing: "s-processing",
    shipped: "s-shipped",
    delivered: "s-delivered",
    cancelled: "s-cancelled"
  };
  return classes[status] || "s-pending";
}

function renderTable(orders) {
  const table = document.getElementById("deliveryTable");
  if (orders.length === 0) {
    table.innerHTML = `<tr><td colspan="5" class="empty-state">No deliveries found</td></tr>`;
    return;
  }

  table.innerHTML = orders.map(o => {
    const customerName = o.shippingAddress?.name || "—";
    const deliveryAddr = resolveDeliveryAddress(o);
    const address = deliveryAddr?.address || "—";
    const status = (o.status || "pending").toLowerCase();

    return `
      <tr>
        <td><span class="order-id">#${o.id.substring(0, 6).toUpperCase()}</span></td>
        <td><div class="customer-name">${customerName}</div></td>
        <td><div class="customer-address">${address}</div></td>
        <td><span class="status-pill ${getStatusClass(status)}">${status.toUpperCase()}</span></td>
        <td><button class="btn-view" onclick="openDeliveryModal('${o.id}')">View</button></td>
      </tr>`;
  }).join('');
}

window.filterDeliveries = function (status, btn) {
  document.querySelectorAll(".filter-btn").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");
  const filtered = status === "all" ? allOrders : allOrders.filter(o => (o.status || "").toLowerCase() === status);
  renderTable(filtered);
};

window.searchDeliveries = function () {
  const q = document.getElementById("searchInput").value.toLowerCase();
  const filtered = allOrders.filter(o => (o.shippingAddress?.name || "").toLowerCase().includes(q));
  renderTable(filtered);
};

window.openDeliveryModal = function (id) {
  const order = allOrders.find(o => o.id === id);
  if (!order) return;

  document.getElementById("modalOrderId").textContent = `Order #${id.substring(0, 6).toUpperCase()}`;
  const date = order.orderDate?.seconds ? new Date(order.orderDate.seconds * 1000).toLocaleString() : "—";
  document.getElementById("modalOrderDate").textContent = date;

  const status = (order.status || "pending").toLowerCase();
  document.getElementById("modalStatus").innerHTML = `<span class="status-pill ${getStatusClass(status)}">${status.toUpperCase()}</span>`;

  document.getElementById("modalName").textContent = order.shippingAddress?.name || "—";
  document.getElementById("modalContact").textContent = order.shippingAddress?.contact || "—";
  document.getElementById("modalEmail").textContent = order.shippingAddress?.email || "—";

  const deliveryAddr = resolveDeliveryAddress(order);
  document.getElementById("modalAddress").textContent = deliveryAddr?.address || "—";
  
  const hasBilling = order.billingAddress?.address?.trim();
  document.getElementById("modalAddressName").textContent = hasBilling 
    ? (order.billingAddress.name ? `Recipient: ${order.billingAddress.name}` : "Recipient Address")
    : (order.shippingAddress?.addressName || "—");

  const STEPS = [
    { key: "pending", label: "Order Placed" },
    { key: "processing", label: "Processing" },
    { key: "shipped", label: "Shipped" },
    { key: "delivered", label: "Delivered" }
  ];

  const timeline = document.getElementById("modalTimeline");
  timeline.innerHTML = "";

  if (status === "cancelled") {
    timeline.innerHTML = `
      <div class="timeline-item"><div class="timeline-dot done"></div><div class="timeline-label">Order Placed</div><div class="timeline-time">Completed</div></div>
      <div class="timeline-item"><div class="timeline-dot cancelled-dot"></div><div class="timeline-label">Cancelled</div><div class="timeline-time">Order Terminated</div></div>`;
  } else {
    const currentIndex = STEPS.findIndex(s => s.key === status);
    timeline.innerHTML = STEPS.map((step, index) => {
      let dotClass = index < currentIndex ? "done" : (index === currentIndex ? "active" : "");
      let timeLabel = index < currentIndex ? "Completed" : (index === currentIndex ? "In Progress" : "Pending");
      return `
        <div class="timeline-item">
          <div class="timeline-dot ${dotClass}"></div>
          <div class="timeline-label">${step.label}</div>
          <div class="timeline-time">${timeLabel}</div>
        </div>`;
    }).join('');
  }

  document.getElementById("deliveryModal").classList.add("show");
};

window.closeDeliveryModal = () => document.getElementById("deliveryModal").classList.remove("show");