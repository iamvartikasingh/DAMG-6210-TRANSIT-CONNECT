-- PACKAGE SPEC
CREATE OR REPLACE PACKAGE TICKET_BOOKING_PKG AS
  FUNCTION is_valid_user(p_user_id IN NUMBER) RETURN BOOLEAN;

  PROCEDURE book_ticket(
    p_user_id         IN NUMBER,
    p_transit_line_id IN NUMBER,
    p_booking_date    IN DATE,
    p_num_passengers  IN NUMBER
  );

  PROCEDURE cancel_ticket(p_ticket_id IN NUMBER);
END TICKET_BOOKING_PKG;
/

-- PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY TICKET_BOOKING_PKG AS

  FUNCTION is_valid_user(p_user_id IN NUMBER) RETURN BOOLEAN IS
    v_exists NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM USER_TBL
    WHERE USER_ID = p_user_id;
    RETURN v_exists > 0;
  END;

  PROCEDURE book_ticket(
    p_user_id         IN NUMBER,
    p_transit_line_id IN NUMBER,
    p_booking_date    IN DATE,
    p_num_passengers  IN NUMBER
  ) IS
    v_user_type           USER_TBL.USER_TYPE%TYPE;
    v_discount_id         DISCOUNT_TYPE.DISCOUNT_TYPE_ID%TYPE := NULL;
    v_discount_percentage NUMBER := 0;
    v_discount_name       VARCHAR2(50) := 'No Discount';
    v_transit_amount      TRANSIT_LINE.AMOUNT%TYPE;
    v_total_amount        NUMBER(10,2);
    v_final_amount        NUMBER(10,2);
    v_booking_id          NUMBER;
    v_ticket_id           NUMBER;
    v_transaction_id      NUMBER;
    v_monthly_total       NUMBER(10,2);
  BEGIN
    IF p_booking_date < TRUNC(SYSDATE) THEN
      DBMS_OUTPUT.PUT_LINE('❌ Booking date cannot be in the past.');
      RETURN;
    END IF;

    IF p_num_passengers > 8 THEN
      DBMS_OUTPUT.PUT_LINE('❌ Cannot book more than 8 tickets per booking.');
      RETURN;
    END IF;

    SELECT NVL(SUM(FINAL_TOTAL_AMOUNT), 0)
    INTO v_monthly_total
    FROM BOOKING
    WHERE USER_USER_ID = p_user_id
      AND EXTRACT(MONTH FROM BOOKING_DATE) = EXTRACT(MONTH FROM SYSDATE)
      AND EXTRACT(YEAR FROM BOOKING_DATE) = EXTRACT(YEAR FROM SYSDATE);

    IF v_monthly_total >= 1000 THEN
      DBMS_OUTPUT.PUT_LINE('❌ Booking denied. User has already spent $' || v_monthly_total || ' this month.');
      RETURN;
    END IF;

    SELECT LOWER(USER_TYPE) INTO v_user_type
    FROM USER_TBL
    WHERE USER_ID = p_user_id;

    -- ✅ Discount Logic (dynamic lookup)
    IF v_user_type = 'student' AND p_num_passengers = 1 THEN
      SELECT DISCOUNT_TYPE_ID, DISCOUNT_PERCENTAGE, DISCOUNT_NAME
      INTO v_discount_id, v_discount_percentage, v_discount_name
      FROM DISCOUNT_TYPE
      WHERE LOWER(DISCOUNT_NAME) = 'student discount';

    ELSIF v_user_type = 'senior' AND p_num_passengers = 1 THEN
      SELECT DISCOUNT_TYPE_ID, DISCOUNT_PERCENTAGE, DISCOUNT_NAME
      INTO v_discount_id, v_discount_percentage, v_discount_name
      FROM DISCOUNT_TYPE
      WHERE LOWER(DISCOUNT_NAME) = 'senior citizen discount';

    ELSIF p_num_passengers BETWEEN 2 AND 4 THEN
      SELECT DISCOUNT_TYPE_ID, DISCOUNT_PERCENTAGE, DISCOUNT_NAME
      INTO v_discount_id, v_discount_percentage, v_discount_name
      FROM DISCOUNT_TYPE WHERE DISCOUNT_TYPE_ID = 4;

    ELSIF p_num_passengers BETWEEN 5 AND 8 THEN
      SELECT DISCOUNT_TYPE_ID, DISCOUNT_PERCENTAGE, DISCOUNT_NAME
      INTO v_discount_id, v_discount_percentage, v_discount_name
      FROM DISCOUNT_TYPE WHERE DISCOUNT_TYPE_ID = 5;

    ELSE
      SELECT DISCOUNT_TYPE_ID, DISCOUNT_PERCENTAGE, DISCOUNT_NAME
      INTO v_discount_id, v_discount_percentage, v_discount_name
      FROM DISCOUNT_TYPE WHERE DISCOUNT_TYPE_ID = 2;
    END IF;

    SELECT AMOUNT INTO v_transit_amount
    FROM TRANSIT_LINE
    WHERE TRANSIT_LINE_ID = p_transit_line_id;

    v_total_amount := p_num_passengers * v_transit_amount;
    v_final_amount := v_total_amount * (1 - v_discount_percentage / 100);

    IF (v_monthly_total + v_final_amount) > 1000 THEN
      DBMS_OUTPUT.PUT_LINE('❌ Booking denied. This booking would exceed the $1000 monthly limit.');
      RETURN;
    END IF;

    SELECT BOOKING_SEQ.NEXTVAL INTO v_booking_id FROM DUAL;

    INSERT INTO BOOKING (
      BOOKING_ID, BOOKING_DATE, NUM_PASSENGERS, DISCOUNT_APPLIED,
      TOTAL_AMOUNT, FINAL_TOTAL_AMOUNT, USER_USER_ID,
      TRANSIT_LINE_TRANSIT_LINE_ID, DISCOUNT_TYPE_DISCOUNT_TYPE_ID
    )
    VALUES (
      v_booking_id, p_booking_date, p_num_passengers,
      CASE WHEN v_discount_percentage > 0 THEN 'Y' ELSE 'N' END,
      v_total_amount, v_final_amount, p_user_id,
      p_transit_line_id, v_discount_id
    );

    FOR i IN 1 .. p_num_passengers LOOP
      SELECT TICKET_SEQ_PK.NEXTVAL INTO v_ticket_id FROM DUAL;

      INSERT INTO TICKET (
        TICKET_ID, PURCHASE_DATE, PURCHASE_TIME, AMOUNT,
        TICKET_STATUS, TRANSIT_LINE_TRANSIT_LINE_ID, BOOKING_BOOKING_ID
      )
      VALUES (
        v_ticket_id, SYSDATE, SYSTIMESTAMP, v_final_amount / p_num_passengers,
        'Unused', p_transit_line_id, v_booking_id
      );

      SELECT TRANSACTION_SEQ.NEXTVAL INTO v_transaction_id FROM DUAL;

      INSERT INTO TRANSACTION (
        TRANSACTION_ID, AMOUNT, REFUND_AMOUNT, REFUND_STATUS,
        PAYMENT_STATUS, TRANSACTION_DATE, TICKET_TICKET_ID
      )
      VALUES (
        v_transaction_id, v_final_amount / p_num_passengers, 0, 'No Refund',
        'Paid', SYSDATE, v_ticket_id
      );
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ ' || v_discount_name || ' applied. ' || p_num_passengers || ' ticket(s) booked successfully.');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('❌ Invalid user ID or transit line ID or discount type.');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('❌ An unexpected error occurred: ' || SQLERRM);
  END;


  PROCEDURE cancel_ticket(p_ticket_id IN NUMBER) IS
    v_purchase_time  TIMESTAMP;
    v_refund_amt     NUMBER(5,2);
    v_amount         NUMBER(5,2);
    v_status         VARCHAR2(100);
  BEGIN
    SELECT PURCHASE_TIME, AMOUNT, TICKET_STATUS
    INTO v_purchase_time, v_amount, v_status
    FROM TICKET
    WHERE TICKET_ID = p_ticket_id;

    IF v_status = 'Used' THEN
      DBMS_OUTPUT.PUT_LINE('❌ Cannot cancel. Ticket is already used.');
      RETURN;
    ELSIF v_status = 'Cancelled' THEN
      DBMS_OUTPUT.PUT_LINE('❌ Ticket is already cancelled.');
      RETURN;
    END IF;

    IF SYSTIMESTAMP <= v_purchase_time + INTERVAL '1' HOUR THEN
      v_refund_amt := v_amount;
    ELSE
      v_refund_amt := 0;
    END IF;

    UPDATE TICKET
    SET TICKET_STATUS = 'Cancelled'
    WHERE TICKET_ID = p_ticket_id;

    UPDATE TRANSACTION
    SET REFUND_AMOUNT = v_refund_amt,
        REFUND_STATUS = CASE WHEN v_refund_amt > 0 THEN 'Full' ELSE 'No Refund' END,
        PAYMENT_STATUS = 'Refunded'
    WHERE TICKET_TICKET_ID = p_ticket_id;

    COMMIT;

    IF v_refund_amt > 0 THEN
      DBMS_OUTPUT.PUT_LINE('✅ Ticket cancelled successfully. Full refund issued.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('✅ Ticket cancelled. No refund as time limit exceeded.');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('❌ Ticket ID not found.');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('❌ An unexpected error occurred during cancellation: ' || SQLERRM);
  END;

END TICKET_BOOKING_PKG;
/