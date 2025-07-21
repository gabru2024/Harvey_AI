# Harvey_AI

Quick call outs on data -
No unique/primary_key in events table (event_id or transaction id)

Firms exist without corresponding event records (PK/FK enforcement needed)

Users table does not have a deleted_at or deactivated_at (to capture users not with firm)

Firms table does not have a deleted_at or deactivated_at (revoking past firms)

Events is missing a Harvey product category (KNOWLEDGE)

Within each event_type/products can have sub_events/sub-categories), data for sub_event_id is missing: (example 
"Vault" - can store, analyze and do other granular subtasks)


Definitions for a few metrics in dbt models -

User engagement:

query_counts - count of user queries

query_growth_mom - compares query count for current vs previous month

avg_feedback_growth_mom - avg feedback from current month compared to previous month

last_active_date_in_month - latest query pull date in a month

active_days - unique count of days with a query pull

query_counts_per_day - query counts per active days

days_activity_spread_across_month - shows total days spread between first and last activity within a month

docs_per_day - documents pulled per active days

user_age_days_in_that_month - user active days since creation (in the event month)


firm_usage_summary: This is at firm grain

firm_query_usage_vs_allfirms_percent - percentage of queries run by firm compared to all firms

query users - unique user count per firm that ever pulled a query

query_days - unique days queries were run per firm

active_days - days between latest and first run

user_activity_intensity - ratio of query_days to active_days (closer to 1 represents better daily usage)

avg_annual_revenue_per_user_in_dollars - revenue per user (using arr_in_thousands)

minimum_days_before_firms_first_user_activity - first user query since user creation