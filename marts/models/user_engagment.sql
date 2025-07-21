{{ config(
    materialized = 'view',
    schema = 'mart_schema'
) }}

with initial_dataset as (

select 
user_id,
monthname(date_trunc(month,ev.created))||' '||year(date_trunc(month,ev.created)) event_month,
count(*) query_counts,
max(ev.created) last_active_date_in_month,
count(distinct ev.created) active_days,
round(query_counts/active_days,1) query_counts_per_day,
max(ev.created) - min(ev.created) days_activity_spread_across_month,
sum(ev.num_docs) monthly_num_docs_pulled,
round(avg(ev.num_docs),0) avg_monthly_num_docs_pulled_per_query,
round(sum(ev.num_docs)/active_days,0) docs_per_day,
round(avg(ev.feedback_score),1) avg_monthly_feedback,
max(ev.created) - max(u.created) user_age_days_in_that_month,
count(case when ev.event_type='WORKFLOW' then ev.user_id end) workflow_events,
count(case when ev.event_type='VAULT' then ev.user_id end) vault_events,
count(case when ev.event_type='ASSISTANT' then ev.user_id end) assistant_events,
count(case when ev.event_type='KNOWLEDGE' then ev.user_id end) knowledge_events,
round(avg(case when ev.event_type = 'WORKFLOW' then ev.feedback_score end),1) as workflow_feedback,
round(avg(case when ev.event_type = 'VAULT' then ev.feedback_score end),1) as vault_feedback,
round(avg(case when ev.event_type = 'ASSISTANT' then ev.feedback_score end),1) as assistant_feedback,
round(avg(case when ev.event_type = 'KNOWLEDGE' then ev.feedback_score end),1) as knowledge_feedback
from events ev join users u on ev.user_id = u.id
group by all )

select 
user_id,
event_month,
query_counts,
ntile(3) over(order by query_counts desc) ntile_3_buckets, 
case 
when 
ntile_3_buckets = 1 
or 
lag(user_id) over(partition by user_id order by last_active_date_in_month asc) is not null
and 
(workflow_events >0 and vault_events>0 or 
workflow_events >0 and assistant_events>0 or 
vault_events>0 and assistant_events>0) 
then 'Yes' else 'No' end as power_user_flag,
round(case when (lag(query_counts) over(partition by user_id order by last_active_date_in_month asc)) is not null then 
(query_counts - (lag(query_counts) over(partition by user_id order by last_active_date_in_month asc)))/
(lag(query_counts) over(partition by user_id order by last_active_date_in_month asc)) end ,1) query_growth_mom,
avg_monthly_feedback,
round(case when (lag(avg_monthly_feedback) over(partition by user_id order by last_active_date_in_month asc)) is not null then 
(avg_monthly_feedback - (lag(avg_monthly_feedback) over(partition by user_id order by last_active_date_in_month asc)))/
(lag(avg_monthly_feedback) over(partition by user_id order by last_active_date_in_month asc)) end,1) avg_feedback_growth_mom,
last_active_date_in_month,
active_days,
query_counts_per_day,
days_activity_spread_across_month,
monthly_num_docs_pulled,
avg_monthly_num_docs_pulled_per_query,
docs_per_day,
user_age_days_in_that_month,
workflow_events,
vault_events,
assistant_events,
knowledge_events,
workflow_feedback,
vault_feedback,
assistant_feedback,
knowledge_feedback
from initial_dataset
order by user_id, last_active_date_in_month