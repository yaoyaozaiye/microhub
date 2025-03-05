INSERT INTO items (id, created_at, description, name, purchase_date, purchase_value, status, updated_at)
SELECT
    row_number() OVER (ORDER BY random()) AS id,
    datetime('now', '-' || abs(random() % 365) || ' days') AS created_at,
    '有用的东西 ' || row_number() OVER (ORDER BY random()) AS description,
    'Item ' || row_number() OVER (ORDER BY random()) AS name,
    datetime('now', '-' || abs(random() % 365) || ' days') AS purchase_date,
    CAST(1 + abs(random() % 1000) AS INTEGER) AS purchase_value,
    CASE WHEN random() < 0.5 THEN 'IN_USE' ELSE 'STORED' END AS status,
    datetime('now', '-' || abs(random() % 365) || ' days') AS updated_at
FROM
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
     UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10)
T1,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
     UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10)
T2
LIMIT 100;

WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 100
),
random_tags AS (
    SELECT
        n AS item_id,
        CASE
            WHEN abs(random()) / 9223372036854775807.0 < 0.25 THEN 'Tag1'
            WHEN abs(random()) / 9223372036854775807.0< 0.5 THEN 'Tag2'
            WHEN abs(random()) / 9223372036854775807.0 < 0.75 THEN 'Tag3'
            ELSE 'Tag4'
        END AS tag
    FROM
        numbers
    UNION ALL
    SELECT
        n AS item_id,
        CASE
            WHEN abs(random()) / 9223372036854775807.0 < 0.25 THEN 'Tag5'
            WHEN abs(random()) / 9223372036854775807.0 < 0.5 THEN 'Tag6'
            WHEN abs(random()) / 9223372036854775807.0 < 0.75 THEN 'Tag7'
            ELSE 'Tag8'
        END AS tag
    FROM
        numbers
    WHERE
        abs(random()) / 9223372036854775807.0 < 0.5
)
INSERT INTO item_tags (item_id, tag)
SELECT item_id, tag FROM random_tags;
