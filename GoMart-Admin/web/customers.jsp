<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>GoMart Admin - Customers</title>
            <link rel="icon" type="image/png" href="images/logo.png"" />

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <style>
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
        .logo-text { color: #fff; font-size: 18px; font-weight: 600; }
        .logo-sub { color: rgba(255,255,255,0.35); font-size: 11px; }
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
        .sidebar-bottom { margin-top: auto; padding: 8px; border-top: 1px solid rgba(255,255,255,0.08); }

        .main-content { margin-left: 220px; padding: 28px; }
        .topbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 28px; }
        .page-title { font-size: 20px; font-weight: 600; color: #1a2332; margin: 0; }
        .page-sub { font-size: 13px; color: #64748b; margin: 2px 0 0; }
        .admin-badge {
            display: flex; align-items: center; gap: 8px;
            background: #fff; border: 1px solid #e2e8f0;
            border-radius: 20px; padding: 6px 14px 6px 8px;
        }
        .admin-avatar { width: 28px; height: 28px; border-radius: 50%; background: #22c55e20; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; color: #22c55e; }
        .admin-name { font-size: 12px; font-weight: 500; color: #1a2332; }

        .stats-row { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; margin-bottom: 24px; }
        .stat-card { background: #fff; border-radius: 14px; border: 1px solid #e2e8f0; padding: 16px 20px; }
        .stat-val { font-size: 24px; font-weight: 700; color: #1a2332; }
        .stat-label { font-size: 12px; color: #64748b; margin-top: 3px; }

        .content-card { background: #fff; border-radius: 14px; border: 1px solid #e2e8f0; padding: 24px; margin-bottom: 24px; }
        .card-title { font-size: 15px; font-weight: 600; color: #1a2332; margin-bottom: 18px; }
        .filter-row { display: flex; gap: 10px; margin-bottom: 18px; flex-wrap: wrap; align-items: center; }
        .search-input { padding: 7px 14px; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 13px; outline: none; width: 260px; }
        .search-input:focus { border-color: #22c55e; box-shadow: 0 0 0 3px #22c55e20; }

        .table th { font-size: 11px; color: #94a3b8; font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid #f1f5f9; padding: 10px 12px; }
        .table td { font-size: 13px; color: #1a2332; vertical-align: middle; border-bottom: 1px solid #f8fafc; padding: 12px; }

        .btn-view {
            background: #f8fafc; color: #475569;
            border: 1px solid #e2e8f0; border-radius: 6px;
            padding: 5px 12px; font-size: 12px; cursor: pointer;
        }
        .btn-view:hover { background: #f1f5f9; }

        .loading { color: #94a3b8; font-size: 13px; text-align: center; padding: 30px; }
        .empty-state { text-align: center; padding: 40px; color: #94a3b8; font-size: 13px; }

        .modal-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.4); z-index: 999; align-items: center; justify-content: center; }
        .modal-overlay.show { display: flex; }
        .modal-box { background: #fff; border-radius: 14px; padding: 28px; width: 100%; max-width: 480px; max-height: 85vh; overflow-y: auto; }
        .modal-title { font-size: 16px; font-weight: 600; color: #1a2332; margin-bottom: 20px; }

        .detail-section-title { font-size: 11px; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.05em; margin: 0 0 10px; font-weight: 500; }
        .detail-row { display: flex; justify-content: space-between; padding: 7px 0; border-bottom: 1px solid #f8fafc; font-size: 13px; }
        .detail-row:last-child { border-bottom: none; }
        .detail-label { color: #64748b; }
        .detail-value { color: #1a2332; font-weight: 500; text-align: right; }

        .order-mini-row { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid #f8fafc; font-size: 13px; }
        .order-mini-row:last-child { border-bottom: none; }
        .order-mini-id { font-weight: 600; color: #1a2332; }
        .order-mini-date { font-size: 11px; color: #94a3b8; }
        .order-mini-amount { font-weight: 600; color: #1a2332; }

        .status-pill { font-size: 10px; padding: 3px 8px; border-radius: 20px; font-weight: 600; }
        .s-pending { background: #fef3c7; color: #92400e; }
        .s-processing { background: #dbeafe; color: #1e40af; }
        .s-out-for-delivery { background: #f3e8ff; color: #6b21a8; }
        .s-delivered { background: #d1fae5; color: #065f46; }
        .s-cancelled { background: #fee2e2; color: #991b1b; }

        .modal-footer { display:flex; justify-content:flex-end; margin-top:20px; padding-top:16px; border-top:1px solid #f1f5f9; }
        .btn-close-modal { background:#f1f5f9; color:#475569; border:none; border-radius:8px; padding:9px 20px; font-size:13px; cursor:pointer; }
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
    <a href="brand.jsp"><i class="fa-solid fa-tags"></i> Brands</a>
    <div class="nav-section">Operations</div>
    <a href="orders.jsp"><i class="fa-solid fa-cart-shopping"></i> Orders</a>
    <a href="inventory.jsp"><i class="fa-solid fa-warehouse"></i> Inventory</a>
    <a href="delivery.jsp"><i class="fa-solid fa-truck"></i> Delivery</a>
    <a href="promotions.jsp"><i class="fa-solid fa-bullhorn"></i> Promotions</a>
    <div class="nav-section">System</div>
    <a href="customers.jsp" class="active"><i class="fa-solid fa-users"></i> Customers</a>
    <a href="messaging.jsp"><i class="fa-solid fa-envelope"></i> Messages</a>

    <div class="sidebar-bottom">
        <a href="#" id="logoutBtn"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
    </div>
</div>

<div class="main-content">
    <div class="topbar">
        <div>
            <p class="page-title">Customer Management</p>
            <p class="page-sub">View and manage registered customers</p>
        </div>
        <div class="admin-badge">
            <div class="admin-avatar">AD</div>
            <span class="admin-name" id="adminEmail">Admin</span>
        </div>
    </div>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="stat-val" id="totalCustomers">--</div>
            <div class="stat-label">Total Customers</div>
        </div>
        <div class="stat-card">
            <div class="stat-val" id="withOrders" style="color:#22c55e">--</div>
            <div class="stat-label">Customers with Orders</div>
        </div>
        <div class="stat-card">
            <div class="stat-val" id="noOrders" style="color:#94a3b8">--</div>
            <div class="stat-label">No Orders Yet</div>
        </div>
    </div>

    <!-- Customers Table -->
    <div class="content-card">
        <div class="card-title">All Customers <span id="customerCount" style="font-size:12px;color:#94a3b8;font-weight:400"></span></div>
        <div class="filter-row">
            <input type="text" class="search-input" id="searchInput"
                   placeholder="Search by name, email or mobile..." oninput="searchCustomers()">
        </div>
        <table class="table table-borderless mb-0">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Mobile</th>
                    <th>Email</th>
                    <th>Total Orders</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="customersTable">
                <tr><td colspan="5" class="loading">Loading customers...</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Customer Detail Modal -->
<div class="modal-overlay" id="customerModal">
    <div class="modal-box">
        <div class="modal-title">Customer Details</div>

        <!-- Info -->
        <div class="detail-section-title">Account Info</div>
        <div class="detail-row"><span class="detail-label">Name</span><span class="detail-value" id="modalName">—</span></div>
        <div class="detail-row"><span class="detail-label">Email</span><span class="detail-value" id="modalEmail">—</span></div>
        <div class="detail-row"><span class="detail-label">Mobile</span><span class="detail-value" id="modalMobile">—</span></div>
        <div class="detail-row"><span class="detail-label">User ID</span><span class="detail-value" id="modalUid" style="font-family:monospace">—</span></div>

        <div class="detail-section-title" style="margin-top:20px">Order History</div>
        <div id="modalOrders">
            <div class="loading">Loading orders...</div>
        </div>

        <div class="modal-footer">
            <button class="btn-close-modal" onclick="closeCustomerModal()">Close</button>
        </div>
    </div>
</div>

<script type="module" src="js/customers.js"></script>
</body>
</html>