<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.catedra.catedrapoo.beans.GroupBean" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Válidar si el usuario tiene permisos para acceder a la página
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");

    if (user == null || user.getRole_id() != 0) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_groups")) {
        request.getRequestDispatcher("/adm?action=display_groups").forward(request, response);
        return;
    }
%>

<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Admin - Grupos</title>
</head>
<body>

<jsp:include page="../navbar.jsp"/>

<main class="container mt-3">
    <h1 class="text-center mb-4">Distribución de grupos</h1>
    <hr/>
    <div class="table-container">
        <table class="table table-striped table-bordered text-center">
            <thead>
            <tr>
                <th>ID</th>
                <th>Área</th>
                <th>Nombre del grupo</th>
                <th>Jefe</th>
                <th>Miembros</th>
                <th>Acción</th>
            </tr>
            </thead>
            <tbody>
            <%
                HashMap<Integer, GroupBean> groups = (HashMap<Integer, GroupBean>) request.getAttribute("groups");
                if (groups != null && !groups.isEmpty()) {
                    for (GroupBean group : groups.values()) {
            %>
            <tr>
                <td><%= group.getId() %>
                </td>
                <td><%= group.getArea().getName() %>
                </td>
                <td><%= group.getName() %>
                </td>
                <td><%= group.getBoss().getName() %>
                </td>
                <td><%= group.getMembers_count() %>
                </td>
                <td>
                    <a href="" class="btn btn-primary">Editar</a>
                </td>
            </tr>
            <%
                    }
                } else {
            %>
            <tr>
                <td colspan="6">No hay grupos registrados</td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>
        <div class="d-flex justify-content-center">
            <a href="/admin/index.jsp" class="btn btn-secondary">Volver</a>
        </div>
    </div>
</main>


</body>
</html>
