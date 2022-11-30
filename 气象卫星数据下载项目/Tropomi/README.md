Sentinel-5P是欧空局于2017年10月13日发射的一颗全球大气污染监测卫星。卫星搭载了对流层观测仪（Tropospheric Monitoring Instrument，TROPOMI），可以有效的观测全球各地大气中痕量气体组分，包括NO2、O3、SO2、 HCHO、CH4和CO等重要的与人类活动密切相关的指标，加强了对气溶胶和云的观测。

<img src="https://www.itrefer.com/pictureBed/2022/11/25_Screenshot-2022-11-25%2011.09.58.png" alt="Sentinel-5P" style="zoom:100%;" />

## 项目简介

-   本项目旨在维护一个TROPOMI卫星数据自动下载程序。以实现下载特定时间段数据的功能。
-   本项目实现了指定日期范围，指定气体列表的下载，仅NC文件。
-   本程序有一个全局调试变量。

| 全局变量           | True           | False                | 配置变量        |
| ------------------ | -------------- | -------------------- | --------------- |
| debugLocalDownload | 下载到本地目录 | 下载到服务器指定目录 | self._save_path |

-   本程序有两个版本

    -   HimawariDownloadBulitIn的时间变量写在程序内部，运行前需手动修改，适用于超算节点。
    -   HimawariDownloadCmdLine的时间变量通过命令行输入，适用于登陆节点。

## 程序

```python
# -*- codeing = utf-8 -*-
import datetime
import json
import numpy as np
from shapely.geometry import Polygon
from pytropomi.downs5p import downs5p as downs5pOfficial
from datetime import datetime

debugLocalDownload = True

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
        self.save_path = './Your_save_path'
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
```

## 相关链接

1.[官方项目](https://github.com/bugsuse/pytropomi)
