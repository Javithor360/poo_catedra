<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page import="java.util.Objects" %>
<%@ page import="com.catedra.catedrapoo.beans.TicketBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="listNames" class="com.catedra.catedrapoo.models.JefeDesarrollo" scope="session" /> <!-- Importar el Bean para obtener la lista de nombres -->

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");

    // Verificar si el usuario es nulo o si no es un jefe de desarrollo
    if(user == null || user.getRole_id() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Verificar si el parámetro "action" ya está presente en la URL
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_new_tickets")) {
        // Redirigir al servlet con el parámetro "action"
        request.getRequestDispatcher("/jdc?action=display_new_tickets").forward(request, response);
        return;
    }

    // Verificar si hay un mensaje en la URL
    if (request.getParameter("info") != null) {
        if(Objects.equals(request.getParameter("info"), "success_accept_ticket")) {
            request.setAttribute("info", "El ticket ha sido aceptado correctamente...");
        } else if(Objects.equals(request.getParameter("info"), "success_deny_ticket")) {
            request.setAttribute("info", "El ticket ha sido rechazado correctamente...");
        } else if(Objects.equals(request.getParameter("info"), "error_accept_ticket")) {
            request.setAttribute("info", "Ha ocurrido un error al aceptar el ticket...");
        } else if(Objects.equals(request.getParameter("info"), "error_denny_ticket")) {
            request.setAttribute("info", "Ha ocurrido un error al rechazar el ticket...");
        }
    }
%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Jefe de Desarrollo - Index</title>
</head>
<body>
<jsp:include page="../navbar.jsp" />

<main class="container mt-3">
    <div>
        <h1>Bienvenido <%= user.getName() %></h1>
        <p class="small"> Jefe de Desarrollo</p>
        <hr />
    </div>
    <div>
        <h3>Casos aperturados recientemente</h3>
        <div class="table-container">
            <table class="table table-striped table-bordered text-center">
                <thead>
                <tr>
                    <th>Código</th>
                    <th>Solicitante</th>
                    <th>Título</th>
                    <th>Fecha de solicitud</th>
                    <th>Acción</th>
                </tr>
                </thead>
                <tbody>
                <%
                    // Obteniendo por medio del parámetro retornado por el servlet los tickets
                    HashMap<String, TicketBean> new_tickets = (HashMap<String, TicketBean>) request.getAttribute("new_tickets");
                    if (new_tickets == null || new_tickets.isEmpty()) {
                %>
                <tr>
                    <td colspan="5" class="text-center">Por el momento no hay casos solicitados...</td>
                </tr>
                <%
                } else {
                    // Iterando el HashMap para mostrar los tickets
                    for(TicketBean ticket : new_tickets.values()) {
                %>
                <tr>
                    <td><%= ticket.getCode() %></td>
                    <td><%= ticket.getBoss_name() %></td>
                    <td><%= ticket.getName() %></td>
                    <td><%= ticket.getCreated_at() %></td>
                    <td>
                        <a href="/jefe_desarrollo/detail.jsp?id=<%= ticket.getId() %>" class="btn btn-primary">Ver más</a>
                    </td>
                </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
            // Aquí se muestra el mensaje recibido por la URL en caso de que exista uno
            if(request.getParameter("info") != null) {
        %>
        <div class="alert mt-2 <%= request.getParameter("info").startsWith("error") ? "alert-danger" : "alert-success" %>"
             role="alert">
            <%= request.getAttribute("info") %>
        </div>
        <%
            }
        %>
    </div>
</main>

</html>
