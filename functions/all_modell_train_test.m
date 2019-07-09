function [Modell,Erg] = all_modell_train_test(Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Inptdaten Konfiguration, LeistungZeit, ClearSky und WetterRow durch
%konfiguration.m vorbereiten
%Trainierte Modelle werden in Modell gespeichert.
%ARX-Modell>>>Modell{1,1}
%ARX-NN-Modell>>>Modell{1,2}
%FF-Netz>>>Modell{1,3}
%NARX-Netz>>>Modell{1,4}
%RandomForest>>>Modell{1,5}
%Berechneter Ergebnisse werden in Erg geseichert.

    Modell = {};
    Erg = {};
   
    for modell_num = 1:size(Konfiguration.ModellName,2)
    
        modell_name = Konfiguration.ModellName{1,modell_num};
        
        %1.ARXB trainieren und auswerten
        if strcmp(modell_name, 'ARX')

            [modell_arxb , quantile_modell_arxb] = arx_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Modell{1,1} = {modell_arxb , quantile_modell_arxb};

            ARXB_Modell = {modell_arxb , quantile_modell_arxb};

            [TestErg1] = arx_auswerten(ARXB_Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Erg{1,1} = {TestErg1};


        %2.ARXNN trainieren und auswerten
        elseif strcmp(modell_name, 'ARXNN')

            [modell_arxnn , quantile_modell_arxnn, net] = arx_nn_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Modell{1,2} = {modell_arxnn , quantile_modell_arxnn, net};

            ARXNN_Modell = {modell_arxnn , quantile_modell_arxnn, net};

            [TestErg2] = arx_nn_auswerten(ARXNN_Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Erg{1,2} = {TestErg2};


        %3.FF trainieren und auswerten
        elseif strcmp(modell_name, 'FF')

            [modell_fit_net] = fitnet_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Modell{1,3} = {modell_fit_net};
            
            FIT_Modell = {modell_fit_net};

            [TestErg3] = fitnet_auswerten(FIT_Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Erg{1,3} = {TestErg3};


        %4.NARX trainieren und auswerten
        elseif strcmp(modell_name, 'NARX')

            [modell_narx_net] = narxnet_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Modell{1,4} = {modell_narx_net};
            
            NARX_Modell = {modell_narx_net};

            [TestErg4] = narxnet_auswerten(NARX_Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Erg{1,4} = {TestErg4};

        %5.RF trainieren und auswerten
        elseif strcmp(modell_name, 'RF')

            [modell_rf] = rf_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Modell{1,5} = {modell_rf};
            
            RF_Modell = {modell_rf};

            [TestErg5] = rf_auswerten(RF_Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow);

            Erg{1,5} = {TestErg5};
            
        %6.Keine richtige Modelle     
        else
            fprintf('Konfiguration.ModellName ist leer oder falsch! \n')
        end
    end


end

