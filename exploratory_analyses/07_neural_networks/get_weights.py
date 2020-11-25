from PIL import Image
from quickdraw import QuickDrawData
from quickdraw import QuickDrawDataGroup
import json
from trained_qd_model import *

qd = QuickDrawData()

#####


# load trained model, get arbitrary image, pass image into trained model, get weights, save weights to a file

# load model
# model = load_model('trained_quickdraw.model')
# model.summary()

arms = QuickDrawDataGroup("arm")
arm = arms.get_drawing()
# extract key id from arm
# print(arm)
#x = arms.search_drawings(key_id= int(5778229946220544))
# print the output?
# x[0]
arm.image.save('arm2.png')
im = Image.open('arm2.png')
im = im.resize((92, 92), Image.ANTIALIAS)
im.save('armcopy.png')
# print('width: %d - height: %d' % im.size)

img_width = 28
img_height = 28

# store the label codes in a dictionary
# label_dict = {0: 'arm', 1: 'bicycle', 2: 'book', 3: 'paper_clip'}

# print X_test_cnn[0]
# CNN predictions

#
# cnn_probab = model.predict(X_test_cnn, batch_size=32, verbose=0)
# print(cnn_probab[4])

img = cv2.imread('armcopy.png', 0)

# ret,thresh1 = cv2.threshold(img,127,255,cv2.THRESH_BINARY)
img = cv2.resize(img, (img_width, img_height))
# plt.imshow((img.reshape((28,28))), cmap='gray_r')

# print img, "\n"
arr = np.array(img - 255)
# print arr
arr = np.array(arr / 255.)
# print arr

new_test_cnn = arr.reshape(1, 28, 28, 1).astype('float32')  # (1,2,28,28)
print(new_test_cnn.shape)

# CNN predictions
new_cnn_predict = model.predict(new_test_cnn, batch_size=32, verbose=0)

#getting weights of the last layer
print(model.layers[8].get_weights())

# get weights for the layers
# for l in model.layers:
#     for w in l.weights:
#         print(w)

# get model weights from new_cnn_predict and save them to csv along with respective key id (key id, weights array)
# keep as matrix, instead of converting to png
# determine which layer to get the weights from
# rename file to "get_weights"


# pr = model.predict_classes(arr.reshape((1, 28, 28, 1))) #(1,1,28,28)
# # print pr
# # Plotting the X_test data and finding out the probabilites of prediction
# fig, ax = plt.subplots(figsize=(8, 3))
#
# # Finding the max probability
# max_index, max_value = max(enumerate(new_cnn_predict[0]), key=operator.itemgetter(1))
#
# #print("The drawing is identified as --> ", label_dict[max_index], " <-- with a probability of ", max_value * 100)
#
# # Plotting the X_test data and finding out the probabilites of prediction
# fig, ax = plt.subplots(figsize=(7, 15))
#
# for i in list(range(6)):
#     print("The drawing is identified as --> ", label_dict[y_test[i]], " <-- with a probability of ", max(cnn_probab[i]) * 100)
#
#     # plot probabilities:
#     ax = plt.subplot2grid((6, 5), (i, 0), colspan=4);
#     plt.bar(np.arange(4), cnn_probab[i], 0.35, align='center');
#     plt.xticks(np.arange(4), ['arm', 'bicycle', 'book', 'paper_clip'])
#     plt.tick_params(axis='x', bottom='off', top='off')
#     plt.ylabel('Probability')
#     plt.ylim(0, 1)
#     plt.subplots_adjust(hspace=0.5)
#
#     # plot picture:
#     ax = plt.subplot2grid((6, 5), (i, 4), colspan=1);
#     plt.imshow(X_test[i].reshape((28, 28)), cmap='gray_r', interpolation='nearest');
#     plt.xlabel(label_dict[y_test[i]]);  # get the label from the dict
#     plt.xticks([])
#     plt.yticks([])
#
#
#
#
# for i in list(range(1)):
#     # plot probabilities:
#     ax = plt.subplot2grid((1, 5), (i, 0), colspan=4);
#     plt.bar(np.arange(4), new_cnn_predict[i], 0.35, align='center');
#     plt.xticks(np.arange(4), ['arm', 'bicycle', 'book', 'paper_clip'])
#     plt.tick_params(axis='x', bottom='off', top='off')
#     plt.ylabel('Probability')
#     plt.ylim(0, 1)
#     plt.subplots_adjust(hspace=0.5)
#
#     # plot picture:
#     ax = plt.subplot2grid((1, 5), (i, 4), colspan=1);
#     plt.imshow((img.reshape(28, 28)), cmap='gray_r')
#     plt.xticks([])
#     plt.yticks([])


# get weights from model.predict for each image
# use pretrained model and pass an image

# loaded the bitmaps of each google drawing from the 4 categories in the beginning
# can we just take a single bitmap of a random drawing in there and pass it through?


# load file qd_neural_nets.py/trained_qd_model