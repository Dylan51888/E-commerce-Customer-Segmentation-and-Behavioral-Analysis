-- 如果表存在，删除 temp_behavior 表
DROP TABLE IF EXISTS temp_behavior;

-- 创建临时表（结构与 user_behavior 相同）
CREATE TABLE temp_behavior LIKE user_behavior;

-- 截取前 9000 条数据到临时表
INSERT INTO temp_behavior
SELECT * FROM user_behavior LIMIT 9000;

-- 查看临时表内容
SELECT * FROM temp_behavior;

-- 计算 pv：统计每个日期的页面访问量 (PV)，限定行为类型为 'pv'
SELECT dates,
       COUNT(*) AS 'pv'
FROM temp_behavior
WHERE behavior_type = 'pv'
GROUP BY dates
LIMIT 9000;

-- 计算 uv：统计每个日期的独立用户访问量 (UV)，限定行为类型为 'pv'
SELECT dates,
       COUNT(DISTINCT user_id) AS 'uv'
FROM temp_behavior
WHERE behavior_type = 'pv'
GROUP BY dates
LIMIT 9000;

-- 计算 pv, uv, 以及 pv/uv 比例
SELECT dates,
       COUNT(*) AS 'pv',
       COUNT(DISTINCT user_id) AS 'uv',
       ROUND(COUNT(*) / COUNT(DISTINCT user_id), 1) AS 'pv/uv'
FROM temp_behavior
WHERE behavior_type = 'pv'
GROUP BY dates
LIMIT 9000;

-- 删除已存在的 pv_uv_puv 表
DROP TABLE IF EXISTS pv_uv_puv;

-- 创建存储最终处理结果的表
CREATE TABLE pv_uv_puv (
    dates CHAR(10),
    pv INT(9),
    uv INT(9),
    puv DECIMAL(10,1)
);

-- 将处理后的数据插入 pv_uv_puv 表
INSERT INTO pv_uv_puv
SELECT dates,
       COUNT(*) AS 'pv',
       COUNT(DISTINCT user_id) AS 'uv',
       ROUND(COUNT(*) / COUNT(DISTINCT user_id), 1) AS 'pv/uv'
FROM user_behavior
WHERE behavior_type = 'pv'
GROUP BY dates
LIMIT 9000;

-- 查看最终处理结果
SELECT * FROM pv_uv_puv;

-- 禁用安全更新模式
SET SQL_SAFE_UPDATES = 0;

-- 删除日期为空的数据
DELETE FROM pv_uv_puv WHERE dates IS NULL;

-- 重新开启安全更新模式
SET SQL_SAFE_UPDATES = 1;