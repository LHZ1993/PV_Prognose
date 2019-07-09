function outputdata = read_data_db(DatenbankPath,DatenbankName,TableName)
%Durch diese Funktion wird die in Datebase gespeicherten Daten in Matlab
%importiert. Achtung: alle Zeit Daten hat Format 'yyyy-MM-dd HH:mm:ss' 
%Input TableName entspricht dem Tabllename in Database.
%Output ist in Database gespeicherten Daten.

%set up database
datasource = ''; %do not need to change
Driver = 'org.sqlite.JDBC';
URL= strcat('jdbc:sqlite:', DatenbankPath, DatenbankName);

%connect database
conn = database(datasource, '', '',Driver, URL);%without user or password

%if the message property is empty then connection successful
conn_stat = conn.Message();

%if connection successful,star to read data
if (isempty(conn_stat)== 1)
    
    fprintf('start to read data\n');
    outputdata = sqlread(conn, TableName); %read data from database
    
    %find if there is a colunms names Zeit
    zeit_vorhanden = 0;
    col_names = outputdata.Properties.VariableNames;
    
    for iname = 1:size(col_names,2)
        if strcmp(col_names{1,iname}, 'Zeit')
            zeit_vorhanden = 1;
            break
        else 
            zeit_vorhanden = 0;
        end
    end
    
    %if there is a Zeit column in table, then change the data type to
    %datetime and read them to matlab
    if (zeit_vorhanden == 1)
        outputdata.Zeit = datetime(outputdata.Zeit,'InputFormat','yyyy-MM-dd HH:mm:ss','Format', 'yyyy-MM-dd HH:mm:ss');
        Info = strcat('read\t',  TableName, ' in to matlab successful\n');
        fprintf(Info);
   
    %if there is no Zeit colunm in table, then read data to matlab   
    else
        Info = strcat('read\t',  TableName, ' in to matlab successful\n');
        fprintf(Info);
    end
%if connection not successful print erroe infos    
else
    Info = conn_stat;
    fprintf(Info); 

end

close(conn)

end

