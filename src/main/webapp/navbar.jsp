<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");
%>

<nav class="navbar navbar-dark bg-dark navbar-expand-sm">
    <div class="container-fluid">
        <div class="navbar-nav me-auto">
            <!-- Todas las páginas de inicio de todos los tipos de usuario deben ser main.jsp -->
            <a class="nav-link" aria-current="page" href="index.jsp">Inicio</a>
            <%
                // Condición que determina que elementos adicionales
                // se utilizarán en el navbar, dependiendo del tipo
                // de usuario que haya iniciado sesión.
                if (user.getRole_id() == 1) {
            %>
            <a class="nav-link" href="supervise.jsp">Supervisar</a>
            <%
                    // Agregar los demás tipos de usuario con un else
                    // aquí si hace falta
                }
            %>
        </div>
        <div class="navbar-nav ms-auto">
            <!-- No modificar el href de este enlace -->
            <a class="nav-link btn btn-danger text-white" href="../session_handler?operacion=logout">Cerrar sesión</a>
        </div>
    </div>
</nav>
