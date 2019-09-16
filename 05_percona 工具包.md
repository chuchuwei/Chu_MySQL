## percona 工具包的使用

### 安装

```shell
1 下载 Percona Toolkit
https://www.percona.com/downloads/percona-toolkit/LATEST/

2 解压
tar -xf tar -xf percona-toolkit-3.0.13_x86_64.tar.gz

3 安装
[root@localhost percona-toolkit-3.0.13]# perl Makefile.PL 
Can't locate ExtUtils/MakeMaker.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at Makefile.PL line 1.
BEGIN failed--compilation aborted at Makefile.PL line 1.
# 报错原因为缺少依赖

4 安装依赖
yum install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker

5 编译
perl Makefile.PL
make
make test
make install

[root@localhost percona-toolkit-3.0.13]# perl Makefile.PL 
Checking if your kit is complete...
Looks good
Writing Makefile for percona-toolkit
[root@localhost percona-toolkit-3.0.13]# make
cp bin/pt-mysql-summary blib/script/pt-mysql-summary
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-mysql-summary
cp bin/pt-mongodb-summary blib/script/pt-mongodb-summary
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-mongodb-summary
cp bin/pt-kill blib/script/pt-kill
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-kill
cp bin/pt-online-schema-change blib/script/pt-online-schema-change
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-online-schema-change
cp bin/pt-table-sync blib/script/pt-table-sync
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-table-sync
cp bin/pt-upgrade blib/script/pt-upgrade
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-upgrade
cp bin/pt-table-usage blib/script/pt-table-usage
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-table-usage
cp bin/pt-fifo-split blib/script/pt-fifo-split
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-fifo-split
cp bin/pt-slave-find blib/script/pt-slave-find
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-slave-find
cp bin/pt-ioprofile blib/script/pt-ioprofile
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-ioprofile
cp bin/pt-find blib/script/pt-find
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-find
cp bin/pt-archiver blib/script/pt-archiver
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-archiver
cp bin/pt-deadlock-logger blib/script/pt-deadlock-logger
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-deadlock-logger
cp bin/pt-fingerprint blib/script/pt-fingerprint
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-fingerprint
cp bin/pt-mext blib/script/pt-mext
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-mext
cp bin/pt-secure-collect blib/script/pt-secure-collect
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-secure-collect
cp bin/pt-slave-restart blib/script/pt-slave-restart
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-slave-restart
cp bin/pt-summary blib/script/pt-summary
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-summary
cp bin/pt-fk-error-logger blib/script/pt-fk-error-logger
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-fk-error-logger
cp bin/pt-table-checksum blib/script/pt-table-checksum
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-table-checksum
cp bin/pt-query-digest blib/script/pt-query-digest
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-query-digest
cp bin/pt-show-grants blib/script/pt-show-grants
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-show-grants
cp bin/pt-mongodb-query-digest blib/script/pt-mongodb-query-digest
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-mongodb-query-digest
cp bin/pt-pmp blib/script/pt-pmp
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-pmp
cp bin/pt-align blib/script/pt-align
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-align
cp bin/pt-heartbeat blib/script/pt-heartbeat
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-heartbeat
cp bin/pt-slave-delay blib/script/pt-slave-delay
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-slave-delay
cp bin/pt-sift blib/script/pt-sift
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-sift
cp bin/pt-diskstats blib/script/pt-diskstats
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-diskstats
cp bin/pt-visual-explain blib/script/pt-visual-explain
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-visual-explain
cp bin/pt-variable-advisor blib/script/pt-variable-advisor
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-variable-advisor
cp bin/pt-index-usage blib/script/pt-index-usage
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-index-usage
cp bin/pt-duplicate-key-checker blib/script/pt-duplicate-key-checker
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-duplicate-key-checker
cp bin/pt-config-diff blib/script/pt-config-diff
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-config-diff
cp bin/pt-stalk blib/script/pt-stalk
/usr/bin/perl -MExtUtils::MY -e 'MY->fixin(shift)' -- blib/script/pt-stalk
Manifying blib/man1/pt-mysql-summary.1p
Manifying blib/man1/pt-kill.1p
Manifying blib/man1/pt-online-schema-change.1p
Manifying blib/man1/pt-table-sync.1p
Manifying blib/man1/pt-upgrade.1p
Manifying blib/man1/pt-table-usage.1p
Manifying blib/man1/pt-fifo-split.1p
Manifying blib/man1/pt-slave-find.1p
Manifying blib/man1/pt-ioprofile.1p
Manifying blib/man1/pt-find.1p
Manifying blib/man1/pt-archiver.1p
Manifying blib/man1/pt-deadlock-logger.1p
Manifying blib/man1/pt-fingerprint.1p
Manifying blib/man1/pt-mext.1p
Manifying blib/man1/pt-secure-collect.1p
Manifying blib/man1/pt-slave-restart.1p
Manifying blib/man1/pt-summary.1p
Manifying blib/man1/pt-fk-error-logger.1p
Manifying blib/man1/pt-table-checksum.1p
Manifying blib/man1/pt-query-digest.1p
Manifying blib/man1/pt-show-grants.1p
Manifying blib/man1/percona-toolkit.1p
Manifying blib/man1/pt-pmp.1p
Manifying blib/man1/pt-align.1p
Manifying blib/man1/pt-heartbeat.1p
Manifying blib/man1/pt-slave-delay.1p
Manifying blib/man1/pt-sift.1p
Manifying blib/man1/pt-diskstats.1p
Manifying blib/man1/pt-visual-explain.1p
Manifying blib/man1/pt-variable-advisor.1p
Manifying blib/man1/pt-index-usage.1p
Manifying blib/man1/pt-duplicate-key-checker.1p
Manifying blib/man1/pt-config-diff.1p
Manifying blib/man1/pt-stalk.1p

[root@localhost percona-toolkit-3.0.13]# make test
No tests defined for percona-toolkit extension.

[root@localhost percona-toolkit-3.0.13]# make install
Installing /usr/local/share/man/man1/pt-mysql-summary.1p
Installing /usr/local/share/man/man1/pt-kill.1p
Installing /usr/local/share/man/man1/pt-online-schema-change.1p
Installing /usr/local/share/man/man1/pt-table-sync.1p
Installing /usr/local/share/man/man1/pt-upgrade.1p
Installing /usr/local/share/man/man1/pt-table-usage.1p
Installing /usr/local/share/man/man1/pt-fifo-split.1p
Installing /usr/local/share/man/man1/pt-slave-find.1p
Installing /usr/local/share/man/man1/pt-ioprofile.1p
Installing /usr/local/share/man/man1/pt-find.1p
Installing /usr/local/share/man/man1/pt-archiver.1p
Installing /usr/local/share/man/man1/pt-deadlock-logger.1p
Installing /usr/local/share/man/man1/pt-fingerprint.1p
Installing /usr/local/share/man/man1/pt-mext.1p
Installing /usr/local/share/man/man1/pt-secure-collect.1p
Installing /usr/local/share/man/man1/pt-slave-restart.1p
Installing /usr/local/share/man/man1/pt-summary.1p
Installing /usr/local/share/man/man1/pt-fk-error-logger.1p
Installing /usr/local/share/man/man1/pt-table-checksum.1p
Installing /usr/local/share/man/man1/pt-query-digest.1p
Installing /usr/local/share/man/man1/pt-show-grants.1p
Installing /usr/local/share/man/man1/percona-toolkit.1p
Installing /usr/local/share/man/man1/pt-pmp.1p
Installing /usr/local/share/man/man1/pt-align.1p
Installing /usr/local/share/man/man1/pt-heartbeat.1p
Installing /usr/local/share/man/man1/pt-slave-delay.1p
Installing /usr/local/share/man/man1/pt-sift.1p
Installing /usr/local/share/man/man1/pt-diskstats.1p
Installing /usr/local/share/man/man1/pt-visual-explain.1p
Installing /usr/local/share/man/man1/pt-variable-advisor.1p
Installing /usr/local/share/man/man1/pt-index-usage.1p
Installing /usr/local/share/man/man1/pt-duplicate-key-checker.1p
Installing /usr/local/share/man/man1/pt-config-diff.1p
Installing /usr/local/share/man/man1/pt-stalk.1p
Installing /usr/local/bin/pt-mysql-summary
Installing /usr/local/bin/pt-mongodb-summary
Installing /usr/local/bin/pt-kill
Installing /usr/local/bin/pt-online-schema-change
Installing /usr/local/bin/pt-table-sync
Installing /usr/local/bin/pt-upgrade
Installing /usr/local/bin/pt-table-usage
Installing /usr/local/bin/pt-fifo-split
Installing /usr/local/bin/pt-slave-find
Installing /usr/local/bin/pt-ioprofile
Installing /usr/local/bin/pt-find
Installing /usr/local/bin/pt-archiver
Installing /usr/local/bin/pt-deadlock-logger
Installing /usr/local/bin/pt-fingerprint
Installing /usr/local/bin/pt-mext
Installing /usr/local/bin/pt-secure-collect
Installing /usr/local/bin/pt-slave-restart
Installing /usr/local/bin/pt-summary
Installing /usr/local/bin/pt-fk-error-logger
Installing /usr/local/bin/pt-table-checksum
Installing /usr/local/bin/pt-query-digest
Installing /usr/local/bin/pt-show-grants
Installing /usr/local/bin/pt-mongodb-query-digest
Installing /usr/local/bin/pt-pmp
Installing /usr/local/bin/pt-align
Installing /usr/local/bin/pt-heartbeat
Installing /usr/local/bin/pt-slave-delay
Installing /usr/local/bin/pt-sift
Installing /usr/local/bin/pt-diskstats
Installing /usr/local/bin/pt-visual-explain
Installing /usr/local/bin/pt-variable-advisor
Installing /usr/local/bin/pt-index-usage
Installing /usr/local/bin/pt-duplicate-key-checker
Installing /usr/local/bin/pt-config-diff
Installing /usr/local/bin/pt-stalk
Appending installation info to /usr/lib64/perl5/perllocal.pod

6 测试安装是否成功
# pt-query-digest --help
# pt-table-checksum --help


pt-query-digest [OPTIONS] [FILES] [DSN]
--create-review-table  当使用--review参数把分析结果输出到表中时，如果没有表就自动创建。
--create-history-table  当使用--history参数把分析结果输出到表中时，如果没有表就自动创建。
--filter  对输入的慢查询按指定的字符串进行匹配过滤后再进行分析
--limit    限制输出结果百分比或数量，默认值是20,即将最慢的20条语句输出，如果是50%则按总响应时间占比从大到小排序，输出到总和达到50%位置截止。
--host  mysql服务器地址
--user  mysql用户名
--password  mysql用户密码
--history 将分析结果保存到表中，分析结果比较详细，下次再使用--history时，如果存在相同的语句，且查询所在的时间区间和历史表中的不同，则会记录到数据表中，可以通过查询同一CHECKSUM来比较某类型查询的历史变化。
--review 将分析结果保存到表中，这个分析只是对查询条件进行参数化，一个类型的查询一条记录，比较简单。当下次使用--review时，如果存在相同的语句分析，就不会记录到数据表中。
--output 分析结果输出类型，值可以是report(标准分析报告)、slowlog(Mysql slow log)、json、json-anon，一般使用report，以便于阅读。
--since 从什么时间开始分析，值为字符串，可以是指定的某个”yyyy-mm-dd [hh:mm:ss]”格式的时间点，也可以是简单的一个时间值：s(秒)、h(小时)、m(分钟)、d(天)，如12h就表示从12小时前开始统计。
--until 截止时间，配合—since可以分析一段时间内的慢查询。
  
 
```

| 序号 | 工具命令                   | 工具作用                           | 备注             |
| ---- | -------------------------- | ---------------------------------- | ---------------- |
|      | *pt-duplicate-key-checker* | 列出并删除重复的索引和外键         |                  |
|      | *pt-online-schema-change*  | 在线修改表结构                     | 常用             |
|      | *pt-query-advisor*         | 分析查询语句，并给出建议，有*bug*  |                  |
|      | *pt-show-grants*           | 规范化和打印权限                   |                  |
|      | *pt-upgrade*               | 在多个服务器上执行查询，并比较不同 |                  |
|      | *pt-index-usage*           | 分析日志中索引使用情况，并出报告   |                  |
|      | *pt-pmp*                   | 为查询结果跟踪，并汇总跟踪结果     |                  |
|      | *pt-visual-explain*        | 格式化执行计划                     |                  |
|      | *pt-table-usage*           | 分析日志中查询并分析表使用情况     | *pt 2.2*新增命令 |
|      | *pt-config-diff*           | 比较配置文件和参数                 |                  |
|      | *pt-mysql-summary*         | 对*mysql*配置和*status*进行汇总    |                  |
|      | *pt-variable-advisor*      | 分析参数，并提出建议               |                  |
|      | *pt-deadlock-logger*       | 提取和记录*mysql*死锁信息          |                  |
|      | *pt-fk-error-logger*       | 提取和记录外键信息                 |                  |
|      | *pt-mext*                  | 并行查看*status*样本信息           |                  |
|      | *pt-query-digest*          | 分析查询日志，并产生报告           | 常用             |
|      | *pt-trend*                 | 按照时间段读取*slow*日志信息       |                  |
|      | *pt-heartbeat*             | 监控*mysql*复制延迟                |                  |
|      | *pt-slave-delay*           | 设定从落后主的时间                 |                  |
|      | *pt-slave-find*            | 查找和打印所有*mysql*复制层级关系  |                  |
|      | *pt-slave-restart*         | 监控*salve*错误，并尝试重启*salve* |                  |
|      | *pt-table-checksum*        | 校验主从复制一致性                 | 常用             |
|      | *pt-table-sync*            | 高效同步表数据                     |                  |
|      | *pt-diskstats*             | 查看系统磁盘状态                   |                  |
|      | *pt-fifo-split*            | 模拟切割文件并输出                 |                  |
|      | *pt-summary*               | 收集和显示系统概况                 |                  |
|      | *pt-stalk*                 | 出现问题时，收集诊断数据           |                  |
|      | *pt-sift*                  | 浏览由*pt-stalk*创建的文件         | *pt 2.2*新增命令 |
|      | *pt-ioprofile*             | 查询进程*IO*并打印一个*IO*活动表   | *pt 2.2*新增命令 |
|      | *pt-archiver*              | 将表数据归档到另一个表或文件中     | 常用             |
|      | *pt-find*                  | 查找表并执行命令                   |                  |
|      | *pt-kill*                  | *Kill*掉符合条件的*sql*            | 常用命令         |
|      | *pt-align*                 | 对齐其他工具的输出                 | *pt 2.2*新增命令 |
|      | *pt-fingerprint*           | 将查询转成密文                     | *pt 2.2*新增命令 |



### pt-query-digest使用

```shell
# 输出分为三部分：
第一部分：总体统计结果
第二部分：按照分组统计结果（占用时间最多的，占用CPU最多的语句等）
第三部分：每个语句的详细统计结果

[root@localhost percona-toolkit-3.0.13]# pt-query-digest /alidata/mysql/log/dataslow190722.log

执行日志分析的用户时间、系统时间、物理内存占用大小、虚拟内存占用大小
# 760ms user time, 70ms system time, 22.94M rss, 187.47M vsz
工具执行时间
# Current date: Mon Jul 22 15:15:31 2019
# Hostname: localhost.localdomain
# Files: /alidata/mysql/log/dataslow190722.log
语句总数量、唯一语句数量、QPS、并发数
# Overall: 229 total, 47 unique, 0.00 QPS, 0.00x concurrency _____________
日志记录的时间范围
# Time range: 2018-08-26T05:08:00 to 2019-06-11T06:18:05
属性                  总计      最小     最大     平均          标准    中等
# Attribute          total     min     max     avg     95%  stddev  median
# ============     ======= ======= ======= ======= ======= ======= =======
语句执行时间
# Exec time            61s   186us     12s   266ms   992ms      1s     4ms
锁占用时间
# Lock time             2s       0   460ms     9ms     4ms    52ms   247us
返回的行数
# Rows sent         38.36k       0   5.16k  171.54  441.81  696.78    4.96
扫描的行数
# Rows examine       8.48M       0 477.82k  37.92k 462.39k 124.33k  136.99
查询的字符数
# Query size        56.64k      17   1.25k  253.28  563.87  199.14  284.79

# Profile
所有语句的排序、语句ID                总的响应时间、该语句的总时间占比、语句执行次数、平均执行时间
# Rank Query ID                        Response time Calls R/Call V/M   It
# ==== =============================== ============= ===== ====== ===== ==
#    1 0x6A8C9AF2E1E6C2A974F7463233... 40.1495 65.9%     8 5.0187  5.01 SELECT test_while
#    2 0xF8308AB5224D9DEB88FAC3E3EE... 11.7109 19.2%    10 1.1711  0.01 UPDATE test_while
#    3 0xA174322ECAEB7D54E9AAF85E4A...  1.7121  2.8%     3 0.5707  0.08 SELECT information_schema.tables
#    4 0x4C0B0E6A37425C3F6A6AD5D8F8...  1.1016  1.8%    23 0.0479  0.14 SELECT information_schema.tables information_schema.KEY_COLUMN_USAGE
#    5 0xD1882526AC61CC0806075750D8...  0.8324  1.4%     3 0.2775  0.29 SELECT information_schema.tables
#    6 0x478300D9BFB3D9ACD80C66D0FF...  0.7096  1.2%     1 0.7096  0.00 SELECT information_schema.tables
#    7 0x64EF0EA126730002088884A136...  0.6531  1.1%     1 0.6531  0.00 
#    8 0xF2EDE9346DFAAFB221A7A6EF3D...  0.5904  1.0%    16 0.0369  0.02 SELECT information_schema.tables information_schema.KEY_COLUMN_USAGE
#    9 0x79521CD91BC757B8FCCCE24233...  0.4982  0.8%     2 0.2491  0.32 SELECT information_schema.tables information_schema.KEY_COLUMN_USAGE
# MISC 0xMISC                           2.9729  4.9%   162 0.0184   0.0 <38 ITEMS>

# Query 1: 0.00 QPS, 0.00x concurrency, ID 0x6A8C9AF2E1E6C2A974F7463233689145 at byte 125606
# Scores: V/M = 5.01
# Time range: 2019-05-30T04:35:51 to 2019-06-11T06:18:05
# Attribute    pct   total     min     max     avg     95%  stddev  median
# ============ === ======= ======= ======= ======= ======= ======= =======
# Count          3       8
# Exec time     65     40s   844ms     12s      5s     12s      5s      6s
# Lock time      0     2ms   135us   476us   201us   467us   103us   172us
# Rows sent      0       8       1       1       1       1       0       1
# Rows examine  44   3.73M 477.82k 477.82k 477.82k 477.82k       0 477.82k
# Query size     0     335      40      44   41.88   42.48    1.32   40.45
# String:
# Databases    test1
# Hosts        localhost
# Users        root
查询时间分布
# Query_time distribution
#   1us
#  10us
# 100us
#   1ms
#  10ms
# 100ms  ################################################################
#    1s  ##########################################
#  10s+  ################################################################
查询中涉及到的表
# Tables
#    SHOW TABLE STATUS FROM `test1` LIKE 'test_while'\G
#    SHOW CREATE TABLE `test1`.`test_while`\G
# EXPLAIN /*!50100 PARTITIONS*/
select count(*),sleep(10) from test_while\G

# Query 2: 0.00 QPS, 0.00x concurrency, ID 0xF8308AB5224D9DEB88FAC3E3EE2572CC at byte 123758
# Scores: V/M = 0.01
# Time range: 2019-05-30T03:39:31 to 2019-05-30T04:33:51
# Attribute    pct   total     min     max     avg     95%  stddev  median
# ============ === ======= ======= ======= ======= ======= ======= =======
# Count          4      10
# Exec time     19     12s   982ms      1s      1s      1s   112ms      1s
# Lock time      0     2ms   101us   238us   169us   214us    45us   167us
# Rows sent      0       0       0       0       0       0       0       0
# Rows examine  55   4.67M 477.82k 477.82k 477.82k 477.82k       0 477.82k
# Query size     0     370      37      37      37      37       0      37
# String:
# Databases    test1
# Hosts        localhost
# Users        root
# Query_time distribution
#   1us
#  10us
# 100us
#   1ms
#  10ms
# 100ms  #######
#    1s  ################################################################
#  10s+
# Tables
#    SHOW TABLE STATUS FROM `test1` LIKE 'test_while'\G
#    SHOW CREATE TABLE `test1`.`test_while`\G
update test_while set id=1 where id=2\G
# Converted for EXPLAIN
# EXPLAIN /*!50100 PARTITIONS*/
select  id=1 from test_while where  id=2\G
```



```shell
1 按照时间查询60天前的SQL
pt-query-digest --since=60d /alidata/mysql/log/dataslow190722.log

2 按照时间查询
pt-query-digest --since '2019-06-01 09:30:00' --until '2019-06-11 10:00:00' /alidata/mysql/log/dataslow190722.log

3 分析binlog 
pt-query-digest --type=binlog mysql-bin000001.sql > slow_report.log

4 分析general log;
 pt-query-digest --type=genlog general.log > slow_report.log

5 分析只含select语句的慢查询;
pt-query-digest --filter '$event->{fingerprint} =~ m/^select/i' slow.log

6 分析针对某个用户的慢查询;
pt-query-digest --filter '($event->{user} || "") =~ m/^root/i' slow.log

7 分析所有的全表扫描或full join的慢查询;
pt-query-digest --filter '(($event->{Full_scan} || "") eq "yes") || (($event->{Full_join} || "") eq "yes")' slow.log

8 把查询保存到query_review表;
pt-query-digest --user=root --password=waqb1314 --review h=localhost,D=test1,t=query_review --create-review-table /alidata/mysql/log/dataslow190722.log
```

### pt-online-schema-change用法

```shell
使用前需要表有主键或唯一键，否则会报错
[root@localhost ~]# pt-online-schema-change  --execute  --alter "drop column name3" h=localhost,P=3306,u=root,p=waqb1314,D=test1,t=t9
No slaves found.  See --recursion-method if host localhost.localdomain has slaves.
Not checking slave lag because no slaves were found and --check-slave-lag was not specified.
Operation, tries, wait:
  analyze_table, 10, 1
  copy_rows, 10, 0.25
  create_triggers, 10, 1
  drop_triggers, 10, 1
  swap_tables, 10, 1
  update_foreign_keys, 10, 1
Altering `test1`.`t9`...
Creating new table...
Created new table test1._t9_new OK.
Altering new table...
Altered `test1`.`_t9_new` OK.
2019-07-25T16:06:36 Creating triggers...
2019-07-25T16:07:04 Created triggers OK.
2019-07-25T16:07:04 Copying approximately 3 rows...
2019-07-25T16:07:04 Copied rows OK.
2019-07-25T16:07:04 Analyzing new table...
2019-07-25T16:07:04 Swapping tables...
2019-07-25T16:07:04 Swapped original and new tables OK.
2019-07-25T16:07:04 Dropping old table...
2019-07-25T16:07:04 Dropped old table `test1`.`_t9_old` OK.
2019-07-25T16:07:04 Dropping triggers...
2019-07-25T16:07:04 Dropped triggers OK.
Successfully altered `test1`.`t9`.
```

