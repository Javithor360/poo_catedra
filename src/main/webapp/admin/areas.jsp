<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.catedra.catedrapoo.beans.AreaBean" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");

    // Verificar si el usuario es nulo o si no es un administrador
    if(user == null || user.getRole_id() != 0) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Verificar si el parámetro "action" ya está presente en la URL
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_areas")) {
        // Redirigir al servlet con el parámetro "action"
        request.getRequestDispatcher("/adm?action=display_areas").forward(request, response);
        return;
    }

    if(request.getParameter("info") != null) {
        if(request.getParameter("info").equals("success_create_area")) {
            request.setAttribute("info", "Área creada exitosamente");
        } else if(request.getParameter("info").equals("error_create_area")) {
            request.setAttribute("info", "Error al crear el área");
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
    <h3>Lista de áreas en el sistema</h3>
    <hr />
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
                <th>Prefijo</th>
                <th>Nombre</th>
                <th>Jefe</th>
                <th>Jefe de Desarrollo</th>
            </tr>
            </thead>
            <tbody>
            <%
                // Obtener la lista de usuarios
                    HashMap<Integer, AreaBean> area_list = (HashMap<Integer, AreaBean>) request.getAttribute("areas");
                    if (area_list == null || area_list.isEmpty()) {
            %>
                <tr>
                    <td colspan="4">No hay áreas registradas en el sistema</td>
                </tr>
            <%
                } else {
                    for (AreaBean area : area_list.values()) {
            %>
                <tr>
                    <td><%= area.getPrefix() %></td>
                    <td><%= area.getName() %></td>
                    <td><%= area.getBoss().getName() %></td>
                    <td><%= area.getDev_boss().getName() %></td>
                </tr>
            <%
                    }
                }
            %>
            </tbody>
        </table>
        <a href="/admin/index.jsp" class="btn btn-secondary">Volver</a>
        <a href="/admin/area_form.jsp" class="btn btn-success">Agregar</a>
    </div>
</main>

</body>
</html>
