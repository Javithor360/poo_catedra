<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.catedra.catedrapoo.models.Grupo" %>
<%@ page import="com.catedra.catedrapoo.models.Admin" %>
<%@ page import="java.sql.SQLException" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");

    HashMap<Integer, UserBean> jefesDesarrollo = null;
    HashMap<Integer, UserBean> jefesArea;
    int numGrupoEmpleados;
    int numGrupoDev;

    // Verificar si el usuario es nulo o si no es un administrador
    if (user == null || user.getRole_id() != 0) {
        response.sendRedirect("../login.jsp");
        return;
    }

    try {
        numGrupoEmpleados = Grupo.countGroups() + 1;
        numGrupoDev = Grupo.countGroups() + 2;

        jefesDesarrollo = Admin.getUsersByRoleWithoutRole(1);
        jefesArea = Admin.getUsersByRoleWithoutRole(3);
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("../admin/index.jsp");
        return;
    }

    if(request.getParameter("info") != null) {
        if(request.getParameter("info").equals("error_empty_fields")) {
            request.setAttribute("info", "Debes completar todos los campos.");
        } else if (request.getParameter("info").equals("error_prefix_length")) {
            request.setAttribute("info", "El prefijo debe tener una longitud de 3 caracteres.");
        }
    }

%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Administrador - Formulario</title>
</head>
<body>

<jsp:include page="../navbar.jsp"/>

<main class="container mt-3">
    <h1 class="text-center mb-4">Crear nueva Área Funcional</h1>
    <div class="text-center mb-2">Administra y visualiza el mapeo de integrantes de los distintos grupos de las Áreas
        Funcionales.
    </div>
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
    <form action="/adm" method="POST" id="createArea">
        <input type="hidden" name="operacion" value="crearAreaFuncional">
        <div class="row">
            <div class="col-md-6 mb-3">
                <label for="name" class="form-label">Nombre:</label>
                <input type="text" class="form-control" id="name" name="name">
            </div>
            <div class="col-md-6 mb-3">
                <label for="prefix" class="form-label">Prefijo:</label>
                <input type="text" class="form-control" id="prefix" name="prefix">
            </div>
        </div>
        <div class="row">
            <div class="col-md-6 mb-3">
                <label for="boss" class="form-label">Jefe de Área:</label>
                <select class="form- form-control" id="boss" name="boss">
                    <option selected disabled value="">Seleccione un Jefe de Área</option>
                    <%
                        if (!jefesArea.isEmpty()) {
                            for (UserBean jefeArea : jefesArea.values()) {
                    %>
                    <option value="<%= jefeArea.getId() %>"><%= jefeArea.getName() %>
                    </option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>
            <div class="col-md-6 mb-3">
                <label for="dev_boss" class="form-label">Jefe de Desarrollo:</label>
                <select class="form-select form-control" id="dev_boss" name="dev_boss">
                    <option selected disabled value="0">Seleccione un Jefe de Desarrollo</option>
                    <%
                        if(!jefesDesarrollo.isEmpty()) {
                            for (UserBean jefeDev : jefesDesarrollo.values()) {
                    %>
                    <option value="<%= jefeDev.getId() %>"><%= jefeDev.getName() %>
                    </option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>
        </div>
        <div class="row">
            <div class="col-md-6 mb-3">
                <label for="empNum" class="form-label">ID Grupo Empleados:</label>
                <input type="number" class="form-control" id="empNum"
                       step="0" disabled value="<%= numGrupoEmpleados %>">
                <input type="hidden" name="empNum" value="<%= numGrupoEmpleados %>" />
            </div>
            <div class="col-md-6 mb-3">
                <label for="devNum" class="form-label">ID Grupo Programadores:</label>
                <input type="number" class="form-control" id="devNum"
                       step="0" disabled value="<%= numGrupoDev%>">
                <input type="hidden" name="devNum" value="<%= numGrupoDev %>" />
            </div>
        </div>

        <div>
            <input type="hidden" name="action" value="new_area" />
            <a href="/admin/areas.jsp" class="btn btn-secondary">Volver</a>
            <button type="submit" class="btn btn-success">Crear</button>
        </div>
    </form>
</main>

</body>
</html>
