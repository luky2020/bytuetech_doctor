#!/bin/bash

# 定义不同的服务名称，用于智能匹配 #
Server_name=$1

case $Server_name in
    tomcat7)
        result=`grep "org.apache.coyote." /opt/tomcat*/conf/server.xml 2>/dev/null|awk -F "\"" '{print $2}'`
        portarray=(`echo $result`)
        length=${#portarray[@]}
                printf "{\n"
                printf  '\t'"\"data\":["
                for ((i=0;i<$length;i++))
                  do
                     printf '\n\t\t{'
                     printf "\"{#TOMCAT7_PORT}\":\"${portarray[$i]}\"}"
                     if [ $i -lt $[$length-1] ];then
                                printf ','
                     fi
                  done
                printf  "\n\t]\n"
                printf "}\n"
                ;;
    nginx)
        result=`grep listen /etc/nginx/conf.d/*.conf 2>/dev/null|awk '{print $2}'|awk -F ";" '{print $1}'`
        portarray=(`echo $result`)
        length=${#portarray[@]}
                printf "{\n"
                printf  '\t'"\"data\":["
                for ((i=0;i<$length;i++))
                  do
                     printf '\n\t\t{'
                     printf "\"{#NGINX_PORT}\":\"${portarray[$i]}\"}"
                     if [ $i -lt $[$length-1] ];then
                                printf ','
                     fi
                  done
                printf  "\n\t]\n"
                printf "}\n"
                ;;
    mysqld)
        result=`grep "port" /etc/my.cnf 2>/dev/null |grep -v ^#|awk '{print $3}'|uniq`
        portarray=(`echo $result`)
        length=${#portarray[@]}
                printf "{\n"
                printf  '\t'"\"data\":["
                for ((i=0;i<$length;i++))
                  do
                     printf '\n\t\t{'
                     printf "\"{#MYSQLD_PORT}\":\"${portarray[$i]}\"}"
                     if [ $i -lt $[$length-1] ];then
                                printf ','
                     fi
                  done
                printf  "\n\t]\n"
                printf "}\n"
                ;;

    vsftpd)
        Server_port=`cat /etc/vsftpd/vsftpd.conf 2>/dev/null|grep -v "grep"|grep "listen_port"|awk -F "=" '{print $2}'`
        Port_default=`cat /etc/vsftpd/vsftpd.conf 2>/dev/null|grep -v "grep"|grep "listen_port"|wc -l`
        Conf=`ls /etc/vsftpd/vsftpd.conf 2>/dev/null|wc -l`
        if [ $Conf -eq 1 ];then
            if [ $Port_default -eq 1 ];then
            result=$Server_port
            else
            result="21"
            fi
        else
            result=""
        fi
        portarray=(`echo $result`)
            length=${#portarray[@]}
                    printf "{\n"
                    printf  '\t'"\"data\":["
                    for ((i=0;i<$length;i++))
                      do
                         printf '\n\t\t{'
                         printf "\"{#VSFTPD_PORT}\":\"${portarray[$i]}\"}"
                         if [ $i -lt $[$length-1] ];then
                                    printf ','
                         fi
                      done
                    printf  "\n\t]\n"
                    printf "}\n"
                ;;
    rsyncd)
        result=`if [ "$(grep "port" /etc/rsyncd.conf 2>/dev/null |grep -v ^#|awk '{print $3}')" == "" ];then echo "873";else grep "port" /etc/rsyncd.conf 2>/dev/null|grep -v ^#|awk '{print $3}';fi`
        portarray=(`echo $result`)
        length=${#portarray[@]}
                printf "{\n"
                printf  '\t'"\"data\":["
                for ((i=0;i<$length;i++))
                  do
                     printf '\n\t\t{'
                     printf "\"{#RSYNCD_PORT}\":\"${portarray[$i]}\"}"
                     if [ $i -lt $[$length-1] ];then
                                printf ','
                     fi
                  done
                printf  "\n\t]\n"
                printf "}\n"
                ;;
    memcached)

        result=`cat /etc/rc.local 2>/dev/null |grep memcached|awk '{print $7}'`
        portarray=(`echo $result`)
        length=${#portarray[@]}
                printf "{\n"
                printf  '\t'"\"data\":["
                for ((i=0;i<$length;i++))
                  do
                     printf '\n\t\t{'
                     printf "\"{#MEMCACHED_PORT}\":\"${portarray[$i]}\"}"
                     if [ $i -lt $[$length-1] ];then
                                printf ','
                     fi
                  done
                printf  "\n\t]\n"
                printf "}\n"
                ;;
    redis-server)

        result=` cat /data/redis/6379/redis.conf 2>/dev/null|grep "port"|awk '{print $2}'`
        portarray=(`echo $result`)
        length=${#portarray[@]}
                printf "{\n"
                printf  '\t'"\"data\":["
                for ((i=0;i<$length;i++))
                  do
                     printf '\n\t\t{'
                     printf "\"{#REDIS-SERVER_PORT}\":\"${portarray[$i]}\"}"
                     if [ $i -lt $[$length-1] ];then
                                printf ','
                     fi
                  done
                printf  "\n\t]\n"
                printf "}\n"
                ;;
    redis-sentine)

        result=`cat /data/redis/sentinel.conf 2>/dev/null| grep "port"|awk '{print $2}'`
        portarray=(`echo $result`)
        length=${#portarray[@]}
                printf "{\n"
                printf  '\t'"\"data\":["
                for ((i=0;i<$length;i++))
                  do
                     printf '\n\t\t{'
                     printf "\"{#REDIS-SENTINE_PORT}\":\"${portarray[$i]}\"}"
                     if [ $i -lt $[$length-1] ];then
                                printf ','
                     fi
                  done
                printf  "\n\t]\n"
                printf "}\n"
                ;;
    magent)

        result=`cat /etc/rc.local 2>/dev/null |grep magent|awk '{print $10}'`
        portarray=(`echo $result`)
        length=${#portarray[@]}
                printf "{\n"
                printf  '\t'"\"data\":["
                for ((i=0;i<$length;i++))
                  do
                     printf '\n\t\t{'
                     printf "\"{#MAGENT_PORT}\":\"${portarray[$i]}\"}"
                     if [ $i -lt $[$length-1] ];then
                                printf ','
                     fi
                  done
                printf  "\n\t]\n"
                printf "}\n"
                ;;
    ??)
        result=`echo "??"`
                echo $result
                ;;
        *)
        echo "Usage:$0"
        ;;
esac

