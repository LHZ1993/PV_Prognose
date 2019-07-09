function [EstModell, Quantile] = database2model(DatenbankPath,DatenbankName,TableName)
%Tabelle in ModellParametern.db :
%Tabelle1 >>> BewoelkerungNormal_2018_10_27_17_45_0_CS_18
%Tabelle2 >>> BewoelkerungNormal_2018_10_27_17_45_0_CS_35

%Tabelle3 >>> TemperaturNormal_2018_10_27_17_45_0_CS_18
%Tabelle4 >>> TemperaturNormal_2018_10_27_17_45_0_CS_35

%Tabelle5 >>> BewoelkerungRelative_2018_10_27_17_45_0_CS_18
%Tabelle6 >>> BewoelkerungRelative_2018_10_27_17_45_0_CS_35

%Tabelle7 >>> TemperaturRelative_2018_10_27_17_45_0_CS_18
%Tabelle8 >>> TemperaturRelative_2018_10_27_17_45_0_CS_35

    
    outputdata = read_data_db(DatenbankPath,DatenbankName,TableName);
    fprintf('start to read AR modell parameters to Matlab \n');
    k = size(outputdata,1);
    Modell = {};
    %Quantile= table(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ,'VariableNames' , {'Quantile_10',...
        %'Quantile_15', 'Quantile_20', 'Quantile_25', 'Quantile_30', 'Quantile_35', 'Quantile_40',...
        %'Quantile_45', 'Quantile_50', 'Quantile_55', 'Quantile_60', 'Quantile_65', 'Quantile_70', ...
        %'Quantile_75', 'Quantile_80', 'Quantile_85', 'Quantile_90'});
    
    for i = 1:k

        P = outputdata.P(i);
        fitmodell = arima(P,0,0);
        fitmodell.Constant = outputdata.Constant(i);
        fitmodell.AR{1,i} = outputdata.AR_first(i);
        fitmodell.AR{1,P} = outputdata.AR_second(i);
        fitmodell.Beta = outputdata.Beta(i);
        fitmodell.Variance = outputdata.Var(i);

        %for ar = 1 :size(fitmodell.AR,2)

            %if isnan(fitmodell.AR{1,ar})
                %fitmodell.AR{1, ar} = 0;
                %continue
            %end

        %end

        AR = fitmodell.AR;
        ind = cellfun(@(x) any(isnan(x)), AR);
        AR(ind) = {0} ;
        fitmodell.AR = AR;
        
        Modell{i,1} = i;
        Modell{i,2} = fitmodell;
        
        if (mod(i,20) == 0)||(i == k )

            fprintf('Fortschritt: %.1f%% \n', i/287*100);

        end

    end
    
   
    Quantile = outputdata(:, 8:24);
    EstModell = Modell;
    

end

