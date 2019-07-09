function [TestErg] = arx_auswerten(Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Anhand von in konfiguration.m ausgewählten Konfiguration.Test.ZeitAngang,
%Konfiguration.Test.ZeitEnde und Konfiguration.Test.Auflösung wird der Testzeitraum
%bestimmt und das ARX-Modell getestet.
%Output TestErg ist cell
%In TestErg{1,1} werden berechneten Fehlermaße in entsprechenden Zeitraum gespeichert.
%Spalte 1 >>> Prognosehorizont von 1 bis Konfiguration.Kstep
%Spalte 2 >>> RMSE 
%Spalte 3 >>> NRMSE 
%Spalte 4 >>> RMQE 
%Spalte 5 >>> NRMQE 
%Spalte 6 >>> MAE 
%Spalte 7 >>> MAPE
%In TestErg{1,2} wird jedes Prognoseergebnis gespeichert.
%Die um Konfiguration.Test.ZeitAngang getroffene Prognose wird in
%TestErg{1,2}{1,1} gespeichert.
%Die um Konfiguration.Test.ZeitEnde getroffene Prognose wird in
%TestErg{1,2}{end,1} gespeichert.
%von Spalte 11 bis Spalte 29 >>> von 5%-Quantile bis 95%-Quantile
%In TestErg{1,3} wird probabilistische Fehlermaße gespeichert.
%TestErg{1,3}{1,1:19} >>> Pinball Loss Function
%TestErg{1,3}{1,20:28} >>> Winkler Score
%TestErg{1,3}{1,29:47} >>> Indicators
%TestErg{1,3}{1,48} >>> Skill Score
    
    fprintf('Auswertung des ARX-Modelles \n');
    fprintf('Testzeitraum vom %s bis zum %s \n', datestr(Konfiguration.Test.ZeitAnfang),datestr(Konfiguration.Test.ZeitEnde));
    
    %Modell einlesen
    EstModell = Modell{1,1};
    Quantile = Modell{1,2};
    
    K = Konfiguration.Kstep;
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);
    
    %Exogener Eingang auswählen
    Merkmal = Konfiguration.ARX.Merkmal;
    Wetter_Resample = exogen_einggang_auswaehlen(WetterRow, Merkmal);
    
    %Wetter und Leistung in einem gleichen Zeitraum setzen
    GesamtDaten = verknuepfen_gesamtleistung_wetter(Wetter_Resample, GesamtLeistung);
    
    %Testzeitraum
    ARX_TestAnfang_Raum = Konfiguration.Test.RaumAnfang;
    ARX_TestEnde_Raum = Konfiguration.Test.RaumEnde;
    
    %In cell QuantileError werden pinball loss function und winkler scores
    %gespeichert
    %Quantile{1:19}>>>Pinball Loss Function
    %Quantile{20:28}>>>Winkler Score
    %Quantile{29:47}>>>Indicators
    %Quantile{48}>>>Skill Score
    error = zeros(size(ARX_TestAnfang_Raum, 2), K);
    QuantileError = {};

    for i = 1: 19+9+19+1

        QuantileError{1, i} = error;

    end

    %In table Error , Messwerte und Prognose werden Punkteprognoseergebnisse
    %gespeichert.
    Error= zeros(size(ARX_TestAnfang_Raum, 2), K);
    Messwerte= zeros(size(ARX_TestAnfang_Raum, 2), K);
    Prognose = zeros(size(ARX_TestAnfang_Raum, 2), K);

    %In cell Gesamt wird jede ProbabilisticPrognose_QuantileRefression
    %gespeichert.
    Gesamt= {};
    
    %ARX Modell Testdaten auswaehlen und testen

    for test_num = 1 :size(ARX_TestAnfang_Raum, 2)


        ARX_Test_Anfang = ARX_TestAnfang_Raum(test_num);
        ARX_Test_Ende = ARX_TestEnde_Raum(test_num);

        ARX_TestDaten = GesamtDaten(find(GesamtDaten.Zeit == ARX_Test_Anfang) : find(GesamtDaten.Zeit == ARX_Test_Ende) , :);
        ARX_TestDaten.NWP_Rel(find(ARX_TestDaten.NWP_Rel < 0.0001)) = 0;


        AktuellZeit = ARX_Test_Anfang - minutes(15);
        AktuellDaten = GesamtDaten(1: find(GesamtDaten.Zeit == AktuellZeit), :);

        %ARX Modell Punkte Prognose
        X = AktuellDaten.NWP_Rel;
        Y = AktuellDaten.Rel;
        Xf = ARX_TestDaten.NWP_Rel;

        PunktePrognose = arx_modell_forecast(Y , X , Xf , K , AktuellZeit, EstModell);
        PunktePrognose.RelPro(find(PunktePrognose.RelPro < 0)) = 0;

        %ARX Modell Probabilistische Prognose
        ProbabilisticPrognose_QuantileRefression = arx_modell_forecast_probabilistic(PunktePrognose, GesamtDaten,2, Quantile);
        Gesamt{test_num, 1} = ProbabilisticPrognose_QuantileRefression;

        %Punkte Prognose Error Analyse
        Prognose(test_num, : ) = ProbabilisticPrognose_QuantileRefression.LeistungPro' ;

        Messwerte(test_num, : ) = ProbabilisticPrognose_QuantileRefression.Leistung' ;

        Error(test_num , :) = ProbabilisticPrognose_QuantileRefression.LeistungError';

        %Quantile Prognose Error Analyse
        %Pinball Loss Function berechnen
        %Indicators berechnen
        pinball = zeros(K,19);
        indicator = zeros(K,19);

        for tau = 0.05 :0.05:0.95

            leistung = ProbabilisticPrognose_QuantileRefression.Leistung;
            quantile = ProbabilisticPrognose_QuantileRefression(:, int16(tau * 20 + 10));
            quantile = table2array(quantile);

            smaller_pinball = find(leistung < quantile);
            bigger_pinball = find(leistung >= quantile);

            pinball(smaller_pinball, int16(tau*20))=(1 - tau) .* (quantile(smaller_pinball) -leistung(smaller_pinball));
            pinball(bigger_pinball, int16(tau*20))= tau .* (leistung(bigger_pinball) - quantile(bigger_pinball));

            smaller_indicator = find(leistung <= quantile);
            bigger_indicator = find(leistung > quantile);

            indicator(smaller_indicator, int16(tau*20)) = 1;
            indicator(bigger_indicator, int16(tau*20)) = 0;

        end

        %In cell QuantileError{1:19}werden Pinball Loss Function von 0.05
        %bis zu 0.95 gespeichert.
        %In cell QuantileError{29:47} werden Indicators von 0.05 bis zu 0.95
        %gespeichert.
        for pb = 1:19
            QuantileError{1,pb}(test_num, :) = pinball(:, pb)';
            QuantileError{1,pb +28}(test_num, :) = indicator(:, pb)';
        end

        %Winkler berechnen
        winkler = zeros(K,9);
        for pi = 0.1:0.1:0.9

            alpha = 1 - pi;
            low = table2array(ProbabilisticPrognose_QuantileRefression(:, int16(pi * (-10) + 20)));
            up = table2array(ProbabilisticPrognose_QuantileRefression(:, int16(pi * 10 + 20)));
            leistung_w = ProbabilisticPrognose_QuantileRefression.Leistung;

            smaller_winkler = find(leistung_w < low);
            bigger_winkler = find(leistung_w > up) ;
            middle_winkler = find( low <= leistung_w <= up);

            winkler(smaller_winkler, int16(pi*10)) = up(smaller_winkler) - low(smaller_winkler) + 2.*( low(smaller_winkler) - leistung_w(smaller_winkler) ) ./alpha;
            winkler(bigger_winkler, int16(pi*10)) = up(bigger_winkler) - low(bigger_winkler) + 2.*( leistung_w(bigger_winkler) - up(bigger_winkler) ) ./alpha;
            winkler(middle_winkler, int16(pi*10)) = up(middle_winkler) - low(middle_winkler);


        end

        %Winkler scores werden in cell QuantileError{20:28} gespeichert.
        for wk = 20:28
            QuantileError{1,wk}(test_num, :)= winkler(:, wk-19)';
        end     

        %Skill score berechnen
        skill = zeros(K,1);
        summe = 0;
        for i = 0.05:0.05:0.95

            leistung = ProbabilisticPrognose_QuantileRefression.Leistung;
            quantile = ProbabilisticPrognose_QuantileRefression(:, int16(tau * 20 + 10));
            quantile = table2array(quantile);

            score = ( indicator(:, int16(i*20)) - i ) .* ( leistung - quantile ) ;

            summe = summe + score;

        end

        QuantileError{1,48}(test_num, :)= summe';

    end
    
    
    %Punkte Error
    RMSE_k = table(0,0,0,0,0,0,0, 'VariableNames', {'K', 'RMSE', 'NRMSE','RMQE','NRMQE','MAE','MAPE'});
    Error_k = Error;
    %Y_k = Error + Prognose;
    Y_k = Messwerte;

    first = ARX_TestAnfang_Raum(1) + minutes(15);
    last = ARX_TestEnde_Raum(end) ;
    N = mean(GesamtDaten.Leistung(find(GesamtDaten.Zeit == first) : find(GesamtDaten.Zeit == last)));
    for k = 1:287

        rmse= mean(Error_k(: , k) .^2) .^0.5;
        nrmse= mean(Error_k(: , k) .^2) .^0.5 /N;

        rmqe= mean(Error_k(: , k) .^4) .^0.25;
        nrmqe= mean(Error_k(: , k) .^4) .^0.25 /N;

        mae= mean(abs(Error_k(: , k)));

        temp_1 = abs(Error_k(: , k) ./  Y_k(:, k)) *100;
        %temp_2 = abs(Error_k(: , k) ./  mean(Y_k(:, k))) *100;
        temp_1(find( temp_1 == Inf)) = 0;
        temp_1(find( isnan( temp_1) )) = 0;
        temp_1(find(temp_1> 1000)) = 0;
        mape= mean(temp_1);

        zeile = {k, rmse, nrmse, rmqe, nrmqe, mae, mape};

        RMSE_k = [RMSE_k ; zeile];

    end

    RMSE_k(1, :) = [];
    
    for col_index = 2 : size(RMSE_k,2)

        x = table2array(RMSE_k( : , col_index));
        [y, ymean] = ergebniss_aufloesen(x);
        RMSE_k( : , col_index) = table(y); 

    end 
    
    PunktError_arxb = RMSE_k;
    
    TestErg = {PunktError_arxb, Gesamt, QuantileError };
    
end

