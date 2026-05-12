CREATE OR REPLACE PACKAGE BJKT_UPLOAD_BANSOS_PKG AS

    PROCEDURE CREATE_PROGRAM (
        p_program_id    IN  NUMBER,
        p_upload_name   IN  VARCHAR2,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    );

    -- Parsing CSV -> Staging
    PROCEDURE INSERT_STAGING (
        p_upload_name       IN  VARCHAR2,
        p_batch_id          IN  NUMBER,
        p_upload_bansos_id  IN  NUMBER,
        p_program_id        IN  NUMBER,
        r_total_rows        OUT NUMBER,
        r_status            OUT VARCHAR2,
        r_message           OUT VARCHAR2
    );

    -- Validasi semua kolom master
    PROCEDURE VALIDATE_MASTER (
        p_batch_id      IN  NUMBER,
        r_valid_count   OUT NUMBER,
        r_error_count   OUT NUMBER
    );

    -- Insert VALID -> Target, flag ERROR ke staging
    PROCEDURE FINAL_INSERT (
        p_batch_id      IN  NUMBER,
        p_program_id    IN  NUMBER,
        r_loaded_count  OUT NUMBER,
        r_error_count   OUT NUMBER,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    );

END BJKT_UPLOAD_BANSOS_PKG;
/