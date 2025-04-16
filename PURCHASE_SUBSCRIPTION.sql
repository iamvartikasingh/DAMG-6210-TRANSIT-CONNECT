-- =======================================
-- FUNCTION: Validate User
-- =======================================
CREATE OR REPLACE FUNCTION validate_user(p_user_id NUMBER) RETURN BOOLEAN IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM USER_TBL WHERE USER_ID = p_user_id;
    RETURN v_count > 0;
END;
/

-- =======================================
-- FUNCTION: Get Subscription Type ID
-- =======================================
CREATE OR REPLACE FUNCTION get_subscription_type_id(p_subscription_name VARCHAR2) RETURN NUMBER IS
    v_sub_type_id NUMBER;
BEGIN
    SELECT SUBSCRIPTION_TYPE_ID INTO v_sub_type_id
    FROM SUBSCRIPTION_TYPE
    WHERE SUBSCRIPTION_NAME = p_subscription_name
    AND ROWNUM = 1;
    RETURN v_sub_type_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

-- =======================================
-- FUNCTION: Get Active Subscription Name
-- =======================================
CREATE OR REPLACE FUNCTION get_active_subscription(p_user_id NUMBER) RETURN VARCHAR2 IS
    v_sub_name VARCHAR2(100);
BEGIN
    SELECT st.SUBSCRIPTION_NAME INTO v_sub_name
    FROM SUBSCRIPTION s
    JOIN SUBSCRIPTION_TYPE st ON s.SUBSCRIPTION_TYPE_ID = st.SUBSCRIPTION_TYPE_ID
    WHERE s.USER_USER_ID = p_user_id
      AND s.SUBSCRIPTION_STATUS = 'Active'
      AND s.END_DATE >= SYSDATE
    FETCH FIRST 1 ROWS ONLY;
    RETURN v_sub_name;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

-- =======================================
-- PACKAGE: subscription_pkg
-- =======================================
CREATE OR REPLACE PACKAGE subscription_pkg IS
    FUNCTION calculate_end_date(subscription_name VARCHAR2, start_date DATE) RETURN DATE;
    PROCEDURE record_subscription(user_id IN NUMBER, subscription_type_id IN NUMBER, start_date IN DATE, end_date IN DATE);
END subscription_pkg;
/

-- =======================================
-- PACKAGE BODY: subscription_pkg
-- =======================================
CREATE OR REPLACE PACKAGE BODY subscription_pkg IS

    FUNCTION calculate_end_date(subscription_name VARCHAR2, start_date DATE) RETURN DATE IS
        months_to_add NUMBER;
    BEGIN
        IF subscription_name = 'Annual Pass' THEN
            months_to_add := 12;
        ELSIF subscription_name = 'Quarterly Pass' THEN
            months_to_add := 3;
        ELSIF subscription_name = 'Monthly Pass' THEN
            months_to_add := 1;
        ELSIF subscription_name = 'Weekly Pass' THEN
            RETURN start_date + 7;
        ELSIF subscription_name = 'Daily Pass' THEN
            RETURN start_date + 1;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Invalid subscription type.');
        END IF;
        RETURN ADD_MONTHS(start_date, months_to_add);
    END calculate_end_date;

    PROCEDURE record_subscription(user_id IN NUMBER, subscription_type_id IN NUMBER, start_date IN DATE, end_date IN DATE) IS
    BEGIN
        INSERT INTO SUBSCRIPTION (
            SUBSCRIPTION_ID,
            START_DATE,
            END_DATE,
            AUTO_RENEWAL,
            SUBSCRIPTION_STATUS,
            USER_USER_ID,
            SUBSCRIPTION_TYPE_ID
        ) VALUES (
            SUBSCRIPTION_SEQ_PK.NEXTVAL,
            start_date,
            end_date,
            'N',
            'Active',
            user_id,
            subscription_type_id
        );
    END record_subscription;

END subscription_pkg;
/

-- =======================================
-- PROCEDURE: purchase_subscription (FIXED ORDER)
-- =======================================
CREATE OR REPLACE PROCEDURE purchase_subscription(
    user_id IN NUMBER,
    subscription_name IN VARCHAR2,
    start_date IN DATE
) AS
    sub_type_id NUMBER;
    end_date DATE;
    existing_sub VARCHAR2(100);
BEGIN
    -- Step 1: Validate user
    IF NOT validate_user(user_id) THEN
        DBMS_OUTPUT.PUT_LINE('Error: User ID does not exist.');
        RETURN;
    END IF;

    -- Step 2: Validate subscription type
    sub_type_id := get_subscription_type_id(subscription_name);
    IF sub_type_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid subscription type "' || subscription_name || '".');
        RETURN;
    END IF;

    -- ✅ Step 3: Validate start date (must not be in past)
    IF start_date < TRUNC(SYSDATE) THEN
        DBMS_OUTPUT.PUT_LINE('Error: Start date cannot be in the past.');
        RETURN;
    END IF;

    -- ✅ Step 4: Check for existing active subscription
    existing_sub := get_active_subscription(user_id);
    IF existing_sub IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: User already has an active ' || existing_sub || ' subscription.');
        RETURN;
    END IF;

    -- Step 5: Calculate end date
    end_date := subscription_pkg.calculate_end_date(subscription_name, start_date);

    -- Step 6: Record subscription
    subscription_pkg.record_subscription(user_id, sub_type_id, start_date, end_date);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('✅ Subscription purchased successfully!');
    DBMS_OUTPUT.PUT_LINE('User ID        : ' || user_id);
    DBMS_OUTPUT.PUT_LINE('Subscription   : ' || subscription_name);
    DBMS_OUTPUT.PUT_LINE('Start Date     : ' || TO_CHAR(start_date, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('End Date       : ' || TO_CHAR(end_date, 'YYYY-MM-DD'));
END;
/


SET SERVEROUTPUT ON;


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

Delete subscription
