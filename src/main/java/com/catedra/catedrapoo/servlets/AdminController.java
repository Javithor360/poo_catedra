package com.catedra.catedrapoo.servlets;

import com.catedra.catedrapoo.beans.GroupBean;
import com.catedra.catedrapoo.beans.UserBean;
import com.catedra.catedrapoo.models.Admin;
import com.catedra.catedrapoo.models.Grupo;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet(name = "AdminController", value = "/adm")
public class AdminController extends HttpServlet {

    Admin admin = new Admin();
    Grupo grupo = new Grupo();

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
                StringBuilder jsonBuffer = new StringBuilder();
                String line;

                try (BufferedReader reader = request.getReader()) {
                    while ((line = reader.readLine()) != null) {
                        jsonBuffer.append(line);
                    }
                }

                JSONObject jsonObj = new JSONObject(jsonBuffer.toString());
                String action = jsonObj.getString("action");

                if(action == null) {
                    return;
                }

                int user_id = jsonObj.getInt("userId");
                int group_id = jsonObj.getInt("groupId");

                switch (action) {
                    case "delete_user_from_group":
                        deleteUserFromGroup(request, response, user_id, group_id);
                        break;
                    case "add_user_to_group":
                        addUserToGroup(request, response, user_id, group_id);
                        break;
                }
            }

            if(request.getParameter("action") == null) {
                return;
            }

            HttpSession currentSession = request.getSession(false);
            UserBean user = (UserBean) currentSession.getAttribute("user");

            // Capturando el valor de la acción
            String action = request.getParameter("action");

            // En base a la acción se ejecuta un método u otro
            switch (action) {
                case "display_users":
                    displayUsers(request, response);
                    break;
                case "display_user":
                    displayUserById(request, response, Integer.parseInt(request.getParameter("id")));
                    break;
                case "create_user":
                    createUser(request, response);
                    break;
                case "modify_user":
                    modifyUser(request, response);
                    break;
                case "delete_user":
                    deleteUser(request, response);
                    break;
                case "display_areas":
                    displayAreas(request, response);
                    break;
                case "new_area":
                    createArea(request, response);
                    break;
                case "display_groups":
                    displayGroups(request, response);
                    break;
                case "update_group":
                    updateGroup(request, response);
                    break;
            }
        }
    }

    private void displayUsers(final HttpServletRequest request, final HttpServletResponse response) {
        try {
            request.setAttribute("users", admin.getUsers());
            request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
        } catch (IOException | SQLException | ServletException e) {
            System.out.println(e.getMessage());
        }
    }

    private void displayUserById(final HttpServletRequest request, final HttpServletResponse response, final int id) {
        try {
            UserBean selected_user = admin.getUserById(id);

            if (selected_user == null) {
                response.sendRedirect("/adm?action=display_users");
                return;
            }

            request.setAttribute("selected_user", selected_user);
            request.getRequestDispatcher("/admin/user_form.jsp?id=" + id).forward(request, response);
        } catch (IOException | SQLException | ServletException e) {
            System.out.println(e.getMessage());
        }
    }

    private void createUser(final HttpServletRequest request, final HttpServletResponse response) {
        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            Date birthdate = dateFormat.parse(request.getParameter("fecha_nac"));

            UserBean newUser = new UserBean(
                    0,
                    request.getParameter("nombre"),
                    request.getParameter("email"),
                    request.getParameter("genero"),
                    birthdate,
                    Integer.parseInt(request.getParameter("rol")),
                    null
            );
            newUser.setPassword(request.getParameter("password"));

            if(admin.createUser(newUser)) {
                response.sendRedirect("/admin/users.jsp?info=success_create_user");
            } else {
                response.sendRedirect("/admin/users.jsp?info=error_create_user");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    private void modifyUser(final HttpServletRequest request, final HttpServletResponse response) {
        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            Date birthdate = dateFormat.parse(request.getParameter("fecha_nac"));
            Date created_at = dateFormat.parse(request.getParameter("fecha_crea"));

            UserBean modifiedUser = new UserBean(
                    Integer.parseInt(request.getParameter("id")),
                    request.getParameter("nombre"),
                    request.getParameter("email"),
                    request.getParameter("genero"),
                    birthdate,
                    Integer.parseInt(request.getParameter("rol")),
                    created_at
            );
            modifiedUser.setPassword(request.getParameter("password"));

            if(admin.updateUser(modifiedUser)) {
                response.sendRedirect("/admin/users.jsp?info=success_update_user");
            } else {
                response.sendRedirect("/admin/users.jsp?info=error_update_user");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    private void deleteUser(final HttpServletRequest request, final HttpServletResponse response) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));

            if(admin.deleteUser(id)) {
                response.sendRedirect("/admin/users.jsp?info=success_delete_user");
            } else {
                response.sendRedirect("/admin/users.jsp?info=error_delete_user");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    private void displayAreas(final HttpServletRequest request, final HttpServletResponse response) {
        try {
            request.setAttribute("areas", admin.getAreas());
            request.getRequestDispatcher("/admin/areas.jsp").forward(request, response);
        } catch (IOException | SQLException | ServletException e) {
            System.out.println(e.getMessage());
        }
    }

    private void createArea(final HttpServletRequest request, final HttpServletResponse response) {
        try {
            if(request.getParameter("prefix") == null || request.getParameter("name") == null || request.getParameter("boss") == null || request.getParameter("dev_boss") == null || request.getParameter("empNum") == null || request.getParameter("devNum") == null) {
                response.sendRedirect("/admin/area_form.jsp?info=error_empty_fields");
                return;
            }

            String prefix = request.getParameter("prefix");
            String name = request.getParameter("name");
            int boss_id = Integer.parseInt(request.getParameter("boss"));
            int dev_id = Integer.parseInt(request.getParameter("dev_boss"));
            int empNum = Integer.parseInt(request.getParameter("empNum"));
            int devNum = Integer.parseInt(request.getParameter("devNum"));

            if(prefix.length() != 3) {
                response.sendRedirect("/admin/area_form.jsp?info=error_prefix_length");
                return;
            }

            if(admin.createArea(prefix, name, boss_id, dev_id, empNum, devNum)) {
                response.sendRedirect("/admin/areas.jsp?info=success_create_area");
            } else {
                response.sendRedirect("/admin/areas.jsp?info=error_create_area");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    private void displayGroups(final HttpServletRequest request, final HttpServletResponse response) {
        try {
            request.setAttribute("groups", admin.getGroups());
            request.getRequestDispatcher("/admin/groups.jsp").forward(request, response);
        } catch (IOException | SQLException | ServletException e) {
            System.out.println(e.getMessage());
        }
    }

    private void updateGroup(final HttpServletRequest request, final HttpServletResponse response) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));

            GroupBean group = admin.getGroupById(id);

            // Validar si el grupo existe
            if(group == null) {
                response.sendRedirect("/admin/groups.jsp?info=error_group_not_found");
                return;
            }

            // Obtener el tipo de grupo
            String type = group.getName().split(" ")[0];

            request.setAttribute("group", group);
            request.setAttribute("miembros", grupo.getUsersFromGroup(id));
            request.setAttribute("usuarios", grupo.getUsersWithoutGroup(type));

            request.getRequestDispatcher("/admin/group.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    private void addUserToGroup(final HttpServletRequest request, final HttpServletResponse response, int user_id, int group_id) {
        try {
            response.setContentType("application/json");

            if(admin.addUserToGroup(new UserBean(user_id, new GroupBean(group_id, null)))) {
                response.getWriter().write("{\"success\": true, \"message\": \"Usuario añadido al grupo correctamente.\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"No se pudo añadir el usuario al grupo.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    private void deleteUserFromGroup(final HttpServletRequest request, final HttpServletResponse response, int user_id, int group_id) {
        try {
            response.setContentType("application/json");

            if(admin.removeUserFromGroup(new UserBean(user_id, new GroupBean(group_id, null)))) {
                response.getWriter().write("{\"success\": true, \"message\": \"Usuario eliminado del grupo correctamente.\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"No se pudo eliminar el usuario del grupo.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }
}