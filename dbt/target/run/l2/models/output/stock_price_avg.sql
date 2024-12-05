
  
    

        create or replace transient table lab2.analytics.stock_price_avg
         as
        (WITH stock_data AS (
    SELECT
        DATE,
        SYMBOL,
        CLOSE,
        TIMESTAMP
    FROM lab2.raw_data.STOCK_PRICE
)

SELECT
    DATE,
    SYMBOL,
    CLOSE,
    TIMESTAMP,
    MAX(TIMESTAMP) OVER (PARTITION BY SYMBOL) AS max_timestamp,
    ROW_NUMBER() OVER (ORDER BY SYMBOL, DATE) AS id,
    AVG(CLOSE) OVER (
        PARTITION BY SYMBOL
        ORDER BY DATE
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7d
FROM stock_data
        );
      
  