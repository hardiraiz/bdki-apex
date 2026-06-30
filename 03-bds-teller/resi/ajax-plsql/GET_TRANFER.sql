DECLARE
    l_data SYS_REFCURSOR;
    v_nama_pengirim     VARCHAR2(200);
    v_no_rek_pengirim   VARCHAR2(50);
    v_no_telp           VARCHAR2(50);
    v_email             VARCHAR2(200);
    v_nominal_transaksi NUMBER;
    v_biaya_transaksi   NUMBER;
    v_total_transaksi   NUMBER;
    v_jenis_transaksi   VARCHAR2(200);
    v_tanggal_transaksi VARCHAR2(50);
    v_jam_transaksi     VARCHAR2(20);
    v_kode_cabang       VARCHAR2(200);
    v_petugas           VARCHAR2(200);
    v_kode_referensi    VARCHAR2(50);
    v_nama_penerima     VARCHAR2(200);
    v_no_rek_penerima   VARCHAR2(50);
    v_nama_bank         VARCHAR2(200);
BEGIN
    BEGIN
        SELECT NRIK, BRANCH_CODE || ' - ' || NAMA_UNIT_KERJA
        INTO v_petugas, v_kode_cabang
        FROM BJKT_DIGSLIP_USERS_V 
        WHERE USER_NAME = NVL(V('APP_USER'), USER)
            AND ROWNUM = 1;
    EXCEPTION
        WHEN OTHERS THEN
            v_petugas := NULL;
            v_kode_cabang := NULL;
    END;

    OPEN l_data FOR 
        SELECT
            NAMA_PENGIRIM,
            NO_REKENING_PENGIRIM             AS NOMOR_REKENING_PENGIRIM,
            NO_HANDPHONE_PENGIRIM            AS NO_TELP,
            EMAIL_PENGIRIM                   AS EMAIL,
            NOMINAL_TRANSFER                 AS NOMINAL_TRANSAKSI,
            BIAYA_LAYANAN_TRANSAKSI          AS BIAYA_TRANSAKSI,
            (NVL(NOMINAL_TRANSFER, 0) + 
            NVL(BIAYA_LAYANAN_TRANSAKSI, 0)) AS TOTAL_TRANSAKSI,
            LAYANAN_TRANSFER                 AS JENIS_TRANSAKSI,
            TO_CHAR(SYSDATE, 'DD-MM-YYYY')   AS TANGGAL_TRANSAKSI,
            TO_CHAR(SYSDATE, 'HH24:MI:SS')   AS JAM_TRANSAKSI,
            v_kode_cabang                    AS CABANG,
            v_petugas                        AS PETUGAS,
            KODE_REF                         AS KODE_REFERENSI,
            NAMA_PENERIMA,
            NO_REKENING_PENERIMA             AS NOMOR_REKENING_PENERIMA,
            BANK_PENERIMA
        FROM BJKT_DIGSLIP_TRANSFER_BANK_LAIN
        WHERE KODE_REF = apex_application.g_x01;

    apex_json.open_object;
    apex_json.open_array('data');

    LOOP
        FETCH l_data INTO
            v_nama_pengirim,
            v_no_rek_pengirim,
            v_no_telp,
            v_email,
            v_nominal_transaksi,
            v_biaya_transaksi,
            v_total_transaksi,
            v_jenis_transaksi,
            v_tanggal_transaksi,
            v_jam_transaksi,
            v_kode_cabang,
            v_petugas,
            v_kode_referensi,
            v_nama_penerima,
            v_no_rek_penerima,
            v_nama_bank;
        EXIT WHEN l_data%NOTFOUND;

        apex_json.open_object;
        apex_json.write('NAMA_PENGIRIM', v_nama_pengirim);
        apex_json.write('NO_REK_PENGIRIM', v_no_rek_pengirim);
        apex_json.write('NO_TELP', v_no_telp);
        apex_json.write('EMAIL', v_email);
        apex_json.write('NOMINAL_TRANSAKSI', v_nominal_transaksi);
        apex_json.write('BIAYA_TRANSAKSI', v_biaya_transaksi);
        apex_json.write('TOTAL_TRANSAKSI', v_total_transaksi);
        apex_json.write('JENIS_TRANSAKSI', v_jenis_transaksi);
        apex_json.write('TANGGAL_TRANSAKSI', v_tanggal_transaksi);
        apex_json.write('JAM_TRANSAKSI', v_jam_transaksi);
        apex_json.write('CABANG', v_kode_cabang);
        apex_json.write('PETUGAS', v_petugas);
        apex_json.write('KODE_REFERENSI', v_kode_referensi);
        apex_json.write('NAMA_PENERIMA', v_nama_penerima);
        apex_json.write('NO_REK_PENERIMA', v_no_rek_penerima);
        apex_json.write('NAMA_BANK_PENERIMA', v_nama_bank);
        apex_json.close_object;
    END LOOP;

    CLOSE l_data;

    apex_json.close_array;
    apex_json.close_object;
END;