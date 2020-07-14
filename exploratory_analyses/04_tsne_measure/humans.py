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
from skimage.measure import *
from skimage.measure import compare_ssim
from scipy.ndimage.morphology import distance_transform_edt as dte
import statistics
import inspect
from sklearn.manifold import TSNE



url = 'https://raw.githubusercontent.com/mllewis/conceptQD/master/data/processed/human_data/drawings_used.json'
df = pd.read_json(url)

strokes_df = pd.read_json('https://raw.githubusercontent.com/mllewis/conceptQD/master/data/processed/human_data/drawings_used_2.json')

#print(inspect.getsource(directed_hausdorff))
#### HAUSDORFF ####
def pairs(b):
    coords = [z for x,y in b for z in zip(x,y)]
    return coords

""" def human_hd():
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
        value = max(directed_hausdorff(u,v)[0], directed_hausdorff(v,u)[0]) #changed
        hausdorff_values.append(value)
    return hausdorff_values """

def humans_hd():
    hausdorff_values = []
    for i in range(len(strokes_df.drawing)):
        u = pairs(strokes_df.drawing[i])
        v = pairs(strokes_df.drawing_2[i])
        if len(u) >= len(v): #checks the lengths of the arrays 
            min = len(v) #takes the smaller length
            u = u[:min] #makes the longer array the length of the shorter array
                #print("u=", u)
        elif len(u) <= len(v):
            min = len(u)
            v = v[:min]
        value = max(directed_hausdorff(u,v)[0], directed_hausdorff(v,u)[0]) #changed
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
    for i in range(len(strokes_df.drawing)):
        a = strokes_df.drawing[i][:3]
        b = strokes_df.drawing_2[i][:3]
        u = pairs(a)
        v = pairs(b)
        if len(u) >= len(v): #checks the lengths of the arrays 
            min = len(v) #takes the smaller length
            u = u[:min] #makes the longer array the length of the shorter array
                #print("u=", u)
        elif len(u) <= len(v):
            min = len(u)
            v = v[:min]
        value = max(directed_hausdorff(u,v)[0], directed_hausdorff(v,u)[0]) #changed
        hd_values.append(value)
    return hd_values


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


#### SSIM ####

def ssim(x,y):
    u_x = statistics.mean(x)
    u_y = statistics.mean(y)
    s_x = statistics.variance(x)
    s_y = statistics.variance(y)
    cov = np.cov(x,y, bias = True)[0][1]
    c1 = 6.5
    c2 = 58.52
    ssim = ((2*u_x*u_y + c1)*(2*cov + c2))/((u_x**2 + u_y**2 + c1)*(s_x**2 + s_y**2 +c2))
    return ssim

def get_ssim():
    ssim_values = []
    for i in range(len(df.drawing)):
        a = df.drawing[i][0]
        b = df.drawing[i][1]
        c = df.drawing_2[i][0]
        d = df.drawing_2[i][1]
        x = ssim(a,b)
        y = ssim(c,d)
        ssim_values.append(np.mean([x,y]))
    return ssim_values

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

#### 3 LONGEST STROKES

def sort_strokes(a):
    a_sorted = sorted(a, key=lambda i: len(i[0]), reverse=True)
    return a_sorted


def longest():
    hausdorff_vals = []
    for i in range(len(strokes_df.drawing)):
        x = sort_strokes(strokes_df.drawing[i])
        y = sort_strokes(strokes_df.drawing_2[i])
        first = x[:3]
        second = y[:3]
        u = pairs(first)
        v = pairs(second)
        if len(u) >= len(v): #checks the lengths of the arrays 
            min = len(v) #takes the smaller length
            u = u[:min] #makes the longer array the length of the shorter array
                #print("u=", u)
        elif len(u) <= len(v):
            min = len(u)
            v = v[:min]
        value = max(directed_hausdorff(u,v)[0], directed_hausdorff(v,u)[0]) #changed
        hausdorff_vals.append(value)
    return hausdorff_vals

#### TSNE ####
""" TSNE components = 2, flatten vector to 1d, do cosine for each pair
TSNE components = 1, euclidean distance between the pairs """

def tsne(x):
    value = TSNE(n_components = 2).fit_transform(x)
    arr = value.flatten()
    return arr

def get_cosine():
    cos_vals = []
    for i in range(len(df.drawing)):
        x = tsne(df.drawing[i])
        y = tsne(df.drawing_2[i])
        cos_vals.append(distance.cosine(x,y))
    return cos_vals

def eucl(x1,y1,x2,y2):
    distance = sqrt((x1 - x2)**2 + (y1-y2)**2)
    return distance

def tsne_n1(x):
    value = TSNE(n_components = 1).fit_transform(x)
    arr = value.flatten()
    return arr

def tsne_euc():
    euc_vals = []
    for i in range(len(df.drawing)):
        x = tsne_n1(df.drawing[i])
        y = tsne_n1(df.drawing_2[i])
        euc_vals.append(eucl(x[0], x[1], y[0], y[1]))
    return euc_vals


#### CSV OUTPUT####

output = humans_hd()
euc_output = get_euc()
imed_output = image_euc()
three_output = first_three_hd()
m_output = get_manhattan()
chess_output = get_chess()
ssim_output = get_ssim()
longest_output = longest()
cos_output = get_cosine()
tsne_euc_output = tsne_euc()
newdf = pd.DataFrame(columns = ['word', 'key_id', 'key_id_2','Hausdorff Distance', 'Euclidean Distance', 'IMED', 'First Three', 'Manhattan', 'Chessboard', 'SSIM', 'Three Longest', 'Cosine', 'Euc TSNE'])
newdf['word'] = df.word
newdf['key_id'] = df.key_id
newdf['key_id_2'] = df.key_id_2
newdf['Hausdorff Distance'] = output
newdf['Euclidean Distance'] = euc_output
newdf['IMED'] = imed_output
newdf['First Three'] = three_output
newdf['Manhattan'] = m_output
newdf['Chessboard'] = chess_output
newdf['SSIM'] = ssim_output
newdf['Three Longest'] = longest_output
newdf['Cosine'] = cos_output
newdf['Euc TSNE'] = tsne_euc_output
newdf.to_csv('Computational_Measures.csv')




