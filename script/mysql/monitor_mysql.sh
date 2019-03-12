#!/bin/sh
ARGS=2
if [ $# -ne "$ARGS" ];then
    echo "Please input one arguement:"
fi
input_01=$1
DB_path='/data/mariadb/bin'

Case_base(){
case $input_01 in
    QPS)
	result=`$DB_path/mysqladmin status|cut -f9 -d":"`
		echo $result
		;;

    Questions)
        result=`$DB_path/mysqladmin status|cut -f4 -d":"|cut -f1 -d"S"`
           	 echo $result
           	 ;;

    Low_queries)
	result=`$DB_path/mysqladmin status|cut -f5 -d":"|cut -f1 -d"O"`
		echo $result
		;;

    Threads_connected)
	result=`$DB_path/mysqladmin extended-status|grep -w "Threads_connected"|cut -d"|" -f3`
		echo $result
		;;
    Com_update)
        result=`$DB_path/mysqladmin extended-status |grep -w "Com_update"|cut -d"|" -f3`
           	 echo $result
            	;;
    Com_select)
        result=`$DB_path/mysqladmin extended-status |grep -w "Com_select"|cut -d"|" -f3`
                echo $result
                ;;
    Com_rollback)
        result=`$DB_path/mysqladmin extended-status |grep -w "Com_rollback"|cut -d"|" -f3`
                echo $result
                ;;
    Com_insert)
        result=`$DB_path/mysqladmin extended-status |grep -w "Com_insert"|cut -d"|" -f3`
                echo $result
                ;;
    Com_delete)
        result=`$DB_path/mysqladmin extended-status |grep -w "Com_delete"|cut -d"|" -f3`
                echo $result
                ;;
    Com_commit)
        result=`$DB_path/mysqladmin extended-status |grep -w "Com_commit"|cut -d"|" -f3`
                echo $result
                ;;
    Bytes_sent)
        result=`$DB_path/mysqladmin extended-status |grep -w "Bytes_sent" |cut -d"|" -f3`
                echo $result
                ;;
    Slave_IO_State)
	result=`if [ "$($DB_path/mysql -e "show slave status\G"| grep Slave_IO_Running|awk '{print $2}')" == "Yes" ];then echo 1; else echo 0;fi`
		echo $result
		;;

    Slave_SQL_State)
	result=`if [ "$($DB_path/mysql -e "show slave status\G"| grep Slave_SQL_Running|awk '{print $2}')" == "Yes" ];then echo 1; else echo 0;fi`
		echo $result
		;;
    Seconds_Behind_Master)
        result=`if [ "$($DB_path/mysql -e "show slave status\G"| grep "Seconds_Behind_Master"|awk '{print $2}')" == "0" ];then echo 1; else echo 0;fi`
                echo $result
                ;;
        *)
        echo "Usage:$0"
        ;;
esac
}

Case_slave() {
case $input_01 in
    Slave_IO_State)
	result=`if [ "$($DB_path/mysql -e "show slave status\G"| grep Slave_IO_Running|awk '{print $2}')" == "Yes" ];then echo 1; else echo 0;fi`
		echo $result
		;;

    Slave_SQL_State)
	result=`if [ "$($DB_path/mysql -e "show slave status\G"| grep Slave_SQL_Running|awk '{print $2}')" == "Yes" ];then echo 1; else echo 0;fi`
		echo $result
		;;
    Seconds_Behind_Master)
        result=`$DB_path/mysql -e "show slave status\G"| grep "Seconds_Behind_Master"|awk '{print $2}'`
                echo $result
                ;;
        *)
        echo "Usage:$0"
        ;;
esac
}

Case_slave_yc() {
case $input_01 in
    Seconds_Behind_Master)
        result=`$DB_path/mysql -e "show slave status\G"| grep "Seconds_Behind_Master"|awk '{print $2}'`
                echo $result
                ;;
        *)
        echo "Usage:$0"
        ;;
esac
}

Case_maxml() {
case $input_01 in
    Maxml_in_ok)
        result=`$DB_path/mysql -uappuser -pappuser -h127.0.0.1. -e "SELECT COUNT(*) FROM ma.ma_xmlinfo t WHERE t.status = '5' AND t.createTime > DATE_FORMAT(NOW(),'%Y-%m-%d');" | sed -n '2p'`
                echo $result
                ;;
    Maxml_in_no)
        result=`$DB_path/mysql -e " SELECT COUNT(*) FROM ma.ma_xmlinfo t WHERE t.status = '6' AND t.createTime > DATE_FORMAT(NOW(),'%Y-%m-%d')"| sed -n '2p'`
                echo $result
                ;;
    Maxml_out_ok)
        result=`$DB_path/mysql -e "SELECT COUNT(*) FROM ma.ma_xmlinfo t WHERE t.status = '14'  AND t.createTime > DATE_FORMAT(NOW(),'%Y-%m-%d')"| sed -n '2p'`
                echo $result
                ;;
    Maxml_out_no)
        result=`$DB_path/mysql -e "SELECT COUNT(*) FROM ma.ma_xmlinfo t WHERE t.status = '12'  AND t.createTime > DATE_FORMAT(NOW(),'%Y-%m-%d')"| sed -n '2p'`
                echo $result
                ;;
        *)
        echo "Usage:$0"
        ;;
esac
}
# execute #
if [ $2 == base ];then
    Case_base
fi

if [ $2 == slave ];then
    Case_slave
fi

if [ $2 == slave_yc ];then
    Case_slave_yc
fi

if [ $2 == maxml ];then
    Case_maxml
fi