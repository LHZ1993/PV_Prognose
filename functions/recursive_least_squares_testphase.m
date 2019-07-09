function WetterNeu= recursive_least_squares_testphase(Step, Wetter, GesamtLeistung, ClearSky)
%UNTITLED Summary of this function goes here

    Anfang = max(Wetter.Zeit(1), GesamtLeistung.Zeit(1));
    Zwischen = min(Wetter.Zeit(end), GesamtLeistung.Zeit(end));

    wetter = Wetter.Temperatur(find(Wetter.Zeit == Anfang) : find(Wetter.Zeit == Zwischen));
    leistung = GesamtLeistung.Leistung(find(GesamtLeistung.Zeit == Anfang): find(GesamtLeistung.Zeit == Zwischen));
    cs = ClearSky.Leistung(find(ClearSky.Zeit == Anfang): find(ClearSky.Zeit == Wetter.Zeit(end)));
    
    obj = recursiveLS(Step);
    input = double(wetter);
    output = double(leistung);
    
    Fehler = {};
    anzahl = 1;
    fprintf('Berechnen NWP Daten zur Relativen Leistungen \n');

    for factor = 0.9 : 0.005 : 1

        obj.ForgettingFactor = factor;

        for i = 1:size(Wetter,1)
            
            if i <= numel(input)
            
                [theta,EstimatedOutput] = step(obj,output(i),input(i));
                Wetter.Theta(i) = theta;
                Wetter.NWP_Leistung(i) = EstimatedOutput;
                
            elseif i > numel(input)
                
                Wetter.Theta(i) = theta;
                Wetter.NWP_Leistung(i) = EstimatedOutput;
                
            end
        end

        Wetter.NWP_Rel = Wetter.NWP_Leistung ./ cs;
        Wetter.NWP_Rel(find(Wetter.NWP_Rel == Inf)) = 0;
        Wetter.NWP_Rel(find(Wetter.NWP_Rel == -Inf)) = 0;
        Wetter.NWP_Rel(find(Wetter.NWP_Rel == NaN)) = 0;
        Wetter.NWP_Rel(find(Wetter.NWP_Rel <= 0)) = 0;

        Wetter.RMSE(1 : find(Wetter.Zeit == Zwischen)) = leistung - Wetter.NWP_Leistung(1 : find(Wetter.Zeit == Zwischen));
        RMSE = mean(Wetter.RMSE(1 : find(Wetter.Zeit == Zwischen)) .^2).^(0.5);
        Theta = Wetter.Theta(end);
        %Wetter_NWP = Wetter;

        Fehler{anzahl,1} = factor;
        Fehler{anzahl,2} = Wetter;
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
    
    WetterNeu = Wetter;
    
end