function Resample_Wetter = resample_hour_15min(Best_Wetter)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here 
    fprintf('resample 1h data to 15min data \n')

    first = Best_Wetter.Zeit(1);
    last = Best_Wetter.Zeit(end);
    ZeitRaum = (first: minutes(15): last);

    NWP = zeros(size(ZeitRaum,2),1)*nan;

    Resample_Wetter = table(ZeitRaum', NWP, NWP,NWP,NWP,NWP,NWP,NWP, 'VariableNames', {'Zeit', 'Temperatur', 'Niederschlagrisiko',...
        'Niederschlagmenge','Windgeschwindigkeit','Luftdruck','Feuchtigkeit', 'Bewoelkerung'});

    
    for i = 1 : size(Best_Wetter.Zeit,1)
        
        re_index =  find(Resample_Wetter.Zeit == Best_Wetter.Zeit(i));
        
        Resample_Wetter(re_index, 2:8) = Best_Wetter (i, 2:8);
        
    end

    for col_linear = [2,5,6,7,8]
        
        temp = Resample_Wetter(:, col_linear);
        %A = table2array(temp);
        %Null = find(A == 0);
        %A(Null) =NaN;
        %temp = array2table(A);
        Resample_Wetter(:, col_linear) = fillmissing(temp, 'linear');
        
    end
    
    for col_last = [3,4]
        
        temp = Resample_Wetter(:, col_last);
        
        Resample_Wetter(:, col_last) = fillmissing(temp, 'previous');
        
    end

        
end
   
