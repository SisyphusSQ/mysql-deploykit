#!/bin/bash
# Program:
#  log记录
# v0.1 by alex.zhao -2021/02/26
#
# 语法：
#  multiDeploy.sh [-P] port
#
# 测试：
#  multiDeploy.sh -P 3310
#
###############################

# 初始化变量
num=$#
ct=none
logfile=/tmp/myMulti_`date +%Y%m%d`.log
basefile=/home/mysql/mysql
USER=mysql
GROUP=mysql

# 方法区
function err(){
	ct="error，shell退出"
	
	./utils/printOut.sh 3 $ct
	./utils/putLog.sh $logfile 3 $ct

	exit 1
}

## 输出内容和记录log [info]
function pt1(){

	./utils/printOut.sh 1 $ct
	./utils/putLog.sh $logfile 1 $ct

}

# 检查$?的返回值
function ckRc(){

	if [ $? -ne 0 ]
	then
		
		ct="error，shell退出"
		
		./utils/printOut.sh 3 $ct
		./utils/putLog.sh $logfile 3 $ct
		
		exit 1
		
	fi

}

# 参数必须是两个，不然shell退出
if [ $num -ne 2 ]
then

	ct="参数有误，请检查。"
	./utils/printOut.sh 3 $ct
	./utils/putLog.sh $logfile 3 $ct
	
	err

fi

if [ "$1" == "-P" ]
then
	# 判断是否为整数
	`awk 'BEGIN { if (match(ARGV[1],"^[0-9]+$") != 0) print "true"; else print "false" }' $2`||err

	port=$2
	datafile=/data/mysql/$port/mydata/
	socket=/data/mysql/$port/mysql.sock
	mycnf=/data/mysql/$port/my.cnf
	portdir=/data/mysql/$port/
	bindir=/data/mysql/$port/mybin

else

	ct="参数输入有误，请检查输入的参数"
	./utils/printOut.sh 3 $ct
	./utils/putLog.sh $logfile 3 $ct
	
	err

fi

# 检查该端口是否已被创建
if [ -d $portdir ]
then

	ct="该端口下，已有mysql实例。请检查。"
	./utils/printOut.sh 3 $ct
	./utils/putLog.sh $logfile 3 $ct
	
	err

fi

# 创建相应文件夹
ct="创建相应文件夹"
pt1

echo $datafile
echo $bindir

mkdir -p $datafile
mkdir -p $bindir

ct="创建完成"
pt1

# 修改配置文件my.cnf
ct="创建my.cnf配置文件"
pt1

./utils/createMyCnf.sh $mycnf $port $socket $basefile $datafile $bindir

chown -R mysql:mysql /data/mysql

ct="已创建my.cnf配置文件"
pt1

# 初始化mysql
ct="开始初始化mysql"
pt1

su - mysql<<EOF
cd $basefile
pwd

./scripts/mysql_install_db --defaults-file=$mycnf

EOF

ct="mysql初始化已完成"
pt1

# 启动mysql，并设置自启动
ct="启动mysql，设置自启"
pt1

./utils/mysqlAutoStart.sh $mycnf $basefile $port

ct="mysql已启动，自启设置已完成"
pt1


