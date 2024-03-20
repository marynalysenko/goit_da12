-- найчастіший випадок - дотягнути розшифровку з довідника
select
  fabd.*, 
  fc.campaign_name
from facebook_ads_basic_daily fabd 
join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
;

-- можемо джойнити одразу декілька таблиць і за багатьма умовами
select 
  fc.campaign_name,
  fa.adset_name,
  fabd.ad_date,
  fabd.spend   as facebook_spends,
  gabd.spend   as google_spends
from facebook_ads_basic_daily fabd 
join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
join facebook_adset fa    on fabd.adset_id = fa.adset_id
join google_ads_basic_daily gabd on gabd.ad_date = fabd.ad_date 
	and gabd.campaign_name = fc.campaign_name 
	and gabd.adset_name = fa.adset_name 
;

select * 
from facebook_campaign fc 
;

select * from facebook_adset fa 
;

select *
from google_ads_basic_daily gabd
;

-------------------------------------
-- Порвіняти для кампейнів суму витрат (спробувати з різними типа джойна)

with facebook as (
  select 
      fc.campaign_name,
      sum(fabd.spend ) as total_spend
  from facebook_ads_basic_daily fabd 
  left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
  where fabd.campaign_id is not null 
  group by fc.campaign_name -- 11
),
google as (
  select 
      campaign_name,
      sum(spend) as total_spend
  from google_ads_basic_daily gabd 
  group by campaign_name -- 9
)
select 
  t1.campaign_name   as fb_campaign_name, 
  t1.total_spend     as fb_total_spend,
  t2.campaign_name   as gl_campaign_name, 
  t2.total_spend     as gl_total_spend
from facebook as t1
full join google as t2 on t1.campaign_name = t2.campaign_name
;

-- приклад cross join  з таблицями
with work_calendar as (
select 
 generate_series('2024-01-01', '2024-12-31', '1 day'::interval)::date as calendar_date 
)
select  
  t2.calendar_date,
  t1.first_name,
  t1.last_name 
from "HR".employees as t1
cross join work_calendar as t2
;

-- таблиця з колонкою з складною структурою
select 
  'Maryna' as user, 		
  array[1,5,7]  as promos
  union
  select 
  'Iryna' as user, 		
  array[2,5,19]  as promos
 ; 
  
-- cross join для розкладання складної структури на рядочки
with tab as (
 select 
  'Maryna' as user, 		
  array[1,5,7]  as promos
  union
  select 
  'Iryna' as user, 		
  array[2,5,19]  as promos
)
select  t1.user, t2		
from 	tab as t1
cross join unnest(promos) as t2 -- unnest(arr) розбиває масив arr на окремі ряди
;

----------------
/*
Під час виконання ДЗ до цього блоку 3.2 необхідно об`єднати дані з 3-х таблиць Facebook, 
але потім зробити обєднану таблицю із даними Google. 
Чи можу я обєднати дані Facebook шляхом використання команди Join,
а Google додати через Union? 
*/

-- Знайти кампанії з найбільшими витратами за весь час
with all_ad_results as (
    select 
      fc.campaign_name,
      fa.adset_name,
      fabd.ad_date,
      fabd.spend,
      'facebook' as ad_source
    from facebook_ads_basic_daily as fabd 
    left join facebook_campaign   as fc on fc.campaign_id = fabd.campaign_id 
    left join facebook_adset      as fa on fabd.adset_id = fa.adset_id
    where fabd.campaign_id is not null
    union all 
    select 
      campaign_name,
      adset_name,
      ad_date,
      spend,
      'google' as ad_source
    from google_ads_basic_daily gabd 
)
select 
  campaign_name, 
  sum(spend) as total_spend
from all_ad_results
group by 1
order by total_spend desc
limit 3
;

-- Знайти кампанії з найбільшими витратами за весь час, що мають позитивний ROI
with all_ad_results as (
    select 
        fc.campaign_name,
        fa.adset_name,
        fabd.ad_date,
        fabd.spend,
        fabd .value,
        'facebook' as ad_source
    from facebook_ads_basic_daily fabd 
    left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
    left join facebook_adset fa on fabd.adset_id = fa.adset_id
    where fabd.campaign_id is not null
    union all 
    select 
        campaign_name,
        adset_name,
        ad_date,
        spend,
        alue,
        'google' as ad_source
    from google_ads_basic_daily gabd 
)
select 
  campaign_name, 
  sum(spend)                     as total_spend,
  sum(value)::numeric/sum(spend) as roi
from all_ad_results
group by 1
having sum(value)::numeric/sum(spend)> 1
order by total_spend desc
limit 3
;
/*
Expansion	11361632	1.1902579664611563
Lookalike	6363109	1.2609354955258506
Electronics	4021553	1.1772780316459835
*/

-- Знайти кампанії з найбільшими витратами за весь час в Google
select 
  campaign_name,
  sum(spend) as total_spend
from google_ads_basic_daily gabd 
group by campaign_name
order by total_spend desc
limit 1
;

-- Знайти кампанії з найвищим CTR
with all_ad_results as (
    select 
        fc.campaign_name,
        fabd.clicks ,
        fabd .impressions
    from facebook_ads_basic_daily fabd 
    left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
    where fabd.campaign_id is not null
    union all 
    select 
        campaign_name,
        clicks,
        impressions
    from google_ads_basic_daily gabd 
)
select 
  campaign_name, 
  round((sum(clicks)::numeric/sum(impressions))*100.0,2) as ctr
from all_ad_results
group by 1
order by ctr desc
limit 3
;

-- Знайти кампанії з найбільшою кількістю лідів
with all_ad_results as (
    select 
        fc.campaign_name,
        fabd.leads 
    from facebook_ads_basic_daily fabd 
    left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
    where fabd.campaign_id is not null
    union all 
    select 
        campaign_name,
        eads
    from google_ads_basic_daily gabd 
)
select 
  campaign_name, 
  sum(leads) as total_leads
from all_ad_results
group by 1
order by total_leads desc
limit 3
;
