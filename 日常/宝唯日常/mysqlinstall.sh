#!/bin/bash
yum -y install libaio
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
Port=3315
IP=10.65.6.202
#安装目录
#/apps/svr/mysql$Port
#数据目录
#/data/mysql$Port/
mkdir -p /Data/dbdata/mysql$Port
mkdir -p /Data/dbdata/mysql$Port/data
mkdir -p /Data/dbdata/mysql$Port/log
mkdir -p /Data/dbdata/mysql$Port/tmp
mkdir -p /Data/dbdata/mysql$Port/slave/tmp
#mkdir -p /apps/svr/
#mkdir -p /apps/sh
mkdir -p /apps/conf/mysql$Port
#mkdir -p /usr/local/mysql/bin

#cd /apps/svr/
#if [ `uname -m` == "x86_64" ];then   #查看是系统否是64位的，如果是就下载64位的包
#  if [ ! -d mysql-5.7.23-linux-glibc2.12-x86_64 ];then
#	 wget https://downloads.mysql.com/archives/get/file/mysql-5.7.23-linux-glibc2.12-x86_64.tar.gz
#         tar -xzvf mysql-5.7.23-linux-glibc2.12-x86_64.tar.gz
#	     ln -s mysql-5.7.23-linux-glibc2.12-x86_64 /apps/svr/mysql$Port
#  else
#         cp -rp mysql-5.7.23-linux-glibc2.12-x86_64 /apps/svr/mysql$Port 
#  fi
  
#else
#  rm -rf mysql-5.7.17-linux-glibc2.5-i686
#  if [ ! -f mysql-5.7.17-linux-glibc2.5-i686.tar.gz ];then
#  wget http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.17-linux-glibc2.5-i686.tar.gz
#  fi
#  tar -xzvf mysql-5.7.17-linux-glibc2.5-i686.tar.gz
#  mv mysql-5.7.17-linux-glibc2.5-i686/* /alidata/mysql

#fi

#install mysql
#groupadd apps
#useradd -g apps -s /sbin/nologin apps


cat > /apps/conf/mysql$Port/my.cnf <<END
[client]
default-character-set=utf8
character_set_client=utf8
character_set_connection=utf8 
character_set_results=utf8
 
[mysqld]
 
 
#**********************Server**************************
#******server start related
user=apps 
bind-address=$IP
port=$Port 
#port-open-timeout= 
server-id=$DATE
#chroot 
#init-file=file_name 
#core-file=OFF 
#skip-grant-tables 
optimizer_switch='index_merge=off,mrr=off,use_index_extensions=off'
 
#******location
basedir=/apps/svr/mysql$Port
pid-file=/Data/dbdata/mysql$Port/mysql.pid 
socket=/tmp/mysql$Port.sock 
datadir=/Data/dbdata/mysql$Port/data
tmpdir=/Data/dbdata/mysql$Port/tmp
 
 
#******security
#secure-auth 
safe-user-create 
#skip-show-database 
max_user_connections=2980 
max_connect_errors=100000 
secure-file-priv= 
#max_prepared_stmt_count= 
#skip-ssl 
#ssl-ca=file_name 
#ssl-capath=directory_name 
#ssl-cert=file_name 
#ssl-cipher=cipher_list 
#ssl-key=file_name 
ssl=0
default_password_lifetime=0
 
 
#******features
default-storage-engine=InnoDB 
#ansi 
sql-mode= 
#auto_increment_increment=1 
#auto_increment_offset=1 
#div_precision_increment=4 
event-scheduler=on 
#skip-event-scheduler 
#flush 
#flush_time= 
#old 
#old-alter-table 
#old-style-user-limits 
partition 
#skip-partition 
#plugin_dir= 
#plugin-load=plugin_list 
#symbolic-links 
#skip-symbolic-links 
lock_wait_timeout=600 
#sync_frm 
#temp-pool 
#updatable_views_with_limit 
 
 
#******function
#allow-suspicious-udfs 
#des-key-file=file_name 
group_concat_max_len=10240 
#max_long_data_size= 
sysdate-is-now 
#default_week_format= 
 
 
#******character set&time zone etc..
character-set-server=utf8 
#collation-server=utf8_general_ci 
collation-server=utf8_bin 
#character-set-client-handshake 
#skip-character-set-client-handshake 
character-set-filesystem=utf8 
#character-sets-dir= 
#lower_case_file_system 
lower_case_table_names=1 
#lc-messages= 
#lc-messages-dir= 
default-time-zone="+8:00" 
log_timestamps=1
#avoid_temporal_upgrade=true
explicit_defaults_for_timestamp=true 
 
#******buffer&cache
#memlock 
#large-pages 
join_buffer_size=128K 
sort_buffer_size=2m 
table_open_cache=20000 
table_open_cache_instances=16
table_definition_cache=10000 
#range_alloc_block_size= 
#query_prealloc_size= 
#query_alloc_block_size= 
#stored_program_cache= 
 
 
#*****query cache
query_cache_type=0 
query_cache_size=0 
#query_cache_min_res_unit= 
query_cache_limit=0 
#query_cache_wlock_invalidate 
 
 
#******thread&connection
thread_handling=one-thread-per-connection 
#slow_launch_time= 
#init_connect= 
back_log=1500 
thread_cache_size=512 
max_connections=3000 
 
 
#******temptable
#big-tables 
tmp_table_size=64m 
max_heap_table_size=64m 
internal_tmp_disk_storage_engine=InnoDB
 
 
#******network
#skip-networking 
skip-name-resolve 
#skip-host-cache 
net_buffer_length=8k 
max_allowed_packet=1g
connect_timeout=10 
wait_timeout=120 
interactive_timeout=120 
net_read_timeout=3 #set to 10 if across IDC
net_write_timeout=6 #set to 10 if across IDC
net_retry_count=2 #set to 5 if across IDC
 
 
#*****profile&optimizer
#profiling 
profiling_history_size=5 
#optimizer_prune_level= 
#optimizer_search_depth= 
#optimizer_switch= 
#max_seeks_for_key=1000 
max_length_for_sort_data=4096 
 
 
#******limitation
#max_error_count= 
#max_join_size= 
#max_sort_length= 
#max_sp_recursion_depth= 
#open-files-limit=8192 
#thread_stack=512k 
 
 
#**********************Logs****************************
log-output=FILE 
 
 
#*****error log
log-error=/Data/dbdata/mysql$Port/log/error$Port.log 
log-warnings 
#skip-log-warnings 
 
 
#*****slow log
slow-query-log 
slow_query_log_file=/Data/dbdata/mysql$Port/log/slow$Port.log 
long_query_time=0.300 
#log-queries-not-using-indexes 
log-slow-admin-statements 
log-slow-slave-statements 
min-examined-row-limit=10 
 
 
#*****general log
#general-log 
#general_log_file=/apps/logs/mysql/query.log 
 
 
#**********************Replication*********************
#skip-slave-start 
read_only=0
#init_slave= 
#master-info-file=master.info 
master_info_repository=table
#sync_master_info=1000 
#slave_type_conversions= 
#slave_transaction_retries= 
#slave_exec_mode= 
#slave-skip-errors=1062 1064 1146 #only for 216
slave-load-tmpdir=/Data/dbdata/mysql$Port/slave/tmp
slave_preserve_commit_order=1
slave_parallel_workers=0
slave_parallel_type=LOGICAL_CLOCK
gtid-mode=on
enforce-gtid-consistency=on
slave_pending_jobs_size_max=2g
 
 
#******network
#slave_compressed_protocol #for RBR
slave-max-allowed-packet=1g 
slave-net-timeout=30 
#master-retry-count= 
 
 
#******report
#show-slave-auth-info 
#report-host= 
#report-password= 
#report-port= 
#report-user= 
 
 
#*****binlog
log-bin=/Data/dbdata/mysql$Port/log/mysql-bin
log-bin-index=/Data/dbdata/mysql$Port/log/mysql-bin.index 
sync_binlog=1         #close for sas
binlog-format=row
max_binlog_size=512m 
expire_logs_days=7
binlog_cache_size=256K 
max_binlog_cache_size=4g #increase this for RBR
binlog_stmt_cache_size=32k 
max_binlog_stmt_cache_size=256m 
binlog-row-event-max-size=256m 
#log-short-format 
log_slave_updates 
log-bin-trust-function-creators 
#binlog_direct_non_transactional_updates 
binlog_rows_query_log_events=true
 
 
#*****relaylog
relay-log=relay-bin 
relay-log-index=/Data/dbdata/mysql$Port/log/relay-bin.index 
relay-log-info-file=/Data/dbdata/mysql$Port/log/relay-log.info 
sync_relay_log=10000 
#sync_relay_log_info=1000 
#max_relay_log_size= 
relay_log_space_limit=100G 
relay_log_purge=false
relay_log_info_repository=table
relay_log_recovery=true 
 
#******filter
#binlog-do-db= 
#binlog-ignore-db= 
#replicate-do-db= 
#replicate-ignore-db= 
#replicate-do-table= 
#replicate-ignore-table= 
#replicate-wild-do-table= 
#replicate-wild-ignore-table= 
#replicate-same-server-id 
#replicate-rewrite-db= 
binlog-ignore-db=mysql
binlog-ignore-db=sys
binlog-ignore-db=information_schema
binlog-ignore-db=performance_schema


 
#**********************InnoDB**************************
innodb_data_home_dir=/Data/dbdata/mysql$Port/data
innodb_data_file_path=ibdata1:64M:autoextend 
innodb_log_group_home_dir=/Data/dbdata/mysql$Port/data
innodb_log_files_in_group=2 
#innodb_log_file_size=64M 
innodb_log_file_size=2G
innodb_temp_data_file_path=ibtmp1:64M:autoextend

innodb_buffer_pool_load_at_startup=0
 
#*****feature
innodb_open_files=4096 
innodb_change_buffering=all 
innodb_adaptive_hash_index=ON 
innodb_autoinc_lock_mode=2
#innodb_large_prefix 
#innodb_strict_mode 
#innodb_use_sys_malloc= 
 
 
#******buffer&cache
innodb_buffer_pool_size=64M 
innodb_buffer_pool_instances=1 
innodb_max_dirty_pages_pct=50 
innodb_old_blocks_pct=25 
innodb_old_blocks_time=3000 
#innodb_additional_mem_pool_size=32m 
innodb_log_buffer_size=64m 
innodb_buffer_pool_chunk_size=128m
innodb_page_cleaners=8
 
 
#******IO
innodb_flush_method=O_DIRECT 
innodb_use_native_aio 
innodb_adaptive_flushing 
innodb_flush_log_at_trx_commit=1
innodb_io_capacity=20000
innodb_read_io_threads=8 
innodb_write_io_threads=8 
innodb_read_ahead_threshold=56 
innodb_doublewrite 
innodb_purge_threads=1 
innodb_purge_batch_size=20 
#innodb_max_purge_lag= 
innodb_stats_persistent = 1
innodb_flush_neighbors=0
 
 
#*****fileformat
innodb_file_per_table 
innodb_autoextend_increment=32 
innodb_file_format=Barracuda 
#innodb_file_format_check= 
#innodb_file_format_max= 
 
 
#******static&status
#innodb_stats_on_metadata 
innodb_stats_sample_pages=32 
innodb_stats_method=nulls_unequal 
#timed_mutexes 
#innodb-status-file 
 
 
#******recovery&related
innodb_fast_shutdown=1 
#innodb_force_load_corrupted 
#innodb_force_recovery= 
#innodb_checksums 
innodb_checksum_algorithm=crc32
 
 
#******transaction,lock,concurrency,rollback
autocommit=1 
#transaction-isolation=REPEATABLE-READ 
transaction-isolation=READ-COMMITTED
#transaction_prealloc_size=64k 
#transaction_alloc_block_size=64k 
completion_type=NO_CHAIN 
innodb_support_xa 
 
 
innodb_table_locks 
innodb_lock_wait_timeout=30 
#innodb_locks_unsafe_for_binlog 
innodb_spin_wait_delay=6
innodb_sync_spin_loops=30
 
 
innodb_commit_concurrency=0 
innodb_thread_concurrency=0      #at least equal cpu nums 
#innodb_concurrency_tickets=500 
#innodb_replication_delay=0 
#innodb_thread_sleep_delay= 
 
 
#innodb_rollback_on_timeout 
#innodb_rollback_segments=128 
 
 
#**********************MyISAM**************************
#******feature
#myisam_data_pointer_size= 
#myisam_use_mmap 
#keep_files_on_create 
myisam-block-size=4096 
delay-key-write=on 
#preload_buffer_size 
myisam_stats_method=nulls_unequal 
#myisam-recover-options=OFF 
myisam_repair_threads=1 
 
 
#******buffer&cache
key_buffer_size=64M 
key_cache_block_size=4096 
key_cache_age_threshold=300 
key_cache_division_limit=20 
read_buffer_size=1m 
read_rnd_buffer_size=2m 
myisam_sort_buffer_size=32m 
 
 
#*******delayed insert
#delayed_queue_size= 
#max_delayed_threads= 
#delayed_insert_limit= 
#delayed_insert_timeout= 
 
 
#******fulltext
#ft_boolean_syntax= 
#ft_max_word_len= 
#ft_min_word_len= 
#ft_query_expansion_limit= 
#ft_stopword_file=file_name 
 
 
#******limitation
bulk_insert_buffer_size=8m 
myisam_max_sort_file_size=10G 
#myisam_mmap_size= 
 
 
#******lock&concurrency
#external-locking 
skip-external-locking 
 
 
concurrent_insert=AUTO 
#skip-concurrent-insert 
max_write_lock_count=10000 
#low-priority-updates 
 
 
#********************performance_schema****************
performance_schema=1
#performance_schema_events_waits_history_long_size= 
#performance_schema_events_waits_history_size= 
#performance_schema_max_cond_classes= 
#performance_schema_max_cond_instances= 
#performance_schema_max_file_classes= 
#performance_schema_max_file_handles= 
#performance_schema_max_file_instances= 
#performance_schema_max_mutex_classes= 
#performance_schema_max_mutex_instances= 
#performance_schema_max_rwlock_classes= 
#performance_schema_max_rwlock_instances= 
#performance_schema_max_table_handles= 
#performance_schema_max_table_instances= 
#performance_schema_max_thread_classes= 
#performance_schema_max_thread_instances= 
 
 
#**************************federated********************
#federated
 
 
[mysqldump]
quick
max_allowed_packet = 2G
log-error=/Data/dbdata/mysql$Port/log/dump.log
net_buffer_length=8k 
 
 
[mysql]
no-auto-rehash
no-beep
default-character-set = utf8
socket=/tmp/mysql-$Port.sock
#prompt="\\U : \\d \\R:\\m:\\s> "
#tee="/apps/logs/mysql/audit.log" 
#pager="less -i -n -S" 
net_buffer_length=64K
unbuffered
 
[mysqladmin]
default-character-set = utf8
socket=/tmp/mysql_$Port.sock
 
[myisamchk]
key_buffer = 512M
sort_buffer_size = 512M
read_buffer = 8M
write_buffer = 8M
 
 
[mysqlhotcopy]
interactive-timeout
 
 
[mysqld_safe]
#open-files-limit = 8192
#ledir = /apps/svr/mysql57/bin
END
chown -R apps. /Data/dbdata/mysql$Port/
chown -R apps. /apps/conf/mysql$Port
/apps/svr/mysql$Port/bin/mysqld --defaults-file=/apps/conf/mysql$Port/my.cnf --initialize-insecure --datadir=/Data/dbdata/mysql$Port/data/ --basedir=/apps/svr/mysql$Port/ --user=apps
#ln -s /alidata/mysql/bin/mysqld /usr/local/mysql/bin/mysqld
/apps/svr/mysql$Port/bin/mysqld_safe --defaults-file=/apps/conf/mysql$Port/my.cnf &

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/apps/svr/mysql$Port/bin" &> /dev/null;then
	echo "export PATH=\$PATH:/apps/svr/mysql$Port/bin" >> /etc/profile
fi
source /etc/profile
