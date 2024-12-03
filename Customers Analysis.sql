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
WHERE odn.status = "Shipped"
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
WHERE odn.status = "Shipped"
GROUP BY CONCAT(c.`contactFirstName`, ' ', c.`contactLastName`)
ORDER BY orders DESC
LIMIT 10
;

-- Total customer purchases by payment year
SELECT DISTINCT(YEAR(`paymentDate`)) AS year,
        COUNT(`customerNumber`) AS customer_purchase
FROM payments
GROUP BY YEAR(`paymentDate`)
;

-- Total customer purchases by payment month
SELECT year,
        customer_purchase
FROM (
    SELECT DISTINCT(MONTHNAME(`paymentDate`)) AS year,
            MONTH(`paymentDate`),
            COUNT(`customerNumber`) AS customer_purchase,
            ROW_NUMBER() OVER(ORDER BY MONTH(`paymentDate`)) AS row_num
    FROM payments
    GROUP BY MONTHNAME(`paymentDate`), MONTH(`paymentDate`)
) AS agg_table
;

--
SELECT *
FROM customers_new c
RIGHT JOIN orders_new odn 
    ON odn.`customerNumber` = c.`customerNumber`
RIGHT JOIN payments p 
    ON p.`customerNumber` = c.`customerNumber`
ORDER BY c.`customerNumber` ASC
;