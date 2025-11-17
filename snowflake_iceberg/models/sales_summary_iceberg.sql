{{
  config(
    materialized='table',
    catalog_name='catalog_horizon'
  )
}}

select 
  category,
  date(transaction_date) as sales_date,
  count(distinct customer_id) as unique_customers,
  count(*) as transaction_count,
  sum(total_amount) as total_sales,
  avg(total_amount) as avg_sales
from {{ source('raw_data', 'sales_transactions') }}
where transaction_date is not null
group by category, date(transaction_date)