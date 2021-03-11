### 注意事项

```shell
# log_slave_updates 此参数开启，从库的relay log会记录进binlog中

前提是二进制安装的数据库mysql5.7
slave1
1 停服务
2 清环境
3 注释参数
rpl_semi_sync_master_enabled=1
rpl_semi_sync_master_timeout=1000
rpl_semi_sync_slave_enabled=1
4 重新初始化
/alidata/mysql/bin/mysqld --initialize-insecure --datadir=/alidata/mysql/data/ --basedir=/alidata/mysql/ --user=mysql
5 启服务
6 安装插件
主节点：MariaDB [(none)]> install plugin rpl_semi_sync_master soname 'semisync_master.so';
从节点：MariaDB [dba]> INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so';
7 注释参数打开
8 重启
9 reset master
10 导入数据
mysql -uroot -pWaqb1314 < /alidata/install/mysqlmasterall3.sql
11 声明
change master to master_host='10.200.63.167',master_user='slave',master_password='abc123',MASTER_LOG_FILE='mybinlog.000023',MASTER_LOG_POS=274;
master_host='10.200.63.167',master_user='slave',master_password='abc123',master_auto_position=1;

slave2 相同操作


管理节点
1 检察状态
masterha_check_status --conf=/etc/masterha/app1.cnf
2 启动
nohup masterha_manager --conf=/etc/masterha/app1.cnf --ignore_fail_on_start > /tmp/mha_manager.log &1 &
停止
masterha_stop --conf=/etc/masterha/app1.cnf
3 查看复制状态
masterha_check_repl --conf=/etc/masterha/app1.cnf
4 查看ssh状态
masterha_check_ssh --global_conf=/etc/masterha/masterha_default.cnf --conf=/etc/masterha/app1.cnf

# 有几个状态参数值得关注的：
rpl_semi_sync_master_status：显示主服务是异步复制模式还是半同步复制模式
rpl_semi_sync_master_clients：显示有多少个从服务器配置为半同步复制模式
rpl_semi_sync_master_yes_tx：显示从服务器确认成功提交的数量
rpl_semi_sync_master_no_tx：显示从服务器确认不成功提交的数量
rpl_semi_sync_master_tx_avg_wait_time：事务因开启 semi_sync，平均需要额外等待的时间
rpl_semi_sync_master_net_avg_wait_time：事务进入等待队列后，到网络平均等待时间 

# 下载mha：https://github.com/yoshinorim/mha4mysql-manager/wiki/Downloads
```

