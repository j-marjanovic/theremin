# -*- coding: utf-8 -*-
"""
Created on Fri Oct 31 09:05:17 2014

@author: jan
"""
import numpy as np
import matplotlib.pyplot as plt

"""
timeMean = [33.517960521726998, 32.930180651461257, 32.576968682430078, 
            32.365697147241406, 32.205482318476669, 32.035642045058239, 
            31.908000278998397, 31.825765501848366, 31.765222849968612, 
            31.647067029364582, 31.573341703285205, 31.497244890841877, 
            31.429936527864964, 31.364860152054124, 31.359349933737882, 
            31.348747994699032, 31.315686684801562, 31.33165934295878, 
            31.292529817953547]

y = np.array(timeMean[::-1]) * 100e6/1e6 -3100
y = np.log(y-3100)

plt.plot(y)
"""

def gen_antilog_lut(in_bits, out_bits):
    x = range(2**in_bits)

    y = [0] + np.log(x[1:])
    m = np.max(y)
    y *= (2**out_bits-1)/m

    y = [int(yi) for yi in y]
    
    f = open('antilog_lut_init.txt', 'w')

    for yi in y:
        f.write(hex(yi)[2:]+'\n')
    
    f.close()
    
    
y = gen_antilog_lut(9,12)
    
    
