CREATE OR REPLACE PACKAGE BODY BJKT_PNL_REFRESH_DATA_PKG AS
/*
|--------------------------------------------------------------------------
| Package Name : BJKT_PNL_REFRESH_DATA_PKG
| Description  : Package digunakan untuk proses refresh data DBLink.
|
| Created By   : Hardi Raiz
| Created Date : 3-Jun-2026
| Version      : 1.0
|
| Modification History
|--------------------------------------------------------------------------
| No | Date        | Developer   | Description
|--------------------------------------------------------------------------
| 1  | 3-Jun-2026  | Hardi Raiz  | Initial package creation
|--------------------------------------------------------------------------
*/

    -- PRIVATE: Logging ke tabel mv_refresh_log
    PROCEDURE LOG_REFRESH (
        p_mv_name   IN VARCHAR2,
        p_status    IN VARCHAR2,
        p_message   IN VARCHAR2 DEFAULT NULL
    ) AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE BJKT_PNL_REFRESH_LOG
        SET
            refresh_end  = SYSTIMESTAMP,
            duration_sec = ROUND((
                                CAST(SYSTIMESTAMP AS DATE) 
                                - CAST(refresh_start AS DATE)) 
                                * 86400, 2
                           ),
            status        = p_status,
            error_message = p_message
        WHERE mv_name = p_mv_name
          AND status IS NULL;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END LOG_REFRESH;


    -- PRIVATE: Insert log awal (status masih NULL = in-progress)
    PROCEDURE LOG_START (
        p_mv_name IN VARCHAR2
    ) AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO BJKT_PNL_REFRESH_LOG (mv_name, refresh_start)
        VALUES (p_mv_name, SYSTIMESTAMP);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END LOG_START;


    -- PUBLIC: Refresh single MV
    PROCEDURE REFRESH_SINGLE (
        p_mv_name   IN VARCHAR2,
        p_method    IN VARCHAR2 DEFAULT 'C'
    ) AS
        v_mv_name   VARCHAR2(100) := UPPER(TRIM(p_mv_name));
    BEGIN
        LOG_START(v_mv_name);

        DBMS_MVIEW.REFRESH(
            list   => v_mv_name,
            method => p_method
        );

        LOG_REFRESH(v_mv_name, 'SUCCESS');
        DBMS_OUTPUT.PUT_LINE('[OK] ' || v_mv_name || ' refreshed at ' || TO_CHAR(SYSTIMESTAMP, 'DD-MON-YYYY HH24:MI:SS'));
    EXCEPTION
        WHEN OTHERS THEN
            LOG_REFRESH(v_mv_name, 'FAILED', SQLERRM);
            DBMS_OUTPUT.PUT_LINE('[ERROR] ' || v_mv_name || ': ' || SQLERRM);
            -- Tidak di-raise agar MV lain tetap lanjut diproses
    END REFRESH_SINGLE;


    -- PUBLIC: Refresh list MV (dipisah koma)
    PROCEDURE REFRESH_LIST (
        p_mv_list   IN VARCHAR2,
        p_method    IN VARCHAR2 DEFAULT 'C'
    ) AS
        v_list      VARCHAR2(4000) := p_mv_list;
        v_mv_name   VARCHAR2(100);
        v_pos       NUMBER;
    BEGIN
        LOOP
            v_pos := INSTR(v_list, ',');

            IF v_pos > 0 THEN
                v_mv_name := TRIM(SUBSTR(v_list, 1, v_pos - 1));
                v_list    := SUBSTR(v_list, v_pos + 1);
            ELSE
                v_mv_name := TRIM(v_list);
                v_list    := NULL;
            END IF;

            IF v_mv_name IS NOT NULL THEN
                REFRESH_SINGLE(v_mv_name, p_method);
            END IF;

            EXIT WHEN v_list IS NULL;
        END LOOP;
    END REFRESH_LIST;


    -- PUBLIC: Refresh semua MV terdaftar di mv_refresh_config
    PROCEDURE REFRESH_ALL_REGISTERED AS
        CURSOR c_mv IS
            SELECT MV_NAME, REFRESH_METHOD
            FROM   BJKT_PNL_REFRESH_CONFIG
            WHERE  IS_ACTIVE = 'Y'
            ORDER BY REFRESH_ORDER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== MV Refresh dimulai: ' || TO_CHAR(SYSTIMESTAMP, 'DD-MON-YYYY HH24:MI:SS') || ' ===');

        FOR r IN c_mv LOOP
            REFRESH_SINGLE(r.mv_name, r.refresh_method);
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('=== MV Refresh selesai: ' || TO_CHAR(SYSTIMESTAMP, 'DD-MON-YYYY HH24:MI:SS') || ' ===');
    END REFRESH_ALL_REGISTERED;

END BJKT_PNL_REFRESH_DATA_PKG;
/