# -*- coding: utf-8 -*-
"""
///////////////////////////////////////////////////////////////////////////////
//   __  __          _____      _         _   _  ______      _______ _____   //
//  |  \/  |   /\   |  __ \    | |  /\   | \ | |/ __ \ \    / /_   _/ ____|  //
//  | \  / |  /  \  | |__) |   | | /  \  |  \| | |  | \ \  / /  | || |       //
//  | |\/| | / /\ \ |  _  /_   | |/ /\ \ | . ` | |  | |\ \/ /   | || |       //
//  | |  | |/ ____ \| | \ \ |__| / ____ \| |\  | |__| | \  /   _| || |____   //
//  |_|  |_/_/    \_\_|  \_\____/_/    \_\_| \_|\____/   \/   |_____\_____|  //
//                                                                           //
//                          JAN MARJANOVIC, 2014                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
"""

import scipy.signal as sig
import math
import matplotlib.pyplot as plt
import numpy as np


# 1 bit sign, 7 bits integer, 24 bit fraction
_bits_int  = 7
_bits_frac = 24
_bits = _bits_int + _bits_frac + 1

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
   
###############################################################################
def quantize(val):
    if val > 255 or val < -255:
        raise error('Invalid value')
        
    val *= 2**_bits_frac
    val = round(val)
    val /= 2**_bits_frac
    
    return val
    
def to_bits(d):
    if d > 0:
        hexStr = hex(int(d*2**_bits_frac))
    if d < 0:
        d = int(-d*2**_bits_frac)
        d ^= 2**(_bits)-1
        d += 1
        hexStr = hex(d)
    
    print hexStr
    hexStr = hexStr[2:]
    nib = int(math.ceil(_bits/4.))
    
    print "nib", nib
    print "len", len(hexStr)
    hexStr = "0"*(nib-len(hexStr)) + hexStr
    
    return str(_bits)+"'h"+hexStr
    
        
        
###############################################################################
def plot_step_response(a,b):                
    
    aq = [quantize(ai) for ai in a]
    bq = [quantize(bi) for bi in b]
    
    T = np.linspace(0,1,Fsamp)
    u = [0.25] * (len(a)-1+int(Fsamp))
    y = [0] * (len(a)-1+int(Fsamp))
    yq = [0] * (len(a)-1+int(Fsamp))
        
    for i in range(len(a),len(a)-1+int(Fsamp)):
        ya = 0
        yb = 0
        for j in range(1,len(a)):
            ya += a[j]*y[i-j]
        
        for j in range(len(b)):
            yb += b[j]*u[i-j]
        
        y[i] = yb - ya
    
    plt.plot(y)
    
    
    for i in range(len(a),len(u)):
        ya = 0
        yb = 0
        for j in range(1,len(aq)):
            ya += quantize(-aq[j]*yq[i-j])
            ya = quantize(ya)
        
        for j in range(len(bq)):
            ya += quantize(bq[j]*u[i-j])
            ya = quantize(ya)
                
        yq[i] = quantize(ya)
    
    plt.plot(yq)



###############################################################################
def gen_a_b_str(a,b):
    a_str = ""
    a = a[1:] # first one is 1. (y[i])
    for ai in a:
        a_str += ", " + to_bits(-ai)
        
    a_str = a_str[1:]
    
    b_str = ""
    for bi in b:
        b_str += ", " + to_bits(bi)
        
    b_str = b_str[1:]
    
    return a_str, b_str
        

def gen_verilog_filter():
    print "Generating SystemVerilog filter"
    

###############################################################################
def gen_test_signal():
    global Fsamp
    
    T = np.linspace(0,1,Fsamp)
    y = 2000*(np.sin(2*math.pi*5.0*T) + np.sin(2*math.pi*50.0*T) +np.sin(2*math.pi*3000.0*T))+6000
    
    f = open("signal.h","w")
    
    for i in range(len(y)):
        f.write("signal["+str(i)+"] = 16'd"+str(int(y[i]))+";\n")
    f.close()
    
if __name__ == '__main__':
    plot_step_response(a,b)
    
    sel = raw_input("Generate filter[y/N]?")
    
    if sel[0].lower() == 'y':
        gen_verilog_filter()