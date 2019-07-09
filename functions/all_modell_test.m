function [Erg] = all_modell_test(Modell, Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Inputdaten Modell >>> Alle auszuwertenden Modelle werden in Modell(Datentyp: cell) gespeichert.
%ARX-Modell>>>Modell{1,1}
%ARX-NN-Modell>>>Modell{1,2}
%FF-Netz>>>Modell{1,3}
%NARX-Netz>>>Modell{1,4}
%RandomForest>>>Modell{1,5}
%Inptdaten Konfiguration, LeistungZeit, ClearSky und WetterRow durch
%konfiguration.m vorbereiten

    Erg = {};
    
    for modell_num = 1: size(Konfiguration.ModellName,2)
        
        modell_name = Konfiguration.ModellName{1,modell_num};
        
        %1.ARXB auswerten
        if strcmp(modell_name, 'ARX')

            [TestErg1] = arx_auswerten(Modell{1,1}, Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Erg{1,1} = {TestErg1};
            
            
        %2.ARXNN auswerten
        elseif strcmp(modell_name, 'ARXNN')

            [TestErg2] = arx_nn_auswerten(Modell{1,2}, Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Erg{1,2} = {TestErg2};
            
        %3.FF auswerten
        elseif strcmp(modell_name, 'FF')

            [TestErg3] = fitnet_auswerten(Modell{1,3}, Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Erg{1,3} = {TestErg3};
         
        %4.NARX auswerten
        elseif strcmp(modell_name, 'NARX')

            [TestErg4] = narxnet_auswerten(Modell{1,4}, Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Erg{1,4} = {TestErg4};
            
        %5.RF auswerten
        elseif strcmp(modell_name, 'RF')

            [TestErg5] = rf_auswerten(Modell{1,5}, Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Erg{1,5} = {TestErg5};  
            
        end
    end
end

