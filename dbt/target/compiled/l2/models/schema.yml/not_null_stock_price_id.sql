
    
    



with __dbt__cte__stock_price as (
SELECT 
    * 
FROMlab2.raw_data.stock_price
) select id
from __dbt__cte__stock_price
where id is null


