#!/bin/bash

input_01=$1
# 网卡与网线的连接状态 #
tool(){
CMD=`ip a|grep $input_01|grep "state UP"|wc -l`

if [ $CMD -eq 1 ];then
   echo "0"
else
   echo "1"
fi
}
# 网卡接口服务的状态 #
if_status(){

BOND=`ip a|grep input_01|grep "master bond0 state UP"|wc -l`
IP=`ip a |grep $input_01|grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"|wc -l`
if [ $BOND -eq 1 ];then
    echo "0"
else

    if [ $IP -gt 1 ];then
        echo "0"
    else
        echo "1"
    fi
fi
}


# execute #
if [ $2 == tool ];then
    tool
fi

if [ $2 == if_status ];then
    if_status
fi