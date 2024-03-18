-- Все  - "таблички"
select 'Hello, world!' as message
;

select now()
;

select 1
;
--------------------------------------------
-- Subquery (підзапити)
select *
from (select 1) as t -- для підзвпита обовязково в частиті from дати аліас
;

select *
from (select 1) t
where true in (select true)
;

-- Subquery with tab example
-- спочатку розберемо саму табличку з підзапиту
select 
  ad_date,
  campaign_name,
  sum(spend) as daily_spend
from google_ads_basic_daily
group by 1, 2
;   
     
 -- приклад з підзапитом і табл    
select 
  campaign_name,
  avg(daily_spend) as avg_daily_spend
from (select 
        ad_date,
        campaign_name,
        sum(spend) as daily_spend
       from google_ads_basic_daily
       group by 1, 2) as campaign_daily_spend
group by 1
;

select * 
from facebook_campaign
limit 100
;

-- приклад з підзапитом в колонці
select  
  distinct campaign_id,
  (select distinct campaign_name
   from facebook_campaign t2
   where t1.campaign_id = t2.campaign_id) campaign_name
from facebook_ads_basic_daily as t1
where campaign_id is not null
;

-- приклад з підзапитом в where
select *
from facebook_ads_basic_daily fabd
where campaign_id in (select distinct campaign_id
                      from facebook_campaign fc)
;

--------------------------------------------
-- CTE

with common_table as (
 select 1 as num, 'a' as letter
),
common_table2 as (
 select 2 as num, 'b' as letter
)
select *
from common_table
where 1 in (select num from common_table)
;

with fb as (
 select 
   ad_date ,
   campaign_id,
   value 
 from facebook_ads_basic_daily fabd 
),
google as (
  select 
    ad_date , 
    campaign_name,  
    value
  from google_ads_basic_daily gabd 
  where campaign_name in ('New items', 'Hobbies')
)
select
  sum(fb.value)
from fb 
where fb.ad_date in (select distinct ad_date from  google)
;

--------------------------------------------
-- Q&A 

--При виконані підзапиту : 
SELECT *
FROM (select 1 ) AS table_name
; 
--Видає помилку на : (), якщо їх забрати пише, що таблички subquery не існує.
-- subquery має бути фактичним підзапитом (наприклад замінила на select 1)


--Поясніть, будь ласка, звідки взялось department_salary в запиті, де його можно побачити і чому воно повинно бути?
--Запит:
SELECT ROUND(AVG(average_salary), 0)
FROM (SELECT 
        AVG(salary) AS average_salary
      FROM "HR".employees
      GROUP BY department_id) as t1
; 
-- то просто аліас, обовязково маємо давати табличці в блоці where якщо формуємо її підзапитом.
-- можна дати будь яку свою, наприклад замінила на t1            
            
          
 -- коли даємо аліаси колонкам           
 SELECT 
	employee_id,
	first_name,
	last_name,
	salary,
	(SELECT ROUND(AVG(salary), 0)FROM "HR".employees) as average_salary,
	salary - (SELECT ROUND(AVG(salary), 0) FROM "HR".employees) as difference
FROM "HR".employees
ORDER BY first_name, last_name
;            


select
  round(5.23434639587),
  round(5.23434639587,2),
  round(5.23434639587,0)
;

--------------------------------------------
-- union

-- Ad_date, traffic_source (facebook/ google), value_sum 
with fb as (
  select 
    ad_date ,
    'facebook' as traffic_source,
    sum(value) as value_sum,
    sum(spend) as spend_sum
  from facebook_ads_basic_daily fabd 
  where ad_date is not null
  group by ad_date
),
google as (
  select 
    'google'      as traffic_source,
    ad_date ,
    sum(value) as value_sum,
    sum(spend) as spend_sum
  from google_ads_basic_daily
  where ad_date is not null
  group by ad_date
),
common_tab as (	
  select * from fb
  union all
  select ad_date, traffic_source,  value_sum, spend_sum from google
)
select
  ad_date, 
  sum(value_sum) as value_sum,
  sum(spend_sum) as spend_sum
into ad_results_by_date -- записуємо результат запиту в таблицю ad_results_by_date
from common_tab
group by ad_date
;

select * 
from ad_results_by_date
;

-- видалення таблиці в базі даних
-- drop table if exists ad_results_by_date
;

-- в union теж можна багато таблиць писати
select 1 as "number", 'a' as letter
union all
select 1 as "number", 'b' as letter
union all
select 1 as "number", 'c' as letter
union all
select 1 as "number", 'd' as letter
 ;                   

--------------------------------------------
-- VIEW
CREATE VIEW employees_details_mlysenko AS
select 
  employee_id, 
  first_name, 
  last_name, 
  department_id
FROM "HR".employees e
;

-- далі можна працювати з в'ю як звичайною таблицею
select * 
from employees_details_mlysenko
;


--------------------------------------------
-- Використання ALTER для зміни структури таблиці

select *
from ad_results_by_date;

-- додати колонку
alter table ad_results_by_date
add column roi numeric;

-- оновити значення в колонці
update ad_results_by_date
set roi = round(value_sum::numeric/spend_sum , 2)
where spend_sum>0
;

-- переіменувати колонку
alter table ad_results_by_date
rename column ad_date to advertisment_date
;

-- змінити тип колонки
alter table ad_results_by_date
alter column spend_sum type numeric
;

-- видалити колонку з таблиці
alter table ad_results_by_date
drop column roi 
;

-- очистити таблицю (перед перезаписом)
truncate table ad_results_by_date
;

select * 
from ad_results_by_date
;

--------------------------------------------
-- Q&A 
-- шукаємо табличку через інформаційну схему
SELECT *
  FROM information_schema.tables
 where table_name like '%employees%';
 

-- певдокод до домашки
/*
with all_ad_data as (
select ... facebook_ads_basic_daily 
union 
select .... google_ads_basic_daily
)
select ...
from all_ad_data
group by 
...
*/
