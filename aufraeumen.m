%% Aufräum Sricpt
% !ACHTUNG! sollte in dem Ordner der Hauptdatei liegen
%Versucht Workingdirectory zu Ändern, damit gepseicherte Workspace's immer im selben Ordner landen

%Prüfen ob Datei im aktuellen Ordner Vorhaben ist und auslesen von Dateieigenschaften (Pfad..)
[status,values] = fileattrib(strcat(mfilename,'.m'));

MyFolderInfo =dir(values.Name);
cd (MyFolderInfo.folder);


% Fügt alle Ordner und Unterordner(von "MyFolderInfo.folder") dem Suchpfad von Matlab hinzu
addpath(genpath(MyFolderInfo.folder));

clear;
%
close all;

%delete *.mat
%tic %Start der Zeitrechnung --> mit "toc" die Rechenzeit
%profile on %-history % Zeigt unter anderem Verbrauchte Rechenzeit einzelner Prozesse an
