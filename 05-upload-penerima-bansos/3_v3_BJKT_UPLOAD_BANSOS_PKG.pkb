CREATE OR REPLACE PACKAGE BODY BJKT_UPLOAD_BANSOS_PKG AS

    PROCEDURE INSERT_STAGING (
        p_upload_name       IN  VARCHAR2,
        p_batch_id          IN  NUMBER,
        p_upload_bansos_id  IN  NUMBER,
        p_program_id        IN  NUMBER,
        r_total_rows        OUT NUMBER,
        r_status            OUT VARCHAR2,
        r_message           OUT VARCHAR2
    ) AS
        CURSOR cur IS
            SELECT
                p.line_number,
                p.col001  nama,                     p.col002  jen_kelamin,
                p.col003  kebangsaan,               p.col004  tempat_lahir,
                p.col005  tanggal_lahir,            p.col006  no_identitas,
                p.col007  nama_ibu_kandung_wali,    p.col008  status_kawin,
                p.col009  agama,                    p.col010  pendidikan,
                p.col011  alamat_ktp,               p.col012  alamat_domisili,
                p.col013  rt,                       p.col014  rw,
                p.col015  kelurahan,                p.col016  kecamatan,
                p.col017  kota,                     p.col018  propinsi,
                p.col019  kode_pos,                 p.col020  status_rumah,
                p.col021  telp_hp,                  p.col022  pekerjaan_bidang_usaha,
                p.col023  kode_profesi,             p.col024  status_pekerjaan,
                p.col025  nama_instansi,            p.col026  alamat_instansi,
                p.col027  kode_pos_instansi,        p.col028  no_telp_instansi,
                p.col029  suami_istri,              p.col030  nama_pihak_dihubungi,
                p.col031  hubungan,                 p.col032  alamat,
                p.col033  kota_domisili,            p.col034  propinsi_domisili,
                p.col035  telpon,                   p.col036  nomor_instansi,
                p.col037  status_instansi,          p.col038  total_dana
            FROM apex_application_temp_files f,
                TABLE(apex_data_parser.parse(
                    p_content      => f.blob_content,
                    p_file_name    => f.filename,
                    p_max_rows     => 99999999,
                    p_file_profile => apex_data_loading.get_file_profile(
                                        p_static_id => 'upload_bansos_recipients')
                )) p
            WHERE f.name = p_upload_name
              AND p.line_number > 1;

        TYPE t_rows IS TABLE OF cur%ROWTYPE INDEX BY PLS_INTEGER;
        v_rows  t_rows;
        v_limit PLS_INTEGER := 500;
        v_total NUMBER := 0;

        bulk_errors EXCEPTION;
        PRAGMA EXCEPTION_INIT(bulk_errors, -24381);
    BEGIN
        OPEN cur;
        LOOP
            FETCH cur BULK COLLECT INTO v_rows LIMIT v_limit;
            EXIT WHEN v_rows.COUNT = 0;

            BEGIN
                FORALL i IN 1..v_rows.COUNT SAVE EXCEPTIONS
                    INSERT INTO BJKT_BANSOS_RECIPIENTS_STG (
                        BATCH_ID, UPLOAD_BANSOS_ID, PROGRAM_ID, LINE_NUMBER,
                        NAMA, JEN_KELAMIN, KEBANGSAAN, TEMPAT_LAHIR, TANGGAL_LAHIR,
                        NO_IDENTITAS, NAMA_IBU_KANDUNG_WALI, STATUS_KAWIN, AGAMA,
                        PENDIDIKAN, ALAMAT_KTP, ALAMAT_DOMISILI, RT, RW,
                        KELURAHAN, KECAMATAN, KOTA, PROPINSI, KODE_POS,
                        STATUS_RUMAH, TELP_HP, PEKERJAAN_BIDANG_USAHA, KODE_PROFESI,
                        STATUS_PEKERJAAN, NAMA_INSTANSI, ALAMAT_INSTANSI,
                        KODE_POS_INSTANSI, NO_TELP_INSTANSI, SUAMI_ISTRI,
                        NAMA_PIHAK_DIHUBUNGI, HUBUNGAN, ALAMAT, KOTA_DOMISILI,
                        PROPINSI_DOMISILI, TELPON, NOMOR_INSTANSI, STATUS_INSTANSI,
                        TOTAL_DANA, STATUS
                    ) VALUES (
                        p_batch_id, p_upload_bansos_id, p_program_id, v_rows(i).line_number,
                        v_rows(i).nama, v_rows(i).jen_kelamin, v_rows(i).kebangsaan,
                        v_rows(i).tempat_lahir, v_rows(i).tanggal_lahir,
                        v_rows(i).no_identitas, v_rows(i).nama_ibu_kandung_wali,
                        v_rows(i).status_kawin, v_rows(i).agama, v_rows(i).pendidikan,
                        v_rows(i).alamat_ktp, v_rows(i).alamat_domisili,
                        v_rows(i).rt, v_rows(i).rw, v_rows(i).kelurahan,
                        v_rows(i).kecamatan, v_rows(i).kota, v_rows(i).propinsi,
                        v_rows(i).kode_pos, v_rows(i).status_rumah, v_rows(i).telp_hp,
                        v_rows(i).pekerjaan_bidang_usaha, v_rows(i).kode_profesi,
                        v_rows(i).status_pekerjaan, v_rows(i).nama_instansi,
                        v_rows(i).alamat_instansi, v_rows(i).kode_pos_instansi,
                        v_rows(i).no_telp_instansi, v_rows(i).suami_istri,
                        v_rows(i).nama_pihak_dihubungi, v_rows(i).hubungan,
                        v_rows(i).alamat, v_rows(i).kota_domisili,
                        v_rows(i).propinsi_domisili, v_rows(i).telpon,
                        v_rows(i).nomor_instansi, v_rows(i).status_instansi,
                        v_rows(i).total_dana, 'PENDING'
                    );

                v_total := v_total + v_rows.COUNT;
                COMMIT;

            EXCEPTION
                WHEN bulk_errors THEN
                    ROLLBACK;
                    IF cur%ISOPEN THEN CLOSE cur; END IF;
                    r_status  := 'ERROR';
                    r_message := 'Staging insert failed. Error count: '
                                 || SQL%BULK_EXCEPTIONS.COUNT;
                    RETURN;
            END;
        END LOOP;
        CLOSE cur;

        r_total_rows := v_total;
        r_status     := 'SUCCESS';
        r_message    := 'Staging berhasil: ' || v_total || ' baris.';

    EXCEPTION
        WHEN OTHERS THEN
            IF cur%ISOPEN THEN CLOSE cur; END IF;
            ROLLBACK;

            r_status  := 'ERROR';
            r_message := 'INSERT_STAGING error: ' || SQLERRM;
    END INSERT_STAGING;


    PROCEDURE VALIDATE_MASTER (
        p_batch_id      IN  NUMBER,
        r_valid_count   OUT NUMBER,
        r_error_count   OUT NUMBER
    ) AS
        TYPE t_stg_rec IS RECORD (
            id                     BJKT_BANSOS_RECIPIENTS_STG.ID%TYPE,
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
            no_identitas           BJKT_BANSOS_RECIPIENTS_STG.NO_IDENTITAS%TYPE,
            kebangsaan             BJKT_BANSOS_RECIPIENTS_STG.KEBANGSAAN%TYPE,
            pekerjaan_bidang_usaha BJKT_BANSOS_RECIPIENTS_STG.PEKERJAAN_BIDANG_USAHA%TYPE
        );

        TYPE t_rows IS TABLE OF t_stg_rec INDEX BY PLS_INTEGER;
        v_rows  t_rows;
        v_valid NUMBER := 0;
        v_error NUMBER := 0;

        -- Variable di level procedure, bukan di dalam loop
        v_json  CLOB;
        v_cols  VARCHAR2(4000);
        v_sep   VARCHAR2(1);
        v_err   BOOLEAN;

        -- Helper di luar loop, dipanggil berkali-kali tanpa overhead alokasi
        FUNCTION is_valid_master(p_category VARCHAR2, p_code VARCHAR2)
        RETURN BOOLEAN 
        IS
            v_count NUMBER;
        BEGIN
            IF p_code IS NULL THEN RETURN FALSE; END IF;
            
            SELECT COUNT(1) INTO v_count
            FROM BJKT_MASTER_CODES_V
            WHERE CATEGORY = p_category AND CODE = p_code;

            RETURN v_count > 0;
        EXCEPTION
            WHEN OTHERS THEN RETURN FALSE;
        END is_valid_master;

        PROCEDURE add_error(p_field VARCHAR2, p_code VARCHAR2, p_label VARCHAR2) IS
        BEGIN
            v_json := v_json || v_sep
                    || '{"' || p_field || '":"Kode \"'
                    || NVL(p_code, 'NULL')
                    || '\" tidak ada di master ' || p_label || '"}';
            v_cols := v_cols || CASE WHEN v_cols IS NOT NULL THEN ',' END || p_field;
            v_sep  := ',';
            v_err  := TRUE;
        END add_error;

    BEGIN
        SELECT
            ID, AGAMA, STATUS_KAWIN, JEN_KELAMIN, PENDIDIKAN,
            STATUS_RUMAH, KODE_PROFESI, STATUS_PEKERJAAN,
            HUBUNGAN, STATUS_INSTANSI, TANGGAL_LAHIR, NO_IDENTITAS,
            KEBANGSAAN, PEKERJAAN_BIDANG_USAHA
        BULK COLLECT INTO v_rows
        FROM BJKT_BANSOS_RECIPIENTS_STG
        WHERE BATCH_ID = p_batch_id AND STATUS = 'PENDING';

        FOR i IN 1..v_rows.COUNT LOOP

            -- Reset variable di awal setiap iterasi (bukan deklarasi ulang)
            v_json := '[';
            v_cols := '';
            v_sep  := '';
            v_err  := FALSE;

            -- Validasi master
            IF NOT is_valid_master('AGAMA',            v_rows(i).agama)                  THEN add_error('AGAMA',            v_rows(i).agama,                  'Agama');             END IF;
            IF NOT is_valid_master('HUBUNGAN',         v_rows(i).hubungan)               THEN add_error('HUBUNGAN',         v_rows(i).hubungan,               'Hubungan Keluarga'); END IF;
            IF NOT is_valid_master('JEN_KELAMIN',      v_rows(i).jen_kelamin)            THEN add_error('JEN_KELAMIN',      v_rows(i).jen_kelamin,            'Jenis Kelamin');     END IF;
            IF NOT is_valid_master('KEBANGSAAN',       v_rows(i).kebangsaan)             THEN add_error('KEBANGSAAN',       v_rows(i).kebangsaan,             'Kebangsaan');        END IF;
            IF NOT is_valid_master('PEKERJAAN',        v_rows(i).pekerjaan_bidang_usaha) THEN add_error('PEKERJAAN',        v_rows(i).pekerjaan_bidang_usaha, 'Pekerjaan');         END IF;
            IF NOT is_valid_master('PENDIDIKAN',       v_rows(i).pendidikan)             THEN add_error('PENDIDIKAN',       v_rows(i).pendidikan,             'Pendidikan');        END IF;
            IF NOT is_valid_master('PROFESI',          v_rows(i).kode_profesi)           THEN add_error('PROFESI',          v_rows(i).kode_profesi,           'Profesi');           END IF;
            IF NOT is_valid_master('STATUS_KAWIN',     v_rows(i).status_kawin)           THEN add_error('STATUS_KAWIN',     v_rows(i).status_kawin,           'Status Kawin');      END IF;
            IF NOT is_valid_master('STATUS_PEKERJAAN', v_rows(i).status_pekerjaan)       THEN add_error('STATUS_PEKERJAAN', v_rows(i).status_pekerjaan,       'Status Pekerjaan'); END IF;
            IF NOT is_valid_master('STATUS_RUMAH',     v_rows(i).status_rumah)           THEN add_error('STATUS_RUMAH',     v_rows(i).status_rumah,           'Status Rumah');      END IF;
            IF NOT is_valid_master('STATUS_INSTANSI',  v_rows(i).status_instansi)        THEN add_error('STATUS_INSTANSI',  v_rows(i).status_instansi,        'Jenis Instansi');    END IF;

            -- Validasi tanggal
            BEGIN
                IF TO_DATE(v_rows(i).tanggal_lahir, 'YYYYMMDD') IS NULL THEN
                    add_error('TANGGAL_LAHIR', v_rows(i).tanggal_lahir, 'Format Tanggal (YYYYMMDD)');
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    add_error('TANGGAL_LAHIR', v_rows(i).tanggal_lahir, 'Format Tanggal (YYYYMMDD)');
            END;

            v_json := v_json || ']';

            IF v_err THEN
                UPDATE BJKT_BANSOS_RECIPIENTS_STG
                SET STATUS             = 'ERROR',
                    ERROR_COLUMNS      = v_cols,
                    ERROR_DETAILS_JSON = TO_CLOB(v_json),
                    VALIDATED_AT       = SYSTIMESTAMP
                WHERE ID = v_rows(i).id;

                v_error := v_error + 1;
            ELSE
                UPDATE BJKT_BANSOS_RECIPIENTS_STG
                SET STATUS       = 'VALID',
                    VALIDATED_AT = SYSTIMESTAMP
                WHERE ID = v_rows(i).id;
                
                v_valid := v_valid + 1;
            END IF;

            IF MOD(i, 500) = 0 THEN COMMIT; END IF;
        END LOOP;

        COMMIT;
        r_valid_count := v_valid;
        r_error_count := v_error;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            r_valid_count := 0;
            r_error_count := 0;
            RAISE;
    END VALIDATE_MASTER;


    PROCEDURE MARK_DUPLICATE (
        p_batch_id      IN  NUMBER,
        p_program_id    IN  NUMBER,
        r_skipped_count OUT NUMBER
    ) AS
    BEGIN
        UPDATE BJKT_BANSOS_RECIPIENTS_STG stg
        SET stg.STATUS       = 'SKIPPED',
            stg.VALIDATED_AT = SYSTIMESTAMP
        WHERE stg.BATCH_ID  = p_batch_id
          AND stg.STATUS    = 'VALID'
          AND EXISTS (
              SELECT 1
              FROM BJKT_HISTORY_BANSOS_RECIPIENTS h
              WHERE h.IDENTITY_CARD_NUM    = stg.NO_IDENTITAS
                AND h.PROGRAM_MASTER_CODE  = TO_CHAR(p_program_id)
          );

        r_skipped_count := SQL%ROWCOUNT;
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            r_skipped_count := 0;
            RAISE;
    END MARK_DUPLICATE;


    PROCEDURE FINAL_INSERT (
        p_batch_id      IN  NUMBER,
        p_program_id    IN  NUMBER,
        r_loaded_count  OUT NUMBER,
        r_error_count   OUT NUMBER,
        r_skipped_count OUT NUMBER,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    ) AS
        v_loaded  NUMBER := 0;
        v_err     NUMBER := 0;
        v_skipped NUMBER := 0;
    BEGIN
        -- 1. Insert VALID (bukan SKIPPED) ke target
        BEGIN
            INSERT INTO BJKT_HISTORY_BANSOS_RECIPIENTS (
                name, gender_master_code, nationality_master_code,
                born_place, born_date, identity_card_num,
                mother_or_guardian_name, religion_master_code,
                education_master_code, id_card_address, domicile_address,
                rt, rw, village, district, city, province, postal_code,
                phone_num, institution_num, institution_name,
                institution_address, institution_postal_code,
                institution_phone_num, intitution_type_master_code,
                contact_person_name, family_relationship_master_code,
                contact_person_address, contact_person_city,
                contact_person_province, contact_person_phone_num,
                marriage_status_code, house_master_status_code,
                job_master_code, profession_master_code,
                job_status_master_code, husband_wife,
                program_master_code, upload_date, total_dana
            )
            SELECT
                NAMA, JEN_KELAMIN, KEBANGSAAN, TEMPAT_LAHIR,
                TO_DATE(TANGGAL_LAHIR, 'YYYYMMDD'),
                NO_IDENTITAS, NAMA_IBU_KANDUNG_WALI,
                AGAMA, PENDIDIKAN, ALAMAT_KTP, ALAMAT_DOMISILI,
                RT, RW, KELURAHAN, KECAMATAN, KOTA, PROPINSI, KODE_POS,
                TELP_HP, NOMOR_INSTANSI, NAMA_INSTANSI, ALAMAT_INSTANSI,
                KODE_POS_INSTANSI, NO_TELP_INSTANSI, STATUS_INSTANSI,
                NAMA_PIHAK_DIHUBUNGI, HUBUNGAN, ALAMAT,
                KOTA_DOMISILI, PROPINSI_DOMISILI, TELPON,
                STATUS_KAWIN, STATUS_RUMAH, PEKERJAAN_BIDANG_USAHA,
                KODE_PROFESI, STATUS_PEKERJAAN, SUAMI_ISTRI,
                p_program_id, SYSTIMESTAMP,
                TO_NUMBER(REPLACE(TOTAL_DANA, ',', ''))
            FROM BJKT_BANSOS_RECIPIENTS_STG
            WHERE BATCH_ID = p_batch_id
              AND STATUS   = 'VALID';  -- SKIPPED sudah tidak masuk sini

            v_loaded := SQL%ROWCOUNT;

            -- Tandai LOADED
            UPDATE BJKT_BANSOS_RECIPIENTS_STG
            SET STATUS    = 'LOADED',
                LOADED_AT = SYSTIMESTAMP
            WHERE BATCH_ID = p_batch_id
              AND STATUS   = 'VALID';

            COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                r_status  := 'ERROR';
                r_message := 'Final insert ke target gagal: ' || SQLERRM;
                RETURN;
        END;

        -- 2. Hitung SKIPPED di staging
        SELECT COUNT(1) INTO v_skipped
        FROM BJKT_BANSOS_RECIPIENTS_STG
        WHERE BATCH_ID = p_batch_id AND STATUS = 'SKIPPED';

        -- 3. Pindahkan ERROR ke tabel error
        BEGIN
            INSERT INTO BJKT_BANSOS_RECIPIENTS_ERR (
                BATCH_ID, UPLOAD_BANSOS_ID, PROGRAM_ID, LINE_NUMBER,
                ERROR_SOURCE,
                NAMA, JEN_KELAMIN, KEBANGSAAN, TEMPAT_LAHIR, TANGGAL_LAHIR,
                NO_IDENTITAS, NAMA_IBU_KANDUNG_WALI, STATUS_KAWIN, AGAMA,
                PENDIDIKAN, ALAMAT_KTP, ALAMAT_DOMISILI, RT, RW,
                KELURAHAN, KECAMATAN, KOTA, PROPINSI, KODE_POS,
                STATUS_RUMAH, TELP_HP, PEKERJAAN_BIDANG_USAHA, KODE_PROFESI,
                STATUS_PEKERJAAN, NAMA_INSTANSI, ALAMAT_INSTANSI,
                KODE_POS_INSTANSI, NO_TELP_INSTANSI, SUAMI_ISTRI,
                NAMA_PIHAK_DIHUBUNGI, HUBUNGAN, ALAMAT, KOTA_DOMISILI,
                PROPINSI_DOMISILI, TELPON, NOMOR_INSTANSI, STATUS_INSTANSI,
                TOTAL_DANA, ERROR_COLUMNS, ERROR_DETAILS_JSON
            )
            SELECT
                BATCH_ID, UPLOAD_BANSOS_ID, PROGRAM_ID, LINE_NUMBER,
                'VALIDATION',
                NAMA, JEN_KELAMIN, KEBANGSAAN, TEMPAT_LAHIR, TANGGAL_LAHIR,
                NO_IDENTITAS, NAMA_IBU_KANDUNG_WALI, STATUS_KAWIN, AGAMA,
                PENDIDIKAN, ALAMAT_KTP, ALAMAT_DOMISILI, RT, RW,
                KELURAHAN, KECAMATAN, KOTA, PROPINSI, KODE_POS,
                STATUS_RUMAH, TELP_HP, PEKERJAAN_BIDANG_USAHA, KODE_PROFESI,
                STATUS_PEKERJAAN, NAMA_INSTANSI, ALAMAT_INSTANSI,
                KODE_POS_INSTANSI, NO_TELP_INSTANSI, SUAMI_ISTRI,
                NAMA_PIHAK_DIHUBUNGI, HUBUNGAN, ALAMAT, KOTA_DOMISILI,
                PROPINSI_DOMISILI, TELPON, NOMOR_INSTANSI, STATUS_INSTANSI,
                TOTAL_DANA, ERROR_COLUMNS, ERROR_DETAILS_JSON
            FROM BJKT_BANSOS_RECIPIENTS_STG
            WHERE BATCH_ID = p_batch_id AND STATUS = 'ERROR';

            v_err := SQL%ROWCOUNT;
            COMMIT;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                r_status  := 'ERROR';
                r_message := 'Insert ke tabel error gagal: ' || SQLERRM;
                RETURN;
        END;

        r_loaded_count  := v_loaded;
        r_error_count   := v_err;
        r_skipped_count := v_skipped;
        r_status        := CASE WHEN v_err > 0 THEN 'PARTIAL' ELSE 'SUCCESS' END;
        r_message       := 'Loaded: ' || v_loaded
                        || ' | Error: '   || v_err
                        || ' | Skipped: ' || v_skipped || ' baris.';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            r_status  := 'ERROR';
            r_message := 'FINAL_INSERT error: ' || SQLERRM;
    END FINAL_INSERT;


    PROCEDURE PURGE_STAGING (
        p_batch_id          IN  NUMBER,
        r_purged_count      OUT NUMBER,
        r_status            OUT VARCHAR2,
        r_message           OUT VARCHAR2
    ) AS
        v_purged_loaded  NUMBER := 0;
        v_purged_skipped NUMBER := 0;
        v_purged_error   NUMBER := 0;
    BEGIN
        DELETE FROM BJKT_BANSOS_RECIPIENTS_STG
        WHERE BATCH_ID = p_batch_id
          AND STATUS IN ('LOADED', 'SKIPPED', 'ERROR');

        v_purged_loaded := SQL%ROWCOUNT;

        COMMIT;

        r_purged_count := v_purged_loaded + v_purged_error;
        r_status       := 'SUCCESS';
        r_message      := 'Purge selesai.'
                       || ' LOADED/SKIPPED dihapus: ' || v_purged_loaded
                       || ' | ERROR lama dihapus: '   || v_purged_error;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            r_purged_count := 0;
            r_status       := 'ERROR';
            r_message      := 'PURGE_STAGING error: ' || SQLERRM;
    END PURGE_STAGING;


    PROCEDURE CLEAN_PREVIOUS_ERRORS (
        p_program_id        IN  NUMBER,
        p_batch_id          IN  NUMBER,
        r_deleted_count     OUT NUMBER,
        r_status            OUT VARCHAR2,
        r_message           OUT VARCHAR2
    ) AS
    BEGIN
        /*
            Hapus error lama untuk program yang sama,
            HANYA untuk NIK yang ada di batch upload sekarang.
            
            Logika:
            - Jika NIK di-upload ulang dan kali ini VALID -> error lama hilang (terhapus di sini)
            - Jika NIK di-upload ulang dan masih ERROR    -> error lama tetap terhapus di sini,
                                                            lalu error baru akan di-INSERT setelah validasi
            - NIK yang tidak ada di batch ini             -> tidak tersentuh
        */
        DELETE FROM BJKT_BANSOS_RECIPIENTS_ERR e
        WHERE  e.PROGRAM_ID = p_program_id
        AND  e.NO_IDENTITAS IN (
                SELECT s.NO_IDENTITAS
                FROM   BJKT_BANSOS_RECIPIENTS_STG s
                WHERE  s.BATCH_ID = p_batch_id
                    AND  s.STATUS   = 'PENDING' -- hanya yang baru masuk staging
                    AND  s.NO_IDENTITAS IS NOT NULL
            );

        r_deleted_count := SQL%ROWCOUNT;
        COMMIT;

        r_status  := 'SUCCESS';
        r_message := r_deleted_count || ' data error lama dihapus untuk program_id=' 
                || p_program_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            r_status  := 'ERROR';
            r_message := 'Gagal clean previous errors: ' || SQLERRM;
    END CLEAN_PREVIOUS_ERRORS;


    PROCEDURE CREATE_PROGRAM (
        p_program_id    IN  NUMBER,
        p_upload_name   IN  VARCHAR2,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    ) AS
        v_upload_id     NUMBER;
        v_batch_id      NUMBER;
        v_file_log_id   NUMBER;
        v_file_log_ret  NUMBER;
        v_blob          BLOB;
        v_filename      VARCHAR2(500);
        v_mime          VARCHAR2(200);
        v_status        VARCHAR2(200);
        v_message       VARCHAR2(4000);
        v_total_rows    NUMBER;
        v_valid         NUMBER;
        v_error         NUMBER;
        v_loaded        NUMBER;
        v_cleaned       NUMBER;
        v_skipped       NUMBER;
        v_purged        NUMBER;
        v_err_final     NUMBER;
        v_final_status  VARCHAR2(50);
        v_sub_status    VARCHAR2(200);
        v_sub_message   VARCHAR2(4000);
        v_sqlerrm       VARCHAR2(4000);
    BEGIN
        -- 1. Ambil file dari temp
        BEGIN
            SELECT blob_content, filename, mime_type
            INTO v_blob, v_filename, v_mime
            FROM apex_application_temp_files
            WHERE name = p_upload_name;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                r_status  := 'ERROR';
                r_message := 'File tidak ditemukan di temp storage!';
                RETURN;
        END;

        -- 2. Generate ID
        v_upload_id   := BJKT_UPLOAD_BANSOS_S.NEXTVAL;
        v_batch_id    := BJKT_UPLOAD_BANSOS_BATCH_S.NEXTVAL;
        v_file_log_id := BJKT_FILE_UPLOAD_LOG_S.NEXTVAL;

        -- 3. Insert header upload
        INSERT INTO BJKT_UPLOAD_BANSOS (ID, BATCH_ID, PROGRAM_ID, FILE_LOG_ID, STATUS)
        VALUES (v_upload_id, v_batch_id, p_program_id, v_file_log_id, 'PROCESSING');
        COMMIT;

        -- 4. Simpan file ke server
        BJKT_FILE_UPLOAD_PKG.save_file_to_server(
            p_file_id      => v_file_log_id,
            p_feature_name => 'UPLOAD_BANSOS',
            p_source_id    => v_upload_id,
            p_file_name    => p_upload_name,
            p_mime_type    => v_mime,
            p_file_blob    => v_blob,
            r_file_id      => v_file_log_ret,
            r_status       => v_status,
            r_message      => v_message
        );
        IF v_status = 'ERROR' THEN
            UPDATE BJKT_UPLOAD_BANSOS SET STATUS = 'ERROR', MESSAGE = v_message WHERE ID = v_upload_id;
            COMMIT; r_status := 'ERROR'; r_message := v_message; RETURN;
        END IF;

        -- 5. Insert Staging
        INSERT_STAGING(p_upload_name, v_batch_id, v_upload_id, p_program_id,
                       v_total_rows, v_status, v_message);
        IF v_status = 'ERROR' THEN
            UPDATE BJKT_UPLOAD_BANSOS SET STATUS = 'ERROR', MESSAGE = v_message WHERE ID = v_upload_id;
            COMMIT; r_status := 'ERROR'; r_message := v_message; RETURN;
        END IF;

        -- 6. Hapus error lama untuk NIK yang di-upload ulang
        CLEAN_PREVIOUS_ERRORS (
            p_program_id    => p_program_id,
            p_batch_id      => v_batch_id,
            r_deleted_count => v_cleaned,
            r_status        => v_sub_status,
            r_message       => v_sub_message
        );

        -- 7. Validasi Master
        VALIDATE_MASTER(v_batch_id, v_valid, v_error);

        -- 8. Tandai Duplicate / Skip
        MARK_DUPLICATE(v_batch_id, p_program_id, v_skipped);

        -- 9. Final Insert
        FINAL_INSERT(v_batch_id, p_program_id,
                     v_loaded, v_err_final, v_skipped,
                     v_status, v_message);
        IF v_status = 'ERROR' THEN
            UPDATE BJKT_UPLOAD_BANSOS SET STATUS = 'ERROR', MESSAGE = v_message WHERE ID = v_upload_id;
            COMMIT; r_status := 'ERROR'; r_message := v_message; RETURN;
        END IF;

        -- 10. Update summary header
        v_final_status := CASE WHEN v_err_final > 0 THEN 'PARTIAL' ELSE 'SUCCESS' END;

        UPDATE BJKT_UPLOAD_BANSOS
        SET STATUS       = v_final_status,
            TOTAL_ROWS   = v_total_rows,
            VALID_ROWS   = v_loaded,
            ERROR_ROWS   = v_err_final,
            LOADED_ROWS  = v_loaded,
            SKIPPED_ROWS = v_skipped,
            FINISHED_AT  = SYSTIMESTAMP,
            MESSAGE      = v_message
        WHERE ID = v_upload_id;

        -- 11. Purge staging (hapus LOADED, ERROR & SKIPPED)
        PURGE_STAGING(
            p_batch_id        => v_batch_id,
            r_purged_count    => v_purged,
            r_status          => v_status,
            r_message         => v_message
        );
        -- Purge gagal tidak stop proses utama, hanya log
        IF v_status = 'ERROR' THEN
            UPDATE BJKT_UPLOAD_BANSOS
            SET MESSAGE = MESSAGE || ' | PURGE WARNING: ' || v_message
            WHERE ID = v_upload_id;
        END IF;

        -- 12. Hapus dari temp
        DELETE FROM apex_application_temp_files WHERE name = p_upload_name;
        COMMIT;

        r_status  := v_final_status;
        r_message := v_message;

    EXCEPTION
        WHEN OTHERS THEN
            v_sqlerrm := SQLERRM;
            ROLLBACK;
            UPDATE BJKT_UPLOAD_BANSOS
            SET STATUS = 'ERROR', MESSAGE = v_sqlerrm
            WHERE ID = v_upload_id;
            COMMIT;
            r_status  := 'ERROR';
            r_message := 'CREATE_PROGRAM error: ' || v_sqlerrm;
    END CREATE_PROGRAM;

END BJKT_UPLOAD_BANSOS_PKG;
/