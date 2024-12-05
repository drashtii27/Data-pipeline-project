SELECT 
    time_open,
    price_open,
    price_high,
    price_low,
    price_close,
    volume_traded,
    trades_count
FROM lab2.raw_data.bitcoin_realtime
WHERE price_close IS NOT NULL