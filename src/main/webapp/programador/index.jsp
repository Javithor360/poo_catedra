<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page import="com.catedra.catedrapoo.beans.TicketBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Verificar si el usuario tiene una sesión activa
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");

    // Si no hay sesión activa o el usuario no es un programador, redirigir al login
    if(user == null || user.getRole_id() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Verificar si el parámetro "action" ya está presente en la URL
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_tickets")) {
        // Redirigir al servlet con el parámetro "action"
        request.getRequestDispatcher("/pdc?action=display_tickets").forward(request, response);
        return;
    }
%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Programador - Main</title>
</head>
<body>

<!-- Importación del navbar -->
<jsp:include page="../navbar.jsp" />

<main class="container mt-3">
    <div>
        <h1>Bienvenido <%= user.getName() %></h1>
        <p class="small"> Programador</p>
        <hr />
    </div>

    <div>
        <h3>Tus casos asignados</h3>
        <div class="table-container">
            <table class="table table-striped table-bordered text-center">
                <thead>
                <tr>
                    <th>Código</th>
                    <th>Título</th>
                    <th>Fecha de entrega</th>
                    <th>Acción</th>
                </tr>
                </thead>
                <tbody>
                <%
                    // Obtener los tickets asignados al programador de la respuesta a la petición inicial
                    HashMap<String, TicketBean> tickets = (HashMap<String, TicketBean>) request.getAttribute("tickets");
                    if(tickets == null || tickets.isEmpty()) {
                %>
                <tr>
                    <td colspan="4">No hay casos asignados</td>
                </tr>
                <%
                } else {
                    // Iterar sobre los tickets y mostrarlos en la tabla
                    for (TicketBean ticket : tickets.values()) {
                %>
                <tr>
                    <td><%= ticket.getCode() %></td>
                    <td><%= ticket.getName() %></td>
                    <td><%= ticket.getDue_date() %></td>
                    <td>
                        <!-- Botón para ver el detalle del ticket -->
                        <a href="/programador/detail.jsp?&id=<%= ticket.getId() %>" class="btn btn-primary">Ver</a>
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
