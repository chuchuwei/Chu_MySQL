# MySQL参数设置

**innodb_buffer_pool_size 参数**

```shell
ERROR 1206 (HY000): The total number of locks exceeds the lock table size

可能是由于innodb_buffer_pool_size参数设置不合理导致的报错
```

查看参数如下：

```shell
mysql>show global variables like "innodb_buffer_pool_size";
+-------------------------+-----------------+
| Variable_name           | Value           |
+-------------------------+-----------------+
| innodb_buffer_pool_size | 12884901888     |    
+-------------------------+-----------------+
mysql> show global variables like "%innodb_buffer_pool_%";
+-------------------------------------+----------------+
| Variable_name                       | Value          |
+-------------------------------------+----------------+
| innodb_buffer_pool_chunk_size       | 134217728      |
| innodb_buffer_pool_dump_at_shutdown | ON             |
| innodb_buffer_pool_dump_now         | OFF            |
| innodb_buffer_pool_dump_pct         | 25             |
| innodb_buffer_pool_filename         | ib_buffer_pool |
| innodb_buffer_pool_instances        | 8              |
| innodb_buffer_pool_load_abort       | OFF            |
| innodb_buffer_pool_load_at_startup  | ON             |
| innodb_buffer_pool_load_now         | OFF            |
| innodb_buffer_pool_size             | 12884901888    |
+-------------------------------------+----------------+
10 rows in set (0.01 sec)


mysql>show global status like "innodb_buffer_pool_pages_total";
+----------------------------+-----------------+
| Variable_name                  | Value       |
+----------------------------+-----------------+
| innodb_buffer_pool_pages_total | 786336      |
+----------------------------+-----------------+
mysql>show global status like "innodb_buffer_pool_pages_data";
+-------------------------+-----------------+
| Variable_name                 | Value     |
+-------------------------+-----------------+
| innodb_buffer_pool_pages_data | 751208    |    
+-------------------------+-----------------+
```

```shell
#innodb_buffer_pool_pages_data为包含数据的页数，innodb_buffer_pool_pages_total为总页数

1 #Innodb_buffer_pool_pages_data'  / 'Innodb_buffer_pool_pages_total'*100%
#当结果 > 95% 则建议增加 innodb_buffer_pool_size，一般建议设置为物理内存的75%
2 #当结果 < 95% 则减少 innodb_buffer_pool_size， 建议 'Innodb_buffer_pool_pages_data' * 'Innodb_page_size' * 1.05 / (1024*1024*1024)
innodb_buffer_pool_size的值为innodb_buffer_pool_chunk_size*innodb_buffer_pool_instances的整数倍
客户实际内存是64G，建议设置为48G，因为有两台mysql实例，所以每台都24G
```

**table_open_cache**

```shell
ERROR 1615 (HY000): Prepared statement needs to be re-prepared

可能是由于table_open_cache参数设置不合理导致的
```

查看参数如下：

```shell
mysql>show global status like "Open%tables";
+-------------------------+-----------------+
| Variable_name           | Value           |
+-------------------------+-----------------+
| Open_tables             | 2000            |
| Opened_tables           | 190649          |
+-------------------------+-----------------+
返回行数：[2]，耗时：10 ms.
mysql>show global variables like '%table_open_cache%';
+----------------------------+-----------------+
| Variable_name              | Value           |
+----------------------------+-----------------+
| table_open_cache           | 2000            |
| table_open_cache_instances | 1               |
+----------------------------+-----------------+
```



```shell
Open_tables表示打开表的数量，Opened_tables表示打开过的表数量，如果Opened_tables数量过大，
说明配置中table_open_cache值可能太小 
 

比较合适的值为： 
Open_tables / Opened_tables * 100% >= 85% 
Open_tables / table_open_cache * 100% <= 95%

#Table_definition_Cache缓存frm文件，关于table_open_cache，文档中并没有说明，想来应该是ibd/MYI/MYD；
#所以Table_definition_Cache的值为table_open_cache的值的1/3，即Table_definition_Cache=table_open_cache/3

假如以客户这个为例，Opened_tables=190649，所以根据Open_tables / Opened_tables * 100% >= 85%，#Open_tables至少为0.85*190649=162051.65
1 #table_open_cache的值为table_open_cache（默认或配置文件中初始定义的值）的整数倍，即table_open_cache（默认或配置文件中初始定义的值）的整数倍
2 #table_open_cache的值需要比Opened_tables的值大，所以建议设置200000
3 #Table_definition_Cache的值建议设置60000
3 #set global table_open_cache=200000
```

```shell
如果对此参数的把握不是很准，VPS管理百科给出一个很保守的设置建议：把MySQL数据库放在生产环境中试运行一段时间
#然后把参数的值调整得比Opened_tables的数值大一些，并且保证在比较高负载的极端条件下依然比Opened_tables略大。
在mysql默认安装情况下，table_cache的值在2G内存以下的机器中的值默认时256到 512，如果机器有4G内存,则默认这个值是2048，

```

备注：如果设置RDS的参数的话，控制台可以直接更改，需要注意控制台设置的极限值

比如：

![](pic\05.png)

Table_definition_Cache的最大值是80000多

**sql_big_selects参数**

> RDS 的 sql_big_selects参数 控制台上没有，是通过调整参数max_join_size控制sql_big_selects的值为off或者on

```shell
sql_big_selects（作用范围：全局、会话；动态）
服务器会把此变量与系统变量max_join_size一起使用。如果sql_big_selects为1（默认）即ON，服务器会接受那些返回任意大小结果集的查询。如果sql_big_selects为0，即OFF，服务器会拒绝那些由可能返回大量行的查询。在这种情况下，执行连接操作时，会使用max_join_size的值：服务器会对它需要检查的行组合数量进行估算，如果该值超过了max_join_size的值，那么服务器将返回一个错误，而不会执行该查询。
将max_join_size设置为DEFAULT以外的某个值，会自动将sql_big_selects设置为0。
```
![](pic\07.png)

![](pic\08.png)

**控制台参数max_join_size默认值为18446744073709551615**

![](pic\02.png)

**查看参数sql_big_selects的值为ON**

![](pic\03.png)

将控制台参数max_join_size的值改为非18446744073709551615，则sql_big_selects的值为OFF

![](D:/DBA%E6%A8%A1%E6%8B%9F%E5%AE%A2%E6%88%B7%E6%B1%87%E6%80%BB/github/Chu_MySQL/%E6%97%A5%E5%B8%B8/MySQL%E6%93%8D%E4%BD%9C%E7%B1%BB/Case/MySQL%E5%8F%82%E6%95%B0%E8%AE%BE%E7%BD%AE/pic/06.png)



> mysql 各参数链接：https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html