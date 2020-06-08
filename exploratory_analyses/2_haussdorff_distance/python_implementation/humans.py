from quickdraw import QuickDrawData
from quickdraw import QuickDrawDataGroup
from scipy.spatial.distance import directed_hausdorff
import numpy as np
from itertools import chain
import pandas as pd
from collections import OrderedDict
import json
import requests

url = 'https://raw.githubusercontent.com/mllewis/conceptQD/master/data/processed/human_data/drawings_used.json'
df = pd.read_json(url)

""" def myfunc():
    for i in range(len(humans.drawing_key_id_1)):
        for j in range(len(humans.drawing_key_id_2)):
            u = humans.iloc[i][1]
            print("u=", u)
            v = humans.iloc[j][2]
            print("v=", v)
    return 5 """

""" resp = requests.get(url)
data = json.loads(resp.text) """

def human_hd():
    hausdorff_values = []
    for i in range(len(df.drawing)):
        #for j in range(len(df.drawing_2)):
            #print(i,j)
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

""" def draw1():
    first = df.drawing[0]
    second = df.drawing_2[0]
    print("u = ", first, "v=", second)
    print("len=", len(first[0]))
    return directed_hausdorff(first, second) """

u = np.array(df.drawing[0])
v = df.drawing_2[0]

output = human_hd()
#print(output)

df['Hausdorff Distance'] = output
