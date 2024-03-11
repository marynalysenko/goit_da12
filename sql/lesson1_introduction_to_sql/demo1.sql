select *
from facebook_ads_basic_daily fabd 
;

-- Перевіряю к-сть записів в таблиці
select count(*)
from facebook_ads_basic_daily
;

select *
from public.facebook_ads_basic_daily fabd 
limit 100 -- завжди коли просто для себе знайомимось з даними залишаємо це обмеження
;

select  campaign_id, 
        campaign_name 
from public.facebook_campaign fc 
where campaign_name = 'Electronics'
;

/*
select *
from public.facebook_ads_basic_daily fabd 
where spend > 50000
order by spend desc, leads
limit 10
;
*/

select ad_date , 
	   spend, -- витрати на рекламу
	   clicks , 
	   'auto' as write_mode,  
	   round( ( spend  / ( impressions * 1.0)*100.0),2)  as new_number
from public.facebook_ads_basic_daily fabd 
where spend > 50000 and clicks > 100 and impressions >10000
order by spend desc, leads
limit 10
;