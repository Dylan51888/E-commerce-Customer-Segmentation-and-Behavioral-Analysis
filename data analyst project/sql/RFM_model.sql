-- Step 1: 禁用安全更新模式
SET SQL_SAFE_UPDATES = 0;

-- Step 2: 确保表 rfm_model 存在 frequency 和 recent 列
-- Drop and create rfm_model table for demonstration purposes (if it doesn't already exist)
DROP TABLE IF EXISTS rfm_model;

CREATE TABLE rfm_model (
    user_id INT,
    frequency INT,
    recent CHAR(10)
);

-- 插入示例数据 (限制为前 9000 条记录)
INSERT INTO rfm_model (user_id, frequency, recent)
SELECT user_id,
       COUNT(user_id) AS 'purchase_count',
       MAX(dates) AS 'last_purchase_date'
FROM user_behavior
WHERE behavior_type = 'buy'
GROUP BY user_id
ORDER BY 2 DESC, 3 DESC
LIMIT 9000;

-- Step 3: 添加 fscore 列 (频率评分)
ALTER TABLE rfm_model ADD COLUMN fscore INT;

-- 更新 fscore 列
UPDATE rfm_model
SET fscore = CASE
    WHEN frequency BETWEEN 100 AND 262 THEN 5
    WHEN frequency BETWEEN 50 AND 99 THEN 4
    WHEN frequency BETWEEN 20 AND 49 THEN 3
    WHEN frequency BETWEEN 5 AND 20 THEN 2
    ELSE 1
END;

-- Step 4: 添加 rscore 列 (最近购买评分)
ALTER TABLE rfm_model ADD COLUMN rscore INT;

-- 更新 rscore 列
UPDATE rfm_model
SET rscore = CASE
    WHEN recent = '2017-12-03' THEN 5
    WHEN recent IN ('2017-12-01', '2017-12-02') THEN 4
    WHEN recent IN ('2017-11-29', '2017-11-30') THEN 3
    WHEN recent IN ('2017-11-27', '2017-11-28') THEN 2
    ELSE 1
END;

-- Step 5: 添加 class 列 (用户分类)
ALTER TABLE rfm_model ADD COLUMN class VARCHAR(40);

-- 计算 fscore 和 rscore 的平均值
SET @f_avg = NULL;
SET @r_avg = NULL;
SELECT AVG(fscore) INTO @f_avg FROM rfm_model;
SELECT AVG(rscore) INTO @r_avg FROM rfm_model;

-- 更新 class 列基于 fscore 和 rscore
UPDATE rfm_model
SET class = CASE
    WHEN fscore > @f_avg AND rscore > @r_avg THEN 'Valuable Customer'
    WHEN fscore > @f_avg AND rscore < @r_avg THEN 'Retention Customer'
    WHEN fscore < @f_avg AND rscore > @r_avg THEN 'Potential Customer'
    WHEN fscore < @f_avg AND rscore < @r_avg THEN 'At Risk Customer'
END;

-- Step 6: 重新启用安全更新模式
SET SQL_SAFE_UPDATES = 1;

-- Step 7: 查询最终结果
SELECT * FROM rfm_model LIMIT 9000;

-- Step 8: 统计各类用户数量
SELECT class, COUNT(user_id) AS user_count
FROM rfm_model
GROUP BY class;