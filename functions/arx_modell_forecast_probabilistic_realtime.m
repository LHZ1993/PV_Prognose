function Prognose_mitError = arx_modell_forecast_probabilistic_realtime(Prognose, ClearSky, Methode, Quantile)
    
    index1 = find(ClearSky.Zeit == Prognose.Zeit(1));
    index2 =find(ClearSky.Zeit == Prognose.Zeit(end));

    CS = ClearSky.Leistung(index1:index2);
    
    Prognose.CS = CS;
    Prognose.LeistungPro = Prognose.CS .* Prognose.RelPro;
    
    %Monte Carlo Simulation
    if Methode ==1
        
        VariableNames = {'Zeit','CDF','Quantile_05','Quantile_10','Quantile_15', 'Quantile_20','Quantile_25','Quantile_30','Quantile_35','Quantile_40','Quantile_45','Quantile_50' , ...
    'Quantile_55','Quantile_60','Quantile_65','Quantile_70','Quantile_75','Quantile_80','Quantile_85'...
    ,'Quantile_90','Quantile_95'};
        CDF = table(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'VariableNames',VariableNames);

        for i = 1: size(Prognose.Zeit,1)

            Zeit = datenum(Prognose.Zeit(i));

            if Prognose.MonteCarlo {i,1}== 0

                Zeile = {Zeit, 0, 0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
                CDF = [CDF; Zeile];
                continue
            end

            temp = cell2mat(Prognose.MonteCarlo(i));
            
            Quantile_05 = prctile(temp,5);
            Quantile_10 = prctile(temp,10);
            Quantile_15 = prctile(temp,15);
            Quantile_20 = prctile(temp,20);
            Quantile_25 = prctile(temp,25);
            Quantile_30 = prctile(temp,30);
            Quantile_35 = prctile(temp,35);
            Quantile_40 = prctile(temp,40);
            Quantile_45 = prctile(temp,45);
            Quantile_50 = prctile(temp,50);
            Quantile_55 = prctile(temp,55);
            Quantile_60 = prctile(temp,60);
            Quantile_65 = prctile(temp,65);
            Quantile_70 = prctile(temp,70);
            Quantile_75 = prctile(temp,75);
            Quantile_80 = prctile(temp,10);
            Quantile_85 = prctile(temp,85);
            Quantile_90 = prctile(temp,90);
            Quantile_95 = prctile(temp,95);


            Zeile = {Zeit, 0, Quantile_05,Quantile_10,Quantile_15,Quantile_20,Quantile_25,Quantile_30...
                ,Quantile_35,Quantile_40,Quantile_45,Quantile_50,Quantile_55,Quantile_60,Quantile_65...
                ,Quantile_70,Quantile_75,Quantile_80,Quantile_85,Quantile_90,Quantile_95};
            CDF = [CDF; Zeile];

            Prognose.MonteCarlo(i) = {temp .* Prognose.CS(i)};
        end

        CDF(1,:) = [];
        
        Prognose.Quantile_05 = CDF.Quantile_05 .* Prognose.CS;
        Prognose.Quantile_10 = CDF.Quantile_10 .* Prognose.CS;
        Prognose.Quantile_15 = CDF.Quantile_15 .* Prognose.CS;
        Prognose.Quantile_20 = CDF.Quantile_20 .* Prognose.CS;
        Prognose.Quantile_25 = CDF.Quantile_25 .* Prognose.CS;
        Prognose.Quantile_30 = CDF.Quantile_30 .* Prognose.CS;
        Prognose.Quantile_35 = CDF.Quantile_35 .* Prognose.CS;
        Prognose.Quantile_40 = CDF.Quantile_40 .* Prognose.CS;
        Prognose.Quantile_45 = CDF.Quantile_45 .* Prognose.CS;
        Prognose.Quantile_50 = CDF.Quantile_50 .* Prognose.CS;
        Prognose.Quantile_55 = CDF.Quantile_55 .* Prognose.CS;
        Prognose.Quantile_60 = CDF.Quantile_60 .* Prognose.CS;
        Prognose.Quantile_65 = CDF.Quantile_65 .* Prognose.CS;
        Prognose.Quantile_70 = CDF.Quantile_70 .* Prognose.CS;
        Prognose.Quantile_75 = CDF.Quantile_75 .* Prognose.CS;
        Prognose.Quantile_80 = CDF.Quantile_80 .* Prognose.CS;
        Prognose.Quantile_85 = CDF.Quantile_85 .* Prognose.CS;
        Prognose.Quantile_90 = CDF.Quantile_90 .* Prognose.CS;
        Prognose.Quantile_95 = CDF.Quantile_95 .* Prognose.CS;
        %Prognose.Quantile_1 = CDF.Quantile_1 .* Prognose.CS;
        %Prognose.UP = CDF.UP .* Prognose.CS;

        Prognose_mitError = Prognose;
    
    %Quantile Regressinon
    elseif Methode ==2

        RelPro=Prognose.RelPro;
        
        %for col = 1 : size(Quantile ,2)
            
           %Quantile(find((table2array(Quantile( : , col)) < 0)), col ) = 0;
           
        %end
        
        Prognose.Quantile_05 = Quantile.Quantile_05 .* Prognose.CS .* RelPro;
        Prognose.Quantile_10 = Quantile.Quantile_10 .* Prognose.CS .* RelPro;
        Prognose.Quantile_15 = Quantile.Quantile_15 .* Prognose.CS .* RelPro;
        Prognose.Quantile_20 = Quantile.Quantile_20 .* Prognose.CS .* RelPro;
        Prognose.Quantile_25 = Quantile.Quantile_25 .* Prognose.CS .* RelPro;
        Prognose.Quantile_30 = Quantile.Quantile_30 .* Prognose.CS .* RelPro;
        Prognose.Quantile_35 = Quantile.Quantile_35 .* Prognose.CS .* RelPro;
        Prognose.Quantile_40 = Quantile.Quantile_40 .* Prognose.CS .* RelPro;
        Prognose.Quantile_45 = Quantile.Quantile_45 .* Prognose.CS .* RelPro;
        Prognose.Quantile_50 = Quantile.Quantile_50 .* Prognose.CS .* RelPro;
        Prognose.Quantile_55 = Quantile.Quantile_55 .* Prognose.CS .* RelPro;
        Prognose.Quantile_60 = Quantile.Quantile_60 .* Prognose.CS .* RelPro;
        Prognose.Quantile_65 = Quantile.Quantile_65 .* Prognose.CS .* RelPro;
        Prognose.Quantile_70 = Quantile.Quantile_70 .* Prognose.CS .* RelPro;
        Prognose.Quantile_75 = Quantile.Quantile_75 .* Prognose.CS .* RelPro;
        Prognose.Quantile_80 = Quantile.Quantile_80 .* Prognose.CS .* RelPro;
        Prognose.Quantile_85 = Quantile.Quantile_85 .* Prognose.CS .* RelPro;
        Prognose.Quantile_90 = Quantile.Quantile_90 .* Prognose.CS .* RelPro;
        Prognose.Quantile_95 = Quantile.Quantile_95 .* Prognose.CS .* RelPro;
        
        Prognose_mitError = Prognose;
        
        
        %K = Prognose.K_Step;
        %hx = 30;
        %fprintf('Berechnung der Quantile Regession: \n')

        %Quantile_1 = quantile_regession(K, RelPro ,0.1, hx);
        %Quantile_2 = quantile_regession(K, RelPro ,0.2, hx);
        %Quantile_3 = quantile_regession(K, RelPro ,0.3, hx);
        %Quantile_4 = quantile_regession(K, RelPro ,0.4, hx);
        %Quantile_5 = quantile_regession(K, RelPro ,0.5, hx);
        %Quantile_6 = quantile_regession(K, RelPro ,0.6, hx);
        %Quantile_7 = quantile_regession(K, RelPro ,0.7, hx);
        %Quantile_8 = quantile_regession(K, RelPro ,0.8, hx);
        %Quantile_9 = quantile_regession(K, RelPro ,0.8, hx);

        %Prognose.Quantile_1 = Quantile_1 .* Prognose.RelPro .* Prognose.CS;
        %Prognose.Quantile_2 = Quantile_2 .* Prognose.RelPro .* Prognose.CS;
        %Prognose.Quantile_3 = Quantile_3 .* Prognose.RelPro .* Prognose.CS;
        %Prognose.Quantile_4 = Quantile_4 .* Prognose.RelPro .* Prognose.CS;
        %Prognose.Quantile_5 = Quantile_5 .* Prognose.RelPro .* Prognose.CS;
        %Prognose.Quantile_6 = Quantile_6 .* Prognose.RelPro .* Prognose.CS;
        %Prognose.Quantile_7 = Quantile_7 .* Prognose.RelPro .* Prognose.CS;
        %Prognose.Quantile_8 = Quantile_8 .* Prognose.RelPro .* Prognose.CS;
        %Prognose.Quantile_9 = Quantile_9 .* Prognose.RelPro .* Prognose.CS;
        
        %Prognose_mitError = Prognose;
        
    end
end
    
    


