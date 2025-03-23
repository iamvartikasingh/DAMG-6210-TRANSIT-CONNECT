CREATE OR REPLACE VIEW CURRENT_INVENTORY_STATUS AS
SELECT 
    TL.TRANSIT_LINE_NAME,
    COUNT(B.BOOKING_ID) AS TOTAL_BOOKINGS
FROM 
    BOOKING B
JOIN 
    TRANSIT_LINE TL ON B.TRANSIT_LINE_TRANSIT_LINE_ID = TL.TRANSIT_LINE_ID
GROUP BY 
    TL.TRANSIT_LINE_NAME;