import ndjson

# with open('full_simplified_arm.ndjson') as f:
#     data = ndjson.load(f)
#
# print(f.read())
import numpy as np
import ujson as json
import pandas as pd

arm = np.load('full_numpy_bitmap_arm.npy')
records = map(json.loads, open('/Users/abalamur/Documents/Summer Research 20/full_simplified_arm.ndjson'))
df = pd.DataFrame.from_records(records)
print(df.head(1))

x = arm.tolist()
df['bitmap'] = x
print(df['bitmap'])

bread = np.load('full_numpy_bitmap_bread.npy')

# to convert back --> np.array(df['bitmap'][0], dtype=np.uint8)


#x = pd.concat([df, pd.Series(arm)])


#match key id from json to numpy bitmap (check if same number of drawings and in the same order)
#figure out index of key id in json file and use that index to get the bitmap
#ask bin


#plot drawings to check if they are the same

#choose one category
#use the few categories that we have human judgments for
#start with one category like bread and train the model on bread and pass it the pairs that we
# have human judgements for and get the similarity estimates for those pairs
#train on 100000 drawings
#get 100000 random sample of drawings (bread)
#look at each country for the bread drawing and take specific number of drawings