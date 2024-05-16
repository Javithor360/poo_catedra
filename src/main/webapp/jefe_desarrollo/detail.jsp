<%@ page import="com.catedra.catedrapoo.beans.TicketBean" %>
<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.catedra.catedrapoo.beans.BitacoraBean" %>
<%@ page import="java.util.HashMap" %>
<jsp:useBean id="listNames" class="com.catedra.catedrapoo.models.JefeDesarrollo" scope="session"/>
<!-- Importar el Bean para obtener la lista de nombres -->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");
    TicketBean ticket = (TicketBean) request.getAttribute("ticket");

    // Si no hay sesión o el usuario no es un jefe de desarrollo, redirigir al login
    if (user == null || user.getRole_id() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Si no hay parámetro, redirigir al controlador
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_ticket")) {
        request.getRequestDispatcher("/jdc?action=display_ticket&ticket_id=" + request.getParameter("id")).forward(request, response);
        return;
    }

    // Si no hay ticket o el ticket no pertenece al jefe de desarrollo, redirigir al dashboard
    if (request.getParameter("id") == null || (ticket != null && !ticket.getDev_boss_name().equals(user.getName()))) {
        response.sendRedirect("/jefe_desarollo/index.jsp");
        return;
    }

    // Si no hay ticket, redirigir al dashboard
    if (ticket == null) {
        response.sendRedirect("/jefe_desarollo/index.jsp");
        return;
    }

%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Jefe de Desarrollo - Información</title>
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
    <%
        if (ticket.getPdf() != null && !ticket.getPdf().isEmpty()) {
    %>
    <a type='text' id='pdf_file' class='btn btn-primary' target='_blank' href='/flc?fileName=<%= ticket.getPdf() %>'>Descargar
        archivo de detalles</a><%
    }
%>
    <hr class="mb-3"/>
    <form action="#">
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
                <label for='fake_observations'><strong>Observaciones del jefe de desarrollo:</strong></label>
                <textarea id='fake_observations' class='form-control' rows='3'
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
                <% if (ticket.getState_id() == 1) { %>
                <button
                        type="button"
                        class="btn btn-primary justify-content-center"
                        data-bs-toggle="modal"
                        data-bs-target="#ticketModal"
                        onclick="loadTicketInfo({
                                id: <%= ticket.getId() %>,
                                code: '<%= ticket.getCode() %>',
                                title: '<%= ticket.getName() %>',
                                description: '<%= ticket.getDescription().replace("\r\n", "\\n").replace("\n", "\\n") %>',
                                observations: null,
                                requester_name: '<%= ticket.getBoss_name() %>',
                                requester_area_name: '<%= ticket.getRequester_area_name() %>',
                                pdf: '<%= ticket.getPdf() %>'
                                })"
                >
                    Procesar solicitud
                </button>
                <% } %>
                <a href="/jefe_desarrollo/index.jsp" class="btn btn-secondary">Volver</a> <!-- Botón de volver -->
            </div>
        </div>
    </form>
</main>

<!-- Modal: Mostrar información del ticket -->
<div class="modal fade" id="ticketModal" tabindex="-1" aria-labelledby="ticketModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="ticketModalLabel">Detalles del Ticket</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>
            <div class="modal-body" id="ticketModalBody">
                <!-- Aquí se mostrará la información del ticket -->
            </div>
        </div>
    </div>
</div>

<!-- Modal: Confirmación de seguimiento de caso -->
<div class="modal fade" id="acceptTicketModal" tabindex="-1" aria-labelledby="ticketModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="acceptTicketModalLabel">Confirmación de seguimiento de caso</h5>
            </div>
            <div class="modal-body" id="acceptTicketModalBody">
                <!-- Aquí se mostrará la información del ticket -->
            </div>
        </div>
    </div>
</div>

</body>

<script>
    // Función para cargar la información del ticket en el modal recibiendo el Object conteniendo la información de ticket
    function loadTicketInfo(ticket) {
        // Construir el HTML con la información del ticket
        document.getElementById("ticketModalBody").innerHTML = "<h2 class='text-center'>Información proporcionada " + ticket.code + "</h2><form>" +
            "<div class='form-group'>" +
            "<label for='code'><strong>ID:</strong></label>" +
            "<input type='text' id='code' class='form-control' value='" + ticket.id + "' readonly>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='title'><strong>Título:</strong></label>" +
            "<input type='text' id='title' class='form-control' value='" + ticket.title + "' readonly>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='description'><strong>Descripción:</strong></label>" +
            "<textarea id='description' class='form-control' rows='3' readonly>" + ticket.description + "</textarea>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='requester_name'><strong>Solicitante:</strong></label>" +
            "<input type='text' id='requester_name' class='form-control' value='" + ticket.requester_name + " (Depto de. " + ticket.requester_area_name + ")' readonly>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='pdf_file' class='mr-3'><strong>Archivos de detalles:</strong></label>" +
            (
                ticket.pdf !== "null" && ticket.pdf !== '' ?
                    "<a type='text' id='pdf_file' class='btn btn-primary'  target='_blank' href='/flc?fileName=" + ticket.pdf + "'>Descargar archivo de detalles</a>"
                    :
                    "<button type='button' class='btn btn-primary disabled' disabled>Archivo no disponible...</button>"
            ) +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='observations'><strong>Observaciones:</strong></label>" +
            "<textarea id='observations' class='form-control' rows='3' placeholder='Escribe aquí tus observaciones...'></textarea>" +
            "</div>" +
            "</form>" +
            "<div class='d-flex justify-content-center gap-2'>" +
            "<button type='button' class='btn btn-success mr-2' data-bs-toggle='modal' data-bs-target='#acceptTicketModal' onclick='validateObservations(" + JSON.stringify(ticket) + ", 10, \"accept\", " + ticket.id + ")'>Aceptar</button>" +
            "<button type='button' class='btn btn-danger mr-2' data-bs-toggle='modal' data-bs-target='#acceptTicketModal' onclick='validateObservations(" + JSON.stringify(ticket) + ", 50, \"deny\", " + ticket.id + ")'>Rechazar</button>" +
            "<button type='button' class='btn btn-info' data-bs-dismiss='modal' aria-label='Close'>Salir</button>" +
            "</div>";

        // Para los botones:
        /*
            1. Para la opción "Aceptar" y "Rechazar" se abre un modal vacío y a su vez se llama la función encargada de validar los inputs del formulario
            2. La función "validateObservations" recibe el Object del ticket, la longitud mínima de las observaciones y el tipo de acción a procesar
            3. Si las observaciones cumplen con la longitud mínima, se carga el modal con la información del ticket y las observaciones
            4. Si las observaciones no cumplen con la longitud mínima, se muestra un mensaje de error
         */
    }

    function loadConfirmTicket(ticket, type, observations, actionUrl) {
        let message; // Definir una variable para el mensaje a mostrar en el modal
        if (type === "invalid") { // Verificar si el tipo de acción es inválido
            message = "<p>Por favor, detalla las observaciones antes de continuar...</p>" +
                "<div class='d-flex justify-content-center'>" +
                "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal' aria-label='Close'>Cancelar</button>" +
                "</div>";
        } else if (type === "accept") { // Verificar si el tipo de acción es "aceptar"
            message = "<p>Completa la siguiente información para poder aceptar el caso</p><form action='/jdc' method='post'>" + // Definir el formulario con la acción a procesar
                "<div class='form-group'>" +
                "<label for='programmer'><strong>Programador asignado:</strong></label>" +
                "<select class='form-control form-select' id='programmer' name='programmer'>";

            <%
                // Iterar la lista de programadores para mostrarlos en el select
                try {
                    HashMap<Integer, String> programmers = listNames.fetchProgramerListNames(user.getId(), ticket.getId());
                    if(programmers != null && !programmers.isEmpty()) {
                        for (Map.Entry<Integer, String> programmer : programmers.entrySet()) {
            %>
            message += "<option value='<%= programmer.getKey() %>'><%= programmer.getValue() %></option>"; // Definir las opciones del select
            <%
                        }
                    } else {
            %>
            message += "<option value='' disabled>No hay programadores disponibles...</option>"; // Definir un mensaje en caso de que no haya programadores
            <%
                    }
                } catch (Exception e) {
                        e.printStackTrace();
                }
            %>
            message += "</select>" +
                "</div>" +
                "<div class='form-group'>" +
                "<label for='tester'><strong>Probador asignado:</strong></label>" +
                "<select class='form-control form-select' id='tester' name='tester'>";
            <%
                // Lo mismo para los probadores
                try {
                    HashMap<Integer, String> testers = listNames.fetchTestersListNames(ticket.getBoss_id(), ticket.getId());
                    if (testers != null && !testers.isEmpty()) {
                        for (Map.Entry<Integer, String> tester : testers.entrySet()) {
            %>
            message += "<option value='<%= tester.getKey() %>'><%= tester.getValue() %></option>";
            <%
                        }
                    } else {
            %>
            message += "<option value='' disabled>No hay probadores disponibles...</option>";
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
            message += "</select>" +
                "</div>" +
                "<div class='form-group'>" +
                "<label for='observations'><strong>Observaciones:</strong></label>" +
                "<textarea id='observations' name='observations' class='form-control' rows='3' readonly>" + observations + "</textarea>" + // Definir las observaciones traidas desde el formulario original
                "</div>" +
                "<div class='form-group'>" +
                "<label for='due_date'><strong>Fecha de entrega:</strong></label>" +
                "<input type='date' id='due_date' name='due_date' class='form-control' />" +
                "</div>" +
                "<div class='d-flex justify-content-center gap-2'>" +
                "<input type='hidden' name='id' value='" + ticket.id + "' /> " +
                "<input type='hidden' name='action' value='accept_ticket' /> " +
                "<button type='submit' class='btn btn-success mr-2'>Aceptar</button>" +
                "<button type='button' class='btn btn-secondary mr-2' data-bs-dismiss='modal' aria-label='Close'>Cancelar</button>" +
                "</div>" +
                "</form>";
        } else {
            message = "<p>¿Estás seguro que deseas rechazar este caso?</p>" +
                "<div class='d-flex justify-content-center gap-2'>" +
                "<a class='btn btn-danger mr-2 text-white' href='/jdc?action=deny_ticket&id=" + ticket.id + "&observations=" + observations + "'>Confirmar</a>" + // Definir la acción a procesar en el servlet
                "<button type='button' class='btn btn-secondary mr-2' data-bs-dismiss='modal' aria-label='Close'>Cancelar</button>" +
                "</div>";
        }

        document.getElementById("acceptTicketModalBody").innerHTML = message;
    }

    function validateObservations(ticket, length, type, ticketId) {
        let observations = document.getElementById("observations").value; // Obteniendo el campo de las observaciones

        // Verificar si las observaciones cumplen con la longitud mínima
        if (observations.length >= length) {
            /*
                Aquí se utilizan varios operadores ternarios para determinar el
                tipo de solicitud a procesar y en base a ello definir el contenido del modal
            */
            // Definiendo por medio de una variable el contenido a mostrar en el modal
            message = "<p>¿Estás seguro que deseas " + (type === "accept" ? "aceptar" : "rechazar") + " este caso?</p>" + // Definiendo el mensaje a mostrar
                "<div class='d-flex justify-content-center gap-2'>" +
                "<a " +
                "class='btn " + (type === "accept" ? "btn-success" : "btn-danger") + " mr-2 text-white' " + // Definiendo el color del botón
                "href='/jdc?action=" + (type === "accept" ? "accept_ticket" : "denny_ticket") + "'" + // Definiendo la acción a procesar en el servlet
                ">" +
                (type === "accept" ? "Confirmar" : "Rechazar") + // Definiendo el texto del botón
                "</a>" +
                "<button type='button' class='btn btn-secondary mr-2' data-bs-dismiss='modal' aria-label='Close'>Cancelar</button>" +
                "</div>";

            let actionUrl = '/jdc?action=' + (type === "accept" ? "accept_ticket" : "denny_ticket") + '&ticketId=' + ticketId;

            loadConfirmTicket(ticket, type, observations, actionUrl); // Cargando el modal con el contenido definido envando el ticket, el tipo de acción y las observaciones
        } else {
            loadConfirmTicket(null, "invalid", null, null); // Cargando el modal con un mensaje de error|
        }
    }
</script>
</html>
