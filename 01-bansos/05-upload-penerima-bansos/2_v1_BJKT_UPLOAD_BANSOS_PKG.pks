create or replace package "BJKT_UPLOAD_BANSOS_PKG" as

    PROCEDURE CREATE_PROGRAM (
        p_program_id    IN  NUMBER,
        p_upload_name   IN  VARCHAR2,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    );    

end "BJKT_UPLOAD_BANSOS_PKG";