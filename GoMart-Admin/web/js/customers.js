import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, getDocs, query, where, orderBy } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db = getFirestore(app);

let allCustomers = [];
let allOrders = [];

// ── Auth check ───────────────────────────────────────────
onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadCustomers();
  }
});

// ── Logout ───────────────────────────────────────────────
document.getElementById("logoutBtn").addEventListener("click", async (e) => {
  e.preventDefault();
  await signOut(auth);
  window.location.href = "index.html";
});

// ── Load customers and orders ────────────────────────────
async function loadCustomers() {
  const table = document.getElementById("customersTable");
  table.innerHTML = `<tr><td colspan="5" class="loading">Loading customers...</td></tr>`;

  try {
    // load both users and orders together
    const [userSnap, orderSnap] = await Promise.all([
      getDocs(collection(db, "users")),
      getDocs(collection(db, "orders"))
    ]);

    allOrders = [];
    orderSnap.forEach(d => allOrders.push({ id: d.id, ...d.data() }));

    allCustomers = [];
    userSnap.forEach(d => allCustomers.push({ id: d.id, ...d.data() }));

    updateStats();
    renderTable(allCustomers);

  } catch (e) {
    console.error("Load customers error:", e);
    table.innerHTML = `<tr><td colspan="5" style="color:#ef4444;text-align:center;font-size:13px">Failed to load customers</td></tr>`;
  }
}

// ── Get order count for a user ───────────────────────────
function getOrderCount(userId) {
  return allOrders.filter(o => o.userId === userId).length;
}

// ── Update stats ─────────────────────────────────────────
function updateStats() {
  const total = allCustomers.length;
  const withOrders = allCustomers.filter(c => getOrderCount(c.uid || c.id) > 0).length;

  document.getElementById("totalCustomers").textContent = total;
  document.getElementById("withOrders").textContent = withOrders;
  document.getElementById("noOrders").textContent = total - withOrders;
  document.getElementById("customerCount").textContent = `(${total})`;
}

// ── Render table ─────────────────────────────────────────
function renderTable(customers) {
  const table = document.getElementById("customersTable");

  if (customers.length === 0) {
    table.innerHTML = `<tr><td colspan="5" class="empty-state">No customers found</td></tr>`;
    return;
  }

  table.innerHTML = "";
  customers.forEach(c => {
    // uid, name, email, mobile, profilePicUrl match User model
    const uid = c.uid || c.id;
    const name = c.name || "—";
    const email = c.email || "—";
    const mobile = c.mobile || "—";
    const pic = c.profilePicUrl || "";
    const orderCount = getOrderCount(uid);
    const initials = name !== "—" ? name.charAt(0).toUpperCase() : "?";

    const avatarHtml = pic
      ? `<img src="${pic}" class="customer-avatar" onerror="this.style.display='none'">`
      : `<div class="customer-avatar-placeholder">${initials}</div>`;

    table.innerHTML += `
      <tr>
        <td>
          <div style="display:flex;align-items:center;gap:10px">
            ${avatarHtml}
            <div>
              <div class="customer-name">${name}</div>
              <div class="customer-uid">${uid.substring(0, 10)}...</div>
            </div>
          </div>
        </td>
        <td>${mobile}</td>
        <td><div class="customer-email">${email}</div></td>
        <td>
          <span style="font-weight:600;color:${orderCount > 0 ? '#22c55e' : '#94a3b8'}">
            ${orderCount}
          </span>
        </td>
        <td>
          <button class="btn-view" onclick="openCustomerModal('${uid}')">View</button>
        </td>
      </tr>`;
  });
}

// ── Search customers ─────────────────────────────────────
window.searchCustomers = function () {
  const q = document.getElementById("searchInput").value.toLowerCase();
  const filtered = allCustomers.filter(c =>
    (c.name || "").toLowerCase().includes(q) ||
    (c.email || "").toLowerCase().includes(q) ||
    (c.mobile || "").toLowerCase().includes(q)
  );
  renderTable(filtered);
};

// ── Open customer modal ──────────────────────────────────
window.openCustomerModal = function (uid) {
  const customer = allCustomers.find(c => (c.uid || c.id) === uid);
  if (!customer) return;

  const name = customer.name || "—";
  const pic = customer.profilePicUrl || "";
  const initials = name !== "—" ? name.charAt(0).toUpperCase() : "?";

  // avatar
  const avatarWrap = document.getElementById("modalAvatarWrap");
  avatarWrap.innerHTML = pic
    ? `<img src="${pic}" class="profile-avatar" onerror="this.style.display='none'">`
    : `<div class="profile-avatar-placeholder">${initials}</div>`;

  document.getElementById("modalName").textContent = name;
  document.getElementById("modalEmail").textContent = customer.email || "—";
  document.getElementById("modalMobile").textContent = customer.mobile || "—";
  document.getElementById("modalUid").textContent = customer.uid || customer.id;

  // customer orders
  const customerOrders = allOrders
    .filter(o => o.userId === uid)
    .sort((a, b) => (b.orderDate?.seconds || 0) - (a.orderDate?.seconds || 0));

  const ordersContainer = document.getElementById("modalOrders");

  if (customerOrders.length === 0) {
    ordersContainer.innerHTML = `<div style="font-size:13px;color:#94a3b8;padding:8px 0">No orders yet</div>`;
  } else {
    ordersContainer.innerHTML = "";
    customerOrders.forEach(o => {
      const date = o.orderDate?.seconds
        ? new Date(o.orderDate.seconds * 1000).toLocaleDateString()
        : "—";
      const amount = o.totalAmount
        ? `Rs. ${parseFloat(o.totalAmount).toFixed(2)}`
        : "—";
      const statusClass = {
        pending: "s-pending",
        processing: "s-processing",
        "out-for-delivery": "s-out-for-delivery",
        delivered: "s-delivered",
        cancelled: "s-cancelled"
      }[o.status] || "s-pending";

      ordersContainer.innerHTML += `
        <div class="order-mini-row">
          <div>
            <div class="order-mini-id">#${o.id.substring(0, 6).toUpperCase()}</div>
            <div class="order-mini-date">${date}</div>
          </div>
          <span class="status-pill ${statusClass}">${o.status || "pending"}</span>
          <div class="order-mini-amount">${amount}</div>
        </div>`;
    });
  }

  document.getElementById("customerModal").classList.add("show");
};

window.closeCustomerModal = function () {
  document.getElementById("customerModal").classList.remove("show");
};
