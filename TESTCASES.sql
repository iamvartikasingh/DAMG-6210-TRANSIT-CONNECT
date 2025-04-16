--TEST CASES
SET SERVEROUTPUT ON;


--User Registration


--password cannot be null
BEGIN
  USER_REGISTRATION_PKG.register_user(
    p_user_name     => 'abcd',
    p_email         => 'test123@example.com',
    p_password      => null,
    p_user_type     => 'Student Discount'
  );
END;
/


--Invalid Discount type
BEGIN
  USER_REGISTRATION_PKG.register_user(
    p_user_name     => 'Invalid Discount User',
    p_email         => null,
    p_password      => 'Test456!',
    p_user_type     => 'Teacher Discount'
    
  );
END;
/

--✅ TC3: Mixed case user type with spaces

BEGIN
  USER_REGISTRATION_PKG.register_user(
    p_user_name     => 'Marina Camel',
    p_email         => 'marina.camel@example.com',
    p_password      => 'StrongPass1!',
    p_user_type     => 'No Discount'
    
  );
END;
/


--Purchase Subscriiption


-- Valid
BEGIN
  purchase_subscription(2, 'Monthly1 Pass', SYSDATE);
END;
/
-- Valid
BEGIN
  purchase_subscription(200, 'Monthly Pass', SYSDATE);
END;
/

-- Past date (should trigger error now)
BEGIN
  purchase_subscription(3, 'Monthly Pass', SYSDATE - 1);
END;
/


-- Ticket Booking and Cancellation


-- ✅ Bookings with multiple tickets
BEGIN TICKET_BOOKING_PKG.book_ticket(1, 1, SYSDATE, 1); END;
BEGIN TICKET_BOOKING_PKG.book_ticket(1, 2, SYSDATE, 3); END;
BEGIN TICKET_BOOKING_PKG.book_ticket(1, 3, SYSDATE, 5); END;

BEGIN TICKET_BOOKING_PKG.book_ticket(3, 1, SYSDATE, 1); END;
BEGIN TICKET_BOOKING_PKG.book_ticket(3, 2, SYSDATE, 2); END;

BEGIN TICKET_BOOKING_PKG.book_ticket(4, 3, SYSDATE, 1); END;
BEGIN TICKET_BOOKING_PKG.book_ticket(5, 4, SYSDATE, 6); END;

BEGIN TICKET_BOOKING_PKG.book_ticket(2, 1, SYSDATE, 1); END;

-- ❌ Edge cases
BEGIN TICKET_BOOKING_PKG.book_ticket(1, 1, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 1); END;
BEGIN TICKET_BOOKING_PKG.book_ticket(1, 1, SYSDATE, 9); END;
BEGIN TICKET_BOOKING_PKG.book_ticket(1, 2, SYSDATE, 4); END;

-- ✅ Ticket cancellation
SELECT TICKET_ID FROM TICKET WHERE TICKET_STATUS = 'Unused' ORDER BY PURCHASE_TIME DESC FETCH FIRST 1 ROWS ONLY;

BEGIN TICKET_BOOKING_PKG.cancel_ticket(1135); END;

BEGIN TICKET_BOOKING_PKG.cancel_ticket(1133); END;

-- Try cancelling again
BEGIN TICKET_BOOKING_PKG.cancel_ticket(1115); END;

