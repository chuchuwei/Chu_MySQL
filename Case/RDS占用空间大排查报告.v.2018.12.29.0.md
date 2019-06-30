# RDS占用空间大排查报告.v.2018.12.29.0

[TOC]



## 故障说明

帮忙看下我们的rds，现在报磁盘超过80%，但我看了下，实际数据140g差不多，这个要怎么清理下好点？

## 故障实例

![](pic\06.png)

## 排查步骤

### 控制台信息

![](pic/07.png)

![](pic/08.png)

![](pic/09.png)

由图中可知：存储空间已使用404G，数据空间占用143G，且数据空间占用空间最大

### 实例内部数据统计

![](pic\01.png)

![](pic\02.png)

![](pic\03.png)

![](pic\04.png)

![](pic\05.png)

 

| 数据库    | 表                   | 数据容量 | 索引容量 | 碎片容量 |
| ------ | ------------------- | ---- | ---- | ---- |
| cargts | fk_stopover         | 82G  | 160G | 6MB  |
| cargts | alarmhistory        | 15G  | 25G  | 4MB  |
| cargts | fk_odometer         | 17G  | 18G  | 6MB  |
| cargts | report_abnormal_gps | 18G  | 15G  | 6MB  |
| cargts | eventdata_w         | 16G  | 12G  | 4MB  |

上图为占用空间比较大的表，占用378G，其余的库表占用空间较小，不一一列举

磁盘占用空间多数为数据占用

## 结论

```shell
1 控制台监控得出的是预估值，不准确，不能作为判断的标准
2 统计磁盘占用需要查看实际物理文件占用（数据、索引、碎片等）
3 对于操作频繁的表建议先收集统计一下表信息后再进行表数据量查看，没有收集统计信息前查看到的表数据是预估值可能不准确
4 如果碎片占用空间太大，可以对表进行下优化释放表空间，本实例碎片占用空间不大，不需要优化
```

```shell
# 统计收集表信息
analyze table 表；

# 表数据查看
select table_schema as '数据库',table_name as '表名',table_rows as '记录数',truncate(data_length/1024/1024, 2) as '数据容量(MB)',truncate(index_length/1024/1024, 2) as '索引容量(MB)',truncate(data_free/1024/1024, 2) as '碎片容量(MB)' from information_schema.tables where table_schema='cargts' and table_name='eventdata_w';

# 优化表
optimize table 表；

# 统计收集表信息和优化表时会对表加读锁，建议业务低峰期时进行统计收集
```

## 解决方法

 根据业务需求清理数据

 磁盘扩容











