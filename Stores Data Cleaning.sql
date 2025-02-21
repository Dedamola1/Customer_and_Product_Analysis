USE db_schema;

-- Duplicating customers table for cleaning
CREATE TABLE customers_new
LIKE customers;

SELECT *
FROM customers_new;

INSERT customers_new
SELECT *
FROM customers;

-- Duplicating offices table for cleaning
CREATE TABLE offices_new
LIKE offices;

SELECT *
FROM offices_new;

INSERT offices_new
SELECT *
FROM offices;

-- Duplicating orders table for cleaning
CREATE TABLE orders_new
LIKE orders;

SELECT *
FROM orders_new;

INSERT orders_new
SELECT *
FROM orders;

-- Duplicating productlines table for cleaning
CREATE TABLE productlines_new
LIKE productlines;

SELECT *
FROM productlines_new;

INSERT productlines_new
SELECT *
FROM productlines;

-- Duplicating productlines table for cleaning
CREATE TABLE products_new
LIKE products;

SELECT *
FROM products_new;

INSERT products_new
SELECT *
FROM products;

-- Duplicating employees table for cleaning
CREATE TABLE employees_new
LIKE employees;

SELECT *
FROM employees_new;

INSERT employees_new
SELECT *
FROM employees;


-- Cleaning new customers table
ALTER TABLE customers_new
DROP COLUMN state,
DROP COLUMN phone,
DROP COLUMN addressline2;

-- Cleaning new offices table
ALTER TABLE offices_new
DROP COLUMN addressline2,
DROP COLUMN state;

UPDATE offices_new
SET territory = 'APAC'
WHERE country = 'Japan';

UPDATE offices_new
SET territory = 'North America'
WHERE country = 'USA';

-- Cleaning new orders table
ALTER TABLE orders_new
DROP COLUMN comments;

-- Cleaning new productlines table
ALTER TABLE productlines_new
DROP COLUMN htmldescription,
DROP COLUMN image;

-- Cleaning new products table
ALTER TABLE products_new
DROP COLUMN productdescription;

-- Cleaning new employees table
UPDATE employees_new
SET `jobTitle` = 'Sales Manager (EMEA)'
WHERE `employeeNumber` = 1102;

-- Removing Duplicates within Tables
-- Customers table
WITH customers_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY customerNumber, customerName, contactFirstName, contactLastName) AS Row_Num
    FROM customers_new
)
SELECT *
FROM customers_CTE
WHERE Row_Num > 1;

-- Orderdetails table
WITH orderdetails_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY orderNumber, productCode, orderLineNumber) AS Row_Num
    FROM orderdetails
)
SELECT *
FROM orderdetails_CTE
WHERE Row_Num > 1;

-- Orders table
WITH orders_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY orderNumber, customerNumber) AS Row_Num
    FROM orders_new
)
SELECT *
FROM orders_CTE
WHERE Row_Num > 1;

-- Payments table
WITH payments_CTE AS (
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY customerNumber, checkNumber) AS Row_Num
    FROM payments
)
SELECT *
FROM payments_CTE
WHERE Row_Num > 1;
