#!/bin/bash
# Program:
#  log记录
# v0.1 by alex.zhao -2021/02/25
#
# 语法：
#  createMyCnf [目标文件] [port] [socket] [basefile] [datafile] [bindir]
#
# 测试：
#
#
###############################

mycnf=$1
port=$2
socket=$3
basefile=$4
datafile=$5
bindir=$6

cat > $mycnf <<EOF
# Example MariaDB config file for large systems.
#
# This is for a large system with memory = 512M where the system runs mainly
# MariaDB.
#
# MariaDB programs look for option files in a set of
# locations which depend on the deployment platform.
# You can copy this option file to one of those
# locations. For information about these locations, do:
# 'my_print_defaults --help' and see what is printed under
# Default options are read from the following files in the given order:
# More information at: http://dev.mysql.com/doc/mysql/en/option-files.html
#
# In this file, you can use all long options that a program supports.
# If you want to know which options a program supports, run the program
# with the "--help" option.
#default-storage-engine = Innodb
# The following options will be passed to all MariaDB clients
[client]
port		= $port
socket		= $socket
default-character-set = utf8
# Here follows entries for some specific programs

# The MariaDB server
[mysqld]
basedir = $basefile
datadir = $datafile
pid_file = /data/mysql/$port/mysql.pid
#log_error = /data/mysql/$port/mysql.err
port		= $port
mysqlx_port = "${port}0"
socket		= $socket
transaction_isolation=READ-COMMITTED
max_allowed_packet = 1M
default_authentication_plugin=mysql_native_password
#skip-external-locking
#connection#
interactive_timeout=1800
skip_name_resolve=ON
max_connections=2000
max_connect_errors=1000
character-set-server=utf8
#init_connect='SET collation_connection=utf8-unicode_ci'
#init_connect='SET NAMES  utf8'
#collation-server=utf8_unicode_ci
skip-character-set-client-handshake
event_scheduler=0

#session memory setting#
sort_buffer_size = 16M
tmp_table_size = 64M
join_buffer_size = 16M
binlog_cache_size = 1M
max_heap_table_size = 64M
key_buffer_size = 256M
table_open_cache = 256
thread_cache_size = 8
#query_cache_size= 16M
character-set-server = utf8

#log settings#
log_error = /data/mysql/$port/mysql.err
slow_query_log=1
slow_query_log_file = /data/mysql/$port/mysql-slow.log
long_query_time = 2
log_queries_not_using_indexes = 0
expire_logs_days = 15
log-bin=$bindir/mysql-bin
binlog_format = row
#min_examined_row_limit = 100
sync_binlog=1



# Point the following paths to different dedicated disks
tmpdir  = /tmp/

# Don't listen on a TCP/IP port at all. This can be a security enhancement,
# if all processes that need to connect to mysqld run on the same host.
# All interaction with mysqld must be made via Unix sockets or named pipes.
# Note that using this option without enabling named pipes on Windows
# (via the "enable-named-pipe" option) will render mysqld useless!
# 
#skip-networking

# Replication Master Server (default)
# binary logging is required for replication
#log-bin=mysql-bin

# binary logging format - mixed recommended
#binlog_format=row

# required unique id between 1 and 2^32 - 1
# defaults to 1 if master-host is not set
# but will not function as a master if omitted

# Replication Slave (comment out master section to use this)
#
# To configure this host as a replication slave, you can choose between
# two methods :
#
# 1) Use the CHANGE MASTER TO command (fully described in our manual) -
#    the syntax is:
#
#    CHANGE MASTER TO MASTER_HOST=<host>, MASTER_PORT=<port>,
#    MASTER_USER=<user>, MASTER_PASSWORD=<password> ;
#
#    where you replace <host>, <user>, <password> by quoted strings and
#    <port> by the master's port number (3306 by default).
#
#    Example:
#
#    CHANGE MASTER TO MASTER_HOST='125.564.12.1', MASTER_PORT=3306,
#    MASTER_USER='joe', MASTER_PASSWORD='secret';
#
# OR
#
# 2) Set the variables below. However, in case you choose this method, then
#    start replication for the first time (even unsuccessfully, for example
#    if you mistyped the password in master-password and the slave fails to
#    connect), the slave will create a master.info file, and any later
#    change in this file to the variables' values below will be ignored and
#    overridden by the content of the master.info file, unless you shutdown
#    the slave server, delete master.info and restart the slaver server.
#    For that reason, you may want to leave the lines below untouched
#    (commented) and instead use CHANGE MASTER TO (see above)
#
# required unique id between 2 and 2^32 - 1
# (and different from the master)
# defaults to 2 if master-host is set
# but will not function as a slave if omitted
server-id       = $port
#
# The replication master for this slave - required
#master-host     =   <hostname>
#
# The username the slave will use for authentication when connecting
# to the master - required
#master-user     =   <username>
#
# The password the slave will authenticate with when connecting to
# the master - required
#master-password =   <password>
#
# The port the master is listening on.
# optional - defaults to 3306
#master-port     =  <port>
#
# binary logging - not required for slaves, but recommended
#log-bin=mysql-bin



#innodb setting#
# Uncomment the following if you are using InnoDB tables
#innodb_data_home_dir = /usr/local/mysql/data
#innodb_data_file_path = ibdata1:10M:autoextend
#innodb_log_group_home_dir = /usr/local/mysql/data
# You can set .._buffer_pool_size up to 50 - 80 %
# of RAM but beware of setting memory usage too high
innodb_buffer_pool_size = 1G
#innodb_additional_mem_pool_size = 20M
# Set .._log_file_size to 25 % of buffer pool size
innodb_log_file_size = 1024M
innodb_log_files_in_group=4
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_write_io_threads=8
innodb_read_io_threads=8
innodb_print_all_deadlocks=1
# Try number of CPU's*2 for thread_concurrency
# thread_concurrency = 16
innodb_max_dirty_pages_pct=90



[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash
#default-character-set = utf8
# Remove the next comment character if you are not familiar with SQL
#safe-updates

[myisamchk]
myisam_sort_buffer_size = 64M
key_buffer_size = 256M
sort_buffer_size = 8M
read_buffer_size = 8M
read_rnd_buffer_size = 8M

[mysqlhotcopy]
interactive-timeout

[mysqld_safe]
open-files-limit = 4096
#default-character-set = utf8
#log_bin_trust_function_creators=1

EOF


