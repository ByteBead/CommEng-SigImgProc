from __future__ import division
import zoneChange
import sys
import time
import os
import xml.dom.minidom as minidom
import win32api
import win32security

REMOTE_TARGET_USER = ''
REMOTE_TARGET_PWD = ''
REMOTE_TARGET_HOST = ''
REMOTE_TARGET_UPLOAD_PATH = ''
REMOTE_TARGET_INSTALL_PARAMETER = ''
INSTALL_LOG_PATH = ''
zone_path = '/usr/share/zoneinfo/Etc/'


def get_attrvalue(node, attrname):
    return node.getAttribute(attrname) if node else ''


def get_nodevalue(node, index=0):
    return node.childNodes[index].nodeValue if node else ''


def get_xmlnode(node, name):
    return node.getElementsByTagName(name) if node else []


def xml_to_string(filename='user.xml'):
    doc = minidom.parse(filename)
    return doc.toxml('UTF-8')


# -------------------------------------------------------------------------------------------
def read_configxml(text):
    global REMOTE_TARGET_HOST
    global REMOTE_TARGET_UPLOAD_PATH
    global REMOTE_TARGET_USER
    global REMOTE_TARGET_PWD
    global INSTALL_LOG_PATH
    global REMOTE_TARGET_INSTALL_PARAMETER

    try:
        dom = minidom.parse(text)
        root = dom.documentElement
        node = get_xmlnode(root, 'LoginUser')
        REMOTE_TARGET_USER = str(get_nodevalue(node[0]).encode('utf-8', 'ignore'))
        node = get_xmlnode(root, 'Password')
        REMOTE_TARGET_PWD = str(get_nodevalue(node[0]).encode('utf-8', 'ignore'))
        node = get_xmlnode(root, 'HostName')
        REMOTE_TARGET_HOST = str(get_nodevalue(node[0]).encode('utf-8', 'ignore'))
        node = get_xmlnode(root, 'UploadPath')
        REMOTE_TARGET_UPLOAD_PATH = str(get_nodevalue(node[0]).encode('utf-8', 'ignore'))
        node = get_xmlnode(root, 'InstallParameter')
        REMOTE_TARGET_INSTALL_PARAMETER = str(get_nodevalue(node[0]).encode('utf-8', 'ignore'))
        node = get_xmlnode(root, 'InstallLogPath')
        INSTALL_LOG_PATH = str(get_nodevalue(node[0]).encode('utf-8', 'ignore'))
        print(REMOTE_TARGET_USER)

    except AttributeError as e:
        print("config file may lack necessary attribute, please check!\n", e)
        sys.exit(10)  # load install config file error


def change_time_zone(path):
    msg = "Start change time zone"
    print(path)
    #tmpStr = REMOTE_TARGET_USER + "@" + REMOTE_TARGET_HOST + " -pw " + REMOTE_TARGET_PWD
    tmpStr = REMOTE_TARGET_HOST[2:len(REMOTE_TARGET_HOST)-1] + ' -l ' + REMOTE_TARGET_USER[2:len(REMOTE_TARGET_USER)-1]\
             + ' -pw ' + REMOTE_TARGET_PWD[2:len(REMOTE_TARGET_PWD)-1]
    cmd = "plink.exe -ssh " + tmpStr + "  cp " + path + " /etc/localtime"
    print(cmd)
    existStr = os.popen(cmd)



# 显示当前时区
print(win32api.GetTimeZoneInformation())
# 索取管理员权限
zoneChange.AdjustPrivilege(win32security.SE_TIME_ZONE_NAME)
# 设置windows时区样例复制(x,(......))的(....)部分
# (2, (180, '格陵兰标准时间', (0, 10, 6, 5, 23, 0, 0, 0), 0, '格陵兰夏令时', (0, 3, 6, 5, 22, 0, 0, 0), -60))
# (0, (180, '格陵兰标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0, '格陵兰标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0))
# (2, (210, '纽芬兰标准时间', (0, 11, 0, 1, 2, 0, 0, 0), 0, '纽芬兰夏令时', (0, 3, 0, 2, 2, 0, 0, 0), -60))
# (0, (210, '纽芬兰标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0, '纽芬兰标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0))
# (2, (360, '中部标准时间', (0, 11, 0, 1, 2, 0, 0, 0), 0, '中部夏令时', (0, 3, 0, 2, 2, 0, 0, 0), -60))
# (2, (540, '阿拉斯加标准时间', (0, 11, 0, 1, 2, 0, 0, 0), 0, '阿拉斯加夏令时', (0, 3, 0, 2, 2, 0, 0, 0), -60))
# (0, (720, '国际日期变更线标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0, '国际日期变更线夏令时', (0, 0, 0, 0, 0, 0, 0, 0), 0))
# (0, (-180, '俄罗斯 TZ 2 标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0, '俄罗斯 TZ 2 夏令时', (0, 0, 0, 0, 0, 0, 0, 0), -60))
# (0, (-330, '印度标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0, '印度夏令时', (0, 0, 0, 0, 0, 0, 0, 0), 0))
# (0, (-540, '东京标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0, '东京夏令时', (0, 0, 0, 0, 0, 0, 0, 0), 0))
# (1, (-720, '斐济标准时间', (0, 1, 6, 1, 0, 0, 0, 0), 0, '斐济夏令时', (0, 11, 0, 2, 2, 0, 0, 0), -60))
# 显示更改后的时区
win32api.SetTimeZoneInformation(
    (-480, '中国标准时间', (0, 0, 0, 0, 0, 0, 0, 0), 0, '中国夏令时', (0, 0, 0, 0, 0, 0, 0, 0), 0))
print(win32api.GetTimeZoneInformation())
read_configxml('CCBConfiguration.xml')
offset_second = time.timezone
offset_hour = divmod(offset_second, 3600)
if offset_hour[1] == 0:
    offset = str(offset_hour[0])
else:
    offset = str(offset_second / 3600)
if offset_hour[0] < 0:
    linux_zone = 'GMT' + str(offset)
else:
    linux_zone = 'GMT+' + str(offset)
print(linux_zone)
zone_path = zone_path + linux_zone
print(zone_path)
change_time_zone(zone_path)
