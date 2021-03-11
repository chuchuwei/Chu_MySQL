### SQL编写

根据两列条件取重复的行（在某一列重复的条件之下判断其他列是否重复），并且保留第一行，查找其余重复行


```shell
select * 
FROM
	T_CMDB_ASSET_PROPERTY_VALUE
WHERE
	(ASSET_CODE, PROPERTY_CODE) IN (		
				SELECT
					ASSET_CODE,
					PROPERTY_CODE
				FROM
					T_CMDB_ASSET_PROPERTY_VALUE
				where
					CATEGORY_CODE='cloud-rds'
				GROUP BY
					ASSET_CODE,
					PROPERTY_CODE
				HAVING
					count(1) > 1)
AND id NOT IN (
			SELECT
				min(id)
			FROM
				T_CMDB_ASSET_PROPERTY_VALUE
			where
					CATEGORY_CODE='cloud-rds'
			GROUP BY
				ASSET_CODE,
				PROPERTY_CODE
			HAVING
				count(1) > 1);
```

