{% snapshot snapshot_stock_price_avg %}

{{
  config(
    target_schema='snapshot',
    unique_key='id',
    strategy='timestamp',
    updated_at='timestamp',
    invalidate_hard_deletes=True 
  )
}}  

SELECT * FROM {{ ref('stock_price_avg') }}

{% endsnapshot %}