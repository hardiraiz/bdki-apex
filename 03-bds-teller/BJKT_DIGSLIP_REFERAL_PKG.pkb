CREATE OR REPLACE PACKAGE BODY BJKT_DIGSLIP_KODE_REFERAL_PKG AS

    -- PRIVATE: VALIDATE STATUS TRANSITION
    PROCEDURE PV_CHECK_STATUS (
        P_ID                IN NUMBER,
        P_EXPECTED_STATUS   IN VARCHAR2,
        P_CURRENT_STATUS    OUT VARCHAR2
    ) IS
    BEGIN
        SELECT STATUS
          INTO P_CURRENT_STATUS
          FROM BJKT_DIGSLIP_KODE_REFERAL
         WHERE ID = P_ID
           FOR UPDATE;

        IF P_CURRENT_STATUS != P_EXPECTED_STATUS THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'Status tidak valid untuk transisi ini. ID=' || P_ID ||
                ', Status saat ini=' || P_CURRENT_STATUS ||
                ', Status yang diharapkan=' || P_EXPECTED_STATUS
            );
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Record BJKT_DIGSLIP_KODE_REFERAL tidak ditemukan. ID=' || P_ID
            );
    END PV_CHECK_STATUS;


    FUNCTION GENERATE_KODE_REF
        RETURN VARCHAR2
    IS
        V_KODE_REF  VARCHAR2(6);
        V_COUNT     NUMBER;
        V_CHARS     CONSTANT VARCHAR2(36) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    BEGIN
        LOOP
            V_KODE_REF := NULL;

            FOR I IN 1..6 LOOP
                V_KODE_REF := V_KODE_REF ||
                    SUBSTR(V_CHARS, TRUNC(DBMS_RANDOM.VALUE(1, LENGTH(V_CHARS) + 1)), 1);
            END LOOP;

            SELECT COUNT(1)
              INTO V_COUNT
              FROM BJKT_DIGSLIP_KODE_REFERAL
             WHERE KODE_REF = V_KODE_REF
               AND STATUS NOT IN (C_STATUS_COMPLETED, C_STATUS_CANCELLED, C_STATUS_EXPIRED);

            EXIT WHEN V_COUNT = 0;
        END LOOP;

        RETURN V_KODE_REF;
    END GENERATE_KODE_REF;


    PROCEDURE INSERT_REFERAL (
        P_KODE_REF              IN OUT VARCHAR2,
        P_ID_TRANSAKSI          IN     NUMBER,
        P_TIPE_TRANSAKSI        IN     VARCHAR2,
        P_EXPIRED_AT            IN     TIMESTAMP,
        P_ID_PARENT             IN     NUMBER DEFAULT NULL,
        P_OUT_ID                OUT    NUMBER,
        P_OUT_STEP_NO           OUT    NUMBER,
        P_OUT_ROOT_PARENT_ID    OUT    NUMBER
    ) IS
        l_parent_step_no    NUMBER;
        l_parent_root_id    NUMBER;
        l_step_no           NUMBER;
        l_root_parent_id    NUMBER;
    BEGIN
        IF P_KODE_REF IS NULL THEN
            P_KODE_REF := GENERATE_KODE_REF;
        END IF;

        IF P_ID_PARENT IS NULL THEN
            -- Record ROOT: titik awal chain
            l_step_no        := 1;
            l_root_parent_id := NULL;
        ELSE
            -- Record CHILD: ambil STEP_NO & ROOT dari parent
            SELECT STEP_NO,
                   NVL(ROOT_PARENT_ID, ID)   -- jika parent itu sendiri root, root-nya = ID parent
              INTO l_parent_step_no,
                   l_parent_root_id
              FROM BJKT_DIGSLIP_KODE_REFERAL
             WHERE ID = P_ID_PARENT;

            l_step_no        := l_parent_step_no + 1;
            l_root_parent_id := l_parent_root_id;
        END IF;

        INSERT INTO BJKT_DIGSLIP_KODE_REFERAL (
            KODE_REF,
            ID_TRANSAKSI,
            TIPE_TRANSAKSI,
            STATUS,
            EXPIRED_AT,
            PARENT_ID,
            STEP_NO,
            ROOT_PARENT_ID
        ) VALUES (
            P_KODE_REF,
            P_ID_TRANSAKSI,
            P_TIPE_TRANSAKSI,
            C_STATUS_GENERATED,
            P_EXPIRED_AT,
            P_ID_PARENT,
            l_step_no,
            l_root_parent_id
        )
        RETURNING ID INTO P_OUT_ID;

        P_OUT_STEP_NO        := l_step_no;
        P_OUT_ROOT_PARENT_ID := l_root_parent_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20004,
                'Record parent BJKT_DIGSLIP_KODE_REFERAL tidak ditemukan. PARENT_ID=' || P_ID_PARENT
            );
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(
                -20003,
                'Kode referal sudah digunakan dan masih aktif. KODE_REF=' || P_KODE_REF
            );
    END INSERT_REFERAL;


    PROCEDURE UPDATE_REFERAL (
        P_ID                IN NUMBER,
        P_ID_TRANSAKSI      IN NUMBER DEFAULT NULL,
        P_TIPE_TRANSAKSI    IN VARCHAR2 DEFAULT NULL,
        P_EXPIRED_AT        IN TIMESTAMP DEFAULT NULL
    ) IS
        V_EXISTS NUMBER;
    BEGIN
        SELECT COUNT(1)
          INTO V_EXISTS
          FROM BJKT_DIGSLIP_KODE_REFERAL
         WHERE ID = P_ID;

        IF V_EXISTS = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Record BJKT_DIGSLIP_KODE_REFERAL tidak ditemukan. ID=' || P_ID
            );
        END IF;

        UPDATE BJKT_DIGSLIP_KODE_REFERAL
           SET ID_TRANSAKSI   = NVL(P_ID_TRANSAKSI, ID_TRANSAKSI),
               TIPE_TRANSAKSI = NVL(P_TIPE_TRANSAKSI, TIPE_TRANSAKSI),
               EXPIRED_AT     = NVL(P_EXPIRED_AT, EXPIRED_AT)
         WHERE ID = P_ID;
    END UPDATE_REFERAL;


    PROCEDURE PROCESS_REFERAL (
        P_ID                    IN NUMBER,
        P_PROCESS_CABANG_CODE   IN VARCHAR2
    ) IS
        V_CURRENT_STATUS VARCHAR2(20);
    BEGIN
        PV_CHECK_STATUS(P_ID, C_STATUS_GENERATED, V_CURRENT_STATUS);

        UPDATE BJKT_DIGSLIP_KODE_REFERAL
           SET STATUS              = C_STATUS_PROCESSED,
               PROCESS_CABANG_CODE = P_PROCESS_CABANG_CODE,
               PROCESSED_BY        = NVL(V('APP_USER'), USER),
               PROCESSED_AT        = SYSTIMESTAMP
         WHERE ID = P_ID;
    END PROCESS_REFERAL;


    PROCEDURE COMPLETE_REFERAL (
        P_ID            IN NUMBER
    ) IS
        V_CURRENT_STATUS VARCHAR2(20);
    BEGIN
        PV_CHECK_STATUS(P_ID, C_STATUS_PROCESSED, V_CURRENT_STATUS);

        UPDATE BJKT_DIGSLIP_KODE_REFERAL
           SET STATUS       = C_STATUS_COMPLETED,
               COMPLETED_BY = NVL(V('APP_USER'), USER),
               COMPLETED_AT = SYSTIMESTAMP
         WHERE ID = P_ID;
    END COMPLETE_REFERAL;


    PROCEDURE CANCEL_REFERAL (
        P_ID            IN NUMBER,
        P_CANCEL_REASON IN VARCHAR2
    ) IS
        V_CURRENT_STATUS VARCHAR2(20);
    BEGIN
        SELECT STATUS
          INTO V_CURRENT_STATUS
          FROM BJKT_DIGSLIP_KODE_REFERAL
         WHERE ID = P_ID
           FOR UPDATE;

        IF V_CURRENT_STATUS NOT IN (C_STATUS_GENERATED, C_STATUS_PROCESSED) THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'Status tidak valid untuk dibatalkan. ID=' || P_ID ||
                ', Status saat ini=' || V_CURRENT_STATUS
            );
        END IF;

        UPDATE BJKT_DIGSLIP_KODE_REFERAL
           SET STATUS        = C_STATUS_CANCELLED,
               CANCELLED_BY  = NVL(V('APP_USER'), USER),
               CANCELLED_AT  = SYSTIMESTAMP,
               CANCEL_REASON = P_CANCEL_REASON
         WHERE ID = P_ID;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Record BJKT_DIGSLIP_KODE_REFERAL tidak ditemukan. ID=' || P_ID
            );
    END CANCEL_REFERAL;


    PROCEDURE EXPIRE_REFERAL (
        P_ID                    IN NUMBER
    ) IS
        V_CURRENT_STATUS VARCHAR2(20);
    BEGIN
        SELECT STATUS
          INTO V_CURRENT_STATUS
          FROM BJKT_DIGSLIP_KODE_REFERAL
         WHERE ID = P_ID
           FOR UPDATE;

        IF V_CURRENT_STATUS NOT IN (C_STATUS_GENERATED, C_STATUS_PROCESSED) THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'Status tidak valid untuk di-expired-kan. ID=' || P_ID ||
                ', Status saat ini=' || V_CURRENT_STATUS
            );
        END IF;

        UPDATE BJKT_DIGSLIP_KODE_REFERAL
           SET STATUS               = C_STATUS_EXPIRED,
               EXPIRED_PROCESSED_BY = NVL(V('APP_USER'), USER),
               EXPIRED_PROCESSED_AT = SYSTIMESTAMP
         WHERE ID = P_ID;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Record BJKT_DIGSLIP_KODE_REFERAL tidak ditemukan. ID=' || P_ID
            );
    END EXPIRE_REFERAL;


    PROCEDURE EXPIRE_OVERDUE_REFERAL (
        P_EXPIRED_PROCESSED_BY  IN VARCHAR2 DEFAULT 'SYSTEM'
    ) IS
    BEGIN
        UPDATE BJKT_DIGSLIP_KODE_REFERAL
           SET STATUS               = C_STATUS_EXPIRED,
               EXPIRED_PROCESSED_BY = P_EXPIRED_PROCESSED_BY,
               EXPIRED_PROCESSED_AT = SYSTIMESTAMP
         WHERE STATUS IN (C_STATUS_GENERATED, C_STATUS_PROCESSED)
           AND EXPIRED_AT < SYSTIMESTAMP;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END EXPIRE_OVERDUE_REFERAL;


    FUNCTION GET_ROOT_ID (
        P_ID IN NUMBER
    ) RETURN NUMBER IS
        l_root_parent_id NUMBER;
    BEGIN
        SELECT NVL(ROOT_PARENT_ID, ID)
          INTO l_root_parent_id
          FROM BJKT_DIGSLIP_KODE_REFERAL
         WHERE ID = P_ID;

        RETURN l_root_parent_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Record BJKT_DIGSLIP_KODE_REFERAL tidak ditemukan. ID=' || P_ID
            );
    END GET_ROOT_ID;

END BJKT_DIGSLIP_KODE_REFERAL_PKG;
/