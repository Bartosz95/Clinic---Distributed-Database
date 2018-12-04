package sample;

public class Investigation {
    private int id, patientId, pesel;
    private String name, surname, type, result;

    public Investigation(int id, int patientId, String name, String surname, int pesel, String type, String result){
        this.id = id;
        this.patientId = patientId;
        this.name = name;
        this.surname = surname;
        this.pesel = pesel;
        this.type = type;
        this.result = result;
    }

    public int getId() {
        return id;
    }

    public int getPatientId() {
        return patientId;
    }

    public String getName() {
        return name;
    }

    public String getSurname() {
        return surname;
    }

    public int getPesel() {
        return pesel;
    }

    public String getType() {
        return type;
    }

    public String getResult() {
        return result;
    }
}
