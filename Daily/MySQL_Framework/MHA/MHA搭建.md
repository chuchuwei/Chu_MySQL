# MHA搭建步骤                                                                                                                                                                                                                        

## 环境

三台服务器

1主，1从，1个Manager节点

## 步骤

### 配置互相无交互

```shell
三台服务器分别执行
ssh-keygen
ssh-copy-id ip1
ssh-copy-id ip2
```

### 搭建主从半同步

#### 安装数据库

两台服务器分别安装

> percona mysql 5.7.18

```shell
# 安装脚本
#!/bin/bash

DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

#\mv /alidata/mysql /alidata/mysql.bak.$DATE &> /dev/null
mkdir -p /alidata/mysql
mkdir -p /alidata/mysql/data
mkdir -p /alidata/mysql/log
mkdir -p /alidata/install
mkdir -p /usr/local/mysql/bin
mkdir -p /alidata/mysql/mybinlog
if [ `uname -m` == "x86_64" ];then   #查看是系统否是64位的，如果是就下载64位的包
  rm -rf mysql-5.7.17-linux-glibc2.5-x86_64
  if [ ! -f mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz ];then
	 wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/mysql/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
  fi
  tar -xzvf mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
  mv mysql-5.7.17-linux-glibc2.5-x86_64/* /alidata/mysql
fi
#install mysql
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql

\cp -f /alidata/mysql/support-files/mysql.server /etc/init.d/mysqld
sed -i 's#^basedir=$#basedir=/alidata/mysql#' /etc/init.d/mysqld
sed -i 's#^datadir=$#datadir=/alidata/mysql/data#' /etc/init.d/mysqld
cat > /etc/my.cnf <<END
[client]
port = 3306
socket = /alidata/mysql/mysql.sock

[mysql]
prompt="\u@MySQL-01 \R:\m:\s [\d]> "
no-auto-rehash  #关闭自动补全命令，auto-rehash表示开启自动补全

[mysqld]
user = mysql
port = 3306
basedir = /alidata/mysql/
datadir = /alidata/mysql/data/
socket  = /alidata/mysql/mysql.sock
pid-file = /alidata/mysql/MySQL-01.pid
slow_query_log_file = /alidata/mysql/log/dataslow.log
log_error = /alidata/mysql/log/dataerror.log
server_id = 1
log-bin = /alidata/mysql/log/mybinlog.log
gtid_mode=on
enforce_gtid_consistency=1
character-set-server = utf8mb4
skip_name_resolve = 1  
open_files_limit = 65535 
back_log = 1024 
max_connections = 512
max_connect_errors = 1000000
table_open_cache = 20000
table_definition_cache = 20000
table_open_cache_instances = 64
thread_stack = 512K
external-locking = FALSE
max_allowed_packet = 32M
sort_buffer_size = 4M
join_buffer_size = 4M
thread_cache_size = 768
query_cache_size = 0
query_cache_type = 0
interactive_timeout = 600
wait_timeout = 600
tmp_table_size = 32M
max_heap_table_size = 32M
slow_query_log = 1
long_query_time = 0.1
log_queries_not_using_indexes =1
log_throttle_queries_not_using_indexes = 60
min_examined_row_limit = 100
log_slow_admin_statements = 1
log_slow_slave_statements = 1
sync_binlog = 1
binlog_cache_size = 4M
max_binlog_cache_size = 2G
max_binlog_size = 1G
expire_logs_days = 30
master_info_repository = TABLE
relay_log_info_repository = TABLE
#gtid_mode = on
#enforce_gtid_consistency = 1
log_slave_updates
binlog_format = row
binlog_checksum = 1
relay_log_recovery = 1
relay-log-purge = 1
key_buffer_size = 32M
read_buffer_size = 8M
read_rnd_buffer_size = 4M
bulk_insert_buffer_size = 64M
myisam_sort_buffer_size = 128M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1
lock_wait_timeout = 3600
explicit_defaults_for_timestamp = 1
innodb_thread_concurrency = 0
innodb_sync_spin_loops = 100
innodb_spin_wait_delay = 30

transaction_isolation = REPEATABLE-READ
#innodb_buffer_pool_size = 22938M  #暗安装时可能由于size太大报错，改小一点就可以了，一般8M,64M
innodb_buffer_pool_instances = 8
innodb_buffer_pool_load_at_startup = 1
innodb_buffer_pool_dump_at_shutdown = 1
#innodb_data_file_path = ibdata1:1G:autoextend  
innodb_flush_log_at_trx_commit = 1
innodb_log_buffer_size = 32M
innodb_log_file_size = 2G
innodb_log_files_in_group = 2
innodb_max_undo_log_size = 4G

innodb_io_capacity = 4000
innodb_io_capacity_max = 8000
innodb_flush_neighbors = 0
innodb_write_io_threads = 8
innodb_read_io_threads = 8
innodb_purge_threads = 4
innodb_page_cleaners = 4
innodb_open_files = 65535
innodb_max_dirty_pages_pct = 50
innodb_flush_method = O_DIRECT
innodb_lru_scan_depth = 4000
innodb_checksums = 1
innodb_checksum_algorithm = crc32
innodb_lock_wait_timeout = 10
innodb_rollback_on_timeout = 1
innodb_print_all_deadlocks = 1
innodb_file_per_table = 1
innodb_online_alter_log_max_size = 4G
internal_tmp_disk_storage_engine = InnoDB
innodb_stats_on_metadata = 0

innodb_status_file = 1
innodb_status_output = 0
innodb_status_output_locks = 0

#performance_schema
performance_schema = 1
performance_schema_instrument = '%=on'

#innodb monitor
innodb_monitor_enable="module_innodb"
innodb_monitor_enable="module_server"
innodb_monitor_enable="module_dml"
innodb_monitor_enable="module_ddl"
innodb_monitor_enable="module_trx"
innodb_monitor_enable="module_os"
innodb_monitor_enable="module_purge"
innodb_monitor_enable="module_log"
innodb_monitor_enable="module_lock"
innodb_monitor_enable="module_buffer"
innodb_monitor_enable="module_index"
innodb_monitor_enable="module_ibuf_system"
innodb_monitor_enable="module_buffer_page"
innodb_monitor_enable="module_adaptive_hash"

[mysqldump]
quick
max_allowed_packet = 32M
END

chown -R mysql:mysql /alidata/mysql/
chown -R mysql:mysql /alidata/mysql/data/
chown -R mysql:mysql /alidata/mysql/log
/alidata/mysql/bin/mysqld --initialize-insecure --datadir=/alidata/mysql/data/  --user=mysql
ln -s /alidata/mysql/bin/mysqld /usr/local/mysql/bin/mysqld
chmod 755 /etc/init.d/mysqld
/etc/init.d/mysqld start

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/mysql/bin" &> /dev/null;then
	echo "export PATH=\$PATH:/alidata/mysql/bin" >> /etc/profile
fi
source /etc/profile
cd $DIR
bash
```

主从半同步配置

> 主库

```shell
#!/bin/bash
# userh和password分别为主从的用户名和密码
DBname=
DBpassword=
ip_master=
ip_slave=
repl_user=
repl_password=
BackupLog=
# 安装半同步插件
echo "install plugin rpl_semi_sync_master soname 'semisync_master.so';install plugin rpl_semi_sync_master soname 'semisync_master.so';" | mysql -u$DBname -p$DBpassword
# 更改配置文件
sed -i '/[mysqld]/arpl_semi_sync_master_enabled=1\nrpl_semi_sync_master_timeout=1000\nrpl_semi_sync_slave_enabled=1\nrelay_log_purge=0\nskip-name-resolve\nread_only=1\nslave-skip-errors=1396' /etc/my.cnf
# 重启服务
/etc/init.d/restart
# 数据库授权
echo "grant replication slave on *.* to $repl_user@$ip_master identified by $repl_password;grant replication slave on *.* to $repl_user@$ip_master identified by $repl_password;grant all privileges on *.* to mha_mon@'%' identified by '123';flush privileges;" | mysql -u$DBname -p$DBpassword
# 主库全备份
a=`mysqldump -uroot -p -A --opt --set-gtid-purged=OFF --default-character-set=utf8 --single-transaction --hex-blob --skip-triggers --master-data=2 --flush-logs --max_allowed_packet=824288000 > /alidata/install/mysqlmasterall.sql;echo $?`
if [ $a -ne 0 ] #-ne不等于
then
 echo "$(date +%y%m%d_%H:%M:%S) 备份失败" >> $BackupLog
else
 echo "$(date +%y%m%d_%H:%M:%S) 备份成功" >> $BackupLog
fi
echo "`sed -n '22p' /alidata/install/mysqlmasterall.sql`" > /alidata/install/masterinfo 
scp /alidata/install/mysqlmasterall.sql $ip_slave:/alidata/install/mysqlmasterall.sql
ln -s /usr/local/mysql/bin/* /usr/bin
```

> 从库

```shell
#!/bin/bash
DBname=
DBpassword=
ip_master=
ip_slave=
slave_name=
slave_password=
BackupLog=
MASTER_LOG_FILE=
MASTER_LOG_POS=
# 安装半同步插件
echo "install plugin rpl_semi_sync_master soname 'semisync_master.so';install plugin rpl_semi_sync_master soname 'semisync_master.so';" | mysql -u$DBname -p$DBpassword
# 更改配置文件
sed -i '/[mysqld]/arpl_semi_sync_master_enabled=1\nrpl_semi_sync_master_timeout=1000\nrpl_semi_sync_slave_enabled=1\nrelay_log_purge=0\nskip-name-resolve\nread_only=1\nslave-skip-errors=1396' /etc/my.cnf
# 重启服务
/etc/init.d/restart
# 清空配置
echo "reset master;" | mysql -u$DBname -p$DBpassword
# 导入数据
mysql -u$DBname -p$DBpassword < /alidata/install/mysqlmasterall.sql
# 声明
echo "change master to master_host=$ip_master,master_user=$user,master_password=$password,MASTER_LOG_FILE='',MASTER_LOG_POS=;" | mysql -u$DBname -p$DBpassword
echo "start slave" | mysql -u$DBname -p$DBpassword
ln -s /usr/local/mysql/bin/* /usr/bin
```

### 安装MHA

#### 安装

> 管理节点manager和node节点都需要安装，数据库节点只需安装node节点即可

两个node节点

```shell
#!/bin/bash
# 首先将node节点下载
rpm --import /etc/pki/rpm-gpg/*
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Config-IniFiles ncftp perl-Params-Validate perl-CPAN perl-Test-Mock-LWP.noarch perl-LWP-Authen-Negotiate.noarch perl-devel
yum install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker
由于perl中可能会出错，所以此操作手动完成
# [root@MANAGER src]# tar -xf mha4mysql-node-0.56.tar.gz
# [root@MANAGER src]# cd mha4mysql-node-0.56
# [root@MANAGER mha4mysql-node-0.56]# perl Makefile.PL
# [root@MANAGER mha4mysql-node-0.56]# make && make install
```

管理节点

```shell
#!/bin/bash
# 首先将manager和node节点下载
rpm --import /etc/pki/rpm-gpg/*
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install perl-DBD-MySQL perl-Config-Tiny perl-Log-Dispatch perl-Parallel-ForkManager perl-Config-IniFiles ncftp perl-Params-Validate perl-CPAN perl-Test-Mock-LWP.noarch perl-LWP-Authen-Negotiate.noarch perl-devel
yum install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker
由于perl中可能会出错，所以此操作手动完成
# [root@MANAGER src]# tar -xf mha4mysql-node-0.56.tar.gz
# [root@MANAGER src]# cd mha4mysql-node-0.56
# [root@MANAGER mha4mysql-node-0.56]# perl Makefile.PL
# [root@MANAGER mha4mysql-node-0.56]# make && make install

# [root@MANAGER src]# tar -xf mha4mysql-manager-0.56.tar.gz
# [root@MANAGER src]# cd mha4mysql-manager-0.56
# [root@MANAGER mha4mysql-manager-0.56]# perl Makefile.PL
# [root@MANAGER mha4mysql-manager-0.56]# make && make install

# 创建目录
mkdir /etc/masterha
mkdir -p /masterha/app1
mkdir -p /scripts
cp /alidata/install/mha4mysql-manager-0.56/samples/conf/* /etc/masterha/
cp /alidata/install/mha4mysql-manager-0.56/samples/scripts/* /scripts
# 更改配置文件
root@iZzm0cl1fi1hbmgaxze2enZ masterha]# cat app1.cnf
[server default]
manager_workdir=/masterha/app1
manager_log=/masterha/app1/manager.log
user=mha_mon
password=123
ssh_user=root
repl_user=slave
repl_password=abc123
ping_interval=1
shutdown_script=""
master_ip_online_change_script=""
report_script=""
 
[server1]
hostname=
master_binlog_dir=/alidata/mysql/log/
candidate_master=1
 
[server2]
hostname=
master_binlog_dir=/alidata/mysql/log/
candidate_master=1
```

### 测试

```shell
# 测试ssh
masterha_check_ssh --global_conf=/etc/masterha/masterha_default.cnf --conf=/etc/masterha/app1.cnf
# 测试mysql
masterha_check_repl --conf=/etc/masterha/app1.cnf

```

启动

```shell
# 测试ssh
masterha_check_ssh --global_conf=/etc/masterha/masterha_default.cnf --conf=/etc/masterha/app1.cnf
# 测试mysql
masterha_check_repl --conf=/etc/masterha/app1.cnf
# 启动
nohup masterha_manager --conf=/etc/masterha/app1.cnf > /tmp/mha_manager.log &1 &
# 查看启动状态
masterha_check_status --conf=/etc/masterha/app1.cnf
# 停止
masterha_stop --conf=/etc/masterha/app1.cnf
```

keepalived配置

```shell
主：
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 10.200.63.169
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 50
    nopreempt
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.200.63.1 dev eth0 label eth0:havip
    }
#    notify_master /etc/keepalived/scripts/ha_vip_start.sh
#    notify_backup /etc/keepalived/scripts/ha_vip_stop.sh
#    notify_fault /etc/keepalived/scripts/ha_vip_stop.sh
#    notify_stop /etc/keepalived/scripts/ha_vip_stop.sh
    unicast_src_ip 10.200.63.167
    unicast_peer {
            10.200.63.169
                 }
}
```

```shell
备：
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 10.200.63.169
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    nopreempt
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.200.63.1 dev eth0 label eth0:havip
    }
#    notify_master /etc/keepalived/scripts/ha_vip_start.sh
#    notify_backup /etc/keepalived/scripts/ha_vip_stop.sh
#    notify_fault /etc/keepalived/scripts/ha_vip_stop.sh
#    notify_stop /etc/keepalived/scripts/ha_vip_stop.sh
    unicast_src_ip 10.200.63.169
    unicast_peer {
            10.200.63.167
                 }
}
```

```shell
如果主库挂掉以后，vip到备库上，主库修复后不希望再抢夺vip，则可以做一下设置:

1、将主库的state 也设置为BACKUP，同时设置nopreempt ，不抢夺vip

2、修改M，B服务器的  state BACKUP 都为【备】类型，同时设置 nopreempt  设置为不抢夺VIP，然后先启动M服务器，M服务器会成为【主】，

3、然后启动B服务器，由于M的优先级高【priority 100】 所以B不会抢夺VIP，这时M宕机，B成为【主】，接着M恢复正常，由于设置了nopreempt 所以M不会抢夺VIP，B继续为【主】而M为【备】。

```

**master_ip_failover**

```
master_ip_failover_script= 
```

```shell
# 更改后的，控制keepqlived的VIP转移

#!/usr/bin/env perl

#  Copyright (C) 2011 DeNA Co.,Ltd.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#  Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## Note: This is a sample script and is not complete. Modify the script based on your environment.

use strict;
use warnings FATAL => 'all';

use Getopt::Long;
use MHA::DBHelper;

my (
  $command,        $ssh_user,         $orig_master_host,
  $orig_master_ip, $orig_master_port, $new_master_host,
  $new_master_ip,  $new_master_port,  $new_master_user,
  $new_master_password
);
my $vip = '10.200.63.1';
my $ssh_start_vip = "systemctl start keepalived";
my $ssh_stop_vip = "systemctl stop keepalived";

GetOptions(
  'command=s'             => \$command,
  'ssh_user=s'            => \$ssh_user,
  'orig_master_host=s'    => \$orig_master_host,
  'orig_master_ip=s'      => \$orig_master_ip,
  'orig_master_port=i'    => \$orig_master_port,
  'new_master_host=s'     => \$new_master_host,
  'new_master_ip=s'       => \$new_master_ip,
  'new_master_port=i'     => \$new_master_port,
  'new_master_user=s'     => \$new_master_user,
  'new_master_password=s' => \$new_master_password,
);

exit &main();

sub main {
  print "\n\nIN SCRIPT TEST====$ssh_stop_vip==$ssh_start_vip===\n\n";
  if ( $command eq "stop" || $command eq "stopssh" ) {

    # $orig_master_host, $orig_master_ip, $orig_master_port are passed.
    # If you manage master ip address at global catalog database,
    # invalidate orig_master_ip here.
    my $exit_code = 1;
    eval {
      print "Disabling the VIP on old master: $orig_master_host \n";
      &stop_vip();
      # updating global catalog, etc
      $exit_code = 0;
    };
    if ($@) {
      warn "Got Error: $@\n";
      exit $exit_code;
    }
    exit $exit_code;
  }
  elsif ( $command eq "start" ) {

    # all arguments are passed.
    # If you manage master ip address at global catalog database,
    # activate new_master_ip here.
    # You can also grant write access (create user, set read_only=0, etc) here.
    my $exit_code = 10;
    eval {
      print "Disabling the VIP on old master: $orig_master_host \n";
      &stop_vip();
      $exit_code = 0;
    };
    if ($@) {
      warn $@;

      # If you want to continue failover, exit 10.
      exit $exit_code;
    }
    exit $exit_code;
  }
  elsif ( $command eq "status" ) {
    print "Checking the Status of the script.. OK \n";
    # do nothing
    exit 0;
  }
  else {
    &usage();
    exit 1;
  }
}
sub start_vip() {
    `ssh $ssh_user\@$new_master_host \" $ssh_start_vip \"`;
}
#A simple system call that disable the VIP on the old_master
sub stop_vip() {
    `ssh $ssh_user\@$orig_master_host \" $ssh_stop_vip \"`;
}
sub usage {
  print
"Usage: master_ip_failover --command=start|stop|stopssh|status --orig_master_host=host --orig_master_ip=ip --orig_master_port=port --new_master_host=host --new_master_ip=ip --new_master_port=port\n";
}
```

### report_script参数

/ samples / scripts / send_report

```shell
#!/usr/bin/perl

#  Copyright (C) 2011 DeNA Co.,Ltd.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#  Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## Note: This is a sample script and is not complete. Modify the script based on your environment.

use strict;
use warnings FATAL => 'all';

use Getopt::Long;

#new_master_host and new_slave_hosts are set only when recovering master succeeded
my ( $dead_master_host, $new_master_host, $new_slave_hosts, $subject, $body );
GetOptions(
  'orig_master_host=s' => \$dead_master_host,
  'new_master_host=s'  => \$new_master_host,
  'new_slave_hosts=s'  => \$new_slave_hosts,
  'subject=s'          => \$subject,
  'body=s'             => \$body,
);

# Do whatever you want here

exit 0;
```







