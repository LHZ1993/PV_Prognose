function [Erg] = arx_echtzeit(Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)

    %Modell einlesen
    EstModell = Modell{1,1};
    Quantile = Modell{1,2};
    
    %Prognosehorizont feststellen
    AktuellZeit = LeistungZeit.Zeit(end);
    FirstPrognose = AktuellZeit + minutes(15);
    LastPrognose = WetterRow.Zeit(end);
    
    if ((LastPrognose - AktuellZeit) / minutes(15)) >= Konfiguration.Kstep
        K = Konfiguration.Kstep;
        LastPrognose = AktuellZeit + minutes(15) * K;
        
    else
        K = (LastPrognose - AktuellZeit) / minutes(15);
        
    end
    
    fprintf('Atkueller Zeitpunkt : %s \n', datestr(AktuellZeit))
    fprintf('PV-Leitung von %s bis zum %s wird mit ARX-Modell vorhergesat. \n', datestr(FirstPrognose), datestr(LastPrognose))
    
    %PV-Leistung, CS-Leistung und relative Leistung in GesamtLeistung
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);
    
    %Wetterprognose in Wetter_Resample
    %Wetter = fullfill_wetter(WetterRow);
    Wetter_Resample = WetterRow;
    
    %Leistung und Wetter in einem gleichen Zeitraum. Ende der AktuellDaten
    %ist Aktueller Zeitpunkt.
    DatenAnfang = max(GesamtLeistung.Zeit(1), Wetter_Resample.Zeit(1));
    
    AktuellLeistung = GesamtLeistung( find(GesamtLeistung.Zeit == DatenAnfang) : find(GesamtLeistung.Zeit == AktuellZeit) , : );
    AktuellWetter = Wetter_Resample( find(Wetter_Resample.Zeit == DatenAnfang) : find(Wetter_Resample.Zeit == AktuellZeit) , : );
    AktuellDaten = [ AktuellLeistung, AktuellWetter(:, 2:end)];
    
    PrognoseWetter = Wetter_Resample( find(Wetter_Resample.Zeit == FirstPrognose ) : find(Wetter_Resample.Zeit == LastPrognose ), : );
   
    %ARX Modell Punkte Prognose
    X = AktuellDaten.Bewoelkerung;
    Y = AktuellDaten.Rel;
    Xf = PrognoseWetter.Bewoelkerung;

    PunktePrognose = arx_modell_forecast(Y , X , Xf , K , AktuellZeit, EstModell);
    PunktePrognose.RelPro(find(PunktePrognose.RelPro < 0)) = 0;

    %ARX Modell Probabilistische Prognose
    ProbabilisticPrognose_QuantileRefression = arx_modell_forecast_probabilistic_realtime(PunktePrognose, ClearSky, 2, Quantile);
    Erg = ProbabilisticPrognose_QuantileRefression;
end

