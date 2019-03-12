#!/bin/bash

Process=`ps -ef |grep keepalived|grep -v "grep"|wc -l`
Status=`cat /etc/keepalived/keepalived.conf 2>/dev/null|grep state|awk '{print $2}'`
# cat keepalived.conf|grep -A 1 "virtual_ipaddress" is OK
Vip=`sed -n '/virtual_ipaddress/N;s/.*\n\(.*\)/\1/p' /etc/keepalived/keepalived.conf 2>/dev/null|grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"`

# 查看配置文件是否存在，然后再查看主从以及VIP
if [ -e /etc/keepalived/keepalived.conf ];then
    if [ $Status == "MASTER" ];then
        result="Master"_VIP:$Vip
    elif [ $Status == "BACKUP" ];then
        result="Slave"_VIP:$Vip
    else
        result=""
    fi
else
    result=""
fi

# input for Json#
portarray=(`echo $result`)
length=${#portarray[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
  do
     printf '\n\t\t{'
     printf "\"{#VIP_CHECK}\":\"${portarray[$i]}\"}"
     if [ $i -lt $[$length-1] ];then
                printf ','
     fi
  done
printf  "\n\t]\n"
printf "}\n"