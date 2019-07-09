function varargout = PrognoseGUI(varargin)
%PROGNOSEGUI MATLAB code file for PrognoseGUI.fig
%      PROGNOSEGUI, by itself, creates a new PROGNOSEGUI or raises the existing
%      singleton*.
%
%      H = PROGNOSEGUI returns the handle to a new PROGNOSEGUI or the handle to
%      the existing singleton*.
%
%      PROGNOSEGUI('Property','Value',...) creates a new PROGNOSEGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to PrognoseGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      PROGNOSEGUI('CALLBACK') and PROGNOSEGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in PROGNOSEGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PrognoseGUI

% Last Modified by GUIDE v2.5 05-Jun-2019 21:25:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PrognoseGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PrognoseGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before PrognoseGUI is made visible.
function PrognoseGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for PrognoseGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PrognoseGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = PrognoseGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes during object creation, after setting all properties.
function Echtzeit_Info_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Echtzeit_Info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end

% --- Executes on button press in Starten_Echtzeit.
function Starten_Echtzeit_Callback(hObject, eventdata, handles)
% hObject    handle to Starten_Echtzeit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stopbit
stopbit = 0;

%Modelle einlesen
Konfiguration = evalin('base', 'Konfiguration');
Modell = Konfiguration.Modell;

while (stopbit == 0)
  
    %Print Infos
    Prognose_Minute = str2num(get(handles.Zeitpunkt_zur_Prognose, 'String'));
    Naechst_Zeit = print_echtzeit_info(Prognose_Minute);

    txt_1 = ['Aktueller Zeitpunkt: ', datestr(datetime('now'))];
    txt_2 = ['Zeitpunkt zur Prognose: ', datestr(Naechst_Zeit)];
    txt = {txt_1,txt_2};
    zeit_info = textwrap(handles.Echtzeit_Info,txt);

    set(handles.Echtzeit_Info,'String',zeit_info);

    %Cell für Prognoseergebnisse erstellen
    Erg = cell(1,5);

    %Beurteilen, ob der Zeitpunkt zur Prognose erreicht
    if (datetime('now').Minute == Prognose_Minute) && (fix(datetime('now').Second) == 0)

        %Echtzeitdaten von Datenbank einlesen
        LeistungZeit = read_data_db(Konfiguration.DatenbankPath, Konfiguration.DatenbankEinlesen, 'VaihingenLeistung');
        ClearSky = read_data_db(Konfiguration.DatenbankPath, Konfiguration.DatenbankEinlesen, 'CS_h35');
        WetterRow = read_data_db(Konfiguration.DatenbankPath, Konfiguration.DatenbankEinlesen, 'Wetter_Resample');
        %WetterRow.Windrichtung = [];

        %Modelle auswaehlen und Prognosen treffen
        for modell_num = 1: size(Konfiguration.ModellName,2)

            modell_name = Konfiguration.ModellName{1,modell_num};

            %1.ARXB mit Echtzeitdaten
            if strcmp(modell_name, 'ARX')

                [Erg_ARX] = arx_echtzeit(Modell{1,1}, Konfiguration, LeistungZeit, ClearSky, WetterRow);

                Erg{1,1} = {Erg_ARX};


            %2.ARXNN mit Echtzeit
            elseif strcmp(modell_name, 'ARXNN')

                [Erg_ARXNN] = arx_nn_echtzeit(Modell{1,2}, Konfiguration, LeistungZeit, ClearSky, WetterRow);

                Erg{1,2} = {Erg_ARXNN};

            %3.FF mit Echtzeit
            elseif strcmp(modell_name, 'FF')

                [Erg_FF] = fitnet_echtzeit(Modell{1,3}, Konfiguration, LeistungZeit, ClearSky, WetterRow);

                Erg{1,3} = {Erg_FF};

            %4.NARX mit Echtzeit
            elseif strcmp(modell_name, 'NARX')

                [Erg_NARX] = narxnet_echtzeit(Modell{1,4}, Konfiguration, LeistungZeit, ClearSky, WetterRow);

                Erg{1,4} = {Erg_NARX};

            %5.RF mit Echtzeit
            elseif strcmp(modell_name, 'RF')

                [Erg_RF] = rf_echtzeit(Modell{1,5}, Konfiguration, LeistungZeit, ClearSky, WetterRow);

                Erg{1,5} = {Erg_RF};  

            end
        end


        %Prognoseergebnisse in Datenbank speichern
        %TO DO
        Konfiguration.EchtzeitErg = Erg;

        %Prognoseergebnissse in GUI speichern und für Plot vorbereiten
        set(hObject,'UserData',Erg);
        
        continue
        
    end

    pause(1);
    global stopbit

end

%guidata(hObject,handles); 

end

function Zeitpunkt_zur_Prognose_Callback(hObject, eventdata, handles)
% hObject    handle to Zeitpunkt_zur_Prognose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zeitpunkt_zur_Prognose as text
%        str2double(get(hObject,'String')) returns contents of Zeitpunkt_zur_Prognose as a double


Prognose_Minute = get(hObject, 'String');

if strcmp(Prognose_Minute, 'Zeitpunkt')

    set(handles.Echtzeit_Info, 'String', 'Zeitpunkt(in Minute) zum Prognose einstellen');

end
end


% --- Executes during object creation, after setting all properties.
function Zeitpunkt_zur_Prognose_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zeitpunkt_zur_Prognose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in Beenden_Echtzeit.
function Beenden_Echtzeit_Callback(hObject, eventdata, handles)
% hObject    handle to Beenden_Echtzeit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close all
%global stopbit;
%stopbit = 0;
end

% --- Executes on selection change in Prognosetypen.
function Prognosetypen_Callback(hObject, eventdata, handles)
% hObject    handle to Prognosetypen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Prognosetypen contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Prognosetypen
end

% --- Executes during object creation, after setting all properties.
function Prognosetypen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Prognosetypen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in Modelltypen.
function Modelltypen_Callback(hObject, eventdata, handles)
% hObject    handle to Modelltypen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Modelltypen contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Modelltypen
end

% --- Executes during object creation, after setting all properties.
function Modelltypen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Modelltypen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function PlotBereich_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlotBereich (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate PlotBereich

set(hObject,'xTick',[]);
set(hObject,'yTick',[]);

set(hObject,'FontSize',12);
set(hObject, 'LineWidth',0.9)

%ylabel('PV Leistung[kW]','FontSize',12)

end


% --- Executes on button press in PlotErg.
function PlotErg_Callback(hObject, eventdata, handles)
% hObject    handle to PlotErg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pause(0.1);

Erg = get(handles.Starten_Echtzeit,'UserData');
Prognosetypen_num = get(handles.Prognosetypen, 'Value') -1;
Modelltypen_num = get(handles.Modelltypen, 'Value') -1;
PrognoseHorizont_num = get(handles.Prognosehorizont, 'Value') -1;

%Plot derterministische Ergebnisse
if ismember(Modelltypen_num, (1:1:5))&&(Prognosetypen_num == 1)
    
    %erg = Erg{1,Modelltypen_num}{1,1};
    erg = Erg{1,Modelltypen_num}{1,1};
    
    if PrognoseHorizont_num == 1
        
        erg = erg(1:96, :);
        
    elseif PrognoseHorizont_num == 2
        
        erg = erg(1:192, :);
        
    else 
        
        erg = erg(1:end, :);
    end
    
    zeit = erg.Zeit;
    prognose = erg.LeistungPro;

    %figure;
    h1 = plot(handles.PlotBereich, zeit, prognose,'LineWidth',0.9);
    
    grid on
    set(handles.PlotBereich,'FontSize',12);
    set(handles.PlotBereich, 'LineWidth',0.9)
    
    ylabel('PV Leistung[kW]','FontSize',12)
    ylim([0,15]);

    
%Plot probabilistische Ergebnisse 
elseif ismember(Modelltypen_num, [1,2,5])&&(Prognosetypen_num == 2)
...

end 
    
end


% --- Executes on button press in Pause.
function Pause_Callback(hObject, eventdata, handles)
% hObject    handle to Pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global stopbit
stopbit = 1;

end


% --- Executes on selection change in Prognosehorizont.
function Prognosehorizont_Callback(hObject, eventdata, handles)
% hObject    handle to Prognosehorizont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Prognosehorizont contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Prognosehorizont
end

% --- Executes during object creation, after setting all properties.
function Prognosehorizont_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Prognosehorizont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
