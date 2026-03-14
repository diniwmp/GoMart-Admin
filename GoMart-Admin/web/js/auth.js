import { app } from "./firebase-config.js";
import { getAuth, signInWithEmailAndPassword } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";

const auth = getAuth(app);

window.handleSignin = async function () {
  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value;
  const btn = document.getElementById("signinBtn");
  const errorDiv = document.getElementById("errorMsg");

  if (!email) {
    errorDiv.textContent = "Please enter your email address.";
    errorDiv.classList.remove("d-none");
    return;
  }

  if (!password) {
    errorDiv.textContent = "Please enter your password.";
    errorDiv.classList.remove("d-none");
    return;
  }

  btn.disabled = true;
  btn.textContent = "Signing in...";
  errorDiv.classList.add("d-none");

  try {
    await signInWithEmailAndPassword(auth, email, password);
    window.location.href = "dashboard.jsp";
  } catch (error) {
    btn.disabled = false;
    btn.textContent = "Sign in";
    errorDiv.classList.remove("d-none");
    errorDiv.textContent = "Invalid email or password.";
  }
};