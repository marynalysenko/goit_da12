-- Рекомендації
-- 1. додавати_ в префіксі назв (легше орієнтуватись, що це не щось важливе в базі)
-- 2. додаємо в назву в закінчення своє ім’я(перша літера) і прізвище

create table __users_mlysenko (
		user_id int,
		user_name varchar,
		email varchar
)
;

select * from __users_mlysenko
;

insert into __users_mlysenko (user_id,user_name,email)
values (1,'John','jo@gmail.com')
;

insert into __users_mlysenko (user_id,user_name,email)
values (2,'Marie','mar@gmail.com'),
			 (3,'Lily','lily@gmail.com')
;

update __users_mlysenko
set  email = 'mar2@gmail.com'
where user_id = 2
;

delete from __users_mlysenko
where user_id = 1
;

-- коли все відтестили, то аби не залишати "сміття" в БД видаляємо СВОЮ табличку (не пробувати з чужими таблицями)
drop table if exists __users_mlysenko
;

-- звернення до таблиці employees в схемі HR. Звертаємось з "", тільки тому що схема названа з порушенням правил назви
select *
from "HR".employees e 
limit 100
;