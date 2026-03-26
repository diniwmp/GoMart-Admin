<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>GoMart Admin - Settings</title>
                <link rel="icon" type="image/png" href="images/logo.png" />

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
            * {
                box-sizing: border-box;
            }
            body {
                background: #f1f5f9;
                margin: 0;
                font-family: sans-serif;
            }

            .sidebar {
                width: 220px;
                min-height: 100vh;
                background: #1a2332;
                position: fixed;
                top: 0;
                left: 0;
                display: flex;
                flex-direction: column;
            }
            .sidebar-logo {
                padding: 20px 16px;
                border-bottom: 1px solid rgba(255,255,255,0.08);
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .logo-text {
                color: #fff;
                font-size: 18px;
                font-weight: 600;
            }
            .logo-sub {
                color: rgba(255,255,255,0.35);
                font-size: 11px;
            }
            .nav-section {
                padding: 14px 16px 4px;
                font-size: 10px;
                color: rgba(255,255,255,0.3);
                text-transform: uppercase;
                letter-spacing: 0.08em;
            }
            .sidebar a {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 9px 14px;
                margin: 1px 8px;
                border-radius: 6px;
                color: rgba(255,255,255,0.65);
                text-decoration: none;
                font-size: 13px;
                transition: all 0.15s;
            }
            .sidebar a:hover, .sidebar a.active {
                background: rgba(34,197,94,0.15);
                color: #22c55e;
            }
            .sidebar-bottom {
                margin-top: auto;
                padding: 8px;
                border-top: 1px solid rgba(255,255,255,0.08);
            }

            .main-content {
                margin-left: 220px;
                padding: 28px;
            }
            .topbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 28px;
            }
            .page-title {
                font-size: 20px;
                font-weight: 600;
                color: #1a2332;
                margin: 0;
            }
            .page-sub {
                font-size: 13px;
                color: #64748b;
                margin: 2px 0 0;
            }
            .admin-badge {
                display: flex;
                align-items: center;
                gap: 8px;
                background: #fff;
                border: 1px solid #e2e8f0;
                border-radius: 20px;
                padding: 6px 14px 6px 8px;
            }
            .admin-avatar-top {
                width: 28px;
                height: 28px;
                border-radius: 50%;
                background: #22c55e20;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 11px;
                font-weight: 600;
                color: #22c55e;
                overflow: hidden;
            }
            .admin-avatar-top img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
            .admin-name {
                font-size: 12px;
                font-weight: 500;
                color: #1a2332;
            }

            .settings-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            .settings-grid-full {
                grid-column: 1 / -1;
            }

            .content-card {
                background: #fff;
                border-radius: 14px;
                border: 1px solid #e2e8f0;
                padding: 24px;
                margin-bottom: 0;
            }
            .card-title {
                font-size: 15px;
                font-weight: 600;
                color: #1a2332;
                margin-bottom: 4px;
            }
            .card-sub {
                font-size: 12px;
                color: #94a3b8;
                margin-bottom: 20px;
            }

            .form-label {
                font-size: 12px;
                color: #64748b;
                margin-bottom: 5px;
                display: block;
            }
            .form-control {
                font-size: 13px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                padding: 9px 12px;
                width: 100%;
                outline: none;
                background: #fff;
                color: #1a2332;
            }
            .form-control:focus {
                border-color: #22c55e;
                box-shadow: 0 0 0 3px #22c55e20;
            }
            .form-control:disabled {
                background: #f8fafc;
                color: #94a3b8;
            }

            /* Profile picture */
            .profile-pic-wrap {
                display: flex;
                align-items: center;
                gap: 20px;
                margin-bottom: 20px;
            }
            .profile-pic-circle {
                width: 80px;
                height: 80px;
                border-radius: 50%;
                border: 2px solid #e2e8f0;
                overflow: hidden;
                background: #22c55e20;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 28px;
                font-weight: 600;
                color: #22c55e;
                flex-shrink: 0;
                cursor: pointer;
                position: relative;
            }
            .profile-pic-circle img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                display: none;
            }
            .profile-pic-overlay {
                position: absolute;
                bottom: 0;
                left: 0;
                right: 0;
                background: rgba(0,0,0,0.4);
                color: #fff;
                font-size: 9px;
                text-align: center;
                padding: 3px 0;
            }
            .profile-pic-input {
                display: none;
            }
            .profile-pic-info {
                font-size: 12px;
                color: #64748b;
            }
            .profile-pic-info span {
                display: block;
                font-size: 11px;
                color: #94a3b8;
                margin-top: 3px;
            }

            /* Progress bar */
            .progress-bar-wrap {
                display: none;
                margin-top: 8px;
            }
            .progress-bar-bg {
                background: #f1f5f9;
                border-radius: 4px;
                height: 5px;
            }
            .progress-bar-fill {
                background: #22c55e;
                height: 5px;
                border-radius: 4px;
                width: 0%;
                transition: width 0.3s;
            }
            .progress-label {
                font-size: 11px;
                color: #64748b;
                margin-top: 3px;
            }

            /* Buttons */
            .btn-save {
                background: #22c55e;
                color: #fff;
                border: none;
                border-radius: 8px;
                padding: 9px 22px;
                font-size: 13px;
                font-weight: 500;
                cursor: pointer;
            }
            .btn-save:hover {
                background: #16a34a;
            }
            .btn-save:disabled {
                background: #86efac;
                cursor: not-allowed;
            }
            .btn-danger {
                background: #fee2e2;
                color: #991b1b;
                border: 1px solid #fecaca;
                border-radius: 8px;
                padding: 9px 22px;
                font-size: 13px;
                font-weight: 500;
                cursor: pointer;
            }
            .btn-danger:hover {
                background: #fecaca;
            }

            /* Alert */
            .alert-msg {
                font-size: 13px;
                padding: 9px 14px;
                border-radius: 8px;
                margin-top: 14px;
                display: none;
            }
            .alert-success {
                background: #d1fae5;
                color: #065f46;
            }
            .alert-error {
                background: #fee2e2;
                color: #991b1b;
            }

            /* About card */
            .about-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 10px 0;
                border-bottom: 1px solid #f8fafc;
                font-size: 13px;
            }
            .about-row:last-child {
                border-bottom: none;
            }
            .about-label {
                color: #64748b;
            }
            .about-value {
                color: #1a2332;
                font-weight: 500;
            }
            .about-badge {
                background: #d1fae5;
                color: #065f46;
                font-size: 11px;
                padding: 3px 10px;
                border-radius: 20px;
                font-weight: 600;
            }

            .strength-bar {
                display: flex;
                gap: 4px;
                margin-top: 6px;
            }
            .strength-seg {
                height: 4px;
                flex: 1;
                border-radius: 2px;
                background: #f1f5f9;
                transition: background 0.3s;
            }
            .strength-label {
                font-size: 11px;
                color: #94a3b8;
                margin-top: 4px;
            }
        </style>
    </head>
    <body>

        <div class="sidebar">
            <div class="sidebar-logo">
                <img src="images/logo.png" alt="GoMart" width="34" height="34" style="border-radius:8px;object-fit:cover;">
                <div>
                    <div class="logo-text">GoMart</div>
                    <div class="logo-sub">Admin Panel</div>
                </div>
            </div>
            <div class="nav-section">Main</div>
            <a href="dashboard.jsp"><i class="fa-solid fa-gauge"></i> Dashboard</a>

            <div class="nav-section">Catalog</div>
            <a href="products.jsp"><i class="fa-solid fa-box"></i> Products</a>
            <a href="categories.jsp"><i class="fa-solid fa-layer-group"></i> Categories</a>
            <a href="brand.jsp" class="active"><i class="fa-solid fa-tags"></i> Brands</a>

            <div class="nav-section">Operations</div>
            <a href="orders.jsp"><i class="fa-solid fa-cart-shopping"></i> Orders</a>
            <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>
            <a href="delivery.jsp"><i class="fa-solid fa-truck"></i> Delivery</a>
            <a href="promotions.jsp"><i class="fa-solid fa-bullhorn"></i> Notifications</a>

            <div class="nav-section">System</div>
            <a href="customers.jsp"><i class="fa-solid fa-users"></i> Customers</a>
            <a href="messaging.jsp"><i class="fa-solid fa-envelope"></i> Messages</a>

            <!--  <a href="settings.jsp">&#9881; Settings</a>-->

            <div class="sidebar-bottom">
                <a href="index.html" id="logoutBtn"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
            </div>
        </div>

        <!-- MAIN -->
        <div class="main-content">

            <div class="topbar">
                <div>
                    <p class="page-title">Settings</p>
                    <p class="page-sub">Manage your admin account and store info</p>
                </div>
                <div class="admin-badge">
                    <div class="admin-avatar-top" id="topbarAvatar">AD</div>
                    <span class="admin-name" id="adminEmail">Admin</span>
                </div>
            </div>

            <div class="settings-grid">

                <!-- Admin Profile -->
                <div class="content-card">
                    <div class="card-title">Admin Profile</div>
                    <div class="card-sub">Update your name and profile picture</div>

                    <div class="profile-pic-wrap">
                        <div class="profile-pic-circle" onclick="document.getElementById('picInput').click()">
                            <img id="profilePicImg" alt="Profile">
                            <span id="profileInitial">A</span>
                            <div class="profile-pic-overlay">Change</div>
                        </div>
                        <input type="file" class="profile-pic-input" id="picInput" accept="image/*"
                               onchange="handlePicChange(this)">
                        <div class="profile-pic-info">
                            Click photo to change
                            <span>JPG or PNG, max 2MB</span>
                        </div>
                    </div>

                    <div class="progress-bar-wrap" id="picProgressWrap">
                        <div class="progress-bar-bg"><div class="progress-bar-fill" id="picProgressBar"></div></div>
                        <div class="progress-label" id="picProgressLabel">Uploading...</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Display Name</label>
                        <input type="text" class="form-control" id="adminName" placeholder="Your name">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email Address</label>
                        <input type="email" class="form-control" id="adminEmailField" disabled>
                    </div>

                    <div class="alert-msg" id="profileAlert"></div>
                    <button class="btn-save" id="profileBtn" onclick="saveProfile()">Save Profile</button>
                </div>

                <!-- Change Password -->
                <div class="content-card">
                    <div class="card-title">Change Password</div>
                    <div class="card-sub">Update your admin login password</div>

                    <div class="mb-3">
                        <label class="form-label">Current Password</label>
                        <input type="password" class="form-control" id="currentPassword" placeholder="••••••••">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">New Password</label>
                        <input type="password" class="form-control" id="newPassword"
                               placeholder="••••••••" oninput="checkStrength(this.value)">
                        <div class="strength-bar">
                            <div class="strength-seg" id="seg1"></div>
                            <div class="strength-seg" id="seg2"></div>
                            <div class="strength-seg" id="seg3"></div>
                            <div class="strength-seg" id="seg4"></div>
                        </div>
                        <div class="strength-label" id="strengthLabel"></div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Confirm New Password</label>
                        <input type="password" class="form-control" id="confirmPassword" placeholder="••••••••">
                    </div>

                    <div class="alert-msg" id="passwordAlert"></div>
                    <button class="btn-save" id="passwordBtn" onclick="changePassword()">Update Password</button>
                </div>

                <!-- Store Info -->
                <div class="content-card">
                    <div class="card-title">Store Information</div>
                    <div class="card-sub">Manage your grocery store details</div>

                    <div class="mb-3">
                        <label class="form-label">Store Name</label>
                        <input type="text" class="form-control" id="storeName" placeholder="e.g. GoMart Grocery">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Phone Number</label>
                        <input type="text" class="form-control" id="storePhone" placeholder="e.g. +94 77 123 4567">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" id="storeEmail" placeholder="store@gomart.com">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Address</label>
                        <input type="text" class="form-control" id="storeAddress" placeholder="Store address">
                    </div>

                    <div class="alert-msg" id="storeAlert"></div>
                    <button class="btn-save" id="storeBtn" onclick="saveStoreInfo()">Save Store Info</button>
                </div>

                <!-- About -->
                <div class="content-card">
                    <div class="card-title">About System</div>
                    <div class="card-sub">GoMart admin panel information</div>

                    <div class="about-row">
                        <span class="about-label">System</span>
                        <span class="about-value">GoMart Admin Panel</span>
                    </div>
                    <div class="about-row">
                        <span class="about-label">Version</span>
                        <span class="about-badge">v1.0.0</span>
                    </div>
                    <div class="about-row">
                        <span class="about-label">Platform</span>
                        <span class="about-value">Java EE + Firebase</span>
                    </div>
                    <div class="about-row">
                        <span class="about-label">Database</span>
                        <span class="about-value">Cloud Firestore</span>
                    </div>
                    <div class="about-row">
                        <span class="about-label">Storage</span>
                        <span class="about-value">Firebase Storage</span>
                    </div>
                    <div class="about-row">
                        <span class="about-label">Mobile App</span>
                        <span class="about-value">Android (Java)</span>
                    </div>
                    <div class="about-row">
                        <span class="about-label">Developed by</span>
                        <span class="about-value">Zenova</span>
                    </div>
                    <div class="about-row">
                        <span class="about-label">Status</span>
                        <span class="about-badge">Active</span>
                    </div>
                </div>

            </div>
        </div>

        <script type="module" src="js/settings.js"></script>
    </body>
</html>