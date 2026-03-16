import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, getDocs } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db = getFirestore(app);

let allCustomers = [];
let allOrders = [];

// Auth check
onAuthStateChanged(auth, (user) => {
    if (!user) {
        window.location.href = "index.html";
    } else {
        document.getElementById("adminEmail").textContent = user.email;
        loadCustomers();
    }
});

// Logout
document.getElementById("logoutBtn").addEventListener("click", async (e) => {
    e.preventDefault();
    await signOut(auth);
    window.location.href = "index.html";
});

// Load customers and orders
async function loadCustomers() {
    const table = document.getElementById("customersTable");
    table.innerHTML = `<tr><td colspan="5" class="loading">Loading customers...</td></tr>`;

    try {
        const [usersSnap, ordersSnap] = await Promise.all([
            getDocs(collection(db, "users")),
            getDocs(collection(db, "orders"))
        ]);

        allCustomers = usersSnap.docs.map(d => ({ id: d.id, ...d.data() }));
        allOrders = ordersSnap.docs.map(d => ({ id: d.id, ...d.data() }));

        updateStats();
        renderTable(allCustomers);

    } catch (e) {
        console.error("Error loading customers:", e);
        table.innerHTML = `<tr><td colspan="5" style="color:#ef4444;text-align:center;font-size:13px">Failed to load customers</td></tr>`;
    }
}

// Get order count for a user
function getOrderCount(uid) {
    return allOrders.filter(o => o.userId === uid).length;
}

// Update stats
function updateStats() {
    const total = allCustomers.length;
    const withOrders = allCustomers.filter(c => getOrderCount(c.id) > 0).length;

    document.getElementById("totalCustomers").textContent = total;
    document.getElementById("withOrders").textContent = withOrders;
    document.getElementById("noOrders").textContent = total - withOrders;
    document.getElementById("customerCount").textContent = `(${total})`;
}

// Render table
function renderTable(customers) {
    const table = document.getElementById("customersTable");
    if (customers.length === 0) {
        table.innerHTML = `<tr><td colspan="5" class="empty-state">No customers found</td></tr>`;
        return;
    }

    table.innerHTML = "";
    customers.forEach(c => {
        const uid = c.id;
        const name = c.name || "—";
        const email = c.email || "—";
        const mobile = c.mobile || "—";
        const orderCount = getOrderCount(uid);

        table.innerHTML += `
            <tr>
                <td>${name}</td>
                <td>${mobile}</td>
                <td>${email}</td>
                <td><span style="font-weight:600;color:${orderCount>0?'#22c55e':'#94a3b8'}">${orderCount}</span></td>
                <td><button class="btn-view" onclick="openCustomerModal('${uid}')">View</button></td>
            </tr>
        `;
    });
}

// Search
window.searchCustomers = function () {
    const q = document.getElementById("searchInput").value.toLowerCase();
    const filtered = allCustomers.filter(c =>
        (c.name && c.name.toLowerCase().includes(q)) ||
        (c.email && c.email.toLowerCase().includes(q)) ||
        (c.mobile && c.mobile.includes(q))
    );
    renderTable(filtered);
};

// Customer modal
window.openCustomerModal = function (uid) {
    const c = allCustomers.find(cust => cust.id === uid);
    if (!c) return;

    document.getElementById("modalName").textContent = c.name || "—";
    document.getElementById("modalEmail").textContent = c.email || "—";
    document.getElementById("modalMobile").textContent = c.mobile || "—";
    document.getElementById("modalUid").textContent = c.id;

    const ordersDiv = document.getElementById("modalOrders");
    const orders = allOrders.filter(o => o.userId === uid);

    if (orders.length === 0) {
        ordersDiv.innerHTML = `<div class="empty-state">No orders found</div>`;
    } else {
        ordersDiv.innerHTML = "";
        orders.forEach(o => {
            // Make sure to replace 'total' and 'date' with your actual Firestore fields
            const amount = o.total || o.totalAmount || o.grandTotal || 0;
            const dateStr = o.date || o.createdAt || "—"; 
            const formattedDate = typeof dateStr === "object" && dateStr.toDate ? dateStr.toDate().toLocaleDateString() : dateStr;

            ordersDiv.innerHTML += `
                <div class="order-mini-row">
                    <div class="order-mini-id">#${o.id}</div>
                    <div class="order-mini-date">${formattedDate}</div>
                    <div class="order-mini-amount">Rs ${amount}</div>
                </div>
            `;
        });
    }

    document.getElementById("customerModal").classList.add("show");
};

window.closeCustomerModal = function () {
    document.getElementById("customerModal").classList.remove("show");
};