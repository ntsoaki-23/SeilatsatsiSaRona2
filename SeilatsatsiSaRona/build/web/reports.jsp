<%@ page import="com.seilatsatsi.dao.OrderDAO" %>
<%@ page import="com.seilatsatsi.dao.ProductDAO" %>
<%@ page import="com.seilatsatsi.dao.ExpenseDAO" %>
<%@ page import="com.seilatsatsi.model.Order" %>
<%@ page import="com.seilatsatsi.model.Product" %>
<%@ page import="com.seilatsatsi.model.Expense" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Initialize DAOs
    OrderDAO orderDAO = new OrderDAO();
    ProductDAO productDAO = new ProductDAO();
    ExpenseDAO expenseDAO = new ExpenseDAO();
    
    // Get data
    List<Order> allOrders = orderDAO.getAllOrders();
    List<Product> allProducts = productDAO.getAllProducts();
    List<Expense> allExpenses = expenseDAO.getAllExpenses();
    OrderDAO.DashboardStats stats = orderDAO.getDashboardStats();
    
    // Calculate monthly profit data (last 6 months)
    Map<String, Double> monthlyProfit = new LinkedHashMap<>();
    Map<String, Integer> monthlyOrders = new LinkedHashMap<>();
    
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat monthFormat = new SimpleDateFormat("MMM yyyy");
    
    for (int i = 5; i >= 0; i--) {
        cal.setTime(new Date());
        cal.add(Calendar.MONTH, -i);
        String monthKey = monthFormat.format(cal.getTime());
        monthlyProfit.put(monthKey, 0.0);
        monthlyOrders.put(monthKey, 0);
    }
    
    double totalProfit = 0;
    if (allOrders != null) {
        for (Order order : allOrders) {
            if (order.getProfit() != null) {
                totalProfit += order.getProfit().doubleValue();
                
                // Add to monthly profit
                if (order.getOrderDate() != null) {
                    String orderMonth = monthFormat.format(order.getOrderDate());
                    if (monthlyProfit.containsKey(orderMonth)) {
                        monthlyProfit.put(orderMonth, monthlyProfit.get(orderMonth) + order.getProfit().doubleValue());
                        monthlyOrders.put(orderMonth, monthlyOrders.get(orderMonth) + 1);
                    }
                }
            }
        }
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
    
    // Calculate total expenses
    double totalExpenses = 0;
    Map<String, Double> expensesByCategory = new HashMap<>();
    if (allExpenses != null) {
        for (Expense expense : allExpenses) {
            if (expense.getAmount() != null) {
                totalExpenses += expense.getAmount().doubleValue();
                String category = expense.getCategory();
                expensesByCategory.put(category, expensesByCategory.getOrDefault(category, 0.0) + expense.getAmount().doubleValue());
            }
        }
    }
    
    double netProfit = stats.totalProfit != null ? stats.totalProfit.doubleValue() - totalExpenses : -totalExpenses;
    
    // Get top selling products
    Map<String, Integer> productSales = new HashMap<>();
    if (allOrders != null) {
        for (Order order : allOrders) {
            String productName = order.getProductName();
            productSales.put(productName, productSales.getOrDefault(productName, 0) + order.getQuantity());
        }
    }
    
    // Sort products by sales
    List<Map.Entry<String, Integer>> topProducts = new ArrayList<>(productSales.entrySet());
    topProducts.sort((a, b) -> b.getValue().compareTo(a.getValue()));
    topProducts = topProducts.subList(0, Math.min(5, topProducts.size()));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seilatsatsi FIS - Reports</title>
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
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; margin-bottom: 25px; }
        .stat-card { background: white; border-radius: 15px; padding: 20px; display: flex; justify-content: space-between; align-items: center; transition: transform 0.3s; }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-info h3 { font-size: 14px; color: #666; margin-bottom: 8px; }
        .stat-number { font-size: 28px; font-weight: 700; color: #333; }
        .stat-icon { width: 60px; height: 60px; background: rgba(102, 126, 234, 0.1); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 30px; color: #667eea; }
        
        /* Charts Row */
        .charts-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(450px, 1fr)); gap: 20px; margin-bottom: 25px; }
        .chart-card { background: white; border-radius: 15px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .chart-title { font-size: 18px; font-weight: 600; margin-bottom: 20px; color: #333; border-left: 4px solid #667eea; padding-left: 15px; }
        canvas { max-height: 300px; width: 100% !important; }
        
        /* Tables */
        .report-table-container { background: white; border-radius: 15px; padding: 20px; margin-bottom: 25px; }
        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 15px; }
        .table-header h3 { font-size: 18px; color: #333; border-left: 4px solid #667eea; padding-left: 15px; }
        .btn-export { background: linear-gradient(135deg, #28a745, #20c997); color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-weight: 500; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: 600; color: #555; }
        .profit-positive { color: #28a745; font-weight: bold; }
        .profit-negative { color: #dc3545; font-weight: bold; }
        
        /* Buttons */
        .btn-group { display: flex; gap: 10px; }
        .btn-secondary { background: #6c757d; color: white; border: none; padding: 8px 15px; border-radius: 6px; cursor: pointer; font-size: 12px; }
        
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
            <a href="${pageContext.request.contextPath}/dashboard" class="menu-item"><i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/orders" class="menu-item"><i class="fas fa-shopping-cart"></i><span>Orders</span></a>
            <a href="${pageContext.request.contextPath}/products" class="menu-item"><i class="fas fa-box"></i><span>Products</span></a>
            <a href="${pageContext.request.contextPath}/customers" class="menu-item"><i class="fas fa-users"></i><span>Customers</span></a>
            <a href="${pageContext.request.contextPath}/expenses" class="menu-item"><i class="fas fa-money-bill-wave"></i><span>Expenses</span></a>
            <a href="${pageContext.request.contextPath}/reports" class="menu-item active"><i class="fas fa-chart-line"></i><span>Reports</span></a>
        </div>
    </div>

    <div class="main-content">
        <div class="top-bar">
            <div class="page-title">
                <h1>Financial Reports & Analytics</h1>
                <p>Comprehensive analysis of your business performance</p>
            </div>
            <div class="user-info">
                <span class="user-name">Admin User</span>
                <div class="avatar">A</div>
            </div>
        </div>

        <!-- Summary Stats -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-info">
                    <h3>Total Revenue</h3>
                    <div class="stat-number">M <%= String.format("%,.2f", stats.totalRevenue != null ? stats.totalRevenue : 0) %></div>
                </div>
                <div class="stat-icon"><i class="fas fa-chart-line"></i></div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>Total Expenses</h3>
                    <div class="stat-number">M <%= String.format("%,.2f", totalExpenses) %></div>
                </div>
                <div class="stat-icon"><i class="fas fa-receipt"></i></div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>Gross Profit</h3>
                    <div class="stat-number profit-positive">M <%= String.format("%,.2f", stats.totalProfit != null ? stats.totalProfit : 0) %></div>
                </div>
                <div class="stat-icon"><i class="fas fa-coins"></i></div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>Net Profit</h3>
                    <div class="stat-number <%= netProfit >= 0 ? "profit-positive" : "profit-negative" %>">M <%= String.format("%,.2f", netProfit) %></div>
                </div>
                <div class="stat-icon"><i class="fas fa-chart-pie"></i></div>
            </div>
        </div>

        <!-- Charts -->
        <div class="charts-row">
            <div class="chart-card">
                <div class="chart-title">Monthly Profit Trend (Last 6 Months)</div>
                <canvas id="profitChart"></canvas>
            </div>
            <div class="chart-card">
                <div class="chart-title">Profit by Supplier</div>
                <canvas id="supplierChart"></canvas>
            </div>
        </div>

        <div class="charts-row">
            <div class="chart-card">
                <div class="chart-title">Expenses by Category</div>
                <canvas id="expenseChart"></canvas>
            </div>
            <div class="chart-card">
                <div class="chart-title">Top Selling Products</div>
                <canvas id="topProductsChart"></canvas>
            </div>
        </div>

        <!-- Detailed Reports -->
        <div class="report-table-container">
            <div class="table-header">
                <h3>Monthly Financial Summary</h3>
                <div class="btn-group">
                    <button class="btn-export" onclick="exportToCSV()"><i class="fas fa-download"></i> Export to CSV</button>
                    <button class="btn-secondary" onclick="printReport()"><i class="fas fa-print"></i> Print</button>
                </div>
            </div>
            <div style="overflow-x: auto;">
                <table id="monthlyTable">
                    <thead>
                        <tr>
                            <th>Month</th>
                            <th>Orders</th>
                            <th>Profit (M)</th>
                            <th>Avg Profit/Order (M)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map.Entry<String, Double> entry : monthlyProfit.entrySet()) { 
                            String month = entry.getKey();
                            double profit = entry.getValue();
                            int orderCount = monthlyOrders.get(month);
                            double avgProfit = orderCount > 0 ? profit / orderCount : 0;
                        %>
                        <tr>
                            <td><%= month %></td>
                            <td><%= orderCount %></td>
                            <td class="<%= profit >= 0 ? "profit-positive" : "profit-negative" %>">M <%= String.format("%,.2f", profit) %></td>
                            <td>M <%= String.format("%,.2f", avgProfit) %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="report-table-container">
            <div class="table-header">
                <h3>Expense Breakdown by Category</h3>
            </div>
            <div style="overflow-x: auto;">
                <table>
                    <thead>
                        <tr><th>Category</th><th>Amount (M)</th><th>Percentage</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map.Entry<String, Double> entry : expensesByCategory.entrySet()) { 
                            double percentage = totalExpenses > 0 ? (entry.getValue() / totalExpenses) * 100 : 0;
                        %>
                        <tr>
                            <td><%= entry.getKey() %></td>
                            <td>M <%= String.format("%,.2f", entry.getValue()) %></td>
                            <td><%= String.format("%.1f", percentage) %>%</td>
                        </tr>
                        <% } %>
                        <% if (expensesByCategory.isEmpty()) { %>
                        <tr><td colspan="3" style="text-align:center;">No expense data available</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="report-table-container">
            <div class="table-header">
                <h3>Top 5 Best Selling Products</h3>
            </div>
            <div style="overflow-x: auto;">
                <table>
                    <thead>
                        <tr><th>Product Name</th><th>Units Sold</th><th>Revenue (M)</th><th>Profit (M)</th></tr>
                    </thead>
                    <tbody>
                        <% for (Map.Entry<String, Integer> entry : topProducts) { 
                            double revenue = 0;
                            double profit = 0;
                            if (allOrders != null) {
                                for (Order order : allOrders) {
                                    if (entry.getKey().equals(order.getProductName())) {
                                        if (order.getTotalCustomerPrice() != null) revenue += order.getTotalCustomerPrice().doubleValue();
                                        if (order.getProfit() != null) profit += order.getProfit().doubleValue();
                                    }
                                }
                            }
                        %>
                        <tr>
                            <td><%= entry.getKey() %></td>
                            <td><%= entry.getValue() %></td>
                            <td>M <%= String.format("%,.2f", revenue) %></td>
                            <td class="profit-positive">M <%= String.format("%,.2f", profit) %></td>
                        </tr>
                        <% } %>
                        <% if (topProducts.isEmpty()) { %>
                        <td><td colspan="4" style="text-align:center;">No product sales data available</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // Monthly Profit Chart
        const profitCtx = document.getElementById('profitChart').getContext('2d');
        new Chart(profitCtx, {
            type: 'bar',
            data: {
                labels: [<% for (String month : monthlyProfit.keySet()) { %>'<%= month %>',<% } %>],
                datasets: [{
                    label: 'Profit (M)',
                    data: [<% for (Double profit : monthlyProfit.values()) { %><%= profit %>,<% } %>],
                    backgroundColor: 'rgba(102, 126, 234, 0.7)',
                    borderColor: '#667eea',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: { legend: { position: 'top' } }
            }
        });

        // Supplier Profit Chart
        const supplierCtx = document.getElementById('supplierChart').getContext('2d');
        new Chart(supplierCtx, {
            type: 'doughnut',
            data: {
                labels: ['SHEIN', 'TEMU'],
                datasets: [{
                    data: [<%= sheinProfit %>, <%= temuProfit %>],
                    backgroundColor: ['#667eea', '#764ba2']
                }]
            },
            options: { responsive: true, maintainAspectRatio: true }
        });

        // Expense Chart
        const expenseCtx = document.getElementById('expenseChart').getContext('2d');
        new Chart(expenseCtx, {
            type: 'pie',
            data: {
                labels: [<% for (String category : expensesByCategory.keySet()) { %>'<%= category %>',<% } %>],
                datasets: [{
                    data: [<% for (Double amount : expensesByCategory.values()) { %><%= amount %>,<% } %>],
                    backgroundColor: ['#667eea', '#764ba2', '#f093fb', '#4facfe', '#43e97b', '#fa709a']
                }]
            },
            options: { responsive: true, maintainAspectRatio: true }
        });

        // Top Products Chart
        const topCtx = document.getElementById('topProductsChart').getContext('2d');
        new Chart(topCtx, {
            type: 'bar',
            data: {
                labels: [<% for (Map.Entry<String, Integer> entry : topProducts) { %>'<%= entry.getKey() %>',<% } %>],
                datasets: [{
                    label: 'Units Sold',
                    data: [<% for (Map.Entry<String, Integer> entry : topProducts) { %><%= entry.getValue() %>,<% } %>],
                    backgroundColor: '#764ba2'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                indexAxis: 'y'
            }
        });

        function exportToCSV() {
            let csv = "Month,Orders,Profit (M),Avg Profit/Order (M)\n";
            const rows = document.querySelectorAll('#monthlyTable tbody tr');
            rows.forEach(row => {
                const cells = row.querySelectorAll('td');
                csv += cells[0].innerText + ",";
                csv += cells[1].innerText + ",";
                csv += cells[2].innerText.replace('M ', '') + ",";
                csv += cells[3].innerText.replace('M ', '') + "\n";
            });
            
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'seilatsatsi_financial_report.csv';
            a.click();
            window.URL.revokeObjectURL(url);
        }

        function printReport() {
            window.print();
        }
    </script>
</body>
</html>