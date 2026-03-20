<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>GoMart Admin - Products</title>
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
            .section-divider {
                font-size: 11px;
                color: #94a3b8;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                margin: 20px 0 12px;
                padding-bottom: 6px;
                border-bottom: 1px solid #f1f5f9;
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
                min-height: 80px;
            }

            .img-preview-row {
                display: flex;
                gap: 12px;
                margin-top: 10px;
            }
            .img-preview-box {
                width: 80px;
                height: 80px;
                border-radius: 10px;
                border: 1px dashed #e2e8f0;
                display: flex;
                align-items: center;
                justify-content: center;
                overflow: hidden;
                background: #f8fafc;
            }
            .img-preview-box img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                border-radius: 10px;
                display: none;
            }
            .img-preview-label {
                font-size: 10px;
                color: #94a3b8;
                text-align: center;
            }

            .toggle-row {
                display: flex;
                align-items: center;
                gap: 12px;
            }
            .toggle-switch {
                position: relative;
                width: 44px;
                height: 24px;
            }
            .toggle-switch input {
                opacity: 0;
                width: 0;
                height: 0;
            }
            .toggle-slider {
                position: absolute;
                cursor: pointer;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: #e2e8f0;
                border-radius: 24px;
                transition: 0.3s;
            }
            .toggle-slider:before {
                position: absolute;
                content: "";
                height: 18px;
                width: 18px;
                left: 3px;
                bottom: 3px;
                background: white;
                border-radius: 50%;
                transition: 0.3s;
            }
            input:checked + .toggle-slider {
                background: #22c55e;
            }
            input:checked + .toggle-slider:before {
                transform: translateX(20px);
            }
            .toggle-label {
                font-size: 13px;
                color: #475569;
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

            .btn-add {
                background: #22c55e;
                color: #fff;
                border: none;
                border-radius: 8px;
                padding: 10px 28px;
                font-size: 13px;
                font-weight: 500;
                cursor: pointer;
            }
            .btn-add:hover {
                background: #16a34a;
            }
            .btn-add:disabled {
                background: #86efac;
                cursor: not-allowed;
            }

            .filter-row {
                display: flex;
                gap: 10px;
                margin-bottom: 18px;
                flex-wrap: wrap;
                align-items: center;
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
                padding: 10px 12px;
            }
            .product-img {
                width: 48px;
                height: 48px;
                object-fit: cover;
                border-radius: 8px;
                border: 1px solid #e2e8f0;
            }
            .product-title {
                font-weight: 500;
                color: #1a2332;
            }
            .product-sub {
                font-size: 11px;
                color: #94a3b8;
            }

            .status-badge {
                font-size: 10px;
                padding: 4px 10px;
                border-radius: 20px;
                font-weight: 600;
            }
            .s-active {
                background: #d1fae5;
                color: #065f46;
            }
            .s-inactive {
                background: #fee2e2;
                color: #991b1b;
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
                align-items: flex-start;
                justify-content: center;
                padding: 30px 0;
                overflow-y: auto;
            }
            .modal-overlay.show {
                display: flex;
            }
            .modal-box {
                background: #fff;
                border-radius: 14px;
                padding: 28px;
                width: 100%;
                max-width: 600px;
                margin: auto;
            }
            .modal-title {
                font-size: 16px;
                font-weight: 600;
                color: #1a2332;
                margin-bottom: 20px;
            }
            .modal-actions {
                display: flex;
                gap: 10px;
                margin-top: 24px;
            }
            .btn-cancel {
                flex: 1;
                background: #f1f5f9;
                color: #475569;
                border: none;
                border-radius: 8px;
                padding: 10px;
                font-size: 13px;
                cursor: pointer;
            }
            .btn-save {
                flex: 1;
                background: #22c55e;
                color: #fff;
                border: none;
                border-radius: 8px;
                padding: 10px;
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

        <!-- MAIN -->
        <div class="main-content">

            <div class="topbar">
                <div>
                    <p class="page-title">Product Management</p>
                    <p class="page-sub">Add and manage products</p>
                </div>
                <div class="admin-badge">
                    <div class="admin-avatar">AD</div>
                    <span class="admin-name" id="adminEmail">Admin</span>
                </div>
            </div>

            <div class="content-card">
                <div class="card-title">Add New Product</div>

                <div class="section-divider">Basic Information</div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Product Title</label>
                        <input type="text" class="form-control" id="productTitle" placeholder="e.g. Basmati Rice 5kg">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Price (Rs.)</label>
                        <input type="number" class="form-control" id="productPrice" placeholder="0.00" min="0" step="0.01">
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Description</label>
                        <textarea class="form-control" id="productDescription" placeholder="Product description..."></textarea>
                    </div>
                </div>

                <div class="section-divider">Category & Brand</div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Category</label>
                        <select class="form-select" id="productCategory">
                            <option value="">Select category...</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Brand</label>
                        <select class="form-select" id="productBrand">
                            <option value="">Select brand...</option>
                        </select>
                    </div>
                </div>

                <div class="section-divider">Stock & Status</div>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Stock Count</label>
                        <input type="number" class="form-control" id="productStock" placeholder="0" min="0">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Rating (0-5)</label>
                        <input type="number" class="form-control" id="productRating" placeholder="0.0" min="0" max="5" step="0.1">
                    </div>
                    <div class="col-md-4 d-flex align-items-end pb-1">
                        <div class="toggle-row">
                            <label class="toggle-switch">
                                <input type="checkbox" id="productStatus" checked>
                                <span class="toggle-slider"></span>
                            </label>
                            <span class="toggle-label">Active / Inactive</span>
                        </div>
                    </div>
                </div>

                <div class="section-divider">Product Images (2 images)</div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Image 1 (Main)</label>
                        <input type="file" class="form-control" id="productImage1" accept="image/*"
                               onchange="previewImage(this, 'preview1')">
                        <div class="img-preview-row">
                            <div class="img-preview-box">
                                <img id="preview1" alt="Preview 1">
                                <span class="img-preview-label" id="previewLabel1">No image</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Image 2</label>
                        <input type="file" class="form-control" id="productImage2" accept="image/*"
                               onchange="previewImage(this, 'preview2')">
                        <div class="img-preview-row">
                            <div class="img-preview-box">
                                <img id="preview2" alt="Preview 2">
                                <span class="img-preview-label" id="previewLabel2">No image</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="progress-bar-wrap" id="progressWrap">
                    <div class="progress-bar-bg"><div class="progress-bar-fill" id="progressBar"></div></div>
                    <div class="progress-label" id="progressLabel">Uploading images...</div>
                </div>
                <div class="alert-msg" id="alertMsg"></div>

                <div class="mt-4">
                    <button class="btn-add" id="addBtn" onclick="addProduct()">+ Add Product</button>
                </div>
            </div>

            <div class="content-card">
                <div class="card-title">All Products
                    <span id="productCount" style="font-size:12px;color:#94a3b8;font-weight:400"></span>
                </div>
                <div class="filter-row">
                    <input type="text" class="search-input" id="searchInput"
                           placeholder="Search product..." oninput="searchProducts()">
                </div>
                <table class="table table-borderless mb-0">
                    <thead>
                        <tr>
                            <th>Image</th>
                            <th>Product</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="productsTable">
                        <tr><td colspan="6" class="loading">Loading products...</td></tr>
                    </tbody>
                </table>
            </div>

        </div>

        <div class="modal-overlay" id="editModal">
            <div class="modal-box">
                <div class="modal-title">Edit Product</div>
                <input type="hidden" id="editProductId">

                <div class="section-divider">Basic Information</div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Product Title</label>
                        <input type="text" class="form-control" id="editTitle" placeholder="Product title">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Price (Rs.)</label>
                        <input type="number" class="form-control" id="editPrice" min="0" step="0.01">
                    </div>
                    <div class="col-md-12">
                        <label class="form-label">Description</label>
                        <textarea class="form-control" id="editDescription"></textarea>
                    </div>
                </div>

                <div class="section-divider">Category & Brand</div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Category</label>
                        <select class="form-select" id="editCategory"></select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Brand</label>
                        <select class="form-select" id="editBrand"></select>
                    </div>
                </div>

                <div class="section-divider">Stock & Status</div>
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Stock Count</label>
                        <input type="number" class="form-control" id="editStock" min="0">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Rating (0-5)</label>
                        <input type="number" class="form-control" id="editRating" min="0" max="5" step="0.1">
                    </div>
                    <div class="col-md-4 d-flex align-items-end pb-1">
                        <div class="toggle-row">
                            <label class="toggle-switch">
                                <input type="checkbox" id="editStatus">
                                <span class="toggle-slider"></span>
                            </label>
                            <span class="toggle-label">Active</span>
                        </div>
                    </div>
                </div>

                <div class="section-divider">Update Images (optional)</div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Image 1</label>
                        <img id="editPreview1" style="width:60px;height:60px;object-fit:cover;border-radius:8px;border:1px solid #e2e8f0;display:block;margin-bottom:8px;">
                        <input type="file" class="form-control" id="editImage1" accept="image/*">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Image 2</label>
                        <img id="editPreview2" style="width:60px;height:60px;object-fit:cover;border-radius:8px;border:1px solid #e2e8f0;display:block;margin-bottom:8px;">
                        <input type="file" class="form-control" id="editImage2" accept="image/*">
                    </div>
                </div>

                <div class="progress-bar-wrap" id="editProgressWrap">
                    <div class="progress-bar-bg"><div class="progress-bar-fill" id="editProgressBar"></div></div>
                    <div class="progress-label" id="editProgressLabel">Uploading...</div>
                </div>

                <div class="modal-actions">
                    <button class="btn-cancel" onclick="closeEditModal()">Cancel</button>
                    <button class="btn-save" id="editSaveBtn" onclick="saveEdit()">Save Changes</button>
                </div>
            </div>
        </div>

        <script type="module" src="js/products.js"></script>
    </body>
</html>