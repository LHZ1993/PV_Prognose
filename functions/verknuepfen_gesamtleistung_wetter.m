function Daten = verknuepfen_gesamtleistung_wetter(Wetter_Resample, GesamtLeistung)
%Tabellen Wetter_Resample und GesamtLeistung werden durch diese Funktion in
%einem gleichen Zeitraum gesetzt. Output Daten ist eine Tabelle mit Spalten
%Zeit, Leistung(PV-Leistung), CS(CS-Leistung), Rel(CS-Faktor) und NWP_Rel(Exogener Eingang für ARX-Modell)

    Daten_anfang = max(GesamtLeistung.Zeit(1), Wetter_Resample.Zeit(1));
    Daten_end = min(GesamtLeistung.Zeit(end), Wetter_Resample.Zeit(end));
    
    index1_wetter = find(Wetter_Resample.Zeit == Daten_anfang);
    index2_wetter = find(Wetter_Resample.Zeit == Daten_end);
    
    index1_leistung = find(GesamtLeistung.Zeit == Daten_anfang);
    index2_leistung = find(GesamtLeistung.Zeit == Daten_end);
    
    Leistung = GesamtLeistung(index1_leistung:index2_leistung, : );
    Wetter = Wetter_Resample(index1_wetter:index2_wetter, : );
    
    for i_wetter = 1: size(Wetter.Zeit,1)
        i_leistung = find(Leistung.Zeit == Wetter.Zeit(i_wetter));
        Leistung.NWP_Rel(i_leistung) =  Wetter.NWP_Rel(i_wetter);
    end
    
    Daten = Leistung;
  
end

