function Best_NWP=  recursive_least_squares(Step, Wetter, Merkmal)
%UNTITLED Summary of this function goes here

    obj = recursiveLS(Step);
    
    if strcmp(Merkmal , 'Temperatur')
        input = double(Wetter.Temperatur);
        
    elseif strcmp(Merkmal, 'Bewoelkung')
        input = double(Wetter.Bewoelkerung);
        
    end
    
    %input = double(Wetter.Feuchtigkeit);
    output = double(Wetter.Leistung);
    Fehler = {};
    anzahl = 1;
    fprintf('Berechnen NWP Daten zur Relativen Leistungen \n');

    for factor = 0.9 : 0.005 : 1

        obj.ForgettingFactor = factor;

        for i = 1:numel(input)
            [theta,EstimatedOutput] = step(obj,output(i),input(i));
            Wetter.Theta(i) = theta;
            Wetter.NWP_Leistung(i) = EstimatedOutput;
        end

        Wetter.NWP_Rel = Wetter.NWP_Leistung ./ Wetter.CS;
        Wetter.NWP_Rel(find(Wetter.NWP_Rel == Inf)) = 0;
        Wetter.NWP_Rel(find(Wetter.NWP_Rel == -Inf)) = 0;
        Wetter.NWP_Rel(find(Wetter.NWP_Rel == NaN)) = 0;
        Wetter.NWP_Rel(find(Wetter.NWP_Rel <= 0)) = 0;

        Wetter.RMSE = Wetter.Leistung - Wetter.NWP_Leistung;
        RMSE = mean(Wetter.RMSE .^2).^(0.5);
        Theta = Wetter.Theta(end);
        Wetter_NWP = Wetter;

        Fehler{anzahl,1} = factor;
        Fehler{anzahl,2} = Wetter_NWP;
        Fehler{anzahl,3} = RMSE;

        anzahl = anzahl +1 ;

        if mod(factor,0.01) == 0 || (factor == 1)
            forschritt = (factor - 0.9) * 1000;
            fprintf('Forschritt: %.1f%% \n', forschritt);
        end
    end
    matrix_RMSE = cell2mat(Fehler(:,3));
    best_RMSE = min(matrix_RMSE);
    best_index = find(matrix_RMSE == best_RMSE);

    Best_NWP = Fehler(best_index, :);

end