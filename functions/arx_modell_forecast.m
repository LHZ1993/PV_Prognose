function Ergebnisse = arx_modell_forecast(Y , X , Xf , K_Step , AkteullZeit, Modell)

    i = 96;
    NachtZeit = [0,1,2,3,4,5,6,21,22,23];
    
    Prognose = table(0,0,0,0,'VariableNames',{'Zeit','K_Step', 'RelPro','MonteCarlo'});
    fprintf('Prognose beginnt um %s \n', AkteullZeit);
    
    for k = 1: K_Step

        Duration = minutes(15);
        Zeit = datenum(AkteullZeit+ k*Duration);
        Hour = hour(AkteullZeit+ k*Duration);
        
        %Wenn vorherzusagenden Zeitpunkte in der Nacht, dann nicht berechnen
        if ismember(Hour, NachtZeit)
            Zeile = {Zeit, k, 0, {0}};
            Prognose = [Prognose;Zeile];
            
            if (k == K_Step)
            fprintf('Fortschritt: %.1f%% \n',100*k/K_Step);
            end
            
            continue
        end
        
        fitmodel = Modell{k,2};
        
        yf = forecast(fitmodel,k ,'Y0',Y, 'X0', X, 'XF', Xf(1:k));
        yf_last = yf(end);
        
        %[E] = infer(fitmodel , Y, 'X', X);
        
        %Monte Carlo Simulation durchfuehren
        V = fitmodel.Variance;
        %[ysim] = simulate(fitmodel, k , 'NumPaths',1000, 'Y0',Y , 'X',X,'E0',E);
        [ysim] = simulate(fitmodel, k , 'NumPaths',1000, 'Y0',Y , 'X',X, 'V0', V);
        ysim = ysim(end,:);
        ysim_last = ysim(ysim>0);
        ysim_last = {ysim_last};
        
        %Zeile = {Zeit, k, yf_last, ysim_last};
        Zeile = {Zeit, k, yf_last, ysim_last};
        Prognose = [Prognose;Zeile];
        
        
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
    
    Prognose(1,:) = [];
    Prognose.Zeit = datetime(Prognose.Zeit, 'ConvertFrom', 'datenum');
    
    Ergebnisse = Prognose;
end
        
        


    
    
    

