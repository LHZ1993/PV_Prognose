%%
%
Konfiguration = struct;

%%
%Vier Hauptfunktionen des Prognoseprogrammes durch die 3 Parametern einstellen 
%1.Prognose mit Echtzeitdaten treffen>>>Konfiguration.EchtdatenPrognose = 1
%2.Modell trainieren>>>Konfiguration.TraininerenModell = 1 und Konfiguration.AuswertenModell  = 0;
%3.Modell trainieren und auswerten>>>Konfiguration.TraininerenModell = 1 und Konfiguration.AuswertenModell  = 1;
%4.vonhandene Modelle auswerten>>>Konfiguration.TraininerenModell = 0 und Konfiguration.AuswertenModell  = 1;
Konfiguration.TraininerenModell = 0;
Konfiguration.AuswertenModell  = 0;
Konfiguration.EchtdatenPrognose = 1;

%%
%Wenn sich mit Echtzeitdaten Prognose treffen lässt, der Zeitpunkt zur Prognose durch
%Konfiguration.PrognoseMinute eingestellt wird.
%Konfiguration.PrognoseMinute = 48;
Konfiguration.EchtzeitErg = 0;
%%
%Prognosehorizont(maximaler K-Step 287 entspricht 72 Stunden im Voraus )
Konfiguration.Kstep = 287;

%Trainzeitraum auswaehlen.
Konfiguration.Train.ZeitAnfang = datetime(2019,4,5,12,0,0);
Konfiguration.Train.ZeitEnde = datetime(2019,5,20,6,0,0);

%Testzeitraum auswaehlen
Konfiguration.Test.ZeitAnfang = datetime(2019,5,20,8,0,0);
Konfiguration.Test.ZeitEnde = datetime(2019,5,20,12,0,0);
Konfiguration.Test.Aufloesung = hours(1);

Konfiguration.Test.RaumAnfang = Konfiguration.Test.ZeitAnfang : Konfiguration.Test.Aufloesung: Konfiguration.Test.ZeitEnde ;
Konfiguration.Test.RaumEnde = Konfiguration.Test.RaumAnfang + minutes(15)*(Konfiguration.Kstep -1);

%%
%Welche Modelle werden trainiert, ausgewertet oder mit aktuellen Daten getestet, hire eingeben
%1.ARXB>>>Autoregression Modell mit Bewoelkung
%2.ARXNN>>>Kombination von ARX mit FF
%3.FF>>>Feed-Forwaard-Netz
%4.NARX>>>Nichtlinear-Autoregressiv-Netz
%5.RF>>>Random Forest
Konfiguration.ModellName = {'FF', 'RF'};% Modell hier auswählen
Konfiguration.ModellPath = 'E:\Projekt\FA\Material\Inhaltlich\Modelle\Haoyan\Abgabe\Matlab_V3\Modell\Modell_01_09_2018.mat';
%Konfiguration.ModellPath = 'E:\Projekt\FA\Material\Inhaltlich\Modelle\Haoyan\Xchange\GUI\Modell\test\Modell1.mat';
Konfiguration.ModellNameDefault = { 'ARX', 'ARXNN', 'FF', 'NARX', 'RF'};%nicht verändern
load(Konfiguration.ModellPath);
Konfiguration.Modell = Modell;
clear Modell

%Clear-Sky-Modell Parametern
Konfiguration.BerechnenCS = 0;%1: Clear-Sky-Modell berechenen, 0: vorhandene CS-Modell verwenden.
Konfiguration.CS.hx = 35;
Konfiguration.CS.Cut = 0.1;

%ARX Modell Parametern
Konfiguration.ARX.Merkmal = 'Bewoelkung';%Merkmal: 'Bewoelkung' oder 'Temperatur'

%ARXNN Modell Parametern
Konfiguration.ARXNN.Layers = 10;

%FF Netz Parametern
Konfiguration.FF.Layers = 10;
Konfiguration.FF.Inputparamter = {'CS', 'Temperatur', 'Windgeschwindigkeit', 'Luftdruck',...
    'Feuchtigkeit', 'Bewoelkerung', 'DoY', 'ToD'};%Inputparameter hier auswählen

%Alle verfügbaren Inputparameter {'CS', 'Temperatur', 'Niederschlagrisiko', 'Niederschlagmenge',
%'Windgeschwindigkeit', 'Luftdruck', 'Feuchtigkeit', 'Bewoelkerung', 'DoY', 'ToD'}


%NARX Netz Parametern
Konfiguration.NARX.Layers = 6;
Konfiguration.NARX.Delays = 24;
Konfiguration.NARX.Inputparamter = {'CS', 'Temperatur', 'Bewoelkerung'};%Inputparameter hier auswählen

%Alle verfügbaren Inputparameter {'CS', 'Temperatur', 'Niederschlagrisiko', 'Niederschlagmenge',
%'Windgeschwindigkeit', 'Luftdruck', 'Feuchtigkeit', 'Bewoelkerung', 'DoY', 'ToD'}

%RF Parametern
Konfiguration.RF.Trees = 300;
Konfiguration.RF.Leafs = 6;
Konfiguration.RF.Inputparamter = {'CS', 'Temperatur', 'Windgeschwindigkeit', 'Feuchtigkeit', ...
    'Bewoelkerung', 'DoY', 'ToD'};%Inputparameter hier auswählen

%Alle verfügbaren Inputparameter {'CS', 'Temperatur', 'Niederschlagrisiko', 'Niederschlagmenge',
%'Windgeschwindigkeit', 'Luftdruck', 'Feuchtigkeit', 'Bewoelkerung', 'DoY', 'ToD'}

%%
%Daten einlesen
%Es gibt zwei Möglichkeiten Daten einzulesen.
%Wenn der Datenaustausch zwischen SQLite und Matlab vorher fertig
%konfiguriert ist(siehe Bemerkung_zum_Matlab_Database.txt), dann soll hier 
%Konfiguration.ReadDatenbank = 1 eingestellt werden. Ansonst werden die
%Daten durch die .mat Datei eingelesen.
%Achtung: Die Funktion zur Echtzeitprognose ist nur möglich mit Konfiguration.ReadDatenbank = 1;
%Die Funktionen zum Modelltraining und Modelltest sind sowohl mit Datenbank als auch mit .mat Datei
%möglich.
Konfiguration.ReadDatenbank = 0;
Konfiguration.MDateiPath = 'E:\Projekt\FA\Material\Inhaltlich\Modelle\Haoyan\Abgabe\Daten\DatenRow_2019.mat';

if Konfiguration.EchtdatenPrognose ~= 1
    
    %Daten einlesen aus Datenbank
    if Konfiguration.ReadDatenbank == 1
       
        Konfiguration.DatenbankPath = 'E:\Projekt\FA\Material\Inhaltlich\Modelle\Haoyan\Abgabe\Daten\';
        Konfiguration.DatenbankEinlesen = 'Vaihingen_2018.db';

        LeistungZeit = read_data_db(Konfiguration.DatenbankPath, Konfiguration.DatenbankEinlesen, 'VaihingenLeistung');
        WetterRow = read_data_db(Konfiguration.DatenbankPath, Konfiguration.DatenbankEinlesen, 'Wetter_Resample');

        %vorhandene CS-Leistung durch Database einlesen
        if Konfiguration.BerechnenCS == 0
            %Es gibt 2 Tablle in Datenbank.
            %'CS_h35'>>>Brandweite 35, 'CS_h18'>>>Brandweite 18
            ClearSky = read_data_db(Konfiguration.DatenbankPath, Konfiguration.DatenbankEinlesen, 'CS_h35');

        %anhand von der historische PV-Leistung berechnen neue CS-Leistung(circa 10min)   
        elseif Konfiguration.BerechnenCS == 1
            %Empfehlung von hx = 35
            Konfiguration.CS.LetztZeit = LeistungZeit.Zeit(end);
            Konfiguration.CS.LetztIndex = find(LeistungZeit.Zeit == Konfiguration.CS.LetztZeit);

            %Beurteilen, ob die Anzahl von der historischen Leistung reicht für
            %eine neue CS-Berechnung?
            if Konfiguration.CS.LetztIndex > 35040

                Konfiguration.CS.ErstIndex = Konfiguration.CS.LetztIndex - 35039;
                Konfiguration.CS.LeistungZeit_CS = LeistungZeit(Konfiguration.CS.ErstIndex : Konfiguration.CS.LetztIndex , :);

                ClearSky = kernel_smoothing_regression(Konfiguration.CS.LeistungZeit_CS.Leistung,Konfiguration.CS.LeistungZeit_CS.Zeit, Konfiguration.CS.hx);

            %Wenn Anzahl von der historischen Leistung nicht reicht, wird
            %vorhandene CS-Leistung verwendet
            else

                fprintf('Anzahl von der historische PV-Leistung nicht reicht für CS-Modell. Die vorhandene CS-Leistung wird verwendet.  \n')
                ClearSky = read_data_db(Konfiguration.DatenbankPath, Konfiguration.DatenbankEinlesen, 'CS_h35');

            end
        end
    
    %Daten einlesen aus .mat Datei
    elseif Konfiguration.ReadDatenbank == 0
        
        load(Konfiguration.MDateiPath)
        
    end
    
    
elseif Konfiguration.EchtdatenPrognose == 1
    
    %Datenbank auswaehlen
    Konfiguration.DatenbankPath = 'E:\Projekt\FA\Material\Inhaltlich\Modelle\Haoyan\Abgabe\Daten\';
    Konfiguration.DatenbankEinlesen = 'Vaihingen_2019.db';
    Konfiguration.DatenbankSpeichern = 'EchtzeitErg.db';

end


