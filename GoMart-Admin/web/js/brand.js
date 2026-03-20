import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, collection, addDoc, getDocs, deleteDoc, doc, updateDoc } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";
import { getStorage, ref, uploadBytesResumable, getDownloadURL } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-storage.js";

const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    document.getElementById("adminEmail").textContent = user.email;
    loadBrands();
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

function compressImage(file, maxWidth = 300, quality = 0.7) {
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

function uploadImage(file, folder) {
  return new Promise((resolve, reject) => {
    const filePath = `${folder}/${Date.now()}_image.webp`;
    const storageRef = ref(storage, filePath);
    const uploadTask = uploadBytesResumable(storageRef, file);

    const progressWrap = document.getElementById("progressWrap");
    const progressBar = document.getElementById("progressBar");
    const progressLabel = document.getElementById("progressLabel");
    progressWrap.style.display = "block";

    uploadTask.on("state_changed",
      (snapshot) => {
        const pct = Math.round((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
        progressBar.style.width = pct + "%";
        progressLabel.textContent = `Uploading... ${pct}%`;
      },
      (error) => {
        progressWrap.style.display = "none";
        reject(error);
      },
      async () => {
        const url = await getDownloadURL(uploadTask.snapshot.ref);
        progressWrap.style.display = "none";
        resolve(url);
      }
    );
  });
}

window.addBrand = async function () {
  const name = document.getElementById("brandName").value.trim();
  const file = document.getElementById("brandImage").files[0];
  const btn = document.getElementById("addBtn");

  if (!name) { showAlert("Please enter a brand name.", "error"); return; }
  if (!file) { showAlert("Please select a brand image.", "error"); return; }

  btn.disabled = true;
  btn.textContent = "Adding...";

  try {
    const compressed = await compressImage(file);
    const imageUrl = await uploadImage(compressed, "brandImages");

    const docRef = await addDoc(collection(db, "brands"), {
      brandName: name,
      imageUrl: imageUrl
    });

    await updateDoc(doc(db, "brands", docRef.id), {
      brandId: docRef.id
    });

    showAlert("Brand added successfully!");
    document.getElementById("brandName").value = "";
    document.getElementById("brandImage").value = "";
    loadBrands();

  } catch (e) {
    console.error("Add brand error:", e);
    showAlert("Failed to add brand. Try again.", "error");
  } finally {
    btn.disabled = false;
    btn.textContent = "+ Add Brand";
  }
};

async function loadBrands() {
  const table = document.getElementById("brandTable");
  table.innerHTML = `<tr><td colspan="4" class="loading">Loading brands...</td></tr>`;

  try {
    const snapshot = await getDocs(collection(db, "brands"));

    if (snapshot.empty) {
      table.innerHTML = `<tr><td colspan="4" class="empty-state">No brands found. Add your first brand above.</td></tr>`;
      document.getElementById("brandCount").textContent = "";
      return;
    }

    document.getElementById("brandCount").textContent = `(${snapshot.size})`;
    table.innerHTML = "";

    snapshot.forEach((docSnap) => {
      const d = docSnap.data();
      const name = d.brandName || "No Name";
      const image = d.imageUrl || "";
      const id = docSnap.id;

      table.innerHTML += `
        <tr>
          <td>
            <img src="${image}" class="brand-img"
              onerror="this.src='https://via.placeholder.com/52x52?text=No+Img'">
          </td>
          <td><span class="brand-name">${name}</span></td>
          <td style="font-size:11px;color:#94a3b8">${id}</td>
          <td>
            <button class="btn-edit" onclick="openEditModal('${id}','${name}','${image}')">Edit</button>
            <button class="btn-delete" onclick="deleteBrand('${id}')">Delete</button>
          </td>
        </tr>`;
    });

  } catch (e) {
    console.error("Load brands error:", e);
    table.innerHTML = `<tr><td colspan="4" style="color:#ef4444;text-align:center;font-size:13px">Failed to load brands</td></tr>`;
  }
}

window.deleteBrand = async function (id) {
  if (!confirm("Are you sure you want to delete this brand?")) return;
  try {
    await deleteDoc(doc(db, "brands", id));
    showAlert("Brand deleted.");
    loadBrands();
  } catch (e) {
    console.error("Delete error:", e);
    showAlert("Failed to delete brand.", "error");
  }
};

window.openEditModal = function (id, name, image) {
  document.getElementById("editBrandId").value = id;
  document.getElementById("editBrandName").value = name;
  document.getElementById("editModal").classList.add("show");
};

window.closeEditModal = function () {
  document.getElementById("editModal").classList.remove("show");
  document.getElementById("editBrandImage").value = "";
};

window.saveEdit = async function () {
  const id = document.getElementById("editBrandId").value;
  const newName = document.getElementById("editBrandName").value.trim();
  const file = document.getElementById("editBrandImage").files[0];

  if (!newName) { showAlert("Brand name cannot be empty.", "error"); return; }

  try {
    const updateData = { brandName: newName };

    if (file) {
      const compressed = await compressImage(file);
      updateData.imageUrl = await uploadImage(compressed, "brandImages");
    }

    await updateDoc(doc(db, "brands", id), updateData);
    closeEditModal();
    showAlert("Brand updated successfully!");
    loadBrands();

  } catch (e) {
    console.error("Update error:", e);
    showAlert("Failed to update brand.", "error");
  }
};