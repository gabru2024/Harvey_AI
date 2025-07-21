{{ config(
    materialized = 'view',
    schema = 'mart_schema'
) }}

with totals as (
select 
e.created,
sum(num_docs) over(partition by e.created) num_docs,
sum(num_docs) over(order by e.created asc) num_docs_till_date,
sum(case when e.event_type='WORKFLOW' then num_docs end) over(partition by e.created) worklfow_docs,
sum(case when e.event_type='VAULT' then num_docs end) over(partition by e.created) vault_docs,
sum(case when e.event_type='ASSISTANT' then num_docs end) over(partition by e.created ) assistant_docs,
sum(case when e.event_type='KNOWLEDGE' then num_docs end) over(partition by e.created ) knowledge_docs,
count(user_id) over(order by e.created asc) queries_till_date,
count(case when title='Junior Associate' then user_id end) over(order by e.created asc) junior_associate_queries_till_date,
count(case when title='Senior Associate' then user_id end) over(order by e.created asc) senior_associate_queries_till_date,
count(case when title='Partner' then user_id end) over(order by e.created asc) partner_queries_till_date,
count(case when title='Associate' then user_id end) over(order by e.created asc) associate_queries_till_date,
from events e join users u on e.user_id=u.id)

select 
r.created,
r.num_docs_till_date,
r.num_docs,
worklfow_docs,
r.vault_docs,
r.assistant_docs,
r.knowledge_docs,
r.queries_till_date,
r.junior_associate_queries_till_date,
r.senior_associate_queries_till_date,
r.partner_queries_till_date,
r.associate_queries_till_date
from totals r 
group by all 
order by r.created