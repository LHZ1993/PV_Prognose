function Resample_Wetter = resample_nwp_leistung(Best_Wetter, GesamtLeistung, Methode, Merkmal)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %Best_Wetter =  Best_NWP{1,2};
    %Zeit = datenum(Best_Wetter.Zeit);
    if strcmp(Methode,'RLS')
        
        first = Best_Wetter.Zeit(1);
        last = Best_Wetter.Zeit(end);
        ZeitRaum = (first: minutes(15): last);

        NWP = zeros(1, size(ZeitRaum,2));
        cs_index1 = find(GesamtLeistung.Zeit == first);
        cs_index2 = find(GesamtLeistung.Zeit == last);

        CS = GesamtLeistung.CS(cs_index1: cs_index2);

        Resample_Wetter = table(ZeitRaum', NWP', 'VariableNames', {'Zeit', 'NWP_Rel'});

        for i = 1 : size(Best_Wetter.Zeit,1)
            re_index =  find(Resample_Wetter.Zeit == Best_Wetter.Zeit(i));
            Resample_Wetter.NWP_Rel(re_index) = Best_Wetter.NWP_Leistung(i);
        end


        Resample_Wetter.NWP_Rel(find(Resample_Wetter.NWP_Rel == 0)) = NaN; 

        NWP_Leistung = fillmissing(Resample_Wetter.NWP_Rel,'linear');

        Resample_Wetter.NWP_Rel = NWP_Leistung./ CS ;
        Resample_Wetter.NWP_Rel(find(Resample_Wetter.NWP_Rel == -Inf )) = 0;
        Resample_Wetter.NWP_Rel(find(Resample_Wetter.NWP_Rel == Inf )) = 0;
        Resample_Wetter.NWP_Rel(find(Resample_Wetter.NWP_Rel < 0 )) = 0;
        
    elseif Methode == 0
        
        if strcmp(Merkmal, 'Temperatur')
            input = Best_Wetter.Temperatur;
            
        elseif strcmp(Merkmal, 'Bewoelkung')
            input = Best_Wetter.Bewoelkerung;
            
        end
        
        first = Best_Wetter.Zeit(1);
        last = Best_Wetter.Zeit(end);
        ZeitRaum = (first: minutes(15): last);

        NWP = zeros(1, size(ZeitRaum,2));
       
        Resample_Wetter = table(ZeitRaum', NWP', 'VariableNames', {'Zeit', 'NWP_Rel'});

        for i = 1 : size(Best_Wetter.Zeit,1)
            re_index =  find(Resample_Wetter.Zeit == Best_Wetter.Zeit(i));
            Resample_Wetter.NWP_Rel(re_index) = input(i);
        end


        Resample_Wetter.NWP_Rel(find(Resample_Wetter.NWP_Rel == 0)) = NaN; 

        NWP_Leistung = fillmissing(Resample_Wetter.NWP_Rel,'linear');

        Resample_Wetter.NWP_Rel = NWP_Leistung;
        
    end
           
        
end
    

   
    
    