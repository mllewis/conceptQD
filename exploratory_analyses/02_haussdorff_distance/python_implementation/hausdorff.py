from quickdraw import QuickDrawData
from quickdraw import QuickDrawDataGroup
from scipy.spatial.distance import directed_hausdorff
import numpy as np
from itertools import chain

qd = QuickDrawData()
anvil = qd.get_drawing("anvil")
anvils = QuickDrawDataGroup("anvil")
#anvil = anvils.get_drawing()


#iterate through drawings
#get one drawing group
#multiple drawings within that group (for one name, ie airplane)
#get coordinates of first drawing and second drawing
#hausdorff distance to get min distance across all drawings in that group
#save distances comparing one drawing per group to the next drawing in that group
#find the minimum distance


#VERSION1

def get_drawing(qd):
    for drawing in qd.drawing_names: #list of names of drawings
        name = qd.get_drawing(qd.drawing_names[drawing]) #gets drawing name
        for i in len(name.image_data): #loops through coords of all drawings
            for j in range(1):
                drawing_1 = np.array(name.image_data[i][0])
                drawing_2 = np.array(name.image_data[i][1])
        return(xcoords, ycoords) 
                
""" for stroke in anvil.strokes:
    for x, y in stroke:
        print("x={} y={}".format(x, y)) """





#VERSION2 (for anvil drawings)

draw = anvils.get_drawing(index = 2) 


#first = anvils.get_drawing(index = 0)
#second = anvils.get_drawing(index = 1)
#drawing_1 = first.strokes
#print("dist = ", directed_hausdorff(u,v))

#print("out = ", list(zip(*x)))

""" compress = [item for sublist in first.strokes for item in sublist]
comp = [item for sublist in second.strokes for item in sublist]
a = np.array(list(zip(*compress)))
b = np.array(list(zip(*comp))) """

""" list(zip(*sum(b,[])))
list(zip(*chain.from_iterable(b))) """

#t = a[:,:25]

def shorten(x,y): #x,y are any 2xN matrices
    min = 0
    if len(x[0]) >= len(y[0]):
        min = len(y[0])
        x = x[:,:min]
        return(x and y)
    elif len(x[0]) <= len(y[0]):
        min = len(x[0])
        y = y[:,:min]
        print(y)

def hausdorff():
    for i in range(anvils.drawing_count):
        for j in range(1,anvils.drawing_count):
            first = anvils.get_drawing(index = i) #gets first anvil drawing
            second = anvils.get_drawing(index = j) #gets second drawing
            coords_1 = [item for sublist in first.strokes for item in sublist] #puts list of list into one list
            coords_2 = [item for sublist in second.strokes for item in sublist]
            u = np.array(list(zip(*coords_1))) #flattens list to combine x and y coords
            v = np.array(list(zip(*coords_2))) #turns into array
            min = 0
            if len(u[0]) >= len(v[0]): #checks the lengths of the arrays 
                min = len(v[0]) #takes the smaller length
                u = u[:,:min] #makes the longer array the length of the shorter array
                print("u=", u)
            elif len(u[0]) <= len(v[0]):
                min = len(u[0])
                v = v[:,:min]
                print("v=", v)
        return directed_hausdorff(u,v)


    
