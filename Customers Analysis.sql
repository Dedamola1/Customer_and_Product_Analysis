USE db_schema;

-- Customer distribution by country
SELECT country,
        COUNT(`customerNumber`) AS total_customers
FROM customers_new
GROUP BY country
ORDER BY total_customers DESC
;

-- Top 10 revenue by customers
SELECT CONCAT(c.`contactFirstName`, " ", c.`contactLastName`) AS fullName,
        SUM(od.`quantityOrdered` * od.`priceEach`) AS revenue
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn
    ON odn.`orderNumber` = od.`orderNumber`
JOIN customers_new c 
    ON c.`customerNumber` = odn.`customerNumber`
GROUP BY CONCAT(c.`contactFirstName`, ' ', c.`contactLastName`)
ORDER BY revenue DESC
LIMIT 10
;

-- Top 10 orders by customers
SELECT CONCAT(c.`contactFirstName`, " ", c.`contactLastName`) AS fullName,
        COUNT(od.`orderNumber`) AS orders
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn
    ON odn.`orderNumber` = od.`orderNumber`
JOIN customers_new c 
    ON c.`customerNumber` = odn.`customerNumber`
GROUP BY CONCAT(c.`contactFirstName`, ' ', c.`contactLastName`)
ORDER BY orders DESC
LIMIT 10;