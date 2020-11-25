import matplotlib
import tensorflow as tf
import numpy as np
import pandas as pd
import keras
from keras.datasets import mnist
from keras.models import Sequential, load_model
from keras.layers import Dense, Dropout, Flatten
from keras.layers.convolutional import Conv2D, MaxPooling2D
from keras.utils import np_utils
from keras import backend as K
#K.set_image_data_format('channels_first')

# %matplotlib inline
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split, GridSearchCV
import quickdraw
from quickdraw import QuickDrawDataGroup
from quickdraw import QuickDrawData
from scipy.spatial.distance import directed_hausdorff
from itertools import chain
import pandas as pd
import ndjson
import cv2
import operator

# K.set_image_dim_ordering('th')

#template taken from https://github.com/ck090/Google_Quick_Draw/blob/master/Myquickdraw.ipynb

#anvil_bit = np.load('full_numpy_bitmap_anvil.npy')
arm = np.load('full_numpy_bitmap_arm.npy')
bicycle = np.load('full_numpy_bitmap_bicycle.npy')
book = np.load('full_numpy_bitmap_book.npy')
paperClip = np.load('full_numpy_bitmap_paper clip.npy')
#print(anvil_bit.shape)  # prints no of pics, pixels_size

#print "no_of_pics, pixels_size"
print(arm.shape)
print(bicycle.shape)
print(book.shape)
print(paperClip.shape)


# add a column with labels, 0=book, 1=bicycle, 2=book, 3=paperclip
arm = np.c_[arm, np.zeros(len(arm))]
bicycle = np.c_[bicycle, np.ones(len(bicycle))]
book = np.c_[book, 2*np.ones(len(book))]
paperClip = np.c_[paperClip, 3*np.ones(len(paperClip))]

# Function to plot 28x28 pixel drawings that are stored in a numpy array.
# Specify how many rows and cols of pictures to display (default 4x5).
# If the array contains less images than subplots selected, surplus subplots remain empty.
# def plot_samples(input_array, rows=1, cols=5, title=''):
#     fig, ax = plt.subplots(figsize=(cols,rows))
#     ax.axis('off')
#     plt.title(title)
#
#     for i in list(range(0, min(len(input_array),(rows*cols)) )):
#         a = fig.add_subplot(rows,cols,i+1)
#         imgplot = plt.imshow(input_array[i,:784].reshape((28,28)), cmap='gray_r', interpolation='nearest')
#         plt.xticks([])
#         plt.yticks([])

# Plot arm samples
#plot_samples(arm, title='Sample arm drawings\n')
#plot_samples(bicycle, title = 'Sample bicycle drawings\n')
#plot_samples(book, title = 'Sample book drawings\n')
#plot_samples(paperClip, title = 'Sample paperClip drawings\n')

# merge the arrays, and split the features (X) and labels (y). Convert to float32 to save some memory.
X = np.concatenate((arm[:10000,:-1], bicycle[:10000,:-1], book[:10000,:-1], paperClip[:10000,:-1]), axis=0).astype('float32') # all columns but the last
y = np.concatenate((arm[:10000,-1], bicycle[:10000,-1], book[:10000,-1], paperClip[:10000,-1]), axis=0).astype('float32') # the last column

# train/test split (divide by 255 to obtain normalized values between 0 and 1)
# Use a 50:50 split, training the models on 10'000 samples and thus have plenty of samples to spare for testing.
X_train, X_test, y_train, y_test = train_test_split(X/255.,y,test_size=0.5,random_state=0)


# one hot encode outputs
y_train_cnn = np_utils.to_categorical(y_train) #converts class vector "y_train" to binary class matrix
y_test_cnn = np_utils.to_categorical(y_test)
num_classes = y_test_cnn.shape[1] #gets the number of cols (second element in tupule)

# reshape to be [samples][pixels][width][height] --> became sample, width, height, pixels/channels
X_train_cnn = X_train.reshape(X_train.shape[0], 28, 28, 1).astype('float32')
X_test_cnn = X_test.reshape(X_test.shape[0], 28, 28, 1).astype('float32')
s = X_train_cnn.shape
print(s, num_classes)


# define the CNN model
def cnn_model(): #780 in model summary
    # create model
    # provides the training and inference features on the model -->start
    model = Sequential()

    #onto the first layer, add the convolutional layer which uses dim of output(number of output filters,
    #kernel size, padding so output has same width and height, input shape =rows,cols,channels since data_format = channels_last
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
# Fit the model
#trains the model for a fixed number of epochs
#validation_data =  Data on which to evaluate the loss and any model metrics at the end of each epoch.

model.fit(X_train_cnn, y_train_cnn, validation_data=(X_test_cnn, y_test_cnn), epochs=1, batch_size=50) #changed from history =

# Final evaluation of the model
#returns the loss value and metric values for the model
# x = input data, y = target data
#verbose says how you want to see the training progress for each epoch
scores = model.evaluate(X_test_cnn, y_test_cnn, verbose=0) #interpret
print('Final CNN accuracy: ', scores[1]*100, "%")

# Save weights
#model.save_weights('quickdraw_neuralnet.h5')
model.save('trained_quickdraw.model')
#print("Model is saved")


#rename file to be trained_qd_model
#get model weights for an arbitrary picture
