<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");

    UserBean selected_user = (UserBean) request.getAttribute("selected_user");

    // Verificar si el usuario es nulo o si no es un administrador
    if(user == null || user.getRole_id() != 0) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Verificar si el parámetro "action" ya está presente en la URL
    String actionParam = request.getParameter("id");
    if (actionParam != null && selected_user == null) {
        // Redirigir al servlet con el parámetro "action"
        request.getRequestDispatcher("/adm?action=display_user&id=" + actionParam).forward(request, response);
        return;
    }
%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Administrador - Formulario</title>
</head>
<body>

<jsp:include page="../navbar.jsp" />

<div class="container">
    <div class="col-md-12 mt-5">
        <div class="form-appl">
            <h3><%= request.getParameter("id") != null ? "Modificar usuario" : "Agregar usuario" %></h3>
            <hr />
            <form class="w-50" method="post" action="/adm">
                <% if (selected_user != null) { %>
                <div class="form-group col-md-12 mb-3 d-flex justify-content-between">
                    <div>
                        <label for="id">ID</label>
                        <input type="text" class="form-control" id="id" value="<%= selected_user != null ? selected_user.getId() : "" %>" required readonly>
                        <input type="hidden" name="id" value="<%= selected_user != null ? selected_user.getId() : "" %>" readonly>
                    </div>
                    <div>
                        <label for="fecha_crea">Fecha creación</label>
                        <input type="date" class="form-control" id="fecha_crea" value="<%= selected_user != null ? selected_user.getCreated_at() : "" %>" required readonly>
                        <input type="hidden" class="form-control" name="fecha_crea" value="<%= selected_user != null ? selected_user.getCreated_at() : "" %>" readonly>
                    </div>
                </div>
                <% } %>
                <div class="form-group col-md-12 mb-3 d-flex justify-content-between">
                    <div>
                        <label for="nombre">Nombre</label>
                        <input type="text" class="form-control" id="nombre" name="nombre" value="<%= selected_user != null ? selected_user.getName() : "" %>" required>
                    </div>
                    <div>
                        <label for="fecha_nac">Fecha nacimiento</label>
                        <input type="date" class="form-control" id="fecha_nac" name="fecha_nac" value="<%= selected_user != null ? selected_user.getBirthday() : "" %>" required>
                    </div>
                </div>
                <div class="form-group col-md-12 mb-3 d-flex justify-content-between">
                    <div>
                        <label for="email">Email</label>
                        <input type="email" class="form-control" id="email" name="email" value="<%= selected_user != null ? selected_user.getEmail() : "" %>" required>
                    </div>
                    <div>
                        <label for="password">Contraseña</label>
                        <input type="password" class="form-control" id="password" name="password" value="<%= selected_user != null ? selected_user.getPassword() : "" %>" required>
                    </div>
                </div>
                <div class="form-group col-md-12 mb-3 d-flex justify-content-between">
                    <div>
                        <label for="genero">Género</label>
                        <select class="form-control form-select" name="genero" id="genero" required>
                            <option value="M" <%= selected_user != null && selected_user.getGender().equals("M") ? "selected" : "" %>>Masculino</option>
                            <option value="F" <%= selected_user != null && selected_user.getGender().equals("F") ? "selected" : "" %>>Femenino</option>
                        </select>
                    </div>
                    <div>
                        <label for="rol">Rol</label>
                        <select class="form-control form-select" name="rol" id="rol" required>
                            <option value="1" <%= selected_user != null && selected_user.getRole_id() == 1 ? "selected" : "" %>>Jefe de Desarrollo</option>
                            <option value="2" <%= selected_user != null && selected_user.getRole_id() == 2 ? "selected" : "" %>>Programador</option>
                            <option value="3" <%= selected_user != null && selected_user.getRole_id() == 3 ? "selected" : "" %>>Jefe de área funcional</option>
                            <option value="4" <%= selected_user != null && selected_user.getRole_id() == 4 ? "selected" : "" %>>Empleado</option>
                        </select>
                    </div>
                </div>

                <input type="hidden" name="action" value="<%= request.getParameter("id") != null ? "modify_user" : "create_user" %>">
                <button type="submit" class="btn btn-primary"><%= request.getParameter("id") != null ? "Modificar" : "Agregar" %></button>
                <a href="/admin/users.jsp" class="btn btn-secondary">Volver</a>
            </form>
        </div>
    </div>
</div>
</body>
</html>