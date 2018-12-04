package sample;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.ComboBox;
import javafx.scene.control.DatePicker;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;

import java.net.URL;
import java.sql.ResultSet;
import java.util.ResourceBundle;

public class addVisit implements Initializable {

    public static ConnectMSSQLServer connection;

    @FXML
    public TextField addVisitTime;
    @FXML
    public DatePicker addVisitDate;
    @FXML
    public TextArea addVisitDescription;
    @FXML
    public ComboBox<Doctor> addVisitDoctor;
    @FXML
    public ComboBox<Patient> addVisitPatient;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        addVisitDoctor.setItems(getDoctor());
        addVisitPatient.setItems(getPatient());
    }
    public void back(ActionEvent actionEvent) {
        Controller.stage.setScene(Main.scene);
    }

    public void addVisit(ActionEvent actionEvent) {
        String query = "EXEC dodaj_wizyte\n" +
                "\t@imie_lekarza\t\t= N'"+addVisitDoctor.getSelectionModel().getSelectedItem().getName()+"',\n" +
                "\t@nazwisko_lekarza\t= N'"+addVisitDoctor.getSelectionModel().getSelectedItem().getSurname()+"',\n" +
                "\t@imie_pacjenta\t\t= N'"+addVisitPatient.getSelectionModel().getSelectedItem().getName()+"',\n" +
                "\t@nazwisko_pacjenta\t= N'"+addVisitPatient.getSelectionModel().getSelectedItem().getSurname()+"',\n" +
                "\t@data\t\t\t\t= N'"+addVisitDate.getValue()+"',\n" +
                "\t@godzina\t\t\t= N'"+addVisitTime.getText()+"', \n" +
                "\t@opis\t\t\t\t= N'"+addVisitDescription.getText()+"'";
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

    private ObservableList<Doctor> getDoctor(){
        ObservableList<Doctor> list = FXCollections.observableArrayList();
        try{
            ResultSet result = connection.query("select * from lekarze");
            while (result.next()) {
                list.add(new Doctor( result.getInt(1), result.getString(2), result.getString(3), result.getString(4), result.getString(5), result.getString(6), result.getInt(7)));
            }
        } catch (Exception e){
            System.out.println(e.toString());
        }
        return list;
    }
}
