# RDS 与自建数据库搭建主从

[TOC]

## 背景

由于RDS是在开源数据库基础上进行了二次开发，且RDS数据库的表全部是innodb引擎的，搭建RDS到自建数据库的主从的话会因为版本不兼容导致问题（开源的数据库的系统表有些事myisam引擎的）

通过RDS全备进行恢复到自建数据库后搭建主从，自建库没法进行权限管理，因为自建数据库的系统表是myisam引擎，而通过RDS恢复的是innodb引擎的。经过测试，Percona公司的数据库与RDS的兼容性更高。

本文为破解RDS限制搭建RDS与自建数据库的主从

## 初步探索

RDS For MySQL 5.7 到自建MySQL 5.7.20/Percona Server5.7.20 搭建主从同步架构:

- 配置从库不同步RDS主库的系统表
```shell
# skip rep(数据库配置文件中加入)
replicate_wild_ignore_table=mysql.%
replicate_wild_ignore_table=sys.%
replicate_wild_ignore_table=information_schema.%
```

- **非系统库数据同步正常**
- 从库无法执行grant命令，即无法添加授权信息
- 从库无法对系统表mysql.user表执行insert操作
- 从库无法对系统表mysql.user表执行updat操作



## 破解方法

经过多次验证发现，RDS使用的应该是Percona的数据库服务器，并进行了二次开发，破解的方法为**物理备份还原后，手动修改系统库**。通过手动删除自建数据库与RDS有差别的系统表，备份RDS有差别的表机构与数据，手动修改表引擎后再导入自建库

```shell
1 通过RDS全备恢复数据到自建数据库（启服务，登陆，确认没问题进行第二步）
2 清除本地与RDS不同的系统表（删除表，删除表文件）
3 备份RDS与自建数据库有差别的表结构，表数据
4 手动修改表引擎以后导入数据库，重新启动服务
5 配置主从
```

## 步骤

### 1 自建MySQL安装

```shell
wget "https://raw.githubusercontent.com/BoobooWei/DBA_Mysql/master/scripts/auto_intall/install_perconaxerver5.7.20_centos7.sh"
bash install_perconaxerver5.7.20_centos7.sh
```

软件架构如下：

| 自建数据库软件架构     | 说明                        |
| ------------- | ------------------------- |
| 安装目录          | /alidata/mysql            |
| 数据目录          | /alidata/mysql/data       |
| 守护进程          | /alidata/mysql/bin/mysqld |
| 监听端口          | 3306                      |
| 配置文件          | /etc/my.cnf               |
| RDS备份文件下载解压目录 | /alidata/mysql/data       |

### 2 全备份文件下载并解压

登陆到阿里云RDS控制台，选择最近的全备份进行下载，全备份时间不能超过binlog设置的过期时间。

```shell
curl -o "RDS.tar.gz" "http://rdsbak-shanghai-v2.oss-cn-shanghai-internal.aliyuncs.com/asldkjalsdkjflasdjf"

或 wget -c "http://rdsbak-shanghai-v2.oss-cn-shanghai-internal.aliyuncs.com/asldkjalsdkjflasdjf" -O RDS.tar.gz
```

下载Percona工具以及阿里云专用解压工具

```shell
wget https://raw.githubusercontent.com/BoobooWei/DBA_Mysql/master/scripts/auto_intall/install_rds_pxc_centos7.sh
# 包含Percona备份工具和RDS专门解压工具
目前备份下载可直接tar解压
```

开始解压全备份数据

```shell
# 全备份恢复
bash rds_backup_extract.sh -f RDS.tar.gz -C /alidata/mysql/xtrabackup_data
# applay-log
innobackupex --apply-log /alidata/mysql/xtrabackup_data
chown mysql. -R /alidata/mysql/xtrabackup_data
```

### 3 将全备份数据恢复

```shell
/alidata/mysql/support-files/mysql.server stop
```

将初始化的数据库数据目录（data本身有数据）重命名为data_back

```shell
mv /alidata/mysql/data/ /alidata/mysql/data_back
```

将pxc恢复的全备份文件目录重命名为data

```shell
mv /alidata/mysql/xtrabackup_data /alidata/mysql/data
```

启动本地数据库

```shell
/alidata/mysql/support-files/mysql.server start
```

配置主从

### 报错排查

```shell
# 启动报错排查
1 为避免版本问题，需修改backup-my.cnf参数
 vi /home/mysql/data/backup-my.cnf
注释
innodb_fast_checksum
innodb_page_size
innodb_log_block_size  

2 根据以下参数修改配置文件  
 
   server-id ###Slave配置需要
   master-info-repository=file### Slave配置需要
   relay-log-info_repository=file### Slave配置需要
   binlog-format=ROW### Slave配置需要
   gtid-mode=on###开启GTID需要
   enforce-gtid-consistency=true###开启GTID需要
   innodb_data_file_path=ibdata1:200M:autoextend###使用RDS的物理备份中的backup-my.cnf参数
   innodb_log_files_in_group=2###使用RDS的物理备份中的backup-my.cnf参数
   innodb_log_file_size=524288000###使用RDS的物理备份中的backup-my.cnf参数

# change 报错排查
ERROR 1794 (HY000): Slave is not configured or failed to initialize properly. You must at least set –server-id to enable either a master or a slave. Additional error messages can be found in the MySQL error log.

#原因是由于RDS的备份文件中包含了RDS的主从复制关系，需要把这些主从复制关系清理掉，清理方法：
truncate table  slave_relay_log_info;
truncate table  mysql.slave_master_info;
truncate table  mysql.slave_worker_info;

最后重启主从
```

### 4 手动修改系统库

备份RDS的元数据（与本地有差别的表结构，都是mysql库中的表）

```shell
mysqldump -u$rds_user -p$rds_pwd -h$rds_url -P $rds_port mysql columns_priv db event func ndb_binlog_index proc procs_priv proxies_priv tables_priv user  --set-gtid-purged=OFF --opt --default-character-set=utf8  --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 -d > mysql.sys.meta.sql
```

备份rds差异表的数据

```shell
mysqldump -u$rds_user -p$rds_pwd -h$rds_url -P $rds_port mysql columns_priv db event func ndb_binlog_index proc procs_priv proxies_priv tables_priv user  --set-gtid-purged=OFF --opt --default-character-set=utf8  --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 -t > mysql.sys.data.sql
```

删除本地恢复的差别表

```shell
cat > local_drop.sql << ENDF
drop table columns_priv ;
drop table db;
drop table event;
drop table func;
drop table ndb_binlog_index;
drop table proc;
drop table procs_priv;
drop table proxies_priv;
drop table tables_priv;
drop table user;
ENDF
mysql mysql < local_drop.sql
```

删除本地文件

```shell
cd $datadir
rm -rf columns_priv\.*
rm -rf db\.*
rm -rf event\.*
rm -rf func\.*
rm -rf ndb_binlog_index\.*
rm -rf proc\.*
rm -rf procs_priv\.*
rm -rf proxies_priv\.*
rm -rf tables_priv\.*
rm -rf user\.*
```

导入元数据

```shell
sed -i 's/ENGINE=InnoDB/ENGINE=myisam/' mysql.sys.meta.sql
mysql mysql < mysql.sys.meta.sql
导入数据
mysql mysql < mysql.sys.data.sql
添加权限
cat > local_grant.sql << ENDF
grant all on *.* to 'test'@'%' identified by 'abc123';
update mysql.user set authentication_string=password('Uploo00king') where user='aliyun_root';
ENDF
 
mysql < local_grant.sql
# aliyun_root用户为阿里云的最大权限用户，在RDS上不能用
GRANT all ON *.* TO root@'%' identified by 'Waqb1314' WITH GRANT OPTION;
创建能授权的用户，一般主从完成后创建root用户，没有授权功能
```

重新启动服务

```shell
/alidata/mysql/support-files/mysql.server restart
```

### 5 配置主从

停止本地数据库的replication线程，并清空相关配置

```shell
stop slave;
reset slave all;
reset master;
```

修改GTID参数

```shell
SET GLOBAL gtid_purged='$gtid';
# 在备份文件的xtrabackup_slave_info文件中查看
```



配置主库同步信息

需要事先在主库RDS上创建复制权限的账号，如果RDS使用的一般用户，则直接创建只读账号即可，如果RDS使用高级用户，则使用grant命令创建replication slave的权限即可。

```shell
change master to master_host='$url',master_user='$user',master_password='$pwd',master_auto_position=1;
```

启动replication

```shell
start slave;
```

查看主从明细
```shell
show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: 
                  Master_Host: rm-uf679e820jx04jnvxvo.mysql.rds.aliyuncs.com
                  Master_User: rep_slave
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: 
          Read_Master_Log_Pos: 4
               Relay_Log_File: iZuf688p52tbipr2komnw2Z-relay-bin.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: 
             Slave_IO_Running: No
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: mysql.%,sys.%,information_schema.%
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 0
              Relay_Log_Space: 154
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 1236
                Last_IO_Error: Got fatal error 1236 from master when reading data from binary log: 'The slave is connecting using CHANGE MASTER TO MASTER_AUTO_POSITION = 1, but the master has purged binary logs containing GTIDs that the slave requires.'
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1649749997
                  Master_UUID: 1e906292-db2b-11e8-a3d2-506b4b3fc346
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 181113 22:39:55
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 1e906292-db2b-11e8-a3d2-506b4b3fc346:1-175761
                Auto_Position: 1
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
1 row in set (0.00 sec)


# 主从中有两个参数 
Retrieved_Gtid_Set：代表从主库拉取的事务
Executed_Gtid_Set：代表已经执行完的事务（show slave status 看的这个事务号是我自己执行的，但是事务号对应的是主库的事务号）

```

## 注意的点

三个参数

```shell
# show variables like "gtid_purged"看到的是二进制日志中已经清理掉的事务号
# Retrieved_Gtid_Set：代表从主库拉取的事务
# Executed_Gtid_Set：代表已经执行完的事务
 主从关系中，如果从库报错gtid已经被清理，以下处理思路
 1 查看全备份中的事务号
 2 到主库查看被清理的事务号，如果全备份中的事务号比主库中的小，则会报错，因为当前事务在主库的二进制文件中已经被清理
 3 重新备份，要保证备份下来的事务号要大于主库清理的事务号，如果擅自在从库上重新声明gtid为主库清理的gtid号的话会造成数据丢失，在全备以后到清理之前那段数据就会丢失

# 可以查看主库当前执行到哪个事务号，用show master status\G;查看
 查到的Executed_Gtid_Set指的就是当前库执行到的事务号
 show slave status\G;查看到的Executed_Gtid_Set是当前执行的事务（不过事务号是主库的事务号，不是本地数据的事务号）和他的主库用master查看的是一样的
 # 如果是主库，查看本地数据库执行的事务号就用master
 # 如果是从库，那就看slave
```

