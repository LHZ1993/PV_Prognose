function [TestErg] = narxnet_auswerten(NARX_Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Anhand von in konfiguration.m ausgewählten Konfiguration.Test.ZeitAngang,
%Konfiguration.Test.ZeitEnde und Konfiguration.Test.Auflösung wird der Testzeitraum
%bestimmt und NARX-Netz getestet.
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
%TestErg{1,2}(1,1) gespeichert.
%Die um Konfiguration.Test.ZeitEnde getroffene Prognose wird in
%TestErg{1,2}(end, 1) gespeichert.

    
    fprintf('Auswertung des NARX-Netzs \n');
    fprintf('Testzeitraum vom %s bis zum %s \n', datestr(Konfiguration.Test.ZeitAnfang),datestr(Konfiguration.Test.ZeitEnde));

    %NARX-Netz einlesen
    neti = NARX_Modell{1,1};
    Delay = Konfiguration.NARX.Delays;
    
    %CS-Faktor umrechnen
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);

    %Wetter mit Leistung verknuepfen
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
    Auswahl_Inputparameter = Konfiguration.NARX.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    %Testzeitraum bestimmen
    TestAnfang_Raum = Konfiguration.Test.RaumAnfang;
    TestEnde_Raum = Konfiguration.Test.RaumEnde;
    
    K = Konfiguration.Kstep;
    
    Error= zeros(size(TestAnfang_Raum, 2), K);
    Messwerte= zeros(size(TestAnfang_Raum, 2), K);
    Prognose = zeros(size(TestAnfang_Raum, 2), K);

    %NN im ausgewälhten Testraum auswerten
    for test_num = 1 :size(TestAnfang_Raum, 2)

        Test_Anfang = TestAnfang_Raum(test_num);
        Test_Ende = TestEnde_Raum(test_num);

        TestDaten = GesamtDaten(find(GesamtDaten.Zeit == Test_Anfang) : find(GesamtDaten.Zeit == Test_Ende) , :);

        Feedback_Anfang = Test_Anfang - Delay*minutes(15);
        Feedback_Ende = Test_Anfang - minutes(15);
        FeedbackDaten = GesamtDaten(find(GesamtDaten.Zeit == Feedback_Anfang) : find(GesamtDaten.Zeit == Feedback_Ende) , :);
        
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
        
        xar = table2array(TestDaten(:,inputvektor))'; %NN Inputs fuer narxnet
        xar = num2cell(xar, [1, size(xar,2)]);
        yar = netc(xar, xc, ac);
        yar = cell2mat(yar);
        rel = yar(1,:)';
        rel(find(rel <= 0)) = 0;
        
        TestDaten.RelPro = rel;
        TestDaten.LeistungPro = TestDaten.CS .* TestDaten.RelPro;
        TestDaten.LeistungError = TestDaten.Leistung - TestDaten.LeistungPro;
        TestDaten.RelError = TestDaten.Rel - TestDaten.RelPro;
        GesamtPrognose{test_num, 1} = TestDaten;
    
        %Punkte Prognose Error Analyse
        Prognose(test_num, : ) = TestDaten.LeistungPro' ;

        Messwerte(test_num, : ) = TestDaten.Leistung' ;

        Error(test_num , :) = TestDaten.LeistungError';

        if mod(test_num,5) == 0 ||  test_num ==size(TestAnfang_Raum, 2)
            fprintf('Fortschritt: %.1f%% \n', test_num/size(TestAnfang_Raum, 2)*100 )
        end
        
    end
    
    %Punkte Error
    RMSE_k = table(0,0,0,0,0,0,0, 'VariableNames', {'K', 'RMSE', 'NRMSE','RMQE','NRMQE','MAE','MAPE'});
    Error_k = Error;
    %Y_k = Error + Prognose;
    Y_k = Messwerte;

    first = TestAnfang_Raum(1) + minutes(15);
    last = TestEnde_Raum(end) ;
    N = mean(GesamtDaten.Leistung(find(GesamtDaten.Zeit == first) : find(GesamtDaten.Zeit == last)));
    %N = 15.8;%Installierte Leistung 15.8kW
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
        temp_1(find(temp_1> 500)) = 0;
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

    TestErg = {RMSE_k, GesamtPrognose};


end

