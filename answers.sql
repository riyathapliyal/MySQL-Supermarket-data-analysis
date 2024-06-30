##### Supermarket SQL Project  

CREATE DATABASE supermarket;

USE supermarket;

CREATE TABLE aisles(
aisle_id INT(11),
aisle VARCHAR(100) NOT NULL,
PRIMARY KEY(aisle_id)
);

CREATE TABLE departments(
department_id INT(11),
department VARCHAR(30) NOT NULL,
PRIMARY KEY(department_id)
);

CREATE TABLE product(
product_id INT(11),
name VARCHAR(200) NOT NULL,
aisle_id INT(11) NOT NULL,
department_id INT(11) NOT NULL,

PRIMARY KEY(product_id),

FOREIGN KEY(aisle_id)
	REFERENCES aisles(aisle_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    
FOREIGN KEY(department_id)
	REFERENCES departments(department_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);

CREATE TABLE orders(
order_id INT(11),
user_id INT(11) NOT NULL,
eval_set VARCHAR(10) NOT NULL,
order_number INT(11) NOT NULL,
order_dow INT(11),
order_hour_of_day INT(11),
days_since_prior_order INT(11),
PRIMARY KEY(order_id)
);

CREATE TABLE order_product(
order_id INT(11) NOT NULL,
product_id INT(11) NOT NULL,
add_to_cart_order INT(11) NOT NULL,
reordered INT(11) NOT NULL,

FOREIGN KEY(order_id)
	REFERENCES orders(order_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    
FOREIGN KEY(product_id)
	REFERENCES product(product_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
);

###########################  DML ############################

## Importing the Data

LOAD DATA LOCAL INFILE 'C:/Users/hp/Desktop/supermarket-data-analysis/aisles.csv' INTO TABLE aisles
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/hp/Desktop/supermarket-data-analysis/departments.csv' INTO TABLE departments
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/hp/Desktop/supermarket-data-analysis/orders.csv' INTO TABLE orders
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/hp/Desktop/supermarket-data-analysis/products.csv' INTO TABLE product
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/hp/Desktop/supermarket-data-analysis/order_products.csv' INTO TABLE order_product
FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES;




# Q1). top 10 products that the users have the most frequent reorder rate

SELECT product_id
FROM order_product
GROUP BY product_id
ORDER BY sum(reordered)/count(*) DESC
LIMIT 10;


# Q2).Calculate the % of order for Sunflower Bread

SELECT 
    (COUNT(DISTINCT order_id) / (SELECT COUNT(DISTINCT order_id) FROM order_products) * 100) AS percentage_orders_Sunflower_Bread
FROM order_products op
JOIN products p ON op.product_id = p.product_id
WHERE p.product_name = 'Sunflower Bread';



# Q3). most popular shopping path
SELECT aisles, COUNT(*) AS count FROM
	(SELECT order_id, GROUP_CONCAT(DISTINCT(a.id) ORDER BY a.id SEPARATOR ' ') as aisles
	FROM order_product AS op
	INNER JOIN product AS p ON op.product_id=p.id
    INNER JOIN aisles AS a ON p.aisle_id=a.id
	GROUP BY op.order_id
    HAVING COUNT(DISTINCT(a.id))>=2 ) AS t
GROUP BY aisles
ORDER BY count DESC ;


# Q4). top pairwise associations in products

SELECT p1.name as product1 ,p2.name as product2
FROM
	(SELECT  op1.product_id AS product1, op2.product_id AS product2, COUNT(*) AS count
	FROM order_product AS op1 INNER JOIN
	order_product AS op2 ON op1.order_id=op2.order_id
	WHERE op1.product_id<op2.product_id
	GROUP BY op1.product_id,op2.product_id
	ORDER BY count DESC
	LIMIT 100 ) AS t
INNER JOIN product AS p1 ON t.product1=p1.id
INNER JOIN product AS p2 ON t.product2=p2.id;

# Q5). Top 5 most frequently purchased orders

SELECT p.product_name, COUNT(op.product_id) AS purchase_count
FROM order_products op
JOIN products p ON op.product_id = p.product_id
GROUP BY op.product_id
ORDER BY purchase_count DESC
LIMIT 5;

# Q6). Determine the average number of products per order

SELECT AVG(product_count) AS average_products_per_order
FROM (
    SELECT order_id, COUNT(product_id) AS product_count
    FROM order_products
    GROUP BY order_id
) subquery;

# Q7). Find the department with highest number of unique product

SELECT d.department_name, COUNT(DISTINCT p.product_id) AS unique_product_count
FROM products p
JOIN departments d ON p.department_id = d.department_id
GROUP BY d.department_name
ORDER BY unique_product_count DESC;

# Q8). shopper’s aisle list for each order

SELECT op.order_id, a.id as aisle_id
FROM order_product AS op
INNER JOIN aisles AS a ON op.product_id=a.id
GROUP BY op.order_id, a.id;


# Q9). List Top 3 orders frequently purchased together

SELECT p1.product_name AS product_1, p2.product_name AS product_2, COUNT(*) AS times_purchased_together
FROM order_products op1
JOIN order_products op2 ON op1.order_id = op2.order_id AND op1.product_id < op2.product_id
JOIN products p1 ON op1.product_id = p1.product_id
JOIN products p2 ON op2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
ORDER BY times_purchased_together DESC
LIMIT 3;


