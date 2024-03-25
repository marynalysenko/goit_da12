-- data for source creating 
 with fb_ads_data as (
         select fabd.ad_date, 
                                  fc.campaign_name, 
                                  fa.adset_name, 
                                  fabd.spend, 
                                  fabd. impressions, 
                                  fabd. reach, 
                                  fabd.clicks,
                                  fabd .value 
        from facebook_ads_basic_daily fabd
        left join facebook_adset fa on fa.adset_id = fabd.adset_id
        left join facebook_campaign fc on fc.campaign_id = fabd. campaign_id
)
select 
                ad_date,
                campaign_name,
                round(sum(spend)::numeric/100, 2) as total_spend, -- центи перевела в долари
                sum (impressions) as total_impressions,  -- 
                sum(clicks) as total_clicks,
                round (sum (value)::numeric/100, 2) as total_value
from fb_ads_data
group by 1,2
having campaign_name is not null
order by campaign_name, ad_date
;