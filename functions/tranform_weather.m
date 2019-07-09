function WetterNeu = tranform_weather(Wetter, GesamtLeistung, ClearSky , Methode)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if strcmp(Methode,'RLS')
        
        Step= 1;
        WetterNeu = recursive_least_squares_testphase(Step, Wetter,GesamtLeistung, ClearSky);

    elseif Methode == 0

        WetterNeu = Wetter;
        WetterNeu.NWP_Rel = Wetter.Bewoelkerung;

    end

    
end


