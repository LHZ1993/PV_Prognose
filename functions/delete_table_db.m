function delete_table_db(DatenbankPath,DatenbankName, TableName)

    %set up database
    datasource = ''; %do not need to change
    Driver = 'org.sqlite.JDBC';
    URL= strcat('jdbc:sqlite:', DatenbankPath, DatenbankName);

    %connect database
    conn = database(datasource, '', '',Driver, URL);%without user or password

    %if the message property is empty then connection successful
    conn_stat = conn.Message();

    if (isempty(conn_stat)== 1)
       
        sqlquery = ['DROP TABLE ' TableName];
        execute(conn,sqlquery);
        fprintf(strcat('delete table : ',TableName, '\n') );
        
    else
        Info = conn_stat;
        fprintf(Info); 
    end

end

