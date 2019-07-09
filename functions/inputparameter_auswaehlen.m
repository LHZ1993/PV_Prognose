function [ind_inputvektor] = inputparameter_auswaehlen( Ausw_Inputnamen, Alle_Inputnamen)
%inputparameter_auswaehlen gibt die Indizes der Inputparameter zurück
%z.B Alle_Inputnamen = {'CS', 'Temperatur', 'Niederschlagrisiko', 'Niederschlagmenge',
%'Windgeschwindigkeit', 'Luftdruck', 'Feuchtigkeit', 'Bewoelkerung', 'DoY','ToD'};
%Ausw_Inputnamen = {'Temperatur', 'Bewoelkerung'};
%ind_inputvektor = [2, 9];

    numinp = length(Ausw_Inputnamen);
    ind_inputvektor = zeros(1,numinp);
    for iaus = 1:numinp
        for ialle = 1:length(Alle_Inputnamen)
            if strcmp(Ausw_Inputnamen{iaus},Alle_Inputnamen{ialle})
                ind_inputvektor(iaus) = ialle;
                break
            end
        end
    end
    
end

