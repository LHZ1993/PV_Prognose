from bs4 import BeautifulSoup
import urllib.request
from datetime import datetime,timedelta
import pandas as pd
import numpy as np
import sqlite3
import time
import requests
from Kostal import Piko

def read_wetter(url_1, url_2, url_3, url_4):

    now = datetime.now()
    Hour = now.hour
    TodaysHour = 24 - Hour - 1

    response_1 = urllib.request.urlopen(url_1)
    response_2 = urllib.request.urlopen(url_2)
    response_3 = urllib.request.urlopen(url_3)
    response_4 = urllib.request.urlopen(url_4)

    result_1 = response_1.read().decode('utf-8')
    result_2 = response_2.read().decode('utf-8')
    result_3 = response_3.read().decode('utf-8')
    result_4 = response_4.read().decode('utf-8')

    soup_1 = BeautifulSoup(result_1, 'html5lib')
    soup_2 = BeautifulSoup(result_2, 'html5lib')
    soup_3 = BeautifulSoup(result_3, 'html5lib')
    soup_4 = BeautifulSoup(result_4, 'html5lib')

    if TodaysHour != 0:

        #1.Temperatur
        Temperaturs_1 = soup_1.find_all('div', class_ = "[ half-left ][ bg--white ][ js-detail-value-container ]")
        Temperaturs_2 = soup_2.find_all('div', class_="[ half-left ][ bg--white ][ js-detail-value-container ]")
        Temperaturs_3 = soup_3.find_all('div', class_="[ half-left ][ bg--white ][ js-detail-value-container ]")
        Temperaturs_4 = soup_4.find_all('div', class_="[ half-left ][ bg--white ][ js-detail-value-container ]")


        Temperaturs_list = []

        #Heute Tenperatur
        for temperatur in Temperaturs_1[0:TodaysHour ]:

            Temperaturs_list.append(temperatur.span.text)

        #Morgen Temperatur
        for temperatur in Temperaturs_2[0:24]:

            Temperaturs_list.append(temperatur.span.text)

        #übermorgen Temperatur
        for temperatur in Temperaturs_3[0:24]:

            Temperaturs_list.append(temperatur.span.text)

        #3Tage Temperatur
        for temperatur in Temperaturs_4[0 :Hour + 1 ]:

            Temperaturs_list.append(temperatur.span.text)

        first_tempeatur = Temperaturs_list[0]
        Temperaturs_list.insert(0, first_tempeatur)

        #print('Temperatur')
        #print(Temperaturs_list)
        #print(len(Temperaturs_list))
        #print('------------------------')

        #2.Niederschlagsrisiko
        Niederschlagsrisiken_1 = soup_1.find_all('td', class_="text--small text--center tdbl tdbr")
        Niederschlagsrisiken_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr")
        Niederschlagsrisiken_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr")
        Niederschlagsrisiken_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr")

        Niederschlagsrisiken_list = []

        #Heute Niederschlagrisiken
        for niederschlagsrisiko in Niederschlagsrisiken_1[0:TodaysHour+1]:

            temp2 = niederschlagsrisiko.text.replace(' ', '').splitlines()
            newtemp2  =[x for x in temp2 if x != ''][0]
            Niederschlagsrisiken_list.append(newtemp2)

        #Morgen Niederschlagrisiken
        for niederschlagsrisiko in Niederschlagsrisiken_2[1:25]:

            temp2 = niederschlagsrisiko.text.replace(' ', '').splitlines()
            newtemp2  =[x for x in temp2 if x != ''][0]
            Niederschlagsrisiken_list.append(newtemp2)

        #Übermorgen Niederschlagrisiken
        for niederschlagsrisiko in Niederschlagsrisiken_3[1:25]:

            temp2 = niederschlagsrisiko.text.replace(' ', '').splitlines()
            newtemp2  =[x for x in temp2 if x != ''][0]
            Niederschlagsrisiken_list.append(newtemp2)

        #3Tage Niederschlagrisiken
        for niederschlagsrisiko in Niederschlagsrisiken_4[1:Hour +2]:

            temp2 = niederschlagsrisiko.text.replace(' ', '').splitlines()
            newtemp2  =[x for x in temp2 if x != ''][0]
            Niederschlagsrisiken_list.append(newtemp2)

        #print('Niederschlagrisiken')
        #print(Niederschlagsrisiken_list)
        #print(len(Niederschlagsrisiken_list))
        #print('------------------------')



        #3.Niederschlagsmenge & Feuchtigkeit
        Niederschlagsmengen_Feuchtigkeit_1 = soup_1.find_all('td', class_ = "text--small text--center tdbl tdbr h70")
        Niederschlagsmengen_Feuchtigkeit_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Niederschlagsmengen_Feuchtigkeit_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Niederschlagsmengen_Feuchtigkeit_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr h70")

        Beide_list_Heute = []
        Beide_list_Morgen = []
        Beide_list_Uebermorgen = []
        Beide_list_In3Tagen = []
        Feuchtigkeit_list = []

        #Heute Niederschlagmenge & Feuchtigkeit
        for niederschlagsmenge in Niederschlagsmengen_Feuchtigkeit_1:

            temp3 = niederschlagsmenge.text.replace(' ', '').splitlines()
            newtemp3 = [x for x in temp3 if x != ''][0]
            Beide_list_Heute.append(newtemp3)
            Heute_Niederschlagmenge = Beide_list_Heute[0: int( len( Beide_list_Heute ) / 2)][0 : TodaysHour +1]
            Heute_Feuchtigkeit = Beide_list_Heute[int(len( Beide_list_Heute ) / 2 ) : ][0 : TodaysHour +1]


        #Morgen Niederschlagmenge & Feuchtigkeit
        for niederschlagsmenge in Niederschlagsmengen_Feuchtigkeit_2:

            temp3 = niederschlagsmenge.text.replace(' ', '').splitlines()
            newtemp3 = [x for x in temp3 if x != ''][0]
            Beide_list_Morgen.append(newtemp3)
            Morgen_Niederschlagmenge = Beide_list_Morgen[0 : int(len( Beide_list_Morgen) /2) ][1:25]
            Morgen_Feuchtigkeit = Beide_list_Morgen[ int(len(Beide_list_Morgen) / 2) : ][1:25]

        #Übermorgen Niderschlagmenge & Feuchtigkeit
        for niederschlagsmenge in Niederschlagsmengen_Feuchtigkeit_3:

            temp3 = niederschlagsmenge.text.replace(' ', '').splitlines()
            newtemp3 = [x for x in temp3 if x != ''][0]
            Beide_list_Uebermorgen.append(newtemp3)
            Uebermorgen_Niederschlagmenge = Beide_list_Uebermorgen[0 : int(len( Beide_list_Uebermorgen) /2) ][1:25]
            Uebermorgen_Feuchtigkeit = Beide_list_Uebermorgen[ int(len(Beide_list_Uebermorgen) / 2) : ][1:25]

        #3Tage Niederschlagmenge & Feuchtigkeit
        for niederschlagsmenge in Niederschlagsmengen_Feuchtigkeit_4:

            temp3 = niederschlagsmenge.text.replace(' ', '').splitlines()
            newtemp3 = [x for x in temp3 if x != ''][0]
            Beide_list_In3Tagen.append(newtemp3)
            In3Tagen_Niederschlagmenge = Beide_list_In3Tagen[0 : int( len( Beide_list_In3Tagen ) / 2 )][1: Hour +2 ]
            In3Tagen_Feuchtigkeit = Beide_list_In3Tagen[int(len(Beide_list_In3Tagen) / 2) :  ][1: Hour + 2]

        Niederschlagsmengen_list = Heute_Niederschlagmenge + Morgen_Niederschlagmenge + Uebermorgen_Niederschlagmenge + In3Tagen_Niederschlagmenge

        Feuchtigkeit_list = Heute_Feuchtigkeit + Morgen_Feuchtigkeit + Uebermorgen_Feuchtigkeit + In3Tagen_Feuchtigkeit

        #print('Niederschlagmenge')
        #print(Niederschlagsmengen_list)
        #print(len(Niederschlagsmengen_list))
        #print('------------------------')

        #print('Feuchtigkeit')
        #print(Feuchtigkeit_list)
        #print(len(Feuchtigkeit_list))
        #print('------------------------')

        #4.Windrichtung

        Windrichtungen_1 = soup_1.find_all('td', class_="text--small text--center tdbl tdbr pb")
        Windrichtungen_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr pb")
        Windrichtungen_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr pb")
        Windrichtungen_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr pb")

        Windrichtungen_list = []

        #Heute Windrichtung
        for windrichtung in Windrichtungen_1[0:TodaysHour+1]:

            temp4 = windrichtung.text.replace(' ', '').splitlines()
            newtemp4 = [x for x in temp4 if x.isalpha()][0]
            Windrichtungen_list.append(newtemp4)

        #Morgen Windrichtung
        for windrichtung in Windrichtungen_2[1:25]:

            temp4 = windrichtung.text.replace(' ', '').splitlines()
            newtemp4 = [x for x in temp4 if x.isalpha()][0]
            Windrichtungen_list.append(newtemp4)

        #Übermorgen Windrichtung
        for windrichtung in Windrichtungen_3[1:25]:

            temp4 = windrichtung.text.replace(' ', '').splitlines()
            newtemp4 = [x for x in temp4 if x.isalpha()][0]
            Windrichtungen_list.append(newtemp4)

        #3Tage Windrichtung
        for windrichtung in Windrichtungen_4[1:Hour +2 ]:

            temp4 = windrichtung.text.replace(' ', '').splitlines()
            newtemp4 = [x for x in temp4 if x.isalpha()][0]
            Windrichtungen_list.append(newtemp4)


        #print('Windrichtung')
        #print(Windrichtungen_list)
        #print(len(Windrichtungen_list))
        #print('------------------------')

        #5.Windgeschwindigkeit
        Windgesschwindigkeiten_1 = soup_1.find_all('div', class_ = "[ half-left cell-center ][ js-detail-value-container ]")
        Windgesschwindigkeiten_2 = soup_2.find_all('div', class_ = "[ half-left cell-center ][ js-detail-value-container ]")
        Windgesschwindigkeiten_3 = soup_3.find_all('div', class_ = "[ half-left cell-center ][ js-detail-value-container ]")
        Windgesschwindigkeiten_4 = soup_4.find_all('div', class_ = "[ half-left cell-center ][ js-detail-value-container ]")

        Windgeschwindigkeiten_list = []

        #Heute Windgeschwindigkeit
        for windgeschwindigkeit in Windgesschwindigkeiten_1[0 : TodaysHour+1]:

            temp5 = windgeschwindigkeit.text.replace(' ', '').splitlines()
            newtemp5 = [x for x in temp5 if x != ''][0]
            Windgeschwindigkeiten_list.append(newtemp5)

        #Morgen Windgeschwindigkeit
        for windgeschwindigkeit in Windgesschwindigkeiten_2[1 : 25]:

            temp5 = windgeschwindigkeit.text.replace(' ', '').splitlines()
            newtemp5 = [x for x in temp5 if x != ''][0]
            Windgeschwindigkeiten_list.append(newtemp5)

        #Übermorgen Winggeschwindigkeit
        for windgeschwindigkeit in Windgesschwindigkeiten_3[1 : 25]:

            temp5 = windgeschwindigkeit.text.replace(' ', '').splitlines()
            newtemp5 = [x for x in temp5 if x != ''][0]
            Windgeschwindigkeiten_list.append(newtemp5)

        #3Tage Windgeschwindigkeit
        for windgeschwindigkeit in Windgesschwindigkeiten_4[1 : Hour + 2]:

            temp5 = windgeschwindigkeit.text.replace(' ', '').splitlines()
            newtemp5 = [x for x in temp5 if x != ''][0]
            Windgeschwindigkeiten_list.append(newtemp5)

        #print('Windgeschwindigkeiten')
        #print(Windgeschwindigkeiten_list)
        #print(len(Windgeschwindigkeiten_list))
        #print('------------------------')

        #6.Luftdruck
        Luftdruck_1 = soup_1.find_all('td', class_="text--tiny text--center tdbl tdbr")
        Luftdruck_2 = soup_2.find_all('td', class_="text--tiny text--center tdbl tdbr")
        Luftdruck_3 = soup_3.find_all('td', class_="text--tiny text--center tdbl tdbr")
        Luftdruck_4 = soup_4.find_all('td', class_="text--tiny text--center tdbl tdbr")

        Luftdruck_list = []

        #Heute Luftdruck
        for luftdruck in Luftdruck_1[0: TodaysHour+1]:
            temp6 = luftdruck.text.replace(' ', '').splitlines()
            newtemp6 = [x for x in temp6 if x!= ''][0]
            Luftdruck_list.append(newtemp6)

        #Morgen Luftdruck
        for luftdruck in Luftdruck_2[1: 25]:
            temp6 = luftdruck.text.replace(' ', '').splitlines()
            newtemp6 = [x for x in temp6 if x!= ''][0]
            Luftdruck_list.append(newtemp6)

        #Übermorgen Luftdruck
        for luftdruck in Luftdruck_3[1: 25]:
            temp6 = luftdruck.text.replace(' ', '').splitlines()
            newtemp6 = [x for x in temp6 if x!= ''][0]
            Luftdruck_list.append(newtemp6)

        #3Tage Luftdruck
        for luftdruck in Luftdruck_4[1: Hour + 2]:
            temp6 = luftdruck.text.replace(' ', '').splitlines()
            newtemp6 = [x for x in temp6 if x!= ''][0]
            Luftdruck_list.append(newtemp6)

        #print('Luftdruck')
        #print(Luftdruck_list)
        #print(len(Luftdruck_list))
        #print('------------------------')

        ''''#7.Feuchtigkeit
        Feuchtigkeit_1 = soup_1.find_all('td',class_="text--small text--center tdbl tdbr h70")
        Feuchtigkeit_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Feuchtigkeit_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Feuchtigkeit_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr h70")

        Feuchtigkeit_list = []
        F_list_Heute = []
        F_list_Morgen = []
        F_list_Uebermorgen = []
        F_list_In3Tagen = []

        #Heute Feuchtigkeit
        for feuchtugkeit in Feuchtigkeit_1:

            temp7 = feuchtugkeit.text.replace(' ', '').splitlines()
            newtemp7 = [x for x in temp7 if x!= ''][0]
            F_list_Heute.append(newtemp7)

        F_list_Heute = [x for x in F_list_Heute if float(x) > 1][0:TodaysHour+1]

        #Morgen Feuchtigkeit
        for feuchtugkeit in Feuchtigkeit_2:

            temp7 = feuchtugkeit.text.replace(' ', '').splitlines()
            newtemp7 = [x for x in temp7 if x!= ''][0]
            F_list_Morgen.append(newtemp7)

        F_list_Morgen = [x for x in F_list_Morgen if float(x) > 1][1:25]


        #Übermorgen Feuchtigkeit
        for feuchtugkeit in Feuchtigkeit_3:
            temp7 = feuchtugkeit.text.replace(' ', '').splitlines()
            newtemp7 = [x for x in temp7 if x!= ''][0]
            F_list_Uebermorgen.append(newtemp7)

        F_list_Uebermorgen = [x for x in F_list_Uebermorgen if float(x) > 1][1:25]


        #3Tage Feuchtigkeit
        for feuchtugkeit in Feuchtigkeit_4:
            temp7 = feuchtugkeit.text.replace(' ', '').splitlines()
            newtemp7 = [x for x in temp7 if x!= ''][0]
            F_list_In3Tagen.append(newtemp7)

        F_list_In3Tagen = [x for x in F_list_In3Tagen if float(x) > 1][1 : Hour +2]


        Feuchtigkeit_list = F_list_Heute + F_list_Morgen + F_list_Uebermorgen + F_list_In3Tagen


        #print('Feuchtigkeit')
        #print(Feuchtigkeit_list)
        #print(len(Feuchtigkeit_list))
        #print('------------------------')'''

        #8.Bewülkerung

        Bewoelkerung_1 = soup_1.find_all('td',class_="text--small text--center tdbl tdbr h36")
        Bewoelkerung_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr h36")
        Bewoelkerung_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr h36")
        Bewoelkerung_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr h36")

        Bewoelkerung_list = []

        #Heute Bewölkerung
        for bewoelkerung in Bewoelkerung_1[0: TodaysHour+1]:
            temp8 = bewoelkerung.text.replace(' ', '').splitlines()
            newtemp8 = [x for x in temp8 if x != ''][0]
            Bewoelkerung_list.append(newtemp8)

        #Morgen Bewölkerung
        for bewoelkerung in Bewoelkerung_2[1: 25]:
            temp8 = bewoelkerung.text.replace(' ', '').splitlines()
            newtemp8 = [x for x in temp8 if x != ''][0]
            Bewoelkerung_list.append(newtemp8)

        #Übermorgen Bewölkerung
        for bewoelkerung in Bewoelkerung_3[1: 25]:
            temp8 = bewoelkerung.text.replace(' ', '').splitlines()
            newtemp8 = [x for x in temp8 if x != ''][0]
            Bewoelkerung_list.append(newtemp8)

        #3Tage Bewölkerung
        for bewoelkerung in Bewoelkerung_4[1: Hour +2 ]:
            temp8 = bewoelkerung.text.replace(' ', '').splitlines()
            newtemp8 = [x for x in temp8 if x != ''][0]
            Bewoelkerung_list.append(newtemp8)


        #print('Bewoelkerung')
        #print(Bewoelkerung_list)
        #print(len(Bewoelkerung_list))
        #print('------------------------')

        wetter = [Temperaturs_list, Niederschlagsrisiken_list, Niederschlagsmengen_list, Windrichtungen_list, Windgeschwindigkeiten_list, Luftdruck_list, Feuchtigkeit_list, Bewoelkerung_list]

        for jede_list in wetter:

            lange = len(jede_list)

            if lange == 73:
                continue

            elif lange < 73:
                last_wert = jede_list[-1]
                append_anzahl = 73 - lange

                for i in range(append_anzahl):
                    jede_list.append(last_wert)



        return wetter

    elif TodaysHour == 0:

        # 1.Temperatur
        Temperaturs_1 = soup_1.find_all('div', class_="[ half-left ][ bg--white ][ js-detail-value-container ]")
        Temperaturs_2 = soup_2.find_all('div', class_="[ half-left ][ bg--white ][ js-detail-value-container ]")
        Temperaturs_3 = soup_3.find_all('div', class_="[ half-left ][ bg--white ][ js-detail-value-container ]")
        Temperaturs_4 = soup_4.find_all('div', class_="[ half-left ][ bg--white ][ js-detail-value-container ]")

        Temperaturs_list = []

        # Morgen Temperatur
        for temperatur in Temperaturs_2[0:24]:
            Temperaturs_list.append(temperatur.span.text)

        # übermorgen Temperatur
        for temperatur in Temperaturs_3[0:24]:
            Temperaturs_list.append(temperatur.span.text)

        # 3Tage Temperatur
        for temperatur in Temperaturs_4[0:24]:
            Temperaturs_list.append(temperatur.span.text)

        #print('Temperatur')
        #print(Temperaturs_list)
        #print(len(Temperaturs_list))
        #print('------------------------')

        # 2.Niederschlagsrisiko
        Niederschlagsrisiken_1 = soup_1.find_all('td', class_="text--small text--center tdbl tdbr")
        Niederschlagsrisiken_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr")
        Niederschlagsrisiken_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr")
        Niederschlagsrisiken_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr")

        Niederschlagsrisiken_list = []

        # Morgen Niederschlagrisiken
        for niederschlagsrisiko in Niederschlagsrisiken_2[0:24]:
            temp2 = niederschlagsrisiko.text.replace(' ', '').splitlines()
            newtemp2 = [x for x in temp2 if x != ''][0]
            Niederschlagsrisiken_list.append(newtemp2)

        # Übermorgen Niederschlagrisiken
        for niederschlagsrisiko in Niederschlagsrisiken_3[0:24]:
            temp2 = niederschlagsrisiko.text.replace(' ', '').splitlines()
            newtemp2 = [x for x in temp2 if x != ''][0]
            Niederschlagsrisiken_list.append(newtemp2)

        # 3Tage Niederschlagrisiken
        for niederschlagsrisiko in Niederschlagsrisiken_4[0:24]:
            temp2 = niederschlagsrisiko.text.replace(' ', '').splitlines()
            newtemp2 = [x for x in temp2 if x != ''][0]
            Niederschlagsrisiken_list.append(newtemp2)

        #print('Niederschlagrisiken')
        #print(Niederschlagsrisiken_list)
        #print(len(Niederschlagsrisiken_list))
        #print('------------------------')

        # 3.Niederschlagsmenge & Feuchtigkeit
        Niederschlagsmengen_1 = soup_1.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Niederschlagsmengen_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Niederschlagsmengen_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Niederschlagsmengen_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr h70")

        Niederschlagsmengen_list = []
        Beide_list_Heute = []
        Beide_list_Morgen = []
        Beide_list_Uebermorgen = []
        Beide_list_In3Tagen = []
        Feuchtigkeit_list = []

        # Morgen Niederschlagmenge
        for niederschlagsmenge in Niederschlagsmengen_2:
            temp3 = niederschlagsmenge.text.replace(' ', '').splitlines()
            newtemp3 = [x for x in temp3 if x != ''][0]
            Beide_list_Heute.append(newtemp3)

            Morgen_Niederschlagmenge = Beide_list_Morgen[0 : int(len(Beide_list_Morgen) / 2)][0:24]
            Morgen_Feuchtigkeit = Beide_list_Morgen[ int( len(Beide_list_Morgen) / 2 ) : ][0:24]

        # Übermorgen Niderschlagmenge
        for niederschlagsmenge in Niederschlagsmengen_3:
            temp3 = niederschlagsmenge.text.replace(' ', '').splitlines()
            newtemp3 = [x for x in temp3 if x != ''][0]
            Beide_list_Uebermorgen.append(newtemp3)

            Uebermorgen_Niederschlagmenge = Beide_list_Uebermorgen[ 0 : int(len(Beide_list_Uebermorgen) /2)][0:24]
            Uebermorgen_Feuchtigkeit = Beide_list_Uebermorgen[int(len(Beide_list_Uebermorgen) /2) : ][0:24]

        # 3Tage Niederschlagmenge
        for niederschlagsmenge in Niederschlagsmengen_4:
            temp3 = niederschlagsmenge.text.replace(' ', '').splitlines()
            newtemp3 = [x for x in temp3 if x != ''][0]
            Beide_list_In3Tagen.append(newtemp3)

            In3Tagen_Niederschlagmenge = Beide_list_In3Tagen[0 : int(len(Beide_list_In3Tagen) /2)][0:24]
            In3Tagen_Feuchtigkeit = Beide_list_In3Tagen[int( len(Beide_list_In3Tagen)) : ][0:24]


        Niederschlagsmengen_list = Morgen_Niederschlagmenge + Uebermorgen_Niederschlagmenge + In3Tagen_Niederschlagmenge
        #print('Niederschlagmenge')
        #print(Niederschlagsmengen_list)
        #print(len(Niederschlagsmengen_list))
        #print('------------------------')

        Feuchtigkeit_list = Morgen_Feuchtigkeit + Uebermorgen_Feuchtigkeit + In3Tagen_Feuchtigkeit
        #print('Feuchtigkeit')
        #print(Feuchtigkeit_list)
        #print(len(Feuchtigkeit_list))
        #print('------------------------')


        # 4.Windrichtung

        Windrichtungen_1 = soup_1.find_all('td', class_="text--small text--center tdbl tdbr pb")
        Windrichtungen_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr pb")
        Windrichtungen_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr pb")
        Windrichtungen_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr pb")

        Windrichtungen_list = []

        # Morgen Windrichtung
        for windrichtung in Windrichtungen_2[0:24]:
            temp4 = windrichtung.text.replace(' ', '').splitlines()
            newtemp4 = [x for x in temp4 if x.isalpha()][0]
            Windrichtungen_list.append(newtemp4)

        # Übermorgen Windrichtung
        for windrichtung in Windrichtungen_3[0:24]:
            temp4 = windrichtung.text.replace(' ', '').splitlines()
            newtemp4 = [x for x in temp4 if x.isalpha()][0]
            Windrichtungen_list.append(newtemp4)

        # 3Tage Windrichtung
        for windrichtung in Windrichtungen_4[0:24]:
            temp4 = windrichtung.text.replace(' ', '').splitlines()
            newtemp4 = [x for x in temp4 if x.isalpha()][0]
            Windrichtungen_list.append(newtemp4)

        #print('Windrichtung')
        #print(Windrichtungen_list)
        #print(len(Windrichtungen_list))
        #print('------------------------')

        # 5.Windgeschwindigkeit
        Windgesschwindigkeiten_1 = soup_1.find_all('div', class_="[ half-left cell-center ][ js-detail-value-container ]")
        Windgesschwindigkeiten_2 = soup_2.find_all('div', class_="[ half-left cell-center ][ js-detail-value-container ]")
        Windgesschwindigkeiten_3 = soup_3.find_all('div', class_="[ half-left cell-center ][ js-detail-value-container ]")
        Windgesschwindigkeiten_4 = soup_4.find_all('div', class_="[ half-left cell-center ][ js-detail-value-container ]")

        Windgeschwindigkeiten_list = []


        # Morgen Windgeschwindigkeit
        for windgeschwindigkeit in Windgesschwindigkeiten_2[0: 24]:
            temp5 = windgeschwindigkeit.text.replace(' ', '').splitlines()
            newtemp5 = [x for x in temp5 if x != ''][0]
            Windgeschwindigkeiten_list.append(newtemp5)

        # Übermorgen Winggeschwindigkeit
        for windgeschwindigkeit in Windgesschwindigkeiten_3[0: 24]:
            temp5 = windgeschwindigkeit.text.replace(' ', '').splitlines()
            newtemp5 = [x for x in temp5 if x != ''][0]
            Windgeschwindigkeiten_list.append(newtemp5)

        # 3Tage Windgeschwindigkeit
        for windgeschwindigkeit in Windgesschwindigkeiten_4[0: 24]:
            temp5 = windgeschwindigkeit.text.replace(' ', '').splitlines()
            newtemp5 = [x for x in temp5 if x != ''][0]
            Windgeschwindigkeiten_list.append(newtemp5)

        #print('Windgeschwindigkeiten')
        #print(Windgeschwindigkeiten_list)
        #print(len(Windgeschwindigkeiten_list))
        #print('------------------------')

        # 6.Luftdruck
        Luftdruck_1 = soup_1.find_all('td', class_="text--tiny text--center tdbl tdbr")
        Luftdruck_2 = soup_2.find_all('td', class_="text--tiny text--center tdbl tdbr")
        Luftdruck_3 = soup_3.find_all('td', class_="text--tiny text--center tdbl tdbr")
        Luftdruck_4 = soup_4.find_all('td', class_="text--tiny text--center tdbl tdbr")

        Luftdruck_list = []

        # Morgen Luftdruck
        for luftdruck in Luftdruck_2[0: 24]:
            temp6 = luftdruck.text.replace(' ', '').splitlines()
            newtemp6 = [x for x in temp6 if x != ''][0]
            Luftdruck_list.append(newtemp6)

        # Übermorgen Luftdruck
        for luftdruck in Luftdruck_3[0: 24]:
            temp6 = luftdruck.text.replace(' ', '').splitlines()
            newtemp6 = [x for x in temp6 if x != ''][0]
            Luftdruck_list.append(newtemp6)

        # 3Tage Luftdruck
        for luftdruck in Luftdruck_4[0: 24]:
            temp6 = luftdruck.text.replace(' ', '').splitlines()
            newtemp6 = [x for x in temp6 if x != ''][0]
            Luftdruck_list.append(newtemp6)

        #print('Luftdruck')
        #print(Luftdruck_list)
        #print(len(Luftdruck_list))
        #print('------------------------')

        '''# 7.Feuchtigkeit
        Feuchtigkeit_1 = soup_1.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Feuchtigkeit_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Feuchtigkeit_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr h70")
        Feuchtigkeit_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr h70")

        Feuchtigkeit_list = []
        F_list_Heute = []
        F_list_Morgen = []
        F_list_Uebermogen = []
        F_list_In3Tagen = []

        # Morgen Feuchtigkeit
        for feuchtugkeit in Feuchtigkeit_2:
            temp7 = feuchtugkeit.text.replace(' ', '').splitlines()
            newtemp7 = [x for x in temp7 if x != ''][0]
            F_list_Morgen.append(newtemp7)

        F_list_Morgen = [x for x in F_list_Morgen if float(x) > 1][0:24]

        # Übermorgen Feuchtigkeit
        for feuchtugkeit in Feuchtigkeit_3:
            temp7 = feuchtugkeit.text.replace(' ', '').splitlines()
            newtemp7 = [x for x in temp7 if x != ''][0]
            F_list_Uebermogen.append(newtemp7)

        F_list_Uebermogen = [x for x in F_list_Uebermogen if float(x) > 1 ][0:24]

        # 3Tage Feuchtigkeit
        for feuchtugkeit in Feuchtigkeit_4:
            temp7 = feuchtugkeit.text.replace(' ', '').splitlines()
            newtemp7 = [x for x in temp7 if x != ''][0]
            F_list_In3Tagen.append(newtemp7)

        F_list_In3Tagen = [x for x in F_list_In3Tagen if float(x) > 1 ][0:24]

        Feuchtigkeit_list = F_list_Morgen + F_list_Uebermogen + F_list_In3Tagen

        print('Feuchtigkeit')
        print(Feuchtigkeit_list)
        print(len(Feuchtigkeit_list))
        print('------------------------')'''



        # 8.Bewülkerung

        Bewoelkerung_1 = soup_1.find_all('td', class_="text--small text--center tdbl tdbr h36")
        Bewoelkerung_2 = soup_2.find_all('td', class_="text--small text--center tdbl tdbr h36")
        Bewoelkerung_3 = soup_3.find_all('td', class_="text--small text--center tdbl tdbr h36")
        Bewoelkerung_4 = soup_4.find_all('td', class_="text--small text--center tdbl tdbr h36")

        Bewoelkerung_list = []

        # Morgen Bewölkerung
        for bewoelkerung in Bewoelkerung_2[0: 24]:
            temp8 = bewoelkerung.text.replace(' ', '').splitlines()
            newtemp8 = [x for x in temp8 if x != ''][0]
            Bewoelkerung_list.append(newtemp8)

        # Übermorgen Bewölkerung
        for bewoelkerung in Bewoelkerung_3[0: 24]:
            temp8 = bewoelkerung.text.replace(' ', '').splitlines()
            newtemp8 = [x for x in temp8 if x != ''][0]
            Bewoelkerung_list.append(newtemp8)

        # 3Tage Bewölkerung
        for bewoelkerung in Bewoelkerung_4[0: 24]:
            temp8 = bewoelkerung.text.replace(' ', '').splitlines()
            newtemp8 = [x for x in temp8 if x != ''][0]
            Bewoelkerung_list.append(newtemp8)

        #print('Bewoelkerung')
        #print(Bewoelkerung_list)
        #print(len(Bewoelkerung_list))
        #print('------------------------')

        wetter = [Temperaturs_list, Niederschlagsrisiken_list, Niederschlagsmengen_list, Windrichtungen_list,
                  Windgeschwindigkeiten_list, Luftdruck_list, Feuchtigkeit_list, Bewoelkerung_list]

        return wetter

def get_zeit():

    now = datetime.now()
    year = now.year
    month = now.month
    day = now.day
    hour = now.hour

    firstdate = datetime(year= year, month= month, day= day, hour= hour, minute=0, second=0)
    duration = timedelta(hours=1)
    zeit_list = []

    for zeitnum in range(73):
        zeit_list.append(firstdate)
        firstdate = firstdate + duration

    return  zeit_list

def change_to_float(x):

    if (x !=0):
        a = int(x.split('/')[0])

        if a == 0:
            return 0
        else :
            b = int(x.split('/')[1])

            result = a/b
            return result

    elif x == 0:

        return 0
    else:
        print('unknown condition')

def veknuepfen_wetter_zeit(heute, morgen, uebermorgen, in3Tagen):

    zeit = get_zeit()
    wetterrow = read_wetter(heute, morgen, uebermorgen, in3Tagen)

    for jede in wetterrow:
        if len(jede) < len(zeit):
            diff = len(zeit) - len(jede)
            last = jede[-1]
            for rest in range(diff):
                jede.append(last)

    Zeit = pd.Series(data=zeit,name='Zeit')
    #WetterName = ['Temperatur', 'Niederschlagrisiko', 'Niederschlagmenge', 'Windrichtung', 'Windgeschwindigkeit', 'Luftdruck', 'Feuchtigkeit','Bewoelkerung']

    d = {'Zeit': Zeit, 'Temperatur':wetterrow[0], 'Niederschlagrisiko': wetterrow[1], 'Niederschlagmenge': wetterrow[2], 'Windrichtung': wetterrow[3], 'Windgeschwindigkeit': wetterrow[4], 'Luftdruck':wetterrow[5], 'Feuchtigkeit':wetterrow[6], 'Bewoelkerung': wetterrow[7]}
    Wetter = pd.DataFrame(data=d)

    col_names = list(Wetter.columns.values)

    for col in col_names[1:]:

        if col == 'Windrichtung':
            continue

        elif col == 'Bewoelkerung':

            Wetter[col] = Wetter[col].apply(change_to_float)
            Wetter[col] = pd.to_numeric(Wetter[col])

        else:
            Wetter[col] = pd.to_numeric(Wetter[col])


    return Wetter

def save_as_txt(data, path):
    name = 'Vaihingen' + '-' + str(datetime.now().year) + '-' + str(datetime.now().month) + '-' + str(
        datetime.now().day) + '-' + str(datetime.now().hour)
    data.to_csv(path + '\\' + name + '.txt', index = False )

def write_log_info(time,path, info):

    log = pd.read_csv(path + '\log.txt')

    error = {'Zeit': time, 'Info':info}

    log = log.append(error, ignore_index= True)

    log.to_csv(path + '\log.txt',index= False)

def resample_to_15min_wetter(data):

    datanum = len(data) -1
    first = data['Zeit'][0]
    last = data['Zeit'][datanum]

    min_num = (last - first).days *24 *60 / 15 + (last - first).seconds / 60 / 15 -1
    #print(min_num)

    now = datetime.now()

    if 0 <= now.minute < 15:
        first = first + timedelta(minutes=15)

    elif 15 <= now.minute < 30:
        first = first + timedelta(minutes=30)

    elif 30 <= now.minute < 45:
        first = first + timedelta(minutes=45)

    elif 45 <= now.minute < 60:
        first = first + timedelta(minutes=60)


    #print('Naechste Prognose : ' , first)

    neu_zeit_list = []
    for zeit in range(int(min_num)):
        neu_zeit_list.append(first)
        first = first + timedelta(minutes= 15)



    neudata = pd.DataFrame()
    neudata['Zeit'] = pd.Series(data= neu_zeit_list)


    col_names = list(data.columns.values)
    for col in col_names[1:]:
        neudata[col] = np.nan


    neudata.loc[0, 'Temperatur':'Bewoelkerung'] = data.loc[0, 'Temperatur':'Bewoelkerung']



    for olddata_index in range(1, len(data['Zeit'])-1):

        neudata_index = neudata[neudata['Zeit'] == data['Zeit'][olddata_index]].index.tolist()[0]
        neudata.loc[neudata_index, 'Temperatur':'Bewoelkerung'] = data.loc[olddata_index, 'Temperatur':'Bewoelkerung']


    #zero_index = (neudata == 0)
    #neudata[zero_index] = np.NAN
    neudata.drop(columns= ['Windrichtung'], inplace= True)
    neudata_col_list = list(neudata.columns.values)

    for col in neudata_col_list:
        #if col == 'Windrichtung':

            #neudata[col] = neudata[col].fillna(method='pad')

        if (col == 'Niederschlagrisiko') or (col == 'Niederschlagmenge'):

            neudata[col] = neudata[col].fillna(method='ffill')

        else :
            neudata[col] = neudata[col].interpolate(methode = 'linear')

    #nan_index = pd.isna(neudata)

    neudata = neudata.fillna(0)

    print(neudata.head(5))

    return neudata

def save_wetter_into_database(database_name, wetter_table, aktuell_prognose):

    connect = sqlite3.connect(database_name)

    conn = connect.cursor()

    database = pd.read_sql('SELECT * FROM Wetter ORDER BY Zeit ASC', connect)

    aktuell_prognose_zeit = aktuell_prognose['Zeit'][0]

    database['Zeit'] = pd.to_datetime(database['Zeit'])

    database_index = database[database['Zeit'] == aktuell_prognose_zeit].index.tolist()

    #print(database_index)

    if database_index != []:

        print('start to update hour weather data ')
        print('-----------------------------------')
        time.sleep(1)

        database.drop(index=range(database_index[0], len(database['Zeit'])), inplace=True)

        database = database.append(aktuell_prognose, sort=False)

        database.to_sql(wetter_table, connect, if_exists='replace', index=False)

        print('Databse Infos: ')
        print(database.info())

    elif database_index == []:

        print('Es fehlt noch Wetterdaten zwischen in der Datenbank gespeicherten Daten und aktuelle Prognose >>> Zeitreihe wird nicht staendig ')

        aktuell_prognose.to_sql(wetter_table, connect, if_exists='append', index=False)


    connect.commit()
    connect.close()

def first_wetter_insert_databse(databse_name, table_name, data):

    time.sleep(1)

    print('start to save hour weather data to table Wetter')

    connect = sqlite3.connect(databse_name)

    conn = connect.cursor()

    conn.execute('''DROP TABLE IF EXISTS Wetter''')

    data.to_sql(table_name, connect, if_exists='replace', index= False)

    print('writting data to Wetter')

    time.sleep(1)

    test= pd.read_sql('SELECT * FROM Wetter LIMIT 3 OFFSET 2', connect)
    print('first insert data to table successful, showing the first 3 rows')
    print('--'*20)
    print(test)
    connect.commit()
    connect.close()

def first_resample_wetter_insert_database(databse_name, table_name, data):

    time.sleep(1)

    print('start to save 15min weather data to table Wetter_Resample')

    connect = sqlite3.connect(databse_name)

    conn = connect.cursor()

    conn.execute('''DROP TABLE IF EXISTS Wetter_Resample''')

    data.to_sql(table_name, connect, if_exists='replace', index= False)

    print('writting data to Wetter_Resample')

    time.sleep(1)

    test= pd.read_sql('SELECT * FROM Wetter_Resample LIMIT 3 OFFSET 2', connect)
    print('first insert data to table successful, showing the first 3 rows')
    print('--'*20)
    print(test)
    connect.commit()
    connect.close()

def save_resample_wetter_into_database(database_name, wetter_table, aktuell_prognose):

    connect = sqlite3.connect(database_name)

    conn = connect.cursor()

    database = pd.read_sql('SELECT * FROM Wetter_Resample ORDER BY Zeit ASC', connect)

    aktuell_prognose_zeit = aktuell_prognose['Zeit'][0]

    database['Zeit'] = pd.to_datetime(database['Zeit'])

    database_index = database[database['Zeit'] == aktuell_prognose_zeit].index.tolist()


    if database_index != []:

        print('start to update 15min weather data ')
        print('------------------------------------')
        time.sleep(1)

        database.drop(index=range(database_index[0], len(database['Zeit'])), inplace=True)

        database = database.append(aktuell_prognose, sort=False)

        database.to_sql(wetter_table, connect, if_exists='replace', index=False)

        print('Database Infos: ')

        print(database.info())

    elif database_index == []:

        print('Es fehlt noch Wetterdaten zwischen in der Datenbank gespeicherten Daten und aktuelle Prognose >>> Zeitreihe wird nicht staendig ')

        aktuell_prognose.to_sql(wetter_table, connect, if_exists= 'append', index= False)

    connect.commit()
    connect.close()

def save_aktuell_wetter_into_database(database_name, wetter_table, aktuell_prognose):


    print('start to save current hour weather data to database')


    connect = sqlite3.connect(database_name)

    conn = connect.cursor()

    conn.execute('''DROP TABLE IF EXISTS Wetter_Aktuell''')

    aktuell_prognose.to_sql(wetter_table, connect, if_exists='replace', index= False)

    test= pd.read_sql('SELECT * FROM Wetter_Aktuell LIMIT 3 OFFSET 2', connect)
    print('insert data to Wetter_Aktuell successful, showing the first 3 rows')
    print('--'*20)
    print(test)
    connect.commit()
    connect.close()

def save_aktuell_resample_wetter_into_database(database_name, wetter_table, aktuell_prognose):


    print('start save current 15min weather data to database')


    connect = sqlite3.connect(database_name)

    conn = connect.cursor()

    conn.execute('''DROP TABLE IF EXISTS Wetter_Resample_Aktuell''')

    aktuell_prognose.to_sql(wetter_table, connect, if_exists='replace', index= False)

    test= pd.read_sql('SELECT * FROM Wetter_Resample_Aktuell LIMIT 3 OFFSET 2', connect)
    print('insert data to Wetter_Resample_Aktuell successful, showing the first 3 rows')
    print('--'*20)
    print(test)
    connect.commit()
    connect.close()

def save_all_wetter_into_database(database_name, table_name, wetter, wetter_resample):

    #print('start to donwnload weather data')

    #save 3tage wetterdaten into table Wetter
    connect = sqlite3.connect(database_name)

    conn = connect.cursor()

    table_1 = pd.read_sql('SELECT * FROM Wetter ORDER BY Zeit ASC', connect)

    aktuell_prognose_zeit_1 = wetter['Zeit'][0]

    table_1['Zeit'] = pd.to_datetime(table_1['Zeit'])

    table_index_1 = table_1[table_1['Zeit'] == aktuell_prognose_zeit_1].index.tolist()

    #print(database_index)
    if table_index_1 != []:

        print('start to update hour weather data ')
        #print('-----------------------------------')
        #time.sleep(1)

        table_1.drop(index=range(table_index_1[0], len(table_1['Zeit'])), inplace=True)

        table_1 = table_1.append(wetter, sort=False)

        table_1.to_sql(table_name[0], connect, if_exists='replace', index=False)

        #print('Databse Infos: ')
        #print(table_1.info())


    elif table_index_1 == []:

        print('Es fehlt noch Wetterdaten zwischen in der Datenbank gespeicherten Daten und aktuelle Prognose >>> '
              'Zeitreihe wird nicht staendig ')

        table_1.to_sql(table_name[0], connect, if_exists='append', index=False)


    #save 3tage wetterdaten_resample into table Wetter_Resample
    table_2 = pd.read_sql('SELECT * FROM Wetter_Resample ORDER BY Zeit ASC', connect)

    aktuell_prognose_zeit_2 = wetter_resample['Zeit'][0]

    table_2['Zeit'] = pd.to_datetime(table_2['Zeit'])

    table_index_2 = table_2[table_2['Zeit'] == aktuell_prognose_zeit_2].index.tolist()


    if table_index_2 != []:

        print('start to update 15min weather data ')
        #print('------------------------------------')
        #time.sleep(1)

        table_2.drop(index=range(table_index_2[0], len(table_2['Zeit'])), inplace=True)

        table_2 = table_2.append(wetter_resample, sort=False)

        table_2.to_sql(table_name[1], connect, if_exists='replace', index=False)

        #print('Database Infos: ')

        #print(table_2.info())

    elif table_index_2 == []:

        print('Es fehlt noch Wetterdaten zwischen in der Datenbank gespeicherten Daten und aktuelle Prognose >>>'
              ' Zeitreihe wird nicht staendig ')

        wetter_resample.to_sql(table_name[1], connect, if_exists= 'append', index= False)

    #save 3tage wetterdaten into table Wetter_Aktuell
    conn.execute('''DROP TABLE IF EXISTS Wetter_Aktuell''')

    wetter.to_sql(table_name[2], connect, if_exists='replace', index= False)

    #save 3tage wetterdaten-resample into table Wetter_Resample_Aktuell
    conn.execute('''DROP TABLE IF EXISTS Wetter_Resample_Aktuell''')

    wetter_resample.to_sql(table_name[3], connect, if_exists='replace', index= False)

    connect.commit()
    connect.close()
    #time.sleep(1)

def get_pv_power_piko_83(ip_83):

    p = Piko(ip_83, 'pvserver', 'PsdOped34')

    power_83 = p.get_current_power()/1000

    return power_83

def get_pv_power_piko_85(ip_85):

    url = ip_85 + '/api/dxs.json?dxsEntries='

    parameter = {'DCLeistung': '33556736', 'ACLeistung': '67109120', 'PVGeneration': '251658753'}

    page = requests.get(url + parameter['ACLeistung'])

    response = page.json()

    result = response["dxsEntries"][0]["value"]

    power_85 = round(result/1000, 3)

    return power_85

def save_all_leistung_into_database(database_name,table_name, leistung, leistung_resample):

    print('start to update pv power data')

    leistung_min = pd.DataFrame(data={'Zeit': leistung[0], 'Leistung1': leistung[1], 'Leistung2': leistung[2], 'Leistung': leistung[3]})

    #print(leistung_min)

    #leistung_min['Zeit'] = pd.to_datetime(leistung_min['Zeit'])

    #save leistung into table VaihingenLeistung_Minute
    connect = sqlite3.connect(database_name)

    conn = connect.cursor()

    conn.execute('''DROP TABLE IF EXISTS VaihingenLeistung_Minuten''')

    leistung_min.to_sql(table_name[4], connect, if_exists='replace', index= False)

    #print('minutewerte update')

    #save leistung_resample into table VaihingenLeistung
    table_leistung = pd.read_sql('SELECT * FROM VaihingenLeistung ORDER BY Zeit ASC', connect)

    leistung_aktuell_zeit = leistung_resample[0][0]

    table_leistung['Zeit'] = pd.to_datetime(table_leistung['Zeit'])

    table_leistung_letzt_zeit = table_leistung['Zeit'][len(table_leistung) -1]

    zeit_diff = leistung_aktuell_zeit - table_leistung_letzt_zeit

    #print(zeit_diff)

    leistung_15min = pd.DataFrame(
        data={'Zeit': leistung_resample[0], 'Leistung1': leistung_resample[1], 'Leistung2': leistung_resample[2],
              'Leistung': leistung_resample[3]})

    if timedelta(minutes=0) <= zeit_diff <= timedelta(minutes=20):

        print('power data is continuous')

        leistung_15min.to_sql(table_name[5], connect, if_exists='append', index=False)

    elif zeit_diff > timedelta(minutes=20):

        print('power data is not continuous')

        print('missing data from {0} to {1}'.format(leistung_aktuell_zeit, table_leistung_letzt_zeit))

        missing_start = table_leistung_letzt_zeit + timedelta(minutes=15)
        missing_end = leistung_aktuell_zeit - timedelta(minutes=15)

        if missing_end == missing_start:

            missing = pd.DataFrame(data= {'Zeit': [missing_start], 'Leistung1': [np.nan], 'Leistung2': [np.nan],
                                          'Leistung': [np.nan]})
            missing.to_sql(table_name[5], connect, if_exists='append', index=False)

            leistung_15min.to_sql(table_name[5], connect, if_exists='append', index=False)

        else:

            missing_zeit = pd.date_range(start= missing_start, end= missing_end, freq= '15T')

            missing = pd.DataFrame(data= missing_zeit, columns= ['Zeit'])

            missing['Leistung1'] = np.nan
            missing['Leistung2'] = np.nan
            missing['Leistung'] = np.nan

            missing.to_sql(table_name[5], connect, if_exists='append', index=False)

            leistung_15min.to_sql(table_name[5], connect, if_exists='append', index=False)

    elif zeit_diff < timedelta(minutes=0):

        insert_index = table_leistung[ table_leistung['Zeit'] == leistung_aktuell_zeit ].index.tolist()[0]

        table_leistung.drop(index=range(insert_index, len(table_leistung['Zeit'])), inplace=True)

        new_table_leistung = table_leistung.append(leistung_15min, sort=False)

        new_table_leistung.to_sql(table_name[5], connect, if_exists='replace', index=False)

    connect.commit()
    connect.close()

def resample_to_15min_leistung(data):


    diff = data[0][-1] - data[0][0] #Zeitliche Differenz zwischen letztem Zeitpunkt und erstem Zeitpunkt

    if diff >= timedelta(minutes=15):

        re_leistung1_list = []
        re_leistung2_list = []
        re_leistung_list = []
        re_zeit_list = []

        zeit_list = data[0]
        leistung1_list = data[1]
        leistung2_list = data[2]
        leistung_list = data[3]


        for i in range(len(zeit_list)):

            zeit = zeit_list[i]
            leistung1 = leistung1_list[i]
            leistung2 = leistung2_list[i]
            leistung = leistung_list[i]

            minute = int(zeit.minute)

            if minute in [0, 15, 30, 45]:

                re_zeit_list.append(zeit)
                re_leistung1_list.append(leistung1)
                re_leistung2_list.append(leistung2)
                re_leistung_list.append(leistung)

            else:

                continue

        resample_data = [re_zeit_list, re_leistung1_list, re_leistung2_list, re_leistung_list]

        datenmenge_genug = 1

        return resample_data, datenmenge_genug

    else:

        resample_data = 0

        datenmenge_genug = 0

        #print(resample_data)

        return resample_data, datenmenge_genug

def main(download_zeit, sample_aufloesung, database_name, log_path):

    #Tabelle in Datenbank
    Tabelle_Name = ['Wetter', 'Wetter_Resample', 'Wetter_Aktuell', 'Wetter_Resample_Aktuell', 'VaihingenLeistung_Minuten', 'VaihingenLeistung']

    #Wechselrichter Infos, Piko8.5>>>http://129.69.80.184, Piko8.3>>>http://129.69.80.113

    WR83_IP = 'http://129.69.80.113'

    WR85_IP = 'http://129.69.80.184'

    Temp_Leistung_List = []

    Temp_Leistung_1_List = []

    Temp_Leistung_2_List = []

    Temp_Zeit_List = []

    #Wetterprognose Infos
    Heute = "https://www.wetter.com/deutschland/stuttgart/vaihingen/DE0010287103.html#diagramm"
    Morgen = 'https://www.wetter.com/wetter_aktuell/wettervorhersage/morgen/deutschland/stuttgart/vaihingen/DE0010287103.html#diagramm'
    Uebermorgen = 'https://www.wetter.com/wetter_aktuell/wettervorhersage/in-2-tagen/deutschland/stuttgart/vaihingen/DE0010287103.html#diagramm'
    In3Tagen = 'https://www.wetter.com/wetter_aktuell/wettervorhersage/in-3-tagen/deutschland/stuttgart/vaihingen/DE0010287103.html#diagramm'


    while True:

        jetzt = datetime.now()

        DownloadMinute = download_zeit

        AktuellMinute = jetzt.minute

        AktuellZeit = jetzt.hour + AktuellMinute/60

        #Leistungdaten auslesen
        #Leistungdaten werden nur von 6:00 bis 20:30 abgefragt. In der Nacht sind
        if  6 <= AktuellZeit <= 20.5:

            Temp_Leistung_1 = get_pv_power_piko_83(WR83_IP)

            Temp_Leistung_2 = get_pv_power_piko_85(WR85_IP)

            Temp_Leistung = round(Temp_Leistung_1 + Temp_Leistung_2, 3)

        else:

            Temp_Leistung_1 = 0

            Temp_Leistung_2 = 0

            Temp_Leistung = 0

        Temp_Zeit = datetime(year=jetzt.year, month=jetzt.month, day=jetzt.day, hour=jetzt.hour, minute=jetzt.minute, second=0)

        Temp_Leistung_1_List.append(Temp_Leistung_1)

        Temp_Leistung_2_List.append(Temp_Leistung_2)

        Temp_Leistung_List.append(Temp_Leistung)

        Temp_Zeit_List.append(Temp_Zeit)


        #Print Infos
        if DownloadMinute > AktuellMinute:

            naechst = datetime(year=jetzt.year, month=jetzt.month, day=jetzt.day, hour=jetzt.hour, minute= DownloadMinute, second=0)

        elif DownloadMinute <= AktuellMinute:

            naechst = datetime(year=jetzt.year, month=jetzt.month, day=jetzt.day, hour=jetzt.hour, minute=DownloadMinute, second=0) + timedelta(hours=1)

        #print('-------------------------------------------')
        print('Aktuelle Uhrzeit: ', jetzt)
        print('Piko8.3[kW]: ', Temp_Leistung_1)
        print('Piko8.5[kW]: ', Temp_Leistung_2)
        print('Summe[kW] : ', Temp_Leistung)
        print('Naechste Download: ', naechst)
        print('-------------------------------------------')

        #Leistungdaten werden minütlich gesammelt
        time.sleep(sample_aufloesung)

        #Wenn DownloadMinute erreicht, lassen sich alle Leistungdaten und Wetterdaten in Datenbank speichen
        if jetzt.minute == DownloadMinute:

            try:
                #Wetter_3Tage ist stuendliche Wetterprognose
                Wetter_3Tage = veknuepfen_wetter_zeit(Heute, Morgen, Uebermorgen, In3Tagen)

                #Re_Wetter_3tage ist 15min aufgeloeste Wetterprognose
                Re_Wetter_3tage = resample_to_15min_wetter(Wetter_3Tage)

                #Speichern Wetterdaten in Datenkank
                save_all_wetter_into_database(database_name, Tabelle_Name, Wetter_3Tage, Re_Wetter_3tage)

                #Leistungdaten
                Temp_PV_minuetlich =  [Temp_Zeit_List, Temp_Leistung_1_List, Temp_Leistung_2_List, Temp_Leistung_List]

                Temp_PV, Datenmenge_Genug = resample_to_15min_leistung(Temp_PV_minuetlich)

                if Datenmenge_Genug == 1:

                    save_all_leistung_into_database(database_name, Tabelle_Name, Temp_PV_minuetlich, Temp_PV)

                    Temp_Zeit_List = []

                    Temp_Leistung_List = []

                    Temp_Leistung_1_List = []

                    Temp_Leistung_2_List = []

                elif Datenmenge_Genug == 0:

                    print('Leistungdaten sind zu wenig zu speichern, zum naechsten Download Zeitpunkt werden genuegend Daten gesammelt und heruntergelden.')

                #Temp_Zeit_List = []

                #Temp_Leistung_List = []

                #Temp_Leistung_1_List = []

                #Temp_Leistung_2_List = []


            except (Exception, IOError, NameError, ValueError) as msg:

                print(msg)

                write_log_info(jetzt,log_path,msg)

            continue

        else :

            continue




#Haupthunktion
'''Wetterprognosen und Leistungdaten werden jede Stunde einmal in lokaler Datenbank gespeichert. 

   Der Zeitpunkt zum Downloden der Wetterprognosen und Leistungdaten ist durch Download_Zeit eingestellt.
   
   Die Leistungdaten von aktuellem Zeitpunkt bis Download_Zeit werden minutlich gesammelt und werden vorübergehend 
   
   in Python gespeichert. Sobald der Zeitpunkt zum Downloaden erreicht, wird zuerst die Wetterprognose abgefragt und in 
   
   SQLite-Datenbank exportiert. Danach werden die minutlichen Leistungdaten in 15min-Leistungdaten neu gesampelt und in
   
   derselbe SQLite-Datenbank exportiert.  
   
   Beachten: Download_Minute minus Aktueller Zeitpunkt immer größer als 15min einstellen.
   
   (Falls die zeitliche Differenz zwischen Download_Minute und aktuellen Zeitpunkt kleiner als 15min ist, werden vielleicht
   
   keine Leistungdaten zu 15-Minute, 30-Minute, 45-Minute oder 0-Minute ausgelesen.)
    
'''
#Einheit der Download_Zeit ist Minute
Download_Zeit = 20

#Einheit der Aufloesung ist Sekunde, hier bedeutet PV-Leistung wird minütlich gesammelt
Sample_Aufloesung = 60

#Datenbank Infos
Database_Name = 'E:\Projekt\FA\Material\Inhaltlich\Modelle\Haoyan\Abgabe\Daten\Vaihingen_2019.db'

#Log Infos
Log_Path = 'E:\Projekt\FA\Material\Inhaltlich\Modelle\Haoyan\Abgabe\Python'

main(Download_Zeit, Sample_Aufloesung, Database_Name, Log_Path)