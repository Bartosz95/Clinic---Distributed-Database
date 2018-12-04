package sample;

import java.sql.*;

public class ConnectMSSQLServer
{
    private static String hostName, dbName, user, password;


    public ConnectMSSQLServer(String hostName, String dbName, String user, String password){
        this.hostName = hostName;
        this.dbName = dbName;
        this.user = user;
        this.password = password;
    }


    public ResultSet query(String query){
        try{

            Connection connection = DriverManager.getConnection("jdbc:sqlserver://"+hostName+";databaseName="+dbName, user, password);
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            CallableStatement call = connection.prepareCall(query);
            return call.executeQuery();
        }catch (Exception e){
            System.out.println("Error execute query");
            e.printStackTrace();
        }
        return null;
    }
}