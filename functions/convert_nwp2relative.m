function Wetter_Resample = convert_nwp2relative(Wetter, GesamtLeistung, Merkmal)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    Daten_anfang = max(GesamtLeistung.Zeit(1), Wetter.Zeit(1));
    Daten_end = min(GesamtLeistung.Zeit(end), Wetter.Zeit(end));

    Leistung_index1 = find(GesamtLeistung.Zeit == Daten_anfang);
    Leistung_index2 = find(GesamtLeistung.Zeit == Daten_end);

    Wetter_index1 = find(Wetter.Zeit == Daten_anfang);
    Wetter_index2 = find(Wetter.Zeit == Daten_end);


    Leistung = GesamtLeistung.Leistung(Leistung_index1:Leistung_index2);
    CS = GesamtLeistung.CS(Leistung_index1:Leistung_index2);
    %Rel = GesamtDaten.Rel(Leistung_index1: Leistung_index2);
    Wetter = Wetter(Wetter_index1: Wetter_index2, :);

    Wetter.Leistung = [Leistung];
    Wetter.CS = [CS];

    if strcmp(Merkmal , 'Temperatur')

        Wetter.NWP_Rel = Wetter.Temperatur;
        Wetter_Resample = Wetter;

    elseif strcmp(Merkmal, 'Bewoelkung')

        Wetter.NWP_Rel = double(Wetter.Bewoelkerung);
        Wetter_Resample = Wetter;
        
    end

   
end

