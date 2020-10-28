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
def plot_samples(input_array, rows=1, cols=5, title=''):
    fig, ax = plt.subplots(figsize=(cols,rows))
    ax.axis('off')
    plt.title(title)

    for i in list(range(0, min(len(input_array),(rows*cols)) )):
        a = fig.add_subplot(rows,cols,i+1)
        imgplot = plt.imshow(input_array[i,:784].reshape((28,28)), cmap='gray_r', interpolation='nearest')
        plt.xticks([])
        plt.yticks([])

# Plot arm samples
plot_samples(arm, title='Sample arm drawings\n')
plot_samples(bicycle, title = 'Sample bicycle drawings\n')
plot_samples(book, title = 'Sample book drawings\n')
plot_samples(paperClip, title = 'Sample paperClip drawings\n')

# merge the arrays, and split the features (X) and labels (y). Convert to float32 to save some memory.
X = np.concatenate((arm[:10000,:-1], bicycle[:10000,:-1], book[:10000,:-1], paperClip[:10000,:-1]), axis=0).astype('float32') # all columns but the last
y = np.concatenate((arm[:10000,-1], bicycle[:10000,-1], book[:10000,-1], paperClip[:10000,-1]), axis=0).astype('float32') # the last column

# train/test split (divide by 255 to obtain normalized values between 0 and 1)
# Use a 50:50 split, training the models on 10'000 samples and thus have plenty of samples to spare for testing.
X_train, X_test, y_train, y_test = train_test_split(X/255.,y,test_size=0.5,random_state=0)


# one hot encode outputs
y_train_cnn = np_utils.to_categorical(y_train)
y_test_cnn = np_utils.to_categorical(y_test)
num_classes = y_test_cnn.shape[1]

# reshape to be [samples][pixels][width][height]
X_train_cnn = X_train.reshape(X_train.shape[0], 28, 28, 1).astype('float32')
X_test_cnn = X_test.reshape(X_test.shape[0], 28, 28, 1).astype('float32')
s = X_train_cnn.shape
print(s, num_classes)


# define the CNN model
def cnn_model():
    # create model
    model = Sequential()

    model.add(Conv2D(30, (5, 5), padding="same", input_shape=(28, 28, 1), activation='relu')) #padding="same"
    model.add(MaxPooling2D(pool_size=(2, 2)))

    model.add(Conv2D(15, (3, 3), activation='relu'))
    model.add(MaxPooling2D(pool_size=(2, 2)))

    model.add(Dropout(0.2))
    model.add(Flatten())

    model.add(Dense(128, activation='relu'))
    model.add(Dense(50, activation='relu'))
    model.add(Dense(num_classes, activation='softmax'))

    # Compile model
    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model

# build the model
model = cnn_model()
# Fit the model
history = model.fit(X_train_cnn, y_train_cnn, validation_data=(X_test_cnn, y_test_cnn), epochs=30, batch_size=50)
# Final evaluation of the model
scores = model.evaluate(X_test_cnn, y_test_cnn, verbose=0)
#print('Final CNN accuracy: ', scores[1]*100, "%")

# Save weights
model.save_weights('quickdraw_neuralnet.h5')
model.save('quickdraw.model')
#print("Model is saved")


model = load_model('quickdraw.model')
model.summary()

img_width = 28
img_height = 28

# store the label codes in a dictionary
label_dict = {0: 'arm', 1: 'bicycle', 2: 'book', 3: 'paper_clip'}

# print X_test_cnn[0]
# CNN predictions
cnn_probab = model.predict(X_test_cnn, batch_size=32, verbose=0)
# print cnn_probab[4]

# Plotting the X_test data and finding out the probabilites of prediction
fig, ax = plt.subplots(figsize=(7, 15))

for i in list(range(6)):
    print
    "The drawing is identified as --> ", label_dict[y_test[i]], " <-- with a probability of ", max(cnn_probab[i]) * 100

    # plot probabilities:
    ax = plt.subplot2grid((6, 5), (i, 0), colspan=4);
    plt.bar(np.arange(4), cnn_probab[i], 0.35, align='center');
    plt.xticks(np.arange(4), ['arm', 'bicycle', 'book', 'paper_clip'])
    plt.tick_params(axis='x', bottom='off', top='off')
    plt.ylabel('Probability')
    plt.ylim(0, 1)
    plt.subplots_adjust(hspace=0.5)

    # plot picture:
    ax = plt.subplot2grid((6, 5), (i, 4), colspan=1);
    plt.imshow(X_test[i].reshape((28, 28)), cmap='gray_r', interpolation='nearest');
    plt.xlabel(label_dict[y_test[i]]);  # get the label from the dict
    plt.xticks([])
    plt.yticks([])



img = cv2.imread('arm.png', 0)
#ret,thresh1 = cv2.threshold(img,127,255,cv2.THRESH_BINARY)
img = cv2.resize(img, (img_width, img_height))
plt.imshow((img.reshape((28,28))), cmap='gray_r')

#print img, "\n"
arr = np.array(img-255)
#print arr
arr = np.array(arr/255.)
#print arr

new_test_cnn = arr.reshape(1, 28, 28, 1).astype('float32') #(1,2,28,28)
print(new_test_cnn.shape)

import operator

# CNN predictions
new_cnn_predict = model.predict(new_test_cnn, batch_size=32, verbose=0)

pr = model.predict_classes(arr.reshape((1, 28, 28, 1))) #(1,1,28,28)
# print pr
# Plotting the X_test data and finding out the probabilites of prediction
fig, ax = plt.subplots(figsize=(8, 3))

# Finding the max probability
max_index, max_value = max(enumerate(new_cnn_predict[0]), key=operator.itemgetter(1))

print("The drawing is identified as --> ", label_dict[max_index], " <-- with a probability of ", max_value * 100)

for i in list(range(1)):
    # plot probabilities:
    ax = plt.subplot2grid((1, 5), (i, 0), colspan=4);
    plt.bar(np.arange(4), new_cnn_predict[i], 0.35, align='center');
    plt.xticks(np.arange(4), ['arm', 'bicycle', 'book', 'paper_clip'])
    plt.tick_params(axis='x', bottom='off', top='off')
    plt.ylabel('Probability')
    plt.ylim(0, 1)
    plt.subplots_adjust(hspace=0.5)

    # plot picture:
    ax = plt.subplot2grid((1, 5), (i, 4), colspan=1);
    plt.imshow((img.reshape(28, 28)), cmap='gray_r')
    plt.xticks([])
    plt.yticks([])