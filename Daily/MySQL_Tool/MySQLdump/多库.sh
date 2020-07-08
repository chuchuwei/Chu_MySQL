#!/bin/bash
# 备份多库
DBUser=root
DBPwd=admin123
DBName=(shop list) #定义一个数组
BackupPath="/alidata/rdsbackup"
# Backup Dest directory, change this if you have someother location
if !(test -d $BackupPath)
then
        mkdir $BackupPath -p
fi
cd $BackupPath
for i in ${DBName[@]}
do
        BackupFile="$i-"$(date +%y%m%d_%H)".sql"
        BackupLog="$i-"$(date +%y%m%d_%H)".log"
        a=`mysqldump -u$DBUser -p$DBPwd $i --opt --set-gtid-purged=OFF --default-character-set=utf8 --single-transaction --hex-blob --skip-triggers --max_allowed_packet=824288000 > "$BackupPath"/"$BackupFile" 2> /dev/null; echo $?`
        if [ $a -ne 0 ] #-ne不等于
        then
                echo "$(date +%y%m%d_%H:%M:%S) 备份失败" >> $BackupLog
        else
                echo "$(date +%y%m%d_%H:%M:%S) 备份成功" >> $BackupLog
        fi
done
#Delete sql type file & log file
find "$BackupPath" -name "$DBname*[log,sql]" -type f -mtime +3 -exec rm -rf {} \;