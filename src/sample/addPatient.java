package sample;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.TextField;

import java.net.URL;
import java.util.ResourceBundle;

public class addPatient implements Initializable {

    public static ConnectMSSQLServer connection;

    @FXML
    public TextField addPatientName, addPatientSurname, addPatientPesel;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
    }
    public void back(ActionEvent actionEvent) {
        Controller.stage.setScene(Main.scene);
    }

    public void addPatient(ActionEvent actionEvent) {
        String query = "EXEC dodaj_pacjenta\n" +
                "\t@imie = N'"+addPatientName.getText()+"',\n" +
                "\t@nazwisko = N'"+addPatientSurname.getText()+"',\n" +
                "\t@pesel = N'"+Integer.parseInt(addPatientPesel.getText())+"'";
        connection.query(query);
        Controller.stage.setScene(Main.scene);
    }


}
