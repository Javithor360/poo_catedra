<%@ page import="com.catedra.catedrapoo.beans.UserSessionBean" %>
<%@ page import="com.catedra.catedrapoo.beans.TicketBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Verificar si el usuario tiene una sesión activa
    HttpSession currentSession = request.getSession(false);
    UserSessionBean user = (UserSessionBean) currentSession.getAttribute("user");

    // Si no hay sesión activa o el usuario no es un jefe de area, redirigir al login
    if (user == null || user.getRole_id() != 3) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Verificar si el parámetro "action" ya está presente en la URL
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_tickets")) {
        // Redirigir al servlet con el parámetro "action"
        request.getRequestDispatcher("/jac?action=display_tickets").forward(request, response);
        return;
    }

    if(request.getParameter("info") != null) {
        if (request.getParameter("info").equals("success_new_ticket")) {
            request.setAttribute("info", "Se ha aperturado un nuevo caso de manera exitosa");
        } else if (request.getParameter("info").equals("error_new_ticket")) {
            request.setAttribute("info", "Ha ocurrido un error al aperturar un nuevo caso");
        } else if(request.getParameter("info").equals("error_empty_fields")) {
            request.setAttribute("info", "Por favor, rellene todos los campos");
        }
    }
%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Jefe de Área - Main</title>
</head>
<body>
<!-- Importación del navbar -->
<jsp:include page="../navbar.jsp"/>

<main class="container mt-3">
    <div>
        <h1>Bienvenido <%= user.getName() %>
        </h1>
        <p class="small"> Jefe de Área</p>
        <hr/>
    </div>

    <div>
        <h3>Historial de casos aperturados</h3>
        <%
            // Aquí se muestra el mensaje recibido por la URL en caso de que exista uno
            if(request.getParameter("info") != null) {
        %>
        <div class="alert mt-5 <%= request.getParameter("info").startsWith("error") ? "alert-danger" : "alert-success" %>"
             role="alert">
            <%= request.getAttribute("info") %>
        </div>
        <%
            }
        %>
        <div class="table-container">
            <table class="table table-striped table-bordered text-center">
                <thead>
                <tr>
                    <th>Código</th>
                    <th>Estado</th>
                    <th>Título</th>
                    <th>Fecha de entrega</th>
                    <th>Acción</th>
                </tr>
                </thead>
                <tbody>
                <%
                    // Obtener los tickets asignados al programador de la respuesta a la petición inicial
                    HashMap<String, TicketBean> tickets = (HashMap<String, TicketBean>) request.getAttribute("tickets");
                    if (tickets == null || tickets.isEmpty()) {
                %>
                <tr>
                    <td colspan="5">No hay casos asignados</td>
                </tr>
                <%
                } else {
                    // Iterar sobre los tickets y mostrarlos en la tabla
                    for (TicketBean ticket : tickets.values()) {
                %>
                <tr>
                    <td><%= ticket.getCode() %>
                    </td>
                    <td><%= ticket.getState() %>
                    </td>
                    <td><%= ticket.getName() %>
                    </td>
                    <td><%= ticket.getDue_date() != null ? ticket.getDue_date() : "Sin asignar" %>
                    </td>
                    <td>
                        <!-- Botón para ver el detalle del ticket -->
                        <a href="/jefe_area/detail.jsp?&id=<%= ticket.getId() %>" class="btn btn-primary">Ver</a>
                    </td>
                </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
            <button
                    class="btn btn-success justify-content-center"
                    data-bs-toggle="modal"
                    data-bs-target="#newTicketModal"
            >
                Aperturar nuevo caso
            </button>
        </div>
    </div>
</main>

<!-- Modal: Creación de nuevo caso -->
<div class="modal fade" id="newTicketModal" tabindex="-1" aria-labelledby="newTicketModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="ticketModalLabel">Creación de un nuevo caso</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>
            <div class="modal-body" id="newTicketModalBody">
                <form method="POST" action="/jac">
                    <div class="mb-3">
                        <label for="ticketTitle" class="form-label">Título del caso</label>
                        <input type="text" class="form-control" id="ticketTitle" name="ticketTitle" required>
                    </div>
                    <div class="mb-3">
                        <label for="ticketDescription" class="form-label">Descripción del caso</label>
                        <textarea class="form-control" id="ticketDescription" name="ticketDescription" required></textarea>
                    </div>
                    <div class="mb-3">
                        <label for="ticketFile" class="form-label">Archivo PDF</label>
                        <input type="file" class="form-control form-control-file" id="ticketFile" />
                    </div>
                    <div class="d-flex">
                        <input type="hidden" name="action" value="new_ticket" />
                        <button type="submit" class="btn btn-success mr-2">Crear caso</button>
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" aria-label="Close">Cancelar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

</body>
</html>
