import pandas as pd
import numpy as np

bread = pd.read_csv("https://raw.githubusercontent.com/mllewis/conceptQD/master/data/processed/computational_distance_measures/Bread_Countries.csv")
coords = pd.read_csv("https://raw.githubusercontent.com/mllewis/conceptQD/master/data/processed/computational_distance_measures/Coordinates.csv")
coords = coords.drop_duplicates(subset = ['iso2'], keep = 'first')



A = pd.merge(bread,coords, how = 'left', left_on='V1', right_on='iso2').drop(['V1'],axis=1)
B = pd.merge(A,coords, how = 'left', left_on='V2', right_on='iso2').drop(['V2'],axis=1)

B.to_csv('bread_coords.csv')
