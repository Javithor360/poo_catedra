package com.catedra.catedrapoo.models;

import com.catedra.catedrapoo.beans.BitacoraBean;
import com.catedra.catedrapoo.beans.TicketBean;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;

public class JefeDesarrollo {

    /*
        Métodos ejecutados por el Jefe de Desarrollo
     */

    // Obtener todos los casos solicitados por las áreas
    public HashMap<String, TicketBean> fetchNewTickets(int dev_boss_id) throws SQLException {
        HashMap<String, TicketBean> ticketList = new HashMap<>();

        Conexion conexion = new Conexion();
        String query = "SELECT " +
                "t.id AS ticket_id, " +
                "t.code AS ticket_code, " +
                "t.name AS ticket_name, " +
                "t.description AS ticket_description, " +
                "t.created_at AS ticket_created_at, " +
                "s.name AS state, u.name AS boss_name, " +
                "u2.name AS dev_boss_name, " +
                "a.name AS area_name " +
                "FROM tickets t " +
                "LEFT JOIN users u ON t.boss_id = u.id " +
                "LEFT JOIN users u2 ON t.dev_boss_id = u2.id " +
                "LEFT JOIN areas a ON t.boss_id = a.boss_id " +
                "LEFT JOIN states s ON t.state_id = s.id " +
                "WHERE t.dev_boss_id = " + dev_boss_id + " " +
                "AND t.state_id = 1;";
        conexion.setRs(query);

        ResultSet rs = conexion.getRs();
        while (rs.next()) {
            // Instancia de Ticket con parámetros necesarios de acorde a su estado actual
            TicketBean ticket = new TicketBean(
                    rs.getInt("ticket_id"),
                    rs.getString("ticket_code"),
                    rs.getString("ticket_name"),
                    rs.getString("ticket_description"),
                    rs.getString("state"),
                    rs.getString("area_name"),
                    rs.getString("boss_name"),
                    rs.getString("dev_boss_name"),
                    rs.getString("ticket_created_at")
            );
            ticketList.put(ticket.getCode(), ticket);
        }
        rs.close();
        conexion.closeConnection();

        return ticketList;
    }

    // Obtener todos los caso que no son recién solicitados
    // Obtener todos los tickets que no son recién solicitados
    public HashMap<String, TicketBean> fetchAllTickets(int dev_boss_id) throws SQLException {
        HashMap<String, TicketBean> ticketList = new HashMap<>();

        Conexion conexion = null;
        try {
            conexion = new Conexion();
            String ticketsQuery = "SELECT " +
                    "t.id AS ticket_id," +
                    "t.code AS ticket_code, " +
                    "t.name AS ticket_name, " +
                    "t.description AS ticket_description, " +
                    "t.state_id AS state_id, " +
                    "t.created_at AS ticket_created_at, " +
                    "t.due_date AS ticket_due_date, " +
                    "t.programmer_id AS programmer_id" +
                    "s.name AS state, " +
                    "u.name AS boss_name, " +
                    "u2.name AS dev_boss_name," +
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
                    "WHERE t.dev_boss_id = " + dev_boss_id + " " +
                    "AND t.state_id != 1;";
            conexion.setRs(ticketsQuery);

            ResultSet rs = conexion.getRs();
            while(rs.next()) {
                // Instanciando la bitácora en caso de que sea necesario
                HashMap<Integer, BitacoraBean> ticketLogs = new HashMap<>();
                // Instancia de Ticket con parámetros necesarios de acorde a su estado actual
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
                ticketList.put(ticket.getCode(), ticket);
            }
            conexion.closeConnection();
            return ticketList;
        } finally {
            if(conexion != null) {
                conexion.closeConnection();
            }
        }
    }

    // Obteniendo la lista de programadores asignados al jefe de desarrollo
    public HashMap<Integer, String> fetchProgramerListNames(int dev_boss_id, int ticket_id) throws SQLException {
        HashMap<Integer, String> programmers = new HashMap<>();

        Conexion conexion = new Conexion();
        String query = "SELECT " +
                "u.name AS programmer_name, " +
                "u.id AS programmer_id " +
                "FROM tickets t " +
                "INNER JOIN assignments_map a ON t.dev_boss_id = a.boss_id " +
                "INNER JOIN users_groups ug ON a.users_group_id = ug.group_id " +
                "INNER JOIN users u ON ug.user_id = u.id " +
                "WHERE t.dev_boss_id = " + dev_boss_id + " " +
                "AND u.role_id = 2 " +
                "AND t.id = " + ticket_id + ";";
        conexion.setRs(query);

        ResultSet rs = conexion.getRs();
        while (rs.next()) {
            int programmer_id = rs.getInt("programmer_id");
            String programmer_name = rs.getString("programmer_name");
            programmers.put(programmer_id, programmer_name);
        }
        conexion.closeConnection();

        return programmers;
    }

    // Obteniendo la lista de testers asignados al jefe de área solicitante
    public HashMap<Integer, String> fetchTestersListNames(int dev_boss_id, int ticket_id) throws SQLException {
        HashMap<Integer, String> testers = new HashMap<>();

        Conexion conexion = new Conexion();
        String query = "SELECT " +
                "u.name AS tester_name, " +
                "u.id AS tester_id " +
                "FROM tickets t " +
                "INNER JOIN assignments_map a ON t.boss_id = a.boss_id " +
                "INNER JOIN users_groups ug ON a.users_group_id = ug.group_id " +
                "INNER JOIN users u ON ug.user_id = u.id " +
                "WHERE t.dev_boss_id = " + dev_boss_id + " " +
                "AND u.role_id = 4 " +
                "AND t.id = " + ticket_id + ";";
        conexion.setRs(query);

        ResultSet rs = conexion.getRs();
        while (rs.next()) {
            int tester_id = rs.getInt("tester_id");
            String tester_name = rs.getString("tester_name");
            testers.put(tester_id, tester_name);
        }
        conexion.closeConnection();

        return testers;
    }

    // Aceptar un caso
    public void acceptTicket(int ticket_id, int programmer_id, int tester_id, int dev_boss_id, String observations, String due_date) throws SQLException {
        Conexion conexion = new Conexion();
        PreparedStatement stmt = null;

        String queryUpdate = "UPDATE tickets " +
                "SET programmer_id = " + programmer_id + ", tester_id = " + tester_id + ", due_date = \"" + due_date + "\", state_id = 3 " +
                "WHERE id = " + ticket_id + ";";

        String queryInsert = "INSERT INTO observations " +
                "(id, name, description, ticket_id, writer_id) " +
                "VALUES (null, '', \"" + observations + "\", " + ticket_id + ", " + dev_boss_id + ");";

        stmt = conexion.setQuery(queryUpdate);
        stmt.executeUpdate();
        stmt.close();

        stmt = conexion.setQuery(queryInsert);
        stmt.executeUpdate();
        stmt.close();

        conexion.closeConnection();
    }

    // Denegar un caso
    public void denyTicket (int ticket_id, int dev_boss_id, String observations) throws SQLException {
        Conexion conexion = new Conexion();
        PreparedStatement stmt = null;

        String queryUpdate = "UPDATE tickets " +
                "SET state_id = 2 " +
                "WHERE id = " + ticket_id + ";";

        String queryInsert = "INSERT INTO observations " +
                "(id, name, description, ticket_id, writer_id) " +
                "VALUES (null, '', \"" + observations + "\", " + ticket_id + ", " + dev_boss_id + ");";

        stmt = conexion.setQuery(queryUpdate);
        stmt.executeUpdate();
        stmt.close();

        stmt = conexion.setQuery(queryInsert);
        stmt.executeUpdate();
        stmt.close();

        conexion.closeConnection();
    }
}
