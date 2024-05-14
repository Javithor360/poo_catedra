<%@ page import="com.catedra.catedrapoo.beans.TicketBean" %>
<%@ page import="com.catedra.catedrapoo.beans.UserSessionBean" %>
<%@ page import="com.catedra.catedrapoo.beans.BitacoraBean" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserSessionBean user = (UserSessionBean) currentSession.getAttribute("user");
    TicketBean ticket = (TicketBean) request.getAttribute("ticket");

    // Si no hay sesión o el usuario no es un probador, redirigir al login
    if (user == null || user.getRole_id() != 4) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Si no hay parámetro, redirigir al controlador
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_ticket")) {
        request.getRequestDispatcher("/pbc?action=display_ticket&ticket_id=" + request.getParameter("id")).forward(request, response);
        return;
    }

    // Si no hay ticket o el ticket no pertenece al probador, redirigir al dashboard
    if (request.getParameter("id") == null || (ticket != null && !ticket.getTester_name().equals(user.getName()))) {
        response.sendRedirect("/probador/index.jsp");
        return;
    }

    // Si no hay ticket, redirigir al dashboard
    if (ticket == null) {
        response.sendRedirect("/probador/index.jsp");
        return;
    }

    if (request.getParameter("info") != null) {
        if(request.getParameter("info").equals("success_accept_ticket")) {
            request.setAttribute("info", "Caso aceptado y finalizado correctamente");
        } else if(request.getParameter("action").equals("error_accept_ticket")) {
            request.setAttribute("info", "Ocurrió un error y no se pudo aceptar y finalizar el caso");
        } else if(request.getParameter("action").equals("success_deny_ticket")) {
            request.setAttribute("info", "Caso rechazado y devuelto correctamente");
        } else if(request.getParameter("action").equals("error_deny_ticket")) {
            request.setAttribute("info", "Ocurrió un error y no se pudo rechazar y devolver el caso");
        } else if (request.getParameter("info").equals("error_empty_fields")) {
            request.setAttribute("info", "Necesitas brindar más información sobre el motivo del rechazo para ejecutar esta acción");
        }
    }

    // Obtener el progreso del ticket una vez el ticket esté definido
    double ticket_progress = ticket.get_latest_percent(ticket);
    // Formateador para la cadena de fecha
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    // Convertir la cadena de fecha en un LocalDateTime
    LocalDateTime newDate = LocalDateTime.parse(ticket.getDue_date(), formatter);
%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Jefe de Área - Información</title>
</head>
<body>

<!-- Navbar -->
<jsp:include page="../navbar.jsp"/>

<!-- Contenido -->
<main class="container mx-auto my-5 w-50">
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
    <h1 class="text-center">Información del ticket</h1>
    <hr class="mb-3"/>
    <form action="#"> <!-- Formulario de información del ticket -->
        <div class="row g-2">
            <div class='form-group col-md-4'>
                <label for='id'><strong>ID:</strong></label>
                <input type='text' id='id' class='form-control' value='<%= ticket.getId() %>' readonly>
                <!-- Campos solo de lectura -->
            </div>
            <div class='form-group col-md-4'>
                <label for='code'><strong>Código:</strong></label>
                <input type='text' id='code' class='form-control' value='<%= ticket.getCode() %>' readonly>
            </div>
            <div class='form-group col-md-4'>
                <label for='state'><strong>Estado:</strong></label>
                <input type='text' id='state' class='form-control' value='<%= ticket.getState() %>' readonly>
            </div>
        </div>

        <div class='row g-2'>
            <div class='form-group col-md-6'>
                <label for='requester'><strong>Solicitante:</strong></label>
                <input type='text' id='requester' class='form-control'
                       value='<%= ticket.getBoss_name() %> (Depto de. <%= ticket.getRequester_area_name() %>)' readonly>
            </div>
            <div class='form-group col-md-6'>
                <label for='tester'><strong>Probador:</strong></label>
                <input type='text' id='tester' class='form-control'
                       value='<%= ticket.getTester_name() != null ? ticket.getTester_name() : "No asignado" %>'
                       readonly>
            </div>
            <div class='form-group col-md-6'>
                <label for='programmer'><strong>Programador:</strong></label>
                <input type='text' id='programmer' class='form-control'
                       value='<%= ticket.getProgrammer_name() != null ? ticket.getProgrammer_name() : "No asignado" %>'
                       readonly>
            </div>
            <div class='form-group col-md-6'>
                <label for='boss'><strong>Jefe de desarrollo:</strong></label>
                <input type='text' id='boss' class='form-control' value='<%= ticket.getDev_boss_name() %>' readonly>
            </div>
        </div>

        <div class='row g-2'>
            <div class='form-group col-md-12'>
                <label for='title'><strong>Título:</strong></label>
                <input type='text' id='title' class='form-control' value='<%= ticket.getName() %>' readonly>
            </div>
            <div class='form-group col-md-12'>
                <label for='description'><strong>Descripción del caso:</strong></label>
                <textarea id='description' class='form-control' rows='3'
                          readonly><%= ticket.getDescription() %></textarea>
            </div>
            <div class='form-group col-md-12'>
                <label for='observations'><strong>Observaciones del jefe de desarrollo:</strong></label>
                <textarea id='observations' class='form-control' rows='3'
                          readonly><%= ticket.getObservations() != null ? ticket.getObservations() : "Sin observaciones..." %></textarea>
            </div>
        </div>

        <div class='row g-2'>
            <div class='form-group col-md-6'>
                <label for='created_at'><strong>Fecha de solicitud:</strong></label>
                <input type='text' id='created_at' class='form-control' value='<%= ticket.getCreated_at() %>' readonly>
            </div>
            <div class='form-group col-md-6'>
                <label for='updated_at'><strong>Fecha de entrega:</strong></label>
                <input type='text' id='updated_at' class='form-control'
                       value='<%= ticket.getDue_date() != null ? ticket.getDue_date() : "No asignada" %>' readonly>
            </div>
        </div>

        <div class='form-group'>
            <label for='logs'><strong>Bitácora:</strong></label>
            <table class='table table-striped table-bordered text-center' id='logs'> <!-- Tabla de bitácora -->
                <thead>
                <tr>
                    <th>Título</th>
                    <th>Descripción</th>
                    <th>Avance</th>
                    <th>Autor</th>
                    <th>Fecha creación</th>
                </tr>
                </thead>
                <tbody>
                <%
                    // Si no hay registros en la bitácora, mostrar mensaje
                    if (ticket.getLogs().isEmpty()) {
                %>
                <tr>
                    <td colspan='5'>No hay registros en la bitácora</td>
                </tr>
                <%
                } else {
                    // Mostrar registros de la bitácora
                    for (Map.Entry<Integer, BitacoraBean> logs : ticket.getLogs().entrySet()) {
                        BitacoraBean log = logs.getValue();
                %>
                <tr>
                    <td><%= log.getName() %>
                    </td>
                    <td><%= log.getDescription() %>
                    </td>
                    <td><%= log.getPercent() %> %
                    </td>
                    <td><%= log.getProgrammer_name() %>
                    </td>
                    <td><%= log.getCreated_at() %>
                    </td>
                </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
            <div class="d-flex justify-content-between">
                <!-- Botones de acción -->
                <%
                    // Deshabilitar los botones de accion si el ticket ya está entregado o no está listo para ser entregado
                    boolean disableButton = !(ticket_progress == 100 && (ticket.getState_id() == 4));
                %>
                <div <%= disableButton ? "hidden" : "" %>>
                    <span class="btn btn-success" data-bs-toggle="modal" data-bs-target="#processTicketModal"
                          onclick="loadTicketModal({
                                  id: <%= ticket.getId() %>,
                                  action: 'accept'
                                  })">Aceptar caso</span>
                    <span class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#processTicketModal"
                          onclick="loadTicketModal({
                                  id: <%= ticket.getId() %>,
                                  ticket_code: '<%= ticket.getCode() %>',
                                  due_date: '<%= newDate.plusWeeks(1) %>',
                                  action: 'reject'
                                  })">Rechazar caso</span>
                </div>
                <a href="/probador/index.jsp" class="btn btn-secondary">Volver</a> <!-- Botón de volver -->
            </div>
        </div>
    </form>
</main>

<!-- Modal: Procesar caso -->
<div class="modal fade" id="processTicketModal" tabindex="-1" aria-labelledby="processTicketModalLabel"
     aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="processTicketModalLabel"></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>
            <div class="modal-body" id="processTicketModalBody">
                <!-- Contenido del modal -->
            </div>
        </div>
    </div>
</div>

</body>

<script>
    function loadTicketModal(ticket) {
        if (ticket.action === 'accept') {
            document.getElementById("processTicketModalLabel").innerText = "Aceptar y finalizar caso";
            document.getElementById("processTicketModalBody").innerHTML = "<p>¿Está seguro que desea aceptar y finalizar el caso?</p>" +
                "<form action='/pbc' method='post'>" +
                "<input type='hidden' name='action' value='accept_ticket'>" +
                "<input type='hidden' name='ticket_id' value='" + ticket.id + "'>" +
                "<div class='d-flex justify-content-between'>" +
                "<button type='submit' class='btn btn-success'>Aceptar</button>" +
                "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancelar</button>" +
                "</div>" +
                "</form>";
        } else if (ticket.action === 'reject') {
            document.getElementById("processTicketModalLabel").innerText = "Rechazar y devolver caso";
            document.getElementById("processTicketModalBody").innerHTML = "<p>¿Está seguro que desea rechazar y devolver el caso?</p>" +
                "<form action='/pbc' method='post'>" +
                "<div class='form-group col-md-12'>" +
                "<label for='description'><strong>Motivo del rechazo y observaciones adicionales:</strong></label>" +
                "<textarea id='description' name='description' class='form-control' rows='3'></textarea>" +
                "</div>" +
                "<input type='hidden' name='action' value='deny_ticket'>" +
                "<input type='hidden' name='ticket_id' value='" + ticket.id + "'>" +
                "<input type='hidden' name='ticket_code' value='" + ticket.ticket_code + "'>" +
                "<input type='hidden' name='due_date' value='" + ticket.due_date + "'>" +
                "<div class='d-flex justify-content-between'>" +
                "<button type='submit' class='btn btn-danger'>Rechazar</button>" +
                "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Cancelar</button>" +
                "</div>" +
                "</form>";
        }
    }
</script>

</html>
