<%@ page import="com.catedra.catedrapoo.beans.UserSessionBean" %>
<%@ page import="com.catedra.catedrapoo.beans.TicketBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.catedra.catedrapoo.beans.BitacoraBean" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserSessionBean user = (UserSessionBean) currentSession.getAttribute("user");

    // Verificar si el usuario es un jefe de desarrollo
    if (user == null || user.getRole_id() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Verificar si el parámetro "action" ya está presente en la URL
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_all_tickets")) {
        // Redirigir al servlet con el parámetro "action"
        request.getRequestDispatcher("/jdc?action=display_all_tickets").forward(request, response);
        return;
    }
%>

<html>
<head>
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Jefe de Desarrollo - Supervisar</title>
</head>
<body>

<!-- Incluir componente de navbar -->
<jsp:include page="../navbar.jsp"/>

<main class="container mt-3">
    <div>
        <h1>Bienvenido <%= user.getName() %>
        </h1>
        <p class="small"> Jefe de Desarrollo</p>
        <hr />
    </div>
    <div>
        <h3>Registro de casos aperturados</h3>
        <div class="table-container">
            <table class="table table-striped table-bordered text-center">
                <thead>
                <tr>
                    <th>Código</th>
                    <th>Estado</th>
                    <th>Solicitante</th>
                    <th>Título</th>
                    <th>Fecha de solicitud</th>
                    <th>Acción</th>
                </tr>
                </thead>
                <tbody>
                <%
                    // Obtener los tickets de la solicitud enviados por la petición
                    HashMap<String, TicketBean> all_tickets = (HashMap<String, TicketBean>) request.getAttribute("all_tickets");
                    if (all_tickets == null || all_tickets.isEmpty()) {
                %>
                <tr>
                    <td colspan="5">No hay registro casos aperturados</td>
                </tr>
                <%
                } else {
                    // Iterar sobre los tickets y mostrarlos en la tabla
                    for (TicketBean ticket : all_tickets.values()) {
                        /*
                            Método para convertir las iteraciones del HashMap con
                            las Bitácoras a un array de objetos en JavaScript
                         */

                        // Inicializar el StringBuilder para el array de bitácoras
                        StringBuilder logsArray = new StringBuilder("[");
                        // Empezando la iteración de las bitácoras
                        for (Map.Entry<Integer, BitacoraBean> log : ticket.getLogs().entrySet()) {
                            // Por cada iteración se añade un objeto al array empezando con "{"
                            logsArray.append("{")
                                    // Por cada iteración se añade una propiedad del objeto, importante escapar las comillas dobles para respetar el formato JSON
                                    .append("\"id\": \"").append(log.getValue().getId()).append("\",")
                                    .append("\"code_ticket\": \"").append(log.getValue().getCode()).append("\",")
                                    .append("\"name\": \"").append(log.getValue().getName()).append("\",")
                                    .append("\"description\": \"").append(log.getValue().getDescription().replace("\r\n", "\\n")).append("\",")
                                    .append("\"percent\": \"").append(log.getValue().getPercent()).append("\",")
                                    .append("\"programmer_name\": \"").append(log.getValue().getProgrammer_name()).append("\",")
                                    .append("\"created_at\": \"").append(log.getValue().getCreated_at()).append("\"")
                                    .append("},");
                        }
                        // Verificar si el array de bitácoras no está vacío
                        if (logsArray.charAt(logsArray.length() - 1) == ',') {
                            logsArray.deleteCharAt(logsArray.length() - 1); // En caso de que no, eliminar la última coma
                        }
                        // Cerrar el array de bitácoras
                        logsArray.append("]");

                        // Reemplazar los saltos de línea por "\n" para evitar errores en el HTML
                        String description = ticket.getDescription().replace("\r\n", "\\n");
                        String observations = ticket.getObservations().replace("\r\n", "\\n");
                %>
                <tr>
                    <!-- Imprimiendo los demás datos de la iteración -->
                    <td><%= ticket.getCode() %>
                    </td>
                    <td><%= ticket.getState() %>
                    </td>
                    <td><%= ticket.getBoss_name() %>
                    </td>
                    <td><%= ticket.getName() %>
                    </td>
                    <td><%= ticket.getCreated_at() %>
                    </td>
                    <td>
                        <!--
                            1. Al hacer clic en el botón, se ejecutará la función "loadTicketInfo" con los datos del ticket
                            2. Se abrirá el modal con la información del ticket
                            ------
                            Cabe mencionar que los datos del ticket se pasan como un objeto de JavaScript, además de que
                            propiedades como description, observations y logsArray se pasan como strings para evitar errores
                        -->
                        <button
                                class="btn btn-primary justify-content-center"
                                data-bs-toggle="modal"
                                data-bs-target="#ticketModal"
                                onclick='loadTicketInfo({
                                        id: <%= ticket.getId() %>,
                                        code: "<%= ticket.getCode() %>",
                                        state: "<%= ticket.getState() %>",
                                        title: "<%= ticket.getName() %>",
                                        description: "<%= description %>",
                                        logs: <%= logsArray.toString() %>,
                                        observations: "<%= observations %>",
                                        requester_name: "<%= ticket.getBoss_name() %>",
                                        requester_area_name: "<%= ticket.getRequester_area_name() %>",
                                        dev_boss_name: "<%= ticket.getDev_boss_name() %>",
                                        programmer_name: "<%= ticket.getProgrammer_name() != null ? ticket.getProgrammer_name() : "No asignado" %>",
                                        tester_name: "<%= ticket.getTester_name() != null ? ticket.getTester_name() : "No asignado" %>",
                                        created_at: "<%= ticket.getCreated_at() %>",
                                        due_date: "<%= ticket.getDue_date() != null ? ticket.getDue_date() : "No asignada" %>",
                                        })'
                        >
                            Ver detalles
                        </button>
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

<!-- Modal: Mostrar información del ticket -->
<div class="modal fade" id="ticketModal" tabindex="-1" aria-labelledby="ticketModalLabel" aria-hidden="true">
    <div class="modal-dialog" style="max-width: 800px;">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="ticketModalLabel">Detalles del caso</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>
            <div class="modal-body" id="ticketModalBody">
                <!-- Aquí se mostrará la información del ticket -->
            </div>
        </div>
    </div>
</div>

</body>

<script>
    // Función para cargar la información del ticket en el modal
    function loadTicketInfo(ticket) {
        let logs; // Variable para almacenar las bitácoras del ticket

        if (ticket.logs.length === 0) {
            logs = "<tr><td colspan='5'>No hay bitácoras registradas</td></tr>"; // En caso de que no haya bitácoras
        } else {
            // Iterar sobre las bitácoras y construir el HTML
            logs = ticket.logs.map(log => {
                return "<tr>" +
                    "<td>" + log.name + "</td>" +
                    "<td>" + log.description + "</td>" +
                    "<td>" + log.percent + "%</td>" +
                    "<td>" + log.programmer_name + "</td>" +
                    "<td>" + log.created_at + "</td>" +
                    "</tr>";
            }).join("");
        }
        // Construir el HTML con la información del ticket
        document.getElementById("ticketModalBody").innerHTML = "<form>" + // Formulario para mostrar los datos
            "<div class='row g-2'>" +
            "<div class='form-group col-md-4'>" +
            "<label for='id'><strong>ID:</strong></label>" +
            "<input type='text' id='id' class='form-control' value='" + ticket.id + "' readonly>" + // Campos de solo lectura
            "</div>" +
            "<div class='form-group col-md-4'>" +
            "<label for='code'><strong>Código:</strong></label>" +
            "<input type='text' id='code' class='form-control' value='" + ticket.code + "' readonly>" +
            "</div>" +
            "<div class='form-group col-md-4'>" +
            "<label for='state'><strong>Estado:</strong></label>" +
            "<input type='text' id='state' class='form-control' value='" + ticket.state + "' readonly>" +
            "</div>" +
            "</div>" +
            "<div class='row g-2'>" +
            "<div class='form-group col-md-6'>" +
            "<label for='requester'><strong>Solicitante:</strong></label>" +
            "<input type='text' id='requester' class='form-control' value='" + ticket.requester_name + " (Depto de. " + ticket.requester_area_name + ")' readonly>" +
            "</div>" +
            "<div class='form-group col-md-6'>" +
            "<label for='tester'><strong>Probador:</strong></label>" +
            "<input type='text' id='tester' class='form-control' value='" + ticket.tester_name + "' readonly>" +
            "</div>" +
            "<div class='form-group col-md-6'>" +
            "<label for='programmer'><strong>Programador:</strong></label>" +
            "<input type='text' id='programmer' class='form-control' value='" + ticket.programmer_name + "' readonly>" +
            "</div>" +
            "<div class='form-group col-md-6'>" +
            "<label for='boss'><strong>Jefe de desarrollo:</strong></label>" +
            "<input type='text' id='boss' class='form-control' value='" + ticket.dev_boss_name + "' readonly>" +
            "</div>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='title'><strong>Título:</strong></label>" +
            "<input type='text' id='title' class='form-control' value='" + ticket.title + "' readonly>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='description'><strong>Descripción del caso:</strong></label>" +
            "<textarea id='description' class='form-control' rows='3' readonly>" + ticket.description + "</textarea>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='observations'><strong>Observaciones del jefe de desarrollo:</strong></label>" +
            "<textarea id='observations' class='form-control' rows='3' readonly>" + ticket.observations + "</textarea>" +
            "</div>" +
            "<div class='row g-2'>" +
            "<div class='form-group col-md'>" +
            "<label for='created_at'><strong>Fecha de solicitud:</strong></label>" +
            "<input type='text' id='created_at' class='form-control' value='" + ticket.created_at + "' readonly>" +
            "</div>" +
            "<div class='form-group col-md'>" +
            "<label for='due_date'><strong>Fecha de entrega:</strong></label>" +
            "<input type='text' id='due_date' class='form-control' value='" + ticket.due_date + "' readonly>" +
            "</div>" +
            "</div>" +
            "<div class='form-group'>" +
            "<label for='logs'><strong>Bitácora:</strong></label>" +
            "<table class='table table-striped table-bordered text-center' id='logs'>" + // Tabla para mostrar las bitácoras
            "<thead>" +
            "<tr>" +
            "<th>Título</th>" +
            "<th>Descripción</th>" +
            "<th>Avance</th>" +
            "<th>Autor</th>" +
            "<th>Fecha creación</th>" +
            "</tr>" +
            "</thead>" +
            "<tbody>" +
            logs + // Insertar las bitácoras obtenidas de la iteración principal
            "</tbody>" +
            "</table>" +
            "</div>" +
            "</form>" +
            "<div class='d-flex justify-content-center gap-2'>" +
            "<button type='button' class='btn btn-info' data-bs-dismiss='modal' aria-label='Close'>Regresar</button>" +
            "</div>";
    }
</script>

</html>
