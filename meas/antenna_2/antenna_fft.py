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



files = ['dist_05.csv']

for i in range(len(files)):
    filename = files[i]
    Ts = 10000/100e6
    fs = 1/Ts
    x = parse_file(filename)
    M = np.abs( np.fft.fft(x - np.mean(x)))
    f = np.linspace(fs/len(x), fs, len(x))
    
    plt.subplot(len(files),1,i)
    plt.plot(f, M)
    plt.grid('on')
    plt.xlabel('Frequency [Hz]')
