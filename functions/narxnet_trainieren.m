function [Netz] = narxnet_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Inptdaten Konfiguration, LeistungZeit, ClearSky und WetterRow durch
%konfiguration.m vorbereiten
%Output Netz ist trainiertes NARX-Netz
    
    fprintf('Train NARX-Netz \n');
    fprintf('Training Daten bis %s \n', datestr(Konfiguration.Train.ZeitEnde));
    
    %CS-Faktor umrechnen
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
    Delay = Konfiguration.NARX.Delays;
    Layers = Konfiguration.NARX.Layers;
    inputDelays = 1:Delay;
    feedbackDelays = 1:Delay;
    net = narxnet(inputDelays,feedbackDelays,Layers,'open','trainlm');
    
    %Inputs : Bewoehkungsgrad , Temperatur, CS-Leistung als Feedback
    net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};
    net.inputs{2}.processFcns = {'removeconstantrows','mapminmax'};
    
    %Trainzeitraum auswählen
    NN_Train_Anfang = Konfiguration.Train.ZeitAnfang;
    NN_Train_Ende = Konfiguration.Train.ZeitEnde;
    
    %Traindaten auswählen
    NN_TrainDaten = GesamtDaten(find(GesamtDaten.Zeit == NN_Train_Anfang) : find(GesamtDaten.Zeit == NN_Train_Ende), :);

    %Inputparameter auswaehlen
    Alle_Inputparameter = NN_TrainDaten.Properties.VariableNames;
    Auswahl_Inputparameter = Konfiguration.NARX.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    x = table2array(NN_TrainDaten(:, inputvektor)); %NN Inputs fuer narxnet
    t = table2array(NN_TrainDaten(: , 4)); %NN Targets
    T = zeros(size(x,1),size(x,2));
    
    for i = 1:size(x,2)
        T(:, i) = t;
    end
    
    x = x';
    T = T';
   
	x=num2cell(x, [1, size(x,2)]); 
	T=num2cell(T, [1, size(T,2)]); 
    
    
    [x,xi,ai,T] = preparets(net,x,{},T);
    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'time';  % Divide up every sample
    
    net.divideParam.trainRatio = 82/100;
    net.divideParam.valRatio = 18/100;
    net.divideParam.testRatio = 0/100;
    
    [neti,tr] = train(net,x,T,xi,ai);
    
    Netz = neti;
    
    
    
end

