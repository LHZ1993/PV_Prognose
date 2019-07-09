function [Erg] = narxnet_echtzeit(Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)

    %NARX Netz einlesen
    neti = Modell{1,1};
    Delay = Konfiguration.NARX.Delays;
    
    %Wetterdaten fuer NN
    %Wetter = fullfill_wetter(WetterRow);
    Wetter_Resample = WetterRow;
    
    %PV-Leistung, CS-Leistung und relative Leistung in GesamtLeistung
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);
    
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
    fprintf('PV-Leitung von %s bis zum %s wird mit NARX-Netz vorhergesagt. \n', datestr(FirstPrognose), datestr(LastPrognose))


    %Leistung und Wetter in einem gleichen Zeitraum. Ende der AktuellDaten
    %ist Aktueller Zeitpunkt.
    DatenAnfang = max(GesamtLeistung.Zeit(1), Wetter_Resample.Zeit(1));
    
    AktuellLeistung = GesamtLeistung( find(GesamtLeistung.Zeit == DatenAnfang) : find(GesamtLeistung.Zeit == AktuellZeit) , : );
    AktuellWetter = Wetter_Resample( find(Wetter_Resample.Zeit == DatenAnfang) : find(Wetter_Resample.Zeit == AktuellZeit) , : );
    AktuellDaten = [ AktuellLeistung, AktuellWetter(:, 2:end)];
    
    
    PrognoseWetter = Wetter_Resample( find(Wetter_Resample.Zeit == FirstPrognose ) : find(Wetter_Resample.Zeit == LastPrognose ), : );
    PrognoseWetter.Niederschlagmenge = [];
    PrognoseWetter.Niederschlagrisiko = [];
    
    %FeedbackDaten auswaehlen
    Feedback_Anfang = AktuellZeit - Delay*minutes(15);
    Feedback_Ende = AktuellZeit - minutes(15);
    FeedbackDaten = AktuellDaten(find(AktuellDaten.Zeit == Feedback_Anfang) : find(AktuellDaten.Zeit == Feedback_Ende) , :);
     
    Alle_Inputparameter = FeedbackDaten.Properties.VariableNames;
    Auswahl_Inputparameter = Konfiguration.NARX.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    %NN Inputs auswaehlen und Prognose treffen
    af = cell(2, 0);
    xf = cell(2, Delay);

    feed_input = table2array(FeedbackDaten(:, inputvektor));
    feed_input = num2cell(feed_input', [1, size(feed_input,2)]);

    f_out = table2array(FeedbackDaten(:, 4))';
    feed_out = zeros(size(feed_input{1,1},1),size(feed_input,2));

    for out_num = 1:size(feed_input{1,1},1)
        feed_out(out_num, :) = f_out;
    end

    feed_out = num2cell(feed_out, [1, size(feed_out,2)]);

    xf(1, :) = feed_input;
    xf(2, :) = feed_out;
    [netc, xc, ac] = closeloop(neti, xf, af);
    
    CS = ClearSky.Leistung( find(ClearSky.Zeit == FirstPrognose ) : find(ClearSky.Zeit == LastPrognose ));
    PrognoseWetter.CS = [CS];
    
    Alle_Inputparameter = PrognoseWetter.Properties.VariableNames;
    inputvektor_2 = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    Features = [PrognoseWetter(:,inputvektor_2)];
    
    xar = table2array(Features)'; %NN Inputs fuer narxnet
    xar = num2cell(xar, [1, size(xar,2)]);
    
    yar = netc(xar, xc, ac);
    
    yar = cell2mat(yar);
    rel = yar(1,:)';
    rel(find(rel <= 0)) = 0;
        
    RelPro = rel;
    
    Zeit = PrognoseWetter.Zeit;
    
    LeistungPro = CS.*RelPro;
    
    Erg = [array2table(Zeit), array2table(RelPro), array2table(CS), array2table(LeistungPro)];
   


end

