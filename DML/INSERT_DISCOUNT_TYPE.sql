BEGIN
    -- Delete existing data
    DELETE FROM DISCOUNT_TYPE;

    -- Insert fresh data
    INSERT INTO DISCOUNT_TYPE (DISCOUNT_TYPE_ID, DISCOUNT_NAME, DISCOUNT_PERCENTAGE) VALUES (1, 'Student Discount', 10);
    INSERT INTO DISCOUNT_TYPE (DISCOUNT_TYPE_ID, DISCOUNT_NAME, DISCOUNT_PERCENTAGE) VALUES (2, 'No Discount', 0);
    INSERT INTO DISCOUNT_TYPE (DISCOUNT_TYPE_ID, DISCOUNT_NAME, DISCOUNT_PERCENTAGE) VALUES (3, 'Senior Citizen Discount', 15);
    INSERT INTO DISCOUNT_TYPE (DISCOUNT_TYPE_ID, DISCOUNT_NAME, DISCOUNT_PERCENTAGE) VALUES (4, '3-5Group', 12);
    INSERT INTO DISCOUNT_TYPE (DISCOUNT_TYPE_ID, DISCOUNT_NAME, DISCOUNT_PERCENTAGE) VALUES (5, '5-8Group', 20);

    COMMIT;
END;
/
