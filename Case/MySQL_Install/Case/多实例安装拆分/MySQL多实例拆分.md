# MySQL5.7 多实例拆分

## 安装多实例

##  MySQL-03

### 1 停服务 
/alidata/mysql/support-files/mysqld_multi  --defaults-extra-file=/etc/my.cnf stop 1,2

lsof /dev/vdb
![](pic1\01.png)

### 2 修改配置文件

  vim /etc/rc.local

![](pic1\02.png)

### 3 umount 卸载

![](pic1\03.png)

### 4 控制台卸载磁盘

![](pic1\04.png)

### 5 修改配置文件

vim /etc/my.cnf (改成单实例的)
```shell
[mysqld]
user            = mysql
pid-file        = MySQL-3306.pid
socket          = /tmp/mysql.sock
port            = 3306
basedir         = /alidata/mysql
datadir         = /alidata/mysql/data

#tmpdir          = /tmp/mysql3306
#lc-messages-dir = /alidata/mysql/share/
bind-address    = 0.0.0.0
explicit_defaults_for_timestamp
federated
lower_case_table_names  = 1
table_open_cache        = 16384
table_definition_cache  = 16384
max_connections = 5000
character-set-server    = utf8mb4
collation-server        = utf8mb4_general_ci
#innodb_buffer_pool_size = 12288M
key_buffer_size         = 8192M
join_buffer_size        = 32M
sort_buffer_size        = 32M
tmp_table_size          = 128M
read_buffer_size        = 8M
max_allowed_packet      = 16M
read_rnd_buffer_size    = 32M
group_concat_max_len    = 4194304
max_connections         = 4096
myisam_sort_buffer_size = 128M
thread_stack            = 192K
thread_cache_size       = 32
query_cache_limit       = 2M
query_cache_size        = 128M
query_cache_type        = OFF
event_scheduler         = ON
myisam-recover-options  = BACKUP
log_error               = /alidata/mysql/data/dataerror.log
log_timestamps          = SYSTEM
slow-query-log          = On
slow_query_log_file     = /alidata/mysql/data/dataslow.log
long_query_time         = 1
server-id               = 1843306
expire_logs_days        = 3
log_bin                 = /alidata/mysql/data/mybinlog
binlog-ignore-db        = mysql  
binlog-ignore-db        = sys
binlog-ignore-db        = information_schema
binlog-ignore-db        = performance_schema
binlog-ignore-db        = backup
binlog-ignore-db        = tmp
binlog-ignore-db        = remote_database
max_binlog_size         = 1024M
expire_logs_days        = 3
sql-mode                = "NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
[mysqldump]
quick
max_allowed_packet = 32M
```
###后续操作
```shell
cp -p /alidata/mysql/supportfiles/mysql.server /etc/init.d/mysqld
ln -s /data/mysql/bin/mysqld /usr/local/mysql/bin/mysqld
chmod 755 /etc/init.d/mysqld
/alidata/mysql/support-files/mysql.server start
```
## mysql-01

1 停服务
2 检查磁盘使用情况
lsof /dev/vdb

3 更改配置文件
vim /etc/rc.local
注释

4 umount /dev/vdb
5 控制台挂载

![](pic1\05.png)

6 mount 挂载

![](pic1\07.png)

7 vim /etc/my.cnf

```shell
[mysqld]
user            = mysql
pid-file        = MySQL-3307.pid
socket          = /tmp/mysql3307.sock
port            = 3307
basedir         = /alidata/mysql
datadir         = /data/data3307
#tmpdir          = /tmp/mysql3307
max_connections = 5000
lc-messages-dir = /usr/share/mysql
bind-address    = 0.0.0.0
explicit_defaults_for_timestamp
lower_case_table_names  = 1
event_scheduler         = 1
character-set-server    = utf8mb4
collation-server        = utf8mb4_general_ci
slave-skip-errors       = 1062
federated
log_slave_updates  = ON
key_buffer_size         = 512M
join_buffer_size        = 32M
sort_buffer_size        = 32M
tmp_table_size          = 128M
read_buffer_size        = 8M
max_allowed_packet      = 16M
read_rnd_buffer_size    = 32M
group_concat_max_len    = 4194304
max_connections         = 4096
myisam_sort_buffer_size = 128M
thread_stack            = 192K
thread_cache_size       = 32
myisam-recover-options  = BACKUP
query_cache_limit       = 2M
query_cache_size        = 128M
query_cache_type        = OFF
log_error               = /data/data3307/dataerror3307.log
log_timestamps          = SYSTEM
slow-query-log          = On
slow_query_log_file     = /data/data3307/dataslow3307.log
long_query_time         = 1
server-id               = 1843307
#relay-log               = /data/data3307/relay-bin
expire_logs_days        = 3
log_bin                 = /data/data3307/mybinlog
binlog-ignore-db        = mysql
binlog-ignore-db        = sys
binlog-ignore-db        = information_schema
binlog-ignore-db        = performance_schema
symbolic-links          = 0
sql-mode                = "NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
[mysqldump]
quick
max_allowed_packet = 32Matadir    = /data/data3307
log_error = /data/data3307/hjx02.error
innodb_buffer_pool_size=8M

```



## 后续操作
```shell
cp -p /alidata/mysql/support-files/mysql.server /etc/init.d/mysqld
ln -s /data/mysql/bin/mysqld /usr/local/mysql/bin/mysqld
chmod 755 /etc/init.d/mysqld
/alidata/mysql/support-files/mysql.server start
```
![](pic1\08.png)

### 配置文件更改

vim /etc/rc.local
```shell
mount /dev/vdc /data
/alidata/mysql/support-files/mysql.server start
```

 ###登录
 mysql -u -p -S /tmp/mysql3307.sock

![](pic1\09.png)




