function [TestErg] = fitnet_auswerten(FIT_Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Anhand von in konfiguration.m ausgewählten Konfiguration.Test.ZeitAngang,
%Konfiguration.Test.ZeitEnde und Konfiguration.Test.Auflösung wird der Testzeitraum
%bestimmt und das FF-Netz getestet.
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


    %Print Infos
    fprintf('Auswertung des FIT-Netzs \n');
    fprintf('Testzeitraum vom %s bis zum %s \n', datestr(Konfiguration.Test.ZeitAnfang),datestr(Konfiguration.Test.ZeitEnde));
    
    %FF Netz einlesen
    neti = FIT_Modell{1,1};
    
    %CS-Faktor umrechnen
    Cut = Konfiguration.CS.Cut;
    GesamtLeistung = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut);
    
    %Inputparameter DoY und ToD berechnen
    %DoY >>> Tag im Jahr(Day of year)
    %ToD >>> Uhrzeit am Tag(Time of Day)
    GesamtDaten = verknuepfen_gesamtleistung_wetter_RF(WetterRow, GesamtLeistung);
    Zeit=reshape(GesamtDaten.Zeit,[],1);

    DoY = 1+floor(days(Zeit-datetime(year(Zeit),1,1)));
    ToD = hour(Zeit)+minute(Zeit)/60;

    DoY=reshape(DoY,1,[]);
    ToD=reshape(ToD,1,[]);

    GesamtDaten.DoY = DoY';
    GesamtDaten.ToD = ToD';

    %Inputparameter auswählen
    Alle_Inputparameter = GesamtDaten.Properties.VariableNames;
    Auswahl_Inputparameter = Konfiguration.FF.Inputparamter;
    inputvektor = inputparameter_auswaehlen(Auswahl_Inputparameter, Alle_Inputparameter);
    
    %NN Testzeitraum auswählen
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
        
        xar = table2array(TestDaten(:,inputvektor))'; %NN Inputs fuer fitnet
        yar = neti(xar);
        rel = yar(1, :)';
        
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
    
    
    %Punkte Error wird in table RMSE_k gespeichert(RMSE, NRMSE...).
    RMSE_k = table(0,0,0,0,0,0,0, 'VariableNames', {'K', 'RMSE', 'NRMSE','RMQE','NRMQE','MAE','MAPE'});

    Error_k = Error;
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

