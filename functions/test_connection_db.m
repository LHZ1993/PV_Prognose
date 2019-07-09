function Info = test_connection_db(DatenbankPath, DatenbankName)
%In dieser Funktion wird die Verbindung mit Database getestet.
%Inputs entsprechen Pfad und Name von Datebase.
%Output bietet Verbindunginformation an.

%set up database
datasource = ''; %do not need to change
Driver = 'org.sqlite.JDBC';
URL= strcat('jdbc:sqlite:', DatenbankPath, DatenbankName);

%connect database
conn = database(datasource, '', '',Driver, URL);%without user or password

%if the message property is empty then connection successful
conn_stat = conn.Message();

if (isempty(conn_stat)== 1)
    Info = 'connection successful\n';
else
    Info = conn_stat;
end
    

close(conn)

end


