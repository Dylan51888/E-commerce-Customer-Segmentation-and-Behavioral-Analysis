-- 切换到 taobao 数据库
USE taobao;

-- 查看表结构
DESC user_behavior;

-- 查询前5条数据
SELECT * FROM user_behavior LIMIT 5;



-- 检查空值（仅检查前1万条数据）
SELECT * FROM user_behavior WHERE user_id IS NULL LIMIT 10000;
SELECT * FROM user_behavior WHERE item_id IS NULL LIMIT 10000;
SELECT * FROM user_behavior WHERE category_id IS NULL LIMIT 10000;
SELECT * FROM user_behavior WHERE behavior_type IS NULL LIMIT 10000;
SELECT * FROM user_behavior WHERE timestamps IS NULL LIMIT 10000;

-- 检查重复值（只针对前1万条记录）
SELECT user_id, item_id, timestamps 
FROM user_behavior
GROUP BY user_id, item_id, timestamps
HAVING COUNT(*) > 1
LIMIT 10000;

-- 去重：使用临时表来加速去重，基于前1万条数据
CREATE TABLE temp_user_behavior AS
SELECT user_id, 
       item_id, 
       timestamps, 
       MAX(category_id) AS category_id, 
       MAX(behavior_type) AS behavior_type
FROM user_behavior
GROUP BY user_id, item_id, timestamps
HAVING COUNT(*) = 1
LIMIT 10000;

-- 替换原表
DROP TABLE user_behavior;
RENAME TABLE temp_user_behavior TO user_behavior;

-- 新增自增主键列
ALTER TABLE user_behavior ADD id INT FIRST;
ALTER TABLE user_behavior MODIFY id INT PRIMARY KEY AUTO_INCREMENT;

-- 更改InnoDB缓冲区大小
SHOW VARIABLES LIKE '%_buffer%';
SET GLOBAL innodb_buffer_pool_size = 1070000000;

-- 新增datetime字段
ALTER TABLE user_behavior ADD datetimes TIMESTAMP(0);

-- 创建存储过程进行批量更新datetimes（只处理前1万条数据，每次更新1千条记录）
DELIMITER $$

CREATE PROCEDURE batch_update_user_behavior()
BEGIN
  DECLARE batch_size INT DEFAULT 1000;
  DECLARE start_id INT DEFAULT 0;
  DECLARE end_id INT DEFAULT 0;

  -- 循环批量更新，直到处理完1万行
  WHILE start_id < 10000 DO
    -- 获取当前批次的最大id
    SET end_id = start_id + batch_size;

    UPDATE user_behavior
    SET datetimes = FROM_UNIXTIME(timestamps)
    WHERE id > start_id AND id <= end_id;

    -- 更新开始id
    SET start_id = end_id;
  END WHILE;

END$$

DELIMITER ;

-- 执行存储过程来更新 datetimes 列
CALL batch_update_user_behavior();

-- 新增 date, time, hour 字段
ALTER TABLE user_behavior ADD dates CHAR(10);
ALTER TABLE user_behavior ADD times CHAR(8);
ALTER TABLE user_behavior ADD hours CHAR(2);

-- 创建存储过程来批量更新 date, time, hour 字段（每次处理1千条记录）
DELIMITER $$

CREATE PROCEDURE batch_update_datetime_columns()
BEGIN
  DECLARE batch_size INT DEFAULT 1000;
  DECLARE start_id INT DEFAULT 0;
  DECLARE end_id INT DEFAULT 0;

  -- 循环批量更新，直到处理完1万行
  WHILE start_id < 10000 DO
    -- 获取当前批次的最大id
    SET end_id = start_id + batch_size;

    UPDATE user_behavior
    SET dates = SUBSTRING(datetimes, 1, 10),
        times = SUBSTRING(datetimes, 12, 8),
        hours = SUBSTRING(datetimes, 12, 2)
    WHERE id > start_id AND id <= end_id;

    -- 更新开始id
    SET start_id = end_id;
  END WHILE;

END$$

DELIMITER ;

-- 执行存储过程来更新 date, time, hour 列
CALL batch_update_datetime_columns();

-- 查看更新后的前5条数据
SELECT * FROM user_behavior LIMIT 5;

-- 去除异常日期数据：删除不在 2017-11-25 到 2017-12-03 范围内的数据（只处理前1万条记录）
DELETE FROM user_behavior
WHERE datetimes < '2017-11-25 00:00:00'
   OR datetimes > '2017-12-03 23:59:59'
LIMIT 10000;

-- 数据概览
DESC user_behavior;
SELECT * FROM user_behavior LIMIT 5;
SELECT COUNT(1) FROM user_behavior LIMIT 10000;