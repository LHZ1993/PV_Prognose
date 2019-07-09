function Daten = verknuepfen_gesamtleistung_wetter_RF(Wetter_Resample, GesamtLeistung)
%Inputdaten sind zwei table Wetter_Resample und GesamtLeistung
%Durch diese Funktion werden die Wetter_Resample und GesamtLeistung in 
%einem gleicen Zeiraum gesetzt und miteinander verknüpft.
%Output Daten ist table mit Spalten Zeit, Leistung, CS, Rel, Temperatur
%Niederschlagrisiko, Niederschlagmenge, Windgeschwindigkeit, Luftdruck,
%Feuchtigkeit, Bewoelkerung

    Daten_anfang = max(GesamtLeistung.Zeit(1), Wetter_Resample.Zeit(1));
    Daten_end = min(GesamtLeistung.Zeit(end), Wetter_Resample.Zeit(end));
    
    index1_wetter = find(Wetter_Resample.Zeit == Daten_anfang);
    index2_wetter = find(Wetter_Resample.Zeit == Daten_end);
    
    index1_leistung = find(GesamtLeistung.Zeit == Daten_anfang);
    index2_leistung = find(GesamtLeistung.Zeit == Daten_end);
    
    Leistung = GesamtLeistung(index1_leistung:index2_leistung, : );
    Wetter = Wetter_Resample(index1_wetter:index2_wetter, 2:end);
    
    Daten = [Leistung, Wetter];

  
end

