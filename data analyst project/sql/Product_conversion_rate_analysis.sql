-- Calculate conversion rate for specific items
SELECT item_id,
       COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) AS 'pv',
       COUNT(IF(behavior_type = 'fav', behavior_type, NULL)) AS 'fav',
       COUNT(IF(behavior_type = 'cart', behavior_type, NULL)) AS 'cart',
       COUNT(IF(behavior_type = 'buy', behavior_type, NULL)) AS 'buy',
       COUNT(DISTINCT IF(behavior_type = 'buy', user_id, NULL)) / COUNT(DISTINCT user_id) AS 'item_conversion_rate'
FROM temp_behavior
GROUP BY item_id
ORDER BY item_conversion_rate DESC
LIMIT 9000;

-- Save results into item_detail table
DROP TABLE IF EXISTS item_detail;
CREATE TABLE item_detail (
    item_id INT,
    pv INT,
    fav INT,
    cart INT,
    buy INT,
    user_buy_rate FLOAT
);

INSERT INTO item_detail
SELECT item_id,
       COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) AS 'pv',
       COUNT(IF(behavior_type = 'fav', behavior_type, NULL)) AS 'fav',
       COUNT(IF(behavior_type = 'cart', behavior_type, NULL)) AS 'cart',
       COUNT(IF(behavior_type = 'buy', behavior_type, NULL)) AS 'buy',
       COUNT(DISTINCT IF(behavior_type = 'buy', user_id, NULL)) / COUNT(DISTINCT user_id) AS 'item_conversion_rate'
FROM user_behavior
GROUP BY item_id
ORDER BY item_conversion_rate DESC
LIMIT 9000;

-- Query the saved item_detail table
SELECT * FROM item_detail LIMIT 9000;

-- Calculate conversion rate for categories
DROP TABLE IF EXISTS category_detail;
CREATE TABLE category_detail (
    category_id INT,
    pv INT,
    fav INT,
    cart INT,
    buy INT,
    user_buy_rate FLOAT
);

INSERT INTO category_detail
SELECT category_id,
       COUNT(IF(behavior_type = 'pv', behavior_type, NULL)) AS 'pv',
       COUNT(IF(behavior_type = 'fav', behavior_type, NULL)) AS 'fav',
       COUNT(IF(behavior_type = 'cart', behavior_type, NULL)) AS 'cart',
       COUNT(IF(behavior_type = 'buy', behavior_type, NULL)) AS 'buy',
       COUNT(DISTINCT IF(behavior_type = 'buy', user_id, NULL)) / COUNT(DISTINCT user_id) AS 'category_conversion_rate'
FROM user_behavior
GROUP BY category_id
ORDER BY category_conversion_rate DESC
LIMIT 9000;

-- Query the saved category_detail table
SELECT * FROM category_detail LIMIT 9000;