#!/bin/bash

DB_path='/data/mariadb/bin'
# Definition monitoring variables #
# Definition monitoring variables -01

base(){
:>/etc/zabbix/script/mysql/db_temp
QPS=`$DB_path/mysqladmin status|cut -f9 -d":"|awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -02
Questions=`$DB_path/mysqladmin status|cut -f4 -d":"|cut -f1 -d"S"|awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -03
Low_queries=`$DB_path/mysqladmin status|cut -f5 -d":"|cut -f1 -d"O"|awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -04
Threads_connected=`$DB_path/mysqladmin extended-status|grep -w "Threads_connected"|cut -d"|" -f3 |awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -05
Com_update=`$DB_path/mysqladmin extended-status |grep -w "Com_update"|cut -d"|" -f3|awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -06
Com_select=`$DB_path/mysqladmin extended-status |grep -w "Com_select"|cut -d"|" -f3|awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -07
Com_rollback=`$DB_path/mysqladmin extended-status |grep -w "Com_rollback"|cut -d"|" -f3|awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -08
Com_insert=`$DB_path/mysqladmin extended-status |grep -w "Com_insert"|cut -d"|" -f3|awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -09
Com_delete=`$DB_path/mysqladmin extended-status |grep -w "Com_delete"|cut -d"|" -f3|awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -10
Com_commit=`$DB_path/mysqladmin extended-status |grep -w "Com_commit"|cut -d"|" -f3|awk -F " " '{print $1}' |wc -l`
# Definition monitoring variables -11
Bytes_sent=`$DB_path/mysqladmin extended-status |grep -w "Bytes_sent" |cut -d"|" -f3|awk -F " " '{print $1}' |wc -l`

# Judging the existence of variables -01
if [ $QPS -gt 0 ];then
    echo QPS>>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -02
if [ $Questions -gt 0 ];then
    echo Questions>>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -03
if [ $Low_queries -gt 0 ];then
    echo "Low_queries">>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -04
if [ $Threads_connected -gt 0 ];then
    echo Threads_connected>>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -05
if [ $Com_update -gt 0 ];then
    echo Com_update>>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -06
if [ $Com_select -gt 0 ];then
    echo Com_select>>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -07
if [ $Com_rollback -gt 0 ];then
    echo Com_rollback>>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -08
if [ $Com_insert -gt 0 ];then
    echo Com_insert>>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -09
if [ $Com_delete -gt 0 ];then
    echo Com_delete>>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -10
if [ $Com_commit -gt 0 ];then
    echo Com_commit>>/etc/zabbix/script/mysql/db_temp
fi
# Judging the existence of variables -11
if [ $Bytes_sent -gt 0 ];then
    echo Bytes_sent>>/etc/zabbix/script/mysql/db_temp
fi

portarray=(`cat /etc/zabbix/script/mysql/db_temp`)
length=${#portarray[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
  do
     printf '\n\t\t{'
     printf "\"{#MYSQL_CHECK}\":\"${portarray[$i]}\"}"
     if [ $i -lt $[$length-1] ];then
                printf ','
     fi
  done
printf  "\n\t]\n"
printf "}\n"
}

slave(){
:>/etc/zabbix/script/mysql/db_temp_slave
Slave_IO_State=`$DB_path/mysql -e "show slave status\G"| grep Slave_IO_Running|wc -l`
# Definition monitoring variables -13
Slave_SQL_State=`$DB_path/mysql -e "show slave status\G"| grep Slave_SQL_Running|wc -l`


# Judging the existence of variables -12
if [ $Slave_IO_State -gt 0 ];then
    echo Slave_IO_State>>/etc/zabbix/script/mysql/db_temp_slave
fi
# Judging the existence of variables -13
if [ $Slave_SQL_State -gt 0 ];then
    echo Slave_SQL_State>>/etc/zabbix/script/mysql/db_temp_slave
fi

# input for Json#
portarray=(`cat /etc/zabbix/script/mysql/db_temp_slave`)
length=${#portarray[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
  do
     printf '\n\t\t{'
     printf "\"{#MYSQL_CHECK}\":\"${portarray[$i]}\"}"
     if [ $i -lt $[$length-1] ];then
                printf ','
     fi
  done
printf  "\n\t]\n"
printf "}\n"

}

slave_yc(){
:>/etc/zabbix/script/mysql/db_temp_yc
# Definition monitoring variables -14
Seconds_Behind_Master=`$DB_path/mysql -e "show slave status\G"| grep "Seconds_Behind_Master"|wc -l`
# Judging the existence of variables -14
if [ $Seconds_Behind_Master -gt 0 ];then
    echo Seconds_Behind_Master>>/etc/zabbix/script/mysql/db_temp_yc
fi

# input for Json#
portarray=(`cat /etc/zabbix/script/mysql/db_temp_yc`)
length=${#portarray[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
  do
     printf '\n\t\t{'
     printf "\"{#MYSQL_CHECK}\":\"${portarray[$i]}\"}"
     if [ $i -lt $[$length-1] ];then
                printf ','
     fi
  done
printf  "\n\t]\n"
printf "}\n"
}


maxml(){
:>/etc/zabbix/script/mysql/db_temp_maxml
# Definition monitoring variables -15
Maxml_in_ok=`$DB_path/mysql -e "SELECT COUNT(*) FROM ma.ma_xmlinfo t WHERE t.status = '5' AND t.createTime > DATE_FORMAT(NOW(),'%Y-%m-%d');" 2>/dev/null| sed -n '2p'|wc -l`
# Definition monitoring variables -16
Maxml_in_no=`$DB_path/mysql -e " SELECT COUNT(*) FROM ma.ma_xmlinfo t WHERE t.status = '6' AND t.createTime > DATE_FORMAT(NOW(),'%Y-%m-%d')" 2>/dev/null| sed -n '2p'|wc -l`
# Definition monitoring variables -17
Maxml_out_ok=`$DB_path/mysql -e "SELECT COUNT(*) FROM ma.ma_xmlinfo t WHERE t.status = '14'  AND t.createTime > DATE_FORMAT(NOW(),'%Y-%m-%d')" 2>/dev/null| sed -n '2p'|wc -l`
# Definition monitoring variables -18
Maxml_out_no=`$DB_path/mysql -e "SELECT COUNT(*) FROM ma.ma_xmlinfo t WHERE t.status = '12'  AND t.createTime > DATE_FORMAT(NOW(),'%Y-%m-%d')" 2>/dev/null| sed -n '2p'|wc -l`
# Judging the existence of variables -15
if [ $Maxml_in_ok -gt 0 ];then
    echo Maxml_in_ok>>/etc/zabbix/script/mysql/db_temp_maxml
fi
# Judging the existence of variables -16
if [ $Maxml_in_no -gt 0 ];then
    echo Maxml_in_no>>/etc/zabbix/script/mysql/db_temp_maxml
fi
# Judging the existence of variables -17
if [ $Maxml_out_ok -gt 0 ];then
    echo Maxml_out_ok>>/etc/zabbix/script/mysql/db_temp_maxml
fi
# Judging the existence of variables -18
if [ $Maxml_out_no -gt 0 ];then
    echo Maxml_out_no>>/etc/zabbix/script/mysql/db_temp_maxml
fi

# input for Json#
portarray=(`cat /etc/zabbix/script/mysql/db_temp_maxml`)
length=${#portarray[@]}
printf "{\n"
printf  '\t'"\"data\":["
for ((i=0;i<$length;i++))
  do
     printf '\n\t\t{'
     printf "\"{#MYSQL_CHECK}\":\"${portarray[$i]}\"}"
     if [ $i -lt $[$length-1] ];then
                printf ','
     fi
  done
printf  "\n\t]\n"
printf "}\n"
}

# Judging the existence of variables #

# execute #
if [ $1 == base ];then
    base
fi

if [ $1 == slave ];then
    slave
fi

if [ $1 == maxml ];then
    maxml
fi

if [ $1 == slave_yc ];then
    slave_yc
fi
