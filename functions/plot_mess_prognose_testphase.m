function plot_mess_prognose_testphase(Prognose_mitError,i)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    x = Prognose_mitError.Zeit;
    y2 = Prognose_mitError.LeistungPro;
    y3 = Prognose_mitError.Quantile_1 ;
    y4 = Prognose_mitError.Quantile_9;
    
    a = reshape(y3, 1, []);
    b = reshape(y4, 1, []);
    t = reshape(x, 1, []);
    %y3 = Prognose_mitError.MonteCarlo;
    
    figure(i)
    %xlim([x(1),x(end)])
    h3 = fill([t fliplr(t)],[b fliplr(a)],[0.3 0.8 0.9]);
    grid on 
    hold on 
    h2 = plot(x, y2, 'k--', 'LineWidth',1.5);

    legend([h2,h3],'prognostizierte Wert','probabilistische Wert','Location','northeast')
    %legend([h2,h3],'prognostizierte Wert','probabilistische Wert','Location','northeast')
    ylim([0,16])
    hold off  

end
        %for i = 1:size(x,1)
         %   zeitpunkt = x(i);
         %  montecarlo= cell2mat(Prognose_mitError.MonteCarlo(i));
         %   h3 = boxplot(montecarlo,zeitpunkt,'PlotStyle','compact');
        %end
    

