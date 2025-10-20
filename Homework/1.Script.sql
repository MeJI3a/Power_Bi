Drop database SUPPLY_CHAIN;
CREATE DATABASE SUPPLY_CHAIN;
USE SUPPLY_CHAIN;

CREATE TEMPORARY TABLE SUPPLY_CHAIN_DATA (
shipment VARCHAR(20),
accept_date DATETIME,
delivery_date DATETIME,
packs INT,
weight FLOAT,
sender_terminal INT,
receiver_terminal INT,
client_id VARCHAR(20),
driver_id VARCHAR(20)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Data.csv'
INTO TABLE SUPPLY_CHAIN_DATA
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
shipment,
@accept_date,
@delivery_date,
packs,
weight,
sender_terminal,
receiver_terminal,
client_id,
driver_id
)
SET
accept_date = STR_TO_DATE(@accept_date, '%m/%d/%Y %H:%i'),
delivery_date = STR_TO_DATE(@delivery_date, '%m/%d/%Y %H:%i');

SELECT*FROM SUPPLY_CHAIN_DATA LIMIT 10;
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

ALTER TABLE orders ADD COLUMN ETA DATETIME;
SET SQL_SAFE_UPDATES = 0;
UPDATE orders
SET ETA =
    CASE
        WHEN DAYOFWEEK(accept_date) = 6 THEN DATE_ADD(DATE(accept_date), INTERVAL 3 DAY)
        WHEN DAYOFWEEK(accept_date) = 7 THEN DATE_ADD(DATE(accept_date), INTERVAL 2 DAY)
        ELSE DATE_ADD(DATE(accept_date), INTERVAL 1 DAY)
    END + INTERVAL '17:00:00' HOUR_SECOND;

ALTER TABLE orders ADD COLUMN eta_weekday VARCHAR(15);
UPDATE orders
SET eta_weekday = DAYNAME(ETA);

SELECT 
    eta_weekday,
    COUNT(*) AS total_shipments
FROM orders
GROUP BY eta_weekday
ORDER BY FIELD(eta_weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


