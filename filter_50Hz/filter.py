# -*- coding: utf-8 -*-
"""
Created on Sun Oct 19 20:31:26 2014

@author: jan
"""

import scipy.signal as sig
import math
import matplotlib.pyplot as plt
import numpy as np


Fsamp = 10000.
Ts = 1.0/Fsamp
Fpass = 15.
Fstop = 40.
gpass = 0.1
gstop = 20

b,a = sig.iirdesign(wp = Fpass/(Fsamp/2.0),
                    ws = Fstop/(Fsamp/2.0),
                    gpass = gpass,
                    gstop = gstop,
                    analog = False)
                    
T = np.linspace(0,1,Fsamp)
"""y = sig.dstep((b,a, Ts) , t=T)

y1 = []
for i in range(len(y[1][0])):
    y1.append(y[1][0][i][0])

#plt.plot(y[0],y1)
"""

u = [0.25] * (len(a)-1+int(Fsamp))
y = [0] * (len(a)-1+int(Fsamp))

u[0] = 0
u[1] = 0
u[2] = 0
u[3] = 0
u[4] = 0
u[5] = 0
u[6] = 0

for i in range(len(a),len(a)-1+int(Fsamp)):
    ya = 0
    yb = 0
    for j in range(1,len(a)):
        ya += a[j]*y[i-j]
    
    for j in range(len(b)):
        yb += b[j]*u[i-j]
    
    y[i] = yb - ya


plt.plot(y)


# 1 bit sign, 7 bits integer, 8 bit fraction
_bits_int  = 7
_bits_frac = 24
_bits = _bits_int + _bits_frac

def quantize(val):
    if val > 255 or val < -255:
        raise error('Invalid value')
        
    val *= 2**_bits_frac
    val = round(val)
    val /= 2**_bits_frac
    
    return val
    
def to_bits(val):
    if val > 0:
        return hex(int(val*2**_bits_frac))
    if val < 0:
        val = int(-val*2**_bits_frac)
        val ^= 2**(_bits+1)-1
        val += 1
        return hex(val)
    
    
    
aq = [quantize(ai) for ai in a]
bq = [quantize(bi) for bi in b]



yq = [0] * (len(a)-1+int(Fsamp))

for i in range(len(a),len(u)):
    ya = 0
    yb = 0
    for j in range(1,len(aq)):
        ya += quantize(-aq[j]*yq[i-j])
        ya = quantize(ya)
    
    for j in range(len(bq)):
        ya += quantize(bq[j]*u[i-j])
        ya = quantize(ya)
            
    #print "yb", yb
    #print quantize(yb + ya)
    yq[i] = quantize(ya)

plt.plot(yq)


def gen_verilog_filter(a,b,fSamp,fClk,inBits, outBits):
    pass

def gen_test_signal():
    global Fsamp
    
    T = np.linspace(0,1,Fsamp)
    y = 2000*(np.sin(2*math.pi*5.0*T) + np.sin(2*math.pi*50.0*T) +np.sin(2*math.pi*3000.0*T))+6000
    
    f = open("signal.h","w")
    
    for i in range(len(y)):
        f.write("signal["+str(i)+"] = 16'd"+str(int(y[i]))+";\n")
    f.close()
    
#gen_test_signal()