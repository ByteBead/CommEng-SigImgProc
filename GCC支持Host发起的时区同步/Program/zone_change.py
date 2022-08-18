from __future__ import division
import sys
import time
import os
import glob
import string
import xml.dom.minidom as minidom

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
