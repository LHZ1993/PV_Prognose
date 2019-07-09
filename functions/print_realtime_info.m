function print_realtime_info(Konfiguration)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    jetzt_min = datetime('now').Minute;
    download_min = Konfiguration.PrognoseMinute;
    
    if download_min > jetzt_min
        
        naechst = datetime(datetime('now').Year, datetime('now').Month, datetime('now').Day, datetime('now').Hour, download_min, 0);
        
    elseif download_min <= jetzt_min
        
        naechst = datetime(datetime('now').Year, datetime('now').Month, datetime('now').Day, datetime('now').Hour, download_min, 0) + hours(1);
        
    end
    
    fprintf('Atkueller Zeitpunkt : %s \n', datetime('now'))
    fprintf('Prognose Zeitpunkt : %s \n', naechst)
    
end

