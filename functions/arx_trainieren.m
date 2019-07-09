function [PunktModell,QuantileModell] = arx_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow)
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
    
    %Daten vorbereiten
    %CS-Faktor umrechnen
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung_mitNaN = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);
    
    %NaN-Werte beseitigen
    GesamtLeistung = check_leistung_nan(GesamtLeistung_mitNaN);
    
    %Exogener Eingang auswählen
    Merkmal = Konfiguration.ARX.Merkmal;
    Wetter_Resample = exogen_einggang_auswaehlen(WetterRow, Merkmal);
    
    %Wetter und Leistung in einem gleichen Zeitraum setzen
    GesamtDaten = verknuepfen_gesamtleistung_wetter(Wetter_Resample, GesamtLeistung);
    
    %Traingsdaten vorbereiten
    TrainingAnfang = Konfiguration.Train.ZeitAnfang;
    TrainingEnde = Konfiguration.Train.ZeitEnde;
    ARX_TrainDaten = GesamtDaten(find(GesamtDaten.Zeit == TrainingAnfang) : find(GesamtDaten.Zeit == TrainingEnde),:);
    
    %AXR-Modell vorbereiten
    K = Konfiguration.Kstep;
    X0 = ARX_TrainDaten.NWP_Rel;
    Y0 = ARX_TrainDaten.Rel(K*3 +1 :end);
    
    [PunktModell,QuantileModell] = arx_modell_estimate(Y0, X0, K, ARX_TrainDaten.Zeit(end));

end

