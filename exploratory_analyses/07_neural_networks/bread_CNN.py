from keras.models import Sequential, load_model
from keras.layers import Dense, Dropout, Flatten
from keras.layers.convolutional import Conv2D, MaxPooling2D
from keras.utils import np_utils

from sklearn.model_selection import train_test_split

import numpy as np
import ujson as json
import pandas as pd




bread = np.load('full_numpy_bitmap_bread.npy')

#bread = np.c_[bread, np.zeros(len(bread))]

A = bread[:10000]
b = bread[:10000, -1]


# train/test split (divide by 255 to obtain normalized values between 0 and 1)
# Use a 50:50 split, training the models on 10'000 samples and thus have plenty of samples to spare for testing.
A_train, A_test, b_train, b_test = train_test_split(A/255.,b,test_size=0.5,random_state=0)

# one hot encode outputs
b_train_cnn = np_utils.to_categorical(b_train) #converts class vector "y_train" to binary class matrix
b_test_cnn = np_utils.to_categorical(b_test)
num_classes = b_test_cnn.shape[1]

# reshape to be [samples][pixels][width][height] --> became sample, width, height, pixels/channels
#A_train = np.arange(3920000).reshape(20000, 784)
A_train_cnn = A_train.reshape(A_train.shape[0], 28, 28, 1).astype('float32')
A_test_cnn = A_test.reshape(A_test.shape[0], 28, 28, 1).astype('float32')
s = A_train_cnn.shape
# print(s, num_classes)

# define the CNN model
def cnn_model(): #780 in model summary
    # create model
    # provides the training and inference features on the model -->start
    model = Sequential()

    #onto the first layer, add the convolutional layer which uses dim of output(number of output filters,
    #kernel size, padding so output has same width and height, input shape =rows,cols,channels since datac_format = channels_last
    #and activation function --> relu = rectified linear unit activation function
    model.add(Conv2D(30, (5, 5), padding="same", input_shape=(28, 28, 1), activation='relu')) #padding="same"
    print("conv weights =", model.get_weights())
    #pool_size = the window size to take max --> (2,2) takes the max value over 2x2 pooling window
    #output gives a feature map containing most prominent features of the previous feature map
    model.add(MaxPooling2D(pool_size=(2, 2)))

    model.add(Conv2D(15, (3, 3), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))

    #randomly sets inout units to 0 w/frequency rate at each step during training time to prevent overfitting
    #rate = fraction of the input units to drop
    model.add(Dropout(0.2))

    #flattens the input to reshape the tensor to have the shape that is equal to num of elements contained in tensor
    #does not affect the batch size
    model.add(Flatten())

    #implements the equation output = activation(dot(input, kernel) + bias)
    #units = dim of output space
    model.add(Dense(128, activation='relu'))
    model.add(Dense(50, activation='relu'))
    model.add(Dense(num_classes, activation='softmax'))

    # Compile model
    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

    # get weights for the layers
    # for l in model.layers:
    #     for w in l.weights:
    #         print(w)
    return model

# build the model
model = cnn_model()

model.fit(A_train_cnn, b_train_cnn, validation_data=(A_test_cnn, b_test_cnn), epochs=1, batch_size=50) #changed from history =

# Final evaluation of the model
#returns the loss value and metric values for the model
# x = input data, y = target data
# verbose says how you want to see the training progress for each epoch
scores = model.evaluate(A_test_cnn, b_test_cnn, verbose=0) #interpret
print('Final CNN accuracy: ', scores[1]*100, "%")

# Save weights
# model.save_weights('quickdraw_neuralnet.h5')
model.save('trained_quickdraw.model')
#print("Model is saved")

################################
### evaluate bread drawings ####
###############################

bread_id = pd.read_csv("https://raw.githubusercontent.com/mllewis/conceptQD/master/exploratory_analyses/07_neural_networks/sampled_bread_ids.csv")
records = map(json.loads, open('/Users/abalamur/Documents/Summer Research 20/full_simplified_bread.ndjson'))
df = pd.DataFrame.from_records(records)
#print(df.head(1))

x = bread.tolist()
df['bitmap'] = x
#print(df['bitmap'])

df['key_id']=df['key_id'].astype(int)
bread_id['key_id']=bread_id['key_id'].astype(int)
bread_pairs = bread_id.merge(df, on=['key_id'], how='left')


drawing = np.array(bread_pairs['bitmap'][0], dtype=np.uint8)
new_test_cnn = drawing.reshape(1, 28, 28, 1).astype('float32')  # (1,2,28,28)
#print(new_test_cnn.shape)

# CNN predictions
new_cnn_predict = model.predict(new_test_cnn, batch_size=32, verbose=0)





# output csv with keyid + 100 columns for each weight within the array
# get additional csv with the second to last layer as well
#test on NEW bread drawings that we have human judgement files
# find csv for the key_id with bread images that we have human judgements for (~200 pairs) so overall 400 weights in total



def weights():
    saved = {}
    for i in range(len(bread_pairs["key_id"])): #10000 key_ids
        drawing = np.array(bread_pairs['bitmap'][i], dtype=np.uint8) #save singular bitmap as a drawing
        new_test_cnn = drawing.reshape(1, 28, 28, 1).astype('float32') #reshape the drawing
        new_cnn_predict = model.predict(new_test_cnn, batch_size=32, verbose=0) #pass drawing to CNN
        w = model.layers[8].get_weights() #getting weights of the last layer
        w = list(w[0].flatten()) #get the 200 elements
        saved[bread_pairs["key_id"][i]] = w #map to dictionary
    return pd.DataFrame.from_dict(saved, orient = 'index').to_csv('bread_weights.csv')

weights()

# df = pd.DataFrame.from_dict(weights(), orient='index')
# df.to_csv('bread_weights.csv')
