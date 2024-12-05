WITH realtime AS (
    SELECT 
        time_open AS time_period_start,
        price_close
    FROM {{ source('raw_data', 'bitcoin_realtime') }}
)

SELECT
    time_period_start,
    AVG(price_close) OVER (ORDER BY time_period_start ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS thirty_min_avg_price
FROM realtime
ORDER BY time_period_start
