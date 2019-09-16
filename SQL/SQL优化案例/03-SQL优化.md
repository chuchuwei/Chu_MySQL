语句

```shell
mysql>SELECT `c_id`,
       `c_name`,
       `c_type`,
       `c_money`,
       `c_condition_money`
  FROM `fx_coupon`
 WHERE `c_end_time`>= '2019-08-14 23:59:59'
 GROUP BY c_name;

耗时：1783 ms 

# 执行计划
------------------------+-------------------+---------------+----------------+--------------------+-----------------+
| id           | select_type           | table           | partitions           | type           | possible_keys                                                               | key                     | key_len           | ref           | rows           | filtered           | Extra           |
+--------------+-----------------------+-----------------+----------------------+----------------+-----------------------------------------------------------------------------+-------------------------+-------------------+---------------+----------------+--------------------+-----------------+
| 1            | SIMPLE                | fx_coupon       |                      | index          | index_c_name_c_end_time,index_c_end_time,c_end_time,index_c_end_time_c_name | index_c_name_c_end_time | 156               |               | 920095         |              25.57 | Using where     |
+--------------+-----------------------+-----------------+----------------------+----------------+-----------------------------------------------------------------------------+-------------------------+-------------------+---------------+----------------+--------------------+-----------------+
返回行数：[1]，耗时：7 ms.
```




```shell
 mysql>select t.c_id,a.`c_name`,
a.`c_type`,
a.`c_money`,
a.`c_condition_money`
from (SELECT `c_id`
  FROM `fx_coupon`
 WHERE `c_end_time`>= '2019-08-14 23:59:59' GROUP BY c_name) t join fx_coupon a
 on t.c_id = a.c_id;
耗时：210ms

 
 SELECT `c_id`
  FROM `fx_coupon`
 WHERE `c_end_time`>= '2019-08-14 23:59:59' GROUP BY c_name
 +--------------+-----------------------+-----------------+----------------------+----------------+-----------------------------------------------------------------------------+-------------------------+-------------------+---------------+----------------+--------------------+-----------------------------------------------------------+
| id           | select_type           | table           | partitions           | type           | possible_keys                                                               | key                     | key_len           | ref           | rows           | filtered           | Extra                                                     |
+--------------+-----------------------+-----------------+----------------------+----------------+-----------------------------------------------------------------------------+-------------------------+-------------------+---------------+----------------+--------------------+-----------------------------------------------------------+
| 1            | SIMPLE                | fx_coupon       |                      | range          | index_c_name_c_end_time,index_c_end_time,c_end_time,index_c_end_time_c_name | index_c_end_time_c_name | 4                 |               | 284008         |                100 | Using where; Using index; Using temporary; Using filesort |
+--------------+-----------------------+-----------------+----------------------+----------------+-----------------------------------------------------------------------------+-------------------------+-------------------+---------------+----------------+--------------------+-----------------------------------------------------------+
返回行数：[1]，耗时：7 ms.
 
 
 
 
 
 +--------------+-----------------------+-----------------+----------------------+----------------+-----------------------------------------------------------------------------+-------------------------+-------------------+---------------+----------------+--------------------+-----------------------------------------------------------+
| id           | select_type           | table           | partitions           | type           | possible_keys                                                               | key                     | key_len           | ref           | rows           | filtered           | Extra                                                     |
+--------------+-----------------------+-----------------+----------------------+----------------+-----------------------------------------------------------------------------+-------------------------+-------------------+---------------+----------------+--------------------+-----------------------------------------------------------+
| 1            | PRIMARY               | <derived2>      |                      | ALL            |                                                                             |                         |                   |               | 284008         |                100 |                                                           |
| 1            | PRIMARY               | a               |                      | eq_ref         | PRIMARY                                                                     | PRIMARY                 | 8                 | t.c_id        | 1              |                100 |                                                           |
| 2            | DERIVED               | fx_coupon       |                      | range          | index_c_name_c_end_time,index_c_end_time,c_end_time,index_c_end_time_c_name | index_c_end_time_c_name | 4                 |               | 284008         |                100 | Using where; Using index; Using temporary; Using filesort |
+--------------+-----------------------+-----------------+----------------------+----------------+-----------------------------------------------------------------------------+-------------------------+-------------------+---------------+----------------+--------------------+-----------------------------------------------------------+
返回行数：[3]，耗时：8 ms.
-----------------------------------------------------------------------+
| Table           | Create Table                                                         -------------------------------------------------------------------+
| fx_coupon       | CREATE TABLE `fx_coupon` (
  `c_id` bigint(11) NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `c_name` varchar(50) NOT NULL DEFAULT '' COMMENT '优惠券名称',
  `c_sn` varchar(32) NOT NULL DEFAULT '' COMMENT '优惠券序列号',
  `c_start_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '开始时间',
  `c_end_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '结束时间',
  `c_is_use` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否使用；0未使用，1已使用',
  `c_memo` varchar(255) NOT NULL DEFAULT '' COMMENT '描述',
  `c_money` decimal(20,2) NOT NULL DEFAULT '0.00' COMMENT '金额',
  `c_condition_money` decimal(20,2) NOT NULL DEFAULT '0.00' COMMENT '使用条件(满足订单多少钱使用)',
  `c_user_id` int(11) NOT NULL DEFAULT '0' COMMENT '使用状态：0全局，其他为指定用户id（该谁用）',
  `c_used_id` int(11) NOT NULL DEFAULT '0' COMMENT '使用用户id(被谁用了)',
  `c_order_id` bigint(20) NOT NULL DEFAULT '0' COMMENT '使用订单id',
  `c_create_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '创建时间',
  `c_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT '优惠券类型（0：现金券，1:折扣券）',
  `c_site` tinyint(1) NOT NULL,
  `c_show_detail` tinyint(1) unsigned zerofill NOT NULL DEFAULT '0',
  `c_toname` tinyint(1) DEFAULT '1',
  `rd_id` int(20) DEFAULT NULL,
  PRIMARY KEY (`c_id`),
  UNIQUE KEY `c_sn` (`c_sn`),
  KEY `c_used_id` (`c_used_id`),
  KEY `c_type` (`c_type`),
  KEY `c_order_id` (`c_order_id`),
  KEY `c_start_time` (`c_start_time`),
  KEY `c_user_id` (`c_user_id`),
  KEY `c_is_use` (`c_is_use`),
  KEY `index_c_name_c_end_time` (`c_name`,`c_end_time`),
  KEY `index_c_condition_money` (`c_condition_money`),
  KEY `index_c_end_time` (`c_end_time`),
  KEY `index_c_money` (`c_money`) USING BTREE,
  KEY `c_end_time` (`c_end_time`),
  KEY `index_c_end_time_c_name` (`c_end_time`,`c_name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1231884 DEFAULT CHARSET=utf8 COMMENT='优惠券表' |
+-----------------+----------------------------------------------------------------
```

