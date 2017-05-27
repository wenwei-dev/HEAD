import numpy as np
import pandas as pd

samples = 15
header = 'Expression,Brow-Outer-L,Brow-Inner-L,Brow-Center,Brow-Inner-R,Brow-Outer-R,Upper-Lid-L,Upper-Lid-R,Lower-Lid-L,LowerLid-R,Sneer-L,Sneer-R,Cheek-Squint-L,Cheek-Squint-R,Upper-Lip-L,Upper-Lip-Center,Upper-Lip-R,Smile_L,Smile_R,EE-R,Frown_R,EE-L,Frown_L,Lower-Lip-L,Lower-Lip-Center,Lower-Lip-R'
col=len(header.split(','))
print col
data = np.random.rand(samples, col)
np.savetxt('motor_data_random.csv', data, delimiter=',', header=header, comments='')


header = 'Expression,Basis,Shrinkwrap,adjustments,brow_center_UP,brow_center_DN,brow_inner_UP.L,brow_inner_DN.L,brow_inner_UP.R,brow_inner_DN.R,brow_outer_UP.L,brow_outer_DN.L,brow_outer_UP.R,brow_outer_DN.R,eye-flare.UP.L,eye-blink.UP.L,eye-flare.UP.R,eye-blink.UP.R,eye-blink.LO.L,eye-flare.LO.L,eye-blink.LO.R,eye-flare.LO.R,wince.L,wince.R,sneer.L,sneer.R,eyes-look.dn,eyes-look.up,lip-UP.C.UP,lip-UP.C.DN,lip-UP.L.UP,lip-UP.L.DN,lip-UP.R.UP,lip-UP.R.DN,lips-smile.L,lips-smile.R,lips-wide.L,lips-narrow.L,lips-wide.R,lips-narrow.R,lip-DN.C.DN,lip-DN.C.UP,lip-DN.L.DN,lip-DN.L.UP,lip-DN.R.DN,lip-DN.R.UP,lips-frown.L,lips-frown.R,lip-JAW.DN,jaw'
col=len(header.split(','))
print col
data = np.random.rand(samples, col)
np.savetxt('pau_values_random.csv', data, delimiter=',', header=header, comments='')
