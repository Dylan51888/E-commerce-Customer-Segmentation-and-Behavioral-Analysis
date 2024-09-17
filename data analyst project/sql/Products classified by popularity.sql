-- 统计热门品类（基于浏览量）
SELECT category_id,
       COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) AS 'category_views'
FROM temp_behavior
GROUP BY category_id
ORDER BY 2 DESC
LIMIT 10;

-- 统计热门商品（基于浏览量）
SELECT item_id,
       COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) AS 'item_views'
FROM temp_behavior
GROUP BY item_id
ORDER BY 2 DESC
LIMIT 10;

-- 统计热门品类下的热门商品（基于浏览量）
SELECT category_id, item_id,
       category_item_views
FROM (
    SELECT category_id, item_id,
           COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) AS category_item_views,
           RANK() OVER (PARTITION BY category_id ORDER BY COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) DESC) AS r
    FROM temp_behavior
    GROUP BY category_id, item_id
    ORDER BY 3 DESC
) a
WHERE a.r = 1
ORDER BY a.category_item_views DESC
LIMIT 10;

-- 存储查询结果到不同的表

-- 创建表存储热门品类
DROP TABLE IF EXISTS popular_categories;
CREATE TABLE popular_categories (
    category_id INT,
    pv INT
);

-- 创建表存储热门商品
DROP TABLE IF EXISTS popular_items;
CREATE TABLE popular_items (
    item_id INT,
    pv INT
);

-- 创建表存储热门品类下的热门商品
DROP TABLE IF EXISTS popular_cateitems;
CREATE TABLE popular_cateitems (
    category_id INT,
    item_id INT,
    pv INT
);

-- 插入热门品类数据
INSERT INTO popular_categories
SELECT category_id,
       COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) AS 'category_views'
FROM user_behavior
GROUP BY category_id
ORDER BY 2 DESC
LIMIT 10;

-- 插入热门商品数据
INSERT INTO popular_items
SELECT item_id,
       COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) AS 'item_views'
FROM user_behavior
GROUP BY item_id
ORDER BY 2 DESC
LIMIT 10;

-- 插入热门品类下的热门商品数据
INSERT INTO popular_cateitems
SELECT category_id, item_id,
       category_item_views
FROM (
    SELECT category_id, item_id,
           COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) AS category_item_views,
           RANK() OVER (PARTITION BY category_id ORDER BY COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) DESC) AS r
    FROM user_behavior
    GROUP BY category_id, item_id
    ORDER BY 3 DESC
) a
WHERE a.r = 1
ORDER BY a.category_item_views DESC
LIMIT 10;

-- 查询存储的热门品类
SELECT * FROM popular_categories;

-- 查询存储的热门商品
SELECT * FROM popular_items;

-- 查询存储的热门品类下的热门商品
SELECT * FROM popular_cateitems;