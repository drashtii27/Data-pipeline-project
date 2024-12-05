-- Calculate total trading activity by hour for both real-time and historical data, and merge them into one table
WITH real_time_hourly_activity AS (
    SELECT
        EXTRACT(HOUR FROM TIME_OPEN) AS HOUR_OF_DAY,
        SUM(VOLUME_TRADED) AS TOTAL_VOLUME_TRADED,
        SUM(TRADES_COUNT) AS TOTAL_TRADES_COUNT,
        'Real-Time' AS DATA_SOURCE  -- Adding a column to distinguish between real-time and historical data
    FROM {{ ref('bitcoin_realtime') }}
    GROUP BY EXTRACT(HOUR FROM TIME_OPEN)
),

historical_hourly_activity AS (
    SELECT
        EXTRACT(HOUR FROM TIME_PERIOD_START) AS HOUR_OF_DAY,
        SUM(VOLUME_TRADED) AS TOTAL_VOLUME_TRADED,
        SUM(TRADES_COUNT) AS TOTAL_TRADES_COUNT,
        'Historical' AS DATA_SOURCE  -- Adding a column to distinguish between real-time and historical data
    FROM {{ ref('bitcoin_historical') }}
    GROUP BY EXTRACT(HOUR FROM TIME_PERIOD_START)
)

-- Combine real-time and historical data
SELECT 
    HOUR_OF_DAY,
    TOTAL_VOLUME_TRADED,
    TOTAL_TRADES_COUNT,
    DATA_SOURCE
FROM real_time_hourly_activity

UNION ALL

SELECT 
    HOUR_OF_DAY,
    TOTAL_VOLUME_TRADED,
    TOTAL_TRADES_COUNT,
    DATA_SOURCE
FROM historical_hourly_activity
ORDER BY HOUR_OF_DAY
