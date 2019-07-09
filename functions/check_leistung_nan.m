function [GesamtLeistung] = check_leistung_nan(GesamtLeistung_nan)
%Input GesamtLeistung_nan ist eine Tabelle mit Spaltenamen
%Zeit, Leistng, CS und Rel. Durch diese Funktion werden der erste NaN-Wert
%in der Spalte Leisutng erkannt und alle Daten nach diesem Zeitpunkt werden
%ausgeschnitten.

nan_index_list = find(isnan(GesamtLeistung_nan.Leistung));

if isempty(nan_index_list) == 1
    
    GesamtLeistung = GesamtLeistung_nan;

else
    
    nan_index_first = nan_index_list(1);
    GesamtLeistung = GesamtLeistung_nan(1:nan_index_first -1 , :);

end

