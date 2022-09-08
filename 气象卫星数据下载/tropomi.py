# -*- codeing = utf-8 -*-
import os
import ftplib
import time
import urllib.request
import ssl
import json
import urllib, os, sys, time
import numpy as np
import netCDF4
import math, hashlib
from shapely.geometry import Polygon
import datetime
#import https
import pytropomi
from pytropomi.s5p import s5p

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
            self.save_path = './testDownloadTropomi'
    def run(self):
        self.start_day = datetime.datetime.strptime("2021-01-26", "%Y-%m-%d")  # 开始日期，日期选择
        self.end_day = datetime.datetime.strptime("2021-10-31", "%Y-%m-%d")  # 结束日期，日期选择
        for pro in self.products:
            # self.downs5p(pro)
            self.downs5p(pro)

    def downs5p(self, pro):
        sp = s5p(username=None, password=None, login_headers=None, login_data=None,
                 platformname='Sentinel-5', producttype=pro, processinglevel=None,
                 beginPosition=self.start_day, endPosition=self.end_day, beginIngestionDate=None,
                 endIngestionDate=None, processingmode='Offline', orbitnumber=None,
                 offset=0, limit=25, sortedby='ingestiondate', order='desc', product_header=None)
        login = sp.login()
        if login:
            print('login successfully!')
        sfs = list(
            sp.search(polygon=self.polygon, area=self.area, longitude=self.longitude, latitude=self.latitude))  # 需要调研
        print('The total number of file indexed is {0}.'.format(sp.totalresults))
        for i in range(1, math.ceil(sp.totalresults / sp._limit + 1)):
            for sg in sfs:
                files = sg[2]
                LocalNew = os.path.join(self.save_path, files)
                # 生成图片名称
                png_name = sg[2].replace('nc', 'png')
                png_save_path = os.path.join(self.save_path, png_name)
                print('now, download {0}, the total size of file is {1}.'.format(sg[2], sg[3]))
                while True:
                    res = sp.download(sg[1], filename=files, savepath=self.save_path, chunk_size=1024)
                    print('###########################################')
                    print(res)
                    print('###########################################')
                    if res:
                        break
                print('下载成功 {0}'.format(sg[2]))
                # 通过文件获取时间数组
                lists = [i for i in files.split('_') if i != '']
                timeArray = time.strptime(lists[4], "%Y%m%dT%H%M%S")
                print(timeArray)
                print(lists)
                pollution = lists[3]
                # nc文件转为png文件
                self.tropomi_nc_to_png(LocalNew, png_save_path, pollution)
                print("png of the file of %s has finished\n" % png_name)
            print('searching from page {0}...'.format(i + 1))
            sfs = sp.next_page(offset=i * sp._limit)

    def tropomi_nc_to_png(input_file, png_save_path, pollution):  ##
        # 读取一下基本信息
        nc_data_obj = netCDF4.Dataset(input_file)
        # 去nc文件中group数组
        Lon = nc_data_obj.groups['PRODUCT'].variables['longitude'][:][0, :, :]
        Lat = nc_data_obj.groups['PRODUCT'].variables['latitude'][:][0, :, :]
        AOD_arr = np.asarray(nc_data_obj.groups['PRODUCT'].variables[POLLECTION_FIRLD[pollution]][0, :, :])
        # 这个循环将所有Nodata的值（即9.96921e+36）全部改为0
        for i in range(len(AOD_arr)):
            for j in range(len(AOD_arr[0])):
                if AOD_arr[i][j] == 9.969209968386869e+36:
                    AOD_arr[i][j] = -9999.0
        LonMin, LatMax, LonMax, LatMin = [Lon.min(), Lat.max(), Lon.max(), Lat.min()]
        AOD_arr = AOD_arr.tolist()
        try:
            params = {
                "styleType": "inventory_tropomi",
                "xMin": LatMin,
                "yMin": LonMin,
                "xMax": LatMax,
                "yMax": LonMax,
                "data": AOD_arr,
                "sourceCRS": "EPSG:4326",
                "targetCRS": "EPSG:3857",
                "scale": 1,
                "width": 2000,
            }
            params = json.dumps(params, cls=NumpyEncoder)
            headers = {'Content-Type': 'application/json'}
            # result = http_request.png_capture('fig/gen/', 'POST', params, headers, png_save_path)
            return LonMin, LatMax, LonMax, LatMin
        except Exception as err:
            raise Exception("nc文件生成png服务失败: {}".format(repr(err)))


# 主程序调用
res = tropomi()
res.run()
