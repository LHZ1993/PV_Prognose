function [RandomForest] = rf_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Inptdaten Konfiguration, LeistungZeit, ClearSky und WetterRow durch
%konfiguration.m vorbereiten
%Output RandomForest ist Klasse TreeBagger
    
    
    fprintf('Train Random Forest \n');
    fprintf('Training Daten bis %s \n', datestr(Konfiguration.Train.ZeitEnde));
    
    %CS-Faktor umrechnen
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);
    
    %Leistung mit Wetter verknuepfen
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
    
    %Randomforest Trainingszeitpunkte auswaehlen
    TrainingEnde = Konfiguration.Train.ZeitEnde;
    TrainingAnfang = Konfiguration.Train.ZeitAnfang;
    
    %Inputs : CS-Leistung, Temperatue, Windgeschwindigkeit, Feuchtigkeit, Bewoelkung, ToD, MoY
    TrainingDaten = GesamtDaten(find(GesamtDaten.Zeit == TrainingAnfang) : find(GesamtDaten.Zeit == TrainingEnde) , :);
    
    %Randomforest Inputparameter auswählen
    Alle_Inputparameter = TrainingDaten.Properties.VariableNames;
    Auswahl_Inputparameter = Konfiguration.RF.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);  
    
    TrainingInput = GesamtDaten(find(GesamtDaten.Zeit == TrainingAnfang) : find(GesamtDaten.Zeit == TrainingEnde) , inputvektor);

    %TrainingPhase
    X = TrainingInput;
    Y = TrainingDaten.Rel;

    NumTrees = Konfiguration.RF.Trees;
    Leafs = Konfiguration.RF.Leafs;
    Trees = TreeBagger(NumTrees ,X ,Y ,'Method','regression','MinLeafSize', Leafs);

    RandomForest = Trees;

end

