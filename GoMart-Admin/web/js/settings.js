import { app } from "./firebase-config.js";
import { getAuth, onAuthStateChanged, signOut, updatePassword, reauthenticateWithCredential, EmailAuthProvider, updateProfile } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { getFirestore, doc, getDoc, setDoc } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";
import { getStorage, ref, uploadBytesResumable, getDownloadURL } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-storage.js";

const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

let currentUser = null;

// ── Auth check ───────────────────────────────────────────
onAuthStateChanged(auth, (user) => {
  if (!user) {
    window.location.href = "index.html";
  } else {
    currentUser = user;
    loadAdminProfile(user);
    loadStoreInfo();
  }
});

// ── Logout ───────────────────────────────────────────────
document.getElementById("logoutBtn").addEventListener("click", async (e) => {
  e.preventDefault();
  await signOut(auth);
  window.location.href = "index.html";
});

// ── Show alert ───────────────────────────────────────────
function showAlert(alertId, message, type = "success") {
  const el = document.getElementById(alertId);
  el.textContent = message;
  el.className = `alert-msg alert-${type}`;
  el.style.display = "block";
  setTimeout(() => { el.style.display = "none"; }, 3000);
}

// ── Load admin profile ───────────────────────────────────
function loadAdminProfile(user) {
  document.getElementById("adminEmail").textContent = user.email;
  document.getElementById("adminEmailField").value = user.email;
  document.getElementById("adminName").value = user.displayName || "";

  // topbar initials
  const initial = (user.displayName || user.email || "A").charAt(0).toUpperCase();
  document.getElementById("profileInitial").textContent = initial;

  // profile picture
  if (user.photoURL) {
    const img = document.getElementById("profilePicImg");
    img.src = user.photoURL;
    img.style.display = "block";
    document.getElementById("profileInitial").style.display = "none";

    // update topbar avatar
    const topbar = document.getElementById("topbarAvatar");
    topbar.innerHTML = `<img src="${user.photoURL}" style="width:100%;height:100%;object-fit:cover;border-radius:50%">`;
  }
}

// ── Handle profile picture change ────────────────────────
window.handlePicChange = function (input) {
  if (!input.files || !input.files[0]) return;
  const file = input.files[0];

  // preview immediately
  const reader = new FileReader();
  reader.onload = (e) => {
    const img = document.getElementById("profilePicImg");
    img.src = e.target.result;
    img.style.display = "block";
    document.getElementById("profileInitial").style.display = "none";
  };
  reader.readAsDataURL(file);
};

// ── Save admin profile ───────────────────────────────────
window.saveProfile = async function () {
  const name = document.getElementById("adminName").value.trim();
  const file = document.getElementById("picInput").files[0];
  const btn = document.getElementById("profileBtn");

  if (!name) { showAlert("profileAlert", "Please enter your name.", "error"); return; }

  btn.disabled = true;
  btn.textContent = "Saving...";

  try {
    let photoURL = currentUser.photoURL || "";

    // upload new profile picture if selected
    if (file) {
      photoURL = await uploadProfilePic(file);
    }

    // update Firebase Auth profile
    await updateProfile(currentUser, {
      displayName: name,
      photoURL: photoURL
    });

    // update topbar
    document.getElementById("adminEmail").textContent = currentUser.email;
    const topbar = document.getElementById("topbarAvatar");
    if (photoURL) {
      topbar.innerHTML = `<img src="${photoURL}" style="width:100%;height:100%;object-fit:cover;border-radius:50%">`;
    } else {
      topbar.textContent = name.charAt(0).toUpperCase();
    }

    showAlert("profileAlert", "Profile updated successfully!");

  } catch (e) {
    console.error("Profile update error:", e);
    showAlert("profileAlert", "Failed to update profile.", "error");
  } finally {
    btn.disabled = false;
    btn.textContent = "Save Profile";
  }
};

// ── Upload profile picture ───────────────────────────────
function uploadProfilePic(file) {
  return new Promise((resolve, reject) => {
    const filePath = `adminProfiles/${currentUser.uid}_profile.webp`;
    const storageRef = ref(storage, filePath);

    // compress first
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement("canvas");
        const size = Math.min(img.width, img.height, 300);
        canvas.width = size;
        canvas.height = size;
        canvas.getContext("2d").drawImage(img, 0, 0, size, size);
        canvas.toBlob((blob) => {
          const uploadTask = uploadBytesResumable(storageRef, blob);
          document.getElementById("picProgressWrap").style.display = "block";

          uploadTask.on("state_changed",
            (snapshot) => {
              const pct = Math.round((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
              document.getElementById("picProgressBar").style.width = pct + "%";
              document.getElementById("picProgressLabel").textContent = `Uploading... ${pct}%`;
            },
            (error) => {
              document.getElementById("picProgressWrap").style.display = "none";
              reject(error);
            },
            async () => {
              document.getElementById("picProgressWrap").style.display = "none";
              const url = await getDownloadURL(uploadTask.snapshot.ref);
              resolve(url);
            }
          );
        }, "image/webp", 0.8);
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  });
}

// ── Password strength checker ─────────────────────────────
window.checkStrength = function (password) {
  const segs = ["seg1", "seg2", "seg3", "seg4"];
  const label = document.getElementById("strengthLabel");

  let strength = 0;
  if (password.length >= 6) strength++;
  if (password.length >= 10) strength++;
  if (/[A-Z]/.test(password) && /[0-9]/.test(password)) strength++;
  if (/[^A-Za-z0-9]/.test(password)) strength++;

  const colors = ["#ef4444", "#f59e0b", "#3b82f6", "#22c55e"];
  const labels = ["Weak", "Fair", "Good", "Strong"];

  segs.forEach((id, i) => {
    document.getElementById(id).style.background = i < strength ? colors[strength - 1] : "#f1f5f9";
  });

  label.textContent = password.length > 0 ? labels[strength - 1] || "" : "";
  label.style.color = strength > 0 ? colors[strength - 1] : "#94a3b8";
};

// ── Change password ───────────────────────────────────────
window.changePassword = async function () {
  const current = document.getElementById("currentPassword").value;
  const newPass = document.getElementById("newPassword").value;
  const confirm = document.getElementById("confirmPassword").value;
  const btn = document.getElementById("passwordBtn");

  if (!current) { showAlert("passwordAlert", "Please enter current password.", "error"); return; }
  if (!newPass) { showAlert("passwordAlert", "Please enter new password.", "error"); return; }
  if (newPass.length < 6) { showAlert("passwordAlert", "Password must be at least 6 characters.", "error"); return; }
  if (newPass !== confirm) { showAlert("passwordAlert", "Passwords do not match.", "error"); return; }

  btn.disabled = true;
  btn.textContent = "Updating...";

  try {
    // re-authenticate first — required by Firebase before password change
    const credential = EmailAuthProvider.credential(currentUser.email, current);
    await reauthenticateWithCredential(currentUser, credential);

    // update password
    await updatePassword(currentUser, newPass);

    document.getElementById("currentPassword").value = "";
    document.getElementById("newPassword").value = "";
    document.getElementById("confirmPassword").value = "";
    document.getElementById("strengthLabel").textContent = "";
    ["seg1","seg2","seg3","seg4"].forEach(id => {
      document.getElementById(id).style.background = "#f1f5f9";
    });

    showAlert("passwordAlert", "Password updated successfully!");

  } catch (e) {
    console.error("Password change error:", e);
    if (e.code === "auth/wrong-password") {
      showAlert("passwordAlert", "Current password is incorrect.", "error");
    } else {
      showAlert("passwordAlert", "Failed to update password.", "error");
    }
  } finally {
    btn.disabled = false;
    btn.textContent = "Update Password";
  }
};

// ── Load store info ───────────────────────────────────────
async function loadStoreInfo() {
  try {
    const snap = await getDoc(doc(db, "settings", "storeInfo"));
    if (snap.exists()) {
      const d = snap.data();
      document.getElementById("storeName").value = d.storeName || "";
      document.getElementById("storePhone").value = d.storePhone || "";
      document.getElementById("storeEmail").value = d.storeEmail || "";
      document.getElementById("storeAddress").value = d.storeAddress || "";
    }
  } catch (e) {
    console.error("Load store info error:", e);
  }
}

// ── Save store info ───────────────────────────────────────
window.saveStoreInfo = async function () {
  const storeName = document.getElementById("storeName").value.trim();
  const storePhone = document.getElementById("storePhone").value.trim();
  const storeEmail = document.getElementById("storeEmail").value.trim();
  const storeAddress = document.getElementById("storeAddress").value.trim();
  const btn = document.getElementById("storeBtn");

  if (!storeName) { showAlert("storeAlert", "Please enter store name.", "error"); return; }

  btn.disabled = true;
  btn.textContent = "Saving...";

  try {
    // save to settings/storeInfo document in Firestore
    await setDoc(doc(db, "settings", "storeInfo"), {
      storeName,
      storePhone,
      storeEmail,
      storeAddress
    });

    showAlert("storeAlert", "Store info saved successfully!");

  } catch (e) {
    console.error("Save store info error:", e);
    showAlert("storeAlert", "Failed to save store info.", "error");
  } finally {
    btn.disabled = false;
    btn.textContent = "Save Store Info";
  }
};