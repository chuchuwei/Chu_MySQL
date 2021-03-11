# MongoDB安装

## 创建yum源

```
vim /etc/yum.repos.d/mongodb-org-3.4.repo


[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7Sever/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc


# yum clean all
# yum makecache
```

## 安装

```shell
yum install -y mongodb-org

rpm -qa |grep mongodb

vi /etc/mongod.conf
把bindIP改成 0.0.0.0所有的机器都可以访问
```

## 下载模板

```shell
下载地址：https://share.zabbix.com/databases/mongodb/mongodb-for-zabbix-3-2
https://github.com/oscm/zabbix/tree/master/mongodb
# 下载
git clone https://github.com/oscm/zabbix.git
# 安装依赖包
yum -y install jq
# cp配置文件到agent的配置文件
cp userparameter_mongodb.conf /etc/zabbix_agentd.conf.d/
# 配置连接信息
vim /srv/zabbix/libexec/mongodb.sh
DB_HOST=127.0.0.1
DB_PORT=27017
DB_USERNAME=admin
DB_PASSWORD=password
# 脚本执行权限
chmod + x /srv/zabbix/libexec/mongodb.sh
```

## 导入模板

```shell
# 导入模板
导入zbx_export_templates.xml文件
# 添加模板
添加Template App MongoDB模板
```

## 测试

```shell
# agent端本地测试key
zabbix_agentd -c 配置文件 -t keyname
如：/apps/svr/zabbix/sbin/zabbix_agentd -c /apps/conf/zabbix_agentd.conf -t Redis.Info[db0,avg_ttl]
# server端测试
zabbix_get -s 10.0.185.35 -p 10050 -k Redis.Info[aof_last_bgrewrite_status]
```

