# -*- coding: utf-8 -*-
"""
Created on Thu Oct 30 22:12:09 2014

@author: jan
"""


def parse_file(filename):
    f = open(filename, 'r')
    
    x = []
    
    for line in f:
        values = line.split(',')
        
        if(len(values) == 17):
            try:
                int(values[1])
                x.append(int(values[1]))
            except ValueError:
                pass
    
    f.close()
    
    return x
    
def gen_test_signal(y):
    global Fsamp
    
      
    f = open("signal.h","w")
    
    for i in range(len(y)):
        f.write("signal["+str(i)+"] = 16'd"+str(int(y[i]))+";\n")
    f.close()


x = parse_file('dist_05.csv')
gen_test_signal(x[0:10000])