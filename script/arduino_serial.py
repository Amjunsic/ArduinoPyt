import serial

class arduino_serial :
    def __init__(self, port, baudrate=9600, timeout=1):
        self.__ser = serial.Serial(
            port= port,
            baudrate=baudrate,
            timeout=timeout
        )
        print(f"Setup serial, port = {port} baudrate = {baudrate}, timeout = {timeout}")

    def write(self, data):
        if isinstance(data, str):
            data = data.encode('utf-8')
        self.__ser.write(data)
        print(f"Sent: {data}")

    def read(self):
        data = self.__ser.readline()
        print(data)
    
