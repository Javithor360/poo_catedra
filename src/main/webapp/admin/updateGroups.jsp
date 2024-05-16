<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>

<%
    HttpSession currentSesion = request.getSession(false);
    UserBean user = (UserBean) currentSesion.getAttribute("user");

    if (user == null || user.getRole_id() != 0) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String groupId = request.getParameter("id");
    // Validar que el id del grupo sea un número
    if (groupId == null || groupId.isEmpty() || !groupId.matches("\\d+")) {
        response.sendRedirect("./grupos.jsp");
        return;
    }

    request.getRequestDispatcher("/adm?action=update_group&id=" + groupId).forward(request, response);
%>