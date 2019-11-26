#主从同步过程中，mysqldump备份--set-gtid-purged=OFF参数

##注解
```shell 
 MySQL 5.6 引入了 GTID 特性，因此随 5.6 版本分发的 mysqldump 工具增加了 --set-gtid-purged 选项。
 选项名：set-gtid-purged
 默认值：AUTO
 可选值：ON，OFF，AUTO
```
 ##作用
 ```shell
 是否输出 SET@@GLOBAL.GTID_PURGED 子句
 ON：在 mysqldump 输出中包含 SET@@GLOBAL.GTID_PURGED 语句
 OFF：在 mysqldump 输出中不包含 SET@@GLOBAL.GTID_PURGED 语句
 AUTO：默认值，对于启用 GTID 实例，会输出 SET@@GLOBAL.GTID_PURGED 语句；对于没有启动或者不支持 GTID 的实例，不输出任何 GTID 相关信息。
 ```
## 小结

gtid是一个全局事物标记号，每执行一个事物，都会有一个gtid标记的号，主从同步时，如果没有开启gtid功能，则进行mysqldump备份时不需要加--set-gtid-purged选项

在开启了gtid功能的数据库中进行逻辑备份的时候需要加--set-gtid-purged=OFF选项

##步骤

### 备份未加参数

>  开启主从同步以后备份一个shop库，备份过程中未加此参数的备份文件截图

![](pic\01.png)

 ![](pic\02.png)

从图中可以看出17,18,24行，表示禁用binlog日志，也就是说在事物1-31（即之前创建库shop以及建表后续的操作）之间的操作禁用了binlog日志

 ### 导入数据 

> 先删除库shop，在创建，用mysql -u -p shop < xx.sql导入 

 1  导入数据以后，主库的截图


 ![](pic\04.png)

从图中可以见到，导入数据以后，主库数据恢复

2 从库的截图

![](pic\05.png)

 从图中可知，导入数据以后，从库中的shop库中没有数据

3 主从同步截图

![](pic\06.png)

从图中可知，主从同步正常

## 总结

未加参数的时候，在备份的文件中会显示上面三行

在主从关系中，若利用此备份文件进行恢复数据，则表示之前对于库表的操作会禁用其二进制日志

则在导入的时候，从库拉取主库的binlog日志时没有这些操作，所以导入成功以后从库中也没有数据，容易导致主从数据不一致，从库数据丢失，而主从同步却还还正常的情况



