import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, getDocs, doc, updateDoc, query, orderBy } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db = getFirestore(app);

let allOrders = [];

// delivery steps in order — mobile app tracks these
const DELIVERY_STEPS = [
  { key: "pending",           label: "Order Placed" },
  { key: "processing",        label: "Processing" },
  { key: "out-for-delivery",  label: "Out for Delivery" },
  { key: "delivered",         label: "Delivered" }
];

// ── Auth check ───────────────────────────────────────────
onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadDeliveries();
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

// ── Status class helper ──────────────────────────────────
function getStatusClass(status) {
  return {
    pending: "s-pending",
    processing: "s-processing",
    "out-for-delivery": "s-out-for-delivery",
    delivered: "s-delivered",
    cancelled: "s-cancelled"
  }[status] || "s-pending";
}

// ── Load deliveries ──────────────────────────────────────
async function loadDeliveries() {
  const table = document.getElementById("deliveryTable");
  table.innerHTML = `<tr><td colspan="6" class="loading">Loading deliveries...</td></tr>`;

  try {
    const snap = await getDocs(
      query(collection(db, "orders"), orderBy("orderDate", "desc"))
    );

    allOrders = [];
    snap.forEach(d => allOrders.push({ id: d.id, ...d.data() }));

    updateStats();
    renderTable(allOrders);

  } catch (e) {
    console.error("Load deliveries error:", e);
    table.innerHTML = `<tr><td colspan="6" style="color:#ef4444;text-align:center;font-size:13px">Failed to load deliveries</td></tr>`;
  }
}

// ── Update stats ─────────────────────────────────────────
function updateStats() {
  document.getElementById("totalDeliveries").textContent = allOrders.length;
  document.getElementById("pendingCount").textContent = allOrders.filter(o => o.status === "pending").length;
  document.getElementById("outForDeliveryCount").textContent = allOrders.filter(o => o.status === "out-for-delivery").length;
  document.getElementById("deliveredCount").textContent = allOrders.filter(o => o.status === "delivered").length;
}

// ── Render table ─────────────────────────────────────────
function renderTable(orders) {
  const table = document.getElementById("deliveryTable");

  if (orders.length === 0) {
    table.innerHTML = `<tr><td colspan="6" class="empty-state">No deliveries found</td></tr>`;
    return;
  }

  table.innerHTML = "";
  orders.forEach(o => {
    // skip cancelled
    if (o.status === "cancelled") return;

    const customerName = o.shippingAddress?.name || "—";
    const address = o.shippingAddress?.address || "—";
    const statusClass = getStatusClass(o.status);
    const currentStatus = o.status || "pending";

    table.innerHTML += `
      <tr>
        <td><span class="order-id">#${o.id.substring(0, 6).toUpperCase()}</span></td>
        <td><div class="customer-name">${customerName}</div></td>
        <td><div class="customer-address">${address}</div></td>
        <td><span class="status-pill ${statusClass}">${formatStatus(currentStatus)}</span></td>
        <td>
          <select class="delivery-select" id="select_${o.id}">
            ${DELIVERY_STEPS.map(s => `
              <option value="${s.key}" ${s.key === currentStatus ? "selected" : ""}>
                ${s.label}
              </option>`).join("")}
            <option value="cancelled" ${currentStatus === "cancelled" ? "selected" : ""}>Cancelled</option>
          </select>
        </td>
        <td>
          <button class="btn-update" onclick="updateDeliveryStatus('${o.id}')">Update</button>
          <button class="btn-view" onclick="openDeliveryModal('${o.id}')">View</button>
        </td>
      </tr>`;
  });
}

// ── Format status label ──────────────────────────────────
function formatStatus(status) {
  return {
    pending: "Pending",
    processing: "Processing",
    "out-for-delivery": "Out for Delivery",
    delivered: "Delivered",
    cancelled: "Cancelled"
  }[status] || status;
}

// ── Filter deliveries ────────────────────────────────────
window.filterDeliveries = function (status, btn) {
  document.querySelectorAll(".filter-btn").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");

  const filtered = status === "all"
    ? allOrders
    : allOrders.filter(o => o.status === status);

  renderTable(filtered);
};

// ── Search deliveries ────────────────────────────────────
window.searchDeliveries = function () {
  const q = document.getElementById("searchInput").value.toLowerCase();
  const filtered = allOrders.filter(o =>
    (o.shippingAddress?.name || "").toLowerCase().includes(q)
  );
  renderTable(filtered);
};

// ── Update delivery status ───────────────────────────────
window.updateDeliveryStatus = async function (id) {
  const select = document.getElementById(`select_${id}`);
  const newStatus = select.value;

  try {
    // update status in orders collection — mobile app reads this
    await updateDoc(doc(db, "orders", id), {
      status: newStatus
    });

    // update local array
    const order = allOrders.find(o => o.id === id);
    if (order) order.status = newStatus;

    updateStats();
    renderTable(allOrders);
    showAlert(`Delivery status updated to "${formatStatus(newStatus)}" successfully!`);

  } catch (e) {
    console.error("Update delivery error:", e);
    showAlert("Failed to update delivery status.", "error");
  }
};

// ── Open delivery detail modal ───────────────────────────
window.openDeliveryModal = function (id) {
  const order = allOrders.find(o => o.id === id);
  if (!order) return;

  document.getElementById("modalOrderId").textContent = `Order #${id.substring(0, 6).toUpperCase()}`;

  const date = order.orderDate?.seconds
    ? new Date(order.orderDate.seconds * 1000).toLocaleString()
    : "—";
  document.getElementById("modalOrderDate").textContent = date;

  // customer info from shippingAddress — matches Order.Address model
  document.getElementById("modalName").textContent = order.shippingAddress?.name || "—";
  document.getElementById("modalContact").textContent = order.shippingAddress?.contact || "—";
  document.getElementById("modalEmail").textContent = order.shippingAddress?.email || "—";
  document.getElementById("modalAddress").textContent = order.shippingAddress?.address || "—";
  document.getElementById("modalAddressName").textContent = order.shippingAddress?.addressName || "—";

  // delivery timeline
  const currentStatus = order.status || "pending";
  const currentIndex = DELIVERY_STEPS.findIndex(s => s.key === currentStatus);
  const timeline = document.getElementById("modalTimeline");
  timeline.innerHTML = "";

  DELIVERY_STEPS.forEach((step, index) => {
    let dotClass = "";
    if (index < currentIndex) dotClass = "done";
    else if (index === currentIndex) dotClass = "active";

    timeline.innerHTML += `
      <div class="timeline-item">
        <div class="timeline-dot ${dotClass}"></div>
        <div class="timeline-label">${step.label}</div>
        <div class="timeline-time">${index <= currentIndex ? "Completed" : "Pending"}</div>
      </div>`;
  });

  document.getElementById("deliveryModal").classList.add("show");
};

window.closeDeliveryModal = function () {
  document.getElementById("deliveryModal").classList.remove("show");
};
