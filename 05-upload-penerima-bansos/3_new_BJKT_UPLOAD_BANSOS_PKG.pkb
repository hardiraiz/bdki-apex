CREATE OR REPLACE PACKAGE BODY BJKT_UPLOAD_BANSOS_PKG AS

FUNCTION UPDATE_STATUS_UPLOAD (
    p_id        NUMBER,
    p_status    VARCHAR2,
    p_message   VARCHAR2
) RETURN VARCHAR2
IS
BEGIN
    UPDATE BJKT_UPLOAD_BANSOS
    SET STATUS = p_status
    WHERE ID = p_id;

    COMMIT;
    RETURN 'Y';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'N';
END;


-- Orkestrator utama — dipanggil dari APEX Process
PROCEDURE CREATE_PROGRAM (
    p_program_id    IN  NUMBER,
    p_upload_name   IN  VARCHAR2,
    r_status        OUT VARCHAR2,
    r_message       OUT VARCHAR2
) AS
    v_upload_bansos_id      NUMBER;
    v_batch_id              NUMBER;
    v_file_log_id           NUMBER;
    v_file_log_id_return    NUMBER;
    v_update_bansos_status  VARCHAR2(1);
    v_blob                  BLOB;
    v_filename              VARCHAR2(500);
    v_mime                  VARCHAR2(200);
    v_total_rows            NUMBER := 0;
    v_valid_count           NUMBER := 0;
    v_error_count           NUMBER := 0;
    v_loaded_count          NUMBER := 0;
    v_err_fi_count          NUMBER := 0;
    v_sub_status            VARCHAR2(200);
    v_sub_message           VARCHAR2(4000);
BEGIN
    -- Validasi: file harus ada di temp files
    BEGIN
        SELECT blob_content, filename, mime_type
        INTO   v_blob, v_filename, v_mime
        FROM   apex_application_temp_files
        WHERE  name = p_upload_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            r_status  := 'ERROR';
            r_message := 'File tidak ditemukan di temporary storage APEX. '
                      || 'Pastikan file sudah ter-upload.';
            RETURN;
    END;

    -- Buat record header upload
    v_upload_bansos_id := BJKT_UPLOAD_BANSOS_S.NEXTVAL;
    v_batch_id         := BJKT_UPLOAD_BANSOS_BATCH_S.NEXTVAL;
    v_file_log_id      := BJKT_FILE_UPLOAD_LOG_S.NEXTVAL;

    BEGIN
        INSERT INTO BJKT_UPLOAD_BANSOS (
            ID,
            BATCH_ID,
            PROGRAM_ID,
            FILE_LOG_ID,
            STATUS
        ) VALUES (
            v_upload_bansos_id,
            v_batch_id,
            p_program_id,
            v_file_log_id,
            'PROCESSING'
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            r_status  := 'ERROR';
            r_message := 'Gagal membuat record upload: ' || SQLERRM;
            RETURN;
    END;

    -- Simpan file ke server (prosedur existing)
    BJKT_FILE_UPLOAD_PKG.SAVE_FILE_TO_SERVER (
        p_file_id      => v_file_log_id,
        p_feature_name => 'UPLOAD_BANSOS',
        p_source_id    => v_upload_bansos_id,
        p_file_name    => p_upload_name,
        p_mime_type    => v_mime,
        p_file_blob    => v_blob,
        r_file_id      => v_file_log_id_return,
        r_status       => v_sub_status,
        r_message      => v_sub_message
    );

    IF v_sub_status = 'ERROR' THEN
        r_status  := 'ERROR';
        r_message := 'Gagal menyimpan file: ' || v_sub_message;

        v_update_bansos_status :=
            UPDATE_STATUS_UPLOAD (
                p_id      => v_upload_bansos_id,
                p_status  => r_status,
                p_message => r_message
            );

        RETURN;
    END IF;

    -- STEP 1: Parse CSV ke Staging
    INSERT_STAGING (
        p_upload_name      => p_upload_name,
        p_batch_id         => v_batch_id,
        p_upload_bansos_id => v_upload_bansos_id,
        r_total_rows       => v_total_rows,
        r_status           => v_sub_status,
        r_message          => v_sub_message
    );

    IF v_sub_status = 'ERROR' THEN
        r_status  := 'ERROR';
        r_message := 'Gagal proses staging: ' || v_sub_message;

        v_update_bansos_status :=
            UPDATE_STATUS_UPLOAD (
                p_id      => v_upload_bansos_id,
                p_status  => r_status,
                p_message => r_message
            );

        RETURN;
    END IF;

    -- STEP 2: Validasi master
    VALIDATE_MASTER (
        p_batch_id    => v_batch_id,
        r_valid_count => v_valid_count,
        r_error_count => v_error_count
    );

    -- STEP 3: Final insert (hanya baris VALID)
    FINAL_INSERT (
        p_batch_id     => v_batch_id,
        p_program_id   => p_program_id,
        r_loaded_count => v_loaded_count,
        r_error_count  => v_err_fi_count,
        r_status       => v_sub_status,
        r_message      => v_sub_message
    );

    -- Update ringkasan di header
    UPDATE BJKT_UPLOAD_BANSOS
    SET
        TOTAL_ROWS    = v_total_rows,
        VALID_ROWS    = v_valid_count,
        ERROR_ROWS    = v_error_count + v_err_fi_count,
        LOADED_ROWS   = v_loaded_count,
        STATUS        = 
            CASE
                WHEN v_error_count + v_err_fi_count = 0 THEN 'SUCCESS'
                WHEN v_loaded_count = 0                 THEN 'ERROR'
                ELSE 'PARTIAL'
            END
    WHERE ID = v_upload_bansos_id;

    COMMIT;

    -- Hapus file dari temp storage APEX
    DELETE FROM apex_application_temp_files
    WHERE name = p_upload_name;

    r_status  := CASE
                    WHEN v_error_count + v_err_fi_count = 0 THEN 'SUCCESS'
                    WHEN v_loaded_count = 0                 THEN 'ERROR'
                    ELSE 'PARTIAL'
                 END;
    r_message := 'Total: '       || v_total_rows
              || ' | Berhasil: ' || v_loaded_count
              || ' | Error: '    || (v_error_count + v_err_fi_count)
              || '. '            || v_sub_message;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        r_status  := 'ERROR';
        r_message := 'Unexpected error di CREATE_PROGRAM: ' || SQLERRM;
END CREATE_PROGRAM;


-- Parse CSV menggunakan APEX_DATA_PARSER dan insert ke staging
PROCEDURE INSERT_STAGING (
    p_upload_name       IN  VARCHAR2,
    p_batch_id          IN  NUMBER,
    p_upload_bansos_id  IN  NUMBER,
    r_total_rows        OUT NUMBER,
    r_status            OUT VARCHAR2,
    r_message           OUT VARCHAR2
) AS
    CURSOR cur_csv IS
        SELECT
            p.line_number,
            p.col001    AS nama,
            p.col002    AS jen_kelamin,
            p.col003    AS kebangsaan,
            p.col004    AS tempat_lahir,
            p.col005    AS tanggal_lahir,
            p.col006    AS no_identitas,
            p.col007    AS nama_ibu_kandung_wali,
            p.col008    AS status_kawin,
            p.col009    AS agama,
            p.col010    AS pendidikan,
            p.col011    AS alamat_ktp,
            p.col012    AS alamat_domisili,
            p.col013    AS rt,
            p.col014    AS rw,
            p.col015    AS kelurahan,
            p.col016    AS kecamatan,
            p.col017    AS kota,
            p.col018    AS propinsi,
            p.col019    AS kode_pos,
            p.col020    AS status_rumah,
            p.col021    AS telp_hp,
            p.col022    AS pekerjaan_bidang_usaha,
            p.col023    AS kode_profesi,
            p.col024    AS status_pekerjaan,
            p.col025    AS nama_instansi,
            p.col026    AS alamat_instansi,
            p.col027    AS kode_pos_instansi,
            p.col028    AS no_telp_instansi,
            p.col029    AS suami_istri,
            p.col030    AS nama_pihak_dihubungi,
            p.col031    AS hubungan,
            p.col032    AS alamat,
            p.col033    AS kota_domisili,
            p.col034    AS propinsi_domisili,
            p.col035    AS telpon,
            p.col036    AS nomor_instansi,
            p.col037    AS status_instansi,
            p.col038    AS total_dana
        FROM apex_application_temp_files f,
             TABLE (
                 apex_data_parser.parse (
                     p_content         => f.blob_content,
                     p_file_name       => f.filename,
                     p_xlsx_sheet_name => NULL,
                     p_max_rows        => 99999999999999,
                     p_file_profile    =>
                         apex_data_loading.get_file_profile (
                             p_static_id => 'upload_bansos_recipients')
                 )
             ) p
        WHERE f.name = p_upload_name
          AND p.line_number > 1;

    TYPE t_csv IS TABLE OF cur_csv%ROWTYPE INDEX BY PLS_INTEGER;
    v_rows  t_csv;
    v_limit CONSTANT PLS_INTEGER := 1000;
    v_count NUMBER := 0;

    bulk_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT (bulk_errors, -24381);
BEGIN
    r_total_rows := 0;

    OPEN cur_csv;
    LOOP
        FETCH cur_csv BULK COLLECT INTO v_rows LIMIT v_limit;
        EXIT WHEN v_rows.COUNT = 0;

        BEGIN
            FORALL i IN 1..v_rows.COUNT SAVE EXCEPTIONS
                INSERT INTO BJKT_BANSOS_RECIPIENTS_STG (
                    BATCH_ID,
                    UPLOAD_BANSOS_ID,
                    LINE_NUMBER,
                    NAMA,
                    JEN_KELAMIN,
                    KEBANGSAAN,
                    TEMPAT_LAHIR,
                    TANGGAL_LAHIR,
                    NO_IDENTITAS,
                    NAMA_IBU_KANDUNG_WALI,
                    STATUS_KAWIN,
                    AGAMA,
                    PENDIDIKAN,
                    ALAMAT_KTP,
                    ALAMAT_DOMISILI,
                    RT,
                    RW,
                    KELURAHAN,
                    KECAMATAN,
                    KOTA,
                    PROPINSI,
                    KODE_POS,
                    STATUS_RUMAH,
                    TELP_HP,
                    PEKERJAAN_BIDANG_USAHA,
                    KODE_PROFESI,
                    STATUS_PEKERJAAN,
                    NAMA_INSTANSI,
                    ALAMAT_INSTANSI,
                    KODE_POS_INSTANSI,
                    NO_TELP_INSTANSI,
                    SUAMI_ISTRI,
                    NAMA_PIHAK_DIHUBUNGI,
                    HUBUNGAN,
                    ALAMAT,
                    KOTA_DOMISILI,
                    PROPINSI_DOMISILI,
                    TELPON,
                    NOMOR_INSTANSI,
                    STATUS_INSTANSI,
                    TOTAL_DANA,
                    STATUS
                ) VALUES (
                    p_batch_id,
                    p_upload_bansos_id,
                    v_rows(i).line_number,
                    v_rows(i).nama,
                    v_rows(i).jen_kelamin,
                    v_rows(i).kebangsaan,
                    v_rows(i).tempat_lahir,
                    v_rows(i).tanggal_lahir,
                    v_rows(i).no_identitas,
                    v_rows(i).nama_ibu_kandung_wali,
                    v_rows(i).status_kawin,
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
                    v_rows(i).status_rumah,
                    v_rows(i).telp_hp,
                    v_rows(i).pekerjaan_bidang_usaha,
                    v_rows(i).kode_profesi,
                    v_rows(i).status_pekerjaan,
                    v_rows(i).nama_instansi,
                    v_rows(i).alamat_instansi,
                    v_rows(i).kode_pos_instansi,
                    v_rows(i).no_telp_instansi,
                    v_rows(i).suami_istri,
                    v_rows(i).nama_pihak_dihubungi,
                    v_rows(i).hubungan,
                    v_rows(i).alamat,
                    v_rows(i).kota_domisili,
                    v_rows(i).propinsi_domisili,
                    v_rows(i).telpon,
                    v_rows(i).nomor_instansi,
                    v_rows(i).status_instansi,
                    v_rows(i).total_dana,
                    'PENDING'
                );

            v_count := v_count + v_rows.COUNT;
            COMMIT;

        EXCEPTION
            WHEN bulk_errors THEN
                ROLLBACK;
                IF cur_csv%ISOPEN THEN
                    CLOSE cur_csv;
                END IF;
                r_status  := 'ERROR';
                r_message := 'Gagal insert ke staging di baris sekitar '
                          || v_rows(SQL%BULK_EXCEPTIONS(1).ERROR_INDEX).line_number
                          || '. ORA-' || SQL%BULK_EXCEPTIONS(1).ERROR_CODE
                          || ': ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
                RETURN;

            WHEN OTHERS THEN
                ROLLBACK;
                IF cur_csv%ISOPEN THEN
                    CLOSE cur_csv;
                END IF;
                r_status  := 'ERROR';
                r_message := 'Error tidak terduga di INSERT_STAGING: ' || SQLERRM;
                RETURN;
        END;

    END LOOP;
    CLOSE cur_csv;

    r_total_rows := v_count;
    r_status     := 'SUCCESS';
    r_message    := v_count || ' baris berhasil masuk staging.';

EXCEPTION
    WHEN OTHERS THEN
        IF cur_csv%ISOPEN THEN
            CLOSE cur_csv;
        END IF;
        r_status  := 'ERROR';
        r_message := 'Error cursor di INSERT_STAGING: ' || SQLERRM;
END INSERT_STAGING;

/*
    Satu UPDATE besar — cek semua kolom master sekaligus.
    Setiap kolom yang salah diisi flag ERR_* dan pesan MSG_*.

    ROOT CAUSE FIX: Blok ERR_STATUS_KAWIN sebelumnya mengandung
    kondisi "mk.JENIS = 'STATUS_KAWIN'" yang tidak ada di tabel
    BJKT_BANSOS_MASTER_STATUS_KAWIN, menyebabkan ORA-00911.
    Kondisi tersebut sudah dihapus dan diseragamkan dengan blok lain.
*/
PROCEDURE VALIDATE_MASTER (
    p_batch_id      IN  NUMBER,
    r_valid_count   OUT NUMBER,
    r_error_count   OUT NUMBER
) AS
    v_sqlerrm       VARCHAR2(4000);
BEGIN
    -- ── PASS 1: Isi semua ERR_* dan MSG_* per kolom ──────────
    UPDATE BJKT_BANSOS_RECIPIENTS_STG s
    SET
        VALIDATED_AT = SYSTIMESTAMP,

        -- NAMA: wajib isi
        ERR_NAMA = CASE
            WHEN TRIM(s.NAMA) IS NULL
            THEN 'Y'
            END,
        MSG_NAMA = CASE
            WHEN TRIM(s.NAMA) IS NULL
            THEN 'Nama wajib diisi'
            END,

        -- JEN_KELAMIN: cek ke BJKT_BANSOS_MASTER_JENIS_KELAMIN
        ERR_JEN_KELAMIN = CASE
            WHEN s.JEN_KELAMIN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_JENIS_KELAMIN mk
                    WHERE  mk.KODE        = s.JEN_KELAMIN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_JEN_KELAMIN = CASE
            WHEN s.JEN_KELAMIN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_JENIS_KELAMIN mk
                    WHERE  mk.KODE        = s.JEN_KELAMIN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.JEN_KELAMIN || '" tidak ada di master Jenis Kelamin'
            END,

        -- KEBANGSAAN: cek ke BJKT_BANSOS_MASTER_KEBANGSAAN
        ERR_KEBANGSAAN = CASE
            WHEN s.KEBANGSAAN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_KEBANGSAAN mk
                    WHERE  mk.KODE        = s.KEBANGSAAN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_KEBANGSAAN = CASE
            WHEN s.KEBANGSAAN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_KEBANGSAAN mk
                    WHERE  mk.KODE        = s.KEBANGSAAN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.KEBANGSAAN || '" tidak ada di master Kebangsaan'
            END,

        -- AGAMA: cek ke BJKT_BANSOS_MASTER_AGAMA
        ERR_AGAMA = CASE
            WHEN s.AGAMA IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_AGAMA mk
                    WHERE  mk.KODE        = s.AGAMA
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_AGAMA = CASE
            WHEN s.AGAMA IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_AGAMA mk
                    WHERE  mk.KODE        = s.AGAMA
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.AGAMA || '" tidak ada di master Agama'
            END,

        -- PENDIDIKAN: cek ke BJKT_BANSOS_MASTER_PENDIDIKAN
        ERR_PENDIDIKAN = CASE
            WHEN s.PENDIDIKAN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_PENDIDIKAN mk
                    WHERE  mk.KODE        = s.PENDIDIKAN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_PENDIDIKAN = CASE
            WHEN s.PENDIDIKAN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_PENDIDIKAN mk
                    WHERE  mk.KODE        = s.PENDIDIKAN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.PENDIDIKAN || '" tidak ada di master Pendidikan'
            END,

        -- STATUS_KAWIN: cek ke BJKT_BANSOS_MASTER_STATUS_KAWIN
        -- FIX: dihapus kondisi "mk.JENIS = 'STATUS_KAWIN'" yang tidak valid
        ERR_STATUS_KAWIN = CASE
            WHEN s.STATUS_KAWIN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_STATUS_KAWIN mk
                    WHERE  mk.KODE        = s.STATUS_KAWIN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_STATUS_KAWIN = CASE
            WHEN s.STATUS_KAWIN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_STATUS_KAWIN mk
                    WHERE  mk.KODE        = s.STATUS_KAWIN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.STATUS_KAWIN || '" tidak ada di master Status Kawin'
            END,

        -- STATUS_RUMAH: cek ke BJKT_BANSOS_MASTER_STATUS_RUMAH
        ERR_STATUS_RUMAH = CASE
            WHEN s.STATUS_RUMAH IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_STATUS_RUMAH mk
                    WHERE  mk.KODE        = s.STATUS_RUMAH
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_STATUS_RUMAH = CASE
            WHEN s.STATUS_RUMAH IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_STATUS_RUMAH mk
                    WHERE  mk.KODE        = s.STATUS_RUMAH
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.STATUS_RUMAH || '" tidak ada di master Status Rumah'
            END,

        -- PEKERJAAN_BIDANG_USAHA: cek ke BJKT_BANSOS_MASTER_PEKERJAAN
        ERR_PEKERJAAN = CASE
            WHEN s.PEKERJAAN_BIDANG_USAHA IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_PEKERJAAN mk
                    WHERE  mk.KODE        = s.PEKERJAAN_BIDANG_USAHA
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_PEKERJAAN = CASE
            WHEN s.PEKERJAAN_BIDANG_USAHA IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_PEKERJAAN mk
                    WHERE  mk.KODE        = s.PEKERJAAN_BIDANG_USAHA
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.PEKERJAAN_BIDANG_USAHA || '" tidak ada di master Pekerjaan'
            END,

        -- KODE_PROFESI: cek ke BJKT_BANSOS_MASTER_PROFESI
        ERR_KODE_PROFESI = CASE
            WHEN s.KODE_PROFESI IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_PROFESI mk
                    WHERE  mk.KODE        = s.KODE_PROFESI
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_KODE_PROFESI = CASE
            WHEN s.KODE_PROFESI IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_PROFESI mk
                    WHERE  mk.KODE        = s.KODE_PROFESI
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.KODE_PROFESI || '" tidak ada di master Profesi'
            END,

        -- STATUS_PEKERJAAN: cek ke BJKT_BANSOS_MASTER_STATUS_PEKERJAAN
        ERR_STATUS_PEKERJAAN = CASE
            WHEN s.STATUS_PEKERJAAN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_STATUS_PEKERJAAN mk
                    WHERE  mk.KODE        = s.STATUS_PEKERJAAN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_STATUS_PEKERJAAN = CASE
            WHEN s.STATUS_PEKERJAAN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_STATUS_PEKERJAAN mk
                    WHERE  mk.KODE        = s.STATUS_PEKERJAAN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.STATUS_PEKERJAAN || '" tidak ada di master Status Pekerjaan'
            END,

        -- HUBUNGAN: cek ke BJKT_BANSOS_MASTER_HUB_KELUARGA
        ERR_HUBUNGAN = CASE
            WHEN s.HUBUNGAN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_HUB_KELUARGA mk
                    WHERE  mk.KODE        = s.HUBUNGAN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_HUBUNGAN = CASE
            WHEN s.HUBUNGAN IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_HUB_KELUARGA mk
                    WHERE  mk.KODE        = s.HUBUNGAN
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.HUBUNGAN || '" tidak ada di master Hubungan Keluarga'
            END,

        -- STATUS_INSTANSI: cek ke BJKT_BANSOS_MASTER_JENIS_INSTANSI
        ERR_STATUS_INSTANSI = CASE
            WHEN s.STATUS_INSTANSI IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_JENIS_INSTANSI mk
                    WHERE  mk.KODE        = s.STATUS_INSTANSI
                      AND  mk.STATUS_DATA = 1)
            THEN 'Y'
            END,
        MSG_STATUS_INSTANSI = CASE
            WHEN s.STATUS_INSTANSI IS NOT NULL
             AND NOT EXISTS (
                    SELECT 1
                    FROM   BJKT_BANSOS_MASTER_JENIS_INSTANSI mk
                    WHERE  mk.KODE        = s.STATUS_INSTANSI
                      AND  mk.STATUS_DATA = 1)
            THEN 'Kode "' || s.STATUS_INSTANSI || '" tidak ada di master Jenis Instansi'
            END,

        -- TANGGAL_LAHIR: harus 8 digit angka murni (YYYYMMDD)
        ERR_TANGGAL_LAHIR = CASE
            WHEN s.TANGGAL_LAHIR IS NOT NULL
             AND NOT REGEXP_LIKE (s.TANGGAL_LAHIR, '^\d{8}$')
            THEN 'Y'
            END,
        MSG_TANGGAL_LAHIR = CASE
            WHEN s.TANGGAL_LAHIR IS NOT NULL
             AND NOT REGEXP_LIKE (s.TANGGAL_LAHIR, '^\d{8}$')
            THEN 'Format tanggal lahir tidak valid: "'
                 || s.TANGGAL_LAHIR
                 || '". Harus YYYYMMDD (contoh: 19900115)'
            END,

        -- NO_IDENTITAS (NIK): harus tepat 16 digit angka
        ERR_NO_IDENTITAS = CASE
            WHEN s.NO_IDENTITAS IS NOT NULL
             AND NOT REGEXP_LIKE (s.NO_IDENTITAS, '^\d{16}$')
            THEN 'Y'
            END,
        MSG_NO_IDENTITAS = CASE
            WHEN s.NO_IDENTITAS IS NOT NULL
             AND NOT REGEXP_LIKE (s.NO_IDENTITAS, '^\d{16}$')
            THEN 'NIK tidak valid: "'
                 || s.NO_IDENTITAS
                 || '". Harus 16 digit angka'
            END

    WHERE s.BATCH_ID = p_batch_id
      AND s.STATUS   = 'PENDING';

    -- ── PASS 2: Set STATUS dan ringkasan ERROR_COLUMNS ────────
    UPDATE BJKT_BANSOS_RECIPIENTS_STG s
    SET
        STATUS = CASE
            WHEN (   s.ERR_NAMA             IS NOT NULL
                  OR s.ERR_JEN_KELAMIN      IS NOT NULL
                  OR s.ERR_KEBANGSAAN       IS NOT NULL
                  OR s.ERR_AGAMA            IS NOT NULL
                  OR s.ERR_PENDIDIKAN       IS NOT NULL
                  OR s.ERR_STATUS_KAWIN     IS NOT NULL
                  OR s.ERR_STATUS_RUMAH     IS NOT NULL
                  OR s.ERR_PEKERJAAN        IS NOT NULL
                  OR s.ERR_KODE_PROFESI     IS NOT NULL
                  OR s.ERR_STATUS_PEKERJAAN IS NOT NULL
                  OR s.ERR_HUBUNGAN         IS NOT NULL
                  OR s.ERR_STATUS_INSTANSI  IS NOT NULL
                  OR s.ERR_TANGGAL_LAHIR    IS NOT NULL
                  OR s.ERR_NO_IDENTITAS     IS NOT NULL)
            THEN 'ERROR'
            ELSE 'VALID'
            END,
        ERROR_COLUMNS = CASE
            WHEN (   s.ERR_NAMA             IS NOT NULL
                  OR s.ERR_JEN_KELAMIN      IS NOT NULL
                  OR s.ERR_KEBANGSAAN       IS NOT NULL
                  OR s.ERR_AGAMA            IS NOT NULL
                  OR s.ERR_PENDIDIKAN       IS NOT NULL
                  OR s.ERR_STATUS_KAWIN     IS NOT NULL
                  OR s.ERR_STATUS_RUMAH     IS NOT NULL
                  OR s.ERR_PEKERJAAN        IS NOT NULL
                  OR s.ERR_KODE_PROFESI     IS NOT NULL
                  OR s.ERR_STATUS_PEKERJAAN IS NOT NULL
                  OR s.ERR_HUBUNGAN         IS NOT NULL
                  OR s.ERR_STATUS_INSTANSI  IS NOT NULL
                  OR s.ERR_TANGGAL_LAHIR    IS NOT NULL
                  OR s.ERR_NO_IDENTITAS     IS NOT NULL)
            THEN TRIM (',' FROM
                     NVL2 (s.ERR_NAMA,             'NAMA,',             '') ||
                     NVL2 (s.ERR_JEN_KELAMIN,      'JEN_KELAMIN,',      '') ||
                     NVL2 (s.ERR_KEBANGSAAN,       'KEBANGSAAN,',       '') ||
                     NVL2 (s.ERR_AGAMA,            'AGAMA,',            '') ||
                     NVL2 (s.ERR_PENDIDIKAN,       'PENDIDIKAN,',       '') ||
                     NVL2 (s.ERR_STATUS_KAWIN,     'STATUS_KAWIN,',     '') ||
                     NVL2 (s.ERR_STATUS_RUMAH,     'STATUS_RUMAH,',     '') ||
                     NVL2 (s.ERR_PEKERJAAN,        'PEKERJAAN,',        '') ||
                     NVL2 (s.ERR_KODE_PROFESI,     'KODE_PROFESI,',     '') ||
                     NVL2 (s.ERR_STATUS_PEKERJAAN, 'STATUS_PEKERJAAN,', '') ||
                     NVL2 (s.ERR_HUBUNGAN,         'HUBUNGAN,',         '') ||
                     NVL2 (s.ERR_STATUS_INSTANSI,  'STATUS_INSTANSI,',  '') ||
                     NVL2 (s.ERR_TANGGAL_LAHIR,    'TANGGAL_LAHIR,',    '') ||
                     NVL2 (s.ERR_NO_IDENTITAS,     'NO_IDENTITAS,',     ''))
            ELSE NULL
            END
    WHERE s.BATCH_ID = p_batch_id
      AND s.STATUS   = 'PENDING';

    COMMIT;

    -- Hitung hasil validasi
    SELECT COUNT(*) INTO r_valid_count
    FROM   BJKT_BANSOS_RECIPIENTS_STG
    WHERE  BATCH_ID = p_batch_id
      AND  STATUS   = 'VALID';

    SELECT COUNT(*) INTO r_error_count
    FROM   BJKT_BANSOS_RECIPIENTS_STG
    WHERE  BATCH_ID = p_batch_id
      AND  STATUS   = 'ERROR';

EXCEPTION
    WHEN OTHERS THEN
        -- Jika validasi crash, set semua PENDING ke ERROR agar tidak menggantung
        v_sqlerrm := SQLERRM; 
        UPDATE BJKT_BANSOS_RECIPIENTS_STG
        SET    STATUS           = 'ERROR',
               MSG_FINAL_INSERT = 'Validasi gagal: ' || v_sqlerrm
        WHERE  BATCH_ID = p_batch_id
          AND  STATUS   = 'PENDING';
        COMMIT;

        r_valid_count := 0;
        r_error_count := 0;
END VALIDATE_MASTER;


/*
    Insert baris VALID ke target table.
    Baris yang lolos  -> status LOADED
    Baris yang gagal  -> status ERROR + ERR_FINAL_INSERT + MSG_FINAL_INSERT
*/
PROCEDURE FINAL_INSERT (
    p_batch_id      IN  NUMBER,
    p_program_id    IN  NUMBER,
    r_loaded_count  OUT NUMBER,
    r_error_count   OUT NUMBER,
    r_status        OUT VARCHAR2,
    r_message       OUT VARCHAR2
) AS
    CURSOR cur_valid IS
        SELECT *
        FROM   BJKT_BANSOS_RECIPIENTS_STG
        WHERE  BATCH_ID = p_batch_id
          AND  STATUS   = 'VALID'
        ORDER BY LINE_NUMBER;

    TYPE t_stg IS TABLE OF BJKT_BANSOS_RECIPIENTS_STG%ROWTYPE INDEX BY PLS_INTEGER;
    v_rows      t_stg;
    v_limit     CONSTANT PLS_INTEGER := 1000;
    v_total_ok  NUMBER := 0;
    v_total_err NUMBER := 0;

    TYPE t_err_set IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
    v_err_set t_err_set;

    bulk_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT (bulk_errors, -24381);
BEGIN
    r_loaded_count := 0;
    r_error_count  := 0;

    OPEN cur_valid;
    LOOP
        FETCH cur_valid BULK COLLECT INTO v_rows LIMIT v_limit;
        EXIT WHEN v_rows.COUNT = 0;

        v_err_set.DELETE;

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
                    v_rows(i).NAMA,
                    v_rows(i).JEN_KELAMIN,
                    v_rows(i).KEBANGSAAN,
                    v_rows(i).TEMPAT_LAHIR,
                    TO_DATE (v_rows(i).TANGGAL_LAHIR, 'YYYYMMDD'),
                    v_rows(i).NO_IDENTITAS,
                    v_rows(i).NAMA_IBU_KANDUNG_WALI,
                    v_rows(i).AGAMA,
                    v_rows(i).PENDIDIKAN,
                    v_rows(i).ALAMAT_KTP,
                    v_rows(i).ALAMAT_DOMISILI,
                    v_rows(i).RT,
                    v_rows(i).RW,
                    v_rows(i).KELURAHAN,
                    v_rows(i).KECAMATAN,
                    v_rows(i).KOTA,
                    v_rows(i).PROPINSI,
                    v_rows(i).KODE_POS,
                    v_rows(i).TELP_HP,
                    v_rows(i).NOMOR_INSTANSI,
                    v_rows(i).NAMA_INSTANSI,
                    v_rows(i).ALAMAT_INSTANSI,
                    v_rows(i).KODE_POS_INSTANSI,
                    v_rows(i).NO_TELP_INSTANSI,
                    v_rows(i).STATUS_INSTANSI,
                    v_rows(i).NAMA_PIHAK_DIHUBUNGI,
                    v_rows(i).HUBUNGAN,
                    v_rows(i).ALAMAT,
                    v_rows(i).KOTA_DOMISILI,
                    v_rows(i).PROPINSI_DOMISILI,
                    v_rows(i).TELPON,
                    v_rows(i).STATUS_KAWIN,
                    v_rows(i).STATUS_RUMAH,
                    v_rows(i).PEKERJAAN_BIDANG_USAHA,
                    v_rows(i).KODE_PROFESI,
                    v_rows(i).STATUS_PEKERJAAN,
                    v_rows(i).SUAMI_ISTRI,
                    p_program_id,
                    SYSTIMESTAMP,
                    TO_NUMBER (
                        REPLACE (
                            REPLACE (v_rows(i).TOTAL_DANA, '.', ''),
                            ',', '.'
                        )
                    )
                );

            -- Seluruh chunk berhasil: update LOADED sekaligus
            FORALL i IN 1..v_rows.COUNT
                UPDATE BJKT_BANSOS_RECIPIENTS_STG
                SET    STATUS    = 'LOADED',
                       LOADED_AT = SYSTIMESTAMP
                WHERE  ID = v_rows(i).ID;

            v_total_ok := v_total_ok + v_rows.COUNT;
            COMMIT;

        EXCEPTION
            WHEN bulk_errors THEN
                -- ── Tampung detail error ke variabel lokal dulu ────────
                DECLARE
                    v_err_idx   PLS_INTEGER;
                    v_err_code  NUMBER;
                    v_err_msg   VARCHAR2(1000);
                BEGIN
                    -- Kumpulkan semua index yang error di chunk ini
                    FOR j IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                        v_err_idx  := SQL%BULK_EXCEPTIONS(j).ERROR_INDEX;
                        v_err_code := SQL%BULK_EXCEPTIONS(j).ERROR_CODE;
                        v_err_msg  := SQLERRM(-v_err_code);  -- negate via variabel, bukan inline

                        v_err_set(v_err_idx) := v_err_code;

                        UPDATE BJKT_BANSOS_RECIPIENTS_STG
                        SET    STATUS           = 'ERROR',
                            ERR_FINAL_INSERT = 'Y',
                            MSG_FINAL_INSERT = SUBSTR(
                                'Gagal insert ke target. ORA-'
                                || v_err_code
                                || ': '
                                || v_err_msg,
                                1, 1000)
                        WHERE  ID = v_rows(v_err_idx).ID;

                        v_total_err := v_total_err + 1;
                    END LOOP;

                    -- Baris yang TIDAK error dalam chunk ini → LOADED
                    FOR i IN 1..v_rows.COUNT LOOP
                        IF NOT v_err_set.EXISTS(i) THEN
                            UPDATE BJKT_BANSOS_RECIPIENTS_STG
                            SET    STATUS    = 'LOADED',
                                LOADED_AT = SYSTIMESTAMP
                            WHERE  ID = v_rows(i).ID;
                            v_total_ok := v_total_ok + 1;
                        END IF;
                    END LOOP;

                    COMMIT;
                END;
        END;
    END LOOP;
    CLOSE cur_valid;

    r_loaded_count := v_total_ok;
    r_error_count  := v_total_err;

    IF v_total_err > 0 AND v_total_ok = 0 THEN
        r_status  := 'ERROR';
        r_message := 'Semua baris gagal diinsert. Total error: ' || v_total_err;
    ELSIF v_total_err > 0 THEN
        r_status  := 'PARTIAL';
        r_message := 'Berhasil: ' || v_total_ok
                  || ' baris. Gagal DB: ' || v_total_err || ' baris.';
    ELSE
        r_status  := 'SUCCESS';
        r_message := 'Semua ' || v_total_ok || ' baris berhasil disimpan.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF cur_valid%ISOPEN THEN
            CLOSE cur_valid;
        END IF;
        r_status  := 'ERROR';
        r_message := 'Error cursor di FINAL_INSERT: ' || SQLERRM;
END FINAL_INSERT;


END BJKT_UPLOAD_BANSOS_PKG;
/