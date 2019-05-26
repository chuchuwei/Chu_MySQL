# SQL

## 背景知识

### SQL语句分类

* SQL方案（schema）语句：用于定义存储数据库中的数据结构
* SQL数据语句：用于操作SQL方案语句所定义的数据结构
* SQL事物语句：用于开始、结束或回滚事物

### 数据类型

#### 数值型

##### 整型

| 类型      | 带符号的范围                                          | 无符号的范围                  |
| --------- | ----------------------------------------------------- | ----------------------------- |
| tinyint   | -128 ~ 127                                            | 0~255                         |
| smallint  | -32678 ~ 32767                                        | 0~65 535                      |
| mediumint | -8 388 608 ~ 8 388 607                                | 0~16 777 215                  |
| int       | -2 147 483 648~ 2 147483 647                          | 0~4 294 967 295               |
| bigint    | -9 223 372 036 854 775 898~ 9 223 372 036 854 775 807 | 0~ 18 446 744 073 709 551 615 |

* **unsigned**：无符号，指该列存储的数据大于等于0
* **zerofill**：缺失的用0填充，如果列中指定了zerofill，将自动增加**unsigned**属性

```shell
root@MySQL-01 15:14:  [test1]> create table chuchu(id int(2) unsigned);
Query OK, 0 rows affected (0.02 sec)

root@MySQL-01 15:23:  [test1]> insert into chuchu values(-1);
ERROR 1264 (22003): Out of range value for column 'id' at row 1
root@MySQL-01 15:24:  [test1]> insert into chuchu values(1);
Query OK, 1 row affected (0.00 sec)

root@MySQL-01 15:24:  [test1]> select * from chuchu;
+------+
| id   |
+------+
|    1 |
+------+
1 row in set (0.00 sec)


root@MySQL-01 15:24:  [test1]> create table chuchu1(id int(2) zerofill);
Query OK, 0 rows affected (0.01 sec)
root@MySQL-01 15:26:  [test1]> insert into chuchu1 values(2);
Query OK, 1 row affected (0.00 sec)

root@MySQL-01 15:26:  [test1]> insert into chuchu1 values(-2);
ERROR 1264 (22003): Out of range value for column 'id' at row 1
root@MySQL-01 15:27:  [test1]> select * from chuchu1;
+------+
| id   |
+------+
|   02 |
+------+
1 row in set (0.00 sec)
```

##### 浮点型

| 类型        | 数值范围                                                     | 备注                                     |
| ----------- | ------------------------------------------------------------ | ---------------------------------------- |
| float(M,d)  | -3.402823466E+38 ~ -1.175494351E-38 <br>1.175494351E-38 ~ 3.402823466E+38 | M指精度 代表总位数，d指标度 代表小数位。 |
| double(M,d) | -1.7976931348623157E+308 ~ 2.2250738585072014E-308<br>2.2250738585072014E-308 ~ 1.7976931348623157E+308 |                                          |

##### 定点数

decimal

##### 区别

* float、double、decimal在有精度和标度时，小数点位数超过定义位数会进行四舍五入
* float、double、decimal在没有精度和标度时，float、double 会按照实际精度显示，decimal则默认按照（10.0）显示，即只保留小数点前的整数
* float、double、decimal在没有精度和标度时，进行求和计算，float、double计算的有误差，decimal计算的是准确的数值

```shell
# 有精度和标度
root@MySQL-01 15:58:  [test1]> create table t15(id decimal(3,2),id1 float(3,2),id2 double(3,2));;
Query OK, 0 rows affected (0.02 sec)

root@MySQL-01 15:59:  [test1]> insert into t15 values(1.234,1.234,1.234);
Query OK, 1 row affected, 1 warning (0.01 sec)

root@MySQL-01 15:59:  [test1]> insert into t15 values(1.236,1.236,1.236);
Query OK, 1 row affected, 1 warning (0.01 sec)

root@MySQL-01 16:00:  [test1]> select * from t15;
+------+------+------+
| id   | id1  | id2  |
+------+------+------+
| 1.23 | 1.23 | 1.23 |
| 1.24 | 1.24 | 1.24 |
+------+------+------+
2 rows in set (0.00 sec)

# 没有精度和标度
root@MySQL-01 16:00:  [test1]> create table t16(id decimal,id1 float,id2 double);
Query OK, 0 rows affected (0.02 sec)

root@MySQL-01 16:01:  [test1]> insert into t16 values(1.236,1.236,1.236);
Query OK, 1 row affected, 1 warning (0.01 sec)

root@MySQL-01 16:01:  [test1]> select * from t16;
+------+-------+-------+
| id   | id1   | id2   |
+------+-------+-------+
|    1 | 1.236 | 1.236 |
+------+-------+-------+
1 row in set (0.00 sec)
root@MySQL-01 16:08:  [test1]> desc t16;
+-------+---------------+------+-----+---------+-------+
| Field | Type          | Null | Key | Default | Extra |
+-------+---------------+------+-----+---------+-------+
| id    | decimal(10,0) | YES  |     | NULL    |       |
| id1   | float         | YES  |     | NULL    |       |
| id2   | double        | YES  |     | NULL    |       |
+-------+---------------+------+-----+---------+-------+
3 rows in set (0.00 sec)

# 求和
root@MySQL-01 16:17:  [test1]> select * from t15;
+------+------+------+
| id   | id1  | id2  |
+------+------+------+
| 1.23 | 1.23 | 1.23 |
| 1.24 | 1.24 | 1.24 |
| 1.24 | 1.24 | 1.24 |
+------+------+------+
3 rows in set (0.00 sec)
root@MySQL-01 16:19:  [test1]> select sum(id),sum(id1),sum(id2) from t15;
+---------+----------+----------+
| sum(id) | sum(id1) | sum(id2) |
+---------+----------+----------+
|    3.71 |     3.71 |     3.71 |
+---------+----------+----------+
1 row in set (0.00 sec)

# 无精度和标度
root@MySQL-01 16:20:  [test1]> select * from t16;
+------+---------+---------+
| id   | id1     | id2     |
+------+---------+---------+
|    1 |   1.236 |   1.236 |
|  100 | 100.236 | 100.236 |
+------+---------+---------+
2 rows in set (0.00 sec)

root@MySQL-01 16:20:  [test1]> select sum(id),sum(id1),sum(id2) from t16;
+---------+--------------------+--------------------+
| sum(id) | sum(id1)           | sum(id2)           |
+---------+--------------------+--------------------+
|     101 | 101.47200000286102 | 101.47200000000001 |
+---------+--------------------+--------------------+
1 row in set (0.00 sec)
```

#### 字符型

* char(M)：定长，存储最大字符数为255
* varchar(M)：变长，存储最大字符数为65535

##### 区别

* char(M)，实占M个字符，不够M个，右侧补空格，取出时，去除右侧空格
* varchar(M)，不需要向右填充，所有字符数可变，有1-2个字节来标记真实的长度

#### 日期型

| 类型      | 默认格式            | 允许的值 | 备注                                                         |
| --------- | ------------------- | -------- | ------------------------------------------------------------ |
| date      | YYYY-MM-DD          |          | 可用于存储出生日期或预计订单发送时间                         |
| datetime  | YYYY-MM-DD HH:MI:SS |          | 可用于存储订单实际发送时间                                   |
| timestamp | YYYY-MM-DD HH:MI:SS |          | 可用于记录用户何时修改特定行，timestamp与datetime类型一样，单MySQL服务器可以在向表中增加或修改数据行时自动为timestamp列产生当前的日期/时间 |
| year      | YYYY                |          |                                                              |
| time      | HHH:MI:SS           |          |                                                              |

```shell
root@MySQL-01 17:06:  [test1]> create table t18(id int,a datetime,b timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP);
Query OK, 0 rows affected (0.02 sec)

root@MySQL-01 17:08:  [test1]> insert into t18 values(1,'2019-10-04','2018-10-04');
Query OK, 1 row affected (0.01 sec)

root@MySQL-01 17:09:  [test1]> select * from t18;
+------+---------------------+---------------------+
| id   | a                   | b                   |
+------+---------------------+---------------------+
|    1 | 2019-10-04 00:00:00 | 2018-10-04 00:00:00 |
+------+---------------------+---------------------+
1 row in set (0.00 sec)

root@MySQL-01 17:09:  [test1]> insert into t18 values(1,'2019-10-04',null);
Query OK, 1 row affected (0.01 sec)

root@MySQL-01 17:10:  [test1]> insert into t18 values(1,null,null);
Query OK, 1 row affected (0.00 sec)

root@MySQL-01 17:11:  [test1]> select * from t18;
+------+---------------------+---------------------+
| id   | a                   | b                   |
+------+---------------------+---------------------+
|    1 | 2019-10-04 00:00:00 | 2018-10-04 00:00:00 |
|    1 | 2019-10-04 00:00:00 | NULL                |
|    1 | NULL                | NULL                |
+------+---------------------+---------------------+

root@MySQL-01 17:13:  [test1]> update t18 set id=3 where id=2;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

root@MySQL-01 17:15:  [test1]> select * from t18;
+------+---------------------+---------------------+
| id   | a                   | b                   |
+------+---------------------+---------------------+
|    1 | 2019-10-04 00:00:00 | 2018-10-04 00:00:00 |
|    1 | 2019-10-04 00:00:00 | NULL                |
|    1 | NULL                | NULL                |
|    3 | 2017-10-04 00:00:00 | 2019-05-16 17:15:21 |
+------+---------------------+---------------------+
4 rows in set (0.00 sec)

root@MySQL-01 17:15:  [test1]> insert into t18 values(2,'2017-10-04',current_timestamp);
Query OK, 1 row affected (0.01 sec)

root@MySQL-01 17:16:  [test1]> select * from t18;
+------+---------------------+---------------------+
| id   | a                   | b                   |
+------+---------------------+---------------------+
|    1 | 2019-10-04 00:00:00 | 2018-10-04 00:00:00 |
|    1 | 2019-10-04 00:00:00 | NULL                |
|    1 | NULL                | NULL                |
|    3 | 2017-10-04 00:00:00 | 2019-05-16 17:15:21 |
|    2 | 2017-10-04 00:00:00 | 2019-05-16 17:16:15 |
+------+---------------------+---------------------+
5 rows in set (0.00 sec)

root@MySQL-01 17:16:  [test1]> insert into t18 values(2,null,current_timestamp);
Query OK, 1 row affected (0.01 sec)

root@MySQL-01 17:16:  [test1]> select * from t18;
+------+---------------------+---------------------+
| id   | a                   | b                   |
+------+---------------------+---------------------+
|    1 | 2019-10-04 00:00:00 | 2018-10-04 00:00:00 |
|    1 | 2019-10-04 00:00:00 | NULL                |
|    1 | NULL                | NULL                |
|    3 | 2017-10-04 00:00:00 | 2019-05-16 17:15:21 |
|    2 | 2017-10-04 00:00:00 | 2019-05-16 17:16:15 |
|    2 | NULL                | 2019-05-16 17:16:44 |
+------+---------------------+---------------------+
6 rows in set (0.00 sec)
```

