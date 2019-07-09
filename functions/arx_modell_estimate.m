function  [Modell, Quantile] = arx_modell_estimate(Y0, X0 , K_Step, Zeit)
%Input Y0 >>> Endogener Eingang des ARX-Modells
%Input XO >>> Exogener Eingang des ARX_Modells
%Input K_Step >>> Prognosehorizont(maximal 287)
%Input Zeit >>> Endzeitpunkt der Trainingsdaten 
%Output Modell >>> für deterministische Prognose
%Outpt Quantile >>> für probabilistische Prognose
%K_Step Prognose:287 entpricht 3 day-ahead, 191 entpricht 2 day-ahead, 95 entspricht 1 day-ahead

    i = 96;
    Modell = {};
    %Prognose = table(0,0,0,0,'VariableNames',{'Zeit','K_Step', 'RelPro','MonteCarlo'});
    fprintf('Berechnen ARX Modell Parametern \n');
    fprintf('Training Daten bis %s \n', datestr(Zeit));
    
    for k = 1: K_Step

        model = arima('ARLags', [k, i]);
        fitmodel = estimate(model, Y0, 'X', X0, 'Display','off');
        
        Modell{k,1} = k;
        Modell{k,2} = fitmodel;
        
        %Berechnen Quantile Regression
        [E] = infer(fitmodel , Y0, 'X', X0);
        
        Residuals = table() ;
        Residuals.Y = Y0;
        Residuals.E = E;
        Residuals.X = Y0 - E;
        
        Modell{k ,3} = Residuals;
        
        for tau = 0.05: 0.05: 0.95  
            
            Q = linear_quantile_regression(tau,Residuals.X, Residuals.Y);
            
            if Q < 0
                Q = 0;
            end
            
            Modell{k, int16(tau*20 +3)} = Q;
            
        end
        
        
        if (mod(k, 10)==0)||(k == K_Step)
            fprintf('Fortschritt: %.1f%% \n',100*k/K_Step);
        end

        if k == 95
            i = 192;
        end

        if k == 191
            i = 288; 
        end

    end
    
    Quantile = cell2table(Modell(:, 4:22),'VariableNames',{'Quantile_05','Quantile_10','Quantile_15', 'Quantile_20','Quantile_25','Quantile_30','Quantile_35','Quantile_40','Quantile_45','Quantile_50' , ...
    'Quantile_55','Quantile_60','Quantile_65','Quantile_70','Quantile_75','Quantile_80','Quantile_85'...
    ,'Quantile_90','Quantile_95'});

    
end

