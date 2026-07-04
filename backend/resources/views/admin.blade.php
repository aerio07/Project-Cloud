<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - MySPBU</title>
    
    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Maps JS API -->
    <script src="https://maps.googleapis.com/maps/api/js?key={{ env('GOOGLE_MAPS_API_KEY') }}&v=weekly"></script>

    <style>
        :root {
            --bg-primary: #0f172a;
            --bg-secondary: #1e293b;
            --bg-tertiary: #0b0f19;
            --text-main: #f8fafc;
            --text-soft: #94a3b8;
            --brand-primary: #e31e24;
            --brand-primary-hover: #b91c1c;
            --brand-accent: #3b82f6;
            --brand-success: #10b981;
            --brand-warning: #f59e0b;
            --border-color: rgba(148, 163, 184, 0.1);
            --glass-bg: rgba(30, 41, 59, 0.45);
            --glass-border: rgba(255, 255, 255, 0.05);
            --sidebar-width: 280px;
            --transition-speed: 0.25s;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background-color: var(--bg-primary);
            color: var(--text-main);
            overflow-x: hidden;
            min-height: 100vh;
        }

        /* Scrollbar Styling */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }
        ::-webkit-scrollbar-track {
            background: var(--bg-primary);
        }
        ::-webkit-scrollbar-thumb {
            background: var(--bg-secondary);
            border-radius: 4px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: var(--brand-primary);
        }

        /* Utility Classes */
        .glass-panel {
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--glass-border);
            border-radius: 16px;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 18px;
            border-radius: 12px;
            border: none;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--transition-speed) ease;
        }

        .btn-primary {
            background-color: var(--brand-primary);
            color: white;
            box-shadow: 0 4px 15px rgba(227, 30, 36, 0.3);
        }

        .btn-primary:hover {
            background-color: var(--brand-primary-hover);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(227, 30, 36, 0.45);
        }

        .btn-secondary {
            background-color: var(--bg-secondary);
            color: var(--text-main);
            border: 1px solid var(--border-color);
        }

        .btn-secondary:hover {
            background-color: rgba(255, 255, 255, 0.05);
            transform: translateY(-2px);
        }

        .btn-danger {
            background-color: rgba(239, 68, 68, 0.15);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }

        .btn-danger:hover {
            background-color: #ef4444;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(239, 68, 68, 0.3);
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 8px;
        }

        /* Login Container */
        .login-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 20px;
            background: radial-gradient(circle at top right, rgba(227, 30, 36, 0.12), transparent 45%),
                        radial-gradient(circle at bottom left, rgba(59, 130, 246, 0.08), transparent 45%),
                        var(--bg-tertiary);
        }

        .login-card {
            width: 100%;
            max-width: 440px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
            border: 1px solid rgba(255, 255, 255, 0.05);
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-logo {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-hover));
            border-radius: 16px;
            color: white;
            font-size: 28px;
            margin-bottom: 16px;
            box-shadow: 0 8px 24px rgba(227, 30, 36, 0.3);
        }

        .login-header h2 {
            font-weight: 700;
            font-size: 24px;
            letter-spacing: -0.5px;
        }

        .login-header p {
            color: var(--text-soft);
            font-size: 13px;
            margin-top: 4px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: var(--text-soft);
            margin-bottom: 8px;
        }

        .form-control {
            width: 100%;
            padding: 12px 16px;
            background-color: rgba(15, 23, 42, 0.6);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            color: white;
            font-size: 14px;
            transition: all var(--transition-speed);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--brand-primary);
            box-shadow: 0 0 0 3px rgba(227, 30, 36, 0.15);
            background-color: rgba(15, 23, 42, 0.8);
        }

        .form-error {
            color: #ef4444;
            font-size: 12px;
            margin-top: 8px;
            display: none;
        }

        /* Dashboard Layout */
        .dashboard-wrapper {
            display: none; /* Show when authenticated */
            min-height: 100vh;
        }

        /* Sidebar styling */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            bottom: 0;
            width: var(--sidebar-width);
            background-color: var(--bg-tertiary);
            border-right: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            padding: 24px;
            z-index: 100;
        }

        .brand-section {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 40px;
        }

        .brand-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 40px;
            background-color: var(--brand-primary);
            color: white;
            border-radius: 10px;
            font-size: 20px;
        }

        .brand-title {
            font-weight: 800;
            font-size: 20px;
            letter-spacing: -0.5px;
            color: var(--text-main);
        }

        .nav-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex-grow: 1;
        }

        .nav-item a {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 12px 16px;
            color: var(--text-soft);
            text-decoration: none;
            border-radius: 12px;
            font-weight: 500;
            font-size: 14px;
            transition: all var(--transition-speed);
        }

        .nav-item a:hover, .nav-item.active a {
            color: white;
            background-color: var(--bg-secondary);
        }

        .nav-item.active a {
            border-left: 3px solid var(--brand-primary);
            border-radius: 4px 12px 12px 4px;
            background: linear-gradient(90deg, rgba(227, 30, 36, 0.08), transparent);
        }

        .nav-item a i {
            font-size: 16px;
            width: 20px;
            text-align: center;
        }

        .admin-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px;
            border-top: 1px solid var(--border-color);
            margin-top: 20px;
        }

        .admin-avatar {
            width: 40px;
            height: 40px;
            background-color: rgba(227, 30, 36, 0.1);
            color: var(--brand-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            font-size: 18px;
        }

        .admin-info h4 {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-main);
            max-width: 140px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .admin-info p {
            font-size: 11px;
            color: var(--text-soft);
        }

        /* Main panel styling */
        .main-panel {
            margin-left: var(--sidebar-width);
            padding: 40px;
            min-height: 100vh;
            background-color: var(--bg-primary);
        }

        .tab-panel {
            display: none;
        }

        .tab-panel.active {
            display: block;
            animation: fadeIn 0.4s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .panel-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 30px;
        }

        .panel-title h1 {
            font-size: 26px;
            font-weight: 700;
            letter-spacing: -0.5px;
        }

        .panel-title p {
            font-size: 14px;
            color: var(--text-soft);
            margin-top: 4px;
        }

        /* Stat Grid */
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 24px;
            margin-bottom: 36px;
        }

        .stat-card {
            padding: 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .stat-info h3 {
            font-size: 28px;
            font-weight: 700;
            margin-top: 4px;
        }

        .stat-info p {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-soft);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
        }

        .stat-card:nth-child(1) .stat-icon { background: rgba(227, 30, 36, 0.1); color: var(--brand-primary); }
        .stat-card:nth-child(2) .stat-icon { background: rgba(59, 130, 246, 0.1); color: var(--brand-accent); }
        .stat-card:nth-child(3) .stat-icon { background: rgba(16, 185, 129, 0.1); color: var(--brand-success); }
        .stat-card:nth-child(4) .stat-icon { background: rgba(245, 158, 11, 0.1); color: var(--brand-warning); }

        /* Tables & Lists */
        .table-responsive {
            width: 100%;
            overflow-x: auto;
            border: 1px solid var(--border-color);
            border-radius: 16px;
        }

        .custom-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 14px;
            background: var(--glass-bg);
        }

        .custom-table th, .custom-table td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--border-color);
        }

        .custom-table th {
            background-color: rgba(15, 23, 42, 0.4);
            color: var(--text-soft);
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .custom-table tr:last-child td {
            border-bottom: none;
        }

        .custom-table tr:hover td {
            background-color: rgba(255, 255, 255, 0.01);
        }

        .badge {
            display: inline-flex;
            align-items: center;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 600;
        }

        .badge-success { background: rgba(16, 185, 129, 0.1); color: var(--brand-success); }
        .badge-danger { background: rgba(239, 68, 68, 0.1); color: #ef4444; }

        .search-bar-wrapper {
            margin-bottom: 20px;
            max-width: 360px;
            position: relative;
        }

        .search-bar-wrapper i {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-soft);
        }

        .search-bar-wrapper input {
            padding-left: 44px;
        }

        .spbu-thumb {
            width: 44px;
            height: 44px;
            border-radius: 8px;
            object-fit: cover;
            background-color: var(--bg-secondary);
        }

        /* Modals */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(15, 23, 42, 0.7);
            backdrop-filter: blur(8px);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            padding: 20px;
        }

        .modal-overlay.active {
            display: flex;
        }

        .modal-card {
            width: 100%;
            max-width: 780px;
            max-height: 90vh;
            overflow-y: auto;
            border: 1px solid var(--glass-border);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
            display: flex;
            flex-direction: column;
        }

        .modal-header {
            padding: 24px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .modal-header h3 {
            font-size: 18px;
            font-weight: 700;
        }

        .modal-close {
            background: none;
            border: none;
            color: var(--text-soft);
            font-size: 20px;
            cursor: pointer;
            transition: color var(--transition-speed);
        }

        .modal-close:hover {
            color: white;
        }

        .modal-body {
            padding: 24px;
        }

        .modal-footer {
            padding: 20px 24px;
            border-top: 1px solid var(--border-color);
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }

        /* Columns in Modal */
        .modal-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        @media (max-width: 768px) {
            .modal-grid-2 {
                grid-template-columns: 1fr;
            }
        }

        /* Checkbox selectors */
        .checkbox-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 12px;
            margin-top: 8px;
        }

        .checkbox-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: var(--text-soft);
            cursor: pointer;
            user-select: none;
        }

        .checkbox-item input {
            accent-color: var(--brand-primary);
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        /* Map styling in modal */
        #google-map {
            width: 100%;
            height: 220px;
            border-radius: 12px;
            border: 1px solid var(--border-color);
            margin-bottom: 16px;
            z-index: 1;
        }

        /* Photo Upload UI */
        .upload-area {
            border: 2px dashed var(--border-color);
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            transition: all var(--transition-speed);
            margin-bottom: 16px;
        }

        .upload-area:hover {
            border-color: var(--brand-primary);
            background-color: rgba(227, 30, 36, 0.02);
        }

        .upload-area i {
            font-size: 32px;
            color: var(--brand-primary);
            margin-bottom: 8px;
        }

        .upload-area p {
            font-size: 13px;
            color: var(--text-soft);
        }

        .photo-previews {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 10px;
        }

        .photo-preview-item {
            position: relative;
            width: 80px;
            height: 80px;
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid var(--border-color);
        }

        .photo-preview-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .photo-preview-item .remove-btn {
            position: absolute;
            top: 2px;
            right: 2px;
            width: 20px;
            height: 20px;
            background-color: rgba(0, 0, 0, 0.6);
            color: white;
            border: none;
            border-radius: 50%;
            font-size: 10px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Toast notifications */
        .toast-container {
            position: fixed;
            bottom: 30px;
            right: 30px;
            z-index: 9999;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .toast {
            min-width: 280px;
            padding: 16px 20px;
            color: white;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.3s ease, fadeOut 0.3s ease 3.7s forwards;
        }

        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }

        @keyframes fadeOut {
            from { opacity: 1; }
            to { opacity: 0; transform: translateY(10px); visibility: hidden; }
        }

        .toast-success {
            background-color: #10b981;
            border-left: 4px solid #047857;
        }

        .toast-error {
            background-color: #ef4444;
            border-left: 4px solid #b91c1c;
        }

        /* Fuel price editing list */
        .fuel-price-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-top: 8px;
        }

        .fuel-price-row {
            display: flex;
            align-items: center;
            gap: 12px;
            background: rgba(15, 23, 42, 0.2);
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
        }

        .fuel-price-row span {
            flex-grow: 1;
            font-size: 13px;
            font-weight: 500;
        }

        .fuel-price-row input[type="number"] {
            width: 120px;
            padding: 6px 10px;
            font-size: 13px;
        }

        .fuel-price-row input[type="checkbox"] {
            accent-color: var(--brand-primary);
            width: 16px;
            height: 16px;
        }
    </style>
</head>
<body>

    <!-- Toast Notifications -->
    <div class="toast-container" id="toast-container"></div>

    <!-- Login screen -->
    <div class="login-wrapper" id="login-wrapper">
        <div class="login-card glass-panel">
            <div class="login-header">
                <div class="login-logo">
                    <i class="fa-solid fa-gas-station"></i>
                </div>
                <h2>MySPBU Admin</h2>
                <p>Silakan masuk menggunakan akun admin Anda</p>
            </div>
            
            <form id="login-form">
                <div class="form-group">
                    <label for="login-email">Alamat Email</label>
                    <input type="email" id="login-email" class="form-control" placeholder="admin@myspbu.com" required>
                </div>
                <div class="form-group">
                    <label for="login-password">Kata Sandi</label>
                    <input type="password" id="login-password" class="form-control" placeholder="••••••••" required>
                </div>
                
                <div class="form-error" id="login-error"></div>
                
                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px;">
                    Masuk Sekarang <i class="fa-solid fa-arrow-right"></i>
                </button>
            </form>
        </div>
    </div>

    <!-- Main Dashboard Application -->
    <div class="dashboard-wrapper" id="dashboard-wrapper">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="brand-section">
                <div class="brand-icon">
                    <i class="fa-solid fa-gas-station"></i>
                </div>
                <span class="brand-title">MySPBU Panel</span>
            </div>
            
            <nav style="flex-grow: 1;">
                <ul class="nav-list">
                    <li class="nav-item active" data-tab="tab-dashboard">
                        <a href="#"><i class="fa-solid fa-chart-pie"></i> Ringkasan</a>
                    </li>
                    <li class="nav-item" data-tab="tab-places">
                        <a href="#"><i class="fa-solid fa-map-location-dot"></i> Kelola SPBU</a>
                    </li>
                    <li class="nav-item" data-tab="tab-categories">
                        <a href="#"><i class="fa-solid fa-tags"></i> Kategori</a>
                    </li>
                    <li class="nav-item" data-tab="tab-facilities">
                        <a href="#"><i class="fa-solid fa-wifi"></i> Fasilitas</a>
                    </li>
                    <li class="nav-item" data-tab="tab-fuels">
                        <a href="#"><i class="fa-solid fa-droplet"></i> BBM & Harga</a>
                    </li>
                </ul>
            </nav>
            
            <div class="admin-profile">
                <div class="admin-avatar">
                    <i class="fa-solid fa-user-shield"></i>
                </div>
                <div class="admin-info">
                    <h4 id="admin-name">Admin User</h4>
                    <p>Administrator</p>
                </div>
                <a href="#" id="logout-btn" style="margin-left: auto; color: var(--text-soft);" title="Keluar">
                    <i class="fa-solid fa-power-off"></i>
                </a>
            </div>
        </aside>

        <!-- Main Content Area -->
        <main class="main-panel">
            
            <!-- TAB: SUMMARY DASHBOARD -->
            <section class="tab-panel active" id="tab-dashboard">
                <div class="panel-header">
                    <div class="panel-title">
                        <h1>Halo, Admin</h1>
                        <p>Berikut adalah ringkasan data stasiun pengisian bahan bakar umum (MySPBU).</p>
                    </div>
                </div>
                
                <div class="stat-grid">
                    <div class="stat-card glass-panel">
                        <div class="stat-info">
                            <p>Total SPBU</p>
                            <h3 id="stat-places">-</h3>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-map-location-dot"></i>
                        </div>
                    </div>
                    <div class="stat-card glass-panel">
                        <div class="stat-info">
                            <p>Tipe Bahan Bakar</p>
                            <h3 id="stat-fuels">-</h3>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-gas-station"></i>
                        </div>
                    </div>
                    <div class="stat-card glass-panel">
                        <div class="stat-info">
                            <p>Kategori SPBU</p>
                            <h3 id="stat-categories">-</h3>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-tags"></i>
                        </div>
                    </div>
                    <div class="stat-card glass-panel">
                        <div class="stat-info">
                            <p>Fasilitas</p>
                            <h3 id="stat-facilities">-</h3>
                        </div>
                        <div class="stat-icon">
                            <i class="fa-solid fa-wifi"></i>
                        </div>
                    </div>
                </div>

                <div class="glass-panel" style="padding: 24px;">
                    <h3 style="margin-bottom: 20px; font-size: 16px;">Statistik Pengguna & Ulasan</h3>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div style="background: rgba(15,23,42,0.3); padding: 20px; border-radius: 12px; display: flex; align-items: center; justify-content: space-between;">
                            <div>
                                <h4 style="font-size: 14px; color: var(--text-soft);">Jumlah Pengguna Terdaftar</h4>
                                <h2 id="stat-users" style="font-size: 28px; margin-top: 8px;">-</h2>
                            </div>
                            <i class="fa-solid fa-users" style="font-size: 28px; color: var(--brand-accent);"></i>
                        </div>
                        <div style="background: rgba(15,23,42,0.3); padding: 20px; border-radius: 12px; display: flex; align-items: center; justify-content: space-between;">
                            <div>
                                <h4 style="font-size: 14px; color: var(--text-soft);">Ulasan Ditulis</h4>
                                <h2 id="stat-reviews" style="font-size: 28px; margin-top: 8px;">-</h2>
                            </div>
                            <i class="fa-solid fa-star" style="font-size: 28px; color: var(--brand-warning);"></i>
                        </div>
                    </div>
                </div>
            </section>

            <!-- TAB: PLACES (SPBU) CRUD -->
            <section class="tab-panel" id="tab-places">
                <div class="panel-header">
                    <div class="panel-title">
                        <h1>Kelola Lokasi SPBU</h1>
                        <p>Tambah, edit, dan hapus lokasi SPBU beserta foto dan informasi detail.</p>
                    </div>
                    <button class="btn btn-primary" onclick="openPlaceModal()">
                        <i class="fa-solid fa-plus"></i> Tambah SPBU
                    </button>
                </div>
                
                <div class="search-bar-wrapper">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="places-search" class="form-control" placeholder="Cari berdasarkan nama/alamat..." oninput="filterPlacesTable()">
                </div>
                
                <div class="table-responsive">
                    <table class="custom-table" id="places-table">
                        <thead>
                            <tr>
                                <th style="width: 70px">Foto</th>
                                <th>Nama SPBU</th>
                                <th>Kategori</th>
                                <th>Alamat</th>
                                <th>Koordinat</th>
                                <th style="width: 140px; text-align: center;">Aksi</th>
                            </tr>
                        </thead>
                        <tbody id="places-table-body">
                            <!-- Dynamically loaded -->
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- TAB: CATEGORIES CRUD -->
            <section class="tab-panel" id="tab-categories">
                <div class="panel-header">
                    <div class="panel-title">
                        <h1>Kategori SPBU</h1>
                        <p>Mengatur daftar klasifikasi brand/kategori SPBU.</p>
                    </div>
                    <button class="btn btn-primary" onclick="openCategoryModal()">
                        <i class="fa-solid fa-plus"></i> Tambah Kategori
                    </button>
                </div>
                
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th style="width: 100px">ID</th>
                                <th>Nama Kategori</th>
                                <th style="width: 140px; text-align: center;">Aksi</th>
                            </tr>
                        </thead>
                        <tbody id="categories-table-body">
                            <!-- Dynamically loaded -->
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- TAB: FACILITIES CRUD -->
            <section class="tab-panel" id="tab-facilities">
                <div class="panel-header">
                    <div class="panel-title">
                        <h1>Kelola Fasilitas SPBU</h1>
                        <p>Mengatur daftar opsi fasilitas penunjang di area SPBU.</p>
                    </div>
                    <button class="btn btn-primary" onclick="openFacilityModal()">
                        <i class="fa-solid fa-plus"></i> Tambah Fasilitas
                    </button>
                </div>
                
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th style="width: 100px">ID</th>
                                <th>Nama Fasilitas</th>
                                <th style="width: 140px; text-align: center;">Aksi</th>
                            </tr>
                        </thead>
                        <tbody id="facilities-table-body">
                            <!-- Dynamically loaded -->
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- TAB: FUELS CRUD -->
            <section class="tab-panel" id="tab-fuels">
                <div class="panel-header">
                    <div class="panel-title">
                        <h1>Daftar BBM & Harga Nasional</h1>
                        <p>Mengatur nama-nama jenis bahan bakar beserta harga dasar nasional.</p>
                    </div>
                    <button class="btn btn-primary" onclick="openFuelModal()">
                        <i class="fa-solid fa-plus"></i> Tambah Jenis BBM
                    </button>
                </div>
                
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th style="width: 100px">ID</th>
                                <th>Nama Bahan Bakar</th>
                                <th>Harga Nasional (Rp)</th>
                                <th style="width: 140px; text-align: center;">Aksi</th>
                            </tr>
                        </thead>
                        <tbody id="fuels-table-body">
                            <!-- Dynamically loaded -->
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

    <!-- MODAL: SPBU CRUD -->
    <div class="modal-overlay" id="place-modal">
        <div class="modal-card glass-panel">
            <div class="modal-header">
                <h3 id="place-modal-title">Tambah SPBU Baru</h3>
                <button class="modal-close" onclick="closePlaceModal()">&times;</button>
            </div>
            <form id="place-form">
                <input type="hidden" id="place-id">
                <div class="modal-body">
                    <div class="modal-grid-2">
                        <!-- Kolom Kiri -->
                        <div>
                            <div class="form-group">
                                <label for="place-name">Nama SPBU</label>
                                <input type="text" id="place-name" class="form-control" placeholder="SPBU Pertamina 31..." required>
                            </div>
                            <div class="form-group">
                                <label for="place-category">Kategori SPBU</label>
                                <select id="place-category" class="form-control" required>
                                    <!-- Dynamic -->
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="place-address">Alamat Lengkap</label>
                                <textarea id="place-address" class="form-control" rows="3" placeholder="Jl. Raya Utama..." required></textarea>
                            </div>
                            <div class="modal-grid-2">
                                <div class="form-group">
                                    <label for="place-lat">Latitude</label>
                                    <input type="number" step="any" id="place-lat" class="form-control" required readonly>
                                </div>
                                <div class="form-group">
                                    <label for="place-lng">Longitude</label>
                                    <input type="number" step="any" id="place-lng" class="form-control" required readonly>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Kolom Kanan -->
                        <div>
                            <label style="display: block; font-size: 13px; font-weight: 500; color: var(--text-soft); margin-bottom: 8px;">Pilih Lokasi di Peta</label>
                            <div id="google-map"></div>
                            
                            <div class="form-group">
                                <label>Foto SPBU (Bisa Pilih Banyak)</label>
                                <div class="upload-area" onclick="document.getElementById('place-photos-input').click()">
                                    <i class="fa-solid fa-cloud-arrow-up"></i>
                                    <p>Klik di sini untuk mengunggah gambar</p>
                                    <input type="file" id="place-photos-input" multiple accept="image/*" style="display: none;" onchange="handlePhotoSelection(event)">
                                </div>
                                <div class="photo-previews" id="photo-previews-container"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Pilihan Fasilitas -->
                    <div class="form-group" style="margin-top: 10px;">
                        <label>Fasilitas yang Tersedia</label>
                        <div class="checkbox-grid" id="place-facilities-checkboxes">
                            <!-- Dynamic -->
                        </div>
                    </div>

                    <!-- Pilihan BBM -->
                    <div class="form-group" style="margin-top: 20px;">
                        <label>Bahan Bakar & Harga Khusus SPBU (Opsional)</label>
                        <p style="font-size: 11px; color: var(--text-soft); margin-bottom: 10px;">Ceklis BBM yang tersedia, kosongkan isian harga jika mengikuti harga dasar nasional.</p>
                        <div class="fuel-price-list" id="place-fuels-list">
                            <!-- Dynamic -->
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closePlaceModal()">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan SPBU</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL: KATEGORI CRUD -->
    <div class="modal-overlay" id="category-modal">
        <div class="modal-card glass-panel" style="max-width: 440px;">
            <div class="modal-header">
                <h3 id="category-modal-title">Kategori</h3>
                <button class="modal-close" onclick="closeCategoryModal()">&times;</button>
            </div>
            <form id="category-form">
                <input type="hidden" id="category-id">
                <div class="modal-body">
                    <div class="form-group">
                        <label for="category-name">Nama Kategori</label>
                        <input type="text" id="category-name" class="form-control" placeholder="Contoh: Pertamina" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeCategoryModal()">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL: FASILITAS CRUD -->
    <div class="modal-overlay" id="facility-modal">
        <div class="modal-card glass-panel" style="max-width: 440px;">
            <div class="modal-header">
                <h3 id="facility-modal-title">Fasilitas</h3>
                <button class="modal-close" onclick="closeFacilityModal()">&times;</button>
            </div>
            <form id="facility-form">
                <input type="hidden" id="facility-id">
                <div class="modal-body">
                    <div class="form-group">
                        <label for="facility-name">Nama Fasilitas</label>
                        <input type="text" id="facility-name" class="form-control" placeholder="Contoh: Toilet" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeFacilityModal()">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL: FUELS CRUD -->
    <div class="modal-overlay" id="fuel-modal">
        <div class="modal-card glass-panel" style="max-width: 440px;">
            <div class="modal-header">
                <h3 id="fuel-modal-title">Jenis BBM</h3>
                <button class="modal-close" onclick="closeFuelModal()">&times;</button>
            </div>
            <form id="fuel-form">
                <input type="hidden" id="fuel-id">
                <div class="modal-body">
                    <div class="form-group">
                        <label for="fuel-name">Nama Bahan Bakar</label>
                        <input type="text" id="fuel-name" class="form-control" placeholder="Contoh: Pertamax" required>
                    </div>
                    <div class="form-group">
                        <label for="fuel-price">Harga Nasional (Rp)</label>
                        <input type="number" id="fuel-price" class="form-control" placeholder="Contoh: 12500" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeFuelModal()">Batal</button>
                    <button type="submit" class="btn btn-primary">Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Application Script -->
    <script>
        // Core Config
        const API_URL = '/api';
        
        // Cache Option Lists
        let allCategories = [];
        let allFacilities = [];
        let allFuels = [];
        let allPlaces = [];

        // Dynamic State
        let selectedPhotosFiles = [];
        let existingPhotosUrls = [];
        
        // Google Map State
        let mapInstance = null;
        let mapMarker = null;

        // Initialize App
        document.addEventListener('DOMContentLoaded', () => {
            initAuth();
            setupTabs();
            setupEventListeners();
        });

        // ------------------------------------
        // TOASTS & NOTIFICATIONS
        // ------------------------------------
        function showToast(message, type = 'success') {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            toast.className = `toast toast-${type}`;
            
            const icon = type === 'success' ? 'fa-circle-check' : 'fa-circle-exclamation';
            toast.innerHTML = `
                <i class="fa-solid ${icon}"></i>
                <span>${message}</span>
            `;
            
            container.appendChild(toast);
            
            // Auto remove toast after 4s
            setTimeout(() => {
                toast.remove();
            }, 4000);
        }

        // ------------------------------------
        // AUTHENTICATION LOGIC
        // ------------------------------------
        function initAuth() {
            const token = localStorage.getItem('admin_token');
            const adminDataStr = localStorage.getItem('admin_data');
            
            if (token && adminDataStr) {
                const adminData = JSON.parse(adminDataStr);
                document.getElementById('admin-name').innerText = adminData.name;
                document.getElementById('login-wrapper').style.display = 'none';
                document.getElementById('dashboard-wrapper').style.display = 'flex';
                
                // Load active tab data
                loadTab('tab-dashboard');
            } else {
                document.getElementById('dashboard-wrapper').style.display = 'none';
                document.getElementById('login-wrapper').style.display = 'flex';
            }
        }

        function getAuthHeaders() {
            return {
                'Authorization': 'Bearer ' + localStorage.getItem('admin_token'),
                'Accept': 'application/json'
            };
        }

        async function handleLogin(e) {
            e.preventDefault();
            const email = document.getElementById('login-email').value;
            const password = document.getElementById('login-password').value;
            const errorEl = document.getElementById('login-error');
            
            errorEl.style.display = 'none';
            
            try {
                const response = await fetch(`${API_URL}/login`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email, password })
                });
                
                const data = await response.json();
                
                if (data.success) {
                    if (data.user && data.user.role === 'admin') {
                        localStorage.setItem('admin_token', data.token);
                        localStorage.setItem('admin_data', JSON.stringify(data.user));
                        showToast('Selamat datang, Admin!');
                        initAuth();
                    } else {
                        errorEl.innerText = 'Akses ditolak. Akun Anda bukan administrator.';
                        errorEl.style.display = 'block';
                    }
                } else {
                    errorEl.innerText = data.message || 'Email atau password salah.';
                    errorEl.style.display = 'block';
                }
            } catch (err) {
                errorEl.innerText = 'Terjadi kesalahan sistem. Silakan coba lagi.';
                errorEl.style.display = 'block';
            }
        }

        function handleLogout() {
            localStorage.removeItem('admin_token');
            localStorage.removeItem('admin_data');
            showToast('Anda berhasil keluar.');
            initAuth();
        }

        // ------------------------------------
        // TABS & NAVIGATION
        // ------------------------------------
        function setupTabs() {
            const navItems = document.querySelectorAll('.nav-item');
            navItems.forEach(item => {
                item.addEventListener('click', (e) => {
                    e.preventDefault();
                    
                    // Remove active classes
                    document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
                    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
                    
                    // Add active class
                    item.classList.add('active');
                    const tabId = item.getAttribute('data-tab');
                    document.getElementById(tabId).classList.add('active');
                    
                    loadTab(tabId);
                });
            });
        }

        function loadTab(tabId) {
            switch (tabId) {
                case 'tab-dashboard':
                    loadDashboardStats();
                    break;
                case 'tab-places':
                    loadPlaces();
                    break;
                case 'tab-categories':
                    loadCategories();
                    break;
                case 'tab-facilities':
                    loadFacilities();
                    break;
                case 'tab-fuels':
                    loadFuels();
                    break;
            }
        }

        // Setup DOM event listeners
        function setupEventListeners() {
            document.getElementById('login-form').addEventListener('submit', handleLogin);
            document.getElementById('logout-btn').addEventListener('click', handleLogout);
            document.getElementById('place-form').addEventListener('submit', savePlace);
            document.getElementById('category-form').addEventListener('submit', saveCategory);
            document.getElementById('facility-form').addEventListener('submit', saveFacility);
            document.getElementById('fuel-form').addEventListener('submit', saveFuel);
        }

        // ------------------------------------
        // DASHBOARD RINGKASAN
        // ------------------------------------
        async function loadDashboardStats() {
            try {
                const res = await fetch(`${API_URL}/admin/dashboard`, { headers: getAuthHeaders() });
                const json = await res.json();
                if (json.success) {
                    const d = json.data;
                    document.getElementById('stat-places').innerText = d.total_places;
                    document.getElementById('stat-users').innerText = d.total_users;
                    document.getElementById('stat-reviews').innerText = d.total_reviews;
                    document.getElementById('stat-fuels').innerText = d.total_fuels;
                    document.getElementById('stat-categories').innerText = d.total_categories;
                    document.getElementById('stat-facilities').innerText = d.total_facilities;
                }
            } catch (e) {
                showToast('Gagal memuat statistik dashboard', 'error');
            }
        }

        // ------------------------------------
        // CRUD SPBU (PLACES)
        // ------------------------------------
        async function loadPlaces() {
            try {
                const res = await fetch(`${API_URL}/admin/places`, { headers: getAuthHeaders() });
                const json = await res.json();
                if (json.success) {
                    allPlaces = json.data || [];
                    renderPlacesTable(allPlaces);
                }
            } catch (e) {
                showToast('Gagal memuat stasiun SPBU', 'error');
            }
        }

        function renderPlacesTable(places) {
            const body = document.getElementById('places-table-body');
            body.innerHTML = '';
            
            if (places.length === 0) {
                body.innerHTML = `<tr><td colspan="6" style="text-align: center; color: var(--text-soft)">Belum ada data SPBU</td></tr>`;
                return;
            }
            
            places.forEach(p => {
                // Get main photo URL
                const photoUrl = p.photo_url 
                    ? (p.photo_url.startsWith('http') ? p.photo_url : `/api${p.photo_url}`) 
                    : 'https://images.unsplash.com/photo-1527018601619-a508a2be00cd?w=100'; // Fallback sample
                
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td><img src="${photoUrl}" class="spbu-thumb" alt="${p.name}"></td>
                    <td style="font-weight: 600; color: white;">${p.name}</td>
                    <td><span class="badge badge-success">${p.category ? p.category.name : '-'}</span></td>
                    <td style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${p.address}</td>
                    <td style="font-size: 12px; color: var(--text-soft); font-family: monospace;">${parseFloat(p.latitude).toFixed(5)}, ${parseFloat(p.longitude).toFixed(5)}</td>
                    <td style="text-align: center;">
                        <button class="btn btn-secondary btn-sm" onclick="editPlace(${p.id})" title="Edit"><i class="fa-solid fa-edit"></i></button>
                        <button class="btn btn-danger btn-sm" onclick="deletePlace(${p.id}, '${p.name}')" title="Hapus"><i class="fa-solid fa-trash"></i></button>
                    </td>
                `;
                body.appendChild(tr);
            });
        }

        function filterPlacesTable() {
            const query = document.getElementById('places-search').value.toLowerCase();
            const filtered = allPlaces.filter(p => 
                p.name.toLowerCase().includes(query) || 
                p.address.toLowerCase().includes(query)
            );
            renderPlacesTable(filtered);
        }

        // Initialize Google Map
        function initGoogleMap(lat = -6.200000, lng = 106.816666, zoom = 14) {
            const myLatLng = { lat: lat, lng: lng };
            
            mapInstance = new google.maps.Map(document.getElementById("google-map"), {
                zoom: zoom,
                center: myLatLng,
                mapTypeControl: false,
                streetViewControl: false,
                fullscreenControl: false,
            });

            mapMarker = new google.maps.Marker({
                position: myLatLng,
                map: mapInstance,
                draggable: true,
            });

            mapMarker.addListener("dragend", () => {
                const pos = mapMarker.getPosition();
                document.getElementById('place-lat').value = pos.lat();
                document.getElementById('place-lng').value = pos.lng();
            });

            mapInstance.addListener("click", (e) => {
                const clickedLatLng = e.latLng;
                mapMarker.setPosition(clickedLatLng);
                document.getElementById('place-lat').value = clickedLatLng.lat();
                document.getElementById('place-lng').value = clickedLatLng.lng();
            });

            document.getElementById('place-lat').value = lat;
            document.getElementById('place-lng').value = lng;
        }

        // Populate place category select
        async function fetchPlaceFormOptions() {
            try {
                // Fetch combined form options in a single API call to minimize network latency
                const res = await fetch(`${API_URL}/admin/places/form-options`, { headers: getAuthHeaders() });
                const json = await res.json();
                
                if (json.success) {
                    allCategories = json.data.categories || [];
                    allFacilities = json.data.facilities || [];
                    allFuels = json.data.fuels || [];
                    
                    // Render Categories
                    const select = document.getElementById('place-category');
                    select.innerHTML = '<option value="">-- Pilih Kategori --</option>';
                    allCategories.forEach(c => {
                        select.innerHTML += `<option value="${c.id}">${c.name}</option>`;
                    });

                    // Render Facilities
                    const facContainer = document.getElementById('place-facilities-checkboxes');
                    facContainer.innerHTML = '';
                    allFacilities.forEach(f => {
                        facContainer.innerHTML += `
                            <label class="checkbox-item">
                                <input type="checkbox" name="facilities" value="${f.id}">
                                <span>${f.name}</span>
                            </label>
                        `;
                    });

                    // Render Fuels
                    const fuelContainer = document.getElementById('place-fuels-list');
                    fuelContainer.innerHTML = '';
                    allFuels.forEach(f => {
                        fuelContainer.innerHTML += `
                            <div class="fuel-price-row">
                                <input type="checkbox" name="fuels-enable" value="${f.id}" id="fuel-check-${f.id}" onchange="toggleFuelPriceInput(${f.id})">
                                <span style="color: white; margin-left: 8px;">${f.name}</span>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <label style="font-size: 11px; color: var(--text-soft)">Harga Khusus (Rp):</label>
                                    <input type="number" id="fuel-price-${f.id}" name="fuels-price" class="form-control" style="width: 140px; padding: 6px; font-size: 12px;" placeholder="${f.price}" disabled>
                                </div>
                            </div>
                        `;
                    });
                }
            } catch (e) {
                showToast('Gagal memuat data opsi formulir', 'error');
            }
        }

        function toggleFuelPriceInput(fuelId) {
            const checked = document.getElementById(`fuel-check-${fuelId}`).checked;
            const priceInput = document.getElementById(`fuel-price-${fuelId}`);
            priceInput.disabled = !checked;
            if (!checked) priceInput.value = '';
        }

        async function openPlaceModal() {
            document.getElementById('place-form').reset();
            document.getElementById('place-id').value = '';
            document.getElementById('place-modal-title').innerText = 'Tambah SPBU Baru';
            
            selectedPhotosFiles = [];
            existingPhotosUrls = [];
            renderPhotoPreviews();

            await fetchPlaceFormOptions();
            
            document.getElementById('place-modal').classList.add('active');

            // Coba dapatkan lokasi pengguna saat ini (sekitar kita)
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    (position) => {
                        const userLat = position.coords.latitude;
                        const userLng = position.coords.longitude;
                        initGoogleMap(userLat, userLng, 14);
                    },
                    () => {
                        // Fallback ke Jakarta jika gagal/akses ditolak
                        initGoogleMap(-6.200000, 106.816666, 11);
                    }
                );
            } else {
                initGoogleMap(-6.200000, 106.816666, 11);
            }
        }

        function closePlaceModal() {
            document.getElementById('place-modal').classList.remove('active');
        }

        // Photo file selection and previews
        function handlePhotoSelection(event) {
            const files = Array.from(event.target.files);
            selectedPhotosFiles.push(...files);
            renderPhotoPreviews();
            
            // Reset input
            event.target.value = '';
        }

        function removeSelectedPhoto(index) {
            selectedPhotosFiles.splice(index, 1);
            renderPhotoPreviews();
        }

        function removeExistingPhoto(index) {
            existingPhotosUrls.splice(index, 1);
            renderPhotoPreviews();
        }

        function renderPhotoPreviews() {
            const container = document.getElementById('photo-previews-container');
            container.innerHTML = '';

            // Render existing photos (from server)
            existingPhotosUrls.forEach((url, i) => {
                const fullUrl = url.startsWith('http') ? url : `/api${url}`;
                const div = document.createElement('div');
                div.className = 'photo-preview-item';
                div.innerHTML = `
                    <img src="${fullUrl}" alt="Existing">
                    <button type="button" class="remove-btn" onclick="removeExistingPhoto(${i})">&times;</button>
                `;
                container.appendChild(div);
            });

            // Render newly picked files
            selectedPhotosFiles.forEach((file, i) => {
                const reader = new FileReader();
                const div = document.createElement('div');
                div.className = 'photo-preview-item';
                
                reader.onload = function(e) {
                    div.innerHTML = `
                        <img src="${e.target.result}" alt="New">
                        <button type="button" class="remove-btn" onclick="removeSelectedPhoto(${i})">&times;</button>
                    `;
                };
                reader.readAsDataURL(file);
                container.appendChild(div);
            });
        }

        // Edit SPBU Hydrate Form
        async function editPlace(id) {
            try {
                // Populate options
                await fetchPlaceFormOptions();
                
                const res = await fetch(`${API_URL}/admin/places`, { headers: getAuthHeaders() });
                const json = await res.json();
                const places = json.data || [];
                const p = places.find(item => item.id === id);
                
                if (!p) {
                    showToast('Data SPBU tidak ditemukan', 'error');
                    return;
                }

                // Hydrate details
                document.getElementById('place-id').value = p.id;
                document.getElementById('place-name').value = p.name;
                document.getElementById('place-category').value = p.category_id;
                document.getElementById('place-address').value = p.address;
                document.getElementById('place-lat').value = p.latitude;
                document.getElementById('place-lng').value = p.longitude;
                document.getElementById('place-modal-title').innerText = 'Edit SPBU';

                // Map initialization to place coordinates
                initGoogleMap(parseFloat(p.latitude), parseFloat(p.longitude), 14);

                // Populate existing photos
                selectedPhotosFiles = [];
                existingPhotosUrls = [];
                if (p.images && p.images.length > 0) {
                    existingPhotosUrls = p.images.map(img => img.photo_url);
                } else if (p.photo_url) {
                    existingPhotosUrls = [p.photo_url];
                }
                renderPhotoPreviews();

                // Check active facilities
                if (p.facilities) {
                    const checks = document.getElementsByName('facilities');
                    p.facilities.forEach(fac => {
                        for (let c of checks) {
                            if (parseInt(c.value) === fac.id) {
                                c.checked = true;
                            }
                        }
                    });
                }

                // Check active fuels and custom prices
                if (p.fuels) {
                    p.fuels.forEach(fuel => {
                        const check = document.getElementById(`fuel-check-${fuel.id}`);
                        if (check) {
                            check.checked = true;
                            const priceInput = document.getElementById(`fuel-price-${fuel.id}`);
                            priceInput.disabled = false;
                            
                            // Check if place has pivot price
                            if (fuel.pivot && fuel.pivot.price !== null) {
                                priceInput.value = fuel.pivot.price;
                            }
                        }
                    });
                }

                document.getElementById('place-modal').classList.add('active');
            } catch (e) {
                showToast('Gagal memuat detail SPBU', 'error');
            }
        }

        // Save (Create / Update) Place
        async function savePlace(e) {
            e.preventDefault();
            const id = document.getElementById('place-id').value;
            
            // Construct multipart form data
            const formData = new FormData();
            formData.append('name', document.getElementById('place-name').value);
            formData.append('category_id', document.getElementById('place-category').value);
            formData.append('address', document.getElementById('place-address').value);
            formData.append('latitude', document.getElementById('place-lat').value);
            formData.append('longitude', document.getElementById('place-lng').value);
            
            // Sync lists indicators
            formData.append('sync_facilities', '1');
            formData.append('sync_fuels', '1');

            // Attach facilities
            const facilityChecks = document.getElementsByName('facilities');
            let facIndex = 0;
            facilityChecks.forEach(c => {
                if (c.checked) {
                    formData.append(`facilities[${facIndex}]`, c.value);
                    facIndex++;
                }
            });

            // Attach fuels
            const fuelChecks = document.getElementsByName('fuels-enable');
            let fuelIndex = 0;
            fuelChecks.forEach(c => {
                if (c.checked) {
                    const fuelId = c.value;
                    const price = document.getElementById(`fuel-price-${fuelId}`).value;
                    
                    formData.append(`fuels[${fuelIndex}][fuel_id]`, fuelId);
                    if (price !== '') {
                        formData.append(`fuels[${fuelIndex}][price]`, price);
                    }
                    formData.append(`fuels[${fuelIndex}][is_available]`, '1');
                    fuelIndex++;
                }
            });

            // Append photos
            selectedPhotosFiles.forEach(file => {
                formData.append('photos[]', file);
            });

            // Send existing photos that were kept (so we can pass to update logic)
            // Wait, does updatePlace delete all and insert new photos? Yes, in Laravel:
            // "If new photos are uploaded, delete existing disk files and database records for that SPBU..."
            // If the user kept existing photos but didn't upload new ones, we want to retain them.
            // If the user modified the photo lists (removed some or added some), we send it.
            // Let's pass the list of existing photo URLs that are remaining:
            existingPhotosUrls.forEach(url => {
                formData.append('existing_photos[]', url);
            });

            const url = id !== '' ? `${API_URL}/admin/places/${id}` : `${API_URL}/admin/places`;
            
            try {
                const response = await fetch(url, {
                    method: 'POST', // POST for both because multipart uploads require POST
                    headers: {
                        'Authorization': 'Bearer ' + localStorage.getItem('admin_token'),
                        'Accept': 'application/json'
                    },
                    body: formData
                });
                
                const json = await response.json();
                if (json.success) {
                    showToast(id !== '' ? 'SPBU berhasil diperbarui' : 'SPBU baru berhasil disimpan');
                    closePlaceModal();
                    loadPlaces();
                } else {
                    showToast(json.message || 'Gagal menyimpan SPBU', 'error');
                }
            } catch (err) {
                showToast('Kesalahan koneksi ke server', 'error');
            }
        }

        // Delete SPBU
        async function deletePlace(id, name) {
            if (!confirm(`Apakah Anda yakin ingin menghapus SPBU "${name}"? Tindakan ini tidak dapat dibatalkan.`)) {
                return;
            }

            try {
                const res = await fetch(`${API_URL}/admin/places/${id}`, {
                    method: 'DELETE',
                    headers: getAuthHeaders()
                });
                const json = await res.json();
                if (json.success) {
                    showToast('SPBU berhasil dihapus');
                    loadPlaces();
                } else {
                    showToast(json.message || 'Gagal menghapus SPBU', 'error');
                }
            } catch (e) {
                showToast('Kesalahan koneksi ke server', 'error');
            }
        }

        // ------------------------------------
        // CRUD CATEGORIES
        // ------------------------------------
        async function loadCategories() {
            try {
                const res = await fetch(`${API_URL}/admin/categories`, { headers: getAuthHeaders() });
                const json = await res.json();
                if (json.success) {
                    allCategories = json.data || [];
                    renderCategoriesTable(allCategories);
                }
            } catch (e) {
                showToast('Gagal memuat kategori', 'error');
            }
        }

        function renderCategoriesTable(list) {
            const body = document.getElementById('categories-table-body');
            body.innerHTML = '';
            
            if (list.length === 0) {
                body.innerHTML = `<tr><td colspan="3" style="text-align: center; color: var(--text-soft)">Belum ada data Kategori</td></tr>`;
                return;
            }

            list.forEach(c => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td style="font-family: monospace; color: var(--text-soft);">${c.id}</td>
                    <td style="font-weight: 600; color: white;">${c.name}</td>
                    <td style="text-align: center;">
                        <button class="btn btn-secondary btn-sm" onclick="editCategory(${c.id}, '${c.name}')" title="Edit"><i class="fa-solid fa-edit"></i></button>
                        <button class="btn btn-danger btn-sm" onclick="deleteCategory(${c.id}, '${c.name}')" title="Hapus"><i class="fa-solid fa-trash"></i></button>
                    </td>
                `;
                body.appendChild(tr);
            });
        }

        // Add Categories Dialogs
        function openCategoryModal() {
            document.getElementById('category-form').reset();
            document.getElementById('category-id').value = '';
            document.getElementById('category-modal-title').innerText = 'Tambah Kategori';
            document.getElementById('category-modal').classList.add('active');
        }

        function closeCategoryModal() {
            document.getElementById('category-modal').classList.remove('active');
        }

        function editCategory(id, name) {
            document.getElementById('category-id').value = id;
            document.getElementById('category-name').value = name;
            document.getElementById('category-modal-title').innerText = 'Edit Kategori';
            document.getElementById('category-modal').classList.add('active');
        }

        async function saveCategory(e) {
            e.preventDefault();
            const id = document.getElementById('category-id').value;
            const name = document.getElementById('category-name').value;

            const url = id !== '' ? `${API_URL}/admin/categories/${id}` : `${API_URL}/admin/categories`;
            const method = id !== '' ? 'PUT' : 'POST';

            try {
                const response = await fetch(url, {
                    method: method,
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ' + localStorage.getItem('admin_token')
                    },
                    body: JSON.stringify({ name })
                });
                
                const json = await response.json();
                if (json.success) {
                    showToast('Kategori berhasil disimpan');
                    closeCategoryModal();
                    loadCategories();
                } else {
                    showToast(json.message || 'Gagal menyimpan kategori', 'error');
                }
            } catch (err) {
                showToast('Kesalahan koneksi ke server', 'error');
            }
        }

        async function deleteCategory(id, name) {
            if (!confirm(`Apakah Anda yakin ingin menghapus kategori "${name}"?`)) return;
            try {
                const res = await fetch(`${API_URL}/admin/categories/${id}`, {
                    method: 'DELETE',
                    headers: getAuthHeaders()
                });
                const json = await res.json();
                if (json.success) {
                    showToast('Kategori berhasil dihapus');
                    loadCategories();
                } else {
                    showToast(json.message || 'Gagal menghapus kategori', 'error');
                }
            } catch (e) {
                showToast('Kesalahan koneksi ke server', 'error');
            }
        }

        // ------------------------------------
        // CRUD FACILITIES
        // ------------------------------------
        async function loadFacilities() {
            try {
                const res = await fetch(`${API_URL}/admin/facilities`, { headers: getAuthHeaders() });
                const json = await res.json();
                if (json.success) {
                    allFacilities = json.data || [];
                    renderFacilitiesTable(allFacilities);
                }
            } catch (e) {
                showToast('Gagal memuat fasilitas', 'error');
            }
        }

        function renderFacilitiesTable(list) {
            const body = document.getElementById('facilities-table-body');
            body.innerHTML = '';
            
            if (list.length === 0) {
                body.innerHTML = `<tr><td colspan="3" style="text-align: center; color: var(--text-soft)">Belum ada data Fasilitas</td></tr>`;
                return;
            }

            list.forEach(f => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td style="font-family: monospace; color: var(--text-soft);">${f.id}</td>
                    <td style="font-weight: 600; color: white;">${f.name}</td>
                    <td style="text-align: center;">
                        <button class="btn btn-secondary btn-sm" onclick="editFacility(${f.id}, '${f.name}')" title="Edit"><i class="fa-solid fa-edit"></i></button>
                        <button class="btn btn-danger btn-sm" onclick="deleteFacility(${f.id}, '${f.name}')" title="Hapus"><i class="fa-solid fa-trash"></i></button>
                    </td>
                `;
                body.appendChild(tr);
            });
        }

        function openFacilityModal() {
            document.getElementById('facility-form').reset();
            document.getElementById('facility-id').value = '';
            document.getElementById('facility-modal-title').innerText = 'Tambah Fasilitas';
            document.getElementById('facility-modal').classList.add('active');
        }

        function closeFacilityModal() {
            document.getElementById('facility-modal').classList.remove('active');
        }

        // Edit Fasilitas
        function editFacility(id, name) {
            document.getElementById('facility-id').value = id;
            document.getElementById('facility-name').value = name;
            document.getElementById('facility-modal-title').innerText = 'Edit Fasilitas';
            document.getElementById('facility-modal').classList.add('active');
        }

        async function saveFacility(e) {
            e.preventDefault();
            const id = document.getElementById('facility-id').value;
            const name = document.getElementById('facility-name').value;

            const url = id !== '' ? `${API_URL}/admin/facilities/${id}` : `${API_URL}/admin/facilities`;
            const method = id !== '' ? 'PUT' : 'POST';

            try {
                const response = await fetch(url, {
                    method: method,
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ' + localStorage.getItem('admin_token')
                    },
                    body: JSON.stringify({ name })
                });
                
                const json = await response.json();
                if (json.success) {
                    showToast('Fasilitas berhasil disimpan');
                    closeFacilityModal();
                    loadFacilities();
                } else {
                    showToast(json.message || 'Gagal menyimpan fasilitas', 'error');
                }
            } catch (err) {
                showToast('Kesalahan koneksi ke server', 'error');
            }
        }

        async function deleteFacility(id, name) {
            if (!confirm(`Apakah Anda yakin ingin menghapus fasilitas "${name}"?`)) return;
            try {
                const res = await fetch(`${API_URL}/admin/facilities/${id}`, {
                    method: 'DELETE',
                    headers: getAuthHeaders()
                });
                const json = await res.json();
                if (json.success) {
                    showToast('Fasilitas berhasil dihapus');
                    loadFacilities();
                } else {
                    showToast(json.message || 'Gagal menghapus fasilitas', 'error');
                }
            } catch (e) {
                showToast('Kesalahan koneksi ke server', 'error');
            }
        }

        // ------------------------------------
        // CRUD BBM (FUELS)
        // ------------------------------------
        async function loadFuels() {
            try {
                const res = await fetch(`${API_URL}/admin/fuels`, { headers: getAuthHeaders() });
                const json = await res.json();
                if (json.success) {
                    allFuels = json.data || [];
                    renderFuelsTable(allFuels);
                }
            } catch (e) {
                showToast('Gagal memuat jenis BBM', 'error');
            }
        }

        function renderFuelsTable(list) {
            const body = document.getElementById('fuels-table-body');
            body.innerHTML = '';
            
            if (list.length === 0) {
                body.innerHTML = `<tr><td colspan="4" style="text-align: center; color: var(--text-soft)">Belum ada data BBM</td></tr>`;
                return;
            }

            list.forEach(f => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td style="font-family: monospace; color: var(--text-soft);">${f.id}</td>
                    <td style="font-weight: 600; color: white;">${f.name}</td>
                    <td style="font-weight: 500; font-family: monospace; color: var(--brand-success);">Rp ${parseFloat(f.national_price).toLocaleString('id-ID')}</td>
                    <td style="text-align: center;">
                        <button class="btn btn-secondary btn-sm" onclick="editFuel(${f.id}, '${f.name}', ${f.national_price})" title="Edit"><i class="fa-solid fa-edit"></i></button>
                        <button class="btn btn-danger btn-sm" onclick="deleteFuel(${f.id}, '${f.name}')" title="Hapus"><i class="fa-solid fa-trash"></i></button>
                    </td>
                `;
                body.appendChild(tr);
            });
        }

        function openFuelModal() {
            document.getElementById('fuel-form').reset();
            document.getElementById('fuel-id').value = '';
            document.getElementById('fuel-modal-title').innerText = 'Tambah Jenis BBM';
            document.getElementById('fuel-modal').classList.add('active');
        }

        function closeFuelModal() {
            document.getElementById('fuel-modal').classList.remove('active');
        }

        function editFuel(id, name, nationalPrice) {
            document.getElementById('fuel-id').value = id;
            document.getElementById('fuel-name').value = name;
            document.getElementById('fuel-price').value = nationalPrice;
            document.getElementById('fuel-modal-title').innerText = 'Edit Jenis BBM';
            document.getElementById('fuel-modal').classList.add('active');
        }

        async function saveFuel(e) {
            e.preventDefault();
            const id = document.getElementById('fuel-id').value;
            const name = document.getElementById('fuel-name').value;
            const price = document.getElementById('fuel-price').value;

            const url = id !== '' ? `${API_URL}/admin/fuels/${id}` : `${API_URL}/admin/fuels`;
            const method = id !== '' ? 'PUT' : 'POST';

            try {
                const response = await fetch(url, {
                    method: method,
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ' + localStorage.getItem('admin_token')
                    },
                    body: JSON.stringify({ name, national_price: price })
                });
                
                const json = await response.json();
                if (json.success) {
                    showToast('Jenis BBM berhasil disimpan');
                    closeFuelModal();
                    loadFuels();
                } else {
                    showToast(json.message || 'Gagal menyimpan jenis BBM', 'error');
                }
            } catch (err) {
                showToast('Kesalahan koneksi ke server', 'error');
            }
        }

        async function deleteFuel(id, name) {
            if (!confirm(`Apakah Anda yakin ingin menghapus BBM "${name}"?`)) return;
            try {
                const res = await fetch(`${API_URL}/admin/fuels/${id}`, {
                    method: 'DELETE',
                    headers: getAuthHeaders()
                });
                const json = await res.json();
                if (json.success) {
                    showToast('BBM berhasil dihapus');
                    loadFuels();
                } else {
                    showToast(json.message || 'Gagal menghapus BBM', 'error');
                }
            } catch (e) {
                showToast('Kesalahan koneksi ke server', 'error');
            }
        }
    </script>
</body>
</html>
