from scipy.optimize import minimize
import matplotlib.pyplot as plt
import pandas as pd
import yaml

def find_params(motor_name):
    with open('motors_settings.yaml') as f:
        motor_config = yaml.load(f)

    motor = [motor for motor in motor_config if motor['name'] == motor_name][0]
    shapekeys = motor['parser_param'].split(';')

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
        mse = ((sum.sum(axis=1)-targets)**2).sum()
        print mse
        return mse

    def fun2(x, shapekey_values, targets):
        '''
            fun = a*x_1^2 + b*x_2^2 + c*x_1 + d*x_2 + e
        '''
        chunk = (len(x)-1)/2
        sum = x[:chunk]*(shapekey_values**2)+x[chunk:2*chunk]*shapekey_values + x[-1]
        mse = ((sum.sum(axis=1)-targets)**2).sum()
        print mse
        return mse

    res = minimize(fun, [1]*param_num+[0], args=(shapekey_values, targets), method='Nelder-Mead', tol=1e-9)
    #res = minimize(fun2, [1]*param_num+[1]*param_num+[0], args=(shapekey_values, targets), method='Nelder-Mead', tol=1e-9)
    print res
    return res

def evaluate_params(motor_name, x):
    with open('motors_settings.yaml') as f:
        motor_config = yaml.load(f)

    motor = [motor for motor in motor_config if motor['name'] == motor_name][0]
    shapekeys = motor['parser_param'].split(';')

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

motor_name = 'Upper-Lip-L'
res = find_params(motor_name)
print res.x

evaluate_params(motor_name, res.x)
