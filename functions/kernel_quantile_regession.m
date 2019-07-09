function Quantile = kernel_quantile_regession(K, RelPro ,tau, hx)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes her
	RelPro=reshape(RelPro,[],1);
	numval=size(RelPro,1);
	RelPro(isnan(RelPro))=0;
	z = zeros(1,numval);

	for ival =  1:numval

		xi = RelPro(ival);
        k = kernel(RelPro,xi,hx,287);

		ksum = sum(k);
		k = k/ksum;
		z(ival) = quantreg(k,RelPro,tau);
		if z(ival) < 0.001
			z(ival) = 0;
        end
	end

	Result = table(K,z','VariableNames',{'K_step','Quantile'});
    Quantile = Result.Quantile;

end

function [w] = fstd(x,xi,h,tot)
	% Standardnormalverteilung in Abhängigkeit von der Distanz
	numx = size(x,2);
	distance = zeros(size(x));
	for ix = 1:numx
		distance(ix) = min([abs(xi-x(ix)) abs(xi+tot-x(ix)) abs(x(ix)+tot-xi)]);        
	end
	w = 1/(h*sqrt(2*pi()))*exp(-1/2*(distance/h).^2);
end

function [k] = kernel(x,xi,hx,totx)
	% Kernel-Funktion. Normierung muss nachträglich durchgeführt werden
	k = fstd(x,xi,hx,totx) .^2 ;
end

function [Q]=quantreg(k,z,tau)
	% Quantile Regression. Fehlerfunktion wird mit fminsearch minimiert
	Qstart=1;
	rho=@(eps)abs((eps>=0)*tau.*eps+(eps<0)*(1-tau).*eps);
	Q=fminsearch(@(Q)sum(k.*rho(z-Q)),Qstart);

end

