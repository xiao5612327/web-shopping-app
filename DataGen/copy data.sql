COPY states(name) 
FROM '/Users/xiaopingweng/Desktop/cse135/cse135_p3/DataGen/states.txt' DELIMITER ',' CSV;

COPY users(name, role, age, state_id) 
FROM '/Users/xiaopingweng/Desktop/cse135/cse135_p3/DataGen/users.txt' DELIMITER ',' CSV;

COPY categories(name, description) 
FROM '/Users/xiaopingweng/Desktop/cse135/cse135_p3/DataGen/categories.txt' DELIMITER ',' CSV;

COPY products(name, sku, category_id, price, is_delete) 
FROM '/Users/xiaopingweng/Desktop/cse135/cse135_p3/DataGen/products.txt' DELIMITER ',' CSV;

COPY orders(user_id, product_id, quantity, price, is_cart) 
FROM '/Users/xiaopingweng/Desktop/cse135/cse135_p3/DataGen/orders.txt' DELIMITER ',' CSV;

