package com.catedra.catedrapoo.beans;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;

public class TicketBean {
    private int id;
    private String code;
    private String name;
    private String description;
    private int state_id;
    private String state;
    private String observations;
    private String pdf;
    private HashMap<Integer, BitacoraBean> logs;
    private String requester_area_name;
    private String boss_name;
    private String dev_boss_name;
    private int tester_id;
    private String tester_name;
    private int programmer_id;
    private String programmer_name;
    private String due_date;
    private String created_at;

    public TicketBean(int id, String code, String name, String description, String state, String requester_area_name, String boss_name, String dev_boss_name, String pdf, String created_at) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.description = description;
        this.state = state;
        this.requester_area_name = requester_area_name;
        this.boss_name = boss_name;
        this.dev_boss_name = dev_boss_name;
        this.pdf = pdf;
        this.created_at = created_at;
    }

    public TicketBean(int id, String code, String name, String description, String state, int state_id, String observations, String pdf, int programmer_id, String requester_area_name, String boss_name, String dev_boss_name, String tester_name, String programmer_name, String due_date, String created_at) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.description = description;
        this.state = state;
        this.state_id = state_id;
        this.observations = observations;
        this.pdf = pdf;
        this.programmer_id = programmer_id;
        this.requester_area_name = requester_area_name;
        this.boss_name = boss_name;
        this.dev_boss_name = dev_boss_name;
        this.tester_name = tester_name;
        this.programmer_name = programmer_name;
        this.due_date = due_date;
        this.created_at = created_at;
    }

    public TicketBean(int id, int state_id, String due_date, String created_at) {
        this.id = id;
        this.state_id = state_id;
        this.due_date = due_date;
        this.created_at = created_at;
    }

    // Obtener el valor del porcentaje en el registro más reciente en base a su fecha de creación
    public double get_latest_percent (TicketBean t) {
        HashMap<Integer, BitacoraBean> bMap = t.getLogs();

        List<BitacoraBean> bitacoras = new ArrayList<>(bMap.values());

        if(!bitacoras.isEmpty()) {
            bitacoras.sort(Comparator.comparing(BitacoraBean::getCreated_at).reversed());
            return bitacoras.get(0).getPercent();
        } else {
            return 0;
        }
    }

    public void addBitacora (BitacoraBean bitacora) {
        if(logs == null) {
            logs = new HashMap<>();
        }

        logs.put(bitacora.getId(), bitacora);
    }

    // Método para verificar si la fecha de entrega ha excedido la fecha actual
    public boolean checkDueDate() {
        LocalDate dueDate = LocalDate.parse(this.due_date, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        LocalDate currentDate = LocalDate.now();

        // Comparar la fecha de entrega con la fecha actual
        return dueDate.isBefore(currentDate);
    }

    public int getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getState() {
        return state;
    }

    public String getRequester_area_name() {
        return requester_area_name;
    }

    public String getBoss_name() {
        return boss_name;
    }

    public String getDev_boss_name() {
        return dev_boss_name;
    }

    public String getTester_name() {
        return tester_name;
    }

    public String getProgrammer_name() {
        return programmer_name;
    }

    public String getDue_date() {
        return due_date;
    }

    public String getCreated_at() {
        return created_at;
    }

    public int getTester_id() {
        return tester_id;
    }

    public int getProgrammer_id() {
        return programmer_id;
    }

    public void setState(String state) {
        this.state = state;
    }

    public void setTester_id(int tester_id) {
        this.tester_id = tester_id;
    }

    public void setProgrammer_id(int programmer_id) {
        this.programmer_id = programmer_id;
    }

    public void setDue_date(String due_date) {
        this.due_date = due_date;
    }

    public int getState_id() {
        return state_id;
    }

    public void setState_id(int state_id) {
        this.state_id = state_id;
    }

    public String getObservations() {
        return observations;
    }

    public void setObservations(String observations) {
        this.observations = observations;
    }

    public HashMap<Integer, BitacoraBean> getLogs() {
        return logs;
    }

    public void setLogs(HashMap<Integer, BitacoraBean> logs) {
        this.logs = logs;
    }

    public String getPdf() {
        return pdf;
    }

    public void setPdf(String pdf) {
        this.pdf = pdf;
    }
}
