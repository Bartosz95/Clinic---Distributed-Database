package sample;


import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.input.MouseEvent;
import javafx.stage.Stage;
import java.net.URL;
import java.sql.ResultSet;
import java.util.ResourceBundle;


public class Controller implements Initializable {

    public static Stage stage;

    private String hostName, dbName, user, password;

    @FXML
    public ListView<Clinic> clinicListView;
    @FXML
    public Label clinicName, clinicCity, clinicStreet;

    @FXML
    public ListView<Doctor> doctorListView;
    @FXML
    public Label doctorName, doctorSurname, doctorTitle, doctorSpecialization, doctorClinicName, doctorSalary;

    @FXML
    public ListView<Patient>  patientListView;
    @FXML
    public Label patientName, patientSurname, patientPesel;

    @FXML
    public Label visitDescription;
    @FXML
    public TableView <Visit> visitTable;
    @FXML
    public TableColumn<Visit, String> visitPatientName, visitPatientSurname, visitDoctorName, visitDoctorSurname, visitData, visitTime;

    @FXML
    public TableView <Investigation> investigationTable;
    @FXML
    public TableColumn<Investigation, String> investigationName, investigationSurname, investigationPesel, investigationType;
    @FXML
    public Label investigationResult;

    public void initialize(URL location, ResourceBundle resources) {
        this.hostName = "192.168.43.5";
        this.dbName = "firma_medyczna";
        this.user = "sa";
        this.password = "Student1";

        clinicListView.setItems(getClinicListView());
        clinicListView.setOnMouseClicked(new EventHandler<MouseEvent>() {
            @Override
            public void handle(MouseEvent event) {
                clinicName.setText(clinicListView.getSelectionModel().getSelectedItem().getName());
                clinicCity.setText(clinicListView.getSelectionModel().getSelectedItem().getCity());
                clinicStreet.setText(clinicListView.getSelectionModel().getSelectedItem().getStreet());
            }
        });

        doctorListView.setItems(getDoctorListView());
        doctorListView.setOnMouseClicked(new EventHandler<MouseEvent>() {
            @Override
            public void handle(MouseEvent event) {
                doctorName.setText(doctorListView.getSelectionModel().getSelectedItem().getName());
                doctorSurname.setText(doctorListView.getSelectionModel().getSelectedItem().getSurname());
                doctorTitle.setText(doctorListView.getSelectionModel().getSelectedItem().getTitle());
                doctorSpecialization.setText(doctorListView.getSelectionModel().getSelectedItem().getSpecialization());
                doctorClinicName.setText(doctorListView.getSelectionModel().getSelectedItem().getClinic());
                doctorSalary.setText(Integer.toString(doctorListView.getSelectionModel().getSelectedItem().getSalary()));
            }
        });

        patientListView.setItems(getPatientListView());
        patientListView.setOnMouseClicked(new EventHandler<MouseEvent>() {
            @Override
            public void handle(MouseEvent event) {
                patientName.setText(patientListView.getSelectionModel().getSelectedItem().getName());
                patientSurname.setText(patientListView.getSelectionModel().getSelectedItem().getSurname());
                patientPesel.setText(Integer.toString(patientListView.getSelectionModel().getSelectedItem().getPesel()));
            }
        });

        visitPatientName.setCellValueFactory(new PropertyValueFactory<Visit,String>("patientName"));
        visitPatientSurname.setCellValueFactory(new PropertyValueFactory<Visit,String>("patientSurname"));
        visitDoctorName.setCellValueFactory(new PropertyValueFactory<Visit,String>("doctorName"));
        visitDoctorSurname.setCellValueFactory(new PropertyValueFactory<Visit,String>("doctorSurname"));
        visitData.setCellValueFactory(new PropertyValueFactory<Visit, String>("date"));
        visitTime.setCellValueFactory(new PropertyValueFactory<Visit, String>("time"));
        visitTable.setItems(getVisitTable());
        visitTable.setOnMouseClicked(new EventHandler<MouseEvent>() {
            @Override
            public void handle(MouseEvent event) {
                visitDescription.setText(visitTable.getSelectionModel().getSelectedItem().getDescription());
            }
        });

        investigationName.setCellValueFactory(new PropertyValueFactory<Investigation,String>("name"));
        investigationSurname.setCellValueFactory(new PropertyValueFactory<Investigation,String>("surname"));
        investigationPesel.setCellValueFactory(new PropertyValueFactory<Investigation,String>("pesel"));
        investigationType.setCellValueFactory(new PropertyValueFactory<Investigation,String>("type"));
        investigationTable.setItems(getInvestigationTable());
        investigationTable.setOnMouseClicked(new EventHandler<MouseEvent>() {
            @Override
            public void handle(MouseEvent event) {
                investigationResult.setText(investigationTable.getSelectionModel().getSelectedItem().getResult());
            }
        });
    }

    private  ObservableList<Clinic> getClinicListView(){
        ObservableList<Clinic> list = FXCollections.observableArrayList();
        try{
            ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            ResultSet result = connection.query("select * from przychodnie");
            while (result.next()) {
                list.add(new Clinic(result.getInt(1), result.getString(2),result.getString(3), result.getString(4)));
            }

        } catch (Exception e){
            System.out.println(e.toString());
        }
        return list;
    }

    private ObservableList<Doctor> getDoctorListView(){
        ObservableList<Doctor> list = FXCollections.observableArrayList();
        try{
            ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            ResultSet result = connection.query("select * from lekarze");
            while (result.next()) {
                list.add(new Doctor( result.getInt(1), result.getString(2), result.getString(3), result.getString(4), result.getString(5), result.getString(6), result.getInt(7)));
            }
        } catch (Exception e){
            System.out.println(e.toString());
        }
        return list;
    }

    private ObservableList<Patient> getPatientListView(){
        ObservableList<Patient> list = FXCollections.observableArrayList();
        try{
            ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            ResultSet result = connection.query("select * from pacjenci");
            while (result.next()) {
                list.add(new Patient(result.getInt(1),result.getString(2), result.getString(3), result.getInt(4)));
            }
        } catch (Exception e){
            System.out.println(e.toString());
        }
        return list;
    }

    private ObservableList<Visit> getVisitTable(){
        ObservableList<Visit> list = FXCollections.observableArrayList();
        try{
            ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            ResultSet result = connection.query("select * from wizyty");
            while (result.next()) {
                list.add(new Visit(result.getInt(1), result.getInt(2), result.getString(3), result.getString(4), result.getInt(5),result.getString(6), result.getString(7), result.getDate(8),result.getTime(9),result.getString(10)));
            }
        } catch (Exception e){
            System.out.println(e.toString());
        }
        return list;
    }

    private ObservableList<Investigation> getInvestigationTable(){
        ObservableList<Investigation> list = FXCollections.observableArrayList();
        try{
            ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            ResultSet result = connection.query("select * from badania");
            while (result.next()) {
                list.add(new Investigation(result.getInt(1), result.getInt(2), result.getString(3), result.getString(4), result.getInt(5),result.getString(6), result.getString(7)));
            }
        } catch (Exception e){
            System.out.println(e.toString());
        }
        return list;
    }

    public void clinicAdd(ActionEvent actionEvent) {
        try {
            addClinic.connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            stage.setScene(new Scene(FXMLLoader.load(getClass().getResource("addClinic.fxml"))));
        }catch (Exception e){
            System.out.println(e.toString());
        }
    }

    public void clinicDelete(ActionEvent actionEvent) {
        String query = "EXEC usun_przychodnie" +
                "\n@nazwa = N'"+clinicListView.getSelectionModel().getSelectedItem().getName()+"'," +
                "\n@miasto = N'"+clinicListView.getSelectionModel().getSelectedItem().getCity()+"'," +
                "\n@ulica = N'"+clinicListView.getSelectionModel().getSelectedItem().getStreet()+"'";
        System.out.println(query);
        ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
        connection.query(query);
        Controller.stage.setScene(Main.scene);
        this.refresh(new ActionEvent());
    }

    public void doctorAdd(ActionEvent actionEvent) {
        try {
            addDoctor.connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            stage.setScene(new Scene(FXMLLoader.load(getClass().getResource("addDoctor.fxml"))));
        }catch (Exception e){
            System.out.println(e.toString());
        }
    }

    public void doctorDelete(ActionEvent actionEvent) {
        ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
        String query = "EXEC usun_lekarza" +
                "\n@imie = N'"+doctorListView.getSelectionModel().getSelectedItem().getName()+"'," +
                "\n@nazwisko = N'"+doctorListView.getSelectionModel().getSelectedItem().getSurname()+"'";
        connection.query(query);
        this.refresh(new ActionEvent());
    }

    public void patientAdd(ActionEvent actionEvent) {
        try {
            addPatient.connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            stage.setScene(new Scene(FXMLLoader.load(getClass().getResource("addPatient.fxml"))));
        }catch (Exception e){
            System.out.println(e.toString());
        }
    }

    public void patientDelete(ActionEvent actionEvent) {
        ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
        String query = "EXEC usun_pacjenta" +
                "\n@imie = N'"+patientListView.getSelectionModel().getSelectedItem().getName()+"'," +
                "\n@nazwisko = N'"+patientListView.getSelectionModel().getSelectedItem().getSurname()+"',"+
                "\n@pesel = N'"+patientListView.getSelectionModel().getSelectedItem().getPesel()+"'";
        connection.query(query);
        this.refresh(new ActionEvent());
    }

    public void visitAdd(ActionEvent actionEvent) {
        try {
            addVisit.connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            stage.setScene(new Scene(FXMLLoader.load(getClass().getResource("addVisit.fxml"))));
        }catch (Exception e){
            System.out.println(e.toString());
        }
    }

    public void visitDelete(ActionEvent actionEvent) {
        ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
        String query = "usun_wizyte\n" +
                "\t@imie_lekarza\t\t= N'"+visitTable.getSelectionModel().getSelectedItem().getDoctorName()+"',\n" +
                "\t@nazwisko_lekarza\t= N'"+visitTable.getSelectionModel().getSelectedItem().getDoctorSurname()+"',\n" +
                "\t@imie_pacjenta\t\t= N'"+visitTable.getSelectionModel().getSelectedItem().getPatientName()+"',\n" +
                "\t@nazwisko_pacjenta\t= N'"+visitTable.getSelectionModel().getSelectedItem().getPatientSurname()+"',\n" +
                "\t@data\t\t\t\t= N'"+visitTable.getSelectionModel().getSelectedItem().getDate()+"',\n" +
                "\t@godzina\t\t\t= N'"+visitTable.getSelectionModel().getSelectedItem().getTime()+"'";
        connection.query(query);
        this.refresh(new ActionEvent());
    }

    public void investigationAdd(ActionEvent actionEvent) {
        try {
            addInvestigation.connection = new ConnectMSSQLServer(hostName, dbName, user, password);
            stage.setScene(new Scene(FXMLLoader.load(getClass().getResource("addInvestigation.fxml"))));
        }catch (Exception e){
            System.out.println(e.toString());
        }
    }

    public void investigationDelete(ActionEvent actionEvent) {
        ConnectMSSQLServer connection = new ConnectMSSQLServer(hostName, dbName, user, password);
        String query = "EXEC usun_badanie\n" +
                "\t@imie\t\t= N'"+investigationTable.getSelectionModel().getSelectedItem().getName()+"',\n" +
                "\t@nazwisko\t= N'"+investigationTable.getSelectionModel().getSelectedItem().getSurname()+"',\n" +
                "\t@pesel\t\t= N'"+investigationTable.getSelectionModel().getSelectedItem().getPesel()+"',\n" +
                "\t@typ\t\t= N'"+investigationTable.getSelectionModel().getSelectedItem().getType()+"'";
        connection.query(query);
        this.refresh(new ActionEvent());
    }

    public void refresh(ActionEvent actionEvent) {
        clinicListView.getItems().removeAll();
        clinicListView.setItems(getClinicListView());

        doctorListView.getItems().removeAll();
        doctorListView.setItems(getDoctorListView());

        patientListView.getItems().removeAll();
        patientListView.setItems(getPatientListView());

        visitTable.getItems().removeAll();
        visitTable.setItems(getVisitTable());

        investigationTable.getItems().removeAll();
        investigationTable.setItems(getInvestigationTable());
    }
}
