<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>GoMart Admin - Promotions</title>
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
            .admin-avatar {
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
            }
            .admin-name {
                font-size: 12px;
                font-weight: 500;
                color: #1a2332;
            }

            .stats-row {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 14px;
                margin-bottom: 24px;
            }
            .stat-card {
                background: #fff;
                border-radius: 14px;
                border: 1px solid #e2e8f0;
                padding: 16px 20px;
            }
            .stat-val {
                font-size: 24px;
                font-weight: 700;
                color: #1a2332;
            }
            .stat-label {
                font-size: 12px;
                color: #64748b;
                margin-top: 3px;
            }

            .content-card {
                background: #fff;
                border-radius: 14px;
                border: 1px solid #e2e8f0;
                padding: 24px;
                margin-bottom: 24px;
            }
            .card-title {
                font-size: 15px;
                font-weight: 600;
                color: #1a2332;
                margin-bottom: 18px;
            }

            .form-label {
                font-size: 12px;
                color: #64748b;
                margin-bottom: 5px;
                display: block;
            }
            .form-control, .form-select {
                font-size: 13px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                padding: 9px 12px;
                width: 100%;
                outline: none;
            }
            .form-control:focus, .form-select:focus {
                border-color: #22c55e;
                box-shadow: 0 0 0 3px #22c55e20;
            }
            textarea.form-control {
                resize: vertical;
                min-height: 90px;
            }

            .promo-preview {
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 16px;
                margin-top: 16px;
                display: none;
            }
            .promo-preview-title {
                font-size: 11px;
                color: #94a3b8;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                margin-bottom: 10px;
            }
            .notif-card {
                background: #fff;
                border-radius: 10px;
                border: 1px solid #e2e8f0;
                padding: 14px;
                display: flex;
                gap: 12px;
                align-items: flex-start;
            }
            .notif-icon {
                width: 36px;
                height: 36px;
                border-radius: 10px;
                background: #22c55e20;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 16px;
                flex-shrink: 0;
            }
            .notif-title {
                font-size: 13px;
                font-weight: 600;
                color: #1a2332;
            }
            .notif-message {
                font-size: 12px;
                color: #64748b;
                margin-top: 2px;
            }
            .notif-time {
                font-size: 10px;
                color: #94a3b8;
                margin-top: 4px;
            }

            .type-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 10px;
                margin-bottom: 4px;
            }
            .type-card {
                border: 1px solid #e2e8f0;
                border-radius: 10px;
                padding: 12px;
                cursor: pointer;
                text-align: center;
                transition: all 0.15s;
            }
            .type-card:hover {
                border-color: #22c55e;
            }
            .type-card.selected {
                border-color: #22c55e;
                background: #f0fdf4;
            }
            .type-card input {
                display: none;
            }
            .type-icon {
                font-size: 20px;
                margin-bottom: 4px;
            }
            .type-label {
                font-size: 12px;
                font-weight: 500;
                color: #475569;
            }

            .btn-send {
                background: #22c55e;
                color: #fff;
                border: none;
                border-radius: 8px;
                padding: 10px 28px;
                font-size: 13px;
                font-weight: 500;
                cursor: pointer;
            }
            .btn-send:hover {
                background: #16a34a;
            }
            .btn-send:disabled {
                background: #86efac;
                cursor: not-allowed;
            }

            .alert-msg {
                font-size: 13px;
                padding: 10px 14px;
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

            .table th {
                font-size: 11px;
                color: #94a3b8;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                border-bottom: 1px solid #f1f5f9;
                padding: 10px 12px;
            }
            .table td {
                font-size: 13px;
                color: #1a2332;
                vertical-align: middle;
                border-bottom: 1px solid #f8fafc;
                padding: 12px;
            }

            .type-badge {
                font-size: 10px;
                padding: 3px 10px;
                border-radius: 20px;
                font-weight: 600;
            }
            .t-promo {
                background: #fef3c7;
                color: #92400e;
            }
            .t-system {
                background: #dbeafe;
                color: #1e40af;
            }
            .t-sale {
                background: #fce7f3;
                color: #9d174d;
            }

            .btn-delete {
                background: #fff1f2;
                color: #991b1b;
                border: 1px solid #fecaca;
                border-radius: 6px;
                padding: 5px 12px;
                font-size: 12px;
                font-weight: 500;
                cursor: pointer;
            }
            .btn-delete:hover {
                background: #fee2e2;
            }

            .loading {
                color: #94a3b8;
                font-size: 13px;
                text-align: center;
                padding: 30px;
            }
            .empty-state {
                text-align: center;
                padding: 40px;
                color: #94a3b8;
                font-size: 13px;
            }
        </style>
    </head>
    <body>

        <!-- SIDEBAR -->
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
            <a href="promotions.jsp"><i class="fa-solid fa-bullhorn"></i> Promotions</a>

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
                    <p class="page-title">Promotional Messages</p>
                    <p class="page-sub">Send notifications to all customers</p>
                </div>
                <div class="admin-badge">
                    <div class="admin-avatar">AD</div>
                    <span class="admin-name" id="adminEmail">Admin</span>
                </div>
            </div>

            <!-- Stats -->
            <div class="stats-row">
                <div class="stat-card">
                    <div class="stat-val" id="totalSent">--</div>
                    <div class="stat-label">Total Sent</div>
                </div>
                <div class="stat-card">
                    <div class="stat-val" id="promoCount" style="color:#f59e0b">--</div>
                    <div class="stat-label">Promotions</div>
                </div>
                <div class="stat-card">
                    <div class="stat-val" id="systemCount" style="color:#3b82f6">--</div>
                    <div class="stat-label">System Messages</div>
                </div>
            </div>

            <!-- Send Form -->
            <div class="content-card">
                <div class="card-title">Send New Notification</div>

                <!-- Type selector -->
                <div class="mb-3">
                    <label class="form-label">Notification Type</label>
                    <div class="type-grid">
                        <label class="type-card selected" onclick="selectType(this, 'PROMO')">
                            <input type="radio" name="notifType" value="PROMO" checked>
                            <div class="type-icon"><i class="bi bi-tag-fill" style="font-size:20px;color:#f59e0b"></i></div>
                            <div class="type-label">Promotion</div>
                        </label>
                        <label class="type-card" onclick="selectType(this, 'SALE')">
                            <input type="radio" name="notifType" value="SALE">
                            <div class="type-icon"><i class="bi bi-percent" style="font-size:20px;color:#22c55e"></i></div>
                            <div class="type-label">Sale</div>
                        </label>
                        <label class="type-card" onclick="selectType(this, 'SYSTEM')">
                            <input type="radio" name="notifType" value="SYSTEM">
                            <div class="type-icon"><i class="bi bi-megaphone-fill" style="font-size:20px;color:#3b82f6"></i></div>
                            <div class="type-label">System</div>
                        </label>
                    </div>
                </div>

                <div class="row g-3">
                    <div class="col-md-12">
                        <label class="form-label">Notification Title</label>
                        <input type="text" class="form-control" id="notifTitle"
                               placeholder="e.g. Special Weekend Offer!"
                               oninput="updatePreview()">
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Message</label>
                        <textarea class="form-control" id="notifMessage"
                                  placeholder="e.g. Get 20% off on all products this weekend only. Shop now!"
                                  oninput="updatePreview()"></textarea>
                    </div>
                </div>

                <div class="promo-preview" id="promoPreview">
                    <div class="promo-preview-title">Preview — how it looks on mobile</div>
                    <div class="notif-card">
                        <div class="notif-icon"><i class="bi bi-tag-fill" style="font-size:20px;color:#f59e0b"></i></div>
                        <div>
                            <div class="notif-title" id="previewTitle">Title here</div>
                            <div class="notif-message" id="previewMessage">Message here</div>
                            <div class="notif-time">Just now</div>
                        </div>
                    </div>
                </div>

                <div class="alert-msg" id="alertMsg"></div>

                <div class="mt-4">
                    <button class="btn-send" id="sendBtn" onclick="sendNotification()">
                        &#9993; Send to All Customers
                    </button>
                </div>
            </div>

            <div class="content-card">
                <div class="card-title">Sent Notifications
                    <span id="notifCount" style="font-size:12px;color:#94a3b8;font-weight:400"></span>
                </div>
                <table class="table table-borderless mb-0">
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Message</th>
                            <th>Type</th>
                            <th>Sent At</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="notifTable">
                        <tr><td colspan="5" class="loading">Loading notifications...</td></tr>
                    </tbody>
                </table>
            </div>

        </div>

        <script type="module" src="js/promotions.js"></script>
    </body>
</html>