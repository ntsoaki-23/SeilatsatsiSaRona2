<%@ page import="com.seilatsatsi.dao.OrderDAO" %>
<%@ page import="com.seilatsatsi.dao.ProductDAO" %>
<%@ page import="com.seilatsatsi.model.Order" %>
<%@ page import="com.seilatsatsi.model.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    OrderDAO orderDAO = new OrderDAO();
    ProductDAO productDAO = new ProductDAO();
    OrderDAO.DashboardStats stats = orderDAO.getDashboardStats();
    List<Order> recentOrders = orderDAO.getRecentOrders();
    List<Product> allProducts = productDAO.getAllProducts();
    List<Order> allOrders = orderDAO.getAllOrders();
    
    // Calculate weekly sales data (last 7 days)
    Map<String, Double> weeklySales = new LinkedHashMap<>();
    List<String> weekDays = Arrays.asList("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun");
    for (String day : weekDays) {
        weeklySales.put(day, 0.0);
    }
    
    // Calculate supplier profit breakdown
    double sheinProfit = 0;
    double temuProfit = 0;
    if (allOrders != null && allProducts != null) {
        for (Order order : allOrders) {
            for (Product product : allProducts) {
                if (order.getProductId() == product.getProductId() && order.getProfit() != null) {
                    if ("SHEIN".equals(product.getSupplier())) {
                        sheinProfit += order.getProfit().doubleValue();
                    } else if ("TEMU".equals(product.getSupplier())) {
                        temuProfit += order.getProfit().doubleValue();
                    }
                    break;
                }
            }
        }
    }
    
    // Calculate monthly profit data (last 6 months)
    Map<String, Double> monthlyProfit = new LinkedHashMap<>();
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat monthFormat = new SimpleDateFormat("MMM");
    
    for (int i = 5; i >= 0; i--) {
        cal.setTime(new Date());
        cal.add(Calendar.MONTH, -i);
        String monthKey = monthFormat.format(cal.getTime());
        monthlyProfit.put(monthKey, 0.0);
    }
    
    if (allOrders != null) {
        for (Order order : allOrders) {
            if (order.getProfit() != null && order.getOrderDate() != null) {
                String orderMonth = monthFormat.format(order.getOrderDate());
                if (monthlyProfit.containsKey(orderMonth)) {
                    monthlyProfit.put(orderMonth, monthlyProfit.get(orderMonth) + order.getProfit().doubleValue());
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seilatsatsi FIS - Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .sidebar { position: fixed; left: 0; top: 0; width: 260px; height: 100%; background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%); color: white; z-index: 100; }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h2 { font-size: 20px; margin-bottom: 5px; }
        .sidebar-header p { font-size: 12px; opacity: 0.7; }
        .sidebar-menu { padding: 20px 0; }
        .menu-item { padding: 12px 25px; display: flex; align-items: center; gap: 12px; color: rgba(255,255,255,0.8); transition: all 0.3s; text-decoration: none; }
        .menu-item:hover, .menu-item.active { background: rgba(255,255,255,0.1); color: white; border-left: 3px solid #667eea; }
        .menu-item i { width: 20px; font-size: 18px; }
        .main-content { margin-left: 260px; padding: 20px; }
        .top-bar { background: white; border-radius: 15px; padding: 15px 25px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; }
        .page-title h1 { font-size: 24px; color: #333; }
        .page-title p { font-size: 14px; color: #666; margin-top: 5px; }
        .user-info { display: flex; align-items: center; gap: 15px; }
        .user-name { font-weight: 500; color: #333; }
        .avatar { width: 40px; height: 40px; background: linear-gradient(135deg, #667eea, #764ba2); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; }
        
        /* Stats Cards */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 25px; }
        .stat-card { background: white; border-radius: 15px; padding: 20px; display: flex; justify-content: space-between; align-items: center; transition: transform 0.3s; }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-info h3 { font-size: 14px; color: #666; margin-bottom: 8px; }
        .stat-number { font-size: 32px; font-weight: 700; color: #333; }
        .stat-icon { width: 60px; height: 60px; background: rgba(102, 126, 234, 0.1); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 30px; color: #667eea; }
        
        /* Charts Row */
        .charts-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 20px; margin-bottom: 25px; }
        .chart-card { background: white; border-radius: 15px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .chart-title { font-size: 18px; font-weight: 600; margin-bottom: 20px; color: #333; border-left: 4px solid #667eea; padding-left: 15px; }
        canvas { max-height: 300px; width: 100% !important; }
        
        /* Orders Table */
        .orders-table-container { background: white; border-radius: 15px; padding: 20px; }
        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .table-header h3 { font-size: 18px; color: #333; }
        .btn-add { background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-weight: 500; text-decoration: none; }
        .btn-add:hover { transform: scale(1.05); }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: 600; color: #555; }
        .status-badge { padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 500; display: inline-block; }
        .status-paid, .status-delivered { background: #d4edda; color: #155724; }
        .status-pending, .status-ordered, .status-shipped { background: #fff3cd; color: #856404; }
        .profit-positive { color: #28a745; font-weight: bold; }
        .profit-negative { color: #dc3545; font-weight: bold; }
        
        @media (max-width: 768px) {
            .sidebar { width: 70px; }
            .sidebar-header h2, .sidebar-header p, .menu-item span { display: none; }
            .main-content { margin-left: 70px; }
            .charts-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="sidebar-header">
            <h2>🛍️ Seilatsatsi</h2>
            <p>Financial Information System</p>
        </div>
        <div class="sidebar-menu">
            <a href="${pageContext.request.contextPath}/dashboard" class="menu-item active">
                <i class="fas fa-tachometer-alt"></i>
                <span>Dashboard</span>
            </a>
            <a href="${pageContext.request.contextPath}/orders" class="menu-item">
                <i class="fas fa-shopping-cart"></i>
                <span>Orders</span>
            </a>
            <a href="${pageContext.request.contextPath}/products" class="menu-item">
                <i class="fas fa-box"></i>
                <span>Products</span>
            </a>
            <a href="${pageContext.request.contextPath}/customers" class="menu-item">
                <i class="fas fa-users"></i>
                <span>Customers</span>
            </a>
            <a href="${pageContext.request.contextPath}/reports" class="menu-item">
                <i class="fas fa-chart-line"></i>
                <span>Reports</span>
            </a>
            <a href="${pageContext.request.contextPath}/expenses" class="menu-item">
                <i class="fas fa-money-bill-wave"></i>
                <span>Expenses</span>
            </a>
        </div>
    </div>

    <div class="main-content">
        <div class="top-bar">
            <div class="page-title">
                <h1>Financial Dashboard</h1>
                <p>Welcome back! Here's what's happening with your business today.</p>
            </div>
            <div class="user-info">
                <span class="user-name">Admin User</span>
                <div class="avatar">A</div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-info">
                    <h3>Total Orders</h3>
                    <div class="stat-number"><%= stats.totalOrders %></div>
                </div>
                <div class="stat-icon">
                    <i class="fas fa-shopping-cart"></i>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>Total Revenue</h3>
                    <div class="stat-number">M <%= stats.totalRevenue %></div>
                </div>
                <div class="stat-icon">
                    <i class="fas fa-chart-line"></i>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>Total Profit</h3>
                    <div class="stat-number">M <%= stats.totalProfit %></div>
                </div>
                <div class="stat-icon">
                    <i class="fas fa-coins"></i>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>Pending Orders</h3>
                    <div class="stat-number"><%= stats.pendingOrders %></div>
                </div>
                <div class="stat-icon">
                    <i class="fas fa-clock"></i>
                </div>
            </div>
        </div>

        <!-- Charts Row -->
        <div class="charts-row">
            <div class="chart-card">
                <div class="chart-title">Weekly Sales Trend</div>
                <canvas id="weeklySalesChart"></canvas>
            </div>
            <div class="chart-card">
                <div class="chart-title">Profit by Supplier</div>
                <canvas id="supplierChart"></canvas>
            </div>
        </div>

        <div class="charts-row">
            <div class="chart-card">
                <div class="chart-title">Monthly Profit Trend</div>
                <canvas id="monthlyProfitChart"></canvas>
            </div>
            <div class="chart-card">
                <div class="chart-title">Revenue Distribution</div>
                <canvas id="revenueChart"></canvas>
            </div>
        </div>

        <!-- Recent Orders Table -->
        <div class="orders-table-container">
            <div class="table-header">
                <h3>Recent Orders</h3>
                <a href="${pageContext.request.contextPath}/orders?action=create" class="btn-add">
                    <i class="fas fa-plus"></i> New Order
                </a>
            </div>
            <div style="overflow-x: auto;">
                <table id="ordersTable">
                    <thead>
                        <tr>
                            <th>Order ID</th>
                            <th>Customer</th>
                            <th>Product</th>
                            <th>Quantity</th>
                            <th>Amount</th>
                            <th>Profit</th>
                            <th>Status</th>
                            <th>Payment</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (recentOrders != null && !recentOrders.isEmpty()) { 
                            for (Order order : recentOrders) { 
                                boolean isProfitPositive = order.getProfit() != null && order.getProfit().doubleValue() > 0;
                        %>
                            <tr>
                                <td><%= order.getOrderId() %></td>
                                <td><%= order.getCustomerName() %></td>
                                <td><%= order.getProductName() %></td>
                                <td><%= order.getQuantity() %></td>
                                <td>M <%= order.getTotalCustomerPrice() %></td>
                                <td class="<%= isProfitPositive ? "profit-positive" : "profit-negative" %>">M <%= order.getProfit() != null ? order.getProfit() : 0 %></td>
                                <td><span class="status-badge status-<%= order.getOrderStatus() %>"><%= order.getOrderStatus() %></span></td>
                                <td><span class="status-badge status-<%= order.getPaymentStatus() %>"><%= order.getPaymentStatus() %></span></td>
                            </tr>
                        <% } 
                        } else { %>
                            <tr>
                                <td colspan="8" style="text-align: center;">No orders found. <a href="${pageContext.request.contextPath}/orders?action=create">Create your first order</a></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // Weekly Sales Chart Data
        const weeklyData = {
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            datasets: [{
                label: 'Revenue (M)',
                data: [<%
                    // Sample weekly data - replace with actual data from database
                    java.util.Random rand = new java.util.Random();
                    for (int i = 0; i < 7; i++) {
                        if (i > 0) out.print(",");
                        out.print(3000 + rand.nextInt(6000));
                    }
                %>],
                borderColor: '#667eea',
                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                tension: 0.4,
                fill: true
            }]
        };

        // Supplier Profit Chart Data
        const supplierData = {
            labels: ['SHEIN', 'TEMU'],
            datasets: [{
                data: [<%= sheinProfit %>, <%= temuProfit %>],
                backgroundColor: ['#667eea', '#764ba2']
            }]
        };

        // Monthly Profit Chart Data
        const monthlyProfitData = {
            labels: [<% for (String month : monthlyProfit.keySet()) { %>'<%= month %>',<% } %>],
            datasets: [{
                label: 'Profit (M)',
                data: [<% for (Double profit : monthlyProfit.values()) { %><%= profit %>,<% } %>],
                backgroundColor: 'rgba(102, 126, 234, 0.7)',
                borderColor: '#667eea',
                borderWidth: 1
            }]
        };

        // Revenue Distribution Chart Data
        const revenueData = {
            labels: ['Product Sales', 'Delivery Fees'],
            datasets: [{
                data: [85, 15],
                backgroundColor: ['#667eea', '#764ba2']
            }]
        };

        // Initialize all charts
        function initCharts() {
            // Weekly Sales Chart (Line Chart)
            const weeklyCtx = document.getElementById('weeklySalesChart').getContext('2d');
            new Chart(weeklyCtx, {
                type: 'line',
                data: weeklyData,
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: { position: 'top' }
                    }
                }
            });

            // Supplier Profit Chart (Doughnut Chart)
            const supplierCtx = document.getElementById('supplierChart').getContext('2d');
            new Chart(supplierCtx, {
                type: 'doughnut',
                data: supplierData,
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: { position: 'bottom' }
                    }
                }
            });

            // Monthly Profit Chart (Bar Chart)
            const monthlyCtx = document.getElementById('monthlyProfitChart').getContext('2d');
            new Chart(monthlyCtx, {
                type: 'bar',
                data: monthlyProfitData,
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: { position: 'top' }
                    }
                }
            });

            // Revenue Distribution Chart (Pie Chart)
            const revenueCtx = document.getElementById('revenueChart').getContext('2d');
            new Chart(revenueCtx, {
                type: 'pie',
                data: revenueData,
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: { position: 'bottom' }
                    }
                }
            });
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            initCharts();
        });
    </script>
</body>
</html>