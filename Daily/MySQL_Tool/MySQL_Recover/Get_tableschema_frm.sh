#!/bin/bash
# DBdir为定义一个目录存放获取到的表结构文件
basedir=
datadir=
DBdir=
frmdir=
# 将数据目录重命名
mv $datadir $datadir.bac
# 创建新的数据目录
mkdir $datadir
# 授权目录
chown mysql. -R $datadir
# 重新初始化
$basedir/bin/mysqld --initialize-insecure --datadir=$datadir --basedir=basedir --user=mysql

DBName=(`ls $datadir.bac | grep -v 'ib*\|innodb*\|mysql*\|sys\|performance_schema\|auto.cnf'`)
# DBName=(test1 test2) 
for i in ${DBName[@]}
do
	mkdir $DBdir/$i
	ls -l $datadir.bac/$i/*.frm | awk '{print $9}' > $DBdir/$i/$i.table
	cd $frmdir
	for line in `cat $DBdir/$i/$i.table`
	do
		a=`mysqlfrm --basedir=$basedir $line --port=3434 --user=mysql --diagnostic >> $DBdir/$i/$i.frm 2> /dev/null;echo $?`
		if [ $a -ne 0 ] #-ne不等于
		then
 			echo "$(date +%y%m%d_%H:%M:%S) 解析失败" >> $DBdir/$i/$i.log
		else
 			echo "$(date +%y%m%d_%H:%M:%S) 解析成功" >> $DBdir/$i/$i.log
			grep -v '^#\|^$' $DBdir/$i/$i.frm > $DBdir/$i/$i.sql
		fi
	done
done