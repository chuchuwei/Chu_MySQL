

## RDS备份还原到自建数据库

```shell
# mysqldump备份还原：（rds逻辑备份不包含系统库，还原的时候需要指定数据库）
  1）下载 
  wget -c '<数据备份文件外网下载地址>' -O <自定义文件名>.tar.gz
  2）解压
  tar -xf 文件
  gunzip 文件
  3导入
  导入之前先把之前的gtid有关的清理掉，reset master;不然导入的时候会报错说这个值不为空不能导入
 mysqldump -u -p 库 < 文件

# 物理备份还原
 1）下载
  wget -c '<数据备份文件外网下载地址>' -O <自定义文件名>.tar.gz
 2）解压
 3）导入
 innobackupex --defaults-file=/alidata/mysql/data/backup-my.cnf --apply-log /alidata/mysql/data
 4）更改权限
   chown mysql. -R /alidata/mysql/data

# 在此之前需要这个文档 https://yq.aliyun.com/articles/9044
需要在my.cnf中配置的一些关键参数：
配置文件中的参数上面的部分和slave相关的是配置主从时需要的，如果只是导入数据重启的话需要加入物理备份文件中的后三条就可以了(数据库已有的ibdata1大小以及redo信息)
   server-id ###Slave配置需要
   master-info-repository=file### Slave配置需要
   relay-log-info_repository=file### Slave配置需要
   binlog-format=ROW### Slave配置需要
   gtid-mode=on###开启GTID需要
   enforce-gtid-consistency=true###开启GTID需要
   innodb_data_file_path=ibdata1:200M:autoextend###使用RDS的物理备份中的backup-my.cnf参数
   innodb_log_files_in_group=2###使用RDS的物理备份中的backup-my.cnf参数
   innodb_log_file_size=524288000###使用RDS的物理备份中的backup-my.cnf参数
   
 5)为避免版本问题，需修改backup-my.cnf参数
# vi /home/mysql/data/backup-my.cnf
注释
innodb_fast_checksum
innodb_page_size
innodb_log_block_size

 6）启动
 /etc/init.d/mysqld start
 7）登录
 mysql -uroot
 8）恢复完成后，表mysql.user中不包含在RDS实例中创建的用户
没有rds创建的用户的信息
如果需要的话需要新建。在新建用户前，执行如下命令
  delete from mysql.db where user<>'root' and char_length(user)>0;
  delete from mysql.tables_priv where user<>'root' and char_length(user)>0;
  flush privileges;

```

## 导入过程中的问题及解决办法

### 报错

```shell
[Err] 1227 - Access denied; you need (at least one of) the SUPER privilege(s) for this operation --常见于 RDS MySQL 5.6

ERROR 1725 (HY000) at line 1936: OPERATION need to be executed set by ADMIN --常见于 RDS MySQL 5.5
```

错误场景

```shell
在创建 存储过程、函数、触发器、事件、视图的时候出现这个错误。

从本地数据库导出 SQL，在 RDS 上应用该 SQL 的时候出现该错误。

从 RDS MySQL 5.6 实例下载逻辑备份，导入到 RDS 或本地数据库中。
```



### 错误原因

- 导入RDS MySQL 实例：SQL 语句中含有需要 Supper 权限才可以执行的语句，而 RDS MySQL不提供 Super 权限，因此需要去除这类语句。
- 本地 MySQL 实例没有启用 GTID

### 解决

#### 去除DEFINER子句

检查 SQL 文件，去除下面类似的子句

```shell
DEFINER=`root`@`%` 
```

在 Linux 平台下，可以尝试使用下面的语句去除：

```shell
mysql中 view、trigger、function、procedure、event。
sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/ ' your.sql > your_revised.sql
正确的： sed "s/`awk '/DEFINER=/ {print $2}' authorize-functionnow.sql|head -1`//" authorize-functionnow.sql
 # 错误的：sed -n "s/`awk '/DEFINER=/ {print $2}' authorize-functionnow.sql|head -1`//p" authorize-functionnow.sql
 因为-n和p的话是只显示修改的那行内容，所以其余的行都没有了

# 加-n p的
CREATE xxx FUNCTION `getChildrenNode`(`rank_id` BIGINT) RETURNS varchar(1000) CHARSET utf8mb4
CREATE xxx FUNCTION `getDtpChildNode`(`dep_id` bigint) RETURNS varchar(1000) CHARSET utf8mb4
CREATE xxx FUNCTION `getRankUserNode`(`user_id` BIGINT,`rank_id` bigint,`department_id` bigint) RETURNS mediumtext CHARSET utf8mb4
CREATE xxx FUNCTION `queryBdmWorkDuration`(did bigint(36),fid bigint(36),ctime varchar(50)) RETURNS varchar(2000) CHARSET utf8mb4
CREATE xxx FUNCTION `queryBdmWorkDuration1`(did bigint(36),fid bigint(36),ctime varchar(50)) RETURNS varchar(2000) CHARSET utf8mb4
CREATE xxx FUNCTION `queryChildRankIds`(powerId VARCHAR(2000)) RETURNS varchar(2000) CHARSET utf8mb4
CREATE xxx FUNCTION `queryChildRankRefIds`(fid VARCHAR(2000)) RETURNS varchar(2000) CHARSET utf8mb4


# 不加-np的
CREATE xxx FUNCTION `queryChildRankRefIds`(fid VARCHAR(2000)) RETURNS varchar(2000) CHARSET utf8mb4
BEGIN
DECLARE sTemp VARCHAR(2000);
DECLARE sTempChd VARCHAR(2000);
SET sTemp = '';
SET sTempChd = cast(fid as CHAR);
WHILE sTempChd is not NULL DO
SET sTemp = CONCAT(sTemp, ',', sTempChd);
SELECT group_concat(id) INTO sTempChd FROM tb_actionnow_rank_user where FIND_IN_SET(father_id,sTempChd)>0;
END WHILE;
return sTemp;
END
```

#### 去除GTID_PURGED子句

检查 SQL 文件，去除下面类似的语句

```SHELL
SET @@GLOBAL.GTID_PURGED='d0502171-3e23-11e4-9d65-d89d672af420:1-373,
d5deee4e-3e23-11e4-9d65-d89d672a9530:1-616234';
```

在 Linux 平台，可以使用下面的语句去除

```shell
awk '{ if (index($0,"GTID_PURGED")) { getline; while (length($0) > 0) { getline; } } else { print $0 } }' your.sql | grep -iv 'set @@' > your_revised.sql
```

#### 检查修改后的文件

修改完毕后，通过下面的语句检查是否合乎要求。

```shell
egrep -in "definer|set @@" your_revised.sql
```

**如果上面的语句没有输出，说明 SQL 文件符合要求。**