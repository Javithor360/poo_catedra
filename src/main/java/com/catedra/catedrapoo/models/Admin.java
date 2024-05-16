package com.catedra.catedrapoo.models;

import com.catedra.catedrapoo.beans.AreaBean;
import com.catedra.catedrapoo.beans.BasicUserBean;
import com.catedra.catedrapoo.beans.GroupBean;
import com.catedra.catedrapoo.beans.UserBean;

import java.sql.*;
import java.util.HashMap;

public class Admin {

    public HashMap<Integer, UserBean> getUsers() throws SQLException {
        Conexion conexion = null;
        HashMap<Integer, UserBean> users = new HashMap<>();

        try {
            conexion = new Conexion();
            String sql = "SELECT u.*, r.name AS role_name " +
                    "FROM users u INNER JOIN roles r ON u.role_id = r.id";
            conexion.setRs(sql);

            ResultSet rs = conexion.getRs();
            while (rs.next()) {
                UserBean user = new UserBean(
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

    public UserBean getUserById(int id) throws SQLException {
        Conexion conexion = null;
        UserBean user = null;

        try {
            conexion = new Conexion();
            String sql = "SELECT u.*, r.name AS role_name " +
                    "FROM users u INNER JOIN roles r ON u.role_id = r.id " +
                    "WHERE u.id = " + id + ";";
            conexion.setRs(sql);

            ResultSet rs = conexion.getRs();
            if (rs.next()) {
                user = new UserBean(
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

    public boolean createUser(UserBean user) throws SQLException {
        Conexion conexion = null;
        boolean created = false;

        try {
            conexion = new Conexion();
            String sql = "INSERT INTO users (name, email, password, gender, birthday, role_id) VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement sqlStatement = conexion.setQuery(sql);
            sqlStatement.setString(1, user.getName());
            sqlStatement.setString(2, user.getEmail());
            sqlStatement.setString(3, user.getPassword());
            sqlStatement.setString(4, user.getGender());
            sqlStatement.setDate(5, new java.sql.Date(user.getBirthday().getTime()));
            sqlStatement.setInt(6, user.getRole_id());

            int rowsAffected = sqlStatement.executeUpdate();

            // Verificar si se insertaron filas
            if (rowsAffected > 0) {
                created = true;
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
        return created;
    }

    public boolean updateUser(UserBean user) throws SQLException {
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

    public boolean deleteUser(int id) throws SQLException {
        Conexion conexion = null;
        boolean deleted = false;

        try {
            conexion = new Conexion();
            String sql = "DELETE FROM users WHERE id = ?";
            PreparedStatement sqlStatement = conexion.setQuery(sql);
            sqlStatement.setInt(1, id);

            int rowsAffected = sqlStatement.executeUpdate();

            // Verificar si se eliminaron filas
            if (rowsAffected > 0) {
                deleted = true;
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
        return deleted;
    }

    public static HashMap<Integer, UserBean> getUsersByRoleWithoutRole(int role_id) throws SQLException {
        Conexion conexion = null;
        HashMap<Integer, UserBean> users = new HashMap<>();

        try {
            conexion = new Conexion();
            String sql = "SELECT u.*, r.name AS role_name " +
                    "FROM users u INNER JOIN roles r ON u.role_id = r.id " +
                    "WHERE u.role_id = ? AND u.id NOT IN (SELECT boss_id FROM assignments_map)";
            PreparedStatement sqlStatement = conexion.setQuery(sql);
            sqlStatement.setInt(1, role_id);

            ResultSet rs = sqlStatement.executeQuery();
            while (rs.next()) {
                UserBean user = new UserBean(
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

    public HashMap<Integer, AreaBean> getAreas() throws SQLException {
        Conexion conexion = null;
        HashMap<Integer, AreaBean> areas = new HashMap<>();

        try {
            conexion = new Conexion();
            String sql = "SELECT " +
                    "a.id AS area_id, " +
                    "a.prefix_code AS area_prefix, " +
                    "a.name AS area_name, " +
                    "b.id AS boss_id, " +
                    "b.name AS boss_name, " +
                    "p.id AS dev_id, " +
                    "p.name AS dev_name " +
                    "FROM areas a " +
                    "LEFT JOIN users b ON a.boss_id = b.id " +
                    "LEFT JOIN users p ON a.dev_boss_id = p.id;";
            conexion.setRs(sql);

            ResultSet rs = conexion.getRs();
            while (rs.next()) {
                AreaBean area = new AreaBean(
                        rs.getInt("area_id"),
                        rs.getString("area_prefix"),
                        rs.getString("area_name"),
                        new BasicUserBean(
                                rs.getInt("boss_id"),
                                rs.getString("boss_name")
                        ),
                        new BasicUserBean(
                                rs.getInt("dev_id"),
                                rs.getString("dev_name")
                        )
                );
                areas.put(area.getId(), area);
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
        return areas;
    }

    public boolean createArea(String prefix, String name, int boss_id, int dev_boss_id, int employeeGroupNum, int devGroupNum) throws SQLException {
        Conexion conexion = new Conexion();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet generatedKeys = null;
        boolean created = false;

        try {
            conn = conexion.getConnection();
            conn.setAutoCommit(false);

            // Inserción para tabla de áreas
            String queryArea = "INSERT INTO areas (name, prefix_code, boss_id, dev_boss_id) VALUES (?, ?, ?, ?)";
            stmt = conn.prepareStatement(queryArea, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, name);
            stmt.setString(2, prefix);
            stmt.setInt(3, boss_id);
            stmt.setInt(4, dev_boss_id);
            stmt.executeUpdate();

            generatedKeys = stmt.getGeneratedKeys();
            int newAreaId = 0;
            if (generatedKeys.next()) {
                newAreaId = generatedKeys.getInt(1);
            }

            // Inserción para tabla de grupos
            String[] groupNames = {"Empleados de " + name, "Programadores para " + prefix};
            int[] groupIDs = new int[2];

            for (int i = 0; i < groupNames.length; i++) {
                String queryGroup = "INSERT INTO `groups` (name) VALUES (?)";
                stmt = conn.prepareStatement(queryGroup, Statement.RETURN_GENERATED_KEYS);
                stmt.setString(1, groupNames[i]);
                stmt.executeUpdate();
                generatedKeys = stmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    groupIDs[i] = generatedKeys.getInt(1);
                }
            }

            // Inserción para tabla de asignaciones con los registros recién hechos
            String queryAssign = "INSERT INTO assignments_map (boss_id, area_id, users_group_id) VALUES (?, ?, ?), (?, ?, ?)";
            stmt = conn.prepareStatement(queryAssign);
            stmt.setInt(1, boss_id);
            stmt.setInt(2, newAreaId);
            stmt.setInt(3, groupIDs[0]);
            stmt.setInt(4, dev_boss_id);
            stmt.setInt(5, newAreaId);
            stmt.setInt(6, groupIDs[1]);
            stmt.executeUpdate();

            conn.commit(); // Confirmar transacción

            if (newAreaId > 0) created = true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // En caso de error, realiza un rollback
                } catch (SQLException ex) {
                    e.printStackTrace();
                }
            }
            e.printStackTrace();
            throw e;
        } finally {
            if (generatedKeys != null) generatedKeys.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
            conexion.closeConnection();
        }
        return created;
    }

    public HashMap<Integer, GroupBean> getGroups() throws SQLException {
        HashMap<Integer, GroupBean> groupList = new HashMap<>();
        Conexion conexion = null;

        try {
            conexion = new Conexion();
            String query = "SELECT g.id AS GrupoID, g.name AS NombreGrupo, " +
                    "a.id AS AreaID, a.name AS NombreArea, u.id AS JefeID, " +
                    "u.name AS NombreJefe, COUNT(ug.user_id) AS TotalIntegrantes " +
                    "FROM `groups` g " +
                    "LEFT JOIN assignments_map ma ON ma.users_group_id = g.id " +
                    "LEFT JOIN areas a ON ma.area_id = a.id " +
                    "LEFT JOIN users u ON ma.boss_id = u.id " +
                    "LEFT JOIN users_groups ug ON g.id = ug.group_id " +
                    "GROUP BY g.id, g.name, a.id, a.name, u.id, u.name;";
            conexion.setRs(query);

            ResultSet rs = conexion.getRs();
            while (rs.next()) {
                GroupBean grupo = new GroupBean(
                        rs.getInt("GrupoID"),
                        rs.getString("NombreGrupo"),
                        new BasicUserBean(
                                rs.getInt("JefeID"),
                                rs.getString("NombreJefe")
                        ),
                        new AreaBean(
                                rs.getInt("AreaID"),
                                rs.getString("NombreArea")
                        ),
                        rs.getInt("TotalIntegrantes")
                );
                groupList.put(grupo.getId(), grupo);
            }
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
        return groupList;
    }
}