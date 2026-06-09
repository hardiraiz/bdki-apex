CREATE OR REPLACE PACKAGE BJKT_PNL_REFRESH_DATA_PKG AS
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

    -- Refresh single MV
    PROCEDURE REFRESH_SINGLE (
        p_mv_name   IN VARCHAR2,
        p_method    IN VARCHAR2 DEFAULT 'C'  -- 'C' = Complete, 'F' = Fast, '?' = Force
    );

    -- Refresh multiple MV sekaligus (list dipisah koma)
    PROCEDURE REFRESH_LIST (
        p_mv_list   IN VARCHAR2,             -- contoh: 'MV_PNL,MV_DPK,MV_KREDIT'
        p_method    IN VARCHAR2 DEFAULT 'C'
    );

    -- Refresh semua MV yang terdaftar di tabel konfigurasi
    PROCEDURE REFRESH_ALL_REGISTERED;

END BJKT_PNL_REFRESH_DATA_PKG;
/