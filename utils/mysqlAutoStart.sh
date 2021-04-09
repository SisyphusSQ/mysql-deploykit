#!/bin/bash
# Program:
#  log记录
# v0.1 by alex.zhao -2021/02/25
#
# 语法：
#  mysqlAutoStart.sh [mycnf] [basefile] [port]
#
#
###############################

# 初始化变量
mycnf=$1
basefile=$2
port=$3
serv=mysqld$port.service

# 建立软链接
mkdir -p /usr/local/mysql/bin/
ln -s $basefile/bin/mysqld /usr/local/mysql/bin/mysqld

chown -R mysql:mysql /usr/local/mysql

# 创建systemctl文件
cat > /etc/systemd/system/$serv <<EOF
[Unit]
Description=MySQL Server
Documentation=man:mysqld
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target
[Install]
WantedBy=multi-user.target
[Service]
User=mysql
Group=mysql
ExecStart=$basefile/bin/mysqld_safe --defaults-file=$mycnf
LimitNOFILE = 65535
Restart=always
RestartSec=1
StartLimitInterval=0

EOF

chmod 766 /etc/systemd/system/$serv

systemctl daemon-reload

systemctl start $serv && systemctl enable $serv
systemctl status $serv


