#!/bin/bash
# Program:
#  log记录
# v0.1 by alex.zhao -2021/02/24
#
# 语法：
#  putLog.sh [logfile] [1|2|3] [content]
###############################

# 将$1传入参数中
logfile=$1

# 将$3传入参数中
ct=$3

# 处理logfile
[ -f $logfile ] || touch $logfile

# 设置当前时间
TIME_STAMP=`date +%Y-%m-%d\ %H:%M:%S`

# 从$2中取得输出信息的类型
# [1]：[Info]
# [2]：[Waring]
# [3]：[Error]
case $2 in
1)
	kind=[Info]
	echo "$TIME_STAMP $kind $ct" >> $logfile
	;;
2)
	kind=[Waring]
	echo "$TIME_STAMP $kind $ct" >> $logfile
	;;
3)
	kind=[Error]
	echo "$TIME_STAMP $kind $ct" >> $logfile
	;;
*)
	echo "输入有误，sorry~"
	exit 1
esac
