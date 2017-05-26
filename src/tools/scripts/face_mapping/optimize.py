from scipy.optimize import minimize
import matplotlib.pyplot as plt
import pandas as pd
import yaml

def find_params(motor_name):
    with open('motors_settings.yaml') as f:
        motor_config = yaml.load(f)

    motor = [motor for motor in motor_config if motor['name'] == motor_name][0]
    #shapekeys = motor['parser_param'].split(';')
    shapekeys = ["brow_center_UP", "brow_center_DN", "brow_inner_UP.L", "brow_inner_DN.L", "brow_inner_UP.R", "brow_inner_DN.R", "brow_outer_UP.L", "brow_outer_DN.L", "brow_outer_UP.R", "brow_outer_DN.R", "eye-flare.UP.L", "eye-blink.UP.L", "eye-flare.UP.R", "eye-blink.UP.R", "eye-blink.LO.L", "eye-flare.LO.L", "eye-blink.LO.R", "eye-flare.LO.R", "wince.L", "wince.R", "sneer.L", "sneer.R", "eyes-look.dn", "eyes-look.up", "lip-UP.C.UP", "lip-UP.C.DN", "lip-UP.L.UP", "lip-UP.L.DN", "lip-UP.R.UP", "lip-UP.R.DN", "lips-smile.L", "lips-smile.R", "lips-wide.L", "lips-narrow.L", "lips-wide.R", "lips-narrow.R", "lip-DN.C.DN", "lip-DN.C.UP", "lip-DN.L.DN", "lip-DN.L.UP", "lip-DN.R.DN", "lip-DN.R.UP", "lips-frown.L", "lips-frown.R", "lip-JAW.DN"]

    motor_data = pd.read_csv('motor_data.csv')
    targets = motor_data[motor_name]
    targets = (targets - motor['init'])/(motor['max'] - motor['min'])

    pau_values = pd.read_csv('pau_values.csv')
    shapekey_values = pau_values[shapekeys]
    param_num = shapekey_values.shape[1]

    def fun(x, shapekey_values, targets):
        '''
            fun = a*x_1 + b*x_2 + c
        '''
        sum = x[:param_num]*shapekey_values + x[-1]
        diff = sum.sum(axis=1)-targets
        mse = (diff**2).sum()
        print mse
        return mse

    res = minimize(fun, [0.5]*param_num+[0], args=(shapekey_values, targets), method='Nelder-Mead', tol=1e-15, options={'disp': True})
    return res

def evaluate_params(motor_name, x):
    with open('motors_settings.yaml') as f:
        motor_config = yaml.load(f)

    motor = [motor for motor in motor_config if motor['name'] == motor_name][0]
    #shapekeys = motor['parser_param'].split(';')
    shapekeys = ["brow_center_UP", "brow_center_DN", "brow_inner_UP.L", "brow_inner_DN.L", "brow_inner_UP.R", "brow_inner_DN.R", "brow_outer_UP.L", "brow_outer_DN.L", "brow_outer_UP.R", "brow_outer_DN.R", "eye-flare.UP.L", "eye-blink.UP.L", "eye-flare.UP.R", "eye-blink.UP.R", "eye-blink.LO.L", "eye-flare.LO.L", "eye-blink.LO.R", "eye-flare.LO.R", "wince.L", "wince.R", "sneer.L", "sneer.R", "eyes-look.dn", "eyes-look.up", "lip-UP.C.UP", "lip-UP.C.DN", "lip-UP.L.UP", "lip-UP.L.DN", "lip-UP.R.UP", "lip-UP.R.DN", "lips-smile.L", "lips-smile.R", "lips-wide.L", "lips-narrow.L", "lips-wide.R", "lips-narrow.R", "lip-DN.C.DN", "lip-DN.C.UP", "lip-DN.L.DN", "lip-DN.L.UP", "lip-DN.R.DN", "lip-DN.R.UP", "lips-frown.L", "lips-frown.R", "lip-JAW.DN"]

    motor_data = pd.read_csv('motor_data.csv')
    targets = motor_data[motor_name]
    targets = (targets - motor['init'])/(motor['max'] - motor['min'])

    pau_values = pd.read_csv('pau_values.csv')
    shapekey_values = pau_values[shapekeys]
    param_num = shapekey_values.shape[1]

    
    sum = x[:param_num]*shapekey_values + x[-1]
    values = sum.sum(axis=1)
    #values = values*(motor['max'] - motor['min'])+motor['init']

    error = targets-values
    print error
    print 'mse', (error**2).sum()

    fig, ax = plt.subplots()
    ax.plot(range(targets.size), targets, label='target')
    ax.plot(range(values.size), values, label='value')
    ax.legend(loc='lower right')
    plt.show()

motor_names = ["Brow-Outer-L", "Brow-Inner-L", "Brow-Center", "Brow-Inner-R", "Brow-Outer-R", "Upper-Lid-L", "Upper-Lid-R", "Lower-Lid-L", "LowerLid-R", "Sneer-L", "Sneer-R", "Cheek-Squint-L", "Cheek-Squint-R", "Upper-Lip-L", "Upper-Lip-Center", "Upper-Lip-R", "Smile_L", "Smile_R", "EE-R", "Frown_R", "EE-L", "Frown_L", "Lower-Lip-L", "Lower-Lip-Center", "Lower-Lip-R"]
motor_name = 'Upper-Lip-R'

res = find_params(motor_name)
print res.x

evaluate_params(motor_name, res.x)
