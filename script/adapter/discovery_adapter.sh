#!/bin/bash
# 获取已激活的网卡
portarray=(`grep -r "ONBOOT=yes" /etc/sysconfig/network-scripts/*|grep -v "ifcfg-lo"|awk -F "-" '{print $3}'|awk -F ":" '{print $1}'`)
# input for Json#
length=${#portarray[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
  do
     printf '\n\t\t{'
     printf "\"{#ADAPTER_CHECK}\":\"${portarray[$i]}\"}"
     if [ $i -lt $[$length-1] ];then
                printf ','
     fi
  done
printf  "\n\t]\n"
printf "}\n"