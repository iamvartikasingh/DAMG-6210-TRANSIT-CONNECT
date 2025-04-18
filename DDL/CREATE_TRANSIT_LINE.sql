BEGIN EXECUTE IMMEDIATE 'DROP TABLE TRANSIT_LINE CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/


CREATE TABLE TRANSIT_LINE (
    TRANSIT_LINE_ID     INTEGER NOT NULL,
    TRANSIT_LINE_NAME   VARCHAR2(100),
    AMOUNT              NUMBER(5,2),
    CONSTRAINT TRANSIT_LINE_PK PRIMARY KEY (TRANSIT_LINE_ID)
);
