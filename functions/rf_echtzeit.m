function [Erg] = rf_echtzeit(Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)

    %Random Forest einlesen
    Trees = Modell{1,1};
    
    %Wetterdaten fuer NN
    %Wetter = fullfill_wetter(WetterRow);
    Wetter_Resample = WetterRow;
    
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
    fprintf('PV-Leitung von %s bis zum %s wird mit RF vorhergesagt. \n', datestr(FirstPrognose), datestr(LastPrognose))
    
    %PrognoseDaten    
    PrognoseWetter = Wetter_Resample( find(Wetter_Resample.Zeit == FirstPrognose ) : find(Wetter_Resample.Zeit == LastPrognose ), : );

    Zeit=reshape(PrognoseWetter.Zeit,[],1);

    DoY = 1+floor(days(Zeit-datetime(year(Zeit),1,1)));
    ToD = hour(Zeit)+minute(Zeit)/60;

    DoY=reshape(DoY,1,[]);
    ToD=reshape(ToD,1,[]);

    PrognoseWetter.DoY = DoY';
    PrognoseWetter.ToD = ToD';
    
    CS = ClearSky.Leistung( find(ClearSky.Zeit == FirstPrognose ) : find(ClearSky.Zeit == LastPrognose ));  
    PrognoseWetter.CS = [CS];
    
    Alle_Inputparameter = PrognoseWetter.Properties.VariableNames;
    Auswahl_Inputparameter = Konfiguration.RF.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    Features = [PrognoseWetter(:, inputvektor)];
    
    X = Features;
    Ypredict = predict(Trees, X);
    Ypredict(Ypredict <= 0) = 0;

    quantiles = [0.05:0.05:0.95];
    Yquantile = quantilePredict(Trees, X, 'Quantile', quantiles);
    Yquantile(Yquantile <= 0) = 0;
    
    RelPro = Ypredict;
    
    Zeit = PrognoseWetter.Zeit;
    
    LeistungPro = CS.*RelPro;
    
    Quantile = Yquantile.*CS;
    
    Erg = [array2table(Zeit), array2table(RelPro),array2table(CS), array2table(LeistungPro),array2table(Quantile)];

    
end

