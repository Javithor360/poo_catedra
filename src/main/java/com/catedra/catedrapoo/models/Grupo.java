package com.catedra.catedrapoo.models;

import com.catedra.catedrapoo.beans.UserBean;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

public class Grupo {
    public static int countGroups() throws SQLException {
        int groupCount = 0;
        Conexion conexion = null;

        try {
            conexion = new Conexion();
            String query = "SELECT COUNT(*) AS count FROM `groups`;";
            conexion.setRs(query);

            ResultSet rs = conexion.getRs();
            if (rs.next()) {
                groupCount = rs.getInt("count");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }

        return groupCount;
    }

    public HashMap<Integer, UserBean> getUsersFromGroup(int id) throws SQLException {
        HashMap<Integer, UserBean> userList = new HashMap<>();
        Conexion conexion = null;

        try {
            conexion = new Conexion();
            String query = "SELECT u.id, u.name, u.email, u.role_id, r.name AS role_name " +
                    "FROM users_groups ug " +
                    "LEFT JOIN users u ON ug.user_id = u.id " +
                    "LEFT JOIN roles r ON u.role_id = r.id " +
                    "WHERE ug.group_id = ?;";
            PreparedStatement stmt = conexion.setQuery(query);
            stmt.setInt(1, id);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                UserBean user = new UserBean(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email")
                );
                userList.put(user.getId(), user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }

        return userList;
    }

    public HashMap<Integer, UserBean> getUsersWithoutGroup(String type) throws SQLException {
        Conexion conexion = null;
        HashMap<Integer, UserBean> userList = new HashMap<>();
        int id_usuario = 0;

        if(type.equals("Empleados")) {
            id_usuario = 4;
        } else if(type.equals("Programadores")) {
            id_usuario = 2;
        }

        try {
            conexion = new Conexion();
            String query = "SELECT u.id, u.name, r.name AS role FROM users u " +
                    "LEFT JOIN users_groups ug ON u.id = ug.user_id " +
                    "LEFT JOIN roles r ON u.role_id = r.id " +
                    "WHERE ug.user_id IS NULL " +
                    "AND u.role_id NOT IN (1, 3) " +
                    "AND u.role_id = ?";
            PreparedStatement stmt = conexion.setQuery(query);
            stmt.setInt(1, id_usuario);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                UserBean user = new UserBean(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("role")
                );
                userList.put(user.getId(), user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }

        return userList;
    }
}
