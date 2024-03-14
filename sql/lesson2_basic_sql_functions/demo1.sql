-- Кастування типів
select 5    					 as col1,
       5/2 					 as col2,
       5/(2*1.0) 				 as col3,
       5.0/2.0 					 as col4,
       5::numeric/2::numeric 		         as col5,
       cast(5 as numeric) / cast(2 as numeric)   as col6
;			
	
-- Кастування типів використовуючи колонки таблиці
select clicks,
       impressions, 
       clicks::numeric /  impressions  as ctr,    
       clicks / impressions            as bag_ctr
from facebook_ads_basic_daily fabd 
where impressions > 0
limit 100			
;
			
select 123, 
       cast(123 as varchar)--приведення до текстового типу
;

select now(), 
       cast(now() as date)--приведеня до дати
;

-- забаговані рядочки
select * 
from facebook_ads_basic_daily
where impressions < reach 
;

--  Розрахунок базової статистики
select count(*)                 as row_cnt,
       count(distinct ad_date)  as cnt_uniq_dates, 
       min(ad_date)             as min_date,
       max(ad_date)             as max_date,
       sum(spend)               as amt_all_spend,
       avg(spend)               as avg_ad_spend,
       sum(clicks)              as cnt_clicks,
       sum(leads)               as cnt_leads
from facebook_ads_basic_daily
;

-- Статистика в розрізі дат і кастування типів при агрегаціях
select ad_date ,
       sum(spend)                            as amt_all_spend,
       sum(clicks)                           as cnt_clicks,
       sum(value)                            as incame,
       sum(spend)/sum(clicks)                as cpc,
       sum(clicks)::numeric/sum(impressions) as ctr
from facebook_ads_basic_daily
group by ad_date
having sum(spend) > 0  -- необхідно обробити помилку ділення на нуль
order by ad_date 
;

-- Статистика по кожній даті і кампаніі
select ad_date , 
       campaign_id ,
       sum(spend)                               as amt_all_spend,
       sum(clicks)                              as cnt_clicks,
       sum(value)                               as incame,
       sum(clicks)::numeric / sum(impressions)  as ctr
from facebook_ads_basic_daily
group by ad_date, campaign_id
having sum(spend) > 0  and sum(value)  > 0 
order by ad_date, campaign_id
;

-- ще один спосіб прописати групування
select ad_date, 
       campaign_id,
       sum(spend)                               as amt_all_spend,
       sum(clicks)                              as cnt_clicks,
       sum(value)                               as incame,
       sum(clicks)::numeric / sum(impressions)  as ctr
from facebook_ads_basic_daily
group by 1,2
having sum(spend) > 0  and sum(value)  > 0 
order by ad_date 
;

-- статистика в розрізі кампанії і ще один спосіб прописати сортування
select 
       campaign_id,
       sum(spend)                               as amt_all_spend,
       sum(clicks)                              as cnt_clicks,
       sum(value)                               as incame,
       sum(clicks)::numeric / sum(impressions)  as ctr,
       sum(value)::numeric  / sum(spend)        as romi
from facebook_ads_basic_daily
group by 1 
having campaign_id is not null and sum(value)> 1000000
order by 4 desc
;

-- Q&A ROMI calculating
select ad_date,
       campaign_id ,
       sum(spend)                               as amt_all_spend,
       sum(clicks)                              as cnt_clicks,
       sum(value)                               as incame,
       sum(clicks)::numeric / sum(impressions)  as ctr,
       sum(value)::numeric  / sum(spend)        as romi
from facebook_ads_basic_daily
group by 1 ,2
having sum(spend) >0
order by romi , campaign_id desc
;

-- Q&A різниця між IN та OR
select ad_date,
       campaign_id ,
       spend,
       leads 
from facebook_ads_basic_daily
where  leads in (1,2,3,10,12,45) or spend > 100
;

-- це все можна переписати і через or
-- але буде купа зайвого коду і так не роблять для перевірки списка значень
select  ad_date,
       campaign_id ,
       spend,
       leads 
from facebook_ads_basic_daily
where  leads = 1 or leads =2 or leads =3  or leads =10  or leads =12  or leads =45  or spend > 100
;

-- Q&A  перевірка доступу до таблички employees
SELECT * 
FROM  "HR".employees
;
