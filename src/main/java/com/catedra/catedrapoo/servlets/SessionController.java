package com.catedra.catedrapoo.servlets;

import com.catedra.catedrapoo.beans.UserSessionBean;
import com.catedra.catedrapoo.models.Conexion;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "Session", urlPatterns = {"/session_handler"})
public class SessionController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Método que se encarga de manejar la lógica de la petición
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Método que se encarga de manejar la lógica de la petición
        processRequest(request, response);
    }

    private void processRequest(final HttpServletRequest request, final HttpServletResponse response) throws ServletException, IOException {
        // Creamos una sesión
        final HttpSession currentSession = request.getSession(true);

        // En base al formulario proveniente obtenemos el tipo de operación a realizar
        final String operacion = request.getParameter("operacion");

        // Si la operacion es "login" se definen las credenciales de sesión
        if(operacion.equals("login")) {
            // Parámetros obtenidos del formulario
            final String email = request.getParameter("email");
            final String password = request.getParameter("password");

            // Si las credenciales son las del administrador se redirige a la vista de superadmin
            if(email.equals("admin") && password.equals("admin")) {
                UserSessionBean admin = new UserSessionBean(0, "Administrador", "admin", null, null, 0, null);
                currentSession.setAttribute("user", admin);

                response.sendRedirect("/admin/index.jsp");
                return;
            }

            try {
                // Instancia de la clase conexión para comprobar los datos
                Conexion con = new Conexion();

                String query = "SELECT * FROM users WHERE email = \"" + email + "\" AND password = \"" + password + "\"";
                con.setRs(query);

                ResultSet rs = con.getRs();
                // Si el usuario existe en la base de datos
                if(rs.next()) {
                    // Instancia del usuario para la sesión con sus parámetros
                    UserSessionBean user = new UserSessionBean(
                            rs.getInt("id"),
                            rs.getString("name"),
                            rs.getString("email"),
                            rs.getString("gender"),
                            rs.getDate("birthday"),
                            rs.getInt("role_id"),
                            rs.getDate("created_at")
                    );
                    // Estableciendo el parámetro como atributo de la sesion
                    currentSession.setAttribute("user", user);

                    // Redirecciones en base al tipo de usuario
                    if(user.getRole_id() == 1) {
                        response.sendRedirect("jefe_desarrollo/index.jsp");
                    } else if(user.getRole_id() == 2) {
                        response.sendRedirect("programador/index.jsp");
                    } else if(user.getRole_id() == 3) {
                        response.sendRedirect("jefe_area/index.jsp");
                    } else if(user.getRole_id() == 4) {
                        response.sendRedirect("probador/index.jsp");
                    }
                } else {
                    response.sendRedirect("login.jsp");
                }

                // Cerrando la conexión con la base de datos
                rs.close();
                con.closeConnection();
            } catch (SQLException e) {
                System.out.println(e.getMessage());
            }

        } else if (operacion.equals("logout")) {
            currentSession.setAttribute("user", null);
            currentSession.invalidate();
            response.sendRedirect("login.jsp");
        }
    }
}