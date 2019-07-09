function [ACF, PACF] = acf_funktion(Data, Lags)
% Autokorrelation Analyse

%1. n'lags 
[acf , lag_1] = autocorr(Data, Lags);
ACF = table(acf, lag_1, 'VariableNames', {'acf', 'lag'});

[pacf, lag_2] = parcorr(Data,Lags);
PACF = table(pacf, lag_2, 'VariableNames', {'pacf', 'lag'});

%2. plot ACF and PACF
figure('Name','ACF')
autocorr(Data,Lags)

figure('Name','PACF')
parcorr(Data,Lags)

end

