CREATE OR REPLACE PACKAGE BJKT_UPLOAD_BANSOS_PKG AS

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

    PROCEDURE VALIDATE_MASTER (
        p_batch_id      IN  NUMBER,
        r_valid_count   OUT NUMBER,
        r_error_count   OUT NUMBER
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