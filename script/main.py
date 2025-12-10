from arduino_serial import *
from path_finder import *
import os
import cv2
import time

def main():
    # pipeline = "libcamerasrc ! video/x-raw,width=640,height=480,framerate=30/1 ! videoconvert ! appsink"
    # cap = cv2.VideoCapture(pipeline, cv2.CAP_GSTREAMER)

    # print("카메라 열림 여부:", cap.isOpened())
    # ret, frame = cap.read()
    # print("프레임 읽기 성공:", ret)
    print(cv2.getBuildInformation())

    while(True):
        time.sleep(60)
    

if __name__ == "__main__":
    main()