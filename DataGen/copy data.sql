select u.name, u.role, u.age, s.name
from states s, users u
where s.id = u.state_id
order by s.id