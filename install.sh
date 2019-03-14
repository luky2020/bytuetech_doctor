#!/bin/bash
source /etc/profile # 加载环境变量

# 变量层定义 #
ServerIp=$1 # 获取服务端IP #
Version_sys=`/usr/bin/cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'` # 判断操作系统选择相应的zabbix版本
Path=`pwd` # 获取程序所在路径 #


# 获取客户端IP #
AgentIp(){
Agent_Ip_All=`/usr/sbin/ip a|grep -w "inet"|awk -F "/" '{print $1}'|awk '{print $2}'|grep -v "127.0.0.1"`
for Agent_Ip in $Agent_Ip_All
do
    ping -c 2 -I "$Agent_Ip" "$ServerIp" 2>&1> /dev/null
    if [[ $? = 0 ]];then
        echo "$Agent_Ip"
        break
    fi
done
}

# 部署客户端 #
AgentInstall(){
if [[ `AgentIp` != "" ]];then
    cat > /etc/yum.repos.d/zabbix_3.4.repo << eof
[bytuetech]
name=zabbix
baseurl=http://$ServerIp/yum/zabbix/3.4/rhel/$Version_sys/x86_64/
gpgcheck=0
enabled=1
eof
    rpm -e zabbix-agent
    mkdir -p /etc/zabbix/script
    yum install -y zabbix-agent
    # 创建Agent配置文件 #
    cd /etc/zabbix/ && :>zabbix_agentd.conf
    # zabbix_agentd.conf
    cat > /etc/zabbix/zabbix_agentd.conf << eof
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
AllowRoot=1
Timeout=30
Server=$ServerIp
ServerActive=$ServerIp:10051
HostMetadataItem=system.uname
Hostname=`AgentIp`
Include=/etc/zabbix/zabbix_agentd.d/*.conf
eof

    if [ $Version_sys -eq 7 ];then
        /usr/bin/systemctl start zabbix-agent;/usr/bin/systemctl enable zabbix-agent
    else
        /sbin/service zabbix-agent start;/sbin/chkconfig zabbix-agent on
    fi

else
    echo "IP address error!" > /tmp/bytuetech_doctor_error
fi
}


# 部署服务端 #
ServerInstall(){
## 准备工作 安装HTTP 和数据库 ##
yum install mariadb-server httpd ansible -y && systemctl restart mariadb httpd && mkdir /etc/zabbix/
if [ $? -eq 0 ];then

    ## 配置yum源 ##
    /usr/bin/scp -r yum/ /etc/zabbix/ /etc/zabbix
    ## 编写yum源的HTTP服务配置文件 ##
    cat > /etc/httpd/conf.d/yum.conf << eof
Alias /yum /etc/zabbix/
<Directory "/etc/zabbix/">
Options Indexes FollowSymLinks
AllowOverride none
Require all granted
</Directory>
eof
    /usr/bin/systemctl restart httpd
    ## 编写yum源的配置文件 ##
    cat > /etc/yum.repos.d/zabbix_3.4.repo << eof
[bytuetech]
name=zabbix
baseurl=http://$ServerIp/yum/zabbix/3.4/rhel/$Version_sys/x86_64/
gpgcheck=0
enabled=1
eof
    ## 开始安装zabbix服务 ##
    yum install -y epel-release #解决所需依赖
    yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-agent
    if [ $? -eq 0 ];then
        mysql -e "create database zabbix character set utf8 collate utf8_bin;"
        mysql -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"
        zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -pzabbix zabbix # 导入初始架构和数据
        echo "DBPassword=zabbix" >> /etc/zabbix/zabbix_server.conf # 修改zabbix配置文件
        sed -i "s/# php_value date.timezone Europe\/Riga/php_value date.timezone Asia\/Shanghai/" /etc/httpd/conf.d/zabbix.conf # 为Zabbix前端配置PHP时区
        systemctl restart zabbix-server zabbix-agent httpd && systemctl enable zabbix-server zabbix-agent httpd

        # ansible执行批量命令，拷贝脚本等配置文件并执行install程序 #


    else
        echo "ERROR zabbix not install "
    fi
else
    exit
fi

}


# 部署批量执行工具ansible #

Ansible(){
yum install ansible -y
if [ $? -eq 0 ];then
    sed -i 's/#host_key_checking = False/host_key_checking = False/' /etc/ansible/ansible.cfg # 不检查angent的SSH knows文件
    echo "[bytuetech_doctor]" > /etc/ansible/hosts && grep -v "^#" $Path/hosts|awk '{print ""$1" ansible_ssh_port="$2" ansible_user="$3" ansible_ssh_pass=\""$4"\" ansible_su_pass=\""$5"\""}' >>/etc/ansible/hosts
    cat > /etc/ansible/roles/bytuetech_doctor.yml << eof #编写 ansible 剧本文件
- hosts: bytuetech_doctor
  user: root
  tasks:
   - name: copy file
     copy: src={{ item.src }} dest={{ item.dest }} mode='0755'
     with_items:
     - {src: "$Path/install.sh",
       dest: "/etc/zabbix/"}
     - {src: "$Path/script/",
       dest: "/etc/zabbix/script"}
     - {src: "$Path/conf/",
       dest: "/etc/zabbix/zabbix_agentd.d/"}
   - name: install zabbix
     shell : sh /etc/zabbix/install.sh $ServerIp
eof
    ansible-playbook -S /etc/ansible/roles/bytuetech_doctor.yml > /

fi

}


# 执行安装 #
ARGS=1 # 定义脚本执行需要输入的变量，必须有1个并且符合IP格式
if [ $# -eq "$ARGS" ] && echo $1 |egrep -q '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$';then
    if [[ `AgentIp` == "" ]];then # 判断输入的IP是否可用
        echo "IP address error!"
    else
        if [[ `AgentIp` == $ServerIp ]];then
            ServerInstall
        else
            AgentInstall
        fi
    fi
else
    echo "Please input one arguement: IP for Server"
fi
