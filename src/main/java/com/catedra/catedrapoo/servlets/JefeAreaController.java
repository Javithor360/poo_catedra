package com.catedra.catedrapoo.servlets;

import com.catedra.catedrapoo.beans.UserSessionBean;
import com.catedra.catedrapoo.models.JefeArea;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

@WebServlet(name = "JefeAreaController", value = "/jac")
public class JefeAreaController extends HttpServlet {

    JefeArea jam = new JefeArea();

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
            UserSessionBean user = (UserSessionBean) currentSession.getAttribute("user");

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
                case "new_ticket":
                    newTicket(request, response, user.getId());
                    break;
            }
        }
    }

    private void displayTickets(final HttpServletRequest request, final HttpServletResponse response, final int boss_id) throws ServletException, IOException {
        try {
            request.setAttribute("tickets", jam.fetchOpenedTickets(boss_id));
            request.getRequestDispatcher("/jefe_area/index.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void displayTicketById(final HttpServletRequest request, final HttpServletResponse response, final int ticket_id) throws ServletException, IOException {
        try {
            request.setAttribute("ticket", jam.fetchTicketById(ticket_id)); // Se obtiene el ticket por su id y se guarda en un atributo de la petición
            request.getRequestDispatcher("/jefe_area/detail.jsp?id=" + ticket_id).forward(request, response); // Se redirige a la vista de detalle del ticket
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void newTicket(final HttpServletRequest request, final HttpServletResponse response, int boss_id) {
        try {
            String title = request.getParameter("ticketTitle");
            String description = request.getParameter("ticketDescription");

            if(title.isEmpty() || description.isEmpty()) {
                response.sendRedirect("/jefe_area/index.jsp?info=error_empty_fields");
            }

            if(jam.createNewTicket(boss_id, title, description)) {
                response.sendRedirect("/jefe_area/index.jsp?info=success_new_ticket");
            } else {
                response.sendRedirect("/jefe_area/index.jsp?info=error_new_ticket");
            }

        } catch (SQLException | IOException e) {
            e.printStackTrace();
        }
    }
}