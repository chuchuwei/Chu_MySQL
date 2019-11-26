# RDS For MySQL 5.7 金融云跨地域迁移.v.18.12.05.0
> 2018.12.05 小楚

[TOC]

## 迁移需求

麻烦今天18:00开始从rm-j5ec9p60s3am4v2f1.mysql.rds.aliyuncs.com（SAP-dev），

将etldb与rptdb的表结构以及hdmpdb的表结构与数据同步到rm-pz5uu48t47n708dmc.mysql.rds.aliyuncs.com(SAP-uat)

可以清空rm-pz5uu48t47n708dmc.mysql.rds.aliyuncs.com(SAP-uat)再导入。

## 迁移明细

### 源数据库

rm-j5ec9p60s3am4v2f1.mysql.rds.aliyuncs.com（SAP-dev）

### 目标数据库

rm-pz5uu48t47n708dmc.mysql.rds.aliyuncs.com(SAP-uat)

## 迁移数据库

### DTS同步工具

![](pic3（12.5）\01.png)

![](pic3（12.5）\02.png)

![](pic3（12.5）\07.png)

![](pic3（12.5）\04.png)

![](pic3（12.5）\06.png)

#### 存储过程部分和表部分出错

手动迁移存储过程

### mysql客户端逻辑备份导入

DTS迁移完etldb与rptdb的表结构之后，由于网络原因导致DTS任务创建不成功，使用逻辑备份的方式进行导入导出

```shell
/data/alidata/mysql/bin/mysqldump -hrm-j5ec9p60s3am4v2f1.mysql.rds.aliyuncs.com -u  -p hdmpdb --opt --set-gtid-purged=OFF --ignore-table=hdmpdb.circ_000037_dtl_64_v --ignore-table=hdmpdb.circ_000037_dtl_65_v --default-character-set=utf8 --single-transaction --hex-blob --max_allowed_packet=824288000 > hdmpdb.sql

# 报错
mysqldump: Couldn't execute 'SHOW FIELDS FROM `circ_000037_dtl_64_v`': View 'hdmpdb.circ_000037_dtl_64_v' references invalid table(s) or column(s) or function(s) or definer/invoker of view lack rights to use them (1356)
```

由于与之视图相关的视图在原库上已经不存在，所以无法备份此视图，与贵司沟通后，忽略此类视图

类似的试图共有8个

```shell
circ_000037_dtl_65_v
circ_000037_dtl_64_v
circ_000037_dtl_66_v
circ_000037_dtl_76_v
circ_000037_sum_64_v
circ_000037_sum_65_v
circ_000037_sum_66_v
circ_000037_sum_76_v

# 重新备份，跳过视图
/data/alidata/mysql/bin/mysqldump -hrm-j5ec9p60s3am4v2f1.mysql.rds.aliyuncs.com -u  -p hdmpdb --opt --set-gtid-purged=OFF --ignore-table=hdmpdb.circ_000037_dtl_64_v --ignore-table=hdmpdb.circ_000037_dtl_65_v --ignore-table=hdmpdb.circ_000037_dtl_66_v --ignore-table=hdmpdb.circ_000037_dtl_76_v --ignore-table=hdmpdb.circ_000037_sum_64_v --ignore-table=hdmpdb.circ_000037_sum_65_v --ignore-table=hdmpdb.circ_000037_sum_66_v --ignore-table=hdmpdb.circ_000037_sum_76_v --default-character-set=utf8 --single-transaction --hex-blob --max_allowed_packet=824288000 > hdmpdb.sql
# 导入
/data/alidata/mysql/bin/mysql -u  -p -hrm-pz5uu48t47n708dmc.mysql.rds.aliyuncs.com hdmpdb < hdmpdb.sql
7G的数据量，导入时间花了40分钟
```

