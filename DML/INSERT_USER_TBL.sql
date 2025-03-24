BEGIN
    -- Delete existing data
    DELETE FROM USER_TBL;
    COMMIT;

-- USER
INSERT INTO USER_TBL VALUES (1, 'Alice', 'pass123', 'alice@example.com', 'Customer', TO_DATE('2024-01-01', 'YYYY-MM-DD'), 1);
INSERT INTO USER_TBL VALUES (2, 'Bob', 'pass456', 'bob@example.com', 'Manager', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 2);
INSERT INTO USER_TBL VALUES (3, 'Charlie', 'pass789', 'charlie@example.com', 'Customer', TO_DATE('2024-01-10', 'YYYY-MM-DD'), 3);
INSERT INTO USER_TBL VALUES (4, 'Diana', 'pass321', 'diana@example.com', 'Customer', TO_DATE('2024-01-15', 'YYYY-MM-DD'), 4);
INSERT INTO USER_TBL VALUES (5, 'Ethan', 'pass654', 'ethan@example.com', 'Customer', TO_DATE('2024-01-20', 'YYYY-MM-DD'), 5);

  COMMIT;
END;
/