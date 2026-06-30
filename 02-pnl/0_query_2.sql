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

SELECT
    "periode"                                  AS "periode",
    "kode_cabang"                              AS "kode_cabang",
    "kode_konsol",
    ABS((SUM("nom_ckpn") / POWER(10,6)))  AS "ckpn_nominal"
FROM BJKT_PNL_CKPN_SY
WHERE
        "tipe_segment" IN ('Konsumer', 'Mikro', 'UKM')
    AND "kode_cabang" = '108'
    -- AND "produk" = 'Konven' -- hilangkan filter produk Hardi: 10-Jun-26
GROUP BY "periode", "kode_cabang", "kode_konsol";
/

select SUM("fbi") from (
    select distinct * from "dwh"."pnl_fbi"@DWH
    where "nama" ='ATM FBI' AND "kode_cabang_akhir" = '108'
) a;
/
select SUM("fbi") from (
    select distinct * from "dwh"."pnl_fbi"@DWH
    where "nama" = 'CMS' AND "kode_cabang_akhir" = '108'
) a;
/

-- Beban CKPN Retail Only
select "kode_cabang", sum("nominal_ckpn") "nom" from "dwh"."pnl_ckpn"@DWH
where "tipe_segment" <> 'Commercial' and "kode_cabang" in ('108','101','702','726')
group by "kode_cabang";

-- Beban CKPN Total
select "kode_cabang", sum("nominal_ckpn") "nom" from "dwh"."pnl_ckpn"@DWH
group by "kode_cabang";

-- JOIN BEBAN CKPN
WITH agg AS (
    SELECT
        "periode",
        "kode_cabang",
        "kode_konsol",
        SUM(CASE WHEN "tipe_segment" <> 'Commercial' 
                 THEN "nominal_ckpn" 
                 ELSE 0 END)      AS ckpn_ret_only_raw,
        SUM("nominal_ckpn")      AS ckpn_total_raw
    FROM BJKT_PNL_CKPN_SY
    WHERE "kode_cabang" = '108'
    GROUP BY 
    "periode", 
    "kode_cabang", "kode_konsol"
)
SELECT
    "periode",
    "kode_cabang",
    "kode_konsol",
    ABS(ckpn_ret_only_raw) AS "ckpn_ret_only",
    ABS(ckpn_total_raw)    AS "ckpn_total"
FROM agg
WHERE "kode_cabang" = '108'
;
/*
    (F7*ABS(F11)/(F7*((C25+C55)/C15)+(1-F7)*((C45+C54)/C37)),0)
    KREDIT_OF_PORTOFOLIO*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_KONVEN)+(1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_KONVEN))
    0.070311313*1537.217772/(0.070311313*((8303.459673+-4164.059564)/969283.6396)+(1-0.070311313)*((-40462.91744+59938.38296)/14062792.67))
    = 68071.87539
*/
-- (KREDIT_OF_PORTOFOLIO*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_KONVEN) + (1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_KONVEN)), 0)

select * from "pnl"."dim_branch_v2"@DWH;

select * from BJKT_PNL_CHARGE_LOAN_SY;

select * from BJKT_PNL_DIRECT_OPEX_SY;

select distinct "tanggal_data" from BJKT_PNL_CKPN_SY;

select * from BJKT_PNL_FEE_BASED_INCOME_MV where "kode_cabang" = '101' order by "periode" asc;

select distinct * from BJKT_PNL_FBI_SY where "kode_cabang_akhir" = '101';
select distinct * from BJKT_PNL_FBI_SY where "nama" = 'ATM FBI' and "kode_cabang_akhir" ='101';

select distinct * from "pnl"."pnl_fbi"@DWH where "nama" = 'CMS' and "kode_cabang_akhir" ='108';









select "periode", "kode_cabang_akhir", "kode_konsol", sum("fbi") AS "nominal" from BJKT_PNL_FBI_SY 
where "nama" = 'Account Maintenance' and "kode_cabang_akhir" ='101'
group by "periode", "kode_cabang_akhir", "kode_konsol"
order by "periode" desc;

select * from "pnl"."pnl_fbi"@DWH where "kode_konsol" is null;


-- CEK MV
SELECT * FROM BJKT_PNL_AVG_BAL_CREDIT_MV 
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_AVG_BAL_DPK_MV 
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV 
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV 
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_FTP_INCOME_MV 
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_FTP_CHARGE_MV 
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_NII_POST_FTP_MV
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_FEE_BASED_INCOME_MV
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_DIRECT_OPEX_MV -- kolom kode_konsol belum ada
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_BEBAN_CKPN_MV
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;
SELECT * FROM BJKT_PNL_BEBAN_CKPN_TOT_MV
WHERE 
        "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kode_konsol
    AND "kode_cabang" = :kode_cabang
;

SELECT
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "cabang"                            AS "kode_cabang",
    "nama_kantor_akhir"                 AS "nama_cabang",
    "kode_konsol"                       AS "kode_konsol",
    "nama_konsol"                       AS "nama_konsol",

    (SUM("avg") / POWER(10,6))                                                            
        AS "total_kredit",

    -- Konven
    (SUM(CASE WHEN "produk" = 'Konven' THEN "avg" ELSE NULL END) / POWER(10,6))         
        AS "kredit_total_konven",
    (SUM(CASE WHEN "produk" = 'Konven'
                    AND "kategori_segment" = 'KMG' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_kmg",
    (SUM(CASE WHEN "produk" = 'Konven'
                    AND "kategori_segment" = 'KPR' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_kpr",
    (SUM(CASE WHEN "produk" = 'Konven'
                    AND "tipe_segment" = 'Mikro' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_mikro",
    (SUM(CASE WHEN "produk" = 'Konven'
                    AND "tipe_segment" = 'UKM' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_ukm",

    -- Syariah
    (SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM') THEN "avg" ELSE NULL END) / POWER(10,6))        
        AS "kredit_total_syariah",
    (SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
                    AND "kategori_segment" = 'KMG' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_syariah_kmg",
    (SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
                    AND "kategori_segment" = 'KPR' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_syariah_kpr",
    (SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
                    AND "tipe_segment" = 'Mikro' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_syariah_mikro",
    (SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
        AND "tipe_segment" = 'UKM' THEN "avg" ELSE NULL END) / POWER(10,6))  AS "kredit_syariah_ukm"

FROM BJKT_PNL_LOAN_AVG_SY
WHERE
    (
            "kategori_segment" IN ('KMG', 'KPR') 
        OR "tipe_segment"      IN ('Mikro', 'UKM')
    ) AND "cabang" = '108'
GROUP BY
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kode_konsol",
    "nama_konsol";

/
SELECT * FROM BJKT_PNL_AVG_BAL_CREDIT_MV WHERE "kode_cabang" = '108';

select * from BJKT_PNL_LOAN_AVG_SY where "cabang" = '108' and "periode" = '2026-01-31';
select * from BJKT_PNL_DIRECT_OPEX_SY where "kode_cabang_akhir" = '108' and "periode" = '2026-01-31';
select * from BJKT_BRANCHES_MV where 'kode_konsol' = '726';


SELECT
    TO_DATE("tanggal_data", 'YYYY-MM-DD')   AS "periode",
    "kode_cabang"                           AS "kode_cabang",
    "kode_konsol",
    SUM("nominal_ckpn")         AS "ckpn_nominal"
FROM "pnl"."pnl_ckpn"@DWH
WHERE "tipe_segment" <> 'Commercial'
        AND "kode_cabang" = '108'
GROUP BY "tanggal_data", "kode_konsol", "kode_cabang";
