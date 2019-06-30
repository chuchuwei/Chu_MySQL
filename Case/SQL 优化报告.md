# SQL优化报告


[TOC]

## 问题描述

从检测报告中看到有一条update语句执行比较慢

语句如下

```shell
UPDATE app_statistics_hc_sales_goods t1 LEFT JOIN
app_statistics_k3_goods t2 ON t1.goods_sn = t2.FNumber SET
t1.FProductManager = t2.FProductManager WHERE
t1.FProductManager IS NULL
```

## 排查过程

### 查询语句

```shell
select * from app_statistics_hc_sales_goods t1 
LEFT JOIN
app_statistics_k3_goods t2 
ON t1.goods_sn = t2.FNumber  
WHERE
t1.FProductManager IS NULL

# t1 表 goods_sn，FProductManager
# t2 表 FNumber
```

### 查看表索引

```shell
mysql>show create table app_statistics_hc_sales_goods\G;

********* 1. row *********
      Table: app_statistics_hc_sales_goods
Create Table: CREATE TABLE app_statistics_hc_sales_goods (
  id int(11) NOT NULL AUTO_INCREMENT,
  region_name varchar(45) DEFAULT NULL,
  date varchar(45) DEFAULT NULL,
  goods_sn varchar(45) DEFAULT NULL,
  goods_name varchar(255) DEFAULT NULL,
  goods_count decimal(10,2) DEFAULT NULL,
  goods_amount decimal(10,2) DEFAULT NULL,
  max_pay_time int(11) DEFAULT NULL,
  FProductManager varchar(20) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uni_row (region_name,date,goods_sn) USING BTREE,
  KEY idx_date (date) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=243966 DEFAULT CHARSET=gbk
返回行数：[1]，耗时：9 ms.



mysql>show create table app_statistics_k3_goods\G;
********* 1. row *********
       Table: app_statistics_k3_goods
Create Table: CREATE TABLE app_statistics_k3_goods (
  id int(11) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  FNumber varchar(20) CHARACTER SET gbk DEFAULT NULL,
  FName varchar(255) CHARACTER SET gbk DEFAULT NULL,
  FProductManager varchar(20) CHARACTER SET gbk DEFAULT NULL,
  PRIMARY KEY (id),
  KEY FNumberIndex (FNumber) USING BTREE,
  KEY FProductManagerIndex (FProductManager) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=54748 DEFAULT CHARSET=utf8
返回行数：[1]，耗时：9 ms.


 
```



### 查看语句执行计划

![](pic1\01.png)

### 查看表app_statistics_hc_sales_goods数据

```shell
mysql>show table status like "app_statistics_hc_sales_goods"\G;

********* 1. row *********
           Name: app_statistics_hc_sales_goods
         Engine: InnoDB
        Version: 10
     Row_format: Compact
           Rows: 167635
 Avg_row_length: 128
    Data_length: 21544960
Max_data_length: 0
   Index_length: 18972672
      Data_free: 5242880
 Auto_increment: 243966
    Create_time: 2018-11-13 10:34:51
    Update_time: 
     Check_time: 
      Collation: gbk_chinese_ci
       Checksum: 
 Create_options: 
        Comment: 
   Block_format: Original
返回行数：[1]，耗时：10 ms.

```

t1表有167635行数据，从表索引和语句执行计划可以看出，t1表没有合适的索引，执行语句时会进行全表扫描

## 优化

### app_statistics_hc_sales_goods表添加索引

```shell
alter table app_statistics_hc_sales_goods add index idx_FProductManager (FProductManager);
```

### 查看执行计划

![](pic1\02.png)

创建索引后，查看语句执行计划，t1表使用索引

## 优化前后对比

| 优化前（未添加索引） | 优化后（添加索引） |
| ---------- | --------- |
| 87ms-95ms  | 55ms-60ms |









