CREATE OR REPLACE PACKAGE BJKT_UPLOAD_BANSOS_PKG AS
/*
|--------------------------------------------------------------------------
| Package Name : BJKT_UPLOAD_BANSOS_PKG
| Description  : Package digunakan untuk proses upload data penerima program bansos.
|
| Created By   : Hardi Raiz
| Created Date : 19-May-2026
| Version      : 1.0
|
| Modification History
|--------------------------------------------------------------------------
| No | Date        | Developer   | Description
|--------------------------------------------------------------------------
| 1  | 19-May-2026 | Hardi Raiz  | Initial package creation
|--------------------------------------------------------------------------
*/

    TYPE t_validation_rec IS RECORD (
        nama                   BJKT_BANSOS_RECIPIENTS_STG.NAMA%TYPE,
        tempat_lahir           BJKT_BANSOS_RECIPIENTS_STG.TEMPAT_LAHIR%TYPE,
        no_identitas           BJKT_BANSOS_RECIPIENTS_STG.NO_IDENTITAS%TYPE,
        agama                  BJKT_BANSOS_RECIPIENTS_STG.AGAMA%TYPE,
        status_kawin           BJKT_BANSOS_RECIPIENTS_STG.STATUS_KAWIN%TYPE,
        jen_kelamin            BJKT_BANSOS_RECIPIENTS_STG.JEN_KELAMIN%TYPE,
        pendidikan             BJKT_BANSOS_RECIPIENTS_STG.PENDIDIKAN%TYPE,
        status_rumah           BJKT_BANSOS_RECIPIENTS_STG.STATUS_RUMAH%TYPE,
        kode_profesi           BJKT_BANSOS_RECIPIENTS_STG.KODE_PROFESI%TYPE,
        status_pekerjaan       BJKT_BANSOS_RECIPIENTS_STG.STATUS_PEKERJAAN%TYPE,
        hubungan               BJKT_BANSOS_RECIPIENTS_STG.HUBUNGAN%TYPE,
        status_instansi        BJKT_BANSOS_RECIPIENTS_STG.STATUS_INSTANSI%TYPE,
        tanggal_lahir          BJKT_BANSOS_RECIPIENTS_STG.TANGGAL_LAHIR%TYPE,
        kebangsaan             BJKT_BANSOS_RECIPIENTS_STG.KEBANGSAAN%TYPE,
        pekerjaan_bidang_usaha BJKT_BANSOS_RECIPIENTS_STG.PEKERJAAN_BIDANG_USAHA%TYPE
    );

    -- Inti validasi
    PROCEDURE VALIDATE_ROW (
        p_rec                IN  t_validation_rec,
        r_is_valid           OUT BOOLEAN,
        r_error_columns      OUT VARCHAR2,
        r_error_details_json OUT CLOB
    );

    PROCEDURE VALIDATE_BY_ID (
        p_id                 IN  NUMBER,
        p_source             IN  VARCHAR2, -- 'STG' atau 'ERR'
        r_is_valid           OUT VARCHAR2, -- 'Y'/'N'
        r_error_columns      OUT VARCHAR2,
        r_error_details_json OUT CLOB
    );

    PROCEDURE VALIDATE_MASTER (
        p_batch_id    IN  NUMBER,
        r_valid_count OUT NUMBER,
        r_error_count OUT NUMBER
    );

    PROCEDURE REVALIDATE_ERROR_ROW (
        p_err_id  IN  NUMBER,
        r_status  OUT VARCHAR2,
        r_message OUT VARCHAR2
    );

    PROCEDURE CREATE_PROGRAM (
        p_program_id    IN  NUMBER,
        p_upload_name   IN  VARCHAR2,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    );

    PROCEDURE INSERT_STAGING (
        p_upload_name       IN  VARCHAR2,
        p_batch_id          IN  NUMBER,
        p_upload_bansos_id  IN  NUMBER,
        p_program_id        IN  NUMBER,
        r_total_rows        OUT NUMBER,
        r_status            OUT VARCHAR2,
        r_message           OUT VARCHAR2
    );

    PROCEDURE FINAL_INSERT (
        p_batch_id      IN  NUMBER,
        p_program_id    IN  NUMBER,
        r_loaded_count  OUT NUMBER,
        r_error_count   OUT NUMBER,
        r_skipped_count OUT NUMBER,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    );

    PROCEDURE MARK_DUPLICATE (
        p_batch_id      IN  NUMBER,
        p_program_id    IN  NUMBER,
        r_skipped_count OUT NUMBER
    );

    PROCEDURE PURGE_STAGING (
        p_batch_id          IN  NUMBER,
        r_purged_count      OUT NUMBER,
        r_status            OUT VARCHAR2,
        r_message           OUT VARCHAR2
    );

END BJKT_UPLOAD_BANSOS_PKG;
/