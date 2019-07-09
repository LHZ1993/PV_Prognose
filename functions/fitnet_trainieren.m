function [Netz] = fitnet_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Inptdaten Konfiguration, LeistungZeit, ClearSky und WetterRow durch
%konfiguration.m vorbereiten
%Output Netz ist trainiertes FF-Netz
    
    fprintf('Train FIT-Netz \n');
    fprintf('Training Daten bis %s \n', datestr(Konfiguration.Train.ZeitEnde));
    
    %CS-Faktor berechnen
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);
    
    %verknuepfen Wetter mit Leistung
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
    net = fitnet(Konfiguration.FF.Layers, 'trainlm');
    net.input.processFcns = {'removeconstantrows','mapminmax'};
    net.output.processFcns = {'removeconstantrows','mapminmax'};
    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainRatio = 82/100;
    net.divideParam.valRatio = 18/100;
    net.divideParam.testRatio = 0/100;
    
    %NN Trainingszeitpunkte auswaehlen
    NN_Train_Anfang = Konfiguration.Train.ZeitAnfang;
    NN_Train_Ende = Konfiguration.Train.ZeitEnde;
    
    %NN Traningdaten auswaehlen
    NN_TrainDaten = GesamtDaten(find(GesamtDaten.Zeit == NN_Train_Anfang) : find(GesamtDaten.Zeit == NN_Train_Ende), :);
    
    %Inputparameter auswählen
    Alle_Inputparameter = NN_TrainDaten.Properties.VariableNames;
    Auswahl_Inputparameter = Konfiguration.FF.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    x = table2array(NN_TrainDaten(:,inputvektor)); %NN Inputs fuer fitnet
    t = table2array(NN_TrainDaten(: , 4)); %NN Targets
    T = zeros(size(x,1),size(x,2));

    for i = 1:size(x,2)
        T(:, i) = t;
    end

    x = x';
    T = T';
    
    %NN trainieren
    [neti,tr] = train(net,x,T);
    
    Netz = neti;
    
end

