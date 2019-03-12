#!/bin/bash

# 屏蔽注释信息，截取工程名称 #
Source='awk 'BEGIN{RS="<!--|-->"}NR%2' /opt/tomcat7/*/server.xml|grep "docBase="|awk -F "\"|/" '{print $3}''



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