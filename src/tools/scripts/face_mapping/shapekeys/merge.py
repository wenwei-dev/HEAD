import pandas as pd
import glob
import os

import rospy
from blender_api_msgs.srv import SetParam, GetParam

get_param = rospy.ServiceProxy('/blender_api/get_param', GetParam)

def get_shape_keys():
    from collections import OrderedDict
    shape_keys = eval(get_param("self.getFaceData()").value).keys()
    return shape_keys

shapekeys = get_shape_keys()

dfs = []
for f in glob.glob('*.csv'):
    if f == 'merged.csv':
        continue
    expression = os.path.splitext(f)[0]
    df = pd.read_csv(f, header=None, dtype='str')
    df.columns = shapekeys
    df['Expression'] = expression
    dfs.append(df)
df = pd.concat(dfs)

df.to_csv('merged.csv', columns=['Expression']+shapekeys, index=False)
