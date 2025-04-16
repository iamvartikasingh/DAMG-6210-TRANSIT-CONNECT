-- ================================================
-- DROP USERS (safe rerun with PL/SQL + "/")
-- ================================================
BEGIN EXECUTE IMMEDIATE 'DROP USER app_transit_admin CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP USER app_customer_user CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP USER app_txn_manager CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP USER app_booking_mgr CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP USER app_subs_mgr CASCADE'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- ================================================
-- CREATE USERS with Strong Passwords
-- ================================================
CREATE USER app_transit_admin IDENTIFIED BY AppAdmin#Pass1234;
CREATE USER app_customer_user IDENTIFIED BY Cust#Pass1234;
CREATE USER app_txn_manager IDENTIFIED BY Txn#Manager1234;
CREATE USER app_booking_mgr IDENTIFIED BY Booking#1234Mgr;
CREATE USER app_subs_mgr IDENTIFIED BY Subs#Manager1234;

-- ================================================
-- GRANT CONNECT ROLE
-- ================================================
GRANT CONNECT TO app_transit_admin;
GRANT CONNECT TO app_customer_user;
GRANT CONNECT TO app_txn_manager;
GRANT CONNECT TO app_booking_mgr;
GRANT CONNECT TO app_subs_mgr;

-- ================================================
-- GRANTS TO EACH USER BASED ON ROLE (with ADMIN.)
-- ================================================

-- Transit Admin (Full Access)
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.BOOKING TO app_transit_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.TICKET TO app_transit_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.TRANSACTION TO app_transit_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.USER_TBL TO app_transit_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.TRANSIT_LINE TO app_transit_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.SUBSCRIPTION TO app_transit_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.SUBSCRIPTION_TYPE TO app_transit_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.DISCOUNT_TYPE TO app_transit_admin;

GRANT SELECT ON ADMIN.CURRENT_INVENTORY_STATUS TO app_transit_admin;
GRANT SELECT ON ADMIN.TOTAL_SALES_BY_LINE TO app_transit_admin;
GRANT SELECT ON ADMIN.WEEKLY_BOOKING_TRENDS TO app_transit_admin;
GRANT SELECT ON ADMIN.TICKET_USAGE_SUMMARY TO app_transit_admin;
GRANT SELECT ON ADMIN.USER_TRANSACTION_HISTORY TO app_transit_admin;

-- Customer User (Read-only)
GRANT SELECT ON ADMIN.TRANSIT_LINE TO app_customer_user;
GRANT SELECT ON ADMIN.BOOKING TO app_customer_user;
GRANT SELECT ON ADMIN.TICKET TO app_customer_user;
GRANT SELECT ON ADMIN.SUBSCRIPTION TO app_customer_user;

GRANT SELECT ON ADMIN.CURRENT_INVENTORY_STATUS TO app_customer_user;
GRANT SELECT ON ADMIN.WEEKLY_BOOKING_TRENDS TO app_customer_user;
GRANT SELECT ON ADMIN.TICKET_USAGE_SUMMARY TO app_customer_user;

-- Transaction Manager
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.TRANSACTION TO app_txn_manager;
GRANT SELECT ON ADMIN.TICKET TO app_txn_manager;
GRANT SELECT ON ADMIN.BOOKING TO app_txn_manager;
GRANT SELECT ON ADMIN.USER_TBL TO app_txn_manager;
GRANT SELECT ON ADMIN.USER_TRANSACTION_HISTORY TO app_txn_manager;

-- Booking Manager
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.BOOKING TO app_booking_mgr;
GRANT SELECT ON ADMIN.TRANSIT_LINE TO app_booking_mgr;
GRANT SELECT ON ADMIN.DISCOUNT_TYPE TO app_booking_mgr;
GRANT SELECT ON ADMIN.USER_TBL TO app_booking_mgr;

GRANT SELECT ON ADMIN.CURRENT_INVENTORY_STATUS TO app_booking_mgr;
GRANT SELECT ON ADMIN.TOTAL_SALES_BY_LINE TO app_booking_mgr;
GRANT SELECT ON ADMIN.WEEKLY_BOOKING_TRENDS TO app_booking_mgr;

-- Subscription Manager
GRANT SELECT, INSERT, UPDATE, DELETE ON ADMIN.SUBSCRIPTION TO app_subs_mgr;
GRANT SELECT ON ADMIN.SUBSCRIPTION_TYPE TO app_subs_mgr;
GRANT SELECT ON ADMIN.USER_TBL TO app_subs_mgr;
