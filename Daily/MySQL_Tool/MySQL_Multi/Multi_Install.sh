#!/bin/bash
DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /alidata/mysql /alidata/mysql.bak.$DATE &> /dev/null
mkdir -p /alidata/mysql
mkdir -p /alidata/mysql/data
mkdir -p /alidata/install
mkdir -p /usr/local/mysql/bin
mkdir -p /data/data3307

cd /alidata/install
if [ `uname -m` == "x86_64" ];then   #查看是系统否是64位的，如果是就下载64位的包
  rm -rf mysql-5.7.17-linux-glibc2.5-x86_64
  if [ ! -f mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz ];then
	 wget http://zy-res.oss-cn-hangzhou.aliyuncs.com/mysql/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
  fi
  tar -xzvf mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
  mv mysql-5.7.17-linux-glibc2.5-x86_64/* /alidata/mysql
#else
#  rm -rf mysql-5.7.17-linux-glibc2.5-i686
#  if [ ! -f mysql-5.7.17-linux-glibc2.5-i686.tar.gz ];then
#  wget http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.17-linux-glibc2.5-i686.tar.gz
#  fi
#  tar -xzvf mysql-5.7.17-linux-glibc2.5-i686.tar.gz
#  mv mysql-5.7.17-linux-glibc2.5-i686/* /alidata/mysql

fi

#install mysql
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql

\cp -f /alidata/mysql/support-files/mysqld_multi.server /etc/init.d/mysqld_multi.server
sed -i 's/^basedir=\/usr\/local\/mysql$/basedir=\/alidata\/mysql/' /etc/init.d/mysqld_multi.server
sed -i 's/^bindir=\/usr\/local\/mysql\/bin$/bindir=\/alidata\/mysql\/bin/' /etc/init.d/mysqld_multi.server
cat > /etc/my.cnf <<END
[mysqld_multi]
mysqld     = /alidata/mysql/bin/mysqld_safe
mysqladmin = /alidata/mysql/bin/mysqladmin
user       = admin
password   = 123456

[mysqld1]
socket     = /tmp/mysql.sock
port       = 3306
pid-file   = /alidata/mysql/hjx01.pid1
#basedir = /alidata/mysql
datadir    = /alidata/mysql/data
log_error = /alidata/mysql/hjx01.error
innodb_buffer_pool_size=8M

[mysqld2]
socket     = /tmp/mysql.sock3307
port       = 3307
pid-file   = /data/data3307/hjx02.pid2
#basedir = /alidata/mysql
datadir    = /data/data3307
log_error = /data/data3307/hjx02.error
innodb_buffer_pool_size=8M

END
chown -R mysql. /alidata/mysql/
chown -R mysql. /data/data3307
/alidata/mysql/bin/mysqld --initialize-insecure --datadir=/alidata/mysql/data/ --basedir=/alidata/mysql/ --user=mysql
/alidata/mysql/bin/mysqld --initialize-insecure --datadir=/data/data3307/ --basedir=/alidata/mysql/ --user=mysql
chmod 755 /etc/init.d/mysqld_multi.server
ln -s /alidata/mysql/bin/mysqld_multi /usr/local/mysql/bin/mysqld_multi
ln -s /alidata/mysql/bin/mysqld /usr/local/mysql/bin/mysqld

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/alidata/mysql/bin" &> /dev/null;then
	echo "export PATH=\$PATH:/alidata/mysql/bin" >> /etc/profile
fi
source /etc/profile

/alidata/mysql/support-files/mysqld_multi --defaults-extra-file=/etc/my.cnf start 1,2  
#需要进入support-files目录下执行mysqld_multi --defaults-extra-file=/etc/my.cnf start 1,2
#/alidata/mysql/bin/mysqld_multi --defaults-extra-file=/etc/my.cnf start 1,2 #也可以启动