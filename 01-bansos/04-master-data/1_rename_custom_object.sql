/* =========================================================
   RENAME TABLE
========================================================= */
ALTER TABLE BJKT_MASTER_PROGRAMS
RENAME TO BJKT_BANSOS_MASTER_PROGRAMS;


/* =========================================================
   RENAME PRIMARY KEY CONSTRAINT
========================================================= */
ALTER TABLE BJKT_BANSOS_MASTER_PROGRAMS
RENAME CONSTRAINT BJKT_MASTER_PROGRAMS_PK
TO BJKT_BANSOS_MASTER_PROGRAMS_PK;


/* =========================================================
   RENAME INDEXES
========================================================= */
ALTER INDEX BJKT_MASTER_PROGRAMS_I1
RENAME TO BJKT_BANSOS_MASTER_PROGRAMS_I1;

ALTER INDEX BJKT_MASTER_PROGRAMS_I2
RENAME TO BJKT_BANSOS_MASTER_PROGRAMS_I2;

ALTER INDEX BJKT_MASTER_PROGRAMS_I3
RENAME TO BJKT_BANSOS_MASTER_PROGRAMS_I3;

ALTER INDEX BJKT_MASTER_PROGRAMS_I4
RENAME TO BJKT_BANSOS_MASTER_PROGRAMS_I4;


/* =========================================================
   RENAME SEQUENCE
========================================================= */
RENAME BJKT_MASTER_PROGRAMS_S
TO BJKT_BANSOS_MASTER_PROGRAMS_S;


/* =========================================================
   RENAME TRIGGER
========================================================= */
ALTER TRIGGER BJKT_MASTER_PROGRAMS_TRG
RENAME TO BJKT_BANSOS_MASTER_PROGRAMS_TRG;


/* =========================================================
   UPDATE TRIGGER SOURCE
========================================================= */
CREATE OR REPLACE EDITIONABLE TRIGGER BJKT_BANSOS_MASTER_PROGRAMS_TRG
BEFORE INSERT OR UPDATE
ON BJKT_BANSOS_MASTER_PROGRAMS
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW.ID := NVL(:NEW.ID, BJKT_BANSOS_MASTER_PROGRAMS_S.NEXTVAL);
        :NEW.CREATED_BY := NVL(V('APP_USER'), USER);
        :NEW.CREATION_DATE := SYSTIMESTAMP;

    ELSIF UPDATING THEN
        :NEW.LAST_UPDATED_BY := NVL(V('APP_USER'), USER);
        :NEW.LAST_UPDATE_DATE := SYSTIMESTAMP;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

ALTER TRIGGER BJKT_BANSOS_MASTER_PROGRAMS_TRG ENABLE;