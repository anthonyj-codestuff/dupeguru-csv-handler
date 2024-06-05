import sys
import os
import datetime
import struct
import json
import platform

def unix_to_datetime(unix_timestamp):
    dt_object = datetime.datetime.fromtimestamp(unix_timestamp)
    formatted_datetime = dt_object.strftime('%Y/%m/%d %H:%M:%S')
    return formatted_datetime

def get_modification_date(file_path):
    modification_time = round(os.path.getmtime(file_path))
    return modification_time

def get_creation_date(filePath):
    currentOS = platform.system()
    if currentOS == "Windows":
        return round(os.path.getctime(filePath))
    elif currentOS == "Darwin":
        stat = os.stat(filePath)
        try:
            return round(stat.st_birthtime)
        except AttributeError:
            return
    elif currentOS == "Linux":
       # OS is Linux, no creation date available
        return

def get_file_properties(file_path):
    properties = {}

    # Getting file creation and modification datetime
    if os.path.exists(file_path):
        creation_time = get_creation_date(file_path)
        properties['creationDateUnix'] = creation_time
        properties['creationDateReadable'] = str(unix_to_datetime(creation_time))
        modification_time = get_modification_date(file_path)
        properties['modificationDateUnix'] = modification_time
        properties['modificationDateReadable'] = str(unix_to_datetime(modification_time))

        # Checking if it's an image to get image dimensions
        if any(file_path.endswith(ext) for ext in ['.jpg', '.jpeg', '.png', '.bmp', '.gif']):
            try:
                with open(file_path, 'rb') as img_file:
                    img_file.seek(0)
                    header = img_file.read(24)
                    if header.startswith(b'\x89PNG\r\n\x1a\n'):
                        width, height = struct.unpack('>LL', header[16:24])
                        properties['imageWidth'] = width
                        properties['imageHeight'] = height
                        properties['imageDimensionsReadable'] = "%s x %s" % (width, height)
                    elif header.startswith(b'\xff\xd8'):
                        img_file.seek(0)
                        img_file.read(2)
                        b = img_file.read(1)
                        while b and ord(b) != 0xDA:
                            while ord(b) != 0xFF:
                                b = img_file.read(1)
                            while ord(b) == 0xFF:
                                b = img_file.read(1)
                            if ord(b) >= 0xC0 and ord(b) <= 0xC3:
                                img_file.read(3)
                                height, width = struct.unpack('>HH', img_file.read(4))
                                properties['imageWidth'] = width
                                properties['imageHeight'] = height
                                properties['imageDimensionsReadable'] = "%s x %s" % (width, height)
                                break
                            else:
                                img_file.read(int(struct.unpack('>H', img_file.read(2))[0]) - 2)
                            b = img_file.read(1)
            except Exception as e:
                sys.exit(1)
    print(json.dumps(properties))

if __name__ == "__main__":
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
        try:
            get_file_properties(file_path)
        except Exception as e:
            sys.exit(1)
