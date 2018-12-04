package sample;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.ComboBox;
import javafx.scene.control.TextField;

import java.net.URL;
import java.sql.ResultSet;
import java.util.ResourceBundle;

public class addDoctor implements Initializable {

    public static ConnectMSSQLServer connection;

    @FXML
    TextField addDoctorName, addDoctorSurname, addDoctorTitle, addDoctorSpecialization, addDoctorSalary;
    @FXML
    ComboBox<Clinic> addDoctorClinicName;


    @Override
    public void initialize(URL location, ResourceBundle resources) {
        addDoctorClinicName.setItems(getClinic());
    }

    public void back(ActionEvent actionEvent) {
        Controller.stage.setScene(Main.scene);
    }

    public void addDoctor(ActionEvent actionEvent) {
        String query = "EXEC addDoctor" +
                "\n@imie = N'"+addDoctorName.getText()+"'," +
                "\n@nazwisko = N'"+addDoctorSurname.getText()+"'," +
                "\n@tytul = N'"+addDoctorTitle.getText()+"'," +
                "\n@specjalizacja = N'"+addDoctorSpecialization.getText()+"'," +
                "\n@id_przychodnia = N'"+addDoctorClinicName.getSelectionModel().getSelectedItem().getId()+"'," +
                "\n@wyplata = N'"+Integer.parseInt(addDoctorSalary.getText())+"'";
        connection.query(query);
        Controller.stage.setScene(Main.scene);
    }
    private ObservableList<Clinic> getClinic(){
        ObservableList<Clinic> list = FXCollections.observableArrayList();
        try{
            ResultSet result = connection.query("select * from przychodnie");
            while (result.next()) {
                list.add(new Clinic(result.getInt(1), result.getString(2),result.getString(3), result.getString(4)));
            }

        } catch (Exception e){
            System.out.println(e.toString());
        }
        return list;
    }
}
