package sample;

import java.sql.Date;
import java.sql.Time;

public class Visit {
    private int id, patientId, doctorID;
    private String patientName, patientSurname, doctorName, doctorSurname, description;
    private Date date;
    private Time time;

    public Visit(int id, int patientId, String patientName, String patientSurname, int doctorID, String doctorName, String doctorSurname, Date date, Time time, String description){
        this.id = id;
        this.patientId = patientId;
        this.patientName = patientName;
        this.patientSurname = patientSurname;
        this.doctorID = doctorID;
        this.doctorName = doctorName;
        this.doctorSurname = doctorSurname;
        this.date = date;
        this.time = time;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public int getPatientId() {
        return patientId;
    }

    public String getPatientName() {
        return patientName;
    }

    public String getPatientSurname() {
        return patientSurname;
    }

    public int getDoctorID() {
        return doctorID;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public String getDoctorSurname() {
        return doctorSurname;
    }

    public Date getDate() {
        return date;
    }

    public Time getTime() {
        return time;
    }

    public String getDescription() {
        return description;
    }
}
