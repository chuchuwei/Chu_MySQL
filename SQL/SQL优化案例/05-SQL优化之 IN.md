## SQL优化

[toc]

### IN查询条件行数太多导致索引失效

IN查询的条件数占总表行数的一半多，导致优化器选择全表扫描

```shell
SELECT
 content_type AS type,
 content_name AS title
FROM
 `tbl_med_content_type_bac`
WHERE
 content_type IN (
  SELECT
   content_type
  FROM
   `tbl_med_project_content_type`
  WHERE
   project_id = 5
  AND visit_type = (
   SELECT
    type
   FROM
    `tbl_med_visit`
   WHERE
    id = 3
  )
  ORDER BY
   content_type ASC
 );
```

