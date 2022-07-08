#!/usr/bin/env python
# coding: utf-8

# In[8]:


# INSTALLARE PACCHETTI!
#!pip install tslearn


# In[1]:


import numpy
import matplotlib.pyplot as plt

from tslearn.clustering import TimeSeriesKMeans
from tslearn.datasets import CachedDatasets
from tslearn.preprocessing import TimeSeriesScalerMeanVariance, TimeSeriesResampler


# In[23]:


seed = 0
numpy.random.seed(seed)
X_train, y_train, X_test, y_test = CachedDatasets().load_dataset("Trace")
X_train = X_train[y_train < 4]  # Keep first 3 classes
numpy.random.shuffle(X_train)
# Keep only 50 time series
X_train = TimeSeriesScalerMeanVariance().fit_transform(X_train[:50])
# Make time series shorter
X_train = TimeSeriesResampler(sz=40).fit_transform(X_train)
sz = X_train.shape[1]


# In[26]:


len(X_train[0])


# In[30]:


# Euclidean k-means
print("Euclidean k-means")
km = TimeSeriesKMeans(n_clusters=3, verbose=True, random_state=seed)
y_pred = km.fit_predict(X_train)


# In[31]:


y_pred


# In[33]:


plt.figure()
for yi in range(3):
    plt.subplot(3, 3, yi + 1)
    for xx in X_train[y_pred == yi]:
        plt.plot(xx.ravel(), "k-", alpha=.2)


# In[39]:


plt.figure()
for yi in range(3):
    plt.subplot(3, 3, yi + 1)
    for xx in X_train[y_pred == yi]:
        plt.plot(xx.ravel(), "k-", alpha=.2)
    #plt.plot(km.cluster_centers_[yi].ravel(), "r-")
   # plt.xlim(0, sz)
    #plt.ylim(-4, 4)
    #plt.text(0.55, 0.85,'Cluster %d' % (yi + 1),
        #     transform=plt.gca().transAxes)
   # if yi == 1:
       # plt.title("Euclidean $k$-means")


# In[38]:


X_train.ravel()


# In[ ]:




