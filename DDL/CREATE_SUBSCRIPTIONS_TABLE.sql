BEGIN EXECUTE IMMEDIATE 'DROP TABLE SUBSCRIPTION CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

CREATE TABLE SUBSCRIPTION (
    SUBSCRIPTION_ID       INTEGER NOT NULL,
    START_DATE            DATE NOT NULL,
    END_DATE              DATE NOT NULL,
    AUTO_RENEWAL          CHAR(1),
    SUBSCRIPTION_STATUS   VARCHAR2(100) NOT NULL,
    USER_USER_ID          INTEGER NOT NULL,
    SUBSCRIPTION_TYPE_ID  INTEGER NOT NULL,
    CONSTRAINT SUBSCRIPTION_PK PRIMARY KEY (SUBSCRIPTION_ID),
    CONSTRAINT SUBSCRIPTION_USER_FK FOREIGN KEY (USER_USER_ID) REFERENCES USER_TBL(USER_ID),
    CONSTRAINT SUBSCRIPTION_TYPE_FK FOREIGN KEY (SUBSCRIPTION_TYPE_ID) REFERENCES SUBSCRIPTION_TYPE(SUBSCRIPTION_TYPE_ID)
);