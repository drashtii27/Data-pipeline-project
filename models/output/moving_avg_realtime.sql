-- Calculate moving averages (e.g., 7-day moving average) for real-time data
WITH real_time_moving_avg AS (
    SELECT
        DATE(TIME_OPEN) AS DAY,
        PRICE_OPEN,
        VOLUME_TRADED,
        AVG(PRICE_OPEN) OVER (ORDER BY TIME_OPEN ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS PRICE_OPEN_7DAY_AVG,
        AVG(VOLUME_TRADED) OVER (ORDER BY TIME_OPEN ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS VOLUME_TRADED_7DAY_AVG
    FROM {{ ref('bitcoin_realtime') }}
)

-- Select final result
SELECT 
    DAY,
    PRICE_OPEN,
    VOLUME_TRADED,
    PRICE_OPEN_7DAY_AVG,
    VOLUME_TRADED_7DAY_AVG
FROM real_time_moving_avg
