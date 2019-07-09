function model2database(DatenbankPath,DatenbankName,NewTableName,EstModell)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    Parameter = table(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 'VariableNames' , {'K', 'Constant', 'P', 'AR_first', 'AR_second', 'Beta','Var', ...
        'Quantile_10', 'Quantile_15', 'Quantile_20', 'Quantile_25', 'Quantile_30', 'Quantile_35', 'Quantile_40',...
        'Quantile_45', 'Quantile_50', 'Quantile_55', 'Quantile_60', 'Quantile_65', 'Quantile_70', 'Quantile_75'...
        , 'Quantile_80', 'Quantile_85', 'Quantile_90'});

    for k = 1: size(EstModell,1)

        model = EstModell{k ,2};
        Constant = model.Constant;
        P = model.P ;
        AR_first = model.AR { 1, k };
        AR_second = model.AR { 1, P};
        Beta = model.Beta;
        Variance = model.Variance;
        
        Q_10 = EstModell{k, 4};
        Q_15 = EstModell{k, 5};
        Q_20 = EstModell{k, 6};
        Q_25 = EstModell{k, 7};
        Q_30 = EstModell{k, 8};
        Q_35 = EstModell{k, 9};
        Q_40 = EstModell{k, 10};
        Q_45 = EstModell{k, 11};
        Q_50 = EstModell{k, 12};
        Q_55 = EstModell{k, 13};
        Q_60 = EstModell{k, 14};
        Q_65 = EstModell{k, 15};
        Q_70 = EstModell{k, 16};
        Q_75 = EstModell{k, 17};
        Q_80 = EstModell{k, 18};
        Q_85 = EstModell{k, 19};
        Q_90 = EstModell{k, 20};
        
        Zeile = {k, Constant , P, AR_first, AR_second, Beta, Variance, Q_10 , Q_15, Q_20, Q_25, Q_30, Q_35...
            , Q_40, Q_45, Q_50, Q_55, Q_60, Q_65, Q_70, Q_75, Q_80, Q_85, Q_90};
        
        Parameter = [Parameter; Zeile];
    end
    
    Parameter(1 , : ) = [];
    
    MatDaten = Parameter;
    
    write_table_db(DatenbankPath,DatenbankName,NewTableName,MatDaten);
    
end

