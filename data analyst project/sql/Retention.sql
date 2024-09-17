-- 查询 dates 列为空的记录
SELECT * FROM user_behavior WHERE dates IS NULL LIMIT 9000;

-- 删除 dates 列为空的记录
DELETE FROM user_behavior WHERE dates IS NULL LIMIT 9000;

-- 查询并分组 user_id 和 dates
SELECT user_id, dates 
FROM temp_behavior
GROUP BY user_id, dates
LIMIT 9000;

-- 自关联查询
SELECT * FROM 
(SELECT user_id, dates 
 FROM temp_behavior
 GROUP BY user_id, dates
 LIMIT 9000) a,
(SELECT user_id, dates 
 FROM temp_behavior
 GROUP BY user_id, dates
 LIMIT 9000) b
WHERE a.user_id = b.user_id;

-- 筛选查询，筛选条件是 a.dates < b.dates
SELECT * FROM 
(SELECT user_id, dates 
 FROM temp_behavior
 GROUP BY user_id, dates
 LIMIT 9000) a,
(SELECT user_id, dates 
 FROM temp_behavior
 GROUP BY user_id, dates
 LIMIT 9000) b
WHERE a.user_id = b.user_id AND a.dates < b.dates;

-- 计算留存数，分别计算 0 天、1 天和 3 天的留存
SELECT a.dates,
       COUNT(IF(DATEDIFF(b.dates, a.dates) = 0, b.user_id, NULL)) AS retention_0,
       COUNT(IF(DATEDIFF(b.dates, a.dates) = 1, b.user_id, NULL)) AS retention_1,
       COUNT(IF(DATEDIFF(b.dates, a.dates) = 3, b.user_id, NULL)) AS retention_3
FROM 
(SELECT user_id, dates 
 FROM temp_behavior
 GROUP BY user_id, dates
 LIMIT 9000) a,
(SELECT user_id, dates 
 FROM temp_behavior
 GROUP BY user_id, dates
 LIMIT 9000) b
WHERE a.user_id = b.user_id AND a.dates <= b.dates
GROUP BY a.dates;

-- 计算留存率，计算 1 天的留存率
SELECT a.dates,
       COUNT(IF(DATEDIFF(b.dates, a.dates) = 1, b.user_id, NULL)) / COUNT(IF(DATEDIFF(b.dates, a.dates) = 0, b.user_id, NULL)) AS retention_1
FROM 
(SELECT user_id, dates 
 FROM temp_behavior
 GROUP BY user_id, dates
 LIMIT 9000) a,
(SELECT user_id, dates 
 FROM temp_behavior
 GROUP BY user_id, dates
 LIMIT 9000) b
WHERE a.user_id = b.user_id AND a.dates <= b.dates
GROUP BY a.dates;

-- 保存结果到 retention_rate 表
CREATE TABLE retention_rate (
    dates CHAR(10),
    retention_1 FLOAT
);

-- 插入计算的留存率结果
INSERT INTO retention_rate 
SELECT a.dates,
       COUNT(IF(DATEDIFF(b.dates, a.dates) = 1, b.user_id, NULL)) / COUNT(IF(DATEDIFF(b.dates, a.dates) = 0, b.user_id, NULL)) AS retention_1
FROM 
(SELECT user_id, dates 
 FROM user_behavior
 GROUP BY user_id, dates
 LIMIT 9000) a,
(SELECT user_id, dates 
 FROM user_behavior
 GROUP BY user_id, dates
 LIMIT 9000) b
WHERE a.user_id = b.user_id AND a.dates <= b.dates
GROUP BY a.dates;

-- 查看留存率表中的数据
SELECT * FROM retention_rate;

-- 计算跳失率，计算只有一个访问行为的用户数量
SELECT COUNT(*) 
FROM 
(SELECT user_id 
 FROM user_behavior
 GROUP BY user_id
 HAVING COUNT(behavior_type) = 1
 LIMIT 9000) a;

-- 计算 pv 总数
SELECT SUM(pv) FROM pv_uv_puv LIMIT 9000;

-- 计算跳失率：跳失用户数除以总 PV 数
-- 假设跳失用户数量是 88
SELECT 88 / (SELECT SUM(pv) FROM pv_uv_puv LIMIT 9000) AS bounce_rate;