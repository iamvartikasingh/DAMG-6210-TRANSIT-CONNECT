--Register User Function
CREATE OR REPLACE PROCEDURE register_user (
    p_user_name     IN VARCHAR2,
    p_email         IN VARCHAR2,
    p_password      IN VARCHAR2,
    p_user_type     IN VARCHAR2,
    p_user_category IN VARCHAR2
) IS
    v_user_id       NUMBER;
    v_discount_id   NUMBER := NULL;
    v_email_exists  NUMBER;
    v_clean_type    VARCHAR2(100); -- ✅ declare a separate variable
BEGIN
    -- Step 1: Validate user name
    IF p_user_name IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: User name cannot be null.');
        RETURN;
    END IF;

    -- Step 2: Validate email format
    IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        DBMS_OUTPUT.PUT_LINE('Error: Invalid email format.');
        RETURN;
    END IF;

    -- Step 3: Check for existing email
    SELECT COUNT(*) INTO v_email_exists
    FROM USER_TBL
    WHERE EMAIL = LOWER(TRIM(p_email));

    IF v_email_exists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Email "' || p_email || '" already registered.');
        RETURN;
    END IF;

    -- Step 4: If user type is provided, fetch discount ID
    IF p_user_type IS NOT NULL THEN
        v_clean_type := TRIM(p_user_type);

        v_discount_id := GET_USER_DISCOUNT(v_clean_type);

        IF v_discount_id IS NULL THEN
            DBMS_OUTPUT.PUT_LINE(
              'Error: Invalid user type "' || p_user_type || 
              '". Invalid Discount type .Please Enter valid Discount Type'
            );
            RETURN;
        END IF;
    ELSE
        v_clean_type := NULL;
        v_discount_id := NULL;
    END IF;

    -- Step 5: Get next user ID
    v_user_id := USER_SEQ_PK.NEXTVAL;

    -- Step 6: Insert user
    INSERT INTO USER_TBL (
        USER_ID, USER_NAME, EMAIL, PASSWORD,
        USER_TYPE, CREATED_AT, DISCOUNT_TYPE_DISCOUNT_TYPE_ID
    ) VALUES (
        v_user_id, INITCAP(p_user_name), LOWER(p_email), p_password,
        INITCAP(v_clean_type), SYSDATE, v_discount_id
    );

    COMMIT;

    -- Step 7: Output confirmation
    DBMS_OUTPUT.PUT_LINE('✅ User registered successfully!');
    DBMS_OUTPUT.PUT_LINE('User ID    : ' || v_user_id);
    DBMS_OUTPUT.PUT_LINE('Name       : ' || INITCAP(p_user_name));
    DBMS_OUTPUT.PUT_LINE('Email      : ' || LOWER(p_email));
    DBMS_OUTPUT.PUT_LINE('User Type  : ' || NVL(INITCAP(v_clean_type), 'None'));
END;



---package body

CREATE OR REPLACE PACKAGE BODY USER_REGISTRATION_PKG AS

  FUNCTION validate_email(p_email IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN REGEXP_LIKE(
      p_email,
      '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    );
  END validate_email;

  PROCEDURE register_user (
    p_user_name     IN VARCHAR2,
    p_email         IN VARCHAR2,
    p_password      IN VARCHAR2,
    p_user_type     IN VARCHAR2
  ) IS
    v_user_id       NUMBER;
    v_discount_id   NUMBER := NULL;
    v_email_exists  NUMBER;
  BEGIN
    -- Step 1: Validate that name is not null
    IF p_user_name IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('❌ Error: User name cannot be null.');
      RETURN;
    END IF;

    -- Step 2: Validate that email is not null
    IF p_email IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('❌ Error: Email cannot be null.');
      RETURN;
    END IF;

    -- Step 3: Validate that password is not null
    IF p_password IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('❌ Error: Password cannot be null.');
      RETURN;
    END IF;

    -- Step 4: Validate email format
    IF NOT validate_email(p_email) THEN
      DBMS_OUTPUT.PUT_LINE('❌ Error: Invalid email format.');
      RETURN;
    END IF;

    -- Step 5: Check for duplicate email
    SELECT COUNT(*) INTO v_email_exists
    FROM USER_TBL
    WHERE EMAIL = LOWER(TRIM(p_email));

    IF v_email_exists > 0 THEN
      DBMS_OUTPUT.PUT_LINE('❌ Error: Email "' || p_email || '" already registered.');
      RETURN;
    END IF;

    -- Step 6: If user type is provided, validate & fetch discount
    IF p_user_type IS NOT NULL THEN
      v_discount_id := get_user_discount(p_user_type);

      IF v_discount_id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE(
          '❌ Error: Invalid user type "' || p_user_type ||
          '". No matching discount found.'
        );
        RETURN;
      END IF;
    END IF;

    -- Step 7: Generate user ID
    v_user_id := USER_SEQ_PK.NEXTVAL;

    -- Step 8: Insert new user
    INSERT INTO USER_TBL (
      USER_ID, USER_NAME, EMAIL, PASSWORD,
      USER_TYPE, CREATED_AT, DISCOUNT_TYPE_DISCOUNT_TYPE_ID
    ) VALUES (
      v_user_id,
      INITCAP(p_user_name),
      LOWER(p_email),
      p_password,
      INITCAP(p_user_type),
      SYSDATE,
      v_discount_id
    );

    COMMIT;

    -- Step 9: Success output
    DBMS_OUTPUT.PUT_LINE('✅ User registered successfully!');
    DBMS_OUTPUT.PUT_LINE('User ID    : ' || v_user_id);
    DBMS_OUTPUT.PUT_LINE('Name       : ' || INITCAP(p_user_name));
    DBMS_OUTPUT.PUT_LINE('Email      : ' || LOWER(p_email));
    DBMS_OUTPUT.PUT_LINE('User Type  : ' || NVL(INITCAP(p_user_type), 'None'));
  END register_user;

END USER_REGISTRATION_PKG;


--PAckage
CREATE OR REPLACE PACKAGE USER_REGISTRATION_PKG AS
  FUNCTION validate_email(p_email IN VARCHAR2) RETURN BOOLEAN;

  PROCEDURE register_user (
    p_user_name     IN VARCHAR2,
    p_email         IN VARCHAR2,
    p_password      IN VARCHAR2,
    p_user_type     IN VARCHAR2
  );
END USER_REGISTRATION_PKG;



--TEST CASES
SET SERVEROUTPUT ON;


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

