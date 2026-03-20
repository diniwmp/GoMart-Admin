<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>GoMart Admin - Categories</title>
        <link rel="icon" type="image/png" href="images/logo.png"" />

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
            }
            .form-control {
                font-size: 13px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                padding: 9px 12px;
            }
            .form-control:focus {
                border-color: #22c55e;
                box-shadow: 0 0 0 3px #22c55e20;
                outline: none;
            }

            .btn-add {
                background: #22c55e;
                color: #fff;
                border: none;
                border-radius: 8px;
                padding: 9px 20px;
                font-size: 13px;
                font-weight: 500;
                cursor: pointer;
                width: 100%;
            }
            .btn-add:hover {
                background: #16a34a;
            }
            .btn-add:disabled {
                background: #86efac;
                cursor: not-allowed;
            }

            .progress-bar-wrap {
                display: none;
                margin-top: 10px;
            }
            .progress-bar-bg {
                background: #f1f5f9;
                border-radius: 4px;
                height: 6px;
            }
            .progress-bar-fill {
                background: #22c55e;
                height: 6px;
                border-radius: 4px;
                width: 0%;
                transition: width 0.3s;
            }
            .progress-label {
                font-size: 11px;
                color: #64748b;
                margin-top: 4px;
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
                padding: 10px 12px;
            }
            .category-img {
                width: 52px;
                height: 52px;
                object-fit: cover;
                border-radius: 10px;
                border: 1px solid #e2e8f0;
            }
            .category-name {
                font-weight: 500;
                color: #1a2332;
            }

            .btn-edit {
                background: #eff6ff;
                color: #1e40af;
                border: 1px solid #bfdbfe;
                border-radius: 6px;
                padding: 5px 12px;
                font-size: 12px;
                font-weight: 500;
                cursor: pointer;
            }
            .btn-edit:hover {
                background: #dbeafe;
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
                margin-left: 6px;
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

            .modal-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0,0,0,0.4);
                z-index: 999;
                align-items: center;
                justify-content: center;
            }
            .modal-overlay.show {
                display: flex;
            }
            .modal-box {
                background: #fff;
                border-radius: 14px;
                padding: 28px;
                width: 100%;
                max-width: 400px;
            }
            .modal-title {
                font-size: 16px;
                font-weight: 600;
                color: #1a2332;
                margin-bottom: 18px;
            }
            .modal-actions {
                display: flex;
                gap: 10px;
                margin-top: 20px;
            }
            .btn-cancel {
                flex: 1;
                background: #f1f5f9;
                color: #475569;
                border: none;
                border-radius: 8px;
                padding: 9px;
                font-size: 13px;
                cursor: pointer;
            }
            .btn-save {
                flex: 1;
                background: #22c55e;
                color: #fff;
                border: none;
                border-radius: 8px;
                padding: 9px;
                font-size: 13px;
                font-weight: 500;
                cursor: pointer;
            }
            .btn-save:hover {
                background: #16a34a;
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

        <div class="main-content">

            <div class="topbar">
                <div>
                    <p class="page-title">Category Management</p>
                    <p class="page-sub">Add and manage product categories</p>
                </div>
                <div class="admin-badge">
                    <div class="admin-avatar">AD</div>
                    <span class="admin-name" id="adminEmail">Admin</span>
                </div>
            </div>

            <div class="content-card">
                <div class="card-title">Add New Category</div>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Category Name</label>
                        <input type="text" class="form-control" id="categoryName" placeholder="e.g. Beverages">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Category Image</label>
                        <input type="file" class="form-control" id="categoryImage" accept="image/*">
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <button class="btn-add" id="addBtn" onclick="addCategory()">+ Add Category</button>
                    </div>
                </div>
                <div class="progress-bar-wrap" id="progressWrap">
                    <div class="progress-bar-bg">
                        <div class="progress-bar-fill" id="progressBar"></div>
                    </div>
                    <div class="progress-label" id="progressLabel">Uploading image...</div>
                </div>
                <div class="alert-msg" id="alertMsg"></div>
            </div>

            <div class="content-card">
                <div class="card-title">
                    All Categories
                    <span id="categoryCount" style="font-size:12px;color:#94a3b8;font-weight:400"></span>
                </div>
                <table class="table table-borderless mb-0">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Category Name</th>
                            <th>Category ID</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="categoryTable">
                        <tr><td colspan="4" class="loading">Loading categories...</td></tr>
                    </tbody>
                </table>
            </div>

        </div>

        <div class="modal-overlay" id="editModal">
            <div class="modal-box">
                <div class="modal-title">Edit Category</div>
                <input type="hidden" id="editCategoryId">
                <div class="mb-3">
                    <label class="form-label">Category Name</label>
                    <input type="text" class="form-control" id="editCategoryName" placeholder="Category name">
                </div>
                <div class="mb-3">
                    <label class="form-label">Update Image (optional)</label>
                    <input type="file" class="form-control" id="editCategoryImage" accept="image/*">
                </div>
                <div class="modal-actions">
                    <button class="btn-cancel" onclick="closeEditModal()">Cancel</button>
                    <button class="btn-save" onclick="saveEdit()">Save Changes</button>
                </div>
            </div>
        </div>

        <!-- JS controller -->
        <script type="module" src="js/category.js"></script>
    </body>
</html>