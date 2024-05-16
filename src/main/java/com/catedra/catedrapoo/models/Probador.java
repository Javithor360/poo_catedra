package com.catedra.catedrapoo.models;

import com.catedra.catedrapoo.beans.BitacoraBean;
import com.catedra.catedrapoo.beans.TicketBean;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

public class Probador {

    // Método para obtener los casos asignados al probador
    public HashMap<String, TicketBean> fetchTesterTickets(int tester_id) throws SQLException {
        HashMap<String, TicketBean> ticketList = new HashMap<>();
        Conexion conexion = null;

        try {
            conexion = new Conexion();
            String ticketsQuery = "SELECT " +
                    "t.id AS ticket_id, " +
                    "t.code AS ticket_code, " +
                    "t.name AS ticket_name, " +
                    "t.description AS ticket_description, " +
                    "t.due_date AS ticket_due_date, " +
                    "t.created_at AS ticket_created_at, " +
                    "t.programmer_id AS programmer_id, " +
                    "t.pdf AS pdf, " +
                    "s.name AS state, s.id AS state_id, " +
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
                    "LEFT JOIN observations o ON t.id = o.ticket_id AND t.dev_boss_id = o.writer_id " +
                    "WHERE t.tester_id = " + tester_id + " AND t.state_id != 1;";
            conexion.setRs(ticketsQuery);

            // Obtener los resultados de la consulta
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
                        rs.getString("pdf"),
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
                String logsQuery = "SELECT tl.id AS log_id, tl.code_ticket AS ticket_code, tl.name AS log_name, tl.description AS log_description, tl.percent AS log_percent, u.name AS programmer_name, tl.created_at AS log_created_at FROM ticket_logs tl INNER JOIN users u ON tl.programmer_id = u.id WHERE tl.code_ticket = \"" + ticket.getCode() + "\"";
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

    // Método para obtener un caso por su id
    public TicketBean fetchTicketById(int ticket_id) throws SQLException {
        Conexion conexion = null;
        TicketBean ticket = null;

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
                    "t.pdf AS pdf, " +
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
                        rs.getString("pdf"),
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

    // Método para actualizar el estado de un caso
    public boolean updateStateTicket(int newState, int ticketId, String ticket_code, int testerId, String description, String due_date) {
        Conexion conexion = null;
        PreparedStatement stmt;
        boolean success = false;
        try {
            conexion = new Conexion();
            conexion.setAutoCommit(false); // Deshabilitar el modo de confirmación automática

            if (newState == 6) {
                String queryDecline = "UPDATE tickets " +
                        "SET state_id = ?, due_date = ? WHERE id = ? AND tester_id = ?";
                stmt = conexion.setQuery(queryDecline);
                stmt.setInt(1, newState);
                stmt.setString(2, due_date);
                stmt.setInt(3, ticketId);
                stmt.setInt(4, testerId);
                stmt.executeUpdate();
                stmt.close();

                String queryInsert = "INSERT INTO ticket_logs (code_ticket, name, description, percent, programmer_id) " +
                        "VALUES (?, 'SOLICITUD RECHAZADA', ?, 0, ?)";
                stmt = conexion.setQuery(queryInsert);
                stmt.setString(1, ticket_code);
                stmt.setString(2, description);
                stmt.setInt(3, testerId);
                stmt.executeUpdate();
                stmt.close();

                // Confirmar la transacción después de ejecutar las consultas
                conexion.commit();

                success = true;

            } else if (newState == 7) {
                String queryFinish = "UPDATE tickets " +
                        "SET state_id = ? WHERE id = ? AND tester_id = ?";
                stmt = conexion.setQuery(queryFinish);
                stmt.setInt(1, newState);
                stmt.setInt(2, ticketId);
                stmt.setInt(3, testerId);
                int rowsAffected = stmt.executeUpdate();
                stmt.close();

                // Confirmar la transacción después de ejecutar la consulta
                conexion.commit();

                success = rowsAffected > 0;
            }

        } catch (SQLException ex) {
            if (conexion != null) {
                try {
                    conexion.rollback(); // Revertir la transacción en caso de error
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            ex.printStackTrace();
        } finally {
            if (conexion != null) {
                try {
                    conexion.closeConnection();
                } catch (SQLException closeEx) {
                    closeEx.printStackTrace();
                }
            }
        }
        return success;
    }

    // Método para actualizar la fecha del caso cuando es rechazado
    public boolean updateDateTicket(String newDate, int ticketId) throws SQLException {
        Conexion conexion = null;
        PreparedStatement stmt;

        try {
            conexion = new Conexion();
            String queryUpdate = "UPDATE tickets SET due_date = \"" + newDate + "\" WHERE id = " + ticketId + ";";

            stmt = conexion.setQuery(queryUpdate);
            int rowsAffected = stmt.executeUpdate();
            stmt.close();

            return rowsAffected > 0;
        } catch (SQLException ex) {
            throw new RuntimeException(ex);
        } finally {
            if (conexion != null) {
                conexion.closeConnection();
            }
        }
    }
}
