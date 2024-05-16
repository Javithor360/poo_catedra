package com.catedra.catedrapoo.servlets;

import com.catedra.catedrapoo.beans.UserBean;
import com.catedra.catedrapoo.models.JefeDesarrollo;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet(name = "JefeDesarrolloController", urlPatterns = {"/jdc"})
public class JefeDesarrolloController extends HttpServlet {

    JefeDesarrollo jdm = new JefeDesarrollo();

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
            UserBean user = (UserBean) currentSession.getAttribute("user");

            // Capturando el valor de la acción
            String action = request.getParameter("action");

            // En base a la acción se ejecuta un método u otro
            switch (action) {
                case "display_new_tickets":
                    displayNewTickets(request, response, user.getId());
                    break;
                case "display_all_tickets":
                    displayAllTickets(request, response, user.getId());
                    break;
                case "display_ticket":
                    displayTicket(request, response);
                    break;
                case "accept_ticket":
                    acceptTicket(request, response, user.getId());
                    break;
                case "deny_ticket":
                    denyTicket(request, response, user.getId());
                    break;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private void displayNewTickets(final HttpServletRequest request, final HttpServletResponse response, final int dev_boss_id) throws SQLException {
        try {
            // Creando un atributo donde su contenido será el resultado devuelto por el modelo
            request.setAttribute("new_tickets", jdm.fetchNewTickets(dev_boss_id));
            // Redirigiendo a la vista correspondiente para mostrar los datos en pantalla
            request.getRequestDispatcher("/jefe_desarrollo/index.jsp").forward(request, response);
        } catch (ServletException | IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void displayAllTickets(final HttpServletRequest request, final HttpServletResponse response, final int dev_boss_id) throws SQLException {
        try {
            // Creando un atributo donde su contenido será el resultado devuelto por el modelo
             request.setAttribute("all_tickets", jdm.fetchAllTickets(dev_boss_id));

            // Redirigiendo a la vista correspondiente para mostrar los datos en pantalla
            request.getRequestDispatcher("/jefe_desarrollo/supervise.jsp").forward(request, response);
        } catch (ServletException | IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void displayTicket(final HttpServletRequest request, final HttpServletResponse response) throws SQLException {
        try {
            // Creando un atributo donde su contenido será el resultado devuelto por el modelo
            request.setAttribute("ticket", jdm.fetchTicketById(Integer.parseInt(request.getParameter("id"))));

            // Redirigiendo a la vista correspondiente para mostrar los datos en pantalla
            request.getRequestDispatcher("/jefe_desarrollo/detail.jsp").forward(request, response);
        } catch (ServletException | IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void acceptTicket(final HttpServletRequest request, final HttpServletResponse response, int dev_boss_id) throws IOException {
        try {
            // Validando la fecha de vencimiento
            String dueDateString = request.getParameter("due_date");
            Date dueDate = new SimpleDateFormat("yyyy-MM-dd").parse(dueDateString);

            if (dueDateString == null || dueDate.compareTo(new Date()) <= 0) {
                response.sendRedirect("/dev_boss/index.jsp?info=error_accept_ticket");
                return;
            }

            // Aceptando el ticket
            jdm.acceptTicket(
                    Integer.parseInt(request.getParameter("id")),
                    Integer.parseInt(request.getParameter("programmer")),
                    Integer.parseInt(request.getParameter("tester")),
                    dev_boss_id,
                    request.getParameter("observations"),
                    request.getParameter("due_date")
            );

            response.sendRedirect("/jefe_desarrollo/index.jsp?info=success_accept_ticket"); // Redirigiendo a la vista principal del jefe de desarrollo
        } catch(SQLException | IOException | ParseException e) {
            response.sendRedirect("/jefe_desarrollo/index.jsp?info=error_accept_ticket"); // Redirigiendo a la vista principal del jefe de desarrollo
        }
    }

    private void denyTicket(final HttpServletRequest request, final HttpServletResponse response, int dev_boss_id) throws SQLException, IOException {
        try {
            // Denegando el ticket
            jdm.denyTicket(
                    Integer.parseInt(request.getParameter("id")),
                    dev_boss_id,
                    request.getParameter("observations")
            );

            // Redirigiendo a la vista principal del jefe de desarrollo
            response.sendRedirect("/jefe_desarrollo/index.jsp?info=success_deny_ticket");
        } catch(Exception e) {
            response.sendRedirect("/jefe_desarrollo/index.jsp?info=error_deny_ticket"); // Redirigiendo a la vista principal del jefe de desarrollo
        }
    }
}