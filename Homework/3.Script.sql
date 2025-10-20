USE SUPPLY_CHAIN;
SHOW TABLES FROM SUPPLY_CHAIN;

SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'SUPPLY_CHAIN'
ORDER BY table_name, ordinal_position;

-- Driver efficiency by clients
SELECT 
    o.driver_id,
    o.client_id,
    SUM(CASE WHEN o.delivery_status = 'Pavėluota' THEN 1 ELSE 0 END) AS paveluota_count,
    SUM(CASE WHEN o.delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS laiku_count,
    COUNT(*) AS total,
    ROUND(100 * SUM(CASE WHEN o.delivery_status = 'Pavėluota' THEN 1 ELSE 0 END)/COUNT(*), 2) AS paveluota_percent
FROM orders o
GROUP BY o.driver_id, o.client_id
ORDER BY paveluota_percent DESC;

-- Average parcel weight by day of the week
SELECT 
    eta_weekday,
    ROUND(AVG(weight), 2) AS avg_weight,
    MIN(weight) AS min_weight,
    MAX(weight) AS max_weight
FROM orders
GROUP BY eta_weekday
ORDER BY FIELD(eta_weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday');

SELECT MAX(weight) AS max_weight FROM orders;

-- TOP 5 drivers for on-time deliveries
SELECT 
    driver_id,
    SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END) AS laiku_count,
    COUNT(*) AS total,
    ROUND(100 * SUM(CASE WHEN delivery_status = 'Laiku' THEN 1 ELSE 0 END)/COUNT(*), 2) AS laiku_percent
FROM orders
GROUP BY driver_id
ORDER BY laiku_percent DESC
LIMIT 5;

-- Average number of parcels per customer and variance
SELECT 
    ROUND(AVG(total),2) AS avg_orders_per_client,
    MIN(total) AS min_orders,
    MAX(total) AS max_orders
FROM clients;


-- Comparison of weight categories and clients
SELECT 
    o.weight_category,
    c.client_id,
    COUNT(*) AS total,
    SUM(CASE WHEN o.delivery_status='Pavėluota' THEN 1 ELSE 0 END) AS paveluota_count,
    ROUND(100 * SUM(CASE WHEN o.delivery_status='Pavėluota' THEN 1 ELSE 0 END)/COUNT(*), 2) AS paveluota_percent
FROM orders o
JOIN clients c ON o.client_id = c.client_id
GROUP BY o.weight_category, c.client_id
ORDER BY o.weight_category, paveluota_percent DESC;

-- Efficiency by day of the week and driver
SELECT 
    o.driver_id,
    o.eta_weekday,
    COUNT(*) AS total,
    SUM(CASE WHEN o.delivery_status='Laiku' THEN 1 ELSE 0 END) AS laiku,
    SUM(CASE WHEN o.delivery_status='Pavėluota' THEN 1 ELSE 0 END) AS paveluota,
    ROUND(100 * SUM(CASE WHEN o.delivery_status='Laiku' THEN 1 ELSE 0 END)/COUNT(*), 2) AS laiku_percent
FROM orders o
GROUP BY o.driver_id, o.eta_weekday
ORDER BY o.driver_id, FIELD(o.eta_weekday,'Monday','Tuesday','Wednesday','Thursday','Friday');

-- Average delay (in hours)
SELECT 
    o.driver_id,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, ETA, delivery_date)), 2) AS avg_delay_hours,
    MAX(TIMESTAMPDIFF(HOUR, ETA, delivery_date)) AS max_delay_hours
FROM orders o
WHERE delivery_date > ETA
GROUP BY o.driver_id
ORDER BY avg_delay_hours DESC;

-- General summary of the entire system
SELECT 
    SUM(CASE WHEN delivery_status='Laiku' THEN 1 ELSE 0 END) AS total_laiku,
    SUM(CASE WHEN delivery_status='Pavėluota' THEN 1 ELSE 0 END) AS total_paveluota,
    COUNT(*) AS total,
    ROUND(100 * SUM(CASE WHEN delivery_status='Laiku' THEN 1 ELSE 0 END)/COUNT(*),2) AS laiku_percent,
    ROUND(100 * SUM(CASE WHEN delivery_status='Pavėluota' THEN 1 ELSE 0 END)/COUNT(*),2) AS paveluota_percent,
    ROUND(AVG(weight),2) AS avg_weight
FROM orders;

SELECT 
    MIN(ETA) AS min_eta,
    MAX(ETA) AS max_eta
FROM orders;

SELECT 
    MIN(accept_date) AS min_accept_date,
    MAX(accept_date) AS max_accept_date
FROM orders;

SELECT *
FROM orders
WHERE DATE(ETA) = '2025-09-07';

SELECT 
    MIN(weight) AS min_weight,
    MAX(weight) AS max_weight
FROM orders;




