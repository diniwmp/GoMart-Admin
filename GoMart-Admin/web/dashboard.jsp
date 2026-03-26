<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>GoMart Admin - Dashboard</title>
        <link rel="icon" type="image/png" href="images/logo.png" />
        <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
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
            .logo-sub  {
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
            .page-sub   {
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

            .stat-card {
                background: #fff;
                border-radius: 14px;
                border: 1px solid #e2e8f0;
                padding: 20px;
                display: flex;
                align-items: center;
                gap: 16px;
            }
            .stat-icon-box {
                width: 48px;
                height: 48px;
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 22px;
                flex-shrink: 0;
            }
            .stat-icon-box i {
                font-size: 20px;
                color: #333;
            }
            .stat-val   {
                font-size: 26px;
                font-weight: 700;
                color: #1a2332;
                line-height: 1;
            }
            .stat-label {
                font-size: 12px;
                color: #64748b;
                margin-top: 4px;
            }

            .content-card {
                background: #fff;
                border-radius: 14px;
                border: 1px solid #e2e8f0;
                padding: 20px;
                margin-bottom: 20px;
            }
            .card-title-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 16px;
            }
            .card-title {
                font-size: 14px;
                font-weight: 600;
                color: #1a2332;
            }
            .card-link  {
                font-size: 12px;
                color: #22c55e;
                text-decoration: none;
            }
            .card-link i {
                margin-left: 6px;
                transition: transform 0.2s ease;
            }
            .card-link:hover i {
                transform: translateX(4px);
            }

            .table th {
                font-size: 11px;
                color: #94a3b8;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                border-bottom: 1px solid #f1f5f9;
            }
            .table td {
                font-size: 13px;
                color: #1a2332;
                vertical-align: middle;
                border-bottom: 1px solid #f8fafc;
            }
            .order-id    {
                font-weight: 600;
            }
            .customer-name {
                color: #475569;
            }

            .status-pill {
                font-size: 10px;
                padding: 4px 10px;
                border-radius: 20px;
                font-weight: 600;
            }
            .s-pending    {
                background: #fef3c7;
                color: #92400e;
            }
            .s-delivered  {
                background:#e0e7ff  ;
                color: #594a7f;
            }
            .s-processing {
                background: #dbeafe;
                color: #1e40af;
            }
            .s-cancelled  {
                background: #fee2e2;
                color: #991b1b;
            }
            .s-paid {
                background:#d1fae5;
                color: #065f46;
            }
            .inv-row {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 10px 0;
                border-bottom: 1px solid #f8fafc;
            }
            .inv-row:last-child {
                border-bottom: none;
            }
            .inv-dot  {
                width: 8px;
                height: 8px;
                border-radius: 50%;
                flex-shrink: 0;
            }
            .inv-name {
                font-size: 13px;
                color: #1a2332;
                flex: 1;
            }
            .inv-qty  {
                font-size: 12px;
                color: #64748b;
                min-width: 60px;
                text-align: right;
            }
            .bar-bg   {
                width: 80px;
                height: 6px;
                background: #f1f5f9;
                border-radius: 3px;
                overflow: hidden;
            }
            .bar-fill {
                height: 100%;
                border-radius: 3px;
            }

            .loading {
                color: #94a3b8;
                font-size: 13px;
                text-align: center;
                padding: 20px;
            }
        </style>
    </head>
    <body>

        <!-- SIDEBAR -->
        <div class="sidebar">
            <div class="sidebar-logo">
                <img src="images/logo.png" alt="GoMart" width="34" height="34"
                     style="border-radius:8px;object-fit:cover;">
                <div>
                    <div class="logo-text">GoMart</div>
                    <div class="logo-sub">Admin Panel</div>
                </div>
            </div>
            <div class="nav-section">Main</div>
            <a href="dashboard.jsp" class="active"><i class="fa-solid fa-gauge"></i> Dashboard</a>
            <div class="nav-section">Catalog</div>
            <a href="products.jsp"><i class="fa-solid fa-box"></i> Products</a>
            <a href="categories.jsp"><i class="fa-solid fa-layer-group"></i> Categories</a>
            <a href="brand.jsp"><i class="fa-solid fa-tags"></i> Brands</a>
            <div class="nav-section">Operations</div>
            <a href="orders.jsp"><i class="fa-solid fa-cart-shopping"></i> Orders</a>
            <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>
            <a href="delivery.jsp"><i class="fa-solid fa-truck"></i> Delivery</a>
            <a href="promotions.jsp"><i class="fa-solid fa-bullhorn"></i> Notifications</a>
            <div class="nav-section">System</div>
            <a href="customers.jsp"><i class="fa-solid fa-users"></i> Customers</a>
            <a href="messaging.jsp"><i class="fa-solid fa-envelope"></i> Messages</a>
            <div class="sidebar-bottom">
                <a href="index.html" id="logoutBtn">
                    <i class="fa-solid fa-right-from-bracket"></i> Logout
                </a>
            </div>
        </div>

        <div class="main-content">

            <div class="topbar">
                <div>
                    <p class="page-title">Dashboard</p>
                    <p class="page-sub">Welcome back, Admin</p>
                </div>
                <div class="admin-badge">
                    <div class="admin-avatar">AD</div>
                    <span class="admin-name" id="adminEmail">Admin</span>
                </div>
            </div>

            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon-box" style="background:#22c55e15">
                            <i class="fa-solid fa-box"></i>
                        </div>
                        <div>
                            <div class="stat-val" id="totalProducts">--</div>
                            <div class="stat-label">Total Products</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon-box" style="background:#3b82f615">
                            <i class="fa-solid fa-tags"></i>
                        </div>
                        <div>
                            <div class="stat-val" id="totalBrands">--</div>
                            <div class="stat-label">Total Brands</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon-box" style="background:#f59e0b15">
                            <i class="fa-solid fa-cart-shopping"></i>
                        </div>
                        <div>
                            <div class="stat-val" id="totalOrders">--</div>
                            <div class="stat-label">Total Orders</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon-box" style="background:#ef444415">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                        </div>
                        <div>
                            <div class="stat-val" id="lowStock"
                                 style="color:#ef4444">--</div>
                            <div class="stat-label">Low Stock Items</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-6">
                    <div class="content-card">
                        <div class="card-title-row">
                            <span class="card-title">Recent Orders</span>
                            <a href="orders.jsp" class="card-link">
                                View all <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                        <table class="table table-borderless mb-0">
                            <thead>
                                <tr>
                                    <th>Order ID</th>
                                    <th>Customer</th>
                                    <th>Status</th>
                                    <th>Time</th>
                                </tr>
                            </thead>
                            <tbody id="recentOrders">
                                <tr><td colspan="4" class="loading">
                                        Loading orders...
                                    </td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="content-card">
                        <div class="card-title-row">
                            <span class="card-title">Inventory Status</span>
                            <a href="inventory.jsp" class="card-link">
                                Manage <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                        <div id="inventoryList">
                            <div class="loading">Loading inventory...</div>
                        </div>
                    </div>
                </div>
            </div>



        </div>

        <script type="module" src="js/dashboard.js"></script>
    </body>
</html>
