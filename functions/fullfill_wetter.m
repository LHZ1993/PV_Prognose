function  Wetter = fullfill_wetter(WetterRow)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    WetterRow.Temperatur = int32(WetterRow.Temperatur);
    WetterRow.Niederschlagrisiko = int32(WetterRow.Niederschlagrisiko);
    WetterRow.Niederschlagmenge = double(WetterRow.Niederschlagmenge);
    WetterRow.Windgeschwindigkeit = int32(WetterRow.Windgeschwindigkeit);
    WetterRow.Luftdruck = int32(WetterRow.Luftdruck);
    WetterRow.Feuchtigkeit = int32(WetterRow.Feuchtigkeit);
    WetterRow.Bewoelkerung = double(WetterRow.Bewoelkerung);

    for i = 1: size(WetterRow.Zeit,1)
        summe = WetterRow.Temperatur(i) + WetterRow.Niederschlagrisiko(i)+ WetterRow.Niederschlagmenge(i)+  WetterRow.Windgeschwindigkeit(i)+  WetterRow.Luftdruck(i)+  WetterRow.Feuchtigkeit(i)+WetterRow.Bewoelkerung(i);
        if summe == 0
            WetterRow.FehlerWert(i) = 1;
        else
            WetterRow.FehlerWert(i) = 0;
        end
    end

    %FehlerZeit = WetterRow.Zeit(find(WetterRow.FehlerWert ==1));

    for i = 2: size(WetterRow.Zeit,1)
        last_index = i -1;
        Temperatur = WetterRow.Temperatur(last_index);
        Niederschlagrisiko =  WetterRow.Niederschlagrisiko(last_index);
        Niederschlagmenge = WetterRow.Niederschlagmenge(last_index);
        Windgeschwindigkeit = WetterRow.Windgeschwindigkeit(last_index);
        Luftdruck = WetterRow.Luftdruck(last_index);
        Feuchtigkeit = WetterRow.Feuchtigkeit(last_index);
        Bewoelkerung = WetterRow.Bewoelkerung(last_index);


        if WetterRow.FehlerWert(i) == 1
            WetterRow.Temperatur(i) = Temperatur;
            WetterRow.Niederschlagrisiko(i) = Niederschlagrisiko;
            WetterRow.Niederschlagmenge(i) = Niederschlagmenge;
            WetterRow.Windgeschwindigkeit(i) = Windgeschwindigkeit;
            WetterRow.Luftdruck(i) = Luftdruck;
            WetterRow.Feuchtigkeit(i) = Feuchtigkeit;
            WetterRow.Bewoelkerung(i) = Bewoelkerung;
            continue   
        end
    end
    
    Wetter = WetterRow;
end

