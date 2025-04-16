# 🚇 Transit Connect System Database

## 📌 Overview

This project sets up a fully functional Oracle-based **Transit Connect Management System**. It includes:

- Table definitions (DDL)
- Sample data (DML)
- Views for reporting
- Application user creation and grants
- Sequence creation for auto-incrementing primary keys
- Full PL/SQL packages, functions, and procedures for:
  - User registration
  - Subscription purchasing
  - Ticket booking and cancellation
- Test case scripts for all major features

---

## ⚙️ Prerequisites

- Oracle Database (e.g., 19c or 21c)
- Oracle SQL Developer / SQL\*Plus / compatible PL/SQL tool
- DBA-level privileges for user creation and grants

---

## 📂 Execution Order

⚠️ **Important**: Run the scripts in the order listed below to avoid dependency and integrity errors.

---

### 1️⃣ Drop Tables (Safe Rerun)

Run all `BEGIN EXECUTE IMMEDIATE 'DROP TABLE ...'; EXCEPTION WHEN OTHERS THEN NULL; END; /` blocks to remove existing tables if they exist.

---

### 2️⃣ Create Tables (DDL)

Run these `CREATE TABLE` statements in the following order:

1. `DISCOUNT_TYPE`
2. `TRANSIT_LINE`
3. `SUBSCRIPTION_TYPE`
4. `USER_TBL`
5. `BOOKING`
6. `SUBSCRIPTION`
7. `TICKET`
8. `TRANSACTION`

---

### 3️⃣ Create Sequences

Run `SEQUENCE.sql` to create sequences for all tables:
- `DISCOUNT_TYPE_SEQ`
- `TRANSIT_LINE_SEQ`
- `SUBSCRIPTION_TYPE_SEQ`
- `USER_SEQ_PK`
- `BOOKING_SEQ`
- `SUBSCRIPTION_SEQ_PK`
- `TICKET_SEQ_PK`
- `TRANSACTION_SEQ`

---

### 4️⃣ Insert Sample Data (DML)

Insert data **after all tables and sequences are created**. Execute these blocks in order:

1. Insert into `DISCOUNT_TYPE`
2. Insert into `TRANSIT_LINE`
3. Insert into `SUBSCRIPTION_TYPE`
4. Insert into `USER_TBL`
5. Insert into `BOOKING`
6. Insert into `SUBSCRIPTION`
7. Insert into `TICKET`
8. Insert into `TRANSACTION`

> Each data insertion is wrapped in a PL/SQL block with `DELETE` and `INSERT` followed by `COMMIT`.

---

### 5️⃣ Create Views

Run these `CREATE OR REPLACE VIEW` statements in order:

1. `TICKET_USAGE_SUMMARY`
2. `USER_TRANSACTION_HISTORY`
3. `WEEKLY_BOOKING_TRENDS`
4. `CURRENT_INVENTORY_STATUS`
5. `TOTAL_SALES_BY_LINE`

---

### 6️⃣ Create Application Users

Run all `CREATE USER ... IDENTIFIED BY` commands with strong passwords:
- `app_transit_admin`
- `app_customer_user`
- `app_txn_manager`
- `app_booking_mgr`
- `app_subs_mgr`

---

### 7️⃣ Grant Roles and Permissions to Users

Run all GRANT statements as the user who created the objects (e.g., ADMIN).

#### Access is given based on role:

- **Transit Admin**: Full access to all tables and views
- **Customer User**: Can purchase subscriptions
- **Transaction Manager**: Can cancel tickets and view transactions
- **Booking Manager**: Can book and manage tickets
- **Subscription Manager**: Can register users and manage subscriptions

Refer to `USER_REGISTRATION.sql` and `USERS AND GRANTS` folder.

---

## 🧩 PL/SQL Modules

### 📌 USER_REGISTRATION.sql
- `Function`: `validate_email`, `get_user_discount`
- `Procedure`: `register_user`
- `Package`: `USER_REGISTRATION_PKG`

### 📌 PURCHASE_SUBSCRIPTION.sql
- `Function`: `validate_user`, `get_subscription_type_id`, `get_active_subscription`
- `Package`: `subscription_pkg` (with `calculate_end_date`, `record_subscription`)
- `Procedure`: `purchase_subscription`

### 📌 TICKETBOOKINGANDCANCELLATION.sql
- `Function`: `is_valid_user`
- `Package`: `TICKET_BOOKING_PKG` with:
  - `book_ticket`
  - `cancel_ticket`

---

## 🧪 Test Cases

Run `TESTCASES.sql` to test:
- Valid and invalid user registration
- Subscription purchase validations
- Ticket booking (including monthly limits and group discount logic)
- Ticket cancellation (with and without refund eligibility)

---

## ✅ Validation Checklist

- All `DROP` and `CREATE` statements use valid Oracle PL/SQL syntax.
- Table and column names are consistent across constraints and references.
- Foreign key dependencies are satisfied by execution order.
- Views are based on existing tables and use Oracle SQL functions like `TO_CHAR()`.
- DML operations are committed inside PL/SQL blocks.
- Sequences ensure safe auto-incrementing primary keys.
- All packages, functions, and procedures are modular and testable.
- Test cases cover both happy path and edge conditions.

---

## 🧪 Optional Testing

After setup, test queries such as:

```sql
SELECT * FROM USER_TBL;
SELECT * FROM TICKET_USAGE_SUMMARY;
SELECT * FROM WEEKLY_BOOKING_TRENDS;
