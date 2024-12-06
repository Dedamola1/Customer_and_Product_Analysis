USE db_schema;

-- Customer distribution by country
SELECT country,
        COUNT(`customerNumber`) AS total_customers
FROM customers_new
GROUP BY country
ORDER BY total_customers DESC
;

-- Top 10 revenue by customers
SELECT `customerName`,
        SUM(od.`quantityOrdered` * od.`priceEach`) AS revenue
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn
    ON odn.`orderNumber` = od.`orderNumber`
JOIN customers_new c 
    ON c.`customerNumber` = odn.`customerNumber`
WHERE odn.status = "Shipped"
GROUP BY `customerName`
ORDER BY revenue DESC
LIMIT 10
;

-- Top 10 orders by customers
SELECT `customerName`,
        COUNT(od.`orderNumber`) AS orders
FROM products_new pn
JOIN orderdetails od
    ON od.`productCode` = pn.`productCode`
JOIN orders_new odn
    ON odn.`orderNumber` = od.`orderNumber`
JOIN customers_new c 
    ON c.`customerNumber` = odn.`customerNumber`
WHERE odn.status = "Shipped"
GROUP BY `customerName`
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
) AS agg_table1
;

-- Total count of customers above & below credit limit
(SELECT COUNT(`customerNumber`) As customersExceedingLimit,
        'Above Credit Limit' AS credit_limit
FROM (
        SELECT c.`customerNumber`,
                `customerName`,
                `creditLimit`,
                SUM(amount) as totalSpend
        FROM customers_new c 
        JOIN payments p 
        ON p.`customerNumber` = c.`customerNumber`
        GROUP BY c.`customerNumber`,
                `customerName`,
                `creditLimit`
        ORDER BY c.`customerNumber`
) as agg_table2
WHERE totalSpend > `creditLimit`)
UNION ALL
(SELECT COUNT(`customerNumber`) As customersExceedingLimit,
        'Below Credit Limit' AS credit_limit
FROM (
        SELECT c.`customerNumber`,
                `customerName`,
                `creditLimit`,
                SUM(amount) as totalSpend
        FROM customers_new c 
        JOIN payments p 
        ON p.`customerNumber` = c.`customerNumber`
        GROUP BY c.`customerNumber`,
                `customerName`,
                `creditLimit`
        ORDER BY c.`customerNumber`
) as agg_table2
WHERE totalSpend < `creditLimit`)
;

-- Customer distribution by locatioon
SELECT country,
        COUNT(`customerNumber`) AS customersCount
FROM customers_new
GROUP BY country
ORDER BY customersCount DESC
;