function [Erg] = arx_nn_echtzeit(Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)

    %Modell einlesen
    EstModell = Modell{1,1};
    Quantile = Modell{1,2};
    neti = Modell{1,3};
        
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
    fprintf('PV-Leitung von %s bis zum %s wird mit ARX-NN-Modell vorhergesat. \n', datestr(FirstPrognose), datestr(LastPrognose))

    %PV-Leistung, CS-Leistung und relative Leistung in GesamtLeistung
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);
    
    %Wetter
    Wetter_Resample = WetterRow;

    %Daten teilen
    %Leistung und Wetter in einem gleichen Zeitraum. Ende der AktuellDaten
    %ist Aktueller Zeitpunkt.
    DatenAnfang = max(GesamtLeistung.Zeit(1), Wetter_Resample.Zeit(1));
    
    AktuellLeistung = GesamtLeistung( find(GesamtLeistung.Zeit == DatenAnfang) : find(GesamtLeistung.Zeit == AktuellZeit) , : );
    AktuellWetter = Wetter_Resample( find(Wetter_Resample.Zeit == DatenAnfang) : find(Wetter_Resample.Zeit == AktuellZeit) , : );
    AktuellDaten = [ AktuellLeistung, AktuellWetter(:, 2:end)];
    
    PrognoseWetter = Wetter_Resample( find(Wetter_Resample.Zeit == FirstPrognose ) : find(Wetter_Resample.Zeit == LastPrognose ), : );

    %NN trainieren in AktuellDaten
    Zeit=reshape(AktuellDaten.Zeit,[],1);

    DoY = 1+floor(days(Zeit-datetime(year(Zeit),1,1)));
    ToD = hour(Zeit)+minute(Zeit)/60;

    DoY=reshape(DoY,1,[]);
    ToD=reshape(ToD,1,[]);

    AktuellDaten.DoY = DoY';
    AktuellDaten.ToD = ToD';

    AktuellDaten.Niederschlagmenge = [];
    AktuellDaten.Niederschlagrisiko = [];
    
    xar = table2array(AktuellDaten(:, [3,5:11])); 
    tar = table2array(AktuellDaten(: , 4)); 
    
    xar = xar';
    yar = neti(xar);
    
    AktuellDaten.NWP = yar(1, :)';
    AktuellDaten.NWP(AktuellDaten.NWP<0) = 0;
    
    %NN trainieren in PrognoseDaten
    Zeit=reshape(PrognoseWetter.Zeit,[],1);

    DoY = 1+floor(days(Zeit-datetime(year(Zeit),1,1)));
    ToD = hour(Zeit)+minute(Zeit)/60;

    DoY=reshape(DoY,1,[]);
    ToD=reshape(ToD,1,[]);

    PrognoseWetter.DoY = DoY';
    PrognoseWetter.ToD = ToD';

    PrognoseWetter.Niederschlagmenge = [];
    PrognoseWetter.Niederschlagrisiko = [];

    CS = ClearSky.Leistung( find(ClearSky.Zeit == FirstPrognose ) : find(ClearSky.Zeit == LastPrognose ));
    
    xp = table2array([array2table(CS),PrognoseWetter(:,2:end) ] );
    xp = xp';
    
    yp = neti(xp);
    PrognoseWetter.NWP = yp(1, :)';
    
    X = AktuellDaten.NWP;
    Y = AktuellDaten.Rel;
    Xf = PrognoseWetter.NWP;
    PunktePrognose = arx_modell_forecast(Y , X , Xf , K , AktuellZeit, EstModell);
    PunktePrognose.RelPro(find(PunktePrognose.RelPro < 0)) = 0;
    
    %ARX Modell Probabilistische Prognose
    ProbabilisticPrognose_QuantileRefression = arx_modell_forecast_probabilistic_realtime(PunktePrognose, ClearSky, 2, Quantile);   
    Erg = ProbabilisticPrognose_QuantileRefression;
end

