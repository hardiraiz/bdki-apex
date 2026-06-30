CREATE OR REPLACE PACKAGE BJKT_DIGSLIP_PELAKU_TRANSAKSI_PKG AS
/*
================================================================================
Package      : BJKT_DIGSLIP_PELAKU_TRANSAKSI_PKG
Purpose      : Mengelola proses submit Input Form Pelaku Transaksi (APEX page 3010), termasuk:
                - Insert data pelaku dari APEX_COLLECTIONS
                - Generate kode referal ROOT via BJKT_DIGSLIP_KODE_REFERAL_PKG
                (PARENT_ID = NULL, karena pelaku transaksi adalah titik awal
                flow -> kode referal ini nantinya menjadi ROOT_PARENT_ID/
                PARENT_ID untuk transaksi child, contoh: Setor Tunai)
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

    C_TIPE_TRANSAKSI    CONSTANT VARCHAR2(25) := 'PELAKU_TRANSAKSI';
    C_DEFAULT_EXP_MIN   CONSTANT NUMBER       := 60; -- menit


    /* Membaca data dari APEX_COLLECTIONS 'BJKT_DIGSLIP_INPUT_PELAKU_TRANSAKSI',
    insert ke BJKT_DIGSLIP_PELAKU_TRANSAKSI untuk setiap baris,
    lalu generate kode referal ROOT (PARENT_ID NULL) via
    BJKT_DIGSLIP_KODE_REFERAL_PKG.INSERT_REFERAL */
    PROCEDURE INSERT_PELAKU_TRANSAKSI (
        P_CHECK_SYARAT_KETENTUAN    IN  VARCHAR2,
        P_EXPIRED_MINUTES           IN  NUMBER DEFAULT C_DEFAULT_EXP_MIN,
        P_OUT_ID                    OUT NUMBER,
        P_OUT_KODE_REF              OUT VARCHAR2,
        P_OUT_EXPIRED_AT            OUT TIMESTAMP,
        P_OUT_CREATION_DATE         OUT TIMESTAMP,
        P_OUT_REFERAL_ID            OUT NUMBER
    );

    PROCEDURE BUILD_EMAIL_HTML (
        P_NAMA_LENGKAP      IN  VARCHAR2,
        P_CREATION_DATE     IN  TIMESTAMP,
        P_EXPIRED_AT        IN  TIMESTAMP,
        P_KODE_REF          IN  VARCHAR2,
        P_TAHUN             IN  VARCHAR2,
        P_OUT_HTML          OUT VARCHAR2
    );

    PROCEDURE SEND_EMAIL_NOTIFICATION (
        P_EMAIL_TO          IN  VARCHAR2,
        P_NAMA_LENGKAP      IN  VARCHAR2,
        P_CREATION_DATE     IN  TIMESTAMP,
        P_EXPIRED_AT        IN  TIMESTAMP,
        P_KODE_REF          IN  VARCHAR2,
        P_TAHUN             IN  VARCHAR2
    );

    PROCEDURE CLEAR_FORM_PAGE_CACHE;

    /* Orchestrator: memanggil INSERT_PELAKU_TRANSAKSI, lalu
    SEND_EMAIL_NOTIFICATION, lalu CLEAR_FORM_PAGE_CACHE.
    Satu pintu masuk utama dipanggil dari APEX */
    PROCEDURE PROCESS_PELAKU_TRANSAKSI_SUBMIT (
        P_CHECK_SYARAT_KETENTUAN    IN  VARCHAR2,
        P_EMAIL_TO                  IN  VARCHAR2,
        P_NAMA_LENGKAP              IN  VARCHAR2,
        P_TAHUN                     IN  VARCHAR2,
        P_EXPIRED_MINUTES           IN  NUMBER DEFAULT C_DEFAULT_EXP_MIN,
        P_OUT_ID                    OUT NUMBER,
        P_OUT_KODE_REF              OUT VARCHAR2,
        P_OUT_REFERAL_ID            OUT NUMBER
    );

END BJKT_DIGSLIP_PELAKU_TRANSAKSI_PKG;
/