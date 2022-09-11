## 1.数据介绍

Sentinel-5P是欧空局于2017年10月13日发射的一颗全球大气污染监测卫星。卫星搭载了对流层观测仪（Tropospheric Monitoring Instrument，TROPOMI），可以有效的观测全球各地大气中痕量气体组分，包括NO2、O3、SO2、 HCHO、CH4和CO等重要的与人类活动密切相关的指标，加强了对气溶胶和云的观测。

## 2.项目简介

+ 本项目旨在维护一个TROPOMI卫星数据自动下载程序。以实现下载特定时间段数据的功能。

+ 本项目实现了指定日期范围，指定气体列表的下载，仅NC文件。

+ 本程序有一个全局调试变量。

| 全局变量           | True           | False                | 配置变量        |
| ------------------ | -------------- | -------------------- | --------------- |
| debugLocalDownload | 下载到本地目录 | 下载到服务器指定目录 | self._save_path |

+ 本程序有两个版本

  - HimawariDownloadBulitIn的时间变量写在程序内部，运行前需手动修改，适用于超算节点。

  - HimawariDownloadCmdLine的时间变量通过命令行输入，适用于登陆节点。



### 相关链接

1.[TROPOMI数据格式介绍](https://blog.csdn.net/xydf_1992/article/details/113483702)

2.[官方项目](https://github.com/bugsuse/pytropomi)

