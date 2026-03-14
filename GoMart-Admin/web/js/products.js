import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, addDoc, getDocs, deleteDoc, doc, updateDoc, query, orderBy } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";
import { getStorage, ref, uploadBytesResumable, getDownloadURL } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-storage.js";

const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

let allProducts = [];

// ── Auth check ───────────────────────────────────────────
onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadDropdowns();
    loadProducts();
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

// ── Image preview ─────────────────────────────────────────
window.previewImage = function (input, previewId) {
  const img = document.getElementById(previewId);
  const labelId = previewId.replace("preview", "previewLabel");
  const label = document.getElementById(labelId);
  if (input.files && input.files[0]) {
    const reader = new FileReader();
    reader.onload = (e) => {
      img.src = e.target.result;
      img.style.display = "block";
      if (label) label.style.display = "none";
    };
    reader.readAsDataURL(input.files[0]);
  }
};

// ── Compress image ────────────────────────────────────────
function compressImage(file, maxWidth = 600, quality = 0.75) {
  return new Promise((resolve) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement("canvas");
        const scale = Math.min(maxWidth / img.width, 1);
        canvas.width = img.width * scale;
        canvas.height = img.height * scale;
        canvas.getContext("2d").drawImage(img, 0, 0, canvas.width, canvas.height);
        canvas.toBlob((blob) => resolve(blob), "image/webp", quality);
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  });
}

// ── Upload single image ───────────────────────────────────
function uploadImage(file, path, progressWrapId, progressBarId, progressLabelId) {
  return new Promise((resolve, reject) => {
    const storageRef = ref(storage, path);
    const uploadTask = uploadBytesResumable(storageRef, file);

    document.getElementById(progressWrapId).style.display = "block";

    uploadTask.on("state_changed",
      (snapshot) => {
        const pct = Math.round((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
        document.getElementById(progressBarId).style.width = pct + "%";
        document.getElementById(progressLabelId).textContent = `Uploading... ${pct}%`;
      },
      (error) => {
        document.getElementById(progressWrapId).style.display = "none";
        reject(error);
      },
      async () => {
        const url = await getDownloadURL(uploadTask.snapshot.ref);
        resolve(url);
      }
    );
  });
}

// ── Load categories and brands into dropdowns ─────────────
async function loadDropdowns() {
  try {
    const [catSnap, brandSnap] = await Promise.all([
      getDocs(collection(db, "categories")),
      getDocs(collection(db, "brands"))
    ]);

    // populate add form dropdowns
    const catSelect = document.getElementById("productCategory");
    const brandSelect = document.getElementById("productBrand");
    const editCatSelect = document.getElementById("editCategory");
    const editBrandSelect = document.getElementById("editBrand");

    catSnap.forEach(d => {
      const opt = `<option value="${d.id}">${d.data().name}</option>`;
      catSelect.innerHTML += opt;
      editCatSelect.innerHTML += opt;
    });

    brandSnap.forEach(d => {
      const opt = `<option value="${d.id}">${d.data().brandName}</option>`;
      brandSelect.innerHTML += opt;
      editBrandSelect.innerHTML += opt;
    });

  } catch (e) {
    console.error("Load dropdowns error:", e);
  }
}

// ── Add Product ───────────────────────────────────────────
window.addProduct = async function () {
  const title = document.getElementById("productTitle").value.trim();
  const price = parseFloat(document.getElementById("productPrice").value);
  const description = document.getElementById("productDescription").value.trim();
  const categoryId = document.getElementById("productCategory").value;
  const brandId = document.getElementById("productBrand").value;
  const stockCount = parseInt(document.getElementById("productStock").value);
  const rating = parseFloat(document.getElementById("productRating").value) || 0;
  const status = document.getElementById("productStatus").checked;
  const file1 = document.getElementById("productImage1").files[0];
  const file2 = document.getElementById("productImage2").files[0];
  const btn = document.getElementById("addBtn");

  // validation
  if (!title) { showAlert("Please enter product title.", "error"); return; }
  if (isNaN(price) || price < 0) { showAlert("Please enter valid price.", "error"); return; }
  if (!categoryId) { showAlert("Please select a category.", "error"); return; }
  if (!brandId) { showAlert("Please select a brand.", "error"); return; }
  if (isNaN(stockCount) || stockCount < 0) { showAlert("Please enter valid stock count.", "error"); return; }
  if (!file1) { showAlert("Please select image 1.", "error"); return; }
  if (!file2) { showAlert("Please select image 2.", "error"); return; }

  btn.disabled = true;
  btn.textContent = "Adding...";

  try {
    const ts = Date.now();

    // compress and upload both images
    const [comp1, comp2] = await Promise.all([
      compressImage(file1),
      compressImage(file2)
    ]);

    document.getElementById("progressLabel").textContent = "Uploading image 1...";
    const imageUrl0 = await uploadImage(
      comp1,
      `productImages/${ts}_img1.webp`,
      "progressWrap", "progressBar", "progressLabel"
    );

    document.getElementById("progressLabel").textContent = "Uploading image 2...";
    const imageUrl1 = await uploadImage(
      comp2,
      `productImages/${ts}_img2.webp`,
      "progressWrap", "progressBar", "progressLabel"
    );

    document.getElementById("progressWrap").style.display = "none";

    // images is array with imageUrl0 and imageUrl1 — matches Product model
    const docRef = await addDoc(collection(db, "products"), {
      title,
      description,
      price,
      categoryId,
      brandId,
      stockCount,
      rating,
      status,
      images: [imageUrl0, imageUrl1]
    });

    // set productId same as document id
    await updateDoc(doc(db, "products", docRef.id), {
      productId: docRef.id
    });

    showAlert("Product added successfully!");

    // reset form
    document.getElementById("productTitle").value = "";
    document.getElementById("productPrice").value = "";
    document.getElementById("productDescription").value = "";
    document.getElementById("productCategory").value = "";
    document.getElementById("productBrand").value = "";
    document.getElementById("productStock").value = "";
    document.getElementById("productRating").value = "";
    document.getElementById("productStatus").checked = true;
    document.getElementById("productImage1").value = "";
    document.getElementById("productImage2").value = "";
    document.getElementById("preview1").style.display = "none";
    document.getElementById("preview2").style.display = "none";

    loadProducts();

  } catch (e) {
    console.error("Add product error:", e);
    showAlert("Failed to add product. Try again.", "error");
  } finally {
    btn.disabled = false;
    btn.textContent = "+ Add Product";
  }
};

// ── Load Products ─────────────────────────────────────────
async function loadProducts() {
  const table = document.getElementById("productsTable");
  table.innerHTML = `<tr><td colspan="6" class="loading">Loading products...</td></tr>`;

  try {
    const snap = await getDocs(
      query(collection(db, "products"), orderBy("title", "asc"))
    );

    allProducts = [];
    snap.forEach(d => allProducts.push({ id: d.id, ...d.data() }));

    document.getElementById("productCount").textContent = `(${allProducts.length})`;
    renderTable(allProducts);

  } catch (e) {
    console.error("Load products error:", e);
    table.innerHTML = `<tr><td colspan="6" style="color:#ef4444;text-align:center;font-size:13px">Failed to load products</td></tr>`;
  }
}

// ── Render table ──────────────────────────────────────────
function renderTable(products) {
  const table = document.getElementById("productsTable");

  if (products.length === 0) {
    table.innerHTML = `<tr><td colspan="6" class="empty-state">No products found</td></tr>`;
    return;
  }

  table.innerHTML = "";
  products.forEach(p => {
    // images[0] is imageUrl0 — matches Product model
    const img = (p.images && p.images[0])
      ? p.images[0]
      : "https://via.placeholder.com/48?text=No+Img";

    const statusClass = p.status ? "s-active" : "s-inactive";
    const statusLabel = p.status ? "Active" : "Inactive";

    table.innerHTML += `
      <tr>
        <td><img src="${img}" class="product-img"
          onerror="this.src='https://via.placeholder.com/48?text=No+Img'"></td>
        <td>
          <div class="product-title">${p.title || "—"}</div>
          <div class="product-sub">${p.id}</div>
        </td>
        <td>Rs. ${parseFloat(p.price || 0).toFixed(2)}</td>
        <td>${p.stockCount || 0}</td>
        <td><span class="status-badge ${statusClass}">${statusLabel}</span></td>
        <td>
          <button class="btn-edit" onclick="openEditModal('${p.id}')">Edit</button>
          <button class="btn-delete" onclick="deleteProduct('${p.id}')">Delete</button>
        </td>
      </tr>`;
  });
}

// ── Search products ───────────────────────────────────────
window.searchProducts = function () {
  const q = document.getElementById("searchInput").value.toLowerCase();
  const filtered = allProducts.filter(p =>
    (p.title || "").toLowerCase().includes(q)
  );
  renderTable(filtered);
};

// ── Delete product ────────────────────────────────────────
window.deleteProduct = async function (id) {
  if (!confirm("Are you sure you want to delete this product?")) return;
  try {
    await deleteDoc(doc(db, "products", id));
    allProducts = allProducts.filter(p => p.id !== id);
    document.getElementById("productCount").textContent = `(${allProducts.length})`;
    renderTable(allProducts);
    showAlert("Product deleted.");
  } catch (e) {
    console.error("Delete error:", e);
    showAlert("Failed to delete product.", "error");
  }
};

// ── Open edit modal ───────────────────────────────────────
window.openEditModal = function (id) {
  const p = allProducts.find(p => p.id === id);
  if (!p) return;

  document.getElementById("editProductId").value = id;
  document.getElementById("editTitle").value = p.title || "";
  document.getElementById("editPrice").value = p.price || "";
  document.getElementById("editDescription").value = p.description || "";
  document.getElementById("editStock").value = p.stockCount || 0;
  document.getElementById("editRating").value = p.rating || 0;
  document.getElementById("editStatus").checked = p.status !== false;
  document.getElementById("editCategory").value = p.categoryId || "";
  document.getElementById("editBrand").value = p.brandId || "";

  // show existing images
  const img1 = (p.images && p.images[0]) ? p.images[0] : "";
  const img2 = (p.images && p.images[1]) ? p.images[1] : "";
  document.getElementById("editPreview1").src = img1;
  document.getElementById("editPreview2").src = img2;

  document.getElementById("editImage1").value = "";
  document.getElementById("editImage2").value = "";

  document.getElementById("editModal").classList.add("show");
};

window.closeEditModal = function () {
  document.getElementById("editModal").classList.remove("show");
};

// ── Save edit ─────────────────────────────────────────────
window.saveEdit = async function () {
  const id = document.getElementById("editProductId").value;
  const btn = document.getElementById("editSaveBtn");

  const updateData = {
    title: document.getElementById("editTitle").value.trim(),
    price: parseFloat(document.getElementById("editPrice").value),
    description: document.getElementById("editDescription").value.trim(),
    categoryId: document.getElementById("editCategory").value,
    brandId: document.getElementById("editBrand").value,
    stockCount: parseInt(document.getElementById("editStock").value),
    rating: parseFloat(document.getElementById("editRating").value) || 0,
    status: document.getElementById("editStatus").checked
  };

  if (!updateData.title) { alert("Title cannot be empty."); return; }

  btn.disabled = true;
  btn.textContent = "Saving...";

  try {
    const product = allProducts.find(p => p.id === id);
    const existingImages = product?.images || ["", ""];
    const ts = Date.now();

    // upload new image 1 if selected
    const file1 = document.getElementById("editImage1").files[0];
    if (file1) {
      const comp1 = await compressImage(file1);
      existingImages[0] = await uploadImage(
        comp1,
        `productImages/${ts}_img1.webp`,
        "editProgressWrap", "editProgressBar", "editProgressLabel"
      );
    }

    // upload new image 2 if selected
    const file2 = document.getElementById("editImage2").files[0];
    if (file2) {
      const comp2 = await compressImage(file2);
      existingImages[1] = await uploadImage(
        comp2,
        `productImages/${ts}_img2.webp`,
        "editProgressWrap", "editProgressBar", "editProgressLabel"
      );
    }

    document.getElementById("editProgressWrap").style.display = "none";
    updateData.images = existingImages;

    await updateDoc(doc(db, "products", id), updateData);

    // update local array
    const idx = allProducts.findIndex(p => p.id === id);
    if (idx !== -1) allProducts[idx] = { id, ...updateData };

    closeEditModal();
    renderTable(allProducts);
    showAlert("Product updated successfully!");

  } catch (e) {
    console.error("Save edit error:", e);
    showAlert("Failed to update product.", "error");
  } finally {
    btn.disabled = false;
    btn.textContent = "Save Changes";
  }
};
