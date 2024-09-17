-- Drop existing views (if they exist)
DROP VIEW IF EXISTS user_behavior_view;
DROP VIEW IF EXISTS user_behavior_standard;
DROP VIEW IF EXISTS user_behavior_path;
DROP VIEW IF EXISTS path_count;

-- Create the view for user behavior summary
CREATE VIEW user_behavior_view AS
SELECT user_id, item_id,
       COUNT(IF(behavior_type='pv', behavior_type, NULL)) AS pv,
       COUNT(IF(behavior_type='fav', behavior_type, NULL)) AS fav,
       COUNT(IF(behavior_type='cart', behavior_type, NULL)) AS cart,
       COUNT(IF(behavior_type='buy', behavior_type, NULL)) AS buy
FROM temp_behavior
GROUP BY user_id, item_id
LIMIT 9000;

-- Create the view for standardizing user behavior
CREATE VIEW user_behavior_standard AS
SELECT user_id, item_id,
       (CASE WHEN pv > 0 THEN 1 ELSE 0 END) AS browsed,
       (CASE WHEN fav > 0 THEN 1 ELSE 0 END) AS favorited,
       (CASE WHEN cart > 0 THEN 1 ELSE 0 END) AS added_to_cart,
       (CASE WHEN buy > 0 THEN 1 ELSE 0 END) AS purchased
FROM user_behavior_view
LIMIT 9000;

-- Create the view for user behavior path
CREATE VIEW user_behavior_path AS
SELECT *,
       CONCAT(browsed, favorited, added_to_cart, purchased) AS purchase_path
FROM user_behavior_standard AS a
WHERE a.purchased > 0
LIMIT 9000;

-- Create the view for counting different purchase paths
CREATE VIEW path_count AS
SELECT purchase_path,
       COUNT(*) AS count
FROM user_behavior_path
GROUP BY purchase_path
ORDER BY count DESC
LIMIT 9000;

-- Create a table to store human-readable descriptions of purchase paths
DROP TABLE IF EXISTS human_readable_path;

CREATE TABLE human_readable_path (
    path_type CHAR(4),
    description VARCHAR(60) -- Increased the length to store longer descriptions
);

-- Insert the human-readable descriptions into the table
INSERT INTO human_readable_path 
VALUES ('0001', 'Direct Purchase'),
       ('1001', 'Browsed and Purchased'),
       ('0011', 'Added to Cart and Purchased'),
       ('1011', 'Browsed, Added to Cart, and Purchased'),
       ('0101', 'Favorited and Purchased'),
       ('1101', 'Browsed, Favorited, and Purchased'),
       ('0111', 'Favorited, Added to Cart, and Purchased'),
       ('1111', 'Browsed, Favorited, Added to Cart, and Purchased');

-- Join path count and human-readable paths
SELECT * FROM path_count p 
JOIN human_readable_path r 
ON p.purchase_path = r.path_type 
ORDER BY p.count DESC
LIMIT 9000;

-- Create a table to store the final results of path analysis
DROP TABLE IF EXISTS path_result;

CREATE TABLE path_result (
    path_type CHAR(4),
    description VARCHAR(60),
    num INT
);

-- Insert results from the join between path_count and human_readable_path
INSERT INTO path_result
SELECT path_type, description, count 
FROM path_count p 
JOIN human_readable_path r 
ON p.purchase_path = r.path_type 
ORDER BY count DESC
LIMIT 9000;

-- Query the final result from path_result
SELECT * FROM path_result;

-- Calculate total number of purchases where the user did not favorite or add to cart
SELECT SUM(buy)
FROM user_behavior_view
WHERE buy > 0 AND fav = 0 AND cart = 0
LIMIT 9000;

-- Subtract 1528016 from total purchase count to get difference
SELECT 2015807 - 1528016 AS diff;

-- Calculate the ratio based on the difference and the total of favorite and add to cart actions
SELECT 487791 / (2888255 + 5530446) AS favorite_and_cart_rate;

-- Clean up: Drop temp views if necessary
DROP VIEW IF EXISTS user_behavior_view;
DROP VIEW IF EXISTS user_behavior_standard;
DROP VIEW IF EXISTS user_behavior_path;
DROP VIEW IF EXISTS path_count;