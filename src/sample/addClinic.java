package sample;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.TextField;

import java.net.URL;
import java.util.ResourceBundle;

public class addClinic implements Initializable {

    public static ConnectMSSQLServer connection;

    @FXML
    public TextField addClinicName, addClinicCity, addClinicStreet;

    @Override
    public void initialize(URL location, ResourceBundle resources) {

    }

    public void back(ActionEvent actionEvent) {
        Controller.stage.setScene(Main.scene);
    }

    public void addClinic(ActionEvent actionEvent) {
        String query = "EXEC dodaj_przychodnie " +
                "\n@nazwa = N'"+addClinicName.getText()+"'," +
                "\n@miasto = N'"+addClinicCity.getText()+"'," +
                "\n@ulica = N'"+addClinicStreet.getText()+"'";
        connection.query(query);
        Controller.stage.setScene(Main.scene);
    }
}
