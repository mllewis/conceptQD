# -*- coding: utf-8 -*-
"""
Created on Thu Aug 24 2017

@author: Molly
"""

from hausdorff import hausdorff_distance

# Wrapper around hausdorff distance for R
def hausdorff_wrapper(A, B):

    # this is some weird thing to prevent a C_Contiguous error
    # https://stackoverflow.com/questions/26778079/valueerror-ndarray-is-not-c-contiguous-in-cython
    #A = A.copy(order='C')
    #B = B.copy(order='C')

    dist = hausdorff_distance(A.astype(float), B.astype(float))

    return(dist)