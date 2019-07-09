function write_table_db(DatenbankPath,DatenbankName,NewTableName,MatDaten)
%Durch diese Funkion wird Matlab table() Daten in Datebase gespeichert.
%Achtung: Wenn eine Zeit VarableName vorhanden ist, muss die Zeit Daten in
%datetime Type sein und steht in der ersten Spalte in einer Tabelle.

%set up database
datasource = ''; %do not need to change
Driver = 'org.sqlite.JDBC';
URL= strcat('jdbc:sqlite:', DatenbankPath, DatenbankName);

%connect database
conn = database(datasource, '', '',Driver, URL);%without user or password

%if the message property is empty then connection successful
conn_stat = conn.Message();

%if connection successful,star to insert data to database
if (isempty(conn_stat)== 1)
    fprintf('start to insert new table to database\n');
    
    zeit_vorhanden = 0;
    
    %check if there is a Zeit variable 
    col_names = MatDaten.Properties.VariableNames;
    
    for iname = 1:size(col_names,2)
        if strcmp(col_names{1,iname}, 'Zeit')
            zeit_vorhanden = 1;
            break
        else 
            zeit_vorhanden = 0;
        end
    end
    
    %wenn there is a Zeit column in table then change datetime type to cell
    if (zeit_vorhanden == 1)
        formatOut = 31; %time format'yyyy-mm-dd HH:MM:SS'
        MatDaten.Zeit = datestr(MatDaten.Zeit, formatOut);
        temp = table2cell(MatDaten);
        MatDaten.Zeit = temp(:,1);
        sqlwrite(conn, NewTableName,MatDaten)
        Info = strcat('write new data to\t',  NewTableName,' successful\n');
        fprintf(Info)
    %wenn there is no Zeit in table than do not change
    else
        sqlwrite(conn, NewTableName,MatDaten)
        Info = strcat('write new data to\t',  NewTableName, ' successful\n');
        fprintf(Info)
    end
 
    
%if connection not successful print erroe infos   
else
    Info = conn_stat;
    fprintf(Info); 
end

end

