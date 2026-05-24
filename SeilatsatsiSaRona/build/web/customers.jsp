<%@ page import="com.seilatsatsi.dao.CustomerDAO" %>
<%@ page import="com.seilatsatsi.model.Customer" %>
<%@ page import="java.util.List" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    CustomerDAO customerDAO = new CustomerDAO();
    List<Customer> customers = customerDAO.getAllCustomers();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seilatsatsi FIS - Customers</title>
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
        .btn-add { background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; }
        .alert { padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; }
        .alert.success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: 600; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center; }
        .modal-content { background: white; border-radius: 15px; width: 500px; max-width: 90%; padding: 25px; }
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .close-modal { cursor: pointer; font-size: 24px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 500; }
        .form-group input, .form-group textarea, .form-group select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; }
        .btn-submit { background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 12px; width: 100%; border-radius: 8px; cursor: pointer; font-weight: 600; margin-top: 10px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="sidebar-header"><h2>🛍️ Seilatsatsi</h2><p>FIS</p></div>
        <div class="sidebar-menu">
            <a href="${pageContext.request.contextPath}/dashboard" class="menu-item"><i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a>
            <a href="${pageContext.request.contextPath}/orders" class="menu-item"><i class="fas fa-shopping-cart"></i><span>Orders</span></a>
            <a href="${pageContext.request.contextPath}/products" class="menu-item"><i class="fas fa-box"></i><span>Products</span></a>
            <a href="${pageContext.request.contextPath}/customers" class="menu-item active"><i class="fas fa-users"></i><span>Customers</span></a>
            <a href="${pageContext.request.contextPath}/expenses" class="menu-item"><i class="fas fa-money-bill-wave"></i><span>Expenses</span></a>
        </div>
    </div>

    <div class="main-content">
        <div class="top-bar">
            <div class="page-title"><h1>Customer Management</h1></div>
            <div class="user-info"><span class="user-name">Admin</span><div class="avatar">A</div></div>
        </div>

        <div class="orders-table-container">
            <div class="table-header">
                <h3>Customer List</h3>
                <button class="btn-add" onclick="openAddCustomerModal()"><i class="fas fa-plus"></i> Add Customer</button>
            </div>
            
            <% if ("added".equals(request.getParameter("success"))) { %>
                <div class="alert success">✓ Customer added successfully!</div>
            <% } %>
            
            <div style="overflow-x: auto;">
                <table>
                    <thead>
                        <tr><th>ID</th><th>Full Name</th><th>Phone</th><th>Email</th><th>Address</th><th>Orders</th><th>Registration Date</th></tr>
                    </thead>
                    <tbody>
                        <% if (customers != null && !customers.isEmpty()) { 
                            for (Customer customer : customers) { 
                        %>
                            <tr>
                                <td><%= customer.getCustomerId() %></td>
                                <td><%= customer.getFullName() %></td>
                                <td><%= customer.getPhone() %></td>
                                <td><%= customer.getEmail() != null ? customer.getEmail() : "-" %></td>
                                <td><%= customer.getAddress() != null ? customer.getAddress() : "-" %></td>
                                <td><%= customer.getTotalOrders() %></td>
                                <td><%= customer.getRegistrationDate() %></td>
                            </tr>
                        <% } 
                        } else { %>
                            <tr><td colspan="7" style="text-align:center;">No customers found</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Add Customer Modal -->
    <div id="addCustomerModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Add Customer</h3>
                <span class="close-modal" onclick="closeCustomerModal()">&times;</span>
            </div>
            <form action="${pageContext.request.contextPath}/customers" method="post">
                <div class="form-group">
                    <label>Full Name *</label>
                    <input type="text" name="fullName" required>
                </div>
                <div class="form-group">
                    <label>Phone Number *</label>
                    <input type="tel" name="phone" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email">
                </div>
                <div class="form-group">
                    <label>Address</label>
                    <textarea name="address" rows="3"></textarea>
                </div>
                <button type="submit" class="btn-submit">Add Customer</button>
            </form>
        </div>
    </div>

    <script>
        function openAddCustomerModal() {
            document.getElementById('addCustomerModal').style.display = 'flex';
        }
        function closeCustomerModal() {
            document.getElementById('addCustomerModal').style.display = 'none';
        }
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
            }
        }
    </script>
</body>
</html>