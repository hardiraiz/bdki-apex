create or replace package "BJKT_FILE_UPLOAD_PKG" as

    PROCEDURE save_file_to_server(
        p_file_id       IN  NUMBER,
        p_feature_name  IN  VARCHAR2,
        p_source_id     IN  NUMBER,
        p_file_name     IN  VARCHAR2,
        p_mime_type     IN  VARCHAR2,
        p_file_blob     IN  BLOB,
        r_file_id       OUT NUMBER,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    );

    PROCEDURE get_file_from_server(
        p_file_id           IN  NUMBER,
        r_file_name_server  OUT VARCHAR2,
        r_file_blob         OUT BLOB,
        r_mime_type         OUT VARCHAR2,
        r_file_size         OUT NUMBER,
        r_status            OUT VARCHAR2,
        r_message           OUT VARCHAR2
    );  
    
    PROCEDURE delete_file_from_server(
        p_file_id   IN  NUMBER,
        r_status    OUT VARCHAR2,
        r_message   OUT VARCHAR2
    );

end "BJKT_FILE_UPLOAD_PKG";