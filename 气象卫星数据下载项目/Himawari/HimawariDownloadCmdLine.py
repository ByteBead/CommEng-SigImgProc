# -*- codeing = utf-8 -*-
# 可以部署在日本的服务器上，下载速度很快

import ftplib
import json
import os
import time
import numpy as np

debugLocalDownload = True
debugDownloadDaily = False

globPersonalTime = [2022, 9, 7]

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


class himawari:
    ftp = ftplib.FTP()

    def __init__(self):
        self._url = '/pub/himawari/L3/ARP/031/'
        self._save_path = '/dssg/home/acct-esehazenet/esehazenet/public_dataset/raw/satellite/himawari/'
        if debugLocalDownload:
            self._save_path = './Download/'
        self.ftp.connect('ftp.ptree.jaxa.jp', 21)
        self.ftp.login('abltht1994_163.com', 'SP+wari8')
        self._yearNum, self._monNum, self._dayNum = self.dayInit()
        self._nginx_path = ''
        print(self.ftp.welcome)  # 显示登录信息

    def run(self):
        self._nginx_path = ''

        try:
            if debugDownloadDaily:
                self._yearNum, self._monNum, self._dayNum = self.getYesterday(self._yearNum, self._monNum, self._dayNum)
            else:
                self._yearNum = globPersonalTime[0]
                self._monNum = globPersonalTime[1]
                self._dayNum = globPersonalTime[2]
            self._yearStr, self._monStr, self._dayStr = self.getDateStr(self._yearNum, self._monNum, self._dayNum)
            ftp_filePath = self._url + self._yearStr + self._monStr + "/" + self._dayStr + "/"
            # 从目标路径ftp_filePath将文件下载至本地路径dst_filePath
            dst_filePath = self._nginx_path + self._save_path + self._yearStr + "/" + self._monStr + "/" + self._dayStr + "/" + "hour" + "/"
            self.deleteFile(dst_filePath)  # 先删除未下载完成的临时文件
            print("Local:" + dst_filePath)
            print("Remote:" + ftp_filePath)
            self.DownLoadFileTree(dst_filePath, ftp_filePath)
            if debugDownloadDaily:
                self.ftp.quit()
        except Exception as err:
            print(err)

    def getYesterday(self, yy, mm, dd):
        dt = (yy, mm, dd, 9, 0, 0, 0, 0, 0)
        dt = time.mktime(dt) - 86400
        yesterdayList = time.strftime("%Y-%m-%d", time.localtime(dt)).split('-')
        return int(yesterdayList[0]), int(yesterdayList[1]), int(yesterdayList[2])

    def dayInit(self, ):
        yesterdayList = time.strftime("%Y-%m-%d", time.localtime(time.time())).split('-')
        return int(yesterdayList[0]), int(yesterdayList[1]), int(yesterdayList[2])

    def getDateStr(self, yy, mm, dd):
        syy = str(yy)
        smm = str(mm)
        sdd = str(dd)
        if mm < 10:
            smm = '0' + smm
        if dd < 10:
            sdd = '0' + sdd
        return syy, smm, sdd

    # 删除目录下扩展名为.temp的文件
    def deleteFile(self, fileDir):
        if os.path.isdir(fileDir):
            targetDir = fileDir
            for file in os.listdir(targetDir):
                targetFile = os.path.join(targetDir, file)
                if targetFile.endswith('.temp'):
                    os.remove(targetFile)

    # 下载单个文件，LocalFile表示本地存储路径和文件名，RemoteFile是FTP路径和文件名
    def DownLoadFile(self, LocalFile, RemoteFile):
        bufSize = 102400
        file_handler = open(LocalFile, 'wb')
        print(file_handler)
        # 接收服务器上文件并写入本地文件
        self.ftp.retrbinary('RETR ' + RemoteFile, file_handler.write, bufSize)
        self.ftp.set_debuglevel(0)
        file_handler.close()
        return True

    # 下载整个目录下的文件，LocalDir表示本地存储路径， emoteDir表示FTP路径
    def DownLoadFileTree(self, LocalDir, RemoteDir):
        # 如果本地不存在该路径，则创建
        if not os.path.exists(LocalDir):
            os.makedirs(LocalDir)
            # 获取FTP路径下的全部文件名，以列表存储
        self.ftp.cwd(RemoteDir)
        RemoteNames = self.ftp.nlst()
        RemoteNames.reverse()
        # print("RemoteNames：", RemoteNames)
        for file in RemoteNames:
            # 先下载为临时文件Local,下载完成后再改名为nc4格式的文件
            # 这是为了防止上一次下载中断后，最后一个下载的文件未下载完整，而再开始下载时，程序会识别为已经下载完成
            Local = os.path.join(LocalDir, file[0:-3] + ".temp")
            files = file[0:-3] + ".nc"
            LocalNew = os.path.join(LocalDir, files)
            '''
            下载小时文件，只下载UTC时间0时至24时（北京时间0时至24时）的文件
            下载的文件必须是nc格式
            若已经存在，则跳过下载
            '''
            # 小时数据命名格式示例：H08_20200819_0700_1HARP030_FLDK.02401_02401.nc
            if int(file[13:15]) >= 0 and int(file[13:15]) <= 24:
                if not os.path.exists(LocalNew):
                    #print("Downloading the file of %s" % file)
                    self.DownLoadFile(Local, file)
                    os.rename(Local, LocalNew)
                    print("The download of the file of %s has finished\n" % file)
                    #print("png of the file of %s has finished\n" % png_name)
                elif os.path.exists(LocalNew):
                    print("The file of %s has already existed!\n" % file)
        self.ftp.cwd("..")
        return


# 主程序
myftp = himawari()
if debugDownloadDaily:
    myftp.run()
else:
    yyStart, mmStart, ddStart = input("Start(yy mm dd):").split()
    yyStart, mmStart, ddStart = int(yyStart), int(mmStart), int(ddStart)
    yyEnd, mmEnd, ddEnd = input("End(yy mm dd):").split()
    yyEnd, mmEnd, ddEnd = int(yyEnd), int(mmEnd), int(ddEnd)
    dtStart = (yyStart, mmStart, ddStart, 9, 0, 0, 0, 0, 0)
    dtEnd = (yyEnd, mmEnd, ddEnd, 10, 0, 0, 0, 0, 0)
    timeIndex = time.mktime(dtStart)
    timeIndexEnd = time.mktime(dtEnd)
    while timeIndex < timeIndexEnd:
        indexDayList = time.strftime("%Y-%m-%d", time.localtime(timeIndex)).split('-')
        globPersonalTime[0] = int(indexDayList[0])
        globPersonalTime[1] = int(indexDayList[1])
        globPersonalTime[2] = int(indexDayList[2])
        print(globPersonalTime)
        myftp.run()
        timeIndex = int(timeIndex) + 3600 * 24
