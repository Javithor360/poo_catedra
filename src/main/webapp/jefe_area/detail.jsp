<%@ page import="com.catedra.catedrapoo.beans.TicketBean" %>
<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.catedra.catedrapoo.beans.BitacoraBean" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Obtener la sesión actual
    HttpSession currentSession = request.getSession(false);
    UserBean user = (UserBean) currentSession.getAttribute("user");
    TicketBean ticket = (TicketBean) request.getAttribute("ticket");

    // Si no hay sesión o el usuario no es un jefe de area, redirigir al login
    if (user == null || user.getRole_id() != 3) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Si no hay ticket, redirigir al dashboard
    String actionParam = request.getParameter("action");
    if (actionParam == null || !actionParam.equals("display_ticket")) {
        request.getRequestDispatcher("/jac?action=display_ticket&ticket_id=" + request.getParameter("id")).forward(request, response);
        return;
    }

    // Si no hay ticket o el ticket no pertenece al jefe de area, redirigir al dashboard
    if (request.getParameter("id") == null || (ticket != null && !ticket.getBoss_name().equals(user.getName()))) {
        response.sendRedirect("/jefe_area/index.jsp");
        return;
    }

    // Si no hay ticket, redirigir al dashboard
    if(ticket == null) {
        response.sendRedirect("/jefe_area/index.jsp");
        return;
    }
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
                <input type='text' id='tester' class='form-control' value='<%= ticket.getTester_name() != null ? ticket.getTester_name() : "No asignado" %>' readonly>
            </div>
            <div class='form-group col-md-6'>
                <label for='programmer'><strong>Programador:</strong></label>
                <input type='text' id='programmer' class='form-control' value='<%= ticket.getProgrammer_name() != null ? ticket.getProgrammer_name() : "No asignado" %>'
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
                <input type='text' id='updated_at' class='form-control' value='<%= ticket.getDue_date() != null ? ticket.getDue_date() : "No asignada" %>' readonly>
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
                <a href="/jefe_area/index.jsp" class="btn btn-secondary">Volver</a> <!-- Botón de volver -->
            </div>
        </div>
    </form>
</main>

</body>
</html>
