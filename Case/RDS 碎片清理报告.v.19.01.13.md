# RDS 碎片清理报告.v.19.01.13


[TOC]

## 待清理实例

![](pic\06.png)

## 待清理库 表

| 库      | 表           |
| ------ | ----------- |
| cargts | fk_stopover |

## 碎片量


```shell
select table_schema as '数据库',table_name as '表名',table_rows as '记录
数',truncate(data_length/1024/1024, 2) as '数据容量(MB)',truncate(index_length/1024/1024, 2) as
'索引容量(MB)',truncate(data_free/1024/1024, 2) as '碎片容量(MB)' from information_schema.tables
where table_schema='cargts' and table_name='fk_stopover';

```

![](pic\12.png)

暂定 2019-01-10 晚8 点： 执行 optimize table fk_stopover;

## 优化过程

![](pic\13.png)

![](pic\14.png)

* 由于优化表过程中用到临时表，导致占用磁盘空间过大，实例锁定，第一次优化失败

* 提交工单以后，阿里从2019-01-11 09:52 解锁至2019-01-12 10:00:17，在2019-01-11 晚 7:30 进行 第二次优化

* 优化完成以后，由于底层存储的原因，主实例碎片利用空间没有下降，备库下降，2019-01-12 晚10：00 进行主备切换，阿里重做备库

  ## 主备切换

  ![](pic\11.png)


## 总结

主备切换完成后，实例磁盘利用空间下降

![](pic\15.png)

![](pic\16.png)