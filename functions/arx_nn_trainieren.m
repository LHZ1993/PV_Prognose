function [PunktModell,QuantileModell,Netz] = arx_nn_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Inptdaten Konfiguration, LeistungZeit, ClearSky und WetterRow durch
%konfiguration.m vorbereiten
%Output PunktModell ist cell
%PunktModell(:, 1) >>> Prognosehorizont von 1 bis Konfiguration.Kstep
%PunktModell(:, 2) >>> Berechnete Klasse 'arima' für entsprechenden Kstep
%PunktModell(:, 3) >>> Berechnete Parameter für Quantilregression
%PunktModell(:, 4 : 22) >>> Quantilfaktor von 5% bis 95%
%Output QuantileModell ist table, wo alle Quantilfaktoren gespeichert
%werden.
%QuantileModell = cell2table(PunktModell(:, 4 : 22))
%Output Netz ist trainiertes FF-Netz, um die Werte für exogenen Eingang des
%ARX-Modells zu berechen.

    %CS-Faktor umrechnen
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);

    %verknuepfen WetterRow mit Leistung
    GesamtDaten = verknuepfen_gesamtleistung_wetter_RF(WetterRow, GesamtLeistung);
    
    %Inputparameter DoY und ToD berechnen
    %DoY >>> Tag im Jahr(Day of year)
    %ToD >>> Uhrzeit am Tag(Time of Day)
    Zeit=reshape(GesamtDaten.Zeit,[],1);
    DoY = 1+floor(days(Zeit-datetime(year(Zeit),1,1)));
    ToD = hour(Zeit)+minute(Zeit)/60;

    DoY=reshape(DoY,1,[]);
    ToD=reshape(ToD,1,[]);

    GesamtDaten.DoY = DoY';
    GesamtDaten.ToD = ToD';
    
    %Fitting Netz erstellen
    net = fitnet(Konfiguration.ARXNN.Layers, 'trainlm');
    net.input.processFcns = {'removeconstantrows','mapminmax'};
    net.output.processFcns = {'removeconstantrows','mapminmax'};
    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainRatio = 82/100;
    net.divideParam.valRatio = 18/100;
    net.divideParam.testRatio = 0/100;
    
    %NN Training Zeitpunkte auswaehlen
    NN_Train_Anfang = Konfiguration.Train.ZeitAnfang;
    NN_Train_Ende = Konfiguration.Train.ZeitEnde;
    
    %NN Traningdaten auswaehlen
    NN_TrainDaten = GesamtDaten(find(GesamtDaten.Zeit == NN_Train_Anfang) : find(GesamtDaten.Zeit == NN_Train_Ende), :);
    
    %NN Training
    %Inputparameter auswählen
    Alle_Inputparameter = NN_TrainDaten.Properties.VariableNames;
    Auswahl_Inputparameter = Konfiguration.FF.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    x = table2array(NN_TrainDaten(:, inputvektor)); %NN Inputs
    t = table2array(NN_TrainDaten(: , 4)); %NN Targets
    T = zeros(size(x,1),size(x,2));

    for i = 1:size(x,2)
        T(:, i) = t;
    end

    x = x';
    T = T';

    [neti,tr] = train(net,x,T);
    Netz = neti;
    
    %NWP_Rel fuer ARX Modell berechnen
    y = neti(x);
    NN_TrainDaten.RelPro = y(1, :)';
    NN_TrainDaten.LeistungPro = NN_TrainDaten.RelPro .* NN_TrainDaten.CS;
    
    %ARX Modellparametern berechnen
    ARX_TrainDaten = NN_TrainDaten;
    ARX_TrainDaten.RelPro(find(ARX_TrainDaten.RelPro < 0.0001)) = 0;
    K = Konfiguration.Kstep;
    X0 = ARX_TrainDaten.RelPro;
    Y0 = ARX_TrainDaten.Rel(K*3 +1 :end);

    [PunktModell,QuantileModell] = arx_modell_estimate(Y0, X0, K, ARX_TrainDaten.Zeit(end));
    
end

