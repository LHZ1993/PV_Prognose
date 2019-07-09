function Q = linear_quantile_regression(tau,x,y)
%Input Y >>> Messwerte
%Input X >>> prognostizierte Werte
%Input tau >>> 0.05....0.95
%Output Q >>> Quantilfaktoe

    Qstart=1;
    
    rho=@(eps)abs((eps>=0)*tau.*eps+(eps<0)*(1-tau).*eps);
    
    Q=fminsearch(@(Q)sum(rho(y-Q.*x)),Qstart);

end

