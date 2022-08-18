## GCC支持Host发起的时区同步

### 1.文件描述

​	/Program/CCBConfiguration.xml是配置文件

+ LoginUser 登录Linux的用户名
+ Password 登录Linux的用户密码
+ HostName Linux设备IP地址
+ 其余项没有作用

​	/Plink/ 远程登录软件

+ 注意 如果电脑没有安装Plink，请将Plink文件夹添加到环境变量

### 2.使用方法

​	在HOST的dos指令框中输入 以下指令

​		 plink.exe -ssh ***HostName*** -l ***LoginUser*** -pw ***Password*** sudo chmod 777 /etc/localtime

+ 请将倾斜加粗的字体替换为配置文件中的相应项目
+ 例如  plink.exe -ssh 192.168.1.11 -l admin -pw pass
+ 只有新设备需要执行上述命令 上述命令是使用户获得修改时区的权限

​	运行zone_change.py





