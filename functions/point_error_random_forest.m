function Gesamt = point_error_random_forest(Prognosewerte,Messwerte)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    Error = table();
    Error.Y = Messwerte;
    Error.X = Prognosewerte;
    Error.E = Error.Y - Error.X;
    
    RMSE = mean(Error.E .^2) .^0.5;
    NRMSE = RMSE / mean(Error.Y);

    RMQE = mean(Error.E .^4) .^0.25;
    NRMQE = RMQE /mean(Error.Y);

    MAE = mean(abs(Error.E));
    
    zwischen_1 = abs(Error.E ./ Error.Y) * 100;
    %zwischen_2 = abs(Error.E ./ mean(Error.Y)) * 100;
    zwischen_1(find(zwischen_1 == Inf)) = 0;
    zwischen_1(find(isnan(zwischen_1))) = 0;
    
    MAPE = mean(zwischen_1);
    
    Error_k = zeros(size(Messwerte,1)-287,287);
    Y_k = zeros(size(Messwerte,1)-287,287);
    X_k = zeros(size(Messwerte,1)-287,287);

    for i = 1: size(Messwerte,1) - 287

        Error_k(i, :) = Error.E(i+1: i + 287);
        Y_k(i, :) = Error.Y(i+1: i + 287);
        X_k(i, :) = Error.X(i+1: i + 287);

    end
    
    RMSE_k = table(0,0,0,0,0,0,0, 'VariableNames', {'K', 'RMSE', 'NRMSE','RMQE','NRMQE','MAE','MAPE'});

    N = mean(Error.Y);
    
    for k = 1:287
    
        K= k;

        rmse= mean(Error_k(: , k) .^2) .^0.5;
        nrmse= mean(Error_k(: , k) .^2) .^0.5 /N;

        rmqe= mean(Error_k(: , k) .^4) .^0.25;
        nrmqe= mean(Error_k(: , k) .^4) .^0.25 /N;

        mae= mean(abs(Error_k(: , k)));
        
        temp_1 = abs(Error_k(: , k) ./  Y_k(:, k)) *100;
        %temp_2 = abs(Error_k(: , k) ./  mean(Y_k(:, k))) *100;
        temp_1(find( temp_1 == Inf)) = 0;
        temp_1(find( isnan( temp_1) )) = 0;
        
        mape= mean(temp_1);

        zeile = {K, rmse, nrmse, rmqe, nrmqe, mae, mape};

        RMSE_k = [RMSE_k ; zeile];
        
    end

    RMSE_k(1, :) = [];
    
    
    Gesamt = {RMSE_k, RMSE, NRMSE, RMQE, NRMQE, MAE, MAPE};

end

