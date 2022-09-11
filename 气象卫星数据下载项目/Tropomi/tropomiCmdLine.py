# -*- codeing = utf-8 -*-
import datetime
import json
import numpy as np
from shapely.geometry import Polygon
from pytropomi.downs5p import downs5p as downs5pOfficial
from datetime import datetime

debugLocalDownload = True

# api
# http_request = HttpRequest('FIG_HOST')

POLLECTION_FIRLD = {
    'O3': 'ozone_total_vertical_column',
    'HCHO': 'formaldehyde_tropospheric_vertical_column',
    'NO2': 'nitrogendioxide_tropospheric_column',
    'CO': 'carbonmonoxide_total_column',
    'SO2': 'sulfurdioxide_total_vertical_column'
}


class NumpyEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (np.int_, np.intc, np.intp, np.int8,
                            np.int16, np.int32, np.int64, np.uint8,
                            np.uint16, np.uint32, np.uint64)):
            return int(obj)
        elif isinstance(obj, (np.float_, np.float16, np.float32, np.float64)):
            return float(obj)
        elif isinstance(obj, (np.ndarray,)):
            return obj.tolist()
        return json.JSONEncoder.default(self, obj)


class tropomi:
    def __init__(self):
        self.products = ['L2__O3____', 'L2__NO2___', 'L2__SO2___', 'L2__HCHO__', 'L2__CH4__', 'L2__CO____']
        self.polygon = Polygon([(70, 0), (70, 60), (140, 60), (140, 0)])
        self.area = 20  # 需要研究
        self.longitude = 121
        self.latitude = 32
        self.save_path = '/dssg/home/acct-esehazenet/esehazenet/public_dataset/raw/satellite/tropomi'
        if debugLocalDownload:
            self.save_path = './TropomiDownload'

    def run(self):
        sStartDay = input("开始日期:(yyyy dd mm):").split(' ')
        sEndDay = input("结束日期:(yyyy dd mm):").split(' ')
        beginPosition = datetime(int(sStartDay[0]), int(sStartDay[1]), int(sStartDay[2]), 0)
        endPosition = datetime(int(sEndDay[0]), int(sEndDay[1]), int(sEndDay[2]), 23)
        for pro in self.products:
            downs5pOfficial(producttype=pro, longitude=self.longitude, latitude=self.latitude, processingmode='Offline',
                            beginPosition=beginPosition, endPosition=endPosition, savepath=self.save_path)


# 主程序调用
res = tropomi()
res.run()
