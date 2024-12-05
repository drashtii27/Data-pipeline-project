
    
    

with __dbt__cte__stock_price as (
SELECT 
    * 
FROMlab2.raw_data.stock_price
) select
    id as unique_field,
    count(*) as n_records

from __dbt__cte__stock_price
where id is not null
group by id
having count(*) > 1


