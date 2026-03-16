<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>GoMart Admin - Inventory</title>
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

            .stats-row {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
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

            .filter-row {
                display: flex;
                gap: 10px;
                margin-bottom: 18px;
                flex-wrap: wrap;
                align-items: center;
            }
            .filter-btn {
                padding: 6px 16px;
                border-radius: 20px;
                border: 1px solid #e2e8f0;
                background: #fff;
                font-size: 12px;
                color: #64748b;
                cursor: pointer;
                transition: all 0.15s;
            }
            .filter-btn:hover {
                border-color: #22c55e;
                color: #22c55e;
            }
            .filter-btn.active {
                background: #22c55e;
                color: #fff;
                border-color: #22c55e;
            }
            .search-input {
                padding: 7px 14px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-size: 13px;
                outline: none;
                width: 220px;
            }
            .search-input:focus {
                border-color: #22c55e;
                box-shadow: 0 0 0 3px #22c55e20;
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
            .product-title {
                font-weight: 500;
                color: #1a2332;
            }
            .product-id {
                font-size: 11px;
                color: #94a3b8;
            }
            .product-img {
                width: 44px;
                height: 44px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid #e2e8f0;
            }

            .stock-bar-bg {
                width: 100px;
                height: 6px;
                background: #f1f5f9;
                border-radius: 3px;
                overflow: hidden;
                display: inline-block;
                vertical-align: middle;
                margin-right: 8px;
            }
            .stock-bar-fill {
                height: 100%;
                border-radius: 3px;
            }
            .stock-qty {
                font-size: 13px;
                font-weight: 600;
                vertical-align: middle;
            }

            .status-badge {
                font-size: 10px;
                padding: 4px 10px;
                border-radius: 20px;
                font-weight: 600;
            }
            .s-in-stock {
                background: #d1fae5;
                color: #065f46;
            }
            .s-low-stock {
                background: #fef3c7;
                color: #92400e;
            }
            .s-out-stock {
                background: #fee2e2;
                color: #991b1b;
            }

            .btn-update {
                background: #eff6ff;
                color: #1e40af;
                border: 1px solid #bfdbfe;
                border-radius: 6px;
                padding: 5px 12px;
                font-size: 12px;
                font-weight: 500;
                cursor: pointer;
            }
            .btn-update:hover {
                background: #dbeafe;
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
                margin-bottom: 6px;
            }
            .modal-sub {
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
            }
            .form-control:focus {
                border-color: #22c55e;
                box-shadow: 0 0 0 3px #22c55e20;
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

            .alert-msg {
                font-size: 13px;
                padding: 10px 14px;
                border-radius: 8px;
                margin-bottom: 16px;
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

            <!-- Topbar -->
            <div class="topbar">
                <div>
                    <p class="page-title">Inventory Management</p>
                    <p class="page-sub">Monitor and update product stock levels</p>
                </div>
                <div class="admin-badge">
                    <div class="admin-avatar">AD</div>
                    <span class="admin-name" id="adminEmail">Admin</span>
                </div>
            </div>

            <!-- Stats -->
            <div class="stats-row">
                <div class="stat-card">
                    <div class="stat-val" id="totalProducts">--</div>
                    <div class="stat-label">Total Products</div>
                </div>
                <div class="stat-card">
                    <div class="stat-val" id="inStockCount" style="color:#22c55e">--</div>
                    <div class="stat-label">In Stock</div>
                </div>
                <div class="stat-card">
                    <div class="stat-val" id="lowStockCount" style="color:#f59e0b">--</div>
                    <div class="stat-label">Low Stock</div>
                </div>
                <div class="stat-card">
                    <div class="stat-val" id="outStockCount" style="color:#ef4444">--</div>
                    <div class="stat-label">Out of Stock</div>
                </div>
            </div>

            <!-- Inventory Table -->
            <div class="content-card">
                <div class="card-title">All Products</div>

                <div class="alert-msg" id="alertMsg"></div>

                <!-- Filters -->
                <div class="filter-row">
                    <button class="filter-btn active" onclick="filterProducts('all', this)">All</button>
                    <button class="filter-btn" onclick="filterProducts('in', this)">In Stock</button>
                    <button class="filter-btn" onclick="filterProducts('low', this)">Low Stock</button>
                    <button class="filter-btn" onclick="filterProducts('out', this)">Out of Stock</button>
                    <input type="text" class="search-input" id="searchInput"
                           placeholder="Search product..." oninput="searchProducts()">
                </div>

                <table class="table table-borderless mb-0">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Product</th>
                            <th>Stock Level</th>
                            <th>Status</th>
                            <th>Price</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="inventoryTable">
                        <tr><td colspan="6" class="loading">Loading inventory...</td></tr>
                    </tbody>
                </table>
            </div>

        </div>

        <!-- Update Stock Modal -->
        <div class="modal-overlay" id="stockModal">
            <div class="modal-box">
                <div class="modal-title" id="modalProductTitle">Update Stock</div>
                <div class="modal-sub" id="modalProductId"></div>
                <input type="hidden" id="modalDocId">
                <div class="mb-3">
                    <label class="form-label">Current Stock</label>
                    <input type="number" class="form-control" id="currentStock" disabled>
                </div>
                <div class="mb-3">
                    <label class="form-label">New Stock Count</label>
                    <input type="number" class="form-control" id="newStock" placeholder="Enter new stock count" min="0">
                </div>
                <div class="modal-actions">
                    <button class="btn-cancel" onclick="closeStockModal()">Cancel</button>
                    <button class="btn-save" onclick="saveStock()">Update Stock</button>
                </div>
            </div>
        </div>

        <script type="module" src="js/inventory.js"></script>
    </body>
</html>