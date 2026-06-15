SELECT SUM("fbi") 
FROM (
    SELECT DISTINCT * FROM BJKT_PNL_FBI_SY
    WHERE "nomor_rekening" = '432003602100'
        AND "periode" = '2026-03-31'
)
WHERE "kode_cabang_akhir" = '108';
/

SELECT * FROM BJKT_PNL_FEE_BASED_INCOME_MV WHERE "kode_cabang" = '108';
/

SET DEFINE OFF;
/

SELECT
    "periode"       AS "periode",
    "kode_cabang",
    "kode_konsol",

    ("fbi_total" / POWER(10,6))             AS "fbi_total",
    ("fbi_acc_maint" / POWER(10,6))         AS "fbi_acc_maint",
    ("fbi_atm" / POWER(10,6))               AS "fbi_atm",
    ("fbi_jom" / POWER(10,6))               AS "fbi_jom",
    ("fbi_edc" / POWER(10,6))               AS "fbi_edc",
    ("fbi_cms" / POWER(10,6))               AS "fbi_cms",
    ("fbi_abank" / POWER(10,6))             AS "fbi_abank",
    ("fbi_jas_pot" / POWER(10,6))           AS "fbi_jas_pot",
    ("fbi_bisnis_kartu" / POWER(10,6))      AS "fbi_bisnis_kartu",
    ("fbi_bisnis_sdb" / POWER(10,6))        AS "fbi_bisnis_sdb",
    ("fbi_kirim_uang" / POWER(10,6))        AS "fbi_kirim_uang",
    ("fbi_rest_biaya_kantor" / POWER(10,6)) AS "fbi_rest_biaya_kantor",
    ("fbi_pin_nas_pen" / POWER(10,6))       AS "fbi_pin_nas_pen",
    ("fbi_bank_garansi" / POWER(10,6))      AS "fbi_bank_garansi",
    ("fbi_admin_kredit" / POWER(10,6))      AS "fbi_admin_kredit",
    ("fbi_ker_pihak_lain" / POWER(10,6))    AS "fbi_ker_pihak_lain",
    ("fbi_lainnya" / POWER(10,6))           AS "fbi_lainnya"
FROM (
    SELECT
        TO_DATE("periode", 'YYYY-MM-DD') AS "periode",
        "kode_cabang_akhir" AS "kode_cabang",
        "kode_konsol",

        SUM("fbi") AS "fbi_total",

        SUM(CASE WHEN "nama" = 'Account Maintenance'
                 THEN "fbi" END) AS "fbi_acc_maint",

        SUM(CASE WHEN "nama" = 'ATM FBI'
                 THEN "fbi" END) AS "fbi_atm",

        SUM(CASE WHEN "nama" = 'JakOne Mobile FBI'
                 THEN "fbi" END) AS "fbi_jom",

        SUM(CASE WHEN "nama" = 'EDC FBI'
                 THEN "fbi" END) AS "fbi_edc",

        SUM(CASE WHEN "nama" = 'CMS'
                 THEN "fbi" END) AS "fbi_cms",

        SUM(CASE WHEN "nama" = 'ABANK FBI'
                 THEN "fbi" END) AS "fbi_abank",

        SUM(CASE WHEN "nomor_rekening" = '432003602100'
                 THEN "fbi" END) AS "fbi_jas_pot",

        SUM(CASE WHEN "nama" = 'Bisnis Kartu'
                 THEN "fbi" END) AS "fbi_bisnis_kartu",

        SUM(CASE WHEN "nama" = 'Bisnis SDB'
                 THEN "fbi" END) AS "fbi_bisnis_sdb",

        SUM(CASE WHEN "nama" = 'Kiriman Uang (RTGS, kliring, dll.)'
                 THEN "fbi" END) AS "fbi_kirim_uang",

        SUM(CASE WHEN "nama" = 'RESTITUSI BIAYA KANTOR'
                 THEN "fbi" END) AS "fbi_rest_biaya_kantor",

        SUM(CASE WHEN "nama" = 'Pinalty Nasabah & Penolakan'
                 THEN "fbi" END) AS "fbi_pin_nas_pen",

        SUM(CASE WHEN "nama" = 'BANK GARANSI'
                 THEN "fbi" END) AS "fbi_bank_garansi",

        SUM(CASE WHEN "nama" = 'Admin Kredit'
                 THEN "fbi" END) AS "fbi_admin_kredit",

        SUM(CASE WHEN "nama" = 'Kerjasama Pihak Lain (komisi agen, asuransi)'
                 THEN "fbi" END) AS "fbi_ker_pihak_lain",

        SUM(CASE WHEN "nama" = 'Lainnya (komisi notaris, denda tunggakan)'
                 THEN "fbi" END) AS "fbi_lainnya"

    FROM BJKT_PNL_FBI_SY
    WHERE "kode_cabang_akhir" = '108'
    GROUP BY
        "periode",
        "kode_cabang_akhir",
        "kode_konsol"
);
/

SELECT * FROM BJKT_PNL_FBI_SY WHERE "nomor_rekening" = '432003602100' and "kode_cabang_akhir" = '108';
/