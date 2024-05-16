package com.catedra.catedrapoo.servlets;

import com.catedra.catedrapoo.beans.UserBean;
import com.catedra.catedrapoo.models.Probador;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

@WebServlet(name = "ProbadorController", value = "/pbc")
public class ProbadorController extends HttpServlet {

    Probador pbm = new Probador();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest (final HttpServletRequest request, final HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            // Corroborando si se envió una acción
            if(request.getParameter("action") == null) {
                return;
            }

            HttpSession currentSession = request.getSession(false);
            UserBean user = (UserBean) currentSession.getAttribute("user");

            // Capturando el valor de la acción
            String action = request.getParameter("action");

            // En base a la acción se ejecuta un método u otro
            switch (action) {
                case "display_tickets":
                    displayTickets(request, response, user.getId());
                    break;
                case "display_ticket":
                    displayTicketById(request, response, Integer.parseInt(request.getParameter("id")));
                    break;
                case "accept_ticket":
                    acceptTicket(request, response, user.getId());
                    break;
                case "deny_ticket":
                    denyTicket(request, response, user.getId());
                    break;
            }
        }
    }

    private void displayTickets(final HttpServletRequest request, final HttpServletResponse response, final int tester_id) throws ServletException, IOException {
        try {
            request.setAttribute("tickets", pbm.fetchTesterTickets(tester_id));
            request.getRequestDispatcher("/probador/index.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void displayTicketById(final HttpServletRequest request, final HttpServletResponse response, final int ticket_id) throws ServletException, IOException {
        try {
            request.setAttribute("ticket", pbm.fetchTicketById(ticket_id)); // Se obtiene el ticket por su id y se guarda en un atributo de la petición
            request.getRequestDispatcher("/probador/detail.jsp?id=" + ticket_id).forward(request, response); // Se redirige a la vista de detalle del ticket
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private void acceptTicket(final HttpServletRequest request, final HttpServletResponse response, final int tester_id) throws ServletException, IOException {
        int ticket_id = Integer.parseInt(request.getParameter("ticket_id"));
        boolean result = pbm.updateStateTicket(7, ticket_id, null, tester_id, null, null);

        System.out.println(result);

        if(result) {
            response.sendRedirect("/probador/detail.jsp?id=" + ticket_id + "&info=success_accept_ticket");
        } else {
            response.sendRedirect("/probador/detail.jsp?id=" + ticket_id + "&info=error_accept_ticket");
        }

        System.out.println("Hola?");
    }

    private void denyTicket(final HttpServletRequest request, final HttpServletResponse response, final int tester_id) throws ServletException, IOException {
        int ticket_id = Integer.parseInt(request.getParameter("ticket_id"));
        String ticket_code = request.getParameter("ticket_code");
        String description = request.getParameter("description");
        String due_date = request.getParameter("due_date");

        System.out.println(description);

        if(description.length() < 50) {
            response.sendRedirect("/probador/detail.jsp?id=" + ticket_id + "&info=error_empty_fields");
            return;
        }

        if(pbm.updateStateTicket(6, ticket_id, ticket_code, tester_id, description, due_date)) {
            response.sendRedirect("/probador/detail.jsp?id=" + ticket_id + "&info=success_deny_ticket");
        } else {
            response.sendRedirect("/probador/detail.jsp?id=" + ticket_id + "&info=error_deny_ticket");
        }
    }
}