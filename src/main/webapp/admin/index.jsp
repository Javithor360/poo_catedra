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

<main class="container mt-3">
    <div>
        <h1>Bienvenido <%= user.getName() %>
        </h1>
        <p class="small"> Admin</p>
    </div>

    <hr />
</main>

</body>
</html>
