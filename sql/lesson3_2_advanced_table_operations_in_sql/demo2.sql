-- Рекомендації
-- 1. додавати_ в префіксі назв (легше орієнтуватись, що це не щось важливе в базі)
-- 2. додаємо в назву в закінчення своє ім’я(перша літера) і прізвище
drop table if exists __users_mlysenko2
;

create table __users_mlysenko2 (
  user_id   int,
  user_name varchar,
  email     varchar
)
;

select * from __users_mlysenko2
;

insert into __users_mlysenko2 (user_id,user_name,email)
values (1,'John','jo@gmail.com')
;

insert into __users_mlysenko2 (user_id,user_name,email)
values (2,'Marie','mar@gmail.com'),
       (3,'Lily','lily@gmail.com')
;

update __users_mlysenko2
set  email = 'mar2@gmail.com'
where user_id = 2
;

-- можемо одним запитом оновлювати одразу декілька колонок
update __users_mlysenko2
set is_deleted = true,
    user_name  = 'Maryana',
    email      = 'mar3@gmail.com'
where user_id = 2
;

-- "hard delete"
delete from __users_mlysenko2
where user_id = 1
;

-- "soft delete"
alter table __users_mlysenko2 
add column is_deleted boolean  default false
;

update __users_mlysenko2
set is_deleted = true
where user_id = 3
;

select * 
from __users_mlysenko2
;
-------------------------------------
-- могли б створити помітку не тільки типа булеан
alter table __users_mlysenko2 
add column is_bad  char  default 'N'
;

update __users_mlysenko2
set is_bad = 'Y'
where user_id = 3
;

-------------------------------------
-- приклад на видалення дублів з таблиці
insert into __users_mlysenko2 (user_id,user_name,email)
values (1,'John','jo@gmail.com')
;
insert into __users_mlysenko2 (user_id,user_name,email)
values (1,'John','jo@gmail.com')
;
insert into __users_mlysenko2 (user_id,user_name,email)
values (1,'John','jo@gmail.com')
;

with deduplicate_tab as (
 select * 
 from __users_mlysenko2
 union 
 select * 
 from __users_mlysenko2
)
select * 
into __users_mlysenko3
from deduplicate_tab
;

drop table if exists __users_mlysenko2
;

select * 
into __users_mlysenko2
from __users_mlysenko3
;

select * 
from __users_mlysenko2
;

-- коли все відтестили, то аби не залишати "сміття" в БД видаляємо СВОЮ табличку (не пробувати з чужими таблицями)
drop table if exists __users_mlysenko2
;

drop table if exists __users_mlysenko3
;
