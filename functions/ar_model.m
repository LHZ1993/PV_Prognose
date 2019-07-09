function Prognose = ar_model(TestData,AkteullZeit)
%Durch diese Funktion wird das AutoRegression Modell nach Bachers Paper
%aufgebaut. Input Variable TestData ist table() und inklusive einer Spalte
%Rel, naemlich entspricht TestData.Rel der normalisierten PV Leistung.
%Input Variable ist der Zeitpunkt, wann Prognose beginnt.
%Output ist Prognose table(), was vorherzusagenden Zeitpunkte, Step,
%normalisierten Leistung und Monte Carlo Simulationsergebnisse umfasst.

    tic
    %K_Step Prognose:287 entpricht 3 day-ahead, 191 entpricht 2 day-ahead, 95 entspricht 1 day-ahead
    K_Step = 287; 
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
            Zeile = {Zeit, 0, 0, 0};
            Prognose = [Prognose;Zeile];
            
            continue
        end

        model = arima('ARLags', [k, i]);
        fitmodel = estimate(model, TestData.Rel, 'Display','off');

        Y0 = TestData.Rel;

        yf = forecast(fitmodel,k ,'Y0' , Y0);
        yf_last = yf(end);

        [E] = infer(fitmodel , Y0);
        
        %Monte Carlo Simulation durchfuehren
        [ysim] = simulate(fitmodel, k , 'NumPaths',1000, 'Y0',Y0 ,'E0',E);
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
    
    toc
    
    %low = prctile(ysim_last,10);
    %up = prctile(ysim_last,90);
    %middle = prctile(ysim_last,50);
    %boxplot(ysim_last)
end

