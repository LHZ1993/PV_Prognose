function Wetter_Resample = exogen_einggang_auswaehlen(Wetter, Merkmal)
%Durch diese Funktion wird exogener Eingang des ARX-Modells ausgewält.
%Output ist eine Tabelle. Die Spalte Wetter.NWP_Rel entspricht dem exogenem
%Eingang.

    if strcmp(Merkmal , 'Temperatur')

        Wetter.NWP_Rel = Wetter.Temperatur;
        Wetter_Resample = Wetter;

    elseif strcmp(Merkmal, 'Bewoelkung')

        Wetter.NWP_Rel = double(Wetter.Bewoelkerung);
        Wetter_Resample = Wetter;
        
    end

end

