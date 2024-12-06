-- Active: 1729712001528@@127.0.0.1@3306@db_schema
USE db_schema;

-- Total orders recorded for each product line
SELECT `productLine`,
        COUNT(od.`orderNumber`) AS total_Orders
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn
    ON odn.`orderNumber` = od.`orderNumber`
GROUP BY `productLine`
ORDER BY total_orders DESC
;

-- Total orders recorded for top 20 products 
SELECT `productName`,
        COUNT(od.`orderNumber`) AS total_Orders
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn
    ON odn.`orderNumber` = od.`orderNumber`
GROUP BY `productName`
ORDER BY total_orders DESC
LIMIT 20
;

-- Quantity sold for each product line
SELECT `productLine`,
        SUM(`quantityOrdered`) AS total_quantity_ordered
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn 
    ON odn.`orderNumber` = od.`orderNumber` 
WHERE odn.`status` IN ('Shipped', 'Resolved')
GROUP BY `productLine`
ORDER BY total_quantity_ordered DESC
;

-- Top 5 & Bottom 5 products by quantity sold
(SELECT `productName`,
        SUM(`quantityOrdered`) AS total_quantity_sold,
        'Top' AS position
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn 
    ON odn.`orderNumber` = od.`orderNumber` 
WHERE odn.`status` IN ('Shipped', 'Resolved')
GROUP BY `productName`, `productLine`
ORDER BY total_quantity_sold DESC
LIMIT 5)
UNION ALL
(SELECT `productName`,
        SUM(`quantityOrdered`) AS total_quantity_sold,
        'Bottom' AS position
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn 
    ON odn.`orderNumber` = od.`orderNumber` 
WHERE odn.`status` IN ('Shipped', 'Resolved')
GROUP BY `productName`, `productLine`
ORDER BY total_quantity_sold ASC
LIMIT 5)
;

-- Top product in product line by quantity sold
WITH product_CTE AS (
    SELECT `productName`,
            `productLine`,
            SUM(`quantityOrdered`) AS total_quantity_sold,
            ROW_NUMBER () OVER(PARTITION BY `productLine` ORDER BY SUM(`quantityOrdered`) DESC) AS row_num
    FROM products_new pn
    JOIN orderdetails od
        ON od.`productCode` = pn.`productCode`
    JOIN orders_new odn 
        ON odn.`orderNumber` = od.`orderNumber`
    GROUP BY `productName`, `productLine`
)
SELECT `productLine`,
        `productName`,
        total_quantity_sold
FROM `product_CTE`
WHERE row_num = 1
;

-- Total orders by status
SELECT odn.status,
       COUNT(od.`orderNumber`) AS total_orders,
       ROUND((COUNT(od.`orderNumber`) * 100.0) / SUM(COUNT(od.`orderNumber`)) OVER (),1) AS orders_percentage
FROM orderdetails od 
JOIN orders_new odn
    ON odn.`orderNumber` = od.`orderNumber`
GROUP BY odn.status
ORDER BY total_orders DESC
;

-- Total shipped orders by product line
WITH product_CTE AS (
    SELECT  pn.`productLine`,
            COUNT(od.`orderNumber`) AS total_shipped_orders
    FROM products_new pn
    JOIN orderdetails od
        ON od.`productCode` = pn.`productCode`
    JOIN orders_new odn
        ON odn.`orderNumber` = od.`orderNumber`
    WHERE odn.`status` IN ('Shipped', 'Resolved')
    GROUP BY pn.`productLine`
)
SELECT `productLine`,
        total_shipped_orders
FROM `product_CTE`
ORDER BY total_shipped_orders DESC
;

-- Total shipped orders by country 
WITH product_CTE AS (
    SELECT c.country,
            COUNT(od.`orderNumber`) AS total_shipped_orders
    FROM products_new pn
    JOIN orderdetails od
        ON od.`productCode` = pn.`productCode`
    JOIN orders_new odn
        ON odn.`orderNumber` = od.`orderNumber`
    JOIN customers_new c 
        ON c.`customerNumber` = odn.`customerNumber` 
     WHERE odn.`status` IN ('Shipped', 'Resolved') 
    GROUP BY c.country
)
SELECT country,
        total_shipped_orders
FROM `product_CTE`
ORDER BY total_shipped_orders DESC
;


-- Total shipped orders by year
SELECT DISTINCT(YEAR(`shippedDate`)) AS year,
        COUNT(odn.`orderNumber`) as total_orders
FROM orders_new odn
JOIN orderdetails od 
    ON od.`orderNumber` = odn.`orderNumber`
WHERE odn.`status` IN ('Shipped', 'Resolved')
GROUP BY YEAR(`shippedDate`)
;

-- Total shipped orders by month 
SELECT DISTINCT(MONTHNAME(`shippedDate`)) AS month,
        COUNT(odn.`orderNumber`) as total_orders
FROM orders_new odn
JOIN orderdetails od 
    ON od.`orderNumber` = odn.`orderNumber`
WHERE odn.`status` IN ('Shipped', 'Resolved')
GROUP BY MONTHNAME(`shippedDate`)
;

-- Total shipped orders by month and year (2003)
SELECT DISTINCT(MONTHNAME(`shippedDate`)) AS month,
        COUNT(odn.`orderNumber`) as total_orders
FROM orders_new odn
JOIN orderdetails od 
    ON od.`orderNumber` = odn.`orderNumber`
WHERE odn.`status` IN ('Shipped', 'Resolved') AND 
        YEAR(`shippedDate`) = 2003
GROUP BY MONTHNAME(`shippedDate`)
;

-- Total shipped orders by month and year (2004)
SELECT DISTINCT(MONTHNAME(`shippedDate`)) AS month,
        COUNT(odn.`orderNumber`) as total_orders
FROM orders_new odn
JOIN orderdetails od 
    ON od.`orderNumber` = odn.`orderNumber`
WHERE odn.`status` IN ('Shipped', 'Resolved') AND 
        YEAR(`shippedDate`) = 2004
GROUP BY MONTHNAME(`shippedDate`)
;

-- Total shipped orders by month and year (2005)
SELECT DISTINCT(MONTHNAME(`shippedDate`)) AS month,
        COUNT(odn.`orderNumber`) as total_orders
FROM orders_new odn
JOIN orderdetails od 
    ON od.`orderNumber` = odn.`orderNumber`
WHERE odn.`status` IN ('Shipped', 'Resolved') AND 
        YEAR(`shippedDate`) = 2005
GROUP BY MONTHNAME(`shippedDate`)
;

-- Total shipped orders by product vendor
SELECT `productVendor`,
        COUNT(odn.`orderNumber`) AS shipped_orders
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn 
    ON odn.`orderNumber` = od.`orderNumber`
WHERE odn.`status` IN ('Shipped', 'Resolved')
GROUP BY `productVendor`
ORDER BY shipped_orders DESC
;

-- Total quantity sold by product vendor
SELECT `productVendor`,
        SUM(odn.`orderNumber`) AS quantity_sold
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn 
    ON odn.`orderNumber` = od.`orderNumber`
WHERE odn.`status` IN ('Shipped', 'Resolved')
GROUP BY `productVendor`
ORDER BY quantity_sold DESC
;
