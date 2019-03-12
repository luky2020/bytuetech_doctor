#!/bin/bash
Vip_status=$1
Vip=`sed -n '/virtual_ipaddress/N;s/.*\n\(.*\)/\1/p' /etc/keepalived/keepalived.conf 2>/dev/null|grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"`
Process=`ps -ef |grep keepalived|grep -v "grep"|wc -l`

case $Vip_status in
    Master_VIP:$Vip)
        M_vip_status=`ip a |grep -w "$Vip"|wc -l`
        if [ $Process -ge 3 ];then
            if [ $M_vip_status -eq 1 ];then
            # 输出0表示 keepalived主的VIP状态正常
                echo "0"
            else
            # 输出1表示 keepalived主的VIP状态异常，VIP在主服务器上不存在
                echo "1"
            fi
        else
            # 输出2表示 keepalived服务未启动
            echo "2"
        fi
            ;;
    Slave_VIP:$Vip)
        S_vip_status=`ip a |grep -w "$Vip"|wc -l`
        if [ $Process -ge 3 ];then
            if [ $S_vip_status -eq 0 ];then
            # 输出0表示 keepalived备的VIP状态正常
                echo "0"
            else
            # 输出3表示 keepalived备的VIP状态异常，VIP漂移至备机
                echo "3"
            fi
        else
            # 输出2表示 keepalived服务未启动
            echo "2"
        fi
            ;;
        *)
        echo "Usage:$0"
            ;;
esac