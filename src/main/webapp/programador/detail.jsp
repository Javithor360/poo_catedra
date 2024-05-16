<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page import="com.catedra.catedrapoo.beans.TicketBean" %>
<%@ page import="com.catedra.catedrapoo.beans.BitacoraBean" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");
    TicketBean ticket = (TicketBean) request.getAttribute("ticket");

    // Si no hay sesión o el usuario no es un programador, redirigir al login
    if (user == null || user.getRole_id() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Si no hay ticket o el ticket no pertenece al programador, redirigir al dashboard
    if (request.getParameter("id") == null || (ticket != null && ticket.getProgrammer_id() != user.getId())) {
        response.sendRedirect("/programador/index.jsp");
        return;
    }

    // Si no hay ticket, redirigir al dashboard
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_ticket")) {
        request.getRequestDispatcher("/pdc?action=display_ticket&ticket_id=" + request.getParameter("id")).forward(request, response);
        return;
    }

    // Si no hay ticket, redirigir al dashboard
    if(ticket == null) {
        response.sendRedirect("/programador/index.jsp");
        return;
    }

    // Mensajes de información recibidos de la petición
    if (request.getParameter("info") != null) {
        if (request.getParameter("info").equals("success_new_log")) {
            request.setAttribute("info", "El registro de bitácora ha sido guardado con éxito");
        } else if (request.getParameter("info").equals("error_new_log")) {
            request.setAttribute("info", "Ha ocurrido un error al guardar el registro de bitácora");
        } else if (request.getParameter("info").equals("success_submit_ticket")) {
            request.setAttribute("info", "El caso ha sido entregado con éxito");
        } else if (request.getParameter("info").equals("error_submit_ticket")) {
            request.setAttribute("info", "Ha ocurrido un error al entregar el caso");
        }
    }

    // Obtener el progreso del ticket una vez el ticket esté definido
    double ticket_progress = ticket.get_latest_percent(ticket);
%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Programador - Información</title>
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
        if(ticket.getPdf() != null && !ticket.getPdf().isEmpty()){
    %>
            <a type='text' id='pdf_file' class='btn btn-primary'  target='_blank' href='/flc?fileName=<%= ticket.getPdf() %>'>Descargar archivo de detalles</a><%
        }
    %>
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
                <input type='text' id='tester' class='form-control' value='<%= ticket.getTester_name() %>' readonly>
            </div>
            <div class='form-group col-md-6'>
                <label for='programmer'><strong>Programador:</strong></label>
                <input type='text' id='programmer' class='form-control' value='<%= ticket.getProgrammer_name() %>'
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
                          readonly><%= ticket.getObservations() %></textarea>
            </div>
        </div>

        <div class='row g-2'>
            <div class='form-group col-md-6'>
                <label for='created_at'><strong>Fecha de solicitud:</strong></label>
                <input type='text' id='created_at' class='form-control' value='<%= ticket.getCreated_at() %>' readonly>
            </div>
            <div class='form-group col-md-6'>
                <label for='updated_at'><strong>Fecha de entrega:</strong></label>
                <input type='text' id='updated_at' class='form-control' value='<%= ticket.getDue_date() %>' readonly>
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
                <a href="/programador/index.jsp" class="btn btn-secondary">Volver</a> <!-- Botón de volver -->
                <div class="text-center">
                    <input type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addLogModal"
                           value="Agregar nuevo registro" <%= ticket_progress < 100 ? "" : "disabled hidden" %>
                           onclick="loadLogForm({
                                   ticket_id: <%= ticket.getId() %>,
                                   programmer_id: <%= user.getId() %>,
                                   ticket_code: '<%= ticket.getCode() %>',
                                   programmer_name: '<%= user.getName() %>'
                                   })"
                    /> <!-- Botón de agregar nuevo registro -->
                </div>
                <%
                    // Deshabilitar botón de entregar caso si el ticket ya está entregado o no está listo para ser entregado
                    boolean disableButton = (ticket_progress == 100 && ticket.getState_id() != 3 && ticket.getState_id() != 6) ||
                            (ticket_progress != 100 && (ticket.getState_id() == 3 || ticket.getState_id() == 6));
                %>

                <input type="button" value="Entregar caso" class="btn btn-warning"
                       data-bs-toggle="modal" data-bs-target="#extraModal"
                        <%= disableButton ? "disabled" : "" %>
                       onclick="loadSubmitTicket({
                               ticket_id: <%= ticket.getId() %>,
                               ticket_code: '<%= ticket.getCode() %>'
                               })"
                /> <!-- Botón de entregar caso -->
            </div>
        </div>
    </form>
</main>

<!-- Modal: Agregar nuevo registro de bitácora -->
<div class="modal fade" id="addLogModal" tabindex="-1" aria-labelledby="addLogModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="addLogModalLabel">Agregar nuevo registro de bitácora</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>
            <div class="modal-body" id="addLogModalBody">
                <!-- Contenido del modal -->
            </div>
        </div>
    </div>
</div>

<!-- Modal: Manejo de errores -->
<div class="modal fade" id="extraModal" tabindex="-1" aria-labelledby="extraModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="extraModalLabel">Atención</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>
            <div class="modal-body" id="extraModalBody">
                <!-- Contenido del modal -->
            </div>
        </div>
    </div>
</div>

</body>

<script>
    // Funciones para cargar contenido en los modales
    function loadLogForm(ticket_info) { // Cargar formulario de nuevo registro de bitácora que recibe información del ticket en un Object
        document.getElementById("addLogModalBody").innerHTML = "<p>Completa todos los campos para guardar el registro</p>" +
            "<form onsubmit='return validateForm()' action='/pdc' method='post'>" + // Formulario de nuevo registro de bitácora donde el evento onsubmit valida los campos y si to.do está correcto, envía la petición al servlet
            "<div class='row g-2'>" +
            "<div class='form-group col-md-6'>" +
            "<label for='ticket_code'><strong>Ticket:</strong></label>" +
            "<input type='text' id='ticket_code' class='form-control' value='" + ticket_info.ticket_code + "' readonly>" +
            "</div>" +
            "<div class='form-group col-md-6'>" +
            "<label for='author'><strong>Autor:</strong></label>" +
            "<input type='text' id='author' class='form-control' value='" + ticket_info.programmer_name + "' readonly>" +
            "</div>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='name'><strong>Título</strong></label>" +
            "<input type='text' class='form-control' id='name' name='name' placeholder='Ingresa el título...' required>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='bdescription'><strong>Descripción</strong></label>" +
            "<textarea class='form-control' id='bdescription' name='description' placeholder='Ingresa la descripción...' required>" +
            "</textarea>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='percent'><strong>Porcentaje de avance</strong></label>" +
            "<input type='number' min='0.00' max='100.00' step='0.01' class='form-control' id='percent' name='percent' placeholder='0' required />" +
            "</div>" +
            "<div class='d-flex justify-content-center'>" +
            "<input type='hidden' name='ticket_id' value='" + ticket_info.ticket_id + "' />" + // Campos ocultos con información del ticket
            "<input type='hidden' name='code' value='" + ticket_info.ticket_code + "' />" +
            "<input type='hidden' name='programmer_id' value='" + ticket_info.programmer_id + "' />" +
            "<input type='hidden' name='action' value='add_log' />" +
            "<input type='submit' class='btn btn-success mr-4' value='Guardar' />" +
            "<button type='button' class='btn btn-info' data-bs-dismiss='modal' aria-label='Close'>Salir</button>" +
            "</div>" +
            "</form>";
    }

    function validateForm() {
        // Validar campos del formulario de nuevo registro de bitácora
        let title = document.getElementById("name").value;
        let description = document.getElementById("bdescription").value;
        let percent = document.getElementById("percent").value;

        // Mostrar mensaje de error si los campos no están completos o no cumplen con las condiciones
        if (title === "" || description === "" || percent === "") {
            showErrorModal("Por favor, completa todos los campos.");
            return false;
        } else if (percent < 0 || percent > 100) {
            showErrorModal("El porcentaje de avance debe ser un número entre 0 y 100.");
            return false;
        } else if (title.length < 10 || description.length < 50) {
            showErrorModal("El título debe tener al menos 10 caracteres y la descripción 50.");
            return false;
        }

        // Si to.do está correcto, retornar true
        return true;
    }

    function showErrorModal(mensaje) {
        // Mostrar modal de error con el mensaje recibido
        let errorModalBody = document.getElementById('extraModalBody');
        errorModalBody.innerHTML = "<p>" + mensaje + "</p>";

        // Ocultar modal actual y mostrar modal de error
        let currentModal = bootstrap.Modal.getInstance(document.getElementById('addLogModal'));
        currentModal.hide();

        // Mostrar modal de error
        let errorModal = new bootstrap.Modal(document.getElementById('extraModal'));
        errorModal.show();
    }

    function loadSubmitTicket(ticket_info) {
        // Cargar modal de confirmación de entrega de caso
        document.getElementById("extraModalBody").innerHTML = "<p>¿Estás seguro que deseas entregar el caso <strong>" + ticket_info.ticket_code + "</strong>? Ten en cuenta que ya no podrás realizar modificaciones...</p>" +
            "<a href='/pdc?action=submit_ticket&id=" + ticket_info.ticket_id + "' class='btn btn-success mr-3'>Entregar</a>" + // Botón de entregar caso que redirige al servlet con la acción de entregar el caso
            "<button type='button' class='btn btn-secondary mr-3' data-bs-dismiss='modal' aria-label='Close'>Cancelar</button>";
    }
</script>

</html>
