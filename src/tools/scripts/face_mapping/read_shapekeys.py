import rospy
from pau2motors.msg import pau

def cb(msg):
    print msg.m_coeffs
    with open('shapekey.csv', 'w') as f:
        f.write(','.join(map(str, msg.m_coeffs)))

rospy.init_node('read_shapekeys')
rospy.Subscriber('/blender_api/get_pau', pau, cb)

rospy.spin()
