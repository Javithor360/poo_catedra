package com.catedra.catedrapoo.servlets;

import com.catedra.catedrapoo.beans.UserBean;
import com.catedra.catedrapoo.models.JefeArea;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.time.Year;
import java.util.Random;

@WebServlet(name = "JefeAreaController", value = "/jac")
@MultipartConfig // Config necesaria para recibir los datos de un formulario enctype='multipart/form-data'
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
            String code = generateNewCode(boss_id);


            // Manejo de archivo adjuntado
            Part filePart = request.getPart("ticketFile"); // Solicitando el archivo a tratar
            String fileName = "";

            if(filePart != null && filePart.getSize() > 0) {
                fileName = code + ".pdf";
                String storagePath = getServletContext().getRealPath("/storage");


                // Verificar si el directorio "storage" existe
                File storageDir = new File(storagePath);
                if(!storageDir.exists()) {
                    // Si no existe, se crea
                    if (!storageDir.mkdir()) {
                        // Si no se puede crear el directorio, maneja el error
                        throw new IOException("No se pudo crear el directorio de almacenamiento");
                    }
                }

                // Construir la ruta completa para guardar el archivo
                String filePath = storagePath + File.separator + fileName;

                // Guardar el archivo en el servidor
                filePart.write(filePath);
            }


            if(title.isEmpty() || description.isEmpty()) {
                response.sendRedirect("/jefe_area/index.jsp?info=error_empty_fields");
            }

            if(jam.createNewTicket(boss_id, title, description, code, fileName)) {
                response.sendRedirect("/jefe_area/index.jsp?info=success_new_ticket");
            } else {
                response.sendRedirect("/jefe_area/index.jsp?info=error_new_ticket");
            }

        } catch (SQLException | ServletException | IOException e) {
            System.out.println(e.getMessage());
            e.printStackTrace();
        }
    }

    public String generateNewCode(int user_id) throws SQLException{
        Random ran = new Random();
        String prefix = JefeArea.getAreaPrefixCode(user_id);
        String year = String.valueOf(Year.now());
        String num = String.valueOf(ran.nextInt(999 - 100 + 1) + 100);

        return prefix+year+num;
    }
}