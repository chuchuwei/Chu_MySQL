### limit (oreder by 后分页)


```shell
SELECT t.charge_no AS charge_no,
       t.out_biz_no AS out_biz_no,
       t.gid AS gid,
       t.partner_id AS partner_id,
       t.trade_amount AS trade_amount,
       t.trade_type AS trade_type,
       t.merch_order_no AS merch_order_no,
       t.trade_date AS trade_time,
       t.over_status AS over_status,
       t.event_code AS event_code,
       m.trans_no AS trans_no,
       m.payee_role AS payee_role,
       m.payee_account_no AS payee_account_no,
       m.payer_role AS payer_role,
       m.payer_account_no AS payer_account_no,
       m.charge_amount AS charge_amount,
       m.charge_status AS charge_status,
       m.cal_type AS cal_type,
       m.create_time AS create_time,
       m.update_time AS update_time
  FROM v3_charge_trans_log m
  LEFT JOIN v3_charge_log t ON t.charge_no= m.charge_no
 ORDER BY trade_time DESC
 LIMIT 1000,
       1000
       
# 此语句order by后limit分页，需要一行行定位到第1000行后，再找后续的1000行，无法使用索引，会导致效率变慢


改写
# 缩小分页的范围，提高查询效率
SELECT t.charge_no AS charge_no,
       t.out_biz_no AS out_biz_no,
       t.gid AS gid,
       t.partner_id AS partner_id,
       t.trade_amount AS trade_amount,
       t.trade_type AS trade_type,
       t.merch_order_no AS merch_order_no,
       t.trade_date AS trade_time,
       t.over_status AS over_status,
       t.event_code AS event_code,
       m.trans_no AS trans_no,
       m.payee_role AS payee_role,
       m.payee_account_no AS payee_account_no,
       m.payer_role AS payer_role,
       m.payer_account_no AS payer_account_no,
       m.charge_amount AS charge_amount,
       m.charge_status AS charge_status,
       m.cal_type AS cal_type,
       m.create_time AS create_time,
       m.update_time AS update_time
  FROM v3_charge_trans_log m
  LEFT JOIN v3_charge_log t ON t.charge_no= m.charge_no
 where trade_date<=(
select trade_date
  from v3_charge_log
 ORDER BY trade_date DESC
 limit 1000, 1)
 ORDER BY trade_date DESC
 limit 1000
 
 
 # 原语句中如果order by后正序，那改写后用 >=
 # 原语句中如果order by后倒序，那改写后用 <=
```

优化前后对比

| 优化前     | 优化后   | 备注   |
| ------- | ----- | ---- |
| 5268 ms | 35 ms | 改写   |

