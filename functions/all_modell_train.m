function [Modell] = all_modell_train(Konfiguration, LeistungZeit, ClearSky, WetterRow)
%Alle trainierten Modelle werden in Output Modell(Datentype: cell) gespeichert.
%ARX-Modell>>>Modell{1,1}
%ARX-NN-Modell>>>Modell{1,2}
%FF-Netz>>>Modell{1,3}
%NARX-Netz>>>Modell{1,4}
%RandomForest>>>Modell{1,5}

    Modell = {};
    
    for modell_num = 1: size(Konfiguration.ModellName,2)
        
        modell_name = Konfiguration.ModellName{1,modell_num};
        
        %1.ARXB trainieren
        if strcmp(modell_name, 'ARX')

            [modell_arxb , quantile_modell_arxb] = arx_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Modell{1,1} = {modell_arxb , quantile_modell_arxb};


        %2.ARXNN trainieren
        elseif strcmp(modell_name, 'ARXNN')

            [modell_arxnn , quantile_modell_arxnn, net] = arx_nn_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Modell{1,2} = {modell_arxnn , quantile_modell_arxnn, net};

        %3.FF trainieren
        elseif strcmp(modell_name, 'FF')

            [net] = fitnet_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Modell{1,3} = {net};
            
        %4.NARX trainieren
        elseif strcmp(modell_name, 'NARX')
        
            [net] = narxnet_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Modell{1,4} = {net};
        
        %5.RF trainieren
        elseif strcmp(modell_name, 'RF')
        
            [forest] = rf_trainieren(Konfiguration, LeistungZeit, ClearSky, WetterRow);
            Modell{1,5} = {forest};

        end
    end
end

