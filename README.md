# 🚇 Transit System Database Setup — README

## 📌 Overview

This project sets up a fully functional Oracle-based **Transit Management System**. It includes:

- Table definitions (DDL)
- Sample data (DML)
- Views for reporting
- Application user creation and grants

This README explains the **correct execution order** and dependencies to ensure the database is initialized and ready for use.

---

## ⚙️ Prerequisites

- Oracle Database (e.g., 19c or 21c)
- Oracle SQL Developer / SQL*Plus / compatible PL/SQL tool
- DBA-level privileges for user creation and grants

---

## 📂 Execution Order

⚠️ **Important**: Run the scripts in the order listed below to avoid dependency and integrity errors.

### 1️⃣ Drop Tables (Safe Rerun)
Run all `BEGIN EXECUTE IMMEDIATE 'DROP TABLE ...'; EXCEPTION WHEN OTHERS THEN NULL; END; /` blocks to remove existing tables if they exist.

### 2️⃣ Create Tables (DDL)

Run these `CREATE TABLE` statements in the following order:

1. `DISCOUNT_TYPE`
2. `TRANSIT_LINE`
3. `USER_TBL`
4. `SUBSCRIPTION_TYPE`
5. `BOOKING`
6. `SUBSCRIPTION`
7. `TICKET`
8. `TRANSACTION`

---

### 3️⃣ Insert Sample Data (DML)

Insert data **after all tables are created**. Execute these blocks in order:

1. Insert into `DISCOUNT_TYPE`
2. Insert into `TRANSIT_LINE`
3. Insert into `USER_TBL`
4. Insert into `BOOKING`
5. Insert into `SUBSCRIPTION`
6. Insert into `TICKET`
7. Insert into `TRANSACTION`

> Each data insertion is wrapped in a PL/SQL block with `DELETE` and `INSERT` followed by `COMMIT`.

---

### 4️⃣ Drop Application Users (Safe Rerun)

Run all `DROP USER ... CASCADE` blocks to remove any existing users:
- `app_transit_admin`
- `app_customer_user`
- `app_txn_manager`
- `app_booking_mgr`
- `app_subs_mgr`

---

### 5️⃣ Create Application Users

Run all `CREATE USER ... IDENTIFIED BY` commands with strong passwords:
- `app_transit_admin`
- `app_customer_user`
- `app_txn_manager`
- `app_booking_mgr`
- `app_subs_mgr`

---

### 6️⃣ Grant Roles to Users

1. `GRANT CONNECT TO` each user
2. Grant `SELECT`, `INSERT`, `UPDATE`, `DELETE` permissions based on user role:
   - **Transit Admin**: Full access to all tables and views
   - **Customer User**: Read-only access to key tables and views
   - **Transaction Manager**: Full access to `TRANSACTION`, read on related tables
   - **Booking Manager**: Full access to `BOOKING`, read on related tables
   - **Subscription Manager**: Full access to `SUBSCRIPTION`, read on related tables

---

### 7️⃣ Create Views

Run these `CREATE OR REPLACE VIEW` statements in order:

1. `TICKET_USAGE_SUMMARY`
2. `USER_TRANSACTION_HISTORY`
3. `WEEKLY_BOOKING_TRENDS`
4. `CURRENT_INVENTORY_STATUS`
5. `TOTAL_SALES_BY_LINE`

---

## ✅ Validation Checklist

- All `DROP` and `CREATE` statements use valid Oracle PL/SQL syntax.
- Table and column names are consistent across constraints and references.
- Foreign key dependencies are satisfied by execution order.
- Views are based on existing tables and use Oracle SQL functions like `TO_CHAR()`.
- DML operations are committed inside PL/SQL blocks.
- All users are created with valid and strong passwords.

---

## 🧪 Optional Testing

After setup, test queries such as:
```sql
SELECT * FROM USER_TBL;
SELECT * FROM TICKET_USAGE_SUMMARY;
SELECT * FROM WEEKLY_BOOKING_TRENDS;
