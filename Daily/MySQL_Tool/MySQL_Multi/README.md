```shell
1 创建关闭账号密码，用于mysqld_multi 管理
进入数据库
CREATE USER 'hjx'@'localhost' IDENTIFIED BY '123456';
GRANT SHUTDOWN ON *.* TO 'hjx'@'localhost';
flush privileges;
2 更改mysqld_multi的默认脚本
[root@hjx02 data2]# my_print_defaults -s mmysqld_multi mysqld4;
--socket=/tmp/mysql.sock4
--port=3309
--pid-file=/alidata/mysql/data4/hjx03.pid4
--datadir=/alidata/mysql/data4

vim /alidata/mysql/bin/mysqld_multi
将my $com= join ' ', 'my_print_defaults', @defaults_options, $group;替换成
my $com= join ' ', 'my_print_defaults -s', @defaults_options, $group;
不替换成-s，关闭mysql会报错
```

