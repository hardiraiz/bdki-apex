CREATE OR REPLACE PACKAGE BJKT_DIGSLIP_SETOR_TUNAI_PKG AS
/*
================================================================================
Package      : BJKT_DIGSLIP_SETOR_TUNAI_PKG
Purpose      : Mengelola proses submit transaksi Setor Tunai dari e-Form, termasuk:
                - Insert data transaksi dari APEX_COLLECTIONS
                - Generate kode referal via BJKT_DIGSLIP_KODE_REFERAL_PKG
                - Kirim notifikasi email
                - Clear page cache APEX setelah submit
Dependency   : BJKT_DIGSLIP_KODE_REFERAL_PKG (untuk insert kode referal)

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

    C_TIPE_TRANSAKSI    CONSTANT VARCHAR2(25) := 'SETOR_TUNAI';
    C_DEFAULT_EXP_MIN   CONSTANT NUMBER       := 60; -- menit default masa berlaku kode referal

    /* Membaca data dari APEX_COLLECTIONS (data pelaku & data penerima),
    insert ke BJKT_DIGSLIP_SETOR_TUNAI untuk setiap baris penerima,
    lalu generate kode referal untuk setiap transaksi via
    BJKT_DIGSLIP_KODE_REFERAL_PKG.INSERT_REFERAL. */
    PROCEDURE INSERT_SETOR_TUNAI (
        P_KODE_REF                  IN OUT VARCHAR2,
        P_PARENT_ID                 IN     NUMBER DEFAULT NULL,
        P_CHECK_SYARAT_KETENTUAN    IN     VARCHAR2,
        P_EXPIRED_MINUTES           IN     NUMBER DEFAULT C_DEFAULT_EXP_MIN,
        P_OUT_ID                    OUT    NUMBER,
        P_OUT_EXPIRED_AT            OUT    TIMESTAMP,
        P_OUT_CREATION_DATE         OUT    TIMESTAMP,
        P_OUT_STEP_NO               OUT    NUMBER,
        P_OUT_ROOT_PARENT_ID        OUT    NUMBER
    );

    PROCEDURE BUILD_EMAIL_HTML (
        P_NAMA_PENERIMA     IN  VARCHAR2,
        P_CREATION_DATE     IN  TIMESTAMP,
        P_NOREK             IN  VARCHAR2,
        P_NOMINAL           IN  NUMBER,
        P_BERITA            IN  VARCHAR2,
        P_EXPIRED_AT        IN  TIMESTAMP,
        P_KODE_REF          IN  VARCHAR2,
        P_TAHUN             IN  VARCHAR2,
        P_OUT_HTML          OUT CLOB
    );

    PROCEDURE SEND_EMAIL_NOTIFICATION (
        P_EMAIL_TO          IN  VARCHAR2,
        P_NAMA_PENERIMA     IN  VARCHAR2,
        P_CREATION_DATE     IN  TIMESTAMP,
        P_NOREK             IN  VARCHAR2,
        P_NOMINAL           IN  NUMBER,
        P_BERITA            IN  VARCHAR2,
        P_EXPIRED_AT        IN  TIMESTAMP,
        P_KODE_REF          IN  VARCHAR2,
        P_TAHUN             IN  VARCHAR2
    );

    PROCEDURE CLEAR_FORM_PAGE_CACHE;

    /* Orchestrator: memanggil INSERT_SETOR_TUNAI, lalu
    SEND_EMAIL_NOTIFICATION, lalu CLEAR_FORM_PAGE_CACHE.
    Ini adalah satu pintu masuk utama yang dipanggil dari APEX */
    PROCEDURE PROCESS_SETOR_TUNAI_SUBMIT (
        P_KODE_REF                  IN OUT VARCHAR2,
        P_PARENT_ID                 IN     NUMBER DEFAULT NULL,
        P_CHECK_SYARAT_KETENTUAN    IN     VARCHAR2,
        P_EMAIL_TO                  IN     VARCHAR2,
        P_TAHUN                     IN     VARCHAR2,
        P_EXPIRED_MINUTES           IN     NUMBER DEFAULT C_DEFAULT_EXP_MIN,
        P_OUT_ID                    OUT    NUMBER,
        P_OUT_STEP_NO               OUT    NUMBER,
        P_OUT_ROOT_PARENT_ID        OUT    NUMBER
    );

END BJKT_DIGSLIP_SETOR_TUNAI_PKG;
/