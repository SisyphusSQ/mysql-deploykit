#!/bin/bash
# Program:
#  log记录
# v0.3 by alex.zhao -2021/02/25
#
# 语法：
#  mysqlAutoDeploy.sh [-P] port
#
# 测试：
#  mysqlAutoDeploy.sh -P 3310
#
###############################

# 初始化变量
num=$#
ct=none
logfile=/tmp/myInstall_`date +%Y%m%d`.log
port=3306
basefile=/home/mysql/mysql
USER=mysql
GROUP=mysql


function err(){
	ct="error，shell退出"
	
	./utils/printOut.sh 3 $ct
	./utils/putLog.sh $logfile 3 $ct

	exit 1
}

# 检查$?的返回值
function ckRc(){

	if [ ${RC} -ne 0 ]
	then
		
		ct="error，shell退出"
		
		./utils/printOut.sh 3 $ct
		./utils/putLog.sh $logfile 3 $ct
		
		exit 1
		
	fi

}

# 输出内容和记录log [info]
function pt1(){

	./utils/printOut.sh 1 $ct
	./utils/putLog.sh $logfile 1 $ct

}

if [ "$1" == "-P" ]
then
	# 判断是否为整数
	`awk 'BEGIN { if (match(ARGV[1],"^[0-9]+$") != 0) print "true"; else print "false" }' $2`||err

	port=$2
	datafile=/data/mysql/$port/mydata/
	socket=/data/mysql/$port/mysql.sock
	mycnf=/data/mysql/$port/my.cnf
	#portdir=/data/mysql/$port/
	bindir=/data/mysql/$port/mybin

elif [ ! $1 ]
then

	datafile=/data/mysql/$port/mydata/
	socket=/data/mysql/$port/mysql.sock
	mycnf=/data/mysql/$port/my.cnf
	#portdir=/data/mysql/$port/
	bindir=/data/mysql/$port/mybin

else

	ct="参数输入有误，请检查输入的参数"
	./utils/printOut.sh 3 $ct
	./utils/putLog.sh $logfile 3 $ct
	
	err

fi

# 测试变量
echo $port
echo $datafile
echo $socket
echo $basefile

# 安装必要的依赖包
ct="开始安装依赖包lvm2和libaio"
pt1

yum install -y lvm2 libaio
RC=$?

# 检查$?返回值
ckRc

ct="依赖包安装完成"
pt1

# 查看并关闭selinux和iptables
ct="检查selinux的状态"
pt1

getenforce |grep Enforcing >& /dev/null && setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

ct="已关闭selinux"
pt1

ct="准备关闭iptables"
pt1

iptables -F && ct="已关闭iptables" && pt1

# 创建用户，并赋予环境变量
id ${USER} >& /dev/null
RC=$?
if [ ${RC} -ne 0 ]
then

	ct="mysql用户不存在，开始创建"
	pt1
	
#	groupadd ${GROUP}
	useradd ${USER}

	ct="mysql用户已创建"
	pt1	
	
	# 环境变量
	ct="设置环境变量"
	pt1	
	
	echo 'export MYSQL_HOME=/home/mysql/mysql' >>/home/mysql/.bash_profile
	echo 'export PATH=$PATH:$MYSQL_HOME/bin' >> /home/mysql/.bash_profile
	source /home/mysql/.bash_profile

	echo 'export MYSQL_HOME=/home/mysql/mysql' >>/root/.bash_profile
	echo 'export PATH=$PATH:$MYSQL_HOME/bin' >> /root/.bash_profile
	source /root/.bash_profile
	
else
	ct="mysql用户已存在"
	pt1
	
	# 环境变量
	ct="检查环境变量"
	pt1	

	cat /home/mysql/.bash_profile|grep MYSQL_HOME=/home/mysql/mysql >& /dev/null || echo 'export MYSQL_HOME=/home/mysql/mysql' >>/home/mysql/.bash_profile
	cat /home/mysql/.bash_profile|grep MYSQL_HOME=/home/mysql/mysql >& /dev/null || echo 'export PATH=$PATH:$MYSQL_HOME/bin' >> /home/mysql/.bash_profile
	source /home/mysql/.bash_profile

	cat /root/.bash_profile|grep MYSQL_HOME=/home/mysql/mysql >& /dev/null || echo 'export MYSQL_HOME=/home/mysql/mysql' >>/root/.bash_profile
	cat /root/.bash_profile|grep MYSQL_HOME=/home/mysql/mysql >& /dev/null || echo 'export PATH=$PATH:$MYSQL_HOME/bin' >> /root/.bash_profile
	source /root/.bash_profile
fi

# 安装mysql
ct="开始安装mysql"
pt1	

#mkdir -p $basefile

tar zxf ./mysql-8.0.21-el7-x86_64.tar.gz

[ $? -ne 0 ] && err

# 重命名，并移动mysql文件
mv ./mysql-8.0.21-el7-x86_64 ./mysql
mv ./mysql /home/mysql/

# 把/home/mysql/下的mysql授权给mysql用户
chown -R mysql:mysql /home/mysql/mysql

ct="已完成mysql的安装"
pt1

# 修改配置文件my.cnf
# 创建mysql的数据目录
ct="创建my.cnf配置文件"
pt1

mkdir -p $datafile
mkdir -p $bindir

cat >> /etc/my.cnf <<EOF
[mysql]
prompt=mysql [\\d]>
EOF

./utils/createMyCnf.sh $mycnf $port $socket $basefile $datafile $bindir

chown -R mysql:mysql /data/mysql

ct="已创建my.cnf配置文件"
pt1

# 初始化mysql
ct="开始初始化mysql"
pt1

# mariadb的初识方式
# su - mysql<<EOF
# cd $basefile
# pwd
# ./scripts/mysql_install_db --defaults-file=$mycnf
# EOF

mysqld --initialize-insecure --user=mysql --basedir=$basefile --datadir=$datafile

[ $? -ne 0 ] && err

ct="mysql初始化已完成"
pt1

# 启动mysql，并设置自启动
ct="启动mysql，设置自启"
pt1

./utils/mysqlAutoStart.sh $mycnf $basefile $port

ct="mysql已启动，自启设置已完成"
pt1

