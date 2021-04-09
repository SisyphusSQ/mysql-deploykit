#!/bin/bash
# Program:
#  打印输出信息
# v0.1 by alex.zhao -2021/02/24
#
# 语法：
#  printOut.sh [1|2|3] [content]
###############################

# 设置颜色
red='\e[0;31m' # 红色  
RED='\e[1;31m' 
green='\e[0;32m' # 绿色  
GREEN='\e[1;32m' 
blue='\e[0;34m' # 蓝色  
BLUE='\e[1;34m' 
purple='\e[0;35m' # 紫色  
PURPLE='\e[1;35m' 
NC='\e[0m' # 没有颜色 

# 把$2的内容传给参数
ct=$2

# 设置当前时间
TIME_STAMP=`date +%Y-%m-%d\ %H:%M:%S`

# 从$1中取得输出信息的类型
# [1]：[Info]
# [2]：[Waring]
# [3]：[Error]
case $1 in
1)
	kind=[Info]
	printf "$TIME_STAMP $kind $GREEN$ct$NC\n"
	;;
2)
	kind=[Waring]
	printf "$TIME_STAMP $kind $BLUE$ct$NC\n"
	;;
3)
	kind=[Error]
	printf "$TIME_STAMP $kind $RED$ct$NC\n"
	;;
*)
	printf "输入有误，sorry~"
	exit 1
esac
