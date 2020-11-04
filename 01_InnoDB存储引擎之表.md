# 表

[toc]



## 索引组织表

在InnoDB存储引擎中，表都是根据主键顺序组织存放的，这种存储方式的表成为索引组织表

在InnoDB存储引擎中，**聚集索引就是表**，是按照主键顺序存放的一颗**B+树**

如果在创建表时没有显式的定义主键，则InnoDB会按照如下方式选择或创建主键

* 首先判断表中是否有非空的唯一索引（Unique NOT NULL），如果有，则该列即为主键
  * 有多个非空的唯一索引时，InnoDB存储引擎将选择建表时**第一个定义的非空唯一索引**为主键，而不是按照 **定义的列顺序**
  * **第一个定义的非空唯一索引**类型为**int类型**时才会成为主键
  * _rowid（表的主键值）只能用于查看单个列为主键的情况，对于多列组成的主键就显得无能为力了
* 如果不符合上述条件，InnoDB存储引擎自动创建一个6字节大小的指针

```shell
# 第一个定义的非空唯一索引a类型为字符串，没有定义此列为主键，查不到_rowid列
root@MySQL-01 19:27:  [chuchu]> create table l1 (id int,a char(10) not null,b int not null,unique key(a),unique key(b));
Query OK, 0 rows affected (0.01 sec)

root@MySQL-01 19:27:  [chuchu]> insert into l1 values(1,'tom',2),(2,'nj',3);
Query OK, 2 rows affected (0.04 sec)
Records: 2  Duplicates: 0  Warnings: 0

root@MySQL-01 19:28:  [chuchu]> select id,a,b,_rowid from l1;
ERROR 1054 (42S22): Unknown column '_rowid' in 'field list'

# 虽然定义列的顺序是a，b，但是定义索引的顺序是b，a,所以最后是b列为索引
root@MySQL-01 02:01:  [chuchu]> create table l5 (id int,a int not null,b int not null,unique key(b),unique key(a));
Query OK, 0 rows affected (0.01 sec)

root@MySQL-01 02:08:  [chuchu]> insert into l5 select 1,2,3;
Query OK, 1 row affected (0.00 sec)
Records: 1  Duplicates: 0  Warnings: 0

root@MySQL-01 02:08:  [chuchu]> insert into l5 select 4,5,6;
Query OK, 1 row affected (0.00 sec)
Records: 1  Duplicates: 0  Warnings: 0

root@MySQL-01 02:08:  [chuchu]> select a,b,_rowid from l5;
+---+---+--------+
| a | b | _rowid |
+---+---+--------+
| 2 | 3 |      3 |
| 5 | 6 |      6 |
+---+---+--------+
2 rows in set (0.00 sec)


#第一个定义的唯一索引是a，但是此列可以为空，所以第一个非空唯一索引是b
root@MySQL-01 01:59:  [chuchu]> create table l4 (id int,a char(10) null,b int not null,unique key(a),unique key(b));
Query OK, 0 rows affected (0.01 sec)

root@MySQL-01 02:00:  [chuchu]> insert into l4 select 4,5,6;
Query OK, 1 row affected (0.01 sec)
Records: 1  Duplicates: 0  Warnings: 0

root@MySQL-01 02:00:  [chuchu]> insert into l4 select 1,2,3;
Query OK, 1 row affected (0.00 sec)
Records: 1  Duplicates: 0  Warnings: 0

root@MySQL-01 02:01:  [chuchu]> select a,b,_rowid from l4;
+------+---+--------+
| a    | b | _rowid |
+------+---+--------+
| 2    | 3 |      3 |
| 5    | 6 |      6 |
+------+---+--------+
2 rows in set (0.00 sec)
```

## InnoDB逻辑存储结构

从InnoDB引擎逻辑存储结构看，所有数据都被逻辑的存放在一个空间中，称之为表空间

表空间由段（segment）、区（extent）、页（page）组成。页在一些文档中有时也称为块（block）

![](pic/表空间.png)

### 表空间

表空间是InnoDB存储引擎逻辑结构的最高层，所有的数据都存放在表空间中

共享表空间：ibdata1，所有数据都存放在这个表空间内，如果用户启用独立表空间innodb_file_per_table，则每张表的数据单独放到一个表空间中

如果启用了独立表空间，每张表的**独立表空间存放的只是：数据、索引、插入缓冲Bitmap页**

**回滚（undo）信息，插入缓冲索引页、系统事务信息，二次写缓冲（Double write buffer）等**还是存放在原来的**共享表空间内**

**注意**

```shell
1 即使启用独立表空间以后，共享表空间还是会不断增大，因为有undo的信息
2 在事务未提交完成以前会产生undo信息，就算事务回滚或提交以后，ibdata1表空间大小也不会缩减
3 master thread每10秒会执行一次的full purge操作（清理无用的undo页），清理的时候将这些空间标记为可用空间，而不会删除，供下次undo使用
```

#### 段

