function [outputArg1,outputArg2] = test(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%%
%
tau = 0.9;
z = 9;
a = 2;
b= 5.5;
Qstart=[0,0];
rho=@(eps) abs((eps>=0)*tau.*eps+(eps<0)*(1-tau).*eps);
f = @(x) sum(rho(z - a*x(1) -b*x(2)));
MIN = fminsearch(f,Qstart);

end

