-- ## 1. Buat directory folder di server Oracle ##
/*
    mkdir -p /home/oracle/bjkt_files
    chmod 755 /home/oracle/bjkt_files
*/

-- ## 2. Buat Directory di Database Oracle LOGIN SEBAGAI SYS ##
CREATE OR REPLACE DIRECTORY BJKT_FILES_DIR AS '/home/oracle/bjkt_files';
/

GRANT READ, WRITE ON DIRECTORY BJKT_FILES_DIR TO DEV;
/

-- ## 3. Cek apakah directory berhasil dibuat ##
SELECT * FROM all_directories WHERE directory_name = 'BJKT_FILES_DIR';
/

-- ## 4. Buat table untuk log upload file ##
DROP TABLE BJKT_FILE_UPLOAD_LOG;
/

CREATE TABLE BJKT_FILE_UPLOAD_LOG (
    id                  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    file_name           VARCHAR2(1000),
    file_name_server    VARCHAR2(1000),
    file_path           VARCHAR2(1000),
    file_size           NUMBER,
    mime_type           VARCHAR2(200),
    uploaded_by         VARCHAR2(100),
    uploaded_at         TIMESTAMP DEFAULT SYSTIMESTAMP
);
/