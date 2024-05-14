<%@ page import="com.catedra.catedrapoo.beans.UserSessionBean" %>
<%@ page import="java.util.Objects" %>
<%@ page import="com.catedra.catedrapoo.beans.TicketBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="listNames" class="com.catedra.catedrapoo.models.JefeDesarrollo" scope="session" /> <!-- Importar el Bean para obtener la lista de nombres -->

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserSessionBean user = (UserSessionBean) currentSession.getAttribute("user");

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
                        <!--
                            1. Un botón que permite interactuar con el ticket
                            2. Al darle click se abre un modal con la información del ticket
                            3. El evento "onclick" envía un Object de Javascript con los datos del ticket iterado
                            4. Revisar la etiqueta script para darle seguimiento
                        -->
                        <button
                                class="btn btn-primary justify-content-center"
                                data-bs-toggle="modal"
                                data-bs-target="#ticketModal"
                                onclick="loadTicketInfo({
                                        id: <%= ticket.getId() %>,
                                        code: '<%= ticket.getCode() %>',
                                        title: '<%= ticket.getName() %>',
                                        description: '<%= ticket.getDescription() %>',
                                        observations: null,
                                        requester_name: '<%= ticket.getBoss_name() %>',
                                        requester_area_name: '<%= ticket.getRequester_area_name() %>'
                                        })"
                        >
                            Ver más
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
        document.getElementById("ticketModalBody").innerHTML = "<h2 class='text-center'>Solicitud del caso " + ticket.code + "</h2><form>" +
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
            "<label for='observations'><strong>Observaciones:</strong></label>" +
            "<textarea id='observations' class='form-control' rows='3' placeholder='Escribe aquí tus observaciones...'></textarea>" +
            "</div>" +
            "</form>" +
            "<div class='d-flex justify-content-center gap-2'>" +
            "<button type='button' class='btn btn-success mr-2' data-bs-toggle='modal' data-bs-target='#acceptTicketModal' onclick='validateObservations(" + JSON.stringify(ticket) + ", 10, \"accept\")'>Aceptar</button>" +
            "<button type='button' class='btn btn-danger mr-2' data-bs-toggle='modal' data-bs-target='#acceptTicketModal' onclick='validateObservations(" + JSON.stringify(ticket) + ", 50, \"deny\")'>Rechazar</button>" +
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

    function loadConfirmTicket(ticket, type, observations) {
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
                    for (Map.Entry<Integer, String> programmer : listNames.fetchProgramerListNames(user.getId(), 1).entrySet()) {
            %>
            message += "<option value='<%= programmer.getKey() %>'><%= programmer.getValue() %></option>"; // Definir las opciones del select
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
                    for (Map.Entry<Integer, String> tester : listNames.fetchTestersListNames(user.getId(), 1).entrySet()) {
            %>
            message += "<option value='<%= tester.getKey() %>'><%= tester.getValue() %></option>";
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

    function validateObservations(ticket, length, type) {
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
            loadConfirmTicket(ticket, type, observations); // Cargando el modal con el contenido definido envando el ticket, el tipo de acción y las observaciones
        } else {
            loadConfirmTicket(null, "invalid", null); // Cargando el modal con un mensaje de error|
        }
    }
</script>

</html>
