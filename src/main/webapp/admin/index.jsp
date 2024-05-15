<%@ page import="com.catedra.catedrapoo.beans.UserSessionBean" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Verificar si el admin tiene una sesión activa
    HttpSession currentSession = request.getSession(false);
    UserSessionBean user = (UserSessionBean) currentSession.getAttribute("user");

    if (user == null || user.getRole_id() != 0) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Admin - Main</title>
</head>
<body>

<jsp:include page="../navbar.jsp"/>

<div class="container mt-5">
    <div class="title border-bottom">
        <h1 class="mb-4 py-1">Bienvenido, <%= user.getName() %></h1>
        <p class="small">Superusuario</p>
    </div>
    <div class="row mt-5">
        <div class="col-md-6">
            <div class="card">
                <div class="card-body align-content-center">
                    <h5 class="card-title">Gestión de usuarios</h5>
                    <p class="card-text">Crea, elimina o modifica los usuarios del sistema</p>
                    <a href="/admin/users.jsp" class="btn btn-primary">Accede aquí</a>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card">
                <div class="card-body align-content-center">
                    <h5 class="card-title">Gestión de áreas</h5>
                    <p class="card-text">Supervisa y administra la información de cada área funcional</p>
                    <a href="#" class="btn btn-primary">Registrarse ahora</a>

                </div>
            </div>
        </div>
    </div>
    <div class="row mt-3">
        <div class="col-md-6">
            <div class="card">
                <div class="card-body align-content-center">
                    <h5 class="card-title">Gestión de grupos</h5>
                    <p class="card-text">Revisa la organización de los grupos para todas las áreas</p>
                    <a href="#" class="btn btn-primary">Abrir menú</a>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card">
                <div class="card-body align-content-center">
                    <h5 class="card-title">Reportes</h5>
                    <p class="card-text">Genera y transfiere información de los casos</p>
                    <a href="#" class="btn btn-primary">Revisar productos</a>
                </div>
            </div>
        </div>
    </div>
</div>

</body>
</html>
