SELECT 
    time_period_start,
    time_period_end,
    time_open,
    time_close,
    price_open,
    price_high,
    price_low,
    price_close,
    volume_traded,
    trades_count
FROM lab2.raw_data.bitcoin_historical
WHERE time_period_start IS NOT NULL