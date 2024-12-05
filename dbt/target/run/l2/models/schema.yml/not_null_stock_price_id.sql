select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



with __dbt__cte__stock_price as (
SELECT 
    * 
FROMlab2.raw_data.stock_price
) select id
from __dbt__cte__stock_price
where id is null



      
    ) dbt_internal_test