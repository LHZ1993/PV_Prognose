function Prognose_mitError = estimate_quantile(Prognose, Quantile, ClearSky,K_Step, num)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here




        CS = ClearSky.Leistung(find(ClearSky.Zeit ==Prognose.Zeit(1)):find(ClearSky.Zeit ==Prognose.Zeit(end)));

        Prognose.CS = CS;

        Prognose.LeistungPro = Prognose.CS .* Prognose.RelPro;

        RelPro=Prognose.RelPro;
        
    if num == 1
        
        Prognose.Quantile_1 = Quantile.Quantile_10(1:K_Step) .* Prognose.CS .* RelPro;
        Prognose.Quantile_2 = Quantile.Quantile_20(1:K_Step) .* Prognose.CS .* RelPro;
        Prognose.Quantile_3 = Quantile.Quantile_30(1:K_Step) .* Prognose.CS .* RelPro;
        Prognose.Quantile_4 = Quantile.Quantile_40(1:K_Step).* Prognose.CS .* RelPro;
        Prognose.Quantile_5 = Quantile.Quantile_50(1:K_Step) .* Prognose.CS .* RelPro;
        Prognose.Quantile_6 = Quantile.Quantile_60(1:K_Step) .* Prognose.CS .* RelPro;
        Prognose.Quantile_7 = Quantile.Quantile_70(1:K_Step) .* Prognose.CS .* RelPro;
        Prognose.Quantile_8 = Quantile.Quantile_80(1:K_Step) .* Prognose.CS .* RelPro;
        Prognose.Quantile_9 = Quantile.Quantile_90(1:K_Step) .* Prognose.CS .* RelPro;

        Prognose_mitError = Prognose;

    elseif num ==2 

        CDF = table(0,0,0,0,0,0,0,0,0,0,0,'VariableNames',{'Zeit','CDF', 'Quantile_10','Quantile_20', 'Quantile_30','Quantile_40','Quantile_50','Quantile_60','Quantile_70','Quantile_80','Quantile_90',});

        for i = 1: size(Prognose.Zeit,1)

            Zeit = datenum(Prognose.Zeit(i));

            if Prognose.MonteCarlo {i,1}== 0

                Zeile = {Zeit, 0, 0, 0,0,0,0,0,0,0,0};
                CDF = [CDF; Zeile];
                continue
            end

            temp = cell2mat(Prognose.MonteCarlo(i));

            Quantile_1 = prctile(temp,10);
            Quantile_2 = prctile(temp,20);
            Quantile_3 = prctile(temp,30);
            Quantile_4 = prctile(temp,40);
            Quantile_5 = prctile(temp,50);
            Quantile_6 = prctile(temp,60);
            Quantile_7 = prctile(temp,70);
            Quantile_8 = prctile(temp,10);
            Quantile_9 = prctile(temp,90);


            Zeile = {Zeit, 0, Quantile_1,Quantile_2,Quantile_3,Quantile_4,Quantile_5,Quantile_6,Quantile_7,Quantile_8,Quantile_9};
            CDF = [CDF; Zeile];

            Prognose.MonteCarlo(i) = {temp .* Prognose.CS(i)};
        end

        CDF(1,:) = [];

        Prognose.Quantile_1 = CDF.Quantile_10 .* Prognose.CS;
        Prognose.Quantile_2 = CDF.Quantile_20 .* Prognose.CS;
        Prognose.Quantile_3 = CDF.Quantile_30 .* Prognose.CS;
        Prognose.Quantile_4 = CDF.Quantile_40 .* Prognose.CS;
        Prognose.Quantile_5 = CDF.Quantile_50 .* Prognose.CS ;
        Prognose.Quantile_6 = CDF.Quantile_60 .* Prognose.CS ;
        Prognose.Quantile_7 = CDF.Quantile_70 .* Prognose.CS ;
        Prognose.Quantile_8 = CDF.Quantile_80 .* Prognose.CS ;
        Prognose.Quantile_9 = CDF.Quantile_90 .* Prognose.CS ;
        %Prognose.Quantile_1 = CDF.Quantile_1 .* Prognose.CS;
        %Prognose.UP = CDF.UP .* Prognose.CS;

        Prognose_mitError = Prognose;

    end
end

