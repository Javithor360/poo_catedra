package com.catedra.catedrapoo.models;

import java.sql.*;

public class Conexion {
    // Declarando las variables requeridas para establecer la conexión con la base de datos
    private Connection connection = null;
    private Statement s = null;
    private ResultSet rs = null;
    private boolean autoCommitEnabled = true;

    // Constructor que inicializa cada instancia de la Conexión
    public Conexion() throws SQLException {
        try {
            // Accediendo al driver de MySQL (JDBC)
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Obteniendo la conexión con la base de datos
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/catedrapoo",
                    "root",
                    ""
            );
            // Declarando statement que permite ejecutar sentencias SQL sin parámetros
            s = connection.createStatement();

            System.out.println("[LOG] Conexión con la base de datos exitosa");
        } catch (ClassNotFoundException e) {
            // Error devuelto en caso de que no se encuentre el driver del MySQL
            System.out.println("[ERROR] No se encontró el driver indicado para la base de datos.");
        }
    }

    // Método para obtener los valores del ResultSet
    public ResultSet getRs() { return rs; }

    // Método para fijar la tabla de resultado de la setencia SQL realizada
    public void setRs(String sql) {
        try {
            this.rs = s.executeQuery(sql);
        } catch (SQLException e) {
            // Login o sentencia SQL errónea
            System.out.println("[ERROR] Fallo en SQL RS: \n" + e.getMessage());
        }
    }

    /*
        Método que recibe un SQL como parámetro
        que sea UPDATE, INSERT o DELETE
     */
    public PreparedStatement setQuery(String sql) throws SQLException {
        PreparedStatement pstmt = null;
        try {
            pstmt = connection.prepareStatement(sql);
        } catch (SQLException e) {
            System.out.println("[ERROR] Fallo en SQL query: \n" + e.getMessage());
            throw e; // Relanza la excepción para manejarla fuera de la clase Conexion
        }
        return pstmt;
    }

    // Método para activar o desactivar el modo de confirmación automática
    public void setAutoCommit(boolean autoCommit) throws SQLException {
        connection.setAutoCommit(autoCommit);
        autoCommitEnabled = autoCommit;
    }

    // Método para realizar un rollback en la transacción actual
    public void rollback() throws SQLException {
        if (!autoCommitEnabled) {
            connection.rollback();
        }
    }

    // Método para confirmar la transacción actual
    public void commit() throws SQLException {
        if (!autoCommitEnabled) {
            connection.commit();
        }
    }

    // Método que cierra la conexión
    public void closeConnection() throws SQLException {
        connection.close();
    }
}
