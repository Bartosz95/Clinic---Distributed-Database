package sample;

public class Doctor {
    private int id, salary;
    private String name, surname, title, specialization, clinic;

    public Doctor(int id, String name, String surname, String title, String specialization, String clinic, int salary){
        this.id = id;
        this.name = name;
        this.surname = surname;
        this.title = title;
        this.specialization = specialization;
        this.clinic = clinic;
        this.salary = salary;
    }

    public String toString(){
        return name+" "+surname;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getSurname() {
        return surname;
    }

    public String getTitle() {
        return title;
    }

    public String getSpecialization() {
        return specialization;
    }

    public String getClinic() {
        return clinic;
    }

    public int getSalary() {
        return salary;
    }
}
