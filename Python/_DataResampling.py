#!/usr/bin/env python
# coding: utf-8

# # Resampling Dati Telemaco pt2

# In[71]:


# packages
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import os 
import re
import glob
from tqdm.auto import tqdm


# frequenza di ricampionamento (s or min)
freq = "1h"



# Type of Merge ("MERGE" or "APPEND") 
mergeOrAppend = "APPEND"


# In[73]:


#lista con i nomi di tutti i file CSV nella cartella dataPath
os.chdir(inPath)
extension = 'csv'

listaFilesCartella = [i for i in glob.glob('*.{}'.format(extension))]
listaFilesCartella


# In[74]:


listaFiles = []
if type(resampleGroups) == str:
    if resampleGroups.upper=="ALL":
        listaFiles = listaFilesCartella
    else:
        for file in listaFilesCartella:
            if re.match("(.*)"+resampleGroups+"(.*)" , file):
                listaFiles.append(file)
                print("file ",file, " aggiunto \n")

if type(resampleGroups) == list:
    for gruppo in resampleGroups:
        for file in listaFilesCartella:
            if re.match("(.*)"+gruppo+"(.*)" , file):
                listaFiles.append(file)
                print("file ", file," aggiunto \n")

listaFiles


# In[75]:



col = ["vehicleID", "dateTime"]
mergedData = pd.DataFrame(columns=col)

for progress in tqdm(range(len(listaFiles)), position=0, leave=True):

    file = listaFiles[progress]

    try:
        print("Resampling for file ", file)
        #load data
        data = pd.read_csv(inPath + file)
    except:
        print("Failed to load ", file)
    try:
        data = data.drop("Time", axis = 1)   
    except:
        print("Time column not found for ", file)
        
    #prendere solo il nome del file (senza .csv)
    for nomeFile in re.finditer("(?P<nome>.*).csv" , file):
        nome = nomeFile.groupdict()["nome"]
    
    #eliminare outliers velocità e SOC ######################   
    if "a" in data:
        data = data[data.TcoVehSpeed < 180 ]
        data.reset_index(drop = True, inplace = True)
        
    for var in ["b", "c"]:   
        if set([var]).issubset(data.columns):
            print(var , " da ripulire")
            toBeDropped = pd.Series(data[((data[var] - data[var].mean())/data[var].std()).abs()>2].index)
            data.drop(toBeDropped, axis=0 ,inplace=True)
            data.reset_index(drop = True, inplace = True)
            print(var, " ripulita, " + str(len(toBeDropped)) + " righe eliminate")
    ###########################################################
    
    # dichiarare la colonna datetime di tipo "datetime" e arrotonda al secondo 
    data.dateTime = pd.to_datetime(data.dateTime)
    data["dateTime"] = data.dateTime.dt.round(freq)
    
    # id veicolo e media su time
    dataID = data[[ "g", "h" ]].drop_duplicates()
    dataMeans = data.groupby("dateTime").mean()

    #merge con il vecchio
    df = pd.merge(dataID , dataMeans , on = "dateTime", how = "inner")
    
    #merge o append con tutti gli altri dataset
    if mergeOrAppend.upper() == "MERGE":
        mergedData = pd.merge(mergedData , df , on = "dateTime", how = "outer")
        print(file , " added to merged dataset")
    elif mergeOrAppend.upper() == "APPEND": 
        mergedData = mergedData.append(df)
        print(file , " added to appended dataset")    
            
    if len(df) != 0:
        df.to_csv(outPath + nome + "_rsmp"+ freq + '.csv', index=False)
        print("+++++ Ricampionamento riuscito per file {} +++++ \n".format(file))

if len(listaFiles)>1:
    if len(mergedData) != 0:
        mergedData.to_csv(outPath + cartella + "_AllGroups" + "_rsmp"+ freq + '.csv', index=False)
        print("!!!!!!!!!!! {} COMPLETATO per la cartella {} !!!!!!!!!!!  \n".format(mergeOrAppend,cartella))

