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
WHERE odn.`status` IN ('Shipped', 'Resolved')
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
WHERE odn.`status` IN ('Shipped', 'Resolved')
GROUP BY `customerName`
ORDER BY orders DESC
LIMIT 10
;

-- Total customer transactions by year
SELECT DISTINCT(YEAR(`paymentDate`)) AS year,
        COUNT(`customerNumber`) AS customerTransactions
FROM payments
GROUP BY YEAR(`paymentDate`)
;

-- Total transactions by top 5 customers
SELECT  `customerName`,
        COUNT(p.`customerNumber`) AS transactions
FROM payments p 
JOIN customers_new c 
        ON c.`customerNumber` = p.`customerNumber`
GROUP BY `customerName`
ORDER BY transactions DESC
LIMIT 5
;

-- Total customer purchases by payment month
SELECT month,
        customer_purchase 
FROM (
    SELECT DISTINCT(MONTHNAME(`paymentDate`)) AS month,
            MONTH(`paymentDate`),
            COUNT((`customerNumber`)) AS customer_purchase,
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
) as agg_table3
WHERE totalSpend < `creditLimit`)
;

-- Customers name who exceed their credit limit
SELECT `customerName`
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
) as agg_table4
WHERE totalSpend > `creditLimit`
;

-- Average revenue per customer (ARPC) in 2003, 2004 and 2005
(SELECT ROUND(revenue / customers,2) AS AverageRevenuePerCustomer,
        '2003' AS Year
FROM (
        SELECT SUM(od.`quantityOrdered` * od.`priceEach`) AS revenue,
                COUNT(DISTINCT(`customerName`)) AS customers
        FROM orderdetails od
        JOIN orders_new odn
                ON odn.`orderNumber` = od.`orderNumber`
        JOIN customers_new c 
                ON c.`customerNumber` = odn.`customerNumber`
        WHERE odn.`status` IN ('Shipped', 'Resolved') AND YEAR(`shippedDate`) = 2003
) AS agg_table5)
UNION ALL
(SELECT ROUND(revenue / customers,2) AS AverageRevenuePerCustomer,
        '2004' AS Year
FROM (
        SELECT SUM(od.`quantityOrdered` * od.`priceEach`) AS revenue,
                COUNT(DISTINCT(`customerName`)) AS customers
        FROM orderdetails od
        JOIN orders_new odn
                ON odn.`orderNumber` = od.`orderNumber`
        JOIN customers_new c 
                ON c.`customerNumber` = odn.`customerNumber`
        WHERE odn.`status` IN ('Shipped', 'Resolved') AND YEAR(`shippedDate`) = 2004
) AS agg_table5)
UNION ALL
(SELECT ROUND(revenue / customers,2) AS AverageRevenuePerCustomer,
        '2005' AS Year
FROM (
        SELECT SUM(od.`quantityOrdered` * od.`priceEach`) AS revenue,
                COUNT(DISTINCT(`customerName`)) AS customers
        FROM orderdetails od
        JOIN orders_new odn
                ON odn.`orderNumber` = od.`orderNumber`
        JOIN customers_new c 
                ON c.`customerNumber` = odn.`customerNumber`
        WHERE odn.`status` IN ('Shipped', 'Resolved') AND YEAR(`shippedDate`) = 2005
) AS agg_table5)
;

-- Customer lifetime value
WITH customerCTE AS (
        SELECT ROUND(total_revenue / total_purchases,2) AS average_purcahse_value,
                ROUND(total_purchases / total_customers,2) AS average_purchase_frequency_rate,
                ROUND((total_customers_begin - total_customers_end)/total_customers_begin,2) AS churn_rate
        FROM (
                SELECT SUM(od.`quantityOrdered` * od.`priceEach`) AS total_revenue,
                        COUNT(`customerNumber`) AS total_purchases,
                        COUNT(DISTINCT(`customerNumber`)) AS total_customers,
                        COUNT(DISTINCT CASE WHEN YEAR(odn.`shippedDate`) = 2003 THEN odn.`customerNumber` END) AS total_customers_begin,
                        COUNT(DISTINCT CASE WHEN YEAR(odn.`shippedDate`) = 2005 THEN odn.`customerNumber` END) AS total_customers_end                       
                FROM orderdetails od
                JOIN orders_new odn
                        ON odn.`orderNumber` = od.`orderNumber`
                WHERE odn.`status` IN ('Shipped', 'Resolved')
                ) as agg_table6
),
CustomerLifetimeValue_CTE AS (
        SELECT ROUND((average_purcahse_value * average_purchase_frequency_rate),2) AS customer_value,
                ROUND(1/churn_rate,1) AS avg_customer_lifespan
        FROM customerCTE
)
SELECT ROUND(avg_customer_lifespan * customer_value,1) AS customer_lifetime_value
FROM CustomerLifetimeValue_CTE 
;

