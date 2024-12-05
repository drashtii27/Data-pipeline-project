
  
    

        create or replace transient table lab2.analytics.stock_price_RSI
         as
        (WITH stock_changes AS (
    SELECT
        DATE,
        SYMBOL,
        CLOSE,
        TIMESTAMP,
        CLOSE - LAG(CLOSE, 1) OVER (PARTITION BY SYMBOL ORDER BY DATE) AS change
    FROM lab2.raw_data.STOCK_PRICE
),

gains_losses AS (
    SELECT
        DATE,
        SYMBOL,
        CLOSE,
        TIMESTAMP,
        CASE WHEN change > 0 THEN change ELSE 0 END AS gain,
        CASE WHEN change < 0 THEN ABS(change) ELSE 0 END AS loss
    FROM stock_changes
),

average_gains_losses AS (
    SELECT
        DATE,
        SYMBOL,
        CLOSE,
        TIMESTAMP,
        MAX(TIMESTAMP) OVER (PARTITION BY SYMBOL) AS max_timestamp,
        ROW_NUMBER() OVER (ORDER BY SYMBOL, DATE) AS id,
        AVG(gain) OVER (PARTITION BY SYMBOL ORDER BY DATE ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) AS avg_gain_14d,
        AVG(loss) OVER (PARTITION BY SYMBOL ORDER BY DATE ROWS BETWEEN 13 PRECEDING AND CURRENT ROW) AS avg_loss_14d
    FROM gains_losses
)

SELECT
    DATE,
    SYMBOL,
    CLOSE,
    TIMESTAMP,
    max_timestamp,
    id,
    100 - (100 / (1 + NULLIF(avg_gain_14d, 0) / NULLIF(avg_loss_14d, 0))) AS rsi_14d
FROM average_gains_losses
        );
      
  