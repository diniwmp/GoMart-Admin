import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut }
  from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, getDocs, query, orderBy }
  from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db   = getFirestore(app);

let allOrders = [];

onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadDeliveries();
  }
});

document.getElementById("logoutBtn")
  .addEventListener("click", async (e) => {
    e.preventDefault();
    await signOut(auth);
    window.location.href = "index.html";
  });

async function loadDeliveries() {
  const table = document.getElementById("deliveryTable");
  table.innerHTML = `<tr><td colspan="5" class="loading">
    Loading deliveries...</td></tr>`;

  try {
    const snap = await getDocs(
      query(collection(db, "orders"),
            orderBy("orderDate", "desc"))
    );

    allOrders = [];
    snap.forEach(d =>
      allOrders.push({ id: d.id, ...d.data() }));

    updateStats();
    renderTable(allOrders);

  } catch (e) {
    console.error("Load error:", e);
    table.innerHTML = `<tr><td colspan="5"
      style="color:#ef4444;text-align:center;font-size:13px">
      Failed to load deliveries</td></tr>`;
  }
}

function updateStats() {
  document.getElementById("totalDeliveries").textContent =
          allOrders.length;
  document.getElementById("pendingCount").textContent =
          allOrders.filter(o =>
                  o.status === "pending").length;
  document.getElementById("processingCount").textContent =
          allOrders.filter(o =>
                  o.status === "processing").length;
  document.getElementById("deliveredCount").textContent =
          allOrders.filter(o =>
                  o.status === "delivered").length;
}

function renderTable(orders) {
  const table = document.getElementById("deliveryTable");

  if (orders.length === 0) {
    table.innerHTML = `<tr><td colspan="5" class="empty-state">
      No deliveries found</td></tr>`;
    return;
  }

  table.innerHTML = "";
  orders.forEach(o => {
    const customerName = o.shippingAddress?.name    || "—";
    const address      = o.shippingAddress?.address || "—";
    const statusClass  = getStatusClass(o.status);
    const status       = o.status || "pending";

    table.innerHTML += `
      <tr>
        <td>
          <span class="order-id">
            #${o.id.substring(0, 6).toUpperCase()}
          </span>
        </td>
        <td>
          <div class="customer-name">${customerName}</div>
        </td>
        <td>
          <div class="customer-address">${address}</div>
        </td>
        <td>
          <span class="status-pill ${statusClass}">
            ${formatStatus(status)}
          </span>
        </td>
        <td>
          <button class="btn-view"
                  onclick="openDeliveryModal('${o.id}')">
            View
          </button>
        </td>
      </tr>`;
  });
}

function getStatusClass(status) {
  return {
    pending:    "s-pending",
    processing: "s-processing",
    delivered:  "s-delivered",
    cancelled:  "s-cancelled"
  }[status] || "s-pending";
}

function formatStatus(status) {
  return {
    pending:    "Pending",
    processing: "Processing",
    delivered:  "Delivered",
    cancelled:  "Cancelled"
  }[status] || status;
}

window.filterDeliveries = function (status, btn) {
  document.querySelectorAll(".filter-btn")
          .forEach(b => b.classList.remove("active"));
  btn.classList.add("active");

  const filtered = status === "all"
    ? allOrders
    : allOrders.filter(o => o.status === status);

  renderTable(filtered);
};

window.searchDeliveries = function () {
  const q = document.getElementById("searchInput")
                    .value.toLowerCase();
  const filtered = allOrders.filter(o =>
    (o.shippingAddress?.name || "")
            .toLowerCase().includes(q)
  );
  renderTable(filtered);
};

window.openDeliveryModal = function (id) {
  const order = allOrders.find(o => o.id === id);
  if (!order) return;

  document.getElementById("modalOrderId").textContent =
          `Order #${id.substring(0, 6).toUpperCase()}`;

  const date = order.orderDate?.seconds
    ? new Date(order.orderDate.seconds * 1000)
              .toLocaleString()
    : "—";
  document.getElementById("modalOrderDate")
          .textContent = date;

  document.getElementById("modalName").textContent =
          order.shippingAddress?.name    || "—";
  document.getElementById("modalContact").textContent =
          order.shippingAddress?.contact || "—";
  document.getElementById("modalEmail").textContent =
          order.shippingAddress?.email   || "—";
  document.getElementById("modalAddress").textContent =
          order.shippingAddress?.address     || "—";
  document.getElementById("modalAddressName").textContent =
          order.shippingAddress?.addressName || "—";

  const statusClass = getStatusClass(order.status);
  document.getElementById("modalStatus").innerHTML =
          `<span class="status-pill ${statusClass}">
            ${formatStatus(order.status || "pending")}
          </span>`;

  const STEPS = [
    { key: "pending",    label: "Order Placed"  },
    { key: "processing", label: "Processing"    },
    { key: "delivered",  label: "Delivered"     },
    { key: "cancelled",  label: "Cancelled"     }
  ];

  const currentIndex = STEPS.findIndex(
          s => s.key === order.status);
  const timeline =
          document.getElementById("modalTimeline");
  timeline.innerHTML = "";

  STEPS.forEach((step, index) => {
    let dotClass = "";
    if      (index < currentIndex)   dotClass = "done";
    else if (index === currentIndex) dotClass = "active";

    timeline.innerHTML += `
      <div class="timeline-item">
        <div class="timeline-dot ${dotClass}"></div>
        <div class="timeline-label">${step.label}</div>
        <div class="timeline-time">
          ${index <= currentIndex
                  ? "Completed"
                  : "Pending"}
        </div>
      </div>`;
  });

  document.getElementById("deliveryModal")
          .classList.add("show");
};

window.closeDeliveryModal = function () {
  document.getElementById("deliveryModal")
          .classList.remove("show");
};