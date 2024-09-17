-- 统计日期-小时的行为，并限制记录数为 9000
SELECT dates, hours,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS 'pv',
       COUNT(IF(behavior_type='cart', behavior_type, NULL)) AS 'cart',
       COUNT(IF(behavior_type='fav', behavior_type, NULL)) AS 'fav',
       COUNT(IF(behavior_type='buy', behavior_type, NULL)) AS 'buy'
FROM temp_behavior
GROUP BY dates, hours
ORDER BY dates, hours
LIMIT 9000;

-- 创建用于存储结果的表
DROP TABLE IF EXISTS date_hour_behavior; -- 删除已存在的表
CREATE TABLE date_hour_behavior (
    dates CHAR(10),
    hours CHAR(2),
    pv INT,
    cart INT,
    fav INT,
    buy INT
);

-- 将结果插入到 date_hour_behavior 表中，限制记录数为 9000
INSERT INTO date_hour_behavior
SELECT dates, hours,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS 'pv',
       COUNT(IF(behavior_type='cart', behavior_type, NULL)) AS 'cart',
       COUNT(IF(behavior_type='fav', behavior_type, NULL)) AS 'fav',
       COUNT(IF(behavior_type='buy', behavior_type, NULL)) AS 'buy'
FROM user_behavior
GROUP BY dates, hours
ORDER BY dates, hours
LIMIT 9000;

-- 查询结果
SELECT * FROM date_hour_behavior;