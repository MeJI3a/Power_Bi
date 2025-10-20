USE SUPPLY_CHAIN;

CREATE TABLE orders (
shipment VARCHAR(20) PRIMARY KEY,
accept_date DATETIME,
delivery_date DATETIME,
packs INT,
weight FLOAT,
sender_terminal INT,
receiver_terminal INT,
client_id VARCHAR(20),
driver_id VARCHAR(20)
);

INSERT INTO orders (shipment, accept_date, delivery_date, packs, weight, sender_terminal, receiver_terminal, client_id, driver_id)
SELECT DISTINCT shipment, accept_date, delivery_date, packs, weight, sender_terminal, receiver_terminal, client_id, driver_id
FROM SUPPLY_CHAIN_DATA;

SELECT*FROM orders LIMIT 10;

SELECT shipment
FROM orders
LIMIT 100;

SELECT shipment, driver_id, client_id
FROM orders
LIMIT 10;

ALTER TABLE orders ADD COLUMN ETA DATETIME; 
SET net_write_timeout = 600;
SET net_read_timeout = 600;
SET SQL_SAFE_UPDATES = 0;

SET SQL_SAFE_UPDATES = 0;
UPDATE orders
SET ETA = 
    CASE 
        WHEN DAYOFWEEK(accept_date) = 6 
            THEN DATE_ADD(DATE(accept_date), INTERVAL 3 DAY)
        WHEN DAYOFWEEK(accept_date) = 7 
            THEN DATE_ADD(DATE(accept_date), INTERVAL 2 DAY)
        ELSE DATE_ADD(DATE(accept_date), INTERVAL 1 DAY)
    END + INTERVAL '17:00:00' HOUR_SECOND;

SELECT accept_date, ETA, DAYNAME(ETA)
FROM orders
LIMIT 10;


SELECT shipment, accept_date, ETA
FROM orders
LIMIT 10;

ALTER TABLE orders ADD COLUMN delivery_status VARCHAR(20);

UPDATE orders
SET delivery_status =
    CASE 
        WHEN delivery_date <= ETA THEN 'Laiku'
        ELSE 'Pavėluota'
    END;

SELECT shipment, accept_date, delivery_date, ETA, delivery_status
FROM orders
LIMIT 200;

SELECT shipment, accept_date, delivery_date, ETA, delivery_status
FROM orders
WHERE delivery_status = 'Pavėluota'
LIMIT 200;

SELECT*FROM orders limit 5;

ALTER TABLE orders ADD COLUMN weight_category VARCHAR(10);

UPDATE orders
SET weight_category =
    CASE
        WHEN weight < 1 THEN 'Small'
        WHEN weight BETWEEN 1 AND 5 THEN 'Medium'
        ELSE 'Big'
    END;

SHOW COLUMNS FROM orders;
DESCRIBE orders;

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders';

SELECT 
    weight_category,
    ROUND(100 * SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) / COUNT(*), 2) AS paveluota_procentas
FROM orders
GROUP BY weight_category;

SELECT 
    weight_category,
    ROUND(100 * SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) / COUNT(*), 2) AS paveluota_procentas
FROM orders
GROUP BY weight_category;


SELECT 
    weight_category,
    COUNT(*) AS total,
    SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS paveluota_count
FROM orders
GROUP BY weight_category;

SELECT 
    weight_category,
    COUNT(*) AS total,
    SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS paveluota_count
FROM orders
GROUP BY weight_category;

CREATE TABLE drivers AS
SELECT 
    driver_id,
    SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS paveluota_count,
    SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS laiku_count
FROM orders
GROUP BY driver_id;

SELECT*FROM drivers limit 100;

CREATE TABLE boxes AS
SELECT 
    weight_category,
    SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS paveluota_count,
    SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS laiku_count
FROM orders
GROUP BY weight_category;

ALTER TABLE boxes ADD COLUMN total INT;

ALTER TABLE boxes ADD COLUMN total INT;
UPDATE boxes
SET total = paveluota_count + laiku_count;

select*from boxes;

ALTER TABLE orders ADD COLUMN weekday VARCHAR(15);
UPDATE orders
SET weekday = DAYNAME(accept_date);

CREATE TABLE weekdays AS
SELECT 
    weekday,
    SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS laiku_count,
    SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS paveluota_count,
    COUNT(*) AS total
FROM orders
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
SELECT*FROM weekdays;
select*from boxes;

DROP TABLE weekdays;
CREATE TABLE weekdays AS
SELECT 
    weekday,
    SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS laiku_count,
    SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS paveluota_count,
    COUNT(*) AS total
FROM orders
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


SELECT COUNT(*) AS sunday_deliveries
FROM orders
WHERE DAYOFWEEK(delivery_date) = 1;

SELECT *
FROM orders
WHERE weekday = 'Sunday'
LIMIT 1000;

UPDATE orders
SET weekday = DAYNAME(accept_date);

ALTER TABLE orders ADD COLUMN delivery_status VARCHAR(20);
UPDATE orders
SET delivery_status =
    CASE 
        WHEN delivery_date <= ETA THEN 'Laiku'
        ELSE 'Pavėluota'
    END;

ALTER TABLE orders ADD COLUMN weight_category VARCHAR(10);
UPDATE orders
SET weight_category =
    CASE
        WHEN weight < 1 THEN 'Small'
        WHEN weight BETWEEN 1 AND 5 THEN 'Medium'
        ELSE 'Big'
    END;


DROP TABLE IF EXISTS weekdays;
CREATE TABLE weekdays AS
SELECT 
    eta_weekday AS weekday,
    SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS paveluota_count,
    SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS laiku_count,
    COUNT(*) AS total,
    ROUND(100 * SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) / COUNT(*), 2) AS paveluota_percent,
    ROUND(100 * SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) / COUNT(*), 2) AS laiku_percent
FROM orders
GROUP BY eta_weekday
ORDER BY FIELD(eta_weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday');
SELECT*FROM weekdays;

DROP TABLE IF EXISTS weight_category;
DROP TABLE IF EXISTS weight_category_summary;
CREATE TABLE weight_category_summary AS
SELECT
    weight_category,

    SUM(CASE WHEN eta_weekday = 'Monday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Monday_Pav,
    SUM(CASE WHEN eta_weekday = 'Monday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Monday_Lai,

    SUM(CASE WHEN eta_weekday = 'Tuesday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Tuesday_Pav,
    SUM(CASE WHEN eta_weekday = 'Tuesday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Tuesday_Lai,

    SUM(CASE WHEN eta_weekday = 'Wednesday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Wednesday_Pav,
    SUM(CASE WHEN eta_weekday = 'Wednesday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Wednesday_Lai,

    SUM(CASE WHEN eta_weekday = 'Thursday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Thursday_Pav,
    SUM(CASE WHEN eta_weekday = 'Thursday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Thursday_Lai,

    SUM(CASE WHEN eta_weekday = 'Friday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Friday_Pav,
    SUM(CASE WHEN eta_weekday = 'Friday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Friday_Lai,

    COUNT(*) AS total
FROM orders
GROUP BY weight_category
ORDER BY FIELD(weight_category, 'Small', 'Medium', 'Big');

         
SELECT*FROM weight_category_summary;

DROP TABLE IF EXISTS weight_category_percent;

CREATE TABLE weight_category_percent AS
SELECT
    weight_category,

    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Monday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Monday' THEN 1 ELSE 0 END), 0), 2) AS Monday_Pav,
    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Monday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Monday' THEN 1 ELSE 0 END), 0), 2) AS Monday_Lai,

    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Tuesday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Tuesday' THEN 1 ELSE 0 END), 0), 2) AS Tuesday_Pav,
    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Tuesday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Tuesday' THEN 1 ELSE 0 END), 0), 2) AS Tuesday_Lai,

    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Wednesday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Wednesday' THEN 1 ELSE 0 END), 0), 2) AS Wednesday_Pav,
    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Wednesday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Wednesday' THEN 1 ELSE 0 END), 0), 2) AS Wednesday_Lai,

    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Thursday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Thursday' THEN 1 ELSE 0 END), 0), 2) AS Thursday_Pav,
    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Thursday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Thursday' THEN 1 ELSE 0 END), 0), 2) AS Thursday_Lai,

    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Friday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Friday' THEN 1 ELSE 0 END), 0), 2) AS Friday_Pav,
    ROUND(100 * SUM(CASE WHEN eta_weekday = 'Friday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) /
          NULLIF(SUM(CASE WHEN eta_weekday = 'Friday' THEN 1 ELSE 0 END), 0), 2) AS Friday_Lai

FROM orders
GROUP BY weight_category
ORDER BY FIELD(weight_category, 'Small', 'Medium', 'Big');

SELECT*FROM weight_category_percent;

DROP TABLE IF EXISTS drivers;

CREATE TABLE drivers AS
SELECT
    driver_id,

    SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS total_paveluota,
    SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS total_laiku,
    COUNT(*) AS total,

    SUM(CASE WHEN eta_weekday = 'Monday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Monday_Pav,
    SUM(CASE WHEN eta_weekday = 'Monday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Monday_Lai,

    SUM(CASE WHEN eta_weekday = 'Tuesday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Tuesday_Pav,
    SUM(CASE WHEN eta_weekday = 'Tuesday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Tuesday_Lai,

    SUM(CASE WHEN eta_weekday = 'Wednesday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Wednesday_Pav,
    SUM(CASE WHEN eta_weekday = 'Wednesday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Wednesday_Lai,

    SUM(CASE WHEN eta_weekday = 'Thursday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Thursday_Pav,
    SUM(CASE WHEN eta_weekday = 'Thursday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Thursday_Lai,

    SUM(CASE WHEN eta_weekday = 'Friday' AND delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS Friday_Pav,
    SUM(CASE WHEN eta_weekday = 'Friday' AND delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS Friday_Lai

FROM orders
GROUP BY driver_id
ORDER BY driver_id;

SELECT*FROM drivers;

DROP TABLE IF EXISTS clients;

CREATE TABLE clients AS
SELECT 
    client_id,
    SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS paveluota_count,
    SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS laiku_count,
    COUNT(*) AS total,
    ROUND(100 * SUM(CASE WHEN delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) / COUNT(*), 2) AS paveluota_percent,
    ROUND(100 * SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) / COUNT(*), 2) AS laiku_percent
FROM orders
GROUP BY client_id
ORDER BY client_id;

SELECT*FROM clients;