#! /usr/bin/env python
from __future__ import division
import cv2
import sys
import logging
import cv
import rospy
from sensor_msgs.msg import Image
from geometry_msgs.msg import Point
from cv_bridge import CvBridge, CvBridgeError
import numpy

logger = logging.getLogger('hr.vision.calibration')

class Tracker(object):
    def __init__(self, node_name):
        rospy.init_node(node_name)
        rospy.on_shutdown(self.cleanup)
        self.node_name = node_name

        self.width = rospy.get_param("~width", 1)
        self.height = rospy.get_param("~height", 1)
        self.depth = rospy.get_param("~depth", 1)
        self.hue_min = rospy.get_param("~hue_min", 20)
        self.hue_max = rospy.get_param("~hue_max", 160)
        self.sat_min = rospy.get_param("~sat_min", 100)
        self.sat_max = rospy.get_param("~sat_max", 255)
        self.val_min = rospy.get_param("~val_min", 200)
        self.val_max = rospy.get_param("~val_max", 256)
        self.input_image = rospy.get_param("~input_image", 'camera/image_raw')
        self.output_image = rospy.get_param("~output_image", 'camera/image_track')
        self.track_point = rospy.get_param("~track_point", 'track_point')
        self.flip_image = rospy.get_param("~flip_image", False)

        self.cv_window_name = self.node_name

        cv.NamedWindow(self.cv_window_name, cv.CV_NORMAL)
        cv.ResizeWindow(self.cv_window_name, 640, 480)

        self.bridge = CvBridge()

        cv.SetMouseCallback (self.node_name, self.on_mouse_click, None)

        self.image_sub = rospy.Subscriber(
            self.input_image, Image, self.image_callback, queue_size=1)
        self.image_pub = rospy.Publisher(self.output_image, Image)
        self.track_point_pub = rospy.Publisher(self.track_point, Point)

        self.channels = {
            'hue': None,
            'saturation': None,
            'value': None,
            'laser': None,
        }

    def on_mouse_click(self, event, x, y, flags, param):
        pass

    def convert_image(self, ros_image):
        """ Convert the raw image to OpenCV format """
        try:
            cv2_image = self.bridge.imgmsg_to_cv2(ros_image, "bgr8")
            cv_image = cv.CreateImageHeader((cv2_image.shape[1], cv2_image.shape[0]), 8, 3)
            cv.SetData(cv_image, cv2_image.tostring(), cv2_image.dtype.itemsize * 3 * cv2_image.shape[1])
            return cv_image, cv2_image
        except CvBridgeError, e:
            logger.error(e)

    def mat2cv_image(self, mat, channel):
        cv_image = cv.CreateImageHeader((mat.shape[1], mat.shape[0]), cv.IPL_DEPTH_8U, channel)
        cv.SetData(cv_image, mat.tostring(), mat.dtype.itemsize * channel * mat.shape[1])
        return cv_image

    def image_callback(self, image):
        start = rospy.Time.now()
        cv2_image = self.bridge.imgmsg_to_cv2(image, "bgr8")
        
        """ Some webcams invert the image """
        if self.flip_image:
            cv.Flip(cv_image)
                    
        width, height, _ = cv2_image.shape
        contours = self.detect(cv2_image)

        if contours:
            cnt = contours[0]
            M = cv2.moments(cnt)
            cx, cy = 0, 0
            if M['m00'] != 0:
                cx = int(M['m10']/M['m00'])
                cy = int(M['m01']/M['m00'])
            else:
                cx = cnt.item(0)
                cy = cnt.item(1)
            
            # xx, yy are the coordinates in new coordinate system with takes
            # the middle of the view as origin
            # |xx| | 1 0 -w/2 | |x|
            # |yy|=| 0 1 h/2  |*|y|
            # |1 | | 0 0  1   | |1|
            xx = cx - width/2
            yy = -cy + height/2
            # x, y are using the pysical unit instead of pixel
            x = xx * self.width/width
            y = yy * self.height/height
            self.track_point_pub.publish(Point(x, y, self.depth))

            x,y,w,h = cv2.boundingRect(cnt)
            cv2.rectangle(cv2_image,(x,y),(x+w,y+h),(0,255,0),2)

        cv2.imshow(self.cv_window_name, cv2_image)
        self.image_pub.publish(self.bridge.cv2_to_imgmsg(cv2_image, "bgr8"))

        cv2.waitKey(10)

    def cleanup(self):
        logger.info("Shutting down vision node.")
        cv.DestroyAllWindows()       

    def threshold_image(self, channel):
        if channel == "hue":
            minimum = self.hue_min
            maximum = self.hue_max
        elif channel == "saturation":
            minimum = self.sat_min
            maximum = self.sat_max
        elif channel == "value":
            minimum = self.val_min
            maximum = self.val_max

        (t, tmp) = cv2.threshold(
            self.channels[channel], # src
            maximum, # threshold value
            0, # we dont care because of the selected type
            cv2.THRESH_TOZERO_INV # type
        )

        (t, self.channels[channel]) = cv2.threshold(
            tmp, # src
            minimum, # threshold value
            255, # maxvalue
            cv2.THRESH_BINARY # type
        )

        if channel == 'hue':
            # only works for filtering red color because the range for the hue is split
            self.channels['hue'] = cv2.bitwise_not(self.channels['hue'])

    def detect(self, frame):
        hsv_img = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)

        # split the video frame into color channels
        h, s, v = cv2.split(hsv_img)
        self.channels['hue'] = h
        self.channels['saturation'] = s
        self.channels['value'] = v

        # Threshold ranges of HSV components; storing the results in place
        self.threshold_image("hue")
        self.threshold_image("saturation")
        self.threshold_image("value")

        # Perform an AND on HSV components to identify the laser!
        self.channels['laser'] = cv2.bitwise_and(
            self.channels['hue'],
            self.channels['value']
        )
        self.channels['laser'] = cv2.bitwise_and(
            self.channels['saturation'],
            self.channels['laser']
        )

        contours, hierarchy = cv2.findContours(
            self.channels['laser'], cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        return contours

if __name__ == '__main__':
    try:   
        Tracker('calibration')
        rospy.spin()
    except KeyboardInterrupt:
        logger.info("Shutting down vision node.")
        cv.DestroyAllWindows()
