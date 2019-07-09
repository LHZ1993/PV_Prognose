function [TestErg] = rf_auswerten(RF_Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Anhand von in konfiguration.m ausgewählten Konfiguration.Test.ZeitAngang,
%Konfiguration.Test.ZeitEnde und Konfiguration.Test.Auflösung wird der Testzeitraum
%bestimmt und RandomForest getestet.
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

    fprintf('Auswertung des Random Forest \n');
    fprintf('Testzeitraum vom %s bis zum %s \n', datestr(Konfiguration.Test.ZeitAnfang),datestr(Konfiguration.Test.ZeitEnde));
    
    %Modell einlesen
    Trees = RF_Modell{1,1};
    
    %CS-Faktor umrechnen
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);
    
    %Leistung mit Wetter verknüpfen
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
    
    %Inputparameter auswählen
    Alle_Inputparameter = GesamtDaten.Properties.VariableNames;
    Auswahl_Inputparameter = Konfiguration.RF.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    %Testzeitraum auswählen
    TestgAnfangRaum = Konfiguration.Test.RaumAnfang;
    TestEndeRaum = Konfiguration.Test.RaumEnde;

    K = Konfiguration.Kstep;

    %In cell QuantileError werden pinball loss function und winkler scores
    %gespeichert
    error = zeros(size(TestgAnfangRaum, 2), K);
    QuantileError = {};
    
    for i = 1: 19+9+19+1
    
        QuantileError{1, i} = error;
    
    end

    %In Error , Messwerte und Prognose werden Punkteprognoseergebnisse
    %gepeichert.
    Error= zeros(size(TestgAnfangRaum, 2), K);
    Messwerte= zeros(size(TestgAnfangRaum, 2), K);
    Prognose = zeros(size(TestgAnfangRaum, 2), K);

    GesamtPrognose = table();
    
    %RF im ausgewälhten Testraum auswerten
    for test_num = 1 : size(TestgAnfangRaum,2)

        %Testdaten Zeitpunkte
        TestAnfang = TestgAnfangRaum(1, test_num);
        TestEnde = TestEndeRaum(1, test_num);
        TestDaten = GesamtDaten(find(GesamtDaten.Zeit == TestAnfang) : find(GesamtDaten.Zeit == TestEnde) , :);

        Xtest = TestDaten( : , inputvektor );
        Ypredict = predict(Trees, Xtest);
        Ypredict(find(Ypredict <= 0)) = 0;

        Ymess = TestDaten( : , [1,2,3,4] );

        quantiles = [0.05:0.05:0.95];
        Yquantile = quantilePredict(Trees, Xtest, 'Quantile', quantiles);
        Yquantile(find(Yquantile <= 0)) = 0;

        GesamtPrognose = Ymess;
        %Ypredict = Ypredict.*GesamtPrognose.CS;
        GesamtPrognose.RelPro = Ypredict;
        GesamtPrognose.LeistungPro = GesamtPrognose.CS .*GesamtPrognose.RelPro;
        GesamtPrognose.LeistungError = GesamtPrognose.Leistung - GesamtPrognose.LeistungPro;
        GesamtPrognose.RelError = GesamtPrognose.Rel - GesamtPrognose.RelPro;
        GesamtPrognose.K_Step = [1:K]';

        Gesamt{test_num, 1} = GesamtPrognose;

        Yquantile = Yquantile .* GesamtPrognose.CS;
        GesamtQuantile{test_num, 1} = Yquantile;

        %Quantile Prognose Error Analyse
        %Pinball Loss Function berechnen
        pinball = zeros(K,19);
        indicator = zeros(K,19);

        for tau = 0.05 :0.05:0.95

            leistung = GesamtPrognose.Leistung;
            quantile = Yquantile(:,int16(tau*20));
            %quantile = table2array(quantile);

            smaller_pinball = find(leistung < quantile);
            bigger_pinball = find(leistung >= quantile);

            pinball(smaller_pinball, int16(tau*20))=(1 - tau) .* (quantile(smaller_pinball) -leistung(smaller_pinball));
            pinball(bigger_pinball, int16(tau*20))= tau .* (leistung(bigger_pinball) - quantile(bigger_pinball));

            smaller_indicator = find(leistung <= quantile);
            bigger_indicator = find(leistung > quantile);

            indicator(smaller_indicator, int16(tau*20)) = 1;
            indicator(bigger_indicator, int16(tau*20)) = 0;

        end

        %In cell QuantileError{1, 1:19}werden Pinball Loss Function von 0.05
        %bis zu 0.95 gespeichert.
        for pb = 1:19
            QuantileError{1,pb}(test_num, :) = pinball(:, pb)';
            QuantileError{1,pb +28}(test_num, :) = indicator(:, pb)';
        end

        %Winkler berechnen
        winkler = zeros(K,9);
        for pi = 0.1:0.1:0.9

            alpha = 1 - pi;
            low = Yquantile(:, int16(pi * (-10) +10));
            up = Yquantile(:, int16(pi * 10 + 10));
            leistung_w = GesamtPrognose.Leistung;

            smaller_winkler = find(leistung_w < low);
            bigger_winkler = find(leistung_w > up) ;
            middle_winkler = find( low <= leistung_w <= up);

            winkler(smaller_winkler, int16(pi*10)) = up(smaller_winkler) - low(smaller_winkler) + 2.*( low(smaller_winkler) - leistung_w(smaller_winkler) ) ./alpha;
            winkler(bigger_winkler, int16(pi*10)) = up(bigger_winkler) - low(bigger_winkler) + 2.*( leistung_w(bigger_winkler) - up(bigger_winkler) ) ./alpha;
            winkler(middle_winkler, int16(pi*10)) = up(middle_winkler) - low(middle_winkler);


        end

        %Winkler scores werden in cell QuantileError{1,20:28} gespeichert.
        for wk = 20:28
            QuantileError{1,wk}(test_num, :)= winkler(:, wk-19)';
        end


        %Punkte Prognose Error Analyse
        Prognose(test_num, : ) = GesamtPrognose.LeistungPro' ;

        Messwerte(test_num, : ) = GesamtPrognose.Leistung' ;

        Error(test_num , :) = GesamtPrognose.LeistungError';

        %Skill score berechnen
        skill = zeros(K,1);
        summe = 0;
        for i = 0.05:0.05:0.95

            leistung = GesamtPrognose.Leistung;
            quantile = Yquantile(:,int16(tau*20));

            score = ( indicator(:, int16(i*20)) - i ) .* ( leistung - quantile ) ;

            summe = summe + score;

        end

        QuantileError{1,48}(test_num, :)= summe';

        if mod(test_num , 5) == 0 || test_num == size(TestgAnfangRaum,2)
            fprintf('Fortschritt : %.1f%% \n' , test_num/size(TestgAnfangRaum,2)*100)
        end
    end
    
    %Ranfom Foorest QuantileErg vorbereiten
    QuantileErg = {};
    montecarlo = zeros(K,1);

    for i = 1: size(Gesamt,1)

        erg = [Gesamt{i,1}, table(montecarlo, 'VariableName', {'MC'}), array2table(GesamtQuantile{i,1})];
        QuantileErg{i,1} = erg;

    end

    %Punkte Error
    RMSE_k = table(0,0,0,0,0,0,0, 'VariableNames', {'K', 'RMSE', 'NRMSE','RMQE','NRMQE','MAE','MAPE'});

    Error_k = Error;
    %Y_k = Error + Prognose;
    Y_k = Messwerte;

    first = TestgAnfangRaum(1) + minutes(15);
    last = TestEndeRaum(end);
    N = mean(GesamtDaten.Leistung(find(GesamtDaten.Zeit == first) : find(GesamtDaten.Zeit == last)));

    for k = 1:K

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
    

    TestErg = {RMSE_k, QuantileErg, QuantileError};
    

end

