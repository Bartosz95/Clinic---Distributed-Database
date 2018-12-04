package sample;

public class Clinic {

    private int id;

    private String name, city, street;

    public Clinic(int id, String name, String city, String street){
        this.id = id;
        this.name = name;
        this.city = city;
        this.street = street;
    }

    public String toString(){
        return name;
    }
    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getCity() {
        return city;
    }

    public String getStreet() {
        return street;
    }
}
