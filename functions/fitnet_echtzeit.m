function [Erg] = fitnet_echtzeit(Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)

    %FF Netz einlesen
    neti = Modell{1,1};
    
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
    fprintf('PV-Leitung von %s bis zum %s wird mit FF-Netz vorhergesagt. \n', datestr(FirstPrognose), datestr(LastPrognose))
    
    %NN trainieren in PrognoseDaten    
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
    Auswahl_Inputparameter = Konfiguration.FF.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    xp = table2array(PrognoseWetter(:, inputvektor));
    xp = xp';    
    yp = neti(xp);
    
    temp = yp(1, :)';
    temp(temp<0) = 0;
    
    RelPro = temp;
    
    Zeit = PrognoseWetter.Zeit;
    
    LeistungPro = CS.*RelPro;
    
    Erg = [array2table(Zeit), array2table(RelPro), array2table(CS), array2table(LeistungPro)];
    
end

