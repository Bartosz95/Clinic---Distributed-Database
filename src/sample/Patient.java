package sample;

public class Patient {
    private int id, pesel;
    private String name, surname;
    public Patient(int id, String name, String surname, int pesel){
        this.id = id;
        this.name = name;
        this.surname = surname;
        this.pesel = pesel;
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

    public int getPesel() {
        return pesel;
    }
}
