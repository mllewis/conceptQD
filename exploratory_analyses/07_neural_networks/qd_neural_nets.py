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

# K.set_image_dim_ordering('th')


qd = QuickDrawData()
anvil = qd.get_drawing("anvil")
anvil.image.save("my_anvil.gif")

anvil_bit = np.load('full_numpy_bitmap_anvil.npy')
print(anvil_bit.shape)  # prints no of pics, pixels_size

anvil_bit = np.c_[anvil_bit, np.zeros(len(anvil_bit))]


def plot_pics(input, rows=1, cols=5, title=''):
    fig, ax = plt.subplots(figsize=(cols, rows))
    ax.axis('off')
    plt.title(title)
    for i in list(range(0, min(len(input), (rows * cols)))):
        a = fig.add_subplot(rows, cols, i + 1)
        imgplot = plt.imshow(input[i, :784].reshape((28, 28)), cmap='gray_r', interpolation='nearest')
        plt.xticks([])
        plt.yticks([])


plot_pics(anvil_bit, title='Anvils')

X = np.concatenate((anvil_bit[:10000,:-1]), axis = 0).astype('float32')
print(X)
Y = np.concatenate((anvil_bit[:10000,:-1]), axis = 0).astype('float32')

X_train, X_test, Y_train, Y_test = train_test_split(X/255., Y, test_size = 0.5, random_state = 0)

Y_train_cnn = np_utils.to_categorical(Y_train)
Y_test_cnn = np_utils.to_categorical(Y_test)
num_classes = Y_test_cnn.shape[1]

#reshape to be [samples][pixels][width][height]
X_train_cnn = X_train.reshape(X_train.shape[0], 1, 28, 28).astype('float32')
X_test_cnn = X_test.reshape(X_test.shape[0], 1, 28, 28). astype('float32')
s = X_train_cnn.shape
print(s)
print(num_classes)

