function ClearSky= kernel_smoothing_regression(Leistung,Zeit, hx)
	%TODO 
	%Bandbreite an zeitliche Aufl�sung anpassen...
	%DoY schleife durch ersetzen
	%
	% In dieser Funktion wird die Kernel-Regression f�r die CS-Leistung
	% durchgef�hrt.

	% Achtung! Genauere Ergebnisse k�nnen erhalten werden, wenn eine
	% viertelst�ndliche Aufl�sung gew�hlt wird. Dann muss das Skript in
	% einigen Punkten angepasst werden

	% Datei, in der die Leistung hinterlegt ist, aus der CS-Leistung
	% gebildet wird
	% Wenn die CS-Regression nur f�r einen Teil der Leistung gebildet
	% werden soll (z.B. nur das erste Zeit), kann LeistungZeit an dieser
	% Stelle verk�rzt werden
	% x: Tag im Zeit, y: Stunde am Tag f�r die Werte in LeistungZeit
	%

	Leistung=reshape(Leistung,[],1);
	Zeit=reshape(Zeit,[],1);
	% DoY  sind die Tage im Zeitraum und 
	% ToD die Stunde am Tag f�r den gesamten Zeitraum
	numval=size(Leistung,1);
	DoY = 1+floor(days(Zeit-datetime(year(Zeit),1,1)));
	ToD = hour(Zeit)+minute(Zeit)/60;
	DoY=reshape(DoY,1,[]);
	ToD=reshape(ToD,1,[]);
	% Ung�ltige Werte werden aussortiert
	% DoY = DoY(~isnan(Leistung));
	% ToD = ToD(~isnan(Leistung));
	Leistung(isnan(Leistung))=0;
	% Zeit = Zeit(~isnan(Leistung));

	% Parameter k�nnen prinzipiell ver�ndert werden
	%hx = 35; % Bandbreite in x-Richtung
	hy = 0.2; % Bandbreite in y-Richtung
	tau = 0.85; % Faktor f�r Fehlerfunktion

	z_cs = zeros(1,numval);
	%% Berechnungsschleife
	%
	fprintf('Berechnung der Kernelregession: \n')
	for ival =  1:numval

		xi = DoY(ival);
		yi = ToD(ival);
		k = kernel(DoY,xi,hx,365,ToD,yi,hy,24);

		ksum = sum(k);
		k = k/ksum;
		z_cs(ival) = quantreg(k,Leistung,tau);
		if z_cs(ival) < 0.001
			z_cs(ival) = 0;
		end
		if (mod(ival,1000) == 0) || (ival==numval)
			fprintf( 'Fortschritt: %.1f%% \n',100*ival/numval );
		end
	end
	% x=DoY;
	% y=ToD;
	% z=Leistung;
	% h = figure;
	% scatter3(x,y,z,'.') %Erst Plotten mit m�gl. NaN-Werten
	% hold on
	% scatter3(DoY,ToD,z_cs) %Regression

	% M�glichkeit, die viertelst�ndlichen Werte aus Regression in
	% st�ndliche Ausgabe umzuwandeln
	% ClearSky_viertel = table(Zeit,z_cs','VariableNames',{'Zeit','Leistung'});
	%  ClearSky_viertel.Leistung(find(abs(ClearSky_viertel.Leistung) < 10e-10)) = 0;

	% Leistung = NaN(8760,1);
	% Zeit = repmat(datetime(2017,1,1,0,0,0),8760,1);
	% for istunde = 1:8760
	%     Leistung(istunde) = sum(ClearSky_viertel.Leistung((istunde-1)*4+1:(istunde-1)*4+4))/4;
	%     Zeit(istunde) = ClearSky_viertel.Zeit((istunde-1)*4+1);
	% end
	ClearSky = table(Zeit,z_cs','VariableNames',{'Zeit','Leistung'});
	% savepfad = fullfile(cs_inputpfad ,kerneldatei);
	% save(savepfad,'ClearSky')
end

function [w] = fstd(x,xi,h,tot)
	% Standardnormalverteilung in Abh�ngigkeit von der Distanz
	numx = size(x,2);
	distance = zeros(size(x));
	for ix = 1:numx
		distance(ix) = min([abs(xi-x(ix)) abs(xi+tot-x(ix)) abs(x(ix)+tot-xi)]);        
	end
	w = 1/(h*sqrt(2*pi()))*exp(-1/2*(distance/h).^2);
end

function [k] = kernel(x,xi,hx,totx,y,yi,hy,toty)
	% Kernel-Funktion. Normierung muss nachtr�glich durchgef�hrt werden
	k = fstd(x,xi,hx,totx).*fstd(y,yi,hy,toty);
end

function [Q]=quantreg(k,z,tau)
	% Quantile Regression. Fehlerfunktion wird mit fminsearch minimiert
	Qstart=3;
	rho=@(eps)abs((eps>=0)*tau.*eps+(eps<0)*(1-tau).*eps);
	Q=fminsearch(@(Q)sum(k'.*rho(z-Q)),Qstart);

end
