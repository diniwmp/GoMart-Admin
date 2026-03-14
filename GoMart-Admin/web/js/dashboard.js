import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, getDocs, query, orderBy, limit, where } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const firebaseConfig = {
  apiKey: "AIzaSyBHa0BSoTa_bN7_d6bsz6hbcdS0JP4k3Rw",
  authDomain: "gomart-8a5ad.firebaseapp.com",
  projectId: "gomart-8a5ad",
  storageBucket: "gomart-8a5ad.firebasestorage.app",
  messagingSenderId: "262843407177",
  appId: "1:262843407177:web:a30e2ea5428e2b72bed898"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// Auth check - redirect if not logged in
onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadDashboard();
  }
});

// Logout
document.getElementById("logoutBtn").addEventListener("click", async (e) => {
  e.preventDefault();
  await signOut(auth);
  window.location.href = "index.html";
});

async function loadDashboard() {
  await Promise.all([
    loadCounts(),
    loadRecentOrders(),
    loadInventory()
  ]);
}

// ── Stat counts 
async function loadCounts() {
  try {
    const [brands, products, orders] = await Promise.all([
      getDocs(collection(db, "brands")),
      getDocs(collection(db, "products")),
      getDocs(collection(db, "orders"))
    ]);

    document.getElementById("totalBrands").innerText = brands.size;
    document.getElementById("totalProducts").innerText = products.size;
    document.getElementById("totalOrders").innerText = orders.size;

    // stockCount is the correct field from Product model
    const lowStockSnap = await getDocs(
      query(collection(db, "products"), where("stockCount", "<", 10))
    );
    document.getElementById("lowStock").innerText = lowStockSnap.size;

  } catch (e) {
    console.error("Count error:", e);
  }
}

// ── Recent orders 
async function loadRecentOrders() {
  const tbody = document.getElementById("recentOrders");
  try {
    // orderDate is the correct field from Order model
    const snap = await getDocs(
      query(collection(db, "orders"), orderBy("orderDate", "desc"), limit(5))
    );

    if (snap.empty) {
      tbody.innerHTML = `<tr><td colspan="4" style="text-align:center;color:#94a3b8;font-size:13px">No orders yet</td></tr>`;
      return;
    }

    tbody.innerHTML = "";
    snap.forEach(doc => {
      const d = doc.data();

      const statusClass = {
        pending: "s-pending",
        delivered: "s-delivered",
        processing: "s-processing",
        cancelled: "s-cancelled"
      }[d.status] || "s-pending";

      // customerName is inside shippingAddress.name from Order model
      const customerName = d.shippingAddress?.name || "—";

      // orderDate is Timestamp from Order model
      const time = d.orderDate?.seconds
        ? new Date(d.orderDate.seconds * 1000).toLocaleTimeString()
        : "—";

      tbody.innerHTML += `<tr>
        <td><span class="order-id">#${doc.id.substring(0, 6).toUpperCase()}</span></td>
        <td><span class="customer-name">${customerName}</span></td>
        <td><span class="status-pill ${statusClass}">${d.status || "pending"}</span></td>
        <td>${time}</td>
      </tr>`;
    });

  } catch (e) {
    console.error("Orders error:", e);
    tbody.innerHTML = `<tr><td colspan="4" style="color:#ef4444;font-size:13px;text-align:center">Failed to load orders</td></tr>`;
  }
}

// ── Inventory 
async function loadInventory() {
  const container = document.getElementById("inventoryList");
  try {
    // stockCount and title are correct fields from Product model
    const snap = await getDocs(
      query(collection(db, "products"), orderBy("stockCount", "asc"), limit(5))
    );

    if (snap.empty) {
      container.innerHTML = `<div class="loading">No products found</div>`;
      return;
    }

    container.innerHTML = "";
    snap.forEach(doc => {
      const d = doc.data();
      const qty = d.stockCount || 0;
      const pct = Math.min(Math.round((qty / 150) * 100), 100);
      const color = qty < 10 ? "#ef4444" : qty < 30 ? "#f59e0b" : "#22c55e";

      container.innerHTML += `
        <div class="inv-row">
          <div class="inv-dot" style="background:${color}"></div>
          <div class="inv-name">${d.title || "—"}</div>
          <div class="inv-qty">${qty} units</div>
          <div class="bar-bg">
            <div class="bar-fill" style="width:${pct}%;background:${color}"></div>
          </div>
        </div>`;
    });

  } catch (e) {
    console.error("Inventory error:", e);
    container.innerHTML = `<div style="color:#ef4444;font-size:13px">Failed to load inventory</div>`;
  }
}