CREATE OR REPLACE PACKAGE BJKT_DIGSLIP_KODE_REFERAL_PKG AS
/*
================================================================================
Package      : BJKT_DIGSLIP_KODE_REFERAL_PKG
Purpose      : Mengelola data BJKT_DIGSLIP_KODE_REFERAL (insert, update status,
               generate kode referal, dan helper terkait).
Catatan      : - Kolom ID, CREATED_DATE, GENERATE_DATE di-handle oleh trigger
                 BJKT_DIGSLIP_KODE_REFERAL_TRG saat INSERT.
               - Kolom LAST_UPDATED_BY, LAST_UPDATE_DATE di-handle oleh trigger
                 saat UPDATE.
               - ID_PARENT diasumsikan ada di tabel (lihat unique index U1).
                 Sesuaikan/insert NULL jika kolom belum ditambahkan.

Created By   : Hardi Raiz
Created Date : 23-Jun-2026
Version      : 1.0

Modification History
|--------------------------------------------------------------------------
| No | Date        | Developer   | Description
|--------------------------------------------------------------------------
| 1  | 23-Jun-2026 | Hardi Raiz  | Initial package creation
|--------------------------------------------------------------------------
================================================================================
*/

    C_STATUS_GENERATED      CONSTANT VARCHAR2(20) := 'GENERATED';
    C_STATUS_PROCESSED      CONSTANT VARCHAR2(20) := 'PROCESSED';
    C_STATUS_COMPLETED      CONSTANT VARCHAR2(20) := 'COMPLETED';
    C_STATUS_CANCELLED      CONSTANT VARCHAR2(20) := 'CANCELLED';
    C_STATUS_EXPIRED        CONSTANT VARCHAR2(20) := 'EXPIRED';

    E_RECORD_NOT_FOUND      EXCEPTION;
    E_INVALID_STATUS        EXCEPTION;
    E_KODE_REF_NOT_UNIQUE   EXCEPTION;
    E_PARENT_NOT_FOUND      EXCEPTION;

    PRAGMA EXCEPTION_INIT(E_RECORD_NOT_FOUND, -20001);
    PRAGMA EXCEPTION_INIT(E_INVALID_STATUS, -20002);
    PRAGMA EXCEPTION_INIT(E_KODE_REF_NOT_UNIQUE, -20003);
    PRAGMA EXCEPTION_INIT(E_PARENT_NOT_FOUND, -20004);

    FUNCTION GENERATE_KODE_REF
        RETURN VARCHAR2;

    -- Insert record baru dengan status default GENERATED.
    -- KODE_REF (jika NULL akan di-generate otomatis)
    PROCEDURE INSERT_REFERAL (
        P_KODE_REF              IN OUT VARCHAR2,
        P_ID_TRANSAKSI          IN     NUMBER,
        P_TIPE_TRANSAKSI        IN     VARCHAR2,
        P_EXPIRED_AT            IN     TIMESTAMP,
        P_ID_PARENT             IN     NUMBER DEFAULT NULL,
        P_OUT_ID                OUT    NUMBER,
        P_OUT_STEP_NO           OUT    NUMBER,
        P_OUT_ROOT_PARENT_ID    OUT    NUMBER
    );

    PROCEDURE UPDATE_REFERAL (
        P_ID                IN NUMBER,
        P_ID_TRANSAKSI      IN NUMBER DEFAULT NULL,
        P_TIPE_TRANSAKSI    IN VARCHAR2 DEFAULT NULL,
        P_EXPIRED_AT        IN TIMESTAMP DEFAULT NULL
    );

    -- Set status -> PROCESSED. Hanya valid dari status GENERATED.
    PROCEDURE PROCESS_REFERAL (
        P_ID                    IN NUMBER,
        P_PROCESS_CABANG_CODE   IN VARCHAR2
    );

    -- Set status -> COMPLETED. Hanya valid dari status PROCESSED.
    PROCEDURE COMPLETE_REFERAL (
        P_ID            IN NUMBER
    );

    -- Set status -> CANCELLED. Valid dari status GENERATED atau PROCESSED.
    PROCEDURE CANCEL_REFERAL (
        P_ID            IN NUMBER,
        P_CANCEL_REASON IN VARCHAR2
    );

    -- Set status -> EXPIRED untuk satu record (dipanggil manual).
    PROCEDURE EXPIRE_REFERAL (
        P_ID                    IN NUMBER
    );

    -- Batch process: set status -> EXPIRED untuk semua record yang
    -- EXPIRED_AT < SYSTIMESTAMP dan status masih GENERATED/PROCESSED.
    PROCEDURE EXPIRE_OVERDUE_REFERAL (
        P_EXPIRED_PROCESSED_BY  IN VARCHAR2 DEFAULT 'SYSTEM'
    );

    FUNCTION GET_ROOT_ID (
        P_ID IN NUMBER
    ) RETURN NUMBER;

END BJKT_DIGSLIP_KODE_REFERAL_PKG;
/