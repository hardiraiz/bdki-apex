DECLARE
    l_data SYS_REFCURSOR;
    v_jenis_rekening      VARCHAR2(100);
    v_nomor_rekening      NUMBER;
    v_pemilik_rekening    VARCHAR2(100);
    v_cabang_tujuan       VARCHAR2(200);
    v_nominal_transaksi   NUMBER;
    v_biaya_transaksi     NUMBER;
    v_kurs                NUMBER;
    v_total_transaksi     NUMBER;
    v_keterangan          VARCHAR2(100);
    v_cabang              VARCHAR2(200);
    v_tanggal_transaksi   VARCHAR2(50);
    v_jenis_transaksi     VARCHAR2(100);
    v_mt_uang_transaksi   VARCHAR2(100);
    v_kode_referensi      VARCHAR2(50);
    v_teller              VARCHAR2(50);
    v_supervisor          VARCHAR2(50);
    v_nama_penyetor       VARCHAR2(100);
    v_alamat_penyetor     VARCHAR2(200);
    v_jenis_identitas     VARCHAR2(50);
    v_no_identitas        VARCHAR2(50);
    v_no_telp             VARCHAR2(50);
    v_sumber_dana         VARCHAR2(100);
    v_tujuan_transaksi    VARCHAR2(100);
BEGIN
    BEGIN
        SELECT NRIK, BRANCH_CODE || ' - ' || NAMA_UNIT_KERJA
        INTO v_teller, v_cabang
        FROM BJKT_DIGSLIP_USERS_V 
        WHERE USER_NAME = NVL(V('APP_USER'), USER)
            AND ROWNUM = 1;
    EXCEPTION
        WHEN OTHERS THEN
            v_teller := NULL;
            v_cabang := NULL;
    END;

    OPEN l_data FOR 
        SELECT 
            'TABUNGAN' AS JENIS_REKENING, 
            st.NOMOR_REKENING_PENERIMA AS NOMOR_REKENING, 
            st.NAMA_PENERIMA AS PEMILIK_REKENING, 
            wu.WORK_UNIT_NAME AS CABANG_TUJUAN, 
            st.NOMINAL AS NOMINAL_TRANSAKSI, 
            1 AS KURS,
            st.NOMINAL AS TOTAL_TRANSAKSI,
            'SETOR TUNAI' AS KETERANGAN, 
            v_cabang AS CABANG,
            TO_CHAR(SYSDATE, 'DD-MM-YYYY / HH24:MI:SS') AS TANGGAL_TRANSAKSI,
            '1000 - SETOR TUNAI' AS JENIS_TRANSAKSI,
            'IDR - RUPIAH' AS MT_UANG_TRANSAKSI,
            st.KODE_REF AS KODE_REFERENSI, 
            v_teller AS TELLER,
            NULL AS SUPERVISOR,
            st.NAMA_NIK_PENYETOR AS NAMA_PENYETOR,
            st.ALAMAT_PENYETOR AS ALAMAT_PENYETOR, 
            'KTP' AS JENIS_IDENTITAS,
            st.NIK_PENYETOR AS NO_IDENTITAS,
            st.NOMOR_HP_PENYETOR AS NO_TELP, 
            st.SUMBER_DANA AS SUMBER_DANA,
            st.TUJUAN_TRANSAKSI AS TUJUAN_TRANSAKSI
        FROM BJKT_DIGSLIP_SETOR_TUNAI st
        LEFT JOIN BJKT_WORK_UNITS wu
            ON  wu.BRANCH_CODE = SUBSTR(st.NOMOR_REKENING_PENERIMA, 1, 3)
            AND wu.PARENT_BRANCH_CODE <> 0
        WHERE KODE_REF = apex_application.g_x01;

    apex_json.open_object;
    apex_json.open_array('data');

    LOOP
        FETCH l_data INTO
            v_jenis_rekening, v_nomor_rekening, v_pemilik_rekening, v_cabang_tujuan,
            v_nominal_transaksi, v_kurs, v_total_transaksi,
            v_keterangan, v_cabang, v_tanggal_transaksi, v_jenis_transaksi,
            v_mt_uang_transaksi, v_kode_referensi, v_teller, v_supervisor,
            v_nama_penyetor, v_alamat_penyetor, v_jenis_identitas, v_no_identitas,
            v_no_telp, v_sumber_dana, v_tujuan_transaksi;
        EXIT WHEN l_data%NOTFOUND;

        apex_json.open_object;
        apex_json.write('JENIS_REKENING', v_jenis_rekening);
        apex_json.write('NOMOR_REKENING', v_nomor_rekening);
        apex_json.write('PEMILIK_REKENING', v_pemilik_rekening);
        apex_json.write('CABANG_TUJUAN', v_cabang_tujuan);
        apex_json.write('NOMINAL_TRANSAKSI', v_nominal_transaksi);
        apex_json.write('KURS', v_kurs);
        apex_json.write('TOTAL_TRANSAKSI', v_total_transaksi);
        apex_json.write('KETERANGAN', v_keterangan);
        apex_json.write('CABANG', v_cabang);
        apex_json.write('TANGGAL_TRANSAKSI', v_tanggal_transaksi);
        apex_json.write('JENIS_TRANSAKSI', v_jenis_transaksi);
        apex_json.write('MT_UANG_TRANSAKSI', v_mt_uang_transaksi);
        apex_json.write('KODE_REFERENSI', v_kode_referensi);
        apex_json.write('TELLER', v_teller);
        apex_json.write('SUPERVISOR', v_supervisor);
        apex_json.write('NAMA_PENYETOR', v_nama_penyetor);
        apex_json.write('ALAMAT_PENYETOR', v_alamat_penyetor);
        apex_json.write('JENIS_IDENTITAS', v_jenis_identitas);
        apex_json.write('NO_IDENTITAS', v_no_identitas);
        apex_json.write('NO_TELP', v_no_telp);
        apex_json.write('SUMBER_DANA', v_sumber_dana);
        apex_json.write('TUJUAN_TRANSAKSI', v_tujuan_transaksi);
        apex_json.close_object;
    END LOOP;

    CLOSE l_data;

    apex_json.close_array;
    apex_json.close_object;
END;