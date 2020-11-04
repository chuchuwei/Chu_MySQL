#!/bin/bash

DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`
#perl-Data-Dumper.x86_64 0:2.145-3.el7 即'perl(Data::Dumper)‘
yum install -y 'perl(Data::Dumper)' #有的环境没有这个包初始化数据库时会报错
\mv /alidata/mysql /alidata/mysql.bak.$DATE &> /dev/null
mkdir -p /alidata/mysql
mkdir -p /alidata/mysql/log
mkdir -p /alidata/install
cd /alidata/install
if [ `uname -m` == "x86_64" ];then
  rm -rf mysql-5.6.15-linux-glibc2.5-x86_64
  if [ ! -f mysql-5.6.15-linux-glibc2.5-x86_64.tar.gz ];then
	 wget http://oss.aliyuncs.com/aliyunecs/onekey/mysql/mysql-5.6.15-linux-glibc2.5-x86_64.tar.gz
  fi
  tar -xzvf mysql-5.6.15-linux-glibc2.5-x86_64.tar.gz
  mv mysql-5.6.15-linux-glibc2.5-x86_64/* /alidata/mysql
else
  rm -rf mysql-5.6.15-linux-glibc2.5-i686
  if [ ! -f mysql-5.6.15-linux-glibc2.5-i686.tar.gz ];then
  wget http://oss.aliyuncs.com/aliyunecs/onekey/mysql/mysql-5.6.15-linux-glibc2.5-i686.tar.gz
  fi
  tar -xzvf mysql-5.6.15-linux-glibc2.5-i686.tar.gz
  mv mysql-5.6.15-linux-glibc2.5-i686/* /alidata/mysql

fi

#install mysql
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql
\cp -f /alidata/mysql/support-files/mysql.server /etc/init.d/mysqld
sed -i 's/^basedir=$/basedir=/alidata/mysql/' /etc/init.d/mysqld
sed -i 's/^datadir=$/datadir=/alidata/mysql/data/' /etc/init.d/mysqld
cat > /etc/my.cnf <<END
[client]
port = 3306
socket = /alidata/mysql/mysql.sock
[mysqld]
port = 3306
socket = /alidata/mysql/mysql.sock
basedir=/alidata/mysql/
datadir=/alidata/mysql/data/
pid-file = /alidata/mysql/mysql-01.pid
log-bin=/alidata/mysql/log/mysql-bin.log
server_id = 2
#mysql5.6中下三个参数要同时添加，不然启动会报错
gtid_mode=on
log-slave-updates=ON
enforce_gtid_consistency=true
binlog_format=row
skip-external-locking
log_error=/alidata/mysql/log/error.log
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M
[mysqlhotcopy]
interactive-timeout
END
chown -R mysql. /alidata/mysql/
/alidata/mysql/scripts/mysql_install_db --datadir=/alidata/mysql/data/ --basedir=/alidata/mysql --user=mysql
chmod 755 /etc/init.d/mysqld
/etc/init.d/mysqld start

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/mysql/bin" &> /dev/null;then
	echo "export PATH=\$PATH:/alidata/mysql/bin" >> /etc/profile
fi
source /etc/profile