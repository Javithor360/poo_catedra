package com.catedra.catedrapoo.servlets;

import com.catedra.catedrapoo.beans.UserSessionBean;
import com.catedra.catedrapoo.models.Programador;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

@WebServlet(name = "ProgramadorController", value = "/pdc")
public class ProgramadorController extends HttpServlet {

    Programador pdm = new Programador();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(final HttpServletRequest request, final HttpServletResponse response) throws ServletException, IOException {
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
                case "add_log":
                    addNewLog(request, response, Integer.parseInt(request.getParameter("ticket_id")));
                    break;
                case "submit_ticket":
                    submitTicket(request, response, user.getId(), Integer.parseInt(request.getParameter("id")));
                    break;
            }
        }
    }

    private void displayTickets(final HttpServletRequest request, final HttpServletResponse response, final int programmer_id) throws ServletException, IOException {
        try {
            request.setAttribute("tickets", pdm.fetchTickets(programmer_id)); // Se obtienen los tickets del programador y se guardan en un atributo de la petición
            request.getRequestDispatcher("/programador/index.jsp").forward(request, response); // Se redirige a la vista principal del programador
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private void displayTicketById(final HttpServletRequest request, final HttpServletResponse response, final int ticket_id) throws ServletException, IOException {
        try {
            request.setAttribute("ticket", pdm.fetchTicketById(ticket_id)); // Se obtiene el ticket por su id y se guarda en un atributo de la petición
            request.getRequestDispatcher("/programador/detail.jsp?id=" + ticket_id).forward(request, response); // Se redirige a la vista de detalle del ticket
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private void addNewLog(final HttpServletRequest request, final HttpServletResponse response, final int ticket_id) throws IOException {
        try {
            // Se obtienen los datos del formulario
            String ticket_code = request.getParameter("code");
            String log_title = request.getParameter("name");
            String log_desc = request.getParameter("description");
            Float percent = Float.parseFloat(request.getParameter("percent"));
            int programmer_id = Integer.parseInt(request.getParameter("programmer_id"));

            pdm.newLog(ticket_code, log_title, log_desc, percent, programmer_id); // Se crea un nuevo log desde el Bean
            response.sendRedirect("/programador/detail.jsp?id=" + ticket_id + "&info=success_new_log"); // Se redirige a la vista de detalle del ticket con un mensaje de éxito
        } catch (SQLException e) {
            response.sendRedirect("/programador/detail.jsp?id=" + ticket_id + "&info=error_new_log"); // Se redirige a la vista de detalle del ticket con un mensaje de error
        }
    }

    private void submitTicket(final HttpServletRequest request, final HttpServletResponse response, final int programmer_id, final int ticket_id) throws IOException {
        try {
            pdm.submitTicket(ticket_id, programmer_id); // Se envía el ticket al Bean para que lo marque como enviado
            response.sendRedirect("/programador/detail.jsp?id=" + ticket_id + "&info=success_submit_ticket"); // Se redirige a la vista de detalle del ticket con un mensaje de éxito
        } catch (SQLException e) {
            response.sendRedirect("/programador/detail.jsp?id=" + request.getParameter("id") + "&info=error_submit_ticket"); // Se redirige a la vista de detalle del ticket con un mensaje de error
        }
    }
}