package com.catedra.catedrapoo.models;

import com.catedra.catedrapoo.beans.UserSessionBean;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

public class Admin {

    public HashMap<Integer, UserSessionBean> getUsers() throws SQLException {
        Conexion conexion = null;
        HashMap<Integer, UserSessionBean> users = new HashMap<>();

        try {
            conexion = new Conexion();
            String sql = "SELECT u.*, r.name AS role_name " +
                    "FROM users u INNER JOIN roles r ON u.role_id = r.id";
            conexion.setRs(sql);

            ResultSet rs = conexion.getRs();
            while (rs.next()) {
                UserSessionBean user = new UserSessionBean(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("gender"),
                        rs.getDate("birthday"),
                        rs.getInt("role_id"),
                        rs.getDate("created_at")
                );
                user.setRole_name(rs.getString("role_name"));
                users.put(user.getId(), user);
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
        return users;
    }

    public UserSessionBean getUserById(int id) throws SQLException {
        Conexion conexion = null;
        UserSessionBean user = null;

        try {
            conexion = new Conexion();
            String sql = "SELECT u.*, r.name AS role_name " +
                    "FROM users u INNER JOIN roles r ON u.role_id = r.id " +
                    "WHERE u.id = " + id + ";";
            conexion.setRs(sql);

            ResultSet rs = conexion.getRs();
            if (rs.next()) {
                user = new UserSessionBean(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("gender"),
                        rs.getDate("birthday"),
                        rs.getInt("role_id"),
                        rs.getDate("created_at")
                );
                user.setRole_name(rs.getString("role_name"));
                user.setPassword(rs.getString("password"));
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
        return user;
    }

    public boolean updateUser(UserSessionBean user) throws SQLException {
        Conexion conexion = null;
        boolean updated = false;

        try {
            conexion = new Conexion();
            String sql = "UPDATE users SET name = ?, email = ?, password = ?, gender = ?, birthday = ?, role_id = ? WHERE id = ?";
            PreparedStatement sqlStatement = conexion.setQuery(sql);
            sqlStatement.setString(1, user.getName());
            sqlStatement.setString(2, user.getEmail());
            sqlStatement.setString(3, user.getPassword());
            sqlStatement.setString(4, user.getGender());
            sqlStatement.setDate(5, new java.sql.Date(user.getBirthday().getTime()));
            sqlStatement.setInt(6, user.getRole_id());
            sqlStatement.setInt(7, user.getId());

            int rowsAffected = sqlStatement.executeUpdate();

            // Verificar si se actualizaron filas
            if (rowsAffected > 0) {
                updated = true;
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
        return updated;
    }
}