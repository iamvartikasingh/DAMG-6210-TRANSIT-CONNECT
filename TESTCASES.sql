-- Enable server output
SET SERVEROUTPUT ON;

-- ======================
-- 🧪 USER REGISTRATION
-- ======================

-- ❌ TC1: Password cannot be null
BEGIN
  USER_REGISTRATION_PKG.register_user(
    p_user_name     => 'abcd',
    p_email         => 'test123@example.com',
    p_password      => null,
    p_user_type     => 'Student Discount'
  );
END;
/

-- ❌ TC2: Invalid Discount type
BEGIN
  USER_REGISTRATION_PKG.register_user(
    p_user_name     => 'Invalid Discount User',
    p_email         => null,
    p_password      => 'Test456!',
    p_user_type     => 'Teacher Discount'
  );
END;
/

-- ✅ TC3: Mixed case user type with spaces
BEGIN
  USER_REGISTRATION_PKG.register_user(
    p_user_name     => 'Marina Camel',
    p_email         => 'marina.camel@example.com',
    p_password      => 'StrongPass1!',
    p_user_type     => 'No Discount'
  );
END;
/

-- ================================
-- 🧪 PURCHASE SUBSCRIPTION TESTS
-- ================================
SET SERVEROUTPUT ON;
-- ❌ TC4: Invalid Subscription Name
BEGIN
  APP_TRANSIT_ADMIN.purchase_subscription(2, 'Monthly1 Pass', SYSDATE);
END;
/

-- ✅ TC5: Valid Subscription Purchase
BEGIN
  APP_TRANSIT_ADMIN.purchase_subscription(1017, 'Monthly Pass', SYSDATE);
END;
/

-- ❌ TC6: Past Date
BEGIN
  APP_TRANSIT_ADMIN.purchase_subscription(3, 'Monthly Pass', SYSDATE - 1);
END;
/

-- ================================
-- 🧪 TICKET BOOKING TESTS
-- ================================
SET SERVEROUTPUT ON;

SELECT * FROM app_transit_admin.user_tbl;
-- ✅ TC7–13: Valid Bookings
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(1, 1, SYSDATE, 1); END;
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(4, 2, SYSDATE, 2); END;
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(4, 3, SYSDATE, 5); END;
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(3, 1, SYSDATE, 1); END;
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(3, 2, SYSDATE, 2); END;
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(4, 3, SYSDATE, 1); END;
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(5, 4, SYSDATE, 6); END;
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(2, 1, SYSDATE, 1); END;

-- ❌ TC14: Past Booking Date
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(1, 1, TO_DATE('2023-01-01', 'YYYY-MM-DD'), 1); END;

-- ❌ TC15: Booking more than 8 passengers
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(1, 1, SYSDATE, 9); END;

-- ✅ TC16: Group Discount (2–4 pax)
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.book_ticket(1, 2, SYSDATE, 4); END;

-- ================================
-- 🧪 TICKET CANCELLATION TESTS
-- ================================
SET SERVEROUTPUT ON;
-- ⚠️ First run this to get an unused TICKET_ID:
SELECT TICKET_ID 
FROM app_transit_admin.TICKET 
WHERE TICKET_STATUS = 'Unused' 
ORDER BY PURCHASE_TIME DESC 
FETCH FIRST 1 ROWS ONLY;

-- 🔁 Replace these ticket IDs with real values as needed:
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.cancel_ticket(1296); END;
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.cancel_ticket(1133); END;
BEGIN APP_TRANSIT_ADMIN.TICKET_BOOKING_PKG.cancel_ticket(1115); END;

