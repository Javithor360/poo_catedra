package com.catedra.catedrapoo.servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.*;

@WebServlet(name = "FileController", value = "/flc")
public class FileController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, IOException {
        String nombreArchivo = request.getParameter("fileName");

        // Obtener la ruta real del archivo PDF
        String filePath = getServletContext().getRealPath("/storage/"+nombreArchivo);

        // Establecer el tipo de contenido y el encabezado de respuesta para la descarga del archivo
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=" + nombreArchivo);

        // Abrir el archivo y preparar el flujo de salida
        File file = new File(filePath);
        FileInputStream fis = new FileInputStream(file);
        OutputStream out = response.getOutputStream();

        // Copiar el contenido del archivo al flujo de salida del servlet
        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = fis.read(buffer)) != -1) {
            out.write(buffer, 0, bytesRead);
        }

        // Cerrar los flujos
        fis.close();
        out.close();
    }
}