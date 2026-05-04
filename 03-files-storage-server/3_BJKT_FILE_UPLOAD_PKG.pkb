create or replace package body "BJKT_FILE_UPLOAD_PKG" as

    l_path_file_storage VARCHAR2(200) := '/home/oracle/bjkt_files/';
    l_dir_name          VARCHAR2(100) := 'BJKT_FILES_DIR';

    PROCEDURE save_file_to_server (
        p_file_name   IN VARCHAR2,
        p_mime_type   IN VARCHAR2,
        p_file_blob   IN BLOB,
        r_status      OUT VARCHAR2,
        r_message     OUT VARCHAR2
    ) AS
        v_file        UTL_FILE.FILE_TYPE;
        v_buffer      RAW(32767);
        v_amount      BINARY_INTEGER := 32767;
        v_pos         INTEGER := 1;
        v_blob_len    INTEGER;
        v_safe_name   VARCHAR2(500);
        v_timestamp   VARCHAR2(30);
    BEGIN
        -- Tambahkan timestamp agar nama file unik
        v_timestamp := TO_CHAR(SYSTIMESTAMP, 'YYYYMMDD_HH24MISS_FF3');
        v_safe_name := v_timestamp || '_' || REGEXP_REPLACE(p_file_name, '[^A-Za-z0-9._-]', '_');

        v_blob_len := DBMS_LOB.GETLENGTH(p_file_blob);

        -- Buka file di server untuk ditulis
        v_file := UTL_FILE.FOPEN(l_dir_name, v_safe_name, 'WB', 32767);

        -- Tulis BLOB ke file secara bertahap (chunk)
        WHILE v_pos <= v_blob_len LOOP
            IF v_pos + v_amount - 1 > v_blob_len THEN
                v_amount := v_blob_len - v_pos + 1;
            END IF;

            DBMS_LOB.READ(p_file_blob, v_amount, v_pos, v_buffer);
            UTL_FILE.PUT_RAW(v_file, v_buffer, TRUE);

            v_pos := v_pos + v_amount;
            v_amount := 32767;
        END LOOP;

        UTL_FILE.FCLOSE(v_file);

        -- Simpan metadata ke log table
        INSERT INTO BJKT_FILE_UPLOAD_LOG (file_name, file_name_server, file_path, file_size, mime_type, uploaded_by)
        VALUES (
            p_file_name,
            v_safe_name,
            l_path_file_storage || v_safe_name,
            v_blob_len,
            p_mime_type,
            NVL(V('APP_USER'), USER)
        );

        COMMIT;

        r_status    := 'SUCCESS';
        r_message   := 'Upload file complete!';

    EXCEPTION
        WHEN OTHERS THEN
            r_status    := 'ERROR';
            r_message   := SQLERRM;

            IF UTL_FILE.IS_OPEN(v_file) THEN
                UTL_FILE.FCLOSE(v_file);
            END IF;
            ROLLBACK;
            RAISE;
    END save_file_to_server;

    PROCEDURE get_file_from_server(
        p_file_id       IN  NUMBER,
        r_file_blob     OUT BLOB,
        r_mime_type     OUT VARCHAR2,
        r_file_size     OUT NUMBER,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    )
    AS
        v_file_name     VARCHAR2(4000);
        v_file          UTL_FILE.FILE_TYPE;
        v_buffer        RAW(32767);
        v_amount        BINARY_INTEGER := 32767;
        v_pos           INTEGER := 1;
        v_temp_blob     BLOB;
    BEGIN
        -- Ambil mime_type dari log
        SELECT mime_type, file_size, file_name_server
        INTO   r_mime_type, r_file_size, v_file_name
        FROM   bjkt_file_upload_log
        WHERE  id = p_file_id;

        -- Buka file dari directory Oracle
        v_file := UTL_FILE.FOPEN(l_dir_name, v_file_name, 'rb', 32767);

        DBMS_LOB.CREATETEMPORARY(v_temp_blob, TRUE);
        DBMS_LOB.OPEN(v_temp_blob, DBMS_LOB.LOB_READWRITE);

        -- Baca file chunk by chunk
        LOOP
            BEGIN
                UTL_FILE.GET_RAW(v_file, v_buffer, v_amount);
                DBMS_LOB.WRITEAPPEND(v_temp_blob, UTL_RAW.LENGTH(v_buffer), v_buffer);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN EXIT;
            END;
        END LOOP;

        UTL_FILE.FCLOSE(v_file);
        r_file_blob := v_temp_blob;

        r_status    := 'SUCCESS';
        r_message   := 'Get file successfully!';

    EXCEPTION
        WHEN OTHERS THEN
            r_status    := 'ERROR';
            r_message   := SQLERRM;

            IF UTL_FILE.IS_OPEN(v_file) THEN
                UTL_FILE.FCLOSE(v_file);
            END IF;
            RAISE;
    END;  

    PROCEDURE delete_file_from_server(
        p_file_id   IN  NUMBER,
        r_status    OUT VARCHAR2,
        r_message   OUT VARCHAR2
    )
    AS
        v_file_name         VARCHAR2(1000);
        v_file_name_server  VARCHAR2(1000);
    BEGIN
        -- Cek apakah file ada di log
        SELECT file_name, file_name_server
        INTO v_file_name, v_file_name_server
        FROM bjkt_file_upload_log
        WHERE id = p_file_id;

        -- Hapus file fisik dari directory Oracle
        UTL_FILE.FREMOVE(l_dir_name, v_file_name_server);

        -- Hapus record dari log
        DELETE FROM bjkt_file_upload_log
        WHERE id = p_file_id;

        COMMIT;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            r_status    := 'ERROR';
            r_message   := 'File not found : [' || v_file_name || ']';
        WHEN OTHERS THEN
            r_status    := 'ERROR';
            r_message   := 'Failed to delete : [' || v_file_name || ']: ' || SQLERRM;
            
            ROLLBACK;
    END;

end "BJKT_FILE_UPLOAD_PKG";