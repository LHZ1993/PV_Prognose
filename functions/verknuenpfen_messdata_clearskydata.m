function Daten_gesamt = verknuenpfen_messdata_clearskydata(LeistungZeit,ClearSky, Cut)
%Durch diese Funktion wird der CS-Faktor berechnet(Absolute PV-Leistung
%durch CS-Leistung). Auﬂerdem werden PV-Leistung, CS-Leistung und CS-Faktor
%in einem gleichen Zeitraum gesetzt. Output ist eine Tabelle mit Saplten
%Zeit, Leistung(PV-Leistung), CS(CS-Leistung) und Rel(CS-Faktor).
    
    Daten_anfang = max(LeistungZeit.Zeit(1), ClearSky.Zeit(1));
    Daten_end = min(LeistungZeit.Zeit(end), ClearSky.Zeit(end));

    Daten_gesamt = table();

    Leistung_index1 = find(LeistungZeit.Zeit== Daten_anfang);
    Leistung_index2 = find(LeistungZeit.Zeit == Daten_end);

    CS_index1 = find(ClearSky.Zeit == Daten_anfang);
    CS_index2 = find(ClearSky.Zeit == Daten_end);

    Zeit = LeistungZeit.Zeit(Leistung_index1: Leistung_index2);

    Leistung = LeistungZeit.Leistung(Leistung_index1: Leistung_index2);

    CS = ClearSky.Leistung(CS_index1: CS_index2);
    CS_max = max(CS);
    CS(find(CS ./ CS_max < Cut)) = 0;


    Rel = Leistung ./ CS;
    Rel(isnan(Rel)) = 0;
    Rel(Rel == Inf) = 0;

    Daten_gesamt.Zeit = Zeit;
    Daten_gesamt.Leistung = Leistung;
    Daten_gesamt.CS = CS;
    Daten_gesamt.Rel = Rel;
end

