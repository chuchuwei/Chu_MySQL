## MySQL 8.0 增强安全性

### 增强密码管理

#### 可插拔认证

当客户端连接到MySQL服务器时，服务器会从系统表中对客户端进行身份验证，并确定哪个身份验证插件适用于客户端

* 如果服务器找不到插件，则会发生错误并拒绝连接尝试
* 否则，服务器调用该插件来验证用户

举例如下：

```shell
1 找不到插件，发生错误报错
[root@localhost mysql]# mysql
ERROR 2059 (HY000): Authentication plugin 'caching_sha2_password' cannot be loaded: /usr/local/mysql/lib/plugin/caching_sha2_password.so: cannot open shared object file: No such file or directory

2 正常
[root@localhost mysql]# /alidata/mysql/bin/mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 8.0.16 MySQL Community Server - GPL
Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.
Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
root@MySQL-01 14:11:  [(none)]>

3 查看插件认证方式
root@MySQL-01 14:11:  [(none)]> select user,host,plugin,authentication_string from mysql.user\G;
*************************** 4. row ***************************
                 user: root
                 host: localhost
               plugin: caching_sha2_password
authentication_string: 
4 rows in set (0.00 sec)
```

原因

* MySQL 8.0的默认认证插件由mysql_native_password变为了caching_sha2_password  

- 情况1 是由于使用的MySQL5.7.17客户端进行连接，默认插件认证方式改变导致报错
- 情况2 是使用MySQL8.0 的客户端进行连接验证

##### caching_sha2_password兼容性问题和解决方案

如果需要使用以前的客户端连接MySQL8.0，恢复8.0之前的兼容性的最简单的方法是恢复以前的默认身份插件（mysql_native_password）。在配置文件中加入以下行

```shell
[mysqld]
default_authentication_plugin=mysql_native_password
```

* 此更改仅能使用于安装或升级到MySQL8.0或更高版本后新创建的账户，对于已升级安装中已存在的账户其身份验证插件方式保持不变
* 可以连接到服务器按如下方式更改账户身份验证插件

```shell
ALTER USER 'root'@'localhost'
  IDENTIFIED WITH mysql_native_password
  BY 'password';
```

* 也可以在初始化目录之前将身份验证插件添加到配置文件中，则初始化过程会在创建root账户后立即与mysql_native_password相关联

以上设置允许8.0之前的客户端连接到8.0服务器,但是不建议这样做，因为它会导致新创建的帐户放弃使用改进的身份验证安全性。建议使用支持caching_sha2_password 插件的客户端连接8.0服务器。

更多身份验证插件以及具体类型的客户端是否支持该插件验证 建议查看MySQL官网

#### 自动开启拒绝远程连接

如果使用 --skip-grant-tables 选项启动服务器，会自动启用--skip-networking 以防止远程连接，因为这是不安全的。即远程用户不管是否使用密码都无法连接此数据库

#### 密码管理

MySQL支持这些密码管理功能：

- 密码过期，要求定期更改密码。
- 密码重用限制，以防止再次选择旧密码。
- 密码验证，要求密码更改还指定要替换的当前密码。
- 双密码，使客户端可以使用主密码或二级密码进行连接。
- 密码强度评估，要求强密码。

##### 密码过期策略

* 可以在全局建立密码过期策略

  default_password_lifetime 系统变量，其默认值为0，表示禁用自动密码到期。如果值为正整数N，则表示允许的密码生存期

  ```shell
  # 密码具有大约六个月生命周期的全局策略
  [mysqld]
  default_password_lifetime=180
  
  # 密码永不过期的全局策略
  default_password_lifetime=0
  ```

* 可以将个人账户设置为遵循全局策略或使用特定的策略覆盖全局策略

  * 创建账户时不指定策略默认遵循全局过期策略
  * 设置特定账户的过期策略会覆盖该账户对应的全局策略

  ```shell
  # 密码每90天更改一次
  CREATE USER 'jeffrey'@'localhost' PASSWORD EXPIRE INTERVAL 90 DAY;
  ALTER USER 'jeffrey'@'localhost' PASSWORD EXPIRE INTERVAL 90 DAY;
  
  # 禁用密码到期
  CREATE USER 'jeffrey'@'localhost' PASSWORD EXPIRE NEVER;
  ALTER USER 'jeffrey'@'localhost' PASSWORD EXPIRE NEVER;
  
  # 遵循全局过期策略
  CREATE USER 'jeffrey'@'localhost' PASSWORD EXPIRE DEFAULT;
  ALTER USER 'jeffrey'@'localhost' PASSWORD EXPIRE DEFAULT;
  
  # 设置账户已过期
  ALTER USER 'jeffrey'@'localhost' PASSWORD EXPIRE;
  ```

* 客户端成功连接后，服务器会确定账户密码是否已经过期

  * 检查密码是否已手动过期

  * 否则，根据自动密码过期策略检查密码年龄是否大于其允许的生存期。如果是，则服务器认为密码已过期。

  * 如果密码已过期（无论是手动还是自动），服务器将断开客户端连接或限制允许的操作

    * 服务器断开客户端连接，通常是在非交互式调用下

      ```shell
      shell> mysql -u myuser -p
      Password: ******
      ERROR 1862 (HY000): Your password has expired. To log in you must
      change it using a client that supports expired passwords.
      ```

    * 将客户端设置为沙箱模式，通常在交互式调用下发生。此模式仅允许客户端重置过期密码所需的操作，密码重置后，服务器恢复会话的正常
    
      * 客户端可以使用 Alter user或重置账户密码 set password for user@'%'='new_password' 来更改密码
    
      * 客户端可以使用set 更该变量的值
    
      * 对于会话中不允许的操作，服务器返回错误
    
        ```shell
        # 更改密码为已过期
        root@MySQL-01 15:32:  [(none)]> alter user ceshi3@'%' paassword expire;
        
        root@MySQL-01 15:31:  [(none)]> select * from mysql.user\G;
        *************************** 1. row ***************************
                            Host: %
                            User: ceshi3
                          plugin: mysql_native_password
           authentication_string: *6E7E074E5A92EC68A5892E2FB8AA2FD74FA2A946
                password_expired: Y
           password_last_changed: 2019-06-05 13:47:34
               password_lifetime: NULL
                  account_locked: N
                Create_role_priv: Y
                  Drop_role_priv: Y
          Password_reuse_history: NULL
             Password_reuse_time: NULL
        Password_require_current: NULL
                 User_attributes: NULL
                 
        # 过期后查询报错         
        ceshi3@MySQL-01 15:39:  [(none)]> select 1；
        ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
        # 更改密码
        ceshi3@MySQL-01 17:39:  [(none)]> alter user ceshi3@'%' identified by '';
        Query OK, 0 rows affected (0.01 sec)
        # 查询正常
        ceshi3@MySQL-01 17:41:  [(none)]> select 1;
        +---+
        | 1 |
        +---+
        | 1 |
        +---+
        1 row in set (0.00 sec)
        
        root@MySQL-01 17:42:  [(none)]> select * from mysql.user\G;
        *************************** 1. row ***************************
                            Host: %
                            User: ceshi3
                          plugin: mysql_native_password
           authentication_string: *DE7692E3A5DDBCB6576D59FF8925FBB1EE4F44D1
                password_expired: N
           password_last_changed: 2019-06-05 17:41:25
               password_lifetime: NULL
                  account_locked: N
                Create_role_priv: Y
                  Drop_role_priv: Y
          Password_reuse_history: NULL
             Password_reuse_time: NULL
        Password_require_current: NULL
                 User_attributes: NULL
        ```
    
        

##### 密码重用限制

MySQL允许对重用以前的密码进行设置，可以根据密码更改次数或者已用时间进行限制

可以将个人账户设置为遵循全局策略或设定特定的账户策略以覆盖全局策略

- 如果根据密码更改次数限制帐户，则无法从指定数量的最新密码中选择新密码。例如，如果密码更改的最小数量设置为3，则新密码不能与任何最近的3个密码相同。
- 如果根据已用时间限制帐户，则无法从历史记录中比指定天数更近的密码中选择新密码。例如，如果密码重用间隔设置为60，则新密码不得使用先前在过去60天内选择的密码。

###### 密码重用限制策略

* 全局策略,可以使用password_history（更改次数限制）和password_reuse_interval （已用时间限制）系统变量

```shell
# 禁止重复使用30天以外的最后3个密码
[mysqld]
password_history=3
password_reuse_interval=30
```

* 个人账户策略，个人账户策略会覆盖该账户对应的全局策略

```shell
# 在允许重用之前，至少需要更改5个密码：
CREATE USER 'jeffrey'@'localhost' PASSWORD HISTORY 5;
ALTER USER 'jeffrey'@'localhost' PASSWORD HISTORY 5;

# 在允许重用之前至少需要365天
CREATE USER 'jeffrey'@'localhost' PASSWORD REUSE INTERVAL 30 DAY;
ALTER USER 'jeffrey'@'localhost' PASSWORD REUSE INTERVAL 30 DAY;

# 结合两种限制一起
CREATE USER 'jeffrey'@'localhost'
  PASSWORD HISTORY 5
  PASSWORD REUSE INTERVAL 30 DAY;
ALTER USER 'jeffrey'@'localhost'
  PASSWORD HISTORY 5
  PASSWORD REUSE INTERVAL 365 DAY;

# 结合两种限制
CREATE USER 'jeffrey'@'localhost'
  PASSWORD HISTORY DEFAULT
  PASSWORD REUSE INTERVAL DEFAULT;
ALTER USER 'jeffrey'@'localhost'
  PASSWORD HISTORY DEFAULT
  PASSWORD REUSE INTERVAL DEFAULT;  
```

##### 密码验证

##### 双密码

  





















