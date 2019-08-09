# 特步中国线下IDC环境新会员系统数据节点宕机

[TOC]

## 表象

2019-07-18早上10点特步中国反馈`新会员系统`xbbzjk001-3306节点连接不上，报错如下：

![](D:\智能团队相关资料\06_项目详情\特步\线下运维资料\线下运维事件资料\2019-07-1973.62实例损坏修复\pic\1.jpg)

## 数据库架构

![](D:\智能团队相关资料\06_项目详情\特步\线下运维资料\线下运维事件资料\2019-07-1973.62实例损坏修复\pic\2.jpg)



## 故障处理步骤

### 日志分析

- xbbzjk001-3306错误日志

```shell
2019-07-05 16:29:08 7fa1ccbe9700 InnoDB: Error: page 585 log sequence number 160429663
InnoDB: is in the future! Current system log sequence number 2451696.
InnoDB: Your database may be corrupt or you may have copied the InnoDB
InnoDB: tablespace but not the InnoDB log files. See
InnoDB: http://dev.mysql.com/doc/refman/5.6/en/forcing-innodb-recovery.html
InnoDB: for more information.
2019-07-05 16:30:13 7fa1d5041700 InnoDB: Error: page 323 log sequence number 437270440
InnoDB: is in the future! Current system log sequence number 4241118.
InnoDB: Your database may be corrupt or you may have copied the InnoDB
InnoDB: tablespace but not the InnoDB log files. See
InnoDB: http://dev.mysql.com/doc/refman/5.6/en/forcing-innodb-recovery.html
InnoDB: for more information.

2019-07-17 14:41:32 16761 [Warning] Did not write failed 'GRANT SELECT, RELOAD, PROCESS, FILE, SHOW DATABASES, SUPER, LOCK TABLES, REPLICATION CLIENT, SHOW VIEW, EVENT ON *.* TO 'cc_monitor'@'192.168.80.10' IDENTIFIED BY PASSWORD 'monitor@CC!!'' into binary log while granting/revoking privileges in databases.
2019-07-17 14:41:34 16761 [Warning] 'proxies_priv' entry '@ root@xhrdb001' ignored in --skip-name-resolve mode.
2019-07-17 14:42:43 16761 [Warning] 'proxies_priv' entry '@ root@xhrdb001' ignored in --skip-name-resolve mode.
2019-07-17 15:00:00 16761 [Warning] InnoDB: Cannot open table hash_realtime_rpt_new_ujiq_0008/__drds__system__lock__ from the internal data dictionary of InnoDB though the .frm file for the table exists. See http://dev.mysql.com/doc/refman/5.6/en/innodb-troubleshooting.html for how you can resolve the problem.
2019-07-17 15:00:00 16761 [Warning] InnoDB: Cannot open table hash_realtime_rpt_new_ujiq_0008/ch_bankaccount_et from the internal data dictionary of InnoDB though the .frm file for the table exists. See http://dev.mysql.com/doc/refman/5.6/en/innodb-troubleshooting.html for how you can resolve the problem.
2019-07-17 15:00:00 16761 [Warning] InnoDB: Cannot open table hash_realtime_rpt_new_ujiq_0008/ch_calculate_org_et from the internal data dictionary of InnoDB though the .frm file for the table exists. See http://dev.mysql.com/doc/refman/5.6/en/innodb-troubleshooting.html for how you can resolve the problem.
2019-07-17 15:00:00 16761 [Warning] InnoDB: Cannot open table hash_realtime_rpt_new_ujiq_0008/ch_customer_credit_limit_et from the internal data dictionary of InnoDB though the .frm file for the table exists. See http://dev.mysql.com/doc/refman/5.6/en/innodb-troubleshooting.html for how you can resolve the problem.
2019-07-17 18:40:00 16761 [Warning] InnoDB: Cannot open table xtep_hr_backup_jlvl_0007/txc_undo_log from the internal data dictionary of InnoDB though the .frm file for the table exists. See http://dev.mysql.com/doc/refman/5.6/en/innodb-troubleshooting.html for how you can resolve the problem.

`190717 18:40:46 mysqld_safe Number of processes running now: 0`
`190717 18:40:46 mysqld_safe mysqld restarted`
2019-07-17 18:40:48 0 [Note] /opt/mysql/bin/mysqld (mysqld 5.6.30-log) starting as process 10388 ...
2019-07-17 18:40:48 10388 [Note] Plugin 'FEDERATED' is disabled.
2019-07-17 18:40:48 7fb4aeb7f740 InnoDB: Warning: Using innodb_additional_mem_pool_size is DEPRECATED. This option may be removed in future releases, together with the option innodb_use_sys_malloc and with the InnoDB's internal memory allocator.
2019-07-17 18:40:48 10388 [Note] InnoDB: Using atomics to ref count buffer pool pages
2019-07-17 18:40:48 10388 [Note] InnoDB: The InnoDB memory heap is disabled
2019-07-17 18:40:48 10388 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2019-07-17 18:40:48 10388 [Note] InnoDB: Memory barrier is not used
2019-07-17 18:40:48 10388 [Note] InnoDB: Compressed tables use zlib 1.2.3
2019-07-17 18:40:48 10388 [Note] InnoDB: Using Linux native AIO
2019-07-17 18:40:48 10388 [Note] InnoDB: Using CPU crc32 instructions
2019-07-17 18:40:48 10388 [Note] InnoDB: Initializing buffer pool, size = 50.0G
2019-07-17 18:40:59 10388 [Note] InnoDB: Completed initialization of buffer pool
2019-07-17 18:41:01 10388 [Note] InnoDB: Highest supported file format is Barracuda.
2019-07-17 18:41:01 10388 [Note] InnoDB: Log scan progressed past the checkpoint lsn 1008066336404
2019-07-17 18:41:01 10388 [Note] InnoDB: Database was not shutdown normally!
2019-07-17 18:41:01 10388 [Note] InnoDB: Starting crash recovery.
2019-07-17 18:41:01 10388 [Note] InnoDB: Reading tablespace information from the .ibd files...
2019-07-17 18:41:06 10388 [ERROR] InnoDB: Attempted to open a previously opened tablespace. Previous tablespace hash_realtime_rpt_new_ujiq_0012/wm_out_receipt_detail_et uses space ID: 538 at filepath: ./hash_realtime_rpt_new_ujiq_0012/wm_out_receipt_detail_et.ibd. Cannot open tablespace xtep_hr/flow_entry which uses space ID: 538 at filepath: ./xtep_hr/flow_entry.ibd
2019-07-17 18:41:06 7fb4aeb7f740  InnoDB: Operating system error number 2 in a file operation.
InnoDB: The error means the system cannot find the path specified.
InnoDB: If you are installing InnoDB, remember that you must create
InnoDB: directories yourself, InnoDB does not create them.

2019-07-17 18:40:48 10388 [Note] Plugin 'FEDERATED' is disabled.
2019-07-17 18:40:48 7fb4aeb7f740 InnoDB: Warning: Using innodb_additional_mem_pool_size is DEPRECATED. This option may be removed in future releases, together with the option innodb_use_sys_malloc and with the InnoDB's internal memory allocator.
2019-07-17 18:40:48 10388 [Note] InnoDB: Using atomics to ref count buffer pool pages
2019-07-17 18:40:48 10388 [Note] InnoDB: The InnoDB memory heap is disabled
2019-07-17 18:40:48 10388 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2019-07-17 18:40:48 10388 [Note] InnoDB: Memory barrier is not used
2019-07-17 18:40:48 10388 [Note] InnoDB: Compressed tables use zlib 1.2.3
2019-07-17 18:40:48 10388 [Note] InnoDB: Using Linux native AIO
2019-07-17 18:40:48 10388 [Note] InnoDB: Using CPU crc32 instructions
2019-07-17 18:40:48 10388 [Note] InnoDB: Initializing buffer pool, size = 50.0G
2019-07-17 18:40:59 10388 [Note] InnoDB: Completed initialization of buffer pool
2019-07-17 18:41:01 10388 [Note] InnoDB: Highest supported file format is Barracuda.
2019-07-17 18:41:01 10388 [Note] InnoDB: Log scan progressed past the checkpoint lsn 1008066336404
2019-07-17 18:41:01 10388 [Note] InnoDB: Database was not shutdown normally!
2019-07-17 18:41:01 10388 [Note] InnoDB: Starting crash recovery.
2019-07-17 18:41:01 10388 [Note] InnoDB: Reading tablespace information from the .ibd files...
2019-07-17 18:41:06 10388 [ERROR] InnoDB: Attempted to open a previously opened tablespace. Previous tablespace hash_realtime_rpt_new_ujiq_0012/wm_out_receipt_detail_et uses space ID: 538 at filepath: ./hash_realtime_rpt_new_ujiq_0012/wm_out_receipt_detail_et.ibd. Cannot open tablespace xtep_hr/flow_entry which uses space ID: 538 at filepath: ./xtep_hr/flow_entry.ibd
2019-07-17 18:41:06 7fb4aeb7f740  InnoDB: Operating system error number 2 in a file operation.
InnoDB: The error means the system cannot find the path specified.
InnoDB: If you are installing InnoDB, remember that you must create
InnoDB: directories yourself, InnoDB does not create them.



```

### 监控告警

![](D:\智能团队相关资料\06_项目详情\特步\线下运维资料\线下运维事件资料\2019-07-1973.62实例损坏修复\pic\3.jpg)

### 故障原因

*从日志当中看到7月5号就开始报错了，报错根本原因是InnoDB日志文件(重做日志)与数据文件不同步。7月17号晚18：40：46MySQL发生了restartd在此时收到监控告警该台服务器内存超过90%以上，Linux系统自动将MySQL进程关闭，由于表空间损坏无法将MySQL实例正常启动*

## 修复表空间

| 序列 | 步骤                                                         |
| ---- | ------------------------------------------------------------ |
| 1    | 启动新实例                                                   |
| 2    | 创建数据库                                                   |
| 3    | 获取原库DDL                                                  |
| 4    | 将DDL导入新实例新创建的数据库当中，分布式数据库0库当中需创建以下三张表<br />`sequence`、`sequence_opt`、`__drds__system__lock__` |
| 5    | 卸载表空间 ALTER TABLE [table_name] DISCARD TABLESPACE;      |
| 6    | 将原实例当中ibd文件拷贝到新实例新创建数据库的data目录下      |
| 7    | 加载表空间 ALTER TABLE [table_name] IMPORT TABLESPACE;       |
| 8    | 将原实例的权限表逻辑导出导入至新实例,并刷新权限mysql.user\|mysql.db\|mysql.tables_priv\|mysql.columns_priv\|mysql.procs_priv |
| 9    | 停止原实例和新实例                                           |
| 10   | 原实例和新实例端口互换，修改配置文件中所有相关目录以及mysql-bin.index当中对应文件目录 |
|      | 启动实例，并验证                                             |

*参考地址：<https://help.aliyun.com/document_detail/29675.html>*

```shell
--启动新实例
mkdir /home/my3308
mkdir -p /home/my3308/{data,log,tmp,run}
chown -R mysql:mysql /home/my3308
cd /opt/mysql
/opt/mysql/scripts/mysql_install_db --datadir=/home/my3308/data --user=mysql
./bin/mysqld_safe --defaults-file=/home/my3308/my.cnf &

--实例登录
[root@xbbzjk001 mysql]# mysql -uroot -p -h127.0.0.1 -P3308
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.6.30-log MySQL Community Server (GPL)

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 

--创建对应数据库
create database xcrm          ;
create database xcrm_wxsn_0000;
create database xcrm_wxsn_0001;
create database xcrm_wxsn_0002;
create database xcrm_wxsn_0003;
create database xcrm_wxsn_0004;
create database xcrm_wxsn_0005;
create database xcrm_wxsn_0006;
create database xcrm_wxsn_0007;

--从其他正常实例中导出表结构
mysqldump -h127.0.0.1  -P3308 -uroot --opt --set-gtid-purged=OFF --default-character-set=utf8  --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 -d xcrm_wxsn_0016 > xcrm_wxsn_0016.sql

--导入创建的数据库中
mysql -uroot -p -h127.0.0.1 -P3308 xcrm < xcrm_wxsn_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 xcrm_wxsn_0000 < xcrm_wxsn_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 xcrm_wxsn_0001 < xcrm_wxsn_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 xcrm_wxsn_0002 < xcrm_wxsn_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 xcrm_wxsn_0003 < xcrm_wxsn_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 xcrm_wxsn_0004 < xcrm_wxsn_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 xcrm_wxsn_0005 < xcrm_wxsn_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 xcrm_wxsn_0006 < xcrm_wxsn_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 xcrm_wxsn_0007 < xcrm_wxsn_0016.sql

--`分布式数据库0库需要创建三张表sequence、sequence_opt、__drds__system__lock__`
CREATE TABLE `__drds__system__lock__` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `gmt_create` datetime NOT NULL COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL COMMENT '修改时间',
  `name` varchar(255) NOT NULL COMMENT 'name',
  `token` varchar(255) NOT NULL COMMENT 'token',
  `identity` varchar(255) NOT NULL COMMENT 'identity',
  `operator` varchar(255) NOT NULL COMMENT 'operator',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_NAME` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE  TABLE  `sequence_opt` (
`id` bigint( 20) unsigned  NOT  NULL  AUTO_INCREMENT, `name` varchar( 128) NOT  NULL, 
`value` bigint( 20) unsigned  NOT  NULL, 
`increment_by` int( 10) unsigned  NOT  NULL  DEFAULT  '1', 
`start_with` bigint( 20) unsigned  NOT  NULL  DEFAULT  '1', 
`max_value` bigint( 20) unsigned  NOT  NULL  DEFAULT  '18446744073709551615', 
`cycle` tinyint( 5) unsigned  NOT  NULL  DEFAULT  '0', 
`gmt_created` TIMESTAMP  NULL  DEFAULT  CURRENT_TIMESTAMP,
 `gmt_modified` TIMESTAMP  NOT  NULL  DEFAULT  '1970-02-01 00:00:00', 
PRIMARY  KEY  (`id`), 
UNIQUE  KEY  `unique_name` (`name`)
) ENGINE= InnoDB  AUTO_INCREMENT= 3  DEFAULT  CHARSET= utf8;

CREATE TABLE `sequence` ( 
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT, 
  `name` varchar(64) NOT NULL,   `value` bigint(20) NOT NULL, 
  `gmt_modified` datetime NOT NULL,  
  PRIMARY KEY (`id`),  
  UNIQUE KEY `unique_name` (`name`)
  ) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

--分别在每个分库当中卸载表空间
ALTER TABLE api_log                     DISCARD TABLESPACE;
ALTER TABLE api_log_interface_type      DISCARD TABLESPACE;
ALTER TABLE base_color                  DISCARD TABLESPACE;
ALTER TABLE base_shop_ali               DISCARD TABLESPACE;
ALTER TABLE base_size                   DISCARD TABLESPACE;
ALTER TABLE bill_belong_adjust          DISCARD TABLESPACE;
ALTER TABLE bill_integral_adjust        DISCARD TABLESPACE;
ALTER TABLE bill_integral_adjust_detail DISCARD TABLESPACE;
ALTER TABLE bill_level_adjust           DISCARD TABLESPACE;
ALTER TABLE bill_level_adjust_detail    DISCARD TABLESPACE;
ALTER TABLE bill_tel_adjust             DISCARD TABLESPACE;
ALTER TABLE crm_consume                 DISCARD TABLESPACE;
ALTER TABLE crm_consume_detail          DISCARD TABLESPACE;
ALTER TABLE crm_coupon                  DISCARD TABLESPACE;
ALTER TABLE crm_coupon_brand            DISCARD TABLESPACE;
ALTER TABLE crm_coupon_detail           DISCARD TABLESPACE;
ALTER TABLE crm_coupon_goods            DISCARD TABLESPACE;
ALTER TABLE crm_coupon_org              DISCARD TABLESPACE;
ALTER TABLE crm_coupon_shop             DISCARD TABLESPACE;
ALTER TABLE crm_customer                DISCARD TABLESPACE;
ALTER TABLE crm_customer_vip_weixin     DISCARD TABLESPACE;
ALTER TABLE crm_customer_weixin         DISCARD TABLESPACE;
ALTER TABLE crm_integral                DISCARD TABLESPACE;
ALTER TABLE crm_vip                     DISCARD TABLESPACE;
ALTER TABLE crm_vip_address             DISCARD TABLESPACE;
ALTER TABLE crm_vip_level               DISCARD TABLESPACE;
ALTER TABLE crm_vip_level_log           DISCARD TABLESPACE;
ALTER TABLE custom_property             DISCARD TABLESPACE;
ALTER TABLE customer_property           DISCARD TABLESPACE;
ALTER TABLE customer_tag                DISCARD TABLESPACE;
ALTER TABLE dd_relation                 DISCARD TABLESPACE;
ALTER TABLE marketing_coupon            DISCARD TABLESPACE;
ALTER TABLE marketing_coupon_cal_detail DISCARD TABLESPACE;
ALTER TABLE marketing_coupon_cal_main   DISCARD TABLESPACE;
ALTER TABLE marketing_coupon_detail     DISCARD TABLESPACE;
ALTER TABLE marketing_coupon_gift       DISCARD TABLESPACE;
ALTER TABLE marketing_coupon_item       DISCARD TABLESPACE;
ALTER TABLE marketing_coupon_scope      DISCARD TABLESPACE;
ALTER TABLE mq_consumer_log             DISCARD TABLESPACE;
ALTER TABLE other_schedule_exception    DISCARD TABLESPACE;
ALTER TABLE other_weixin                DISCARD TABLESPACE;
ALTER TABLE rpt_vip_day_cal             DISCARD TABLESPACE;
ALTER TABLE rpt_vip_level_cal           DISCARD TABLESPACE;
ALTER TABLE rpt_vip_repeat_cal          DISCARD TABLESPACE;
ALTER TABLE rpt_vip_summary             DISCARD TABLESPACE;
ALTER TABLE strategy_abnormal_record    DISCARD TABLESPACE;
ALTER TABLE strategy_abnormal_scope     DISCARD TABLESPACE;
ALTER TABLE strategy_abnormal_stop      DISCARD TABLESPACE;
ALTER TABLE strategy_integral           DISCARD TABLESPACE;
ALTER TABLE strategy_integral_item      DISCARD TABLESPACE;
ALTER TABLE strategy_integral_scope     DISCARD TABLESPACE;
ALTER TABLE strategy_level_grade        DISCARD TABLESPACE;
ALTER TABLE strategy_level_merge        DISCARD TABLESPACE;
ALTER TABLE sync_data_coup              DISCARD TABLESPACE;
ALTER TABLE sync_data_err_log           DISCARD TABLESPACE;
ALTER TABLE sync_data_vip               DISCARD TABLESPACE;
ALTER TABLE sys_brand                   DISCARD TABLESPACE;
ALTER TABLE sys_brand_shop              DISCARD TABLESPACE;
ALTER TABLE sys_integral_type           DISCARD TABLESPACE;
ALTER TABLE sys_level                   DISCARD TABLESPACE;
ALTER TABLE sys_level_org               DISCARD TABLESPACE;
ALTER TABLE sys_param                   DISCARD TABLESPACE;
ALTER TABLE txc_undo_log                DISCARD TABLESPACE;
ALTER TABLE vip_address                 DISCARD TABLESPACE;
ALTER TABLE vip_consume                 DISCARD TABLESPACE;
ALTER TABLE vip_consume_detail          DISCARD TABLESPACE;
ALTER TABLE vip_consume_org_shop        DISCARD TABLESPACE;
ALTER TABLE vip_integral                DISCARD TABLESPACE;
ALTER TABLE vip_level_change            DISCARD TABLESPACE;
ALTER TABLE vip_main                    DISCARD TABLESPACE;
ALTER TABLE vip_property                DISCARD TABLESPACE;
ALTER TABLE vip_property_category       DISCARD TABLESPACE;
ALTER TABLE vip_property_set            DISCARD TABLESPACE;
ALTER TABLE vip_status_record           DISCARD TABLESPACE;
ALTER TABLE vip_weixin                  DISCARD TABLESPACE;
`该操作会将创建出来的ibd文件清掉`
mysql> ALTER TABLE wm_stock_shelf_et DISCARD TABLESPACE;
Query OK, 0 rows affected (0.02 sec)

mysql> system ls /home/my3308/data/hash_realtime_rpt_new_ujiq_0008
db.opt	wm_stock_shelf_et.frm


--将原实例data目录当中的ibd文件复制到新实例的数据库data目录中
[root@xbbzjk001 xcrm_wxsn_0001]# cd /home/my3306/data/xcrm_wxsn_0002
[root@xbbzjk001 xcrm_wxsn_0002]# cp -rp *.ibd /home/my3308/data/xcrm_wxsn_0002
[root@xbbzjk001 xcrm_wxsn_0002]# cd /home/my3306/data/xcrm_wxsn_0003
[root@xbbzjk001 xcrm_wxsn_0003]# cp -rp *.ibd /home/my3308/data/xcrm_wxsn_0003
[root@xbbzjk001 xcrm_wxsn_0003]# cd /home/my3306/data/xcrm_wxsn_0004
[root@xbbzjk001 xcrm_wxsn_0004]# cp -rp *.ibd /home/my3308/data/xcrm_wxsn_0004
[root@xbbzjk001 xcrm_wxsn_0004]# cd /home/my3306/data/xcrm_wxsn_0005
[root@xbbzjk001 xcrm_wxsn_0005]# cp -rp *.ibd /home/my3308/data/xcrm_wxsn_0005
[root@xbbzjk001 xcrm_wxsn_0005]# cd /home/my3306/data/xcrm_wxsn_0006
[root@xbbzjk001 xcrm_wxsn_0006]# cp -rp *.ibd /home/my3308/data/xcrm_wxsn_0006
[root@xbbzjk001 xcrm_wxsn_0006]# cd /home/my3306/data/xcrm_wxsn_0007
[root@xbbzjk001 xcrm_wxsn_0007]# cp -rp *.ibd /home/my3308/data/xcrm_wxsn_0007

--加载表空间
ALTER TABLE __drds__system__lock__                     IMPORT TABLESPACE;

ALTER TABLE api_log                     IMPORT TABLESPACE;
ALTER TABLE api_log_interface_type      IMPORT TABLESPACE;
ALTER TABLE base_color                  IMPORT TABLESPACE;
ALTER TABLE base_shop_ali               IMPORT TABLESPACE;
ALTER TABLE base_size                   IMPORT TABLESPACE;
ALTER TABLE bill_belong_adjust          IMPORT TABLESPACE;
ALTER TABLE bill_integral_adjust        IMPORT TABLESPACE;
ALTER TABLE bill_integral_adjust_detail IMPORT TABLESPACE;
ALTER TABLE bill_level_adjust           IMPORT TABLESPACE;
ALTER TABLE bill_level_adjust_detail    IMPORT TABLESPACE;
ALTER TABLE bill_tel_adjust             IMPORT TABLESPACE;
ALTER TABLE crm_consume                 IMPORT TABLESPACE;
ALTER TABLE crm_consume_detail          IMPORT TABLESPACE;
ALTER TABLE crm_coupon                  IMPORT TABLESPACE;
ALTER TABLE crm_coupon_brand            IMPORT TABLESPACE;
ALTER TABLE crm_coupon_detail           IMPORT TABLESPACE;
ALTER TABLE crm_coupon_goods            IMPORT TABLESPACE;
ALTER TABLE crm_coupon_org              IMPORT TABLESPACE;
ALTER TABLE crm_coupon_shop             IMPORT TABLESPACE;
ALTER TABLE crm_customer                IMPORT TABLESPACE;
ALTER TABLE crm_customer_vip_weixin     IMPORT TABLESPACE;
ALTER TABLE crm_customer_weixin         IMPORT TABLESPACE;
ALTER TABLE crm_integral                IMPORT TABLESPACE;
ALTER TABLE crm_vip                     IMPORT TABLESPACE;
ALTER TABLE crm_vip_address             IMPORT TABLESPACE;
ALTER TABLE crm_vip_level               IMPORT TABLESPACE;
ALTER TABLE crm_vip_level_log           IMPORT TABLESPACE;
ALTER TABLE custom_property             IMPORT TABLESPACE;
ALTER TABLE customer_property           IMPORT TABLESPACE;
ALTER TABLE customer_tag                IMPORT TABLESPACE;
ALTER TABLE dd_relation                 IMPORT TABLESPACE;
ALTER TABLE marketing_coupon            IMPORT TABLESPACE;
ALTER TABLE marketing_coupon_cal_detail IMPORT TABLESPACE;
ALTER TABLE marketing_coupon_cal_main   IMPORT TABLESPACE;
ALTER TABLE marketing_coupon_detail     IMPORT TABLESPACE;
ALTER TABLE marketing_coupon_gift       IMPORT TABLESPACE;
ALTER TABLE marketing_coupon_item       IMPORT TABLESPACE;
ALTER TABLE marketing_coupon_scope      IMPORT TABLESPACE;
ALTER TABLE mq_consumer_log             IMPORT TABLESPACE;
ALTER TABLE other_schedule_exception    IMPORT TABLESPACE;
ALTER TABLE other_weixin                IMPORT TABLESPACE;
ALTER TABLE rpt_vip_day_cal             IMPORT TABLESPACE;
ALTER TABLE rpt_vip_level_cal           IMPORT TABLESPACE;
ALTER TABLE rpt_vip_repeat_cal          IMPORT TABLESPACE;
ALTER TABLE rpt_vip_summary             IMPORT TABLESPACE;
ALTER TABLE strategy_abnormal_record    IMPORT TABLESPACE;
ALTER TABLE strategy_abnormal_scope     IMPORT TABLESPACE;
ALTER TABLE strategy_abnormal_stop      IMPORT TABLESPACE;
ALTER TABLE strategy_integral           IMPORT TABLESPACE;
ALTER TABLE strategy_integral_item      IMPORT TABLESPACE;
ALTER TABLE strategy_integral_scope     IMPORT TABLESPACE;
ALTER TABLE strategy_level_grade        IMPORT TABLESPACE;
ALTER TABLE strategy_level_merge        IMPORT TABLESPACE;
ALTER TABLE sync_data_coup              IMPORT TABLESPACE;
ALTER TABLE sync_data_err_log           IMPORT TABLESPACE;
ALTER TABLE sync_data_vip               IMPORT TABLESPACE;
ALTER TABLE sys_brand                   IMPORT TABLESPACE;
ALTER TABLE sys_brand_shop              IMPORT TABLESPACE;
ALTER TABLE sys_integral_type           IMPORT TABLESPACE;
ALTER TABLE sys_level                   IMPORT TABLESPACE;
ALTER TABLE sys_level_org               IMPORT TABLESPACE;
ALTER TABLE sys_param                   IMPORT TABLESPACE;
ALTER TABLE txc_undo_log                IMPORT TABLESPACE;
ALTER TABLE vip_address                 IMPORT TABLESPACE;
ALTER TABLE vip_consume                 IMPORT TABLESPACE;
ALTER TABLE vip_consume_detail          IMPORT TABLESPACE;
ALTER TABLE vip_consume_org_shop        IMPORT TABLESPACE;
ALTER TABLE vip_integral                IMPORT TABLESPACE;
ALTER TABLE vip_level_change            IMPORT TABLESPACE;
ALTER TABLE vip_main                    IMPORT TABLESPACE;
ALTER TABLE vip_property                IMPORT TABLESPACE;
ALTER TABLE vip_property_category       IMPORT TABLESPACE;
ALTER TABLE vip_property_set            IMPORT TABLESPACE;
ALTER TABLE vip_status_record           IMPORT TABLESPACE;
ALTER TABLE vip_weixin                  IMPORT TABLESPACE;
--至此数据文件恢复

--权限检查
GRANT REPLICATION SLAVE, REPLICATION CLIENT, CREATE USER ON *.* TO 'hpljmoyv2'@'%' IDENTIFIED BY PASSWORD '*A03C416B86C6F1C6BA4084AE6B7E5662F446887C'                                                                
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm`.* TO 'hpljmoyv2'@'%';           
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0003`.* TO 'hpljmoyv2'@'%'; 
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0002`.* TO 'hpljmoyv2'@'%'; 
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0005`.* TO 'hpljmoyv2'@'%'; 
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0006`.* TO 'hpljmoyv2'@'%'; 
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0004`.* TO 'hpljmoyv2'@'%'; 
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0001`.* TO 'hpljmoyv2'@'%'; 
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0000`.* TO 'hpljmoyv2'@'%'; 
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0007`.* TO 'hpljmoyv2'@'%';



GRANT USAGE ON *.* TO 'hpljmoyv2'@'localhost' IDENTIFIED BY PASSWORD '*A03C416B86C6F1C6BA4084AE6B7E5662F446887C'                                                                                                            ;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm`.* TO 'hpljmoyv2'@'localhost'          ;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0003`.* TO 'hpljmoyv2'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0004`.* TO 'hpljmoyv2'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0000`.* TO 'hpljmoyv2'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0005`.* TO 'hpljmoyv2'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0002`.* TO 'hpljmoyv2'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0006`.* TO 'hpljmoyv2'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0007`.* TO 'hpljmoyv2'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER ON `xcrm_wxsn_0001`.* TO 'hpljmoyv2'@'localhost';
```


## hash_realtime_rpt_new

```shell
--创建数据库
create database hash_realtime_rpt_new_ujiq_0008;
create database hash_realtime_rpt_new_ujiq_0009;
create database hash_realtime_rpt_new_ujiq_0010;
create database hash_realtime_rpt_new_ujiq_0011;
create database hash_realtime_rpt_new_ujiq_0012;
create database hash_realtime_rpt_new_ujiq_0013;
create database hash_realtime_rpt_new_ujiq_0014;
create database hash_realtime_rpt_new_ujiq_0015;

--导入表结构
mysql -uroot -p -h127.0.0.1 -P3308 hash_realtime_rpt_new_ujiq_0008 < hash_realtime_rpt_new_ujiq_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 hash_realtime_rpt_new_ujiq_0009 < hash_realtime_rpt_new_ujiq_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 hash_realtime_rpt_new_ujiq_0010 < hash_realtime_rpt_new_ujiq_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 hash_realtime_rpt_new_ujiq_0011 < hash_realtime_rpt_new_ujiq_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 hash_realtime_rpt_new_ujiq_0012 < hash_realtime_rpt_new_ujiq_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 hash_realtime_rpt_new_ujiq_0013 < hash_realtime_rpt_new_ujiq_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 hash_realtime_rpt_new_ujiq_0014 < hash_realtime_rpt_new_ujiq_0016.sql
mysql -uroot -p -h127.0.0.1 -P3308 hash_realtime_rpt_new_ujiq_0015 < hash_realtime_rpt_new_ujiq_0016.sql

--卸载表空间
use hash_realtime_rpt_new_ujiq_0008;
use hash_realtime_rpt_new_ujiq_0013;
use hash_realtime_rpt_new_ujiq_0014;
use hash_realtime_rpt_new_ujiq_0015;
ALTER TABLE  __drds__system__lock__            DISCARD TABLESPACE;
ALTER TABLE  ch_bankaccount_et                 DISCARD TABLESPACE;
ALTER TABLE  ch_calculate_org_et               DISCARD TABLESPACE;
ALTER TABLE  ch_customer_credit_limit_et       DISCARD TABLESPACE;
ALTER TABLE  ch_customer_et                    DISCARD TABLESPACE;
ALTER TABLE  ch_department_et                  DISCARD TABLESPACE;
ALTER TABLE  ch_employee_et                    DISCARD TABLESPACE;
ALTER TABLE  ch_shop_et                        DISCARD TABLESPACE;
ALTER TABLE  ch_sys_codelist_et                DISCARD TABLESPACE;
ALTER TABLE  ch_warehouse_et                   DISCARD TABLESPACE;
ALTER TABLE  crm_vip_level                     DISCARD TABLESPACE;
ALTER TABLE  da_account_et                     DISCARD TABLESPACE;
ALTER TABLE  or_account_et                     DISCARD TABLESPACE;
ALTER TABLE  or_bond_et                        DISCARD TABLESPACE;
ALTER TABLE  or_meeting_order_et               DISCARD TABLESPACE;
ALTER TABLE  or_meeting_order_line_et          DISCARD TABLESPACE;
ALTER TABLE  or_po_return_et                   DISCARD TABLESPACE;
ALTER TABLE  or_po_return_line_et              DISCARD TABLESPACE;
ALTER TABLE  or_props_et                       DISCARD TABLESPACE;
ALTER TABLE  or_saleretbill_et                 DISCARD TABLESPACE;
ALTER TABLE  or_saleretbill_line_et            DISCARD TABLESPACE;
ALTER TABLE  or_sd_salebill_et                 DISCARD TABLESPACE;
ALTER TABLE  or_sd_salebill_line_et            DISCARD TABLESPACE;
ALTER TABLE  or_sd_saleorder_et                DISCARD TABLESPACE;
ALTER TABLE  or_sd_saleorder_line_et           DISCARD TABLESPACE;
ALTER TABLE  or_tic_udticket_log_et            DISCARD TABLESPACE;
ALTER TABLE  or_ud_ticket_et                   DISCARD TABLESPACE;
ALTER TABLE  or_ud_ticket_line_et              DISCARD TABLESPACE;
ALTER TABLE  or_udticket_input_et              DISCARD TABLESPACE;
ALTER TABLE  or_udticketline_input_et          DISCARD TABLESPACE;
ALTER TABLE  pr_analysis_et                    DISCARD TABLESPACE;
ALTER TABLE  pr_item_allot_analysis_et         DISCARD TABLESPACE;
ALTER TABLE  pr_item_et                        DISCARD TABLESPACE;
ALTER TABLE  pr_item_image_et                  DISCARD TABLESPACE;
ALTER TABLE  pr_trunk_et                       DISCARD TABLESPACE;
ALTER TABLE  pr_trunk_line_et                  DISCARD TABLESPACE;
ALTER TABLE  st_allo_detail_et                 DISCARD TABLESPACE;
ALTER TABLE  st_allo_variance_et               DISCARD TABLESPACE;
ALTER TABLE  st_allo_variance_line_et          DISCARD TABLESPACE;
ALTER TABLE  st_allocation_et                  DISCARD TABLESPACE;
ALTER TABLE  st_assembly_detail_et             DISCARD TABLESPACE;
ALTER TABLE  st_assembly_et                    DISCARD TABLESPACE;
ALTER TABLE  st_entry_detail_et                DISCARD TABLESPACE;
ALTER TABLE  st_entry_detail_et_znbh           DISCARD TABLESPACE;
ALTER TABLE  st_in_receipt_detail_et           DISCARD TABLESPACE;
ALTER TABLE  st_in_receipt_et                  DISCARD TABLESPACE;
ALTER TABLE  st_inventory_detail_et            DISCARD TABLESPACE;
ALTER TABLE  st_inventory_diff_et              DISCARD TABLESPACE;
ALTER TABLE  st_inventory_et                   DISCARD TABLESPACE;
ALTER TABLE  st_inventoryfirm_detail_et        DISCARD TABLESPACE;
ALTER TABLE  st_inventoryfirm_et               DISCARD TABLESPACE;
ALTER TABLE  st_out_receipt_detail_et          DISCARD TABLESPACE;
ALTER TABLE  st_out_receipt_et                 DISCARD TABLESPACE;
ALTER TABLE  st_po_et                          DISCARD TABLESPACE;
ALTER TABLE  st_po_line_et                     DISCARD TABLESPACE;
ALTER TABLE  st_request_detail_et              DISCARD TABLESPACE;
ALTER TABLE  st_request_et                     DISCARD TABLESPACE;
ALTER TABLE  st_stock_adjust_detail_et         DISCARD TABLESPACE;
ALTER TABLE  st_stock_adjust_et                DISCARD TABLESPACE;
ALTER TABLE  st_stock_cost_et                  DISCARD TABLESPACE;
ALTER TABLE  st_stock_et                       DISCARD TABLESPACE;
ALTER TABLE  txc_undo_log                      DISCARD TABLESPACE;
ALTER TABLE  wm_in_job_allot_et                DISCARD TABLESPACE;
ALTER TABLE  wm_in_job_detail_et               DISCARD TABLESPACE;
ALTER TABLE  wm_in_job_et                      DISCARD TABLESPACE;
ALTER TABLE  wm_in_job_link_et                 DISCARD TABLESPACE;
ALTER TABLE  wm_in_scan_detail_et              DISCARD TABLESPACE;
ALTER TABLE  wm_out_receipt_detail_et          DISCARD TABLESPACE;
ALTER TABLE  wm_out_receipt_et                 DISCARD TABLESPACE;
ALTER TABLE  wm_out_receipt_express_et         DISCARD TABLESPACE;
ALTER TABLE  wm_out_scan_detail_et             DISCARD TABLESPACE;
ALTER TABLE  wm_phy_warehouse_link_et          DISCARD TABLESPACE;
ALTER TABLE  wm_shipper_et                     DISCARD TABLESPACE;
ALTER TABLE  wm_stock_shelf_et                 DISCARD TABLESPACE;

--移动ibd文件到新目录
cp -rp *.ibd /home/my3308/data/hash_realtime_rpt_new_ujiq_0008/
[root@xbbzjk001 xcrm_wxsn_0007]# cd /home/my3306/data/hash_realtime_rpt_new_ujiq_0011
[root@xbbzjk001 hash_realtime_rpt_new_ujiq_0011]# cp -rp *.ibd /home/my3308/data/hash_realtime_rpt_new_ujiq_0011/
[root@xbbzjk001 hash_realtime_rpt_new_ujiq_0011]# cd /home/my3306/data/hash_realtime_rpt_new_ujiq_0012
[root@xbbzjk001 hash_realtime_rpt_new_ujiq_0012]# cp -rp *.ibd /home/my3308/data/hash_realtime_rpt_new_ujiq_0012/
[root@xbbzjk001 hash_realtime_rpt_new_ujiq_0012]# cd /home/my3306/data/hash_realtime_rpt_new_ujiq_0013
[root@xbbzjk001 hash_realtime_rpt_new_ujiq_0013]# cp -rp *.ibd /home/my3308/data/hash_realtime_rpt_new_ujiq_0013/
[root@xbbzjk001 hash_realtime_rpt_new_ujiq_0013]# cd /home/my3306/data/hash_realtime_rpt_new_ujiq_0014
[root@xbbzjk001 hash_realtime_rpt_new_ujiq_0014]# cp -rp *.ibd /home/my3308/data/hash_realtime_rpt_new_ujiq_0014/
[root@xbbzjk001 hash_realtime_rpt_new_ujiq_0014]# cd /home/my3306/data/hash_realtime_rpt_new_ujiq_0015
[root@xbbzjk001 hash_realtime_rpt_new_ujiq_0015]# cp -rp *.ibd /home/my3308/data/hash_realtime_rpt_new_ujiq_0015/

--重新加载表空间
ALTER TABLE  __drds__system__lock__            IMPORT TABLESPACE;
ALTER TABLE  ch_bankaccount_et                 IMPORT TABLESPACE;
ALTER TABLE  ch_calculate_org_et               IMPORT TABLESPACE;
ALTER TABLE  ch_customer_credit_limit_et       IMPORT TABLESPACE;
ALTER TABLE  ch_customer_et                    IMPORT TABLESPACE;
ALTER TABLE  ch_department_et                  IMPORT TABLESPACE;
ALTER TABLE  ch_employee_et                    IMPORT TABLESPACE;
ALTER TABLE  ch_shop_et                        IMPORT TABLESPACE;
ALTER TABLE  ch_sys_codelist_et                IMPORT TABLESPACE;
ALTER TABLE  ch_warehouse_et                   IMPORT TABLESPACE;
ALTER TABLE  crm_vip_level                     IMPORT TABLESPACE;
ALTER TABLE  da_account_et                     IMPORT TABLESPACE;
ALTER TABLE  or_account_et                     IMPORT TABLESPACE;
ALTER TABLE  or_bond_et                        IMPORT TABLESPACE;
ALTER TABLE  or_meeting_order_et               IMPORT TABLESPACE;
ALTER TABLE  or_meeting_order_line_et          IMPORT TABLESPACE;
ALTER TABLE  or_po_return_et                   IMPORT TABLESPACE;
ALTER TABLE  or_po_return_line_et              IMPORT TABLESPACE;
ALTER TABLE  or_props_et                       IMPORT TABLESPACE;
ALTER TABLE  or_saleretbill_et                 IMPORT TABLESPACE;
ALTER TABLE  or_saleretbill_line_et            IMPORT TABLESPACE;
ALTER TABLE  or_sd_salebill_et                 IMPORT TABLESPACE;
ALTER TABLE  or_sd_salebill_line_et            IMPORT TABLESPACE;
ALTER TABLE  or_sd_saleorder_et                IMPORT TABLESPACE;
ALTER TABLE  or_sd_saleorder_line_et           IMPORT TABLESPACE;
ALTER TABLE  or_tic_udticket_log_et            IMPORT TABLESPACE;
ALTER TABLE  or_ud_ticket_et                   IMPORT TABLESPACE;
ALTER TABLE  or_ud_ticket_line_et              IMPORT TABLESPACE;
ALTER TABLE  or_udticket_input_et              IMPORT TABLESPACE;
ALTER TABLE  or_udticketline_input_et          IMPORT TABLESPACE;
ALTER TABLE  pr_analysis_et                    IMPORT TABLESPACE;
ALTER TABLE  pr_item_allot_analysis_et         IMPORT TABLESPACE;
ALTER TABLE  pr_item_et                        IMPORT TABLESPACE;
ALTER TABLE  pr_item_image_et                  IMPORT TABLESPACE;
ALTER TABLE  pr_trunk_et                       IMPORT TABLESPACE;
ALTER TABLE  pr_trunk_line_et                  IMPORT TABLESPACE;
ALTER TABLE  st_allo_detail_et                 IMPORT TABLESPACE;
ALTER TABLE  st_allo_variance_et               IMPORT TABLESPACE;
ALTER TABLE  st_allo_variance_line_et          IMPORT TABLESPACE;
ALTER TABLE  st_allocation_et                  IMPORT TABLESPACE;
ALTER TABLE  st_assembly_detail_et             IMPORT TABLESPACE;
ALTER TABLE  st_assembly_et                    IMPORT TABLESPACE;
ALTER TABLE  st_entry_detail_et                IMPORT TABLESPACE;
ALTER TABLE  st_entry_detail_et_znbh           IMPORT TABLESPACE;
ALTER TABLE  st_in_receipt_detail_et           IMPORT TABLESPACE;
ALTER TABLE  st_in_receipt_et                  IMPORT TABLESPACE;
ALTER TABLE  st_inventory_detail_et            IMPORT TABLESPACE;
ALTER TABLE  st_inventory_diff_et              IMPORT TABLESPACE;
ALTER TABLE  st_inventory_et                   IMPORT TABLESPACE;
ALTER TABLE  st_inventoryfirm_detail_et        IMPORT TABLESPACE;
ALTER TABLE  st_inventoryfirm_et               IMPORT TABLESPACE;
ALTER TABLE  st_out_receipt_detail_et          IMPORT TABLESPACE;
ALTER TABLE  st_out_receipt_et                 IMPORT TABLESPACE;
ALTER TABLE  st_po_et                          IMPORT TABLESPACE;
ALTER TABLE  st_po_line_et                     IMPORT TABLESPACE;
ALTER TABLE  st_request_detail_et              IMPORT TABLESPACE;
ALTER TABLE  st_request_et                     IMPORT TABLESPACE;
ALTER TABLE  st_stock_adjust_detail_et         IMPORT TABLESPACE;
ALTER TABLE  st_stock_adjust_et                IMPORT TABLESPACE;
ALTER TABLE  st_stock_cost_et                  IMPORT TABLESPACE;
ALTER TABLE  st_stock_et                       IMPORT TABLESPACE;
ALTER TABLE  txc_undo_log                      IMPORT TABLESPACE;
ALTER TABLE  wm_in_job_allot_et                IMPORT TABLESPACE;
ALTER TABLE  wm_in_job_detail_et               IMPORT TABLESPACE;
ALTER TABLE  wm_in_job_et                      IMPORT TABLESPACE;
ALTER TABLE  wm_in_job_link_et                 IMPORT TABLESPACE;
ALTER TABLE  wm_in_scan_detail_et              IMPORT TABLESPACE;
ALTER TABLE  wm_out_receipt_detail_et          IMPORT TABLESPACE;
ALTER TABLE  wm_out_receipt_et                 IMPORT TABLESPACE;
ALTER TABLE  wm_out_receipt_express_et         IMPORT TABLESPACE;
ALTER TABLE  wm_out_scan_detail_et             IMPORT TABLESPACE;
ALTER TABLE  wm_phy_warehouse_link_et          IMPORT TABLESPACE;
ALTER TABLE  wm_shipper_et                     IMPORT TABLESPACE;
ALTER TABLE  wm_stock_shelf_et                 IMPORT TABLESPACE;
mysql> ALTER TABLE  wm_stock_shelf_et                 IMPORT TABLESPACE;
Query OK, 0 rows affected, 1 warning (0.04 sec)

mysql> select * from wm_shipper_et;
+------------+------------+--------------------+--------------------+-------+---------+---------+------------------+-------------+---------------------+------------------+-------------+---------------------+--------------------+--------+
| SHIPPER_ID | ACT_ORG_ID | SHIPPER_CODE       | SHIPPER_NAME       | PHONE | LINKMAN | ADDRESS | CREATE_USER_NAME | CREATE_USER | CREATE_TIME         | MODIFY_USER_NAME | MODIFY_USER | MODIFY_TIME         | REMARKS            | IS_USE |
+------------+------------+--------------------+--------------------+-------+---------+---------+------------------+-------------+---------------------+------------------+-------------+---------------------+--------------------+--------+
|          3 |          3 | 河南货主           | 河南货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 河南               |      1 |
|          4 |          4 | 济南货主           | 济南货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 济南货主           |      1 |
|          5 |          5 | 云南货主           | 云南货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 云南货主           |      1 |
|          7 |          7 | 安徽货主           | 安徽货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 安徽货主           |      1 |
|         12 |         12 | 湖北货主           | 湖北货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 湖北               |      1 |
|         13 |         13 | 山西货主           | 山西货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 山西货主           |      1 |
|         17 |         17 | 河北               | 河北货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 河北货主           |      1 |
|         18 |         18 | 四川货主           | 四川货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 四川货主           |      1 |
|         20 |         20 | 重庆货主           | 重庆货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 重庆货主           |      1 |
|         21 |         21 | 南京货主           | 南京货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 南京货主           |      1 |
|         23 |         23 | 甘肃货主           | 甘肃货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 甘肃货主           |      1 |
|         41 |         41 | 福州货主           | 福州货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 福州               |      1 |
|         42 |         42 | 江西货主           | 江西货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 江西货主           |      1 |
|         43 |         43 | 上海货主           | 上海货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 上海货主           |      1 |
|         44 |         44 | 天津货主           | 天津货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 |                    |      1 |
|         46 |         46 | 广西货主           | 广西货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 广西货主           |      1 |
|         47 |         47 | 泉厦货主           | 泉厦货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 泉厦               |      1 |
|         51 |         51 | 库降货主           | 库降货主           |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 库降               |      1 |
|         65 |         65 | 四川儿童货主       | 四川儿童货主       |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 |                    |      1 |
|         66 |         66 | 云南儿童货主       | 云南儿童货主       |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 |                    |      1 |
|         71 |         71 | 北京儿童货主       | 北京儿童货主       |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 |                    |      1 |
|         77 |         77 | 福建儿童货主       | 福建儿童货主       |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 |                    |      1 |
|         90 |         90 | 青岛儿童货主       | 青岛儿童货主       |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 |                    |      1 |
|     200001 |     200001 | 山西侯马货主       | 山西侯马货主       |       |         |         | 陈琼红           | cqh         | 2018-07-23 00:00:00 |                  |             | 2018-07-23 00:00:00 | 山西侯马货主       |      1 |
+------------+------------+--------------------+--------------------+-------+---------+---------+------------------+-------------+---------------------+------------------+-------------+---------------------+--------------------+--------+
24 rows in set (0.00 sec)

mysql>
```

## 实例运行资源详情

```shell
[root@xbbzjk001 /]# ps -ef | grep mysql
root     11894  5491  0 15:24 pts/4    00:00:00 grep --color=auto mysql
root     14516     1  0 Jul18 ?        00:00:00 /bin/sh ./bin/mysqld_safe --defaults-file=/home/my3306/my.cnf
mysql    16114 14516  7 Jul18 ?        01:22:21 /opt/mysql/bin/mysqld --defaults-file=/home/my3306/my.cnf --basedir=/opt/mysql --datadir=/home/my3306/data --plugin-dir=/opt/mysql/lib/plugin --user=mysql --log-error=/home/my3306/log/alert.log --open-files-limit=65535 --pid-file=/home/my3306/run/mysqld.pid --socket=/home/my3306/run/mysql.sock --port=3306
root     16237     1  0 Jul18 ?        00:00:00 /bin/sh ./bin/mysqld_safe --defaults-file=/home/my3307/my.cnf
mysql    17835 16237  0 Jul18 ?        00:09:07 /opt/mysql/bin/mysqld --defaults-file=/home/my3307/my.cnf --basedir=/opt/mysql --datadir=/home/my3307/data --plugin-dir=/opt/mysql/lib/plugin --user=mysql --log-error=/home/my3307/log/alert.log --open-files-limit=65535 --pid-file=/home/my3307/run/mysqld.pid --socket=/home/my3307/run/mysql.sock --port=3307
root     31354  3467  0 11:02 pts/1    00:00:00 mysql -h127.0.0.1 -P3306 -uroot -px xxxxxxx


[root@xbbzjk001 /]# top
top - 15:24:41 up 1 day,  2:58,  3 users,  load average: 0.61, 0.83, 0.94
Tasks: 321 total,   1 running, 320 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.9 us,  0.4 sy,  0.0 ni, 97.5 id,  1.2 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem : 82319056 total, 32037640 free, 37885988 used, 12395428 buff/cache
KiB Swap:  2097148 total,  2050556 free,    46592 used. 43817132 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND                                                                                                                   
16114 mysql     20   0   62.9g  29.9g   8976 S  36.4 38.1  82:27.78 mysqld                                                                                                                    
 6222 root      20   0 3583056  37420  17016 S   7.6  0.0   2:47.90 telegraf                                                                                                                  
11906 root      20   0  162104   2460   1576 R   0.7  0.0   0:00.08 top                                                                                                                       
    1 root      20   0  195812   4176   2744 S   0.3  0.0   0:33.96 systemd                                                                                                                   
  192 root      20   0       0      0      0 S   0.3  0.0   0:17.94 kworker/12:1                                                                                                              
  194 root      20   0       0      0      0 S   0.3  0.0   0:24.81 kworker/14:1                                                                                                              
  197 root      20   0       0      0      0 S   0.3  0.0   0:01.61 kworker/17:1                                                                                                              
  208 root      20   0       0      0      0 S   0.3  0.0   1:40.51 kworker/28:1                                                                                                              
  917 root      20   0       0      0      0 S   0.3  0.0   0:10.16 kworker/2:2                                                                                                               
 1619 root       0 -20       0      0      0 S   0.3  0.0   0:41.60 kworker/28:1H                                                                                                             
17835 mysql     20   0   56.2g   5.5g   7900 S   0.3  7.1   9:07.07 mysqld                                                                                                                    
    2 root      20   0       0      0      0 S   0.0  0.0   0:00.08 kthreadd                                                                                                                  
    3 root      20   0       0      0      0 S   0.0  0.0   0:00.21 ksoftirqd/0                                                                                                               
    5 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/0:0H                                                                                                              
    6 root      20   0       0      0      0 S   0.0  0.0   0:00.00 kworker/u64:0                                                                                                             
    7 root      20   0       0      0      0 S   0.0  0.0   0:56.49 kworker/u65:0                                                                                                             
    8 root      rt   0       0      0      0 S   0.0  0.0   0:00.12 migration/0                                                                                                               
    9 root      20   0       0      0      0 S   0.0  0.0   0:00.00 rcu_bh                                                                                                                    
   10 root      20   0       0      0      0 S   0.0  0.0   0:18.13 rcu_sched                                                                                                                 
   11 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 lru-add-drain                                                                                                             
   12 root      rt   0       0      0      0 S   0.0  0.0   0:00.51 watchdog/0                                                                                                                
   13 root      rt   0       0      0      0 S   0.0  0.0   0:00.37 watchdog/1                                                                                                                
   14 root      rt   0       0      0      0 S   0.0  0.0   0:00.14 migration/1    
```

**原实例ibdata2达到137G，内存使用达到93%；**

**通过优化目前ibdata1为10M，ibdata2为32M，内存使用率目前平稳在39%。**





