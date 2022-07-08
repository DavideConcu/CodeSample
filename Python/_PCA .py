#!/usr/bin/env python
# coding: utf-8

# In[2]:


import pandas as pd 
import numpy as np
import matplotlib.pyplot as plt

from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.impute import SimpleImputer

import datetime
#import pca

get_ipython().run_line_magic('matplotlib', 'inline')


# In[3]:




df = df[keep]


# In[7]:


### IMPUTARE I NAN
imputer = SimpleImputer(missing_values=np.NaN, strategy='mean')


# In[8]:


lista = list(df.columns)





#imputare i NaN le colonne
for colonna in lista:
    df[colonna] = imputer.fit_transform(df[colonna].values.reshape(-1,1))[:,0]


# In[11]:


x = df.loc[:, lista].values


# In[12]:


#standardizzare le colonne
x = StandardScaler().fit_transform(x)


# In[13]:


pd.DataFrame(data = x, columns = lista).head()


# In[176]:


#PCA
pca = PCA(n_components=2)


# In[177]:


principalComponents = pca.fit_transform(x)


# In[178]:


principalDf = pd.DataFrame(data = principalComponents
             , columns = ['principal component 1', 'principal component 2'])


# In[179]:


#merge con la colonna customer
finalDf = pd.concat([principalDf, df[['customer']]], axis = 1)


# In[180]:


finalDf


# In[196]:


#plots
fig = plt.figure(figsize = (8,8))
ax = fig.add_subplot(1,1,1) 
ax.set_xlabel('Principal Component 1', fontsize = 15)
ax.set_ylabel('Principal Component 2', fontsize = 15)
ax.set_title('Principal Component Analysis', fontsize = 20)


targets = [ "AMAZON", 'DHL', 'UPS']
colors = ['r', 'g', 'b']
for target, color in zip(targets,colors):
    indicesToKeep = finalDf['customer'] == target
    ax.scatter(finalDf.loc[indicesToKeep, 'principal component 1']
               , finalDf.loc[indicesToKeep, 'principal component 2']
               , c = color
               , s = 2
               , alpha=0.05)
ax.legend(targets, s=10)
ax.grid()


# In[198]:


ax.legend(targets)


# In[193]:


#explained variance
pca.explained_variance_ratio_




