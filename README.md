＃bytuetech_doctor

*注意：yum源的下载需要进入yum目录里，点击【repo.zabbix.com.zip】，然后点击【download】，请自行替换clone下载到本地的文件。

测试阶段第一版
1.首先安装SERVER端
将安装包拷贝至/opt/software/下
2.执行安装脚本(根据您的实际情况更改SERVER服务器的IP地址)
cd /opt/software/bytuetech_doctor/
sh install.sh 10.0.0.22
3.批量安装客户端agent
  