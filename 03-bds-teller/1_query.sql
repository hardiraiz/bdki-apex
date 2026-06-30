SELECT * FROM BJKT_DIGSLIP_SETOR_TUNAI;
/

DECLARE
    l_hash      VARCHAR2(64);
    p_length    NUMBER DEFAULT 10; 
BEGIN
    l_hash := BJKT_JAVA_PKG.HASH256('108');

    DBMS_OUTPUT.PUT_LINE('Result: ' || SUBSTR(l_hash, 1, p_length));
END;
/

SELECT * FROM BJKT_DIGSLIP_SETOR_TUNAI WHERE KODE_REF = 'KH11OS';
/

SELECT object_name, status FROM user_objects WHERE object_name = 'AS_PDF3';
/

SELECT * FROM BJKT_DIGSLIP_TARIK_TUNAI WHERE KODE_REF = 'TF9A8B7C';
/

SELECT * FROM BJKT_DIGSLIP_TELLER_USERS_V WHERE USER_NAME = 'MA51010424';
/

DELETE FROM BJKT_DIGSLIP_TARIK_TUNAI;
DELETE FROM BJKT_DIGSLIP_SETOR_TUNAI;
DELETE FROM BJKT_DIGSLIP_TRANSFER_BANK_LAIN;
COMMIT;
/
SELECT * FROM BJKT_DIGSLIP_SETOR_TUNAI WHERE KODE_REF = 'STGRDE9L';
/

DECLARE
    v_status VARCHAR2(100);
    v_message VARCHAR2(4000);
BEGIN
    BJKT_EFORM_INTEGRATIONS_PKG.get_transaction_withdraw('TT1X4KEZ', v_status, v_message);
    -- apex_error.add_error (
    --     p_message          => 'STATUS: ' || v_status || ', MESSAGE: ' || v_message,
    --     p_display_location => apex_error.c_inline_in_notification
    -- );
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status || ', Error: ' || v_message);
END;
/

SELECT user_name || ' - ' || nama AS TELLER
FROM bjkt_digslip_users_v 
WHERE USER_NAME = 'MA51010424'
FETCH FIRST 1 ROWS ONLY;
/

SELECT id_unit_kerja || ' - ' || nama_unit_kerja AS CABANG
FROM bjkt_digslip_users_v 
WHERE USER_NAME = 'MA51010424'
FETCH FIRST 1 ROWS ONLY;
/

SELECT * FROM bjkt_digslip_users_v WHERE USER_NAME = 'MA51010424';


SELECT
    NAMA                                    AS NAMA_PENARIK,
    NOMOR_REKENING                          AS NOMOR_REKENING,
    NOMOR_HP                                AS NO_TELP,
    EMAIL                                   AS EMAIL,
    NOMINAL_TARIK                           AS NOMINAL_TRANSAKSI,
    BIAYA                                   AS BIAYA,
    TO_CHAR(TANGGAL_TARIK, 'DD-MON-YYYY')   AS TANGGAL_TRANSAKSI,
    TO_CHAR(TANGGAL_TARIK, 'HH24:MI')       AS JAM_TRANSAKSI,
    KODE_REF                                AS KODE_REFERENSI
FROM BJKT_DIGSLIP_TARIK_TUNAI
WHERE KODE_REF = 'TT1X4KEZ';
/

SELECT * FROM BJKT_DIGSLIP_USERS_V;
/

SELECT
    NAMA_PENGIRIM,
    NO_REKENING_PENGIRIM            AS NOMOR_REKENING_PENGIRIM,
    NO_HANDPHONE_PENGIRIM           AS NO_TELP,
    EMAIL_PENGIRIM                  AS EMAIL,
    NOMINAL_TRANSFER                AS NOMINAL_TRANSAKSI,
    BIAYA_LAYANAN_TRANSAKSI         AS BIAYA_TRANSAKSI,
    (NVL(NOMINAL_TRANSFER, 0) + 
     NVL(BIAYA_LAYANAN_TRANSAKSI, 0)) AS TOTAL_TRANSAKSI,
    LAYANAN_TRANSFER                AS JENIS_TRANSAKSI,
    TO_CHAR(SYSDATE, 'DD-MON-YYYY') AS TANGGAL_TRANSAKSI,
    TO_CHAR(SYSDATE, 'HH24:MI')     AS JAM_TRANSAKSI,
    'v_kode_cabang'                   AS CABANG,
    'v_petugas'                       AS PETUGAS,
    KODE_REF                        AS KODE_REFERENSI,
    NAMA_PENERIMA,
    NO_REKENING_PENERIMA            AS NOMOR_REKENING_PENERIMA,
    BANK_PENERIMA
FROM BJKT_DIGSLIP_TRANSFER_BANK_LAIN
WHERE KODE_REF = 'TF9A8B7C';
/

SELECT * FROM BJKT_DIGSLIP_USERS_V;
/

SELECT 
    'TABUNGAN' AS JENIS_REKENING, 
    st.NOMOR_REKENING_PENERIMA AS NOMOR_REKENING, 
    st.NAMA_PENERIMA AS PEMILIK_REKENING, 
    wu.WORK_UNIT_NAME AS CABANG_TUJUAN, 
    st.NOMINAL AS NOMINAL_TRANSAKSI, 
    1 AS KURS,
    st.NOMINAL AS TOTAL_TRANSAKSI,
    'SETOR TUNAI' AS KETERANGAN, 
    'v_cabang' AS CABANG,
    TO_CHAR(SYSDATE, 'DD-MM-YYYY / HH24:MI:SS') AS TANGGAL_TRANSAKSI,
    '1000 - SETOR TUNAI' AS JENIS_TRANSAKSI,
    'IDR - RUPIAH' AS MT_UANG_TRANSAKSI,
    st.KODE_REF AS KODE_REFERENSI, 
    'v_teller' AS TELLER,
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
WHERE KODE_REF = 'STGRDE9L';
/

SELECT * FROM BJKT_WORK_UNITS WHERE BRANCH_CODE = '683'
AND PARENT_BRANCH_CODE <> 0;
/

/* 
    1. Buat satu page item untuk menampung pending ref dengan session state memory 
    2. Cek apakah ada pending ref, jalankan pada dynamic action before get referal
*/
DECLARE
    v_user     VARCHAR2(100);
    v_kode_ref VARCHAR2(100);
BEGIN
    v_user := 'MA51010424';
    SELECT COALESCE(
        (SELECT KODE_REF FROM BJKT_DIGSLIP_TARIK_TUNAI WHERE CREATED_BY = v_user AND STATUS NOT IN ('Dibatalkan', 'Sukses') AND ROWNUM = 1),
        (SELECT KODE_REF FROM BJKT_DIGSLIP_SETOR_TUNAI WHERE CREATED_BY = v_user AND STATUS NOT IN ('Dibatalkan', 'Sukses') AND ROWNUM = 1),
        (SELECT KODE_REF FROM BJKT_DIGSLIP_TRANSFER_BANK_LAIN WHERE CREATED_BY = v_user AND STATUS NOT IN ('Dibatalkan', 'Sukses') AND ROWNUM = 1)
    ) INTO v_kode_ref
    FROM DUAL;

    -- :P1000_PENDING_REF := v_kode_ref;
    DBMS_OUTPUT.PUT_LINE('Kode Ref: ' || v_kode_ref);
END;
/
/*
    3. Go to page jika pending ref tidak null
    4. Tambahkan client side condition get ref jika pending ref null
    5. Jalankan sintaks execute javascript ini sebelum pemanggilan sintaks get kode ref

    const pendingRef = apex.item('P1000_PENDING_REF').getValue();
    if (pendingRef) {
        apex.navigation.redirect(
            `f?p=&APP_ID.:1005:&APP_SESSION.::&DEBUG.::P1005_PENDING_REF:${pendingRef}`
        );
    }

    const pendingRef = apex.item('P1000_PENDING_REF').getValue();
    if (pendingRef) {
        apex.navigation.redirect(
            apex.page.url({
                pageId: "1005",
                itemNames: ["P1005_PENDING_REF"],
                itemValues: [pendingRef]
            })
        );
    }
*/