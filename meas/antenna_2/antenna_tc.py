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

import os
import numpy as np
import matplotlib.pyplot as plt


files = [f for f in os.listdir('.') if f[0:4] == 'dist']


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


files.sort()    

timeMean = []
timeStdP = []
timeStdN = []
timeMin  = []
timeMax  = []
dist = []

for filename in files:
    dist.append( filename.split('_')[1].replace('.csv','') )
    x = parse_file(filename)
    x = np.array(x)
    x /= 100e6/1e6
    timeMean.append( np.mean(x) )
    timeStdP.append( np.mean(x) + np.std(x))
    timeStdN.append( np.mean(x) - np.std(x))
    timeMin.append( np.min(x) )
    timeMax.append( np.max(x) )


plt.plot(dist, timeMean, 'o')
plt.plot(dist, timeStdN, 'g')    
plt.plot(dist, timeStdP, 'g')  
plt.plot(dist, timeMin, 'k--')  
plt.plot(dist, timeMax, 'k--')  


plt.grid('on')
plt.xlabel('Distance hand-antenna [cm]')
plt.ylabel('Time constant [us]')




