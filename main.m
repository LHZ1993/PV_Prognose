%% 1.Pfad anpassen
%
aufraeumen;

%% 2.Konfiguration, Initialsierung und Dateneinlesen 
%Programmparametern in konfiguration.m einstellen
konfiguration;

%% 3.Prognose mit Echtzeitdaten treffen
if Konfiguration.EchtdatenPrognose == 1
    %GUI aufmachen
    PrognoseGUI
    
%% 4.Modelle neu trainieren und auswerten
elseif (Konfiguration.TraininerenModell  == 1) && (Konfiguration.AuswertenModell  == 1)
    
    [Modell,Erg] = all_modell_train_test(Konfiguration, LeistungZeit, ClearSky, WetterRow);
    
    %Ergebnisse mitaneinder vergleichen
   

%% 5.vorhandenes Modell im bestimmten Testzeitraum auswerten    
elseif (Konfiguration.TraininerenModell  == 0) && (Konfiguration.AuswertenModell  == 1)
    
    Modell = Konfiguration.Modell;
    
    [Erg] = all_modell_test(Modell,Konfiguration, LeistungZeit, ClearSky, WetterRow);

%% 6. Modell trainieren aber nicht auswerten 
elseif (Konfiguration.TraininerenModell  == 1) && (Konfiguration.AuswertenModell  == 0)

    [NeuModell] = all_modell_train(Konfiguration, LeistungZeit, ClearSky, WetterRow);  
    
    Konfiguration.Modell = NeuModell;
    %save('D:\Projekt\FA\IER\Material\Inhaltlich\Modelle\Haoyan\Abgabe\Modell\test\ModellNew.mat', 'NeuModell');
    
end
    
