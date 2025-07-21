{{ config(
    materialized = 'view',
    schema = 'mart_schema'
) }}

with temp as (
select 
ev.firm_id,
count(*) over (partition by ev.firm_id) firm_query_count,
round(firm_query_count*100/(count(ev.*) over()),1) firm_query_usage_vs_allfirms_percent,
count(distinct ev.user_id) over (partition by ev.firm_id) query_users,
count(distinct ev.created) over (partition by ev.firm_id) query_days,
max(ev.created) over (partition by ev.firm_id) - min(ev.created) over (partition by ev.firm_id) active_days,
sum(ev.num_docs) over(partition by ev.firm_id) num_docs_firm,
round(query_days/active_days,1) user_activity_intensity,
round(firm_query_count/query_days,0) queries_per_day,
round(firm_query_count/query_users,0) query_per_user,
round(num_docs_firm/query_users,0) docs_per_user,
round(avg(ev.feedback_score) over (partition by ev.firm_id),1) avg_feedback,
max(f.arr_in_thousands) over (partition by ev.firm_id) firm_arr_in_thousands,
round(100*count(case when title='Junior Associate' then user_id end) over(partition by ev.firm_id)/(count(ev.*) over()),1) junior_associate_firm_queries,
round(100*count(case when title='Senior Associate' then user_id end) over(partition by ev.firm_id)/(count(ev.*) over()),1) senior_associate_firm_queries,
round(100*count(case when title='Partner' then user_id end) over(partition by ev.firm_id)/(count(ev.*) over()),1) partner_firm_queries,
round(100*count(case when title='Associate' then user_id end) over(partition by ev.firm_id)/(count(ev.*) over()),1) associate_firm_queries,
round(firm_arr_in_thousands*1000/query_users,1) avg_annual_revenue_per_user_in_dollars,
min(ev.created) over (partition by ev.firm_id) - f.created as minimum_days_before_firms_first_user_activity,
from events ev join firms f 
on ev.firm_id = f.id
)

select * from temp group by all