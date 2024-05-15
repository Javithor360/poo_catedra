<%@ page import="com.catedra.catedrapoo.beans.UserSessionBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserSessionBean user = (UserSessionBean) currentSession.getAttribute("user");

    // Verificar si el usuario es nulo o si no es un administrador
    if(user == null || user.getRole_id() != 0) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Verificar si el parámetro "action" ya está presente en la URL
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_users")) {
        // Redirigir al servlet con el parámetro "action"
        request.getRequestDispatcher("/adm?action=display_users").forward(request, response);
        return;
    }

    System.out.println(request.getAttribute("info") != null ? request.getAttribute("info") : "No hay mensajes");
    if(request.getParameter("info") != null) {
        if(request.getParameter("info").equals("success_update_user")) {
            request.setAttribute("info", "Usuario actualizado correctamente");
        } else if(request.getParameter("info").equals("error_update_user")) {
            request.setAttribute("info", "Ocurrió un error al intentar actualizar el usuario");
        } else if (request.getParameter("info").equals("success_delete_user")) {
            request.setAttribute("info", "Usuario eliminado correctamente");
        } else if (request.getParameter("info").equals("error_delete_user")) {
            request.setAttribute("info", "Ocurrió un error al intentar eliminar el usuario");
        }
    }
%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Administrador - Usuarios</title>
</head>
<body>

<jsp:include page="../navbar.jsp" />

<main class="container mt-3">
    <div>
        <h1>Bienvenido <%= user.getName() %></h1>
        <p class="small">Superusuario</p>
    </div>
    <hr />
    <div>
        <h3>Lista de usuarios en el sistema</h3>
        <div class="table-container">
            <%
                // Mostrar mensajes de información recibidos de la petición
                if (request.getAttribute("info") != null) {
            %>
            <div class="alert my-5 <%= request.getParameter("info").startsWith("error") ? "alert-danger" : "alert-success" %>"
                 role="alert">
                <%= request.getAttribute("info") %>
            </div>
            <%
                }
            %>
            <table class="table table-striped table-bordered text-center">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Nombre</th>
                    <th>Cargo</th>
                    <th>Email</th>
                    <th>Género</th>
                    <th>Fecha creación</th>
                    <th>Acción</th>
                </tr>
                </thead>
                <tbody>
                <%
                    // Obtener la lista de usuarios
                    HashMap<Integer, UserSessionBean> user_list = (HashMap<Integer, UserSessionBean>) request.getAttribute("users");
                    if (user_list == null || user_list.isEmpty()) {
                %>
                    <tr>
                        <td colspan="6">No hay usuarios registrados</td>
                    </tr>
                <%
                    } else {
                        for (UserSessionBean employee : user_list.values()) {
                %>
                    <tr>
                        <td><%= employee.getId() %></td>
                        <td><%= employee.getName() %></td>
                        <td><%= employee.getRole_name() %></td>
                        <td><%= employee.getEmail() %></td>
                        <td><%= employee.getGender().equals("M") ? "Masculino" : "Femenino" %></td>
                        <td><%= employee.getCreated_at() %></td>
                        <td>
                            <a href="/admin/form.jsp?id=<%= employee.getId() %>" class="btn btn-primary">Editar</a>
                            <a href="/adm?action=delete_user&id=<%= employee.getId() %>" class="btn btn-danger">Eliminar</a>
                        </td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</main>

</body>
</html>
