package com.catedra.catedrapoo.models;

import com.catedra.catedrapoo.beans.BitacoraBean;
import com.catedra.catedrapoo.beans.TicketBean;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Year;
import java.util.HashMap;
import java.util.Random;

public class JefeArea {

    // Obtener los casos aperturados previamente
    public HashMap<String, TicketBean> fetchOpenedTickets(int boss_id) throws SQLException {
        HashMap<String, TicketBean> ticketList = new HashMap<>();
        Conexion conexion = null;

        try {
            conexion = new Conexion();
            String ticketsQuery = "SELECT " +
                    "t.id AS ticket_id, " +
                    "t.code AS ticket_code, " +
                    "t.name AS ticket_name, " +
                    "t.description AS ticket_description, " +
                    "t.state_id AS state_id, " +
                    "t.due_date AS ticket_due_date, " +
                    "t.created_at AS ticket_created_at, " +
                    "t.programmer_id AS programmer_id, " +
                    "s.name AS state, " +
                    "u.name AS boss_name, " +
                    "u2.name AS dev_boss_name, " +
                    "u3.name AS programmer_name, " +
                    "u4.name AS tester_name, " +
                    "a.name AS area_name, " +
                    "o.description AS observations " +
                    "FROM tickets t " +
                    "LEFT JOIN users u ON t.boss_id = u.id " +
                    "LEFT JOIN users u2 ON t.dev_boss_id = u2.id " +
                    "LEFT JOIN users u3 ON t.programmer_id = u3.id " +
                    "LEFT JOIN users u4 ON t.tester_id = u4.id " +
                    "LEFT JOIN areas a ON t.boss_id = a.boss_id " +
                    "LEFT JOIN states s ON t.state_id = s.id " +
                    "LEFT JOIN observations o ON t.id = o.ticket_id " +
                    "AND t.dev_boss_id = o.writer_id " +
                    "WHERE t.boss_id = " + boss_id + ";";
            conexion.setRs(ticketsQuery);

            ResultSet rs = conexion.getRs();
            while (rs.next()) {
                HashMap<Integer, BitacoraBean> ticketLogs = new HashMap<>();
                TicketBean ticket = new TicketBean(
                        rs.getInt("ticket_id"),
                        rs.getString("ticket_code"),
                        rs.getString("ticket_name"),
                        rs.getString("ticket_description"),
                        rs.getString("state"),
                        rs.getInt("state_id"),
                        rs.getString("observations"),
                        rs.getInt("programmer_id"),
                        rs.getString("area_name"),
                        rs.getString("boss_name"),
                        rs.getString("dev_boss_name"),
                        rs.getString("tester_name"),
                        rs.getString("programmer_name"),
                        rs.getString("ticket_due_date"),
                        rs.getString("ticket_created_at")
                );

                // Usar una nueva instancia de Conexion para la consulta de registros de bitácora
                Conexion conexionLogs = new Conexion();
                String logsQuery = "SELECT " +
                        "tl.id AS log_id, " +
                        "tl.code_ticket AS ticket_code, " +
                        "tl.name AS log_name, " +
                        "tl.description AS log_description, " +
                        "tl.percent AS log_percent, " +
                        "u.name AS programmer_name, " +
                        "tl.created_at AS log_created_at " +
                        "FROM ticket_logs tl " +
                        "INNER JOIN users u ON tl.programmer_id = u.id " +
                        "WHERE tl.code_ticket = \"" + ticket.getCode() + "\"";
                conexionLogs.setRs(logsQuery);

                ResultSet rs2 = conexionLogs.getRs();
                while (rs2.next()) {
                    BitacoraBean log = new BitacoraBean(
                            rs2.getInt("log_id"),
                            rs2.getString("ticket_code"),
                            rs2.getString("log_name"),
                            rs2.getString("log_description"),
                            rs2.getFloat("log_percent"),
                            rs2.getString("programmer_name"),
                            rs2.getString("log_created_at")
                    );
                    ticketLogs.put(log.getId(), log);
                }
                ticket.setLogs(ticketLogs);
                ticketList.put(ticket.getCode(), ticket);
            }
            conexion.closeConnection();
            return ticketList;
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
    }

    // Obtener información de un caso por su ID
    public TicketBean fetchTicketById (int ticket_id) throws SQLException {
        TicketBean ticket = null;
        Conexion conexion = null;

        try {
            conexion = new Conexion();
            String query = "SELECT " +
                    "t.id AS ticket_id, " +
                    "t.code AS ticket_code, " +
                    "t.name AS ticket_name, " +
                    "t.description AS ticket_description, " +
                    "t.state_id AS state_id, " +
                    "t.due_date AS ticket_due_date, " +
                    "t.created_at AS ticket_created_at, " +
                    "t.programmer_id AS programmer_id, " +
                    "s.name AS state, " +
                    "u.name AS boss_name, " +
                    "u2.name AS dev_boss_name, " +
                    "u3.name AS programmer_name, " +
                    "u4.name AS tester_name, " +
                    "a.name AS area_name, " +
                    "o.description AS observations " +
                    "FROM tickets t " +
                    "LEFT JOIN users u ON t.boss_id = u.id " +
                    "LEFT JOIN users u2 ON t.dev_boss_id = u2.id " +
                    "LEFT JOIN users u3 ON t.programmer_id = u3.id " +
                    "LEFT JOIN users u4 ON t.tester_id = u4.id " +
                    "LEFT JOIN areas a ON t.boss_id = a.boss_id " +
                    "LEFT JOIN states s ON t.state_id = s.id " +
                    "LEFT JOIN observations o ON t.id = o.ticket_id " +
                    "AND t.dev_boss_id = o.writer_id " +
                    "WHERE t.id = " + ticket_id + " ";
            conexion.setRs(query);
            ResultSet rs = conexion.getRs();
            if (rs.next()) {
                HashMap<Integer, BitacoraBean> ticketLogs = new HashMap<>();
                ticket = new TicketBean(
                        rs.getInt("ticket_id"),
                        rs.getString("ticket_code"),
                        rs.getString("ticket_name"),
                        rs.getString("ticket_description"),
                        rs.getString("state"),
                        rs.getInt("state_id"),
                        rs.getString("observations"),
                        rs.getInt("programmer_id"),
                        rs.getString("area_name"),
                        rs.getString("boss_name"),
                        rs.getString("dev_boss_name"),
                        rs.getString("tester_name"),
                        rs.getString("programmer_name"),
                        rs.getString("ticket_due_date"),
                        rs.getString("ticket_created_at")
                );

                Conexion conexionLogs = new Conexion();
                String logsQuery = "SELECT " +
                        "tl.id AS log_id, " +
                        "tl.code_ticket AS ticket_code, " +
                        "tl.name AS log_name, " +
                        "tl.description AS log_description, " +
                        "tl.percent AS log_percent, " +
                        "u.name AS programmer_name, " +
                        "tl.created_at AS log_created_at " +
                        "FROM ticket_logs tl " +
                        "INNER JOIN users u ON tl.programmer_id = u.id " +
                        "WHERE tl.code_ticket = \"" + ticket.getCode() + "\"";
                conexionLogs.setRs(logsQuery);

                ResultSet rs2 = conexionLogs.getRs();
                while (rs2.next()) {
                    BitacoraBean logs = new BitacoraBean(
                            rs2.getInt("log_id"),
                            rs2.getString("ticket_code"),
                            rs2.getString("log_name"),
                            rs2.getString("log_description"),
                            rs2.getDouble("log_percent"),
                            rs2.getString("programmer_name"),
                            rs2.getString("log_created_at")
                    );
                    ticketLogs.put(logs.getId(), logs);
                }
                ticket.setLogs(ticketLogs);
            }
            conexion.closeConnection();

            return ticket;
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
    }

    // Crear un nuevo caso
    public boolean createNewTicket(int boss_id, String title, String description) throws SQLException {
        int dev_boss_id = 0;
        Conexion conexion = null;

        try {
            conexion = new Conexion();
            String query = "SELECT dev_boss_id FROM areas WHERE boss_id = " + boss_id + ";";
            conexion.setRs(query);
            ResultSet rs = conexion.getRs();

            while(rs.next()) {
                dev_boss_id = rs.getInt("dev_boss_id");
            }

            PreparedStatement stmt;
            String queryInsert = "INSERT INTO tickets (code, name, description, state_id, boss_id, dev_boss_id, created_at) VALUES (?, ?, ?, 1, ?, ?, CURRENT_TIMESTAMP)";

            stmt = conexion.setQuery(queryInsert);
            stmt.setString(1, generateNewCode(boss_id));
            stmt.setString(2, title);
            stmt.setString(3, description);
            stmt.setInt(4, boss_id);
            stmt.setInt(5, dev_boss_id);

            int rowsAffected = stmt.executeUpdate();
            stmt.close();

            // Si se insertó al menos una fila, se considera exitoso
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            // En caso de error, devolver false
            return false;
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
    }

    public String generateNewCode(int user_id) throws SQLException{
        Random ran = new Random();
        String prefix =  getAreaPrefixCode(user_id);
        String year = String.valueOf(Year.now());
        String num = String.valueOf(ran.nextInt(999 - 100 + 1) + 100);

        return prefix+year+num;
    }

    public String getAreaPrefixCode(int user_id) throws SQLException{
        Conexion conexion = new Conexion();

        try{
            String query = "SELECT a.prefix_code " +
                    "FROM users u " +
                    "JOIN assignments_map am ON u.id = am.boss_id " +
                    "JOIN areas a ON am.area_id = a.id " +
                    "WHERE u.id = "+user_id+";";

            conexion.setRs(query);
            ResultSet rs = conexion.getRs();

            while(rs.next()){
                return rs.getString("prefix_code");
            }
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
        return "NULL";
    }
}
