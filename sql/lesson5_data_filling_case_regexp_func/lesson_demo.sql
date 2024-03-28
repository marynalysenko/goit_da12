-- Регулярні вирази
-- дод матеріали по регулярним виразам https://docs.google.com/document/d/1BfnKEcrJ0ueUam-MPLRyUZyc2TUOzERHqAjFiRRComs/edit

-- перевірити на відповідність шаблону
select 
  'example@gmail.com' ~ '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9_.+-]+\.[a-zA-Z0-9_.+-]'
;

-- замінити частину тексту
select
	url_parameters ,
	regexp_replace(url_parameters, 'utm_medium=(cpc)', 'utm_medium=ppc')
from facebook_ads_basic_daily fabd
;

--дістати частину тексту
select 
	url_parameters,
	substring(url_parameters, 'utm_medium=([^&#$]+)') as utm_medium
from facebook_ads_basic_daily fabd;


select 
	substring(url_parameters, 'utm_medium=([^&#$]+)') as utm_medium,
	count(*)
from facebook_ads_basic_daily fabd
group by 1;


select 
	lower( substring(url_parameters, 'utm_medium=([^&#$]+)'))    as utm_medium,
	lower( substring(url_parameters, 'utm_source=([^&#$]+)'))      as utm_source,
	lower( substring(url_parameters, 'utm_campaign=([^&#$]+)')) as utm_campaign,
	count(*)
from facebook_ads_basic_daily fabd
group by 1,2,3
order by 4
;

-- використання like 
select 
	url_parameters
from facebook_ads_basic_daily fabd
where url_parameters like '%utm_medium=cpc%'
;

-- використання case when для умови
select 
	url_parameters ,
	case when lower( substring(url_parameters, 'utm_medium=([^&#$]+)')) = 'cpc' then 'error'
			  when lower( substring(url_parameters, 'utm_medium=([^&#$]+)')) is null  then 'no utm param'
			  else 'ok' end  as check_res
from facebook_ads_basic_daily
;

select 
	ad_date,
	campaign_id,
	adset_id,
	case when value < 100 then 'low'
			  when value >= 100 and value < 10000 then 'middle'
			  when value>= 10000 then 'top'
			  else 'unkown' end as value_category
from facebook_ads_basic_daily
;

----- Homework 2 with case  щоб не втрачати інформацію -----
select 
	ad_date, 
	campaign_id, 
	sum(spend)                                                                                                                                           as total_spend, 
	sum(impressions)                                                                                                                                 as total_impressions,
	sum(clicks)                                                                                                                                            as total_clicks,
	sum(value)                                                                                                                                             as total_value,
	case when sum(clicks)> 0 then  sum(spend)/sum(clicks) else -1 end                                       as cpc,
	case when sum(impressions)>0 then  1000*sum(spend)/sum(impressions)  else -1 end      as cpm,
	case when sum(impressions)>0 then sum(clicks)::numeric/sum(impressions)  else -1 end  as ctr,
	case when sum(spend)>0 then sum(value)::numeric/sum(spend)  else -1 end                       as romi
from facebook_ads_basic_daily fabd 
group by ad_date, campaign_id
order by ad_date desc
;

-- застосування coalesce для заповнення пропусків
select 	
    ad_date, 
	campaign_id, 
	coalesce(leads, 0) as leads,
	coalesce(clicks,0) as clicks
from facebook_ads_basic_daily
;


-- more for coalese 
drop table if exists sales_mlysenko2;

CREATE TABLE sales_mlysenko2 (
    order_date DATE,
    ship_date DATE,
    delivery_date DATE,
    return_date DATE
);

INSERT INTO sales_mlysenko2 (order_date, ship_date, delivery_date, return_date)
VALUES
    ('2023-01-01', '2023-01-05', '2023-01-10', NULL),
    ('2023-01-02', '2023-01-06', NULL, '2023-01-15'),
    ('2023-01-03', NULL, '2023-01-11', '2023-01-20'),
    ('2023-01-04', '2023-01-08', NULL, NULL);
      
 SELECT 
    order_date,
    COALESCE(ship_date, delivery_date, return_date) AS actual_date_coalesce
FROM sales_mlysenko2;  
   
SELECT 
    order_date,
    COALESCE(ship_date, delivery_date, return_date) AS actual_date_coalesce,
    ISNULL(ship_date::date, now()::date) AS ship_date_isnull,
    ISNULL(delivery_date::date, now()::date) AS delivery_date_isnull,
    ISNULL(return_date::date, now()::date) AS return_date_isnull
FROM sales_mlysenko2
;


-------------------------------------------------------------------------------
-- Ця функція буде декодувати URL-параметри, використовуючи регулярні вирази, та повертати результат у форматі UTF-8. Вона може бути використана для розкодування URL-параметрів у базі даних.
-- робить теж саме, що подібні сервіси https://www.urldecoder.org/
				
-- CREATE OR REPLACE FUNCTION: Це ключове слово SQL для створення нової функції або заміни існуючої функції. 
-- OR REPLACE вказує на те, що якщо функція з такою ж назвою вже існує, вона буде замінена новою.
-- pg_temp.decode_url_part: Це назва функції разом із її схемою. pg_temp вказує на те, що ця функція буде створена в тимчасовій схемі бази даних. decode_url_part - це назва функції.
--(p varchar) RETURNS varchar: Ця частина визначає вхідний параметр функції та тип даних, який функція повертає. У цьому випадку p - це вхідний параметр типу varchar, а функція повертає значення типу varchar.
-- $$: Це роздільник між тілом функції та її визначенням.
-- Ключове слово LANGUAGE SQL вказує, що функція написана мовою SQL.
I-- MMUTABLE вказує на те, що функція завжди повертає той самий результат для однакових вхідних параметрів, що може оптимізувати запити. 
-- STRICT вказує, що функція повинна повертати NULL, якщо будь-який з її вхідних параметрів дорівнює NULL.
-- string_agg - конвертування у формат bytea (байтовий рядок)
-- convert_from(...): Ця частина конвертує байтовий рядок у рядок UTF-8, що є зрозумілим для більшості додатків та користувачів.
CREATE OR REPLACE FUNCTION pg_temp.decode_url_part(p varchar) RETURNS varchar AS $$
select
  convert_from(CAST(E'\\x' || string_agg(CASE WHEN length(r.m[1]) = 1 THEN encode(convert_to(r.m[1], 'SQL_ASCII'), 'hex') ELSE substring(r.m[1] from 2 for 2) END, '') AS bytea), 'UTF8')
FROM regexp_matches($1, '%[0-9a-f][0-9a-f]|.', 'gi') AS r(m);--розбиття рядка на окремі символи та їх кодування
$$ LANGUAGE SQL IMMUTABLE STRICT;
-- Рядок для виклику функції для розкодування URL-параметрів, винувати разом з попереднім запитом
select 
  decode_url_part(url_parameters) 
from facebook_ads_basic_daily fabd
;
-- приклад 2 та частина коду з Q&A
CREATE OR REPLACE FUNCTION pg_temp.decode_url_part(p varchar) RETURNS varchar AS $$
select
  convert_from(CAST(E'\\x' || string_agg(CASE WHEN length(r.m[1]) = 1 THEN encode(convert_to(r.m[1], 'SQL_ASCII'), 'hex') ELSE substring(r.m[1] from 2 for 2) END, '') AS bytea), 'UTF8')
FROM regexp_matches($1, '%[0-9a-f][0-9a-f]|.', 'gi') AS r(m);
$$ LANGUAGE SQL IMMUTABLE STRICT;
select 
  	ad_date,
	url_parameters,
	lower(substring(decode_url_part(url_parameters) , 'utm_campaign=([^\&]+)')) as campaign,
	case
		when lower(substring(url_parameters, 'utm_campaign=([^\&]+)')) != 'nan' 
					then lower(substring(decode_url_part(url_parameters) , 'utm_campaign=([^\&]+)'))
	end as utm_campaign_fixed
from facebook_ads_basic_daily fabd

-------------------------------------------------------------------------------
-- Q&A - опис - це?
SELECT * 
FROM "HR".employees
WHERE "опис" ~* 'manager'
-- просто криво названа в БД колонка, викликаємо взявши в лапки подвійні

-- але таблицю вам залили криво і тут немає даних на які подивитись 
SELECT * 
FROM "HR".employees
WHERE "опис" is not null 

-- різниця CONCAT і concat_ws() в додаванні роздільника (довільний) між частинами текста 
SELECT CONCAT( 'Hello', ' ', 'World', '!');
SELECT CONCAT_WS('....', 'Hello', ' ', 'World', '!');
SELECT CONCAT_WS(' ', 'apple', 'banana', 'orange');

--використання trim
SELECT 
  LTRIM('   Hello   ')  AS ltrim_result, 
  RTRIM('   Hello   ') AS rtrim_result,
  TRIM( '  Hello   ')    AS trim_result
;


SELECT 
  length('   Hello   ') as len_result,
  length(LTRIM('   Hello   ')) AS len_ltrim_result, 
  length(RTRIM('   Hello   ')) AS len_rtrim_result,
  length(TRIM( '  Hello   ') )   AS len_trim_result
 ; 
 
-- concat текста з числом
select concat('dihit is ' ,7)
;