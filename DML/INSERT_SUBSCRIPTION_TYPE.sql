BEGIN
    -- Delete existing data
    DELETE FROM SUBSCRIPTION_TYPE;
    COMMIT;

-- SUBSCRIPTION_TYPE
INSERT INTO SUBSCRIPTION_TYPE VALUES (1, 'Annual Pass', 500.00);
INSERT INTO SUBSCRIPTION_TYPE VALUES (2, 'Monthly Pass', 100.00);
INSERT INTO SUBSCRIPTION_TYPE VALUES (3, 'Weekly Pass', 40.00);
INSERT INTO SUBSCRIPTION_TYPE VALUES (4, 'Daily Pass', 10.00);
INSERT INTO SUBSCRIPTION_TYPE VALUES (5, 'Quarterly Pass', 250.00);


    COMMIT;
END;
/