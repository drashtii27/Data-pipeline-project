{% snapshot test_snapshot %}

{{
    config(
      target_schema='snapshot',
      unique_key='TIME_PERIOD_START',
      strategy='timestamp',
      updated_at='TIME_PERIOD_START',
    )
}}

select * from {{ source('raw_data', 'bitcoin_realtime') }}

{% endsnapshot %}