DECLARE
    l_data SYS_REFCURSOR;
    v_nama_penarik        VARCHAR2(100);
    v_nomor_rekening      VARCHAR2(100);
    v_no_telp             VARCHAR2(50);
    v_email               VARCHAR2(100);
    v_nominal_transaksi   NUMBER;
    v_biaya               NUMBER;
    v_tanggal_transaksi   VARCHAR2(50);
    v_jam_transaksi       VARCHAR2(50);
    v_kode_cabang         VARCHAR2(50);
    v_petugas             VARCHAR2(100);
    v_kode_referensi      VARCHAR2(255);
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
            NAMA                                    AS NAMA_PENARIK,
            NOMOR_REKENING                          AS NOMOR_REKENING,
            NOMOR_HP                                AS NO_TELP,
            EMAIL                                   AS EMAIL,
            NOMINAL_TARIK                           AS NOMINAL_TRANSAKSI,
            BIAYA                                   AS BIAYA,
            TO_CHAR(TANGGAL_TARIK, 'DD-MM-YYYY')    AS TANGGAL_TRANSAKSI,
            TO_CHAR(TANGGAL_TARIK, 'HH24:MI:SS')    AS JAM_TRANSAKSI,
            v_kode_cabang                           AS KODE_CABANG,
            v_petugas                               AS PETUGAS,
            KODE_REF                                AS KODE_REFERENSI
        FROM BJKT_DIGSLIP_TARIK_TUNAI
        WHERE KODE_REF = apex_application.g_x01;

    apex_json.open_object;
    apex_json.open_array('data');

    LOOP
        FETCH l_data INTO
            v_nama_penarik,
            v_nomor_rekening,
            v_no_telp,
            v_email,
            v_nominal_transaksi,
            v_biaya,
            v_tanggal_transaksi,
            v_jam_transaksi,
            v_kode_cabang,
            v_petugas,
            v_kode_referensi;
        EXIT WHEN l_data%NOTFOUND;

        apex_json.open_object;
        apex_json.write('NAMA_PENARIK', v_nama_penarik);
        apex_json.write('NOMOR_REKENING', v_nomor_rekening);
        apex_json.write('NO_TELP', v_no_telp);
        apex_json.write('EMAIL', v_email);
        apex_json.write('NOMINAL_TRANSAKSI', v_nominal_transaksi);
        apex_json.write('BIAYA', v_biaya);
        apex_json.write('TANGGAL_TRANSAKSI', v_tanggal_transaksi);
        apex_json.write('JAM_TRANSAKSI', v_jam_transaksi);
        apex_json.write('KODE_CABANG', v_kode_cabang);
        apex_json.write('PETUGAS', v_petugas);
        apex_json.write('KODE_REFERENSI', v_kode_referensi);
        apex_json.close_object;
    END LOOP;

    CLOSE l_data;

    apex_json.close_array;
    apex_json.close_object;
END;