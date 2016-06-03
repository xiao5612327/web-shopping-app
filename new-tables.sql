
CREATE TABLE states_precomputed AS
SELECT st.name, st.id AS sid, SUM(s.quantity*s.price) AS price 
FROM states st 
LEFT OUTER JOIN users u 
ON st.id = u.state_id
LEFT OUTER JOIN orders s 
ON s.user_id=u.id 
GROUP BY st.id, st.name 
ORDER BY price DESC nulls last;

CREATE TABLE products_precomputed AS
SELECT p.name, p.id AS pid, p.category_id, COALESCE( SUM(s.quantity * s.price), 0 ) AS price 
FROM products p 
JOIN categories c
ON p.category_id = c.id
LEFT OUTER JOIN orders s 
ON s.product_id = p.id  
GROUP BY p.id, p.name 
ORDER BY price DESC nulls last;

CREATE TABLE cell_precomputed AS
SELECT u.state_id, s.product_id, SUM(s.quantity * s.price) 
FROM users u, orders s 
WHERE s.user_id = u.id 
GROUP BY u.state_id, s.product_id;

CREATE TABLE log_table
(
	order_id integer,
	state_id integer,
	product_id integer,
	amount integer
);

-- DON'T NEED THIS ANYMORE
--CREATE TABLE u_t
--(
--  sid integer,
--  pid integer,
--  amount integer
--);

-- DON'T NEED THIS ANYMORE
--CREATE TABLE p_u_t
--(
--  sid integer,
--  pid integer,
--  amount integer
--);

CREATE INDEX cell_product_index ON cell_precomputed(product_id);
CREATE INDEX products_id_index ON products_precomputed(pid);
CREATE INDEX products_catid_index ON products_precomputed(category_id);
CREATE INDEX states_id_index ON states_precomputed(sid);

