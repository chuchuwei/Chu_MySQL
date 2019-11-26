# 自建MySQL数据库高可用搭建报告.v.19.01.24

[TOC]



## 环境准备

| 实例           | 备注   |
| ------------ | ---- |
| 10.116.63.18 | 灾备环境 |
| 10.116.246.1 | 生产环境 |

两个实例mysql数据库互为主从

数据库之前运行在docker中，在10.116.246.1中重新安装数据库以后，将数据库从docker中迁移到10.116.246.1中运行

### 数据库安装

> percona mysql 5.7.18

```shell
# 安装脚本
#!/bin/bash

DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

#\mv /alidata/mysql /alidata/mysql.bak.$DATE &> /dev/null
mkdir -p /alidata/mysql
mkdir -p /alidata/mysql/data
mkdir -p /alidata/mysql/log
mkdir -p /alidata/install
mkdir -p /usr/local/mysql/bin
mkdir -p /alidata/mysql/mybinlog
#install mysql
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql

\cp -f /alidata/mysql/support-files/mysql.server /etc/init.d/mysqld
sed -i 's#^basedir=$#basedir=/alidata/mysql#' /etc/init.d/mysqld
sed -i 's#^datadir=$#datadir=/alidata/mysql/data#' /etc/init.d/mysqld
cat > /etc/my.cnf <<END
[client]
port	= 3306
socket	= /tmp/mysql.sock

[mysql]
prompt="\u@AM_MySQL-01 \R:\m:\s [\d]> "
no-auto-rehash

[mysqld]
#skip-grant-tables
user	= mysql
port	= 3306
basedir	= /alidata/mysql
datadir	= /alidata/mysql/data
socket	= /tmp/mysql.sock
character-set-server = utf8mb4
skip_name_resolve = 1
slow_query_log = 1
slow_query_log_file = /alidata/mysql/dataslow.log
log-error = /alidata/mysql/dataerror.log
long_query_time = 0.1
log_queries_not_using_indexes =1
log_throttle_queries_not_using_indexes = 60
server-id = 2 
log-bin = /alidata/mysql/mybinlog
binlog_format = row
sync_binlog = 1
expire_logs_days = 30
master_info_repository = TABLE
relay_log_info_repository = TABLE
gtid_mode = on
enforce_gtid_consistency = 1
# auto-increment-increment=3
log_slave_updates
sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION

[mysqldump]
quick
max_allowed_packet = 32M
END

chown -R mysql:mysql /alidata/mysql/
chown -R mysql:mysql /alidata/mysql/data/
chown -R mysql:mysql /alidata/mysql/log
/alidata/mysql/bin/mysqld --initialize-insecure --datadir=/alidata/mysql/data/  --user=mysql
ln -s /alidata/mysql/bin/mysqld /usr/local/mysql/bin/mysqld
chmod 755 /etc/init.d/mysqld
/etc/init.d/mysqld start

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/mysql/bin" &> /dev/null;then
	echo "export PATH=\$PATH:/alidata/mysql/bin" >> /etc/profile
fi
source /etc/profile
cd $DIR
bash

```

### 数据库备份

```shell
# 原库备份
mysqldump -h 10.116.246.2 -uroot -p -A --opt --default-character-set=utf8mb4 --single-transaction --hex-blob --skip-triggers max_allowed_packet=824288000 > mysqlmasterall.sql

# 导入到实例10.116.246.1
mysql -u -p < mysqlmasterall.sql
```

### 主从搭建

```shell
# 主：
1 二进制日志
server-id = 2 
log-bin = /alidata/mysql/mybinlog
2 gtid打开
gtid_mode = on
enforce_gtid_consistency = 1
3 授权
grant replication slave on *.* to slave@'10.116.246.1' identified by 'abc123';
grant replication slave on *.* to slave@'10.116.63.18' identified by 'abc123';

4 主机全备份
mysqldump -uroot -p -A --opt --default-character-set=utf8 --single-transaction --hex-blob --skip-triggers --master-data=2 --flush-logs --max_allowed_packet=824288000 > /alidata/install/backup/mysqlmasterall.sql

# 从：

1 二进制日志
server-id = 5 
log-bin = /alidata/mysql/mybinlog
2 gtid打开
gtid_mode = on
enforce_gtid_consistency = 1
auto-increment-increment=2
3 reset master
4 导入备份
mysql -u -p < /alidata/install/backup/mysqlmasterall.sql
4 声明
change master to master_host='10.116.246.1',master_user='slave',master_password='abc123',master_auto_position=1;

#主
change master to master_host='10.116.63.18',master_user='slave',master_password='abc123',master_auto_position=1;

```

#### 主从搭建成功

![](01.png)

![](02.png)

```shell
# 10.116.63.18
root@AM_MySQL-01 19:19:  [(none)]> create database test;
Query OK, 1 row affected (0.00 sec)

# 10.116.246.1
root@AM_MySQL-01 19:16:  [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| cbis_billing       |
| cbis_cloud_adapter |
| cbis_misc          |
| cbis_product       |
| cbis_security      |
| cbis_user          |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
11 rows in set (0.00 sec)

# 10.116.246.1
root@AM_MySQL-01 19:17:  [(none)]> create database test1;
Query OK, 1 row affected (0.01 sec)

# 10.116.63.18
root@AM_MySQL-01 19:20:  [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| cbis_billing       |
| cbis_cloud_adapter |
| cbis_misc          |
| cbis_product       |
| cbis_security      |
| cbis_user          |
| mysql              |
| performance_schema |
| sys                |
| test               |
| test1              |
+--------------------+
```

### 备份部署

#### 物理备份

##### 功能概述

- 实现MySQL数据库物理备份；
- 一周一全备，每天一增备；
- 自动清理过期备份（只保留最近的全备+增备）
- 备份任务每日定时执行

##### 安装percona-xtrabackupex

官网下载对应版本的percona-xtrabackupex软件

```shell
# /alidata/install/
# percona-xtrabackup-2.4.13-Linux-x86_64.libgcrypt11.tar
tar -zxf percona-xtrabackup-2.4.13-Linux-x86_64.libgcrypt11.tar
mv percona-xtrabackup-2.4.13-Linux-x86_64.libgcrypt11 perconaxtrabackup
```

##### 数据库授权

遵循最小权限原则，授予如下权限：

```shell
grant lock tables,reload,process,replication client,super on *.* to xtrabackup_user@'localhost' identified by 'abc123';

flush privileges;
```

##### 备份脚本

```shell
cd /alidata/xtrabackup_cron/
[root@node001 xtrabackup_cron]# ll
total 0
drwxr-xr-x 2 root root 42 Jan  24  2019 bin
drwxr-xr-x 2 root root 87 Jan  24  2019 conf
drwxr-xr-x 2 root root  6 Jan  24  2019 log
drwxr-xr-x 2 root root 82 Jan  24  2019 var
```

备份脚本结构：

- bin 备份的可执行脚本
- conf 备份的配置文件
- log 备份脚本的日志信息
- var 备份文件的索引信息

##### 备份测试明细

修改配置文件如下：

```shell
# mysql 用户名
user=xtrabackup_user

# mysql 密码
password=abc123

# 备份路劲
backup_dir=/alidata/backup

# percona-xtrabackup 备份软件路径
xtrabackup_dir=/alidata/install/perconaxtrabackup/

# 全备是在一周的第几天
full_backup_week_day=1

# 全量备信息名称 前缀
full_backup_prefix=full

# 增量备信息名称 前缀
increment_prefix=incr

# mysql配置文件
mysql_conf_file=/etc/my.cnf

# 错误日志文件(更具此文件知道备份是否成功)
# format:
# {week_day:1,dir:full/incr_2015-12-29_00-00-00_7,type:full/incr,date:2015-12-30}
error_log=../var/mysql_increment_hot_backup.err

# 索引文件
# format:
# {week_day:1,dir:full/incr_2015-12-29_00-00-00_7,type:full/incr}
index_file=../var/mysql_increment_hot_backup.index

```

执行备份脚本查看情况

```shell
[root@node001 backup]# ll
total 8
drwxr-xr-x 13 root root 4096 Jan 24 19:37 full_2019-01-24_19-37-24_4
drwxr-xr-x 13 root root 4096 Jan 24 19:39 incr_2019-01-24_19-39-03_4

[root@node001 log]# ll
total 188
-rw-r--r-- 1 root root 93845 Jan 24 19:37 full_2019-01-24_19-37-24_4.log
-rw-r--r-- 1 root root 94989 Jan 24 19:39 incr_2019-01-24_19-39-03_4.log
```

查看日志情况

![](05.png)

![](06.png)

备份成功

#### 逻辑备份

##### 创建逻辑备份账号

```shell
grant select,reload,show databases,super,lock tables,replication client,show view,event,file on *.* to backup@'localhost' identified by 'abc123';
```

##### 备份脚本

```shell
#!/bin/bash
# backup_mysql_all_databases.sh
# 备份目标 所有的库表
DBUser=backup
DBPwd=abc123
DBHost=localhost
BackupPath="/alidata/mysql_backup"
BackupFile="mysql.all."$(date +%y%m%d_%H)".sql"
BackupLog="mysql.all."$(date +%y%m%d_%H)".log"
# Backup Dest directory, change this if you have someother location
if !(test -d $BackupPath)
then
mkdir $BackupPath -p
fi
cd $BackupPath
a=`mysqldump -u$DBUser -p$DBPwd -h$DBHost -A --opt --set-gtid-purged=OFF --default-character-set=utf8 --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 > "$BackupPath"/"$BackupFile" 2> /dev/null; echo $?`
if [ $a -ne 0 ]
then
 echo "$(date +%y%m%d_%H:%M:%S) 备份失败" >> $BackupLog
else
 echo "$(date +%y%m%d_%H:%M:%S) 备份成功" >> $BackupLog
fi
#Delete sql type file & log file
find "$BackupPath" -name "mysql.all*[log,sql]" -type f -mtime +3 -exec rm -rf {} \;



```

##### 测试

```shell
[root@node001 install]# cd ../mysql_backup/
[root@node001 mysql_backup]# ll
total 125688
-rw-r--r-- 1 root root 42896313 Jan 24 18:40 mysql.all.190124_18.sql
-rw-r--r-- 1 root root       29 Jan 24 19:25 mysql.all.190124_19.log
-rw-r--r-- 1 root root 42899356 Jan 24 19:25 mysql.all.190124_19.sql
-rw-r--r-- 1 root root 42897875 Jan 24 18:53 mysqlmasterall.sql
[root@node001 mysql_backup]# cat mysql.all.190124_19.log 
190124_19:25:26 备份成功
```

逻辑备份备份成功

#### 创建定时任务

```shell
0 8,10,12,15,18,21 * * * bash /alidata/install/mysqlbackup.sh
0 23 * * * bash /alidata/xtrabackup_cron/bin/mysql_increment_hot_backup.sh &> /alidata/install/xtrabackup_log
```

### 目录明细

| 安装目录     | /alidata/mysql                  |
| -------- | ------------------------------- |
| 数据目录     | /alidata/mysql/data             |
| 二进制日志    | /alidata/mysql/mybinlog         |
| 错误日志     | /alidata/mysql/dataerror.log    |
| 慢查询日志    | /alidata/mysql/dataslow.log     |
| 逻辑备份安装目录 | /alidata/install/mysqlbackup.sh |
| 逻辑备份存放目录 | /alidata/mysql_backup           |
| 物理备份安装目录 | /alidata/xtrabackup_cron        |
| 物理备份存放目录 | /alidata/backup                 |



