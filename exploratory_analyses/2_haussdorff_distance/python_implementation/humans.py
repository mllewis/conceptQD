from quickdraw import QuickDrawData
from quickdraw import QuickDrawDataGroup
from scipy.spatial.distance import directed_hausdorff
import numpy as np
from itertools import chain
import pandas as pd
import json
import requests
from scipy.spatial import distance
from math import *
import torch
#from chamferdist import ChamferDist
from skimage.measure import *
from skimage.measure import compare_ssim
from scipy.ndimage.morphology import distance_transform_edt as dte

url = 'https://raw.githubusercontent.com/mllewis/conceptQD/master/data/processed/human_data/drawings_used.json'
df = pd.read_json(url)


#### HAUSDORFF ####

def human_hd():
    hausdorff_values = []
    for i in range(len(df.drawing)):
        u = np.array(df.drawing[i])
        v = np.array(df.drawing_2[i])
        if len(u[0]) >= len(v[0]): #checks the lengths of the arrays 
            min = len(v[0]) #takes the smaller length
            u = u[:,:min] #makes the longer array the length of the shorter array
                #print("u=", u)
        elif len(u[0]) <= len(v[0]):
            min = len(u[0])
            v = v[:,:min]
        value = directed_hausdorff(u,v)[0]
        hausdorff_values.append(value)
    return hausdorff_values

#### EUCLIDEAN ####  
   
def euclidean(x1, y1, x2, y2):
    for i in range(len(x1)):
        for j in range(len(x2)):
            distance = sqrt((x1[i] - x2[j])**2 + (y1[i]-y2[j])**2)
    return (distance/(len(x1)*len(x2)))

def get_euc():
    euc_values = []
    for i in range(len(df.drawing)):
        a = df.drawing[i][0]
        b = df.drawing[i][1]
        c = df.drawing_2[i][0]
        d = df.drawing_2[i][1]
        euc_values.append(euclidean(a,b,c,d))
    return euc_values

#### IMAGE EUCLIDEAN ####

def get_imed(X,Y):
    final_array = []
    for row in X:
        output = row - Y
        final_array.append(output)
    return final_array

def image_euc():
    imed_values = []
    for i in range(len(df.drawing)):
        u = np.array(df.drawing[i])
        v = np.array(df.drawing_2[i])
        if len(u[0]) >= len(v[0]): #checks the lengths of the arrays 
            min = len(v[0]) #takes the smaller length
            u = u[:,:min] #makes the longer array the length of the shorter array
        elif len(u[0]) <= len(v[0]):
            min = len(u[0])
            v = v[:,:min]
        value = sum(get_imed(u,v))/len(get_imed(u,v))
        avg = np.mean(value)
        imed_values.append(avg)
    return [abs(number) for number in imed_values]

#### THREE STROKES ####

def first_three_hd():
    hd_values = []
    for i in range(len(df.drawing)):
        u = df.drawing[i]
        v = df.drawing_2[i]
        a = np.array([el[:3] for el in u])
        b = np.array([el[:3] for el in v])
        value = directed_hausdorff(a,b)[0]
        hd_values.append(value)
    return hd_values


""" X = np.array([[1,2,3], [4,5,6]])
Y = np.array([[3,4,5],[5,6,7]]) """


#### MANHATTAN ####

def manhattan(x1, y1, x2, y2):
    for i in range(len(x1)):
        for j in range(len(x2)):
            final = abs(x1[i]-x2[j]) + abs(y1[i]-y2[j])
    return final

def get_manhattan():
    m_values = []
    for i in range(len(df.drawing)):
        a = df.drawing[i][0]
        b = df.drawing[i][1]
        c = df.drawing_2[i][0]
        d = df.drawing_2[i][1]
        m_values.append(manhattan(a,b,c,d))
            #euc_values.append(euclidean(a,b,c,d))
    return m_values


#### SSIM

""" X = np.array([[[-9.035250067710876], [7.453250169754028], [33.34074878692627]],[[-6.63700008392334], [5.132999956607819], [31.66075038909912]],[[-5.1272499561309814], [8.251499891281128], [30.925999641418457]]])

Y = np.array([
    [[-5.035250067710876], [7.453250169754028], [33.34074878692627]],
    [[-7.63700008392334], [5.132999956607819], [29.66075038909912]],
    [[-5.1272499561309814], [8.251499891281128], [31.925999641418457]]
    ])

a = np.array(X)
grayA = (X - np.amin(X))/(np.amax(X)-np.amin(X))
b = np.array(Y)
grayB = (Y - np.amin(Y))/(np.amax(Y)-np.amin(Y))

Z = [[5,6], [7,8]]
L = (1-Z) """

#### CHESSBOARD ####
def chessboard(x1,y1,x2,y2):
    for i in range(len(x1)):
        for j in range(len(x2)):
            chess = max(abs(x2[j]-x1[i]),abs(y2[j]-y1[i]))
    return chess

def get_chess():
    chess_values = []
    for i in range(len(df.drawing)):
        a = df.drawing[i][0]
        b = df.drawing[i][1]
        c = df.drawing_2[i][0]
        d = df.drawing_2[i][1]
        chess_values.append(chessboard(a,b,c,d))
    return chess_values

#### CSV OUTPUT####

output = human_hd()
euc_output = get_euc()
imed_output = image_euc()
three_output = first_three_hd()
m_output = get_manhattan()
chess_output = get_chess()
newdf = pd.DataFrame(columns = ['word', 'key_id', 'key_id_2','Hausdorff Distance', 'Euclidean Distance', 'IMED', 'First Three', 'Manhattan', 'Chessboard'])
newdf['word'] = df.word
newdf['key_id'] = df.key_id
newdf['key_id_2'] = df.key_id_2
newdf['Hausdorff Distance'] = output
newdf['Euclidean Distance'] = euc_output
newdf['IMED'] = imed_output
newdf['First Three'] = three_output
newdf['Manhattan'] = m_output
newdf['Chessboard'] = chess_output
newdf.to_csv('Computational_Measures.csv')



