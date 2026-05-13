create or replace package body "BJKT_UPLOAD_BANSOS_PKG" as

    PROCEDURE CREATE_PROGRAM (
        p_program_id    IN  NUMBER,
        p_upload_name   IN  VARCHAR2,
        r_status        OUT VARCHAR2,
        r_message       OUT VARCHAR2
    ) AS
        v_upload_bansos_id      NUMBER;
        v_file_log_id           NUMBER;
        v_file_log_id_return    NUMBER;
        v_blob                  BLOB;
        v_filename              VARCHAR2(500);
        v_mime                  VARCHAR2(200);
        v_status                VARCHAR2(200);
        v_message               VARCHAR2(4000);
        v_error_count           NUMBER := 0;
        v_error_detail          VARCHAR2(4000);

        CURSOR cur_bansos_recipients IS
            SELECT
                p.line_number,
                p.col001  nama,
                p.col002  jen_kelamin,
                p.col003  kebangsaan,
                p.col004  tempat_lahir,
                p.col005  tanggal_lahir,
                p.col006  no_identitas,
                p.col007  nama_ibu_kandung_wali,
                p.col008  status_kawin,
                p.col009  agama,
                p.col010  pendidikan,
                p.col011  alamat_ktp,
                p.col012  alamat_domisili,
                p.col013  rt,
                p.col014  rw,
                p.col015  kelurahan,
                p.col016  kecamatan,
                p.col017  kota,
                p.col018  propinsi,
                p.col019  kode_pos,
                p.col020  status_rumah,
                p.col021  telp_hp,
                p.col022  pekerjaan_bidang_usaha,
                p.col023  kode_profesi,
                p.col024  status_pekerjaan,
                p.col025  nama_instansi,
                p.col026  alamat_instansi,
                p.col027  kode_pos_instansi,
                p.col028  no_telp_instansi,
                p.col029  suami_istri,
                p.col030  nama_pihak_yang_dapat_dihubungi,
                p.col031  hubungan,
                p.col032  alamat,
                p.col033  kota_domisili,
                p.col034  propinsi_domisili,
                p.col035  telpon,
                p.col036  nomor_instansi,
                p.col037  status_instansi,
                p.col038  total_dana
            FROM apex_application_temp_files f,
                TABLE (
                    apex_data_parser.parse (
                        p_content           => f.blob_content,
                        p_file_name         => f.filename,
                        p_xlsx_sheet_name   => NULL,
                        p_max_rows          => 99999999999999,
                        p_file_profile      => 
                            apex_data_loading.get_file_profile (p_static_id => 'upload_bansos_recipients')
                    )
                ) p
            WHERE f.name = p_upload_name and p.line_number > 1;

        TYPE t_bansos_recipients IS TABLE OF cur_bansos_recipients%ROWTYPE 
            INDEX BY PLS_INTEGER;

        v_rows      t_bansos_recipients;
        v_limit     PLS_INTEGER := 1000;
        
        -- exception untuk BULK COLLECT
        bulk_errors EXCEPTION;
        PRAGMA EXCEPTION_INIT(bulk_errors, -24381);
    BEGIN
        BEGIN
            SELECT blob_content, filename, mime_type
            INTO v_blob, v_filename, v_mime
            FROM apex_application_temp_files
            WHERE name = p_upload_name;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                r_status    := 'ERROR';
                r_message   := 'Upload file not found on application temp files!';
                RETURN;
        END;
        
        v_upload_bansos_id := BJKT_MASTER_PROGRAMS_S.NEXTVAL;
        v_file_log_id      := BJKT_FILE_UPLOAD_LOG_S.NEXTVAL;
        
        BEGIN
            INSERT INTO BJKT_UPLOAD_BANSOS (
                ID,
                PROGRAM_ID,
                FILE_LOG_ID
            ) VALUES (
                v_upload_bansos_id,
                p_program_id,
                v_file_log_id
            );

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                r_status    := 'ERROR';
                r_message   := 'Failed to insert file upload bansos!';
                RETURN; 
        END;

        BJKT_FILE_UPLOAD_PKG.save_file_to_server (
            p_file_id       => v_file_log_id,
            p_feature_name  => 'UPLOAD_BANSOS',
            p_source_id     => v_upload_bansos_id,
            p_file_name     => p_upload_name,
            p_mime_type     => v_mime,
            p_file_blob     => v_blob,
            r_file_id       => v_file_log_id_return,
            r_status        => v_status,
            r_message       => v_message
        );

        IF v_status = 'ERROR' THEN
            r_status    := v_status;
            r_message   := v_message;
            RETURN;
        END IF;

        BEGIN
            OPEN cur_bansos_recipients;
            LOOP
                FETCH cur_bansos_recipients BULK COLLECT INTO v_rows LIMIT v_limit;
                EXIT WHEN v_rows.COUNT = 0;

                BEGIN
                    FORALL i IN 1..v_rows.COUNT SAVE EXCEPTIONS
                        INSERT INTO BJKT_HISTORY_BANSOS_RECIPIENTS (
                            name,
                            gender_master_code,
                            nationality_master_code,
                            born_place,
                            born_date,
                            identity_card_num,
                            mother_or_guardian_name,
                            religion_master_code,
                            education_master_code,
                            id_card_address,
                            domicile_address,
                            rt,
                            rw,
                            village,
                            district,
                            city,
                            province,
                            postal_code,
                            phone_num,
                            institution_num,
                            institution_name,
                            institution_address,
                            institution_postal_code,
                            institution_phone_num,
                            intitution_type_master_code,
                            contact_person_name,
                            family_relationship_master_code,
                            contact_person_address,
                            contact_person_city,
                            contact_person_province,
                            contact_person_phone_num,
                            marriage_status_code,
                            house_master_status_code,
                            job_master_code,
                            profession_master_code,
                            job_status_master_code,
                            husband_wife,
                            program_master_code,
                            upload_date,
                            total_dana
                        ) VALUES (
                            v_rows(i).nama,
                            v_rows(i).jen_kelamin,
                            v_rows(i).kebangsaan,
                            v_rows(i).tempat_lahir,
                            TO_DATE(v_rows(i).tanggal_lahir, 'YYYYMMDD'),
                            v_rows(i).no_identitas,
                            v_rows(i).nama_ibu_kandung_wali,
                            v_rows(i).agama,
                            v_rows(i).pendidikan,
                            v_rows(i).alamat_ktp,
                            v_rows(i).alamat_domisili,
                            v_rows(i).rt,
                            v_rows(i).rw,
                            v_rows(i).kelurahan,
                            v_rows(i).kecamatan,
                            v_rows(i).kota,
                            v_rows(i).propinsi,
                            v_rows(i).kode_pos,
                            v_rows(i).telp_hp,
                            v_rows(i).nomor_instansi,
                            v_rows(i).nama_instansi,
                            v_rows(i).alamat_instansi,
                            v_rows(i).kode_pos_instansi,
                            v_rows(i).no_telp_instansi,
                            v_rows(i).status_instansi,
                            v_rows(i).nama_pihak_yang_dapat_dihubungi,
                            v_rows(i).hubungan,
                            v_rows(i).alamat,
                            v_rows(i).kota_domisili,
                            v_rows(i).propinsi_domisili,
                            v_rows(i).telpon,
                            v_rows(i).status_kawin,
                            v_rows(i).status_rumah,
                            v_rows(i).pekerjaan_bidang_usaha,
                            v_rows(i).kode_profesi,
                            v_rows(i).status_pekerjaan,
                            v_rows(i).suami_istri,
                            p_program_id,
                            SYSTIMESTAMP,
                            v_rows(i).total_dana
                        );

                    COMMIT; -- commit per batch jika tidak ada error

                -- tangkap error bulk
                EXCEPTION
                    WHEN bulk_errors THEN
                        -- Kumpulkan detail error dari setiap baris yang gagal
                        FOR j IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                            v_error_count := v_error_count + 1;
                            v_error_detail := v_error_detail
                                || 'Row index ' || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX
                                || ', ORA-' || SQL%BULK_EXCEPTIONS(j).ERROR_CODE
                                || ': ' || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE)
                                || CHR(10);
                        END LOOP;

                        -- Pilihan A: Stop langsung jika ada error
                        ROLLBACK;
                        IF cur_bansos_recipients%ISOPEN THEN
                            CLOSE cur_bansos_recipients;
                        END IF;
                        r_status  := 'ERROR';
                        r_message := 'Bulk insert failed. Total errors: ' 
                                    || v_error_count || CHR(10) || v_error_detail;
                        RETURN;

                        -- Pilihan B: Skip baris error, lanjut proses (uncomment jika ingin skip)
                        -- COMMIT; -- commit baris yang berhasil, skip yang gagal

                    WHEN OTHERS THEN
                        ROLLBACK;
                        IF cur_bansos_recipients%ISOPEN THEN
                            CLOSE cur_bansos_recipients;
                        END IF;
                        r_status  := 'ERROR';
                        r_message := 'Unexpected error during insert: ' || SQLERRM  -- ← SQLERRM di sini
                                    || ' | SQLCODE: ' || SQLCODE;
                        RETURN;
                END;

            END LOOP;
            CLOSE cur_bansos_recipients;

        EXCEPTION
            WHEN OTHERS THEN
                IF cur_bansos_recipients%ISOPEN THEN
                    CLOSE cur_bansos_recipients;
                END IF;
                ROLLBACK;
                r_status  := 'ERROR';
                r_message := 'Cursor error: ' || SQLERRM;
                RETURN;
        END;

        -- Hapus dari temp storage APEX
        DELETE FROM apex_application_temp_files
        WHERE name = p_upload_name;

        r_status    := 'SUCCESS';
        r_message   := 'Data uploaded successfully.';

    EXCEPTION
        WHEN OTHERS THEN
            r_status    := 'ERROR';
            r_message   := SQLERRM;
    END;

end "BJKT_UPLOAD_BANSOS_PKG";