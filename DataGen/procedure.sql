select s.name AS state, p.id, COALESCE(SUM(o.price), 0) AS sum
from users u
RIGHT OUTER JOIN states s 
ON s.id = u.state_id 
cross join (
		select * 
		from products p
		where p.category_id >0
		) as p
INNER JOIN 
(select s.name as state, COALESCE(SUM(a.price), 0) AS sum
from users u 
left outer join(
		select o.user_id, o.price, o.quantity
		from orders o 
		join products p
		on o.product_id = p.id AND p.category_id > 0
		) AS a
ON u.id = a.user_id
right outer join states s 
ON s.id = u.state_id 
GROUP BY s.name
ORDER BY sum DESC, s.name
LIMIT 50) l
ON l.state = s.name
INNER JOIN 
(select p.id, p.name AS product_name, COALESCE(SUM(o.price), 0) AS sum
from (
	select * 
	from products p
	where p.category_id > 0
	) as p
LEFT OUTER JOIN orders o 
ON p.id = o.product_id
LEFT OUTER JOIN users u
ON u.id = o.user_id
GROUP BY p.id,  p.name
ORDER BY sum DESC 
LIMIT 50) r 
ON r.id = p.id
LEFT OUTER JOIN orders o 
ON o.product_id = p.id and o.user_id = u.id
group by s.name, p.id, p.name, l.sum, r.sum
order by l.sum DESC, state, r.sum DESC, SUM DESC