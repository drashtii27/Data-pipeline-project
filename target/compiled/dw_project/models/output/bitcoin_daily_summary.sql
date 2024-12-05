WITH historical_data AS (
    SELECT
        TIME_PERIOD_START::DATE AS date,
        PRICE_OPEN,
        PRICE_HIGH,
        PRICE_LOW,
        PRICE_CLOSE,
        VOLUME_TRADED,
        TRADES_COUNT
    FROM lab2.raw_data.bitcoin_historical
),
realtime_data AS (
    SELECT
        TIME_OPEN::DATE AS date,
        PRICE_OPEN,
        PRICE_HIGH,
        PRICE_LOW,
        PRICE_CLOSE,
        VOLUME_TRADED,
        TRADES_COUNT
    FROM lab2.raw_data.bitcoin_realtime
)

SELECT
    date,
    AVG(PRICE_OPEN) AS avg_open,
    AVG(PRICE_HIGH) AS avg_high,
    AVG(PRICE_LOW) AS avg_low,
    AVG(PRICE_CLOSE) AS avg_close,
    SUM(VOLUME_TRADED) AS total_volume,
    SUM(TRADES_COUNT) AS total_trades
FROM (
    SELECT * FROM historical_data
    UNION ALL
    SELECT * FROM realtime_data
) AS combined_data
GROUP BY date
ORDER BY date