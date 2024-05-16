package com.catedra.catedrapoo.models;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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
}
