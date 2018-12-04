package sample;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.ComboBox;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;

import java.net.URL;
import java.sql.ResultSet;
import java.util.ResourceBundle;

public class addInvestigation implements Initializable {

    public static ConnectMSSQLServer connection;

    @FXML
    public TextField addInvestigationType;
    @FXML
    public TextArea addInvestigationDescription;
    @FXML
    ComboBox<Patient> addInvestigationPatient;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        addInvestigationPatient.setItems(getPatient());
    }
    public void back(ActionEvent actionEvent) {
        Controller.stage.setScene(Main.scene);
    }

    public void addInvestigation(ActionEvent actionEvent) {
        String query = "EXEC dodaj_badanie\n" +
                "@imie\t\t= N'"+addInvestigationPatient.getSelectionModel().getSelectedItem().getName()+"',\n" +
                "@nazwisko\t= N'"+addInvestigationPatient.getSelectionModel().getSelectedItem().getSurname()+"',\n" +
                "@wyniki\t\t= N'"+ addInvestigationDescription.getText()+"', \n" +
                "@typ\t\t= N'"+addInvestigationType.getText()+"'";
        System.out.println(query);
        connection.query(query);
        Controller.stage.setScene(Main.scene);
    }

    private ObservableList<Patient> getPatient(){
        ObservableList<Patient> list = FXCollections.observableArrayList();
        try{
            ResultSet result = connection.query("select * from pacjenci");
            while (result.next()) {
                list.add(new Patient(result.getInt(1),result.getString(2), result.getString(3), result.getInt(4)));
            }
        } catch (Exception e){
            System.out.println(e.toString());
        }
        return list;
    }
}
