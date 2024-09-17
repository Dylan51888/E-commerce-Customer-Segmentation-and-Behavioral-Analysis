-- 删除已存在的临时表（如有）
DROP TABLE IF EXISTS temp_behavior;

-- 创建临时表并插入前 9000 条记录
CREATE TABLE temp_behavior LIKE user_behavior;

INSERT INTO temp_behavior
SELECT * FROM user_behavior LIMIT 9000;

-- 统计各类行为的用户数，限制为前 9000 条记录
SELECT behavior_type,
       COUNT(DISTINCT user_id) AS user_num
FROM temp_behavior
GROUP BY behavior_type
ORDER BY behavior_type DESC
LIMIT 9000;

-- 删除已存在的表（如有），确保可以创建新的表
DROP TABLE IF EXISTS behavior_user_num;

-- 创建存储行为用户数的表
CREATE TABLE behavior_user_num (
    behavior_type VARCHAR(5),
    user_num INT
);

-- 将结果插入 behavior_user_num 表，限制记录数为 9000
INSERT INTO behavior_user_num
SELECT behavior_type,
       COUNT(DISTINCT user_id) AS user_num
FROM user_behavior
GROUP BY behavior_type
ORDER BY behavior_type DESC
LIMIT 9000;

-- 查询插入后的结果，限制为 9000 条记录
SELECT * FROM behavior_user_num LIMIT 9000;

-- 计算购买商品的用户比例
SELECT 672404 / 984105 AS buy_user_ratio;

-- 统计各类行为的数量，限制为前 9000 条记录
SELECT behavior_type,
       COUNT(*) AS behavior_num
FROM temp_behavior
GROUP BY behavior_type
ORDER BY behavior_type DESC
LIMIT 9000;

-- 删除已存在的表（如有），确保可以创建新的表
DROP TABLE IF EXISTS behavior_num;

-- 创建存储行为数量的表
CREATE TABLE behavior_num (
    behavior_type VARCHAR(5),
    behavior_count_num INT
);

-- 将结果插入 behavior_num 表，限制记录数为 9000
INSERT INTO behavior_num
SELECT behavior_type,
       COUNT(*) AS behavior_count_num
FROM user_behavior
GROUP BY behavior_type
ORDER BY behavior_type DESC
LIMIT 9000;

-- 查询插入后的结果，限制为 9000 条记录
SELECT * FROM behavior_num LIMIT 9000;

-- 计算购买率
SELECT 2015807 / 89660670 AS buy_rate;

-- 计算收藏加购率
SELECT (2888255 + 5530446) / 89660670 AS collect_and_cart_rate;