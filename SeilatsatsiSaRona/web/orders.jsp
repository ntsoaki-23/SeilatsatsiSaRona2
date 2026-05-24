<%@ page import="com.seilatsatsi.dao.OrderDAO" %>
<%@ page import="com.seilatsatsi.model.Order" %>
<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    OrderDAO orderDAO = new OrderDAO();
    List<Order> orders = orderDAO.getAllOrders();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seilatsatsi FIS - Orders</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .sidebar { position: fixed; left: 0; top: 0; width: 260px; height: 100%; background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%); color: white; z-index: 100; }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h2 { font-size: 20px; }
        .sidebar-header p { font-size: 12px; opacity: 0.7; }
        .sidebar-menu { padding: 20px 0; }
        .menu-item { padding: 12px 25px; display: flex; align-items: center; gap: 12px; color: rgba(255,255,255,0.8); transition: all 0.3s; text-decoration: none; }
        .menu-item:hover, .menu-item.active { background: rgba(255,255,255,0.1); color: white; border-left: 3px solid #667eea; }
        .menu-item i { width: 20px; }
        .main-content { margin-left: 260px; padding: 20px; }
        .top-bar { background: white; border-radius: 15px; padding: 15px 25px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; }
        .page-title h1 { font-size: 24px; color: #333; }
        .user-info { display: flex; align-items: center; gap: 15px; }
        .avatar { width: 40px; height: 40px; background: linear-gradient(135deg, #667eea, #764ba2); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; }
        .orders-table-container { background: white; border-radius: 15px; padding: 20px; }
        .table-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn-add { background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 10px 20px; border-radius: 8px; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; }
        .alert { padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; }
        .alert.success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert.error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: 600; }
        .status-badge { padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 500; display: inline-block; }
        .status-paid, .status-delivered { background: #d4edda; color: #155724; }
        .status-pending, .status-ordered, .status-shipped { background: #fff3cd; color: #856404; }
        select, .btn-small { padding: 5px 10px; border-radius: 5px; border: 1px solid #ddd; }
        .btn-small { background: #17a2b8; color: white; text-decoration: none; display: inline-block; font-size: 12px; }
        .profit-positive { color: #28a745; font-weight: bold; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="sidebar-header"><h2>🛍️ Seilatsatsi</h2><p>FIS</p></div>
        <div class="sidebar-menu">
            <a href="${pageContext.request.contextPath}/dashboard" class="menu-item"><i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/orders" class="menu-item active"><i class="fas fa-shopping-cart"></i><span>Orders</span></a>
            <a href="${pageContext.request.contextPath}/products" class="menu-item"><i class="fas fa-box"></i><span>Products</span></a>
            <a href="${pageContext.request.contextPath}/customers" class="menu-item"><i class="fas fa-users"></i><span>Customers</span></a>
            <a href="${pageContext.request.contextPath}/expenses" class="menu-item"><i class="fas fa-money-bill-wave"></i><span>Expenses</span></a>
        </div>
    </div>

    <div class="main-content">
        <div class="top-bar">
            <div class="page-title"><h1>Order Management</h1></div>
            <div class="user-info"><span class="user-name">Admin</span><div class="avatar">A</div></div>
        </div>

        <div class="orders-table-container">
            <div class="table-header">
                <h3>All Orders</h3>
                <a href="${pageContext.request.contextPath}/orders?action=create" class="btn-add"><i class="fas fa-plus"></i> New Order</a>
            </div>
            
            <% String success = request.getParameter("success"); %>
            <% String error = request.getParameter("error"); %>
            <% if ("created".equals(success)) { %>
                <div class="alert success">✓ Order created successfully!</div>
            <% } else if ("updated".equals(success)) { %>
                <div class="alert success">✓ Order status updated!</div>
            <% } else if (error != null) { %>
                <div class="alert error">✗ Operation failed! Please try again.</div>
            <% } %>
            
            <div style="overflow-x: auto;">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th><th>Date</th><th>Customer</th><th>Product</th><th>Qty</th><th>Amount (M)</th><th>Profit (M)</th><th>Status</th><th>Payment</th><th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (orders != null && !orders.isEmpty()) { 
                            for (Order order : orders) { 
                                boolean isProfitPositive = order.getProfit() != null && order.getProfit().doubleValue() > 0;
                        %>
                            <tr>
                                <td><%= order.getOrderId() %></td>
                                <td><%= order.getOrderDate() %></td>
                                <td><%= order.getCustomerName() %></td>
                                <td><%= order.getProductName() %></td>
                                <td><%= order.getQuantity() %></td>
                                <td>M <%= order.getTotalCustomerPrice() %></td>
                                <td class="<%= isProfitPositive ? "profit-positive" : "" %>">M <%= order.getProfit() != null ? order.getProfit() : 0 %></td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/orders" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                                        <select name="status" onchange="this.form.submit()">
                                            <option value="ordered" <%= "ordered".equals(order.getOrderStatus()) ? "selected" : "" %>>Ordered</option>
                                            <option value="shipped" <%= "shipped".equals(order.getOrderStatus()) ? "selected" : "" %>>Shipped</option>
                                            <option value="delivered" <%= "delivered".equals(order.getOrderStatus()) ? "selected" : "" %>>Delivered</option>
                                            <option value="cancelled" <%= "cancelled".equals(order.getOrderStatus()) ? "selected" : "" %>>Cancelled</option>
                                        </select>
                                    </form>
                                </td>
                                <td><span class="status-badge status-<%= order.getPaymentStatus() %>"><%= order.getPaymentStatus() %></span></td>
                                <td><a href="#" class="btn-small">View</a></td>
                            </tr>
                        <% } 
                        } else { %>
                            <tr>
                                <td colspan="10" style="text-align:center;">No orders found. <a href="${pageContext.request.contextPath}/orders?action=create">Create your first order</a></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>