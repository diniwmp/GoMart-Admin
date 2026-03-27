import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, getDocs, doc, updateDoc, query, orderBy } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const auth = getAuth(app);
const db = getFirestore(app);

let allProducts = [];

onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadInventory();
  }
});

document.getElementById("logoutBtn").addEventListener("click", async (e) => {
  e.preventDefault();
  await signOut(auth);
  window.location.href = "index.html";
});

function showAlert(message, type = "success") {
  const el = document.getElementById("alertMsg");
  el.textContent = message;
  el.className = `alert-msg alert-${type}`;
  el.style.display = "block";
  setTimeout(() => { el.style.display = "none"; }, 3000);
}

function getStockStatus(qty) {
  if (qty <= 0) return { label: "Out of Stock", cls: "s-out-stock", type: "out" };
  if (qty < 10) return { label: "Low Stock", cls: "s-low-stock", type: "low" };
  return { label: "In Stock", cls: "s-in-stock", type: "in" };
}

async function loadInventory() {
  const table = document.getElementById("inventoryTable");
  table.innerHTML = `<tr><td colspan="6" class="loading">Loading inventory...</td></tr>`;

  try {
    const snap = await getDocs(
      query(collection(db, "products"), orderBy("stockCount", "asc"))
    );

    allProducts = [];
    snap.forEach(docSnap => {
      allProducts.push({ id: docSnap.id, ...docSnap.data() });
    });

    updateStats();
    renderTable(allProducts);

  } catch (e) {
    console.error("Load inventory error:", e);
    table.innerHTML = `<tr><td colspan="6" style="color:#ef4444;text-align:center;font-size:13px">Failed to load inventory</td></tr>`;
  }
}

function updateStats() {
  document.getElementById("totalProducts").textContent = allProducts.length;
  document.getElementById("inStockCount").textContent = allProducts.filter(p => p.stockCount >= 10).length;
  document.getElementById("lowStockCount").textContent = allProducts.filter(p => p.stockCount > 0 && p.stockCount < 10).length;
  document.getElementById("outStockCount").textContent = allProducts.filter(p => !p.stockCount || p.stockCount <= 0).length;
}

function renderTable(products) {
  const table = document.getElementById("inventoryTable");

  if (products.length === 0) {
    table.innerHTML = `<tr><td colspan="6" class="empty-state">No products found</td></tr>`;
    return;
  }

  table.innerHTML = "";
  products.forEach(p => {
    const qty = p.stockCount || 0;
    const stock = getStockStatus(qty);
    const pct = Math.min(Math.round((qty / 150) * 100), 100);
    const barColor = qty <= 0 ? "#ef4444" : qty < 10 ? "#f59e0b" : "#22c55e";

    const img = (p.images && p.images.length > 0)
      ? p.images[0]
      : "https://via.placeholder.com/44x44?text=No+Img";

    table.innerHTML += `
      <tr>
        <td>
          <img src="${img}" class="product-img"
            onerror="this.src='https://via.placeholder.com/44x44?text=No+Img'">
        </td>
        <td>
          <div class="product-title">${p.title || "—"}</div>
          <div class="product-id">${p.id}</div>
        </td>
        <td>
          <span class="stock-bar-bg">
            <span class="stock-bar-fill" style="width:${pct}%;background:${barColor}"></span>
          </span>
          <span class="stock-qty" style="color:${barColor}">${qty}</span>
        </td>
        <td>
          <span class="status-badge ${stock.cls}">${stock.label}</span>
        </td>
        <td>Rs. ${parseFloat(p.price || 0).toFixed(2)}</td>
        <td>
          <button class="btn-update" onclick="openStockModal('${p.id}')">Update Stock</button>
        </td>
      </tr>`;
  });
}

window.filterProducts = function (type, btn) {
  document.querySelectorAll(".filter-btn").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");

  const filtered = type === "all"
    ? allProducts
    : allProducts.filter(p => getStockStatus(p.stockCount || 0).type === type);

  renderTable(filtered);
};

window.searchProducts = function () {
  const q = document.getElementById("searchInput").value.toLowerCase();
  const filtered = allProducts.filter(p =>
    (p.title || "").toLowerCase().includes(q)
  );
  renderTable(filtered);
};

window.openStockModal = function (id) {
  const product = allProducts.find(p => p.id === id);
  if (!product) return;

  document.getElementById("modalDocId").value = id;
  document.getElementById("modalProductTitle").textContent = product.title || "Update Stock";
  document.getElementById("modalProductId").textContent = `Product ID: ${id}`;
  document.getElementById("currentStock").value = product.stockCount || 0;
  document.getElementById("newStock").value = "";

  document.getElementById("stockModal").classList.add("show");
};

window.closeStockModal = function () {
  document.getElementById("stockModal").classList.remove("show");
};

window.saveStock = async function () {
  const id = document.getElementById("modalDocId").value;
  const newQty = parseInt(document.getElementById("newStock").value);

  if (isNaN(newQty) || newQty < 0) {
    alert("Please enter a valid stock count.");
    return;
  }

  try {
    await updateDoc(doc(db, "products", id), {
      stockCount: newQty
    });

    const product = allProducts.find(p => p.id === id);
    if (product) product.stockCount = newQty;

    updateStats();
    renderTable(allProducts);
    closeStockModal();
    showAlert("Stock updated successfully!");

  } catch (e) {
    console.error("Update stock error:", e);
    showAlert("Failed to update stock.", "error");
  }
};
