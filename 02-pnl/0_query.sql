-- list access table
select *
from "information_schema"."tables"@dwh_dev
where "table_schema" = 'dwh'
    -- and "table_name" = 'pnl_assumptions'
;
/
select *
  from "information_schema"."columns"@dwh_dev
 where 1 = 1
   and "table_name" = 'pnl_fbi';
/
select "periode",
       "kode_konsol",
       "nama_konsol",
       "cabang",
       "nama_kantor_akhir",
       "kategori",
       "segmentasi",
       "cabang_padanan",
       "avg",
       "beban_bunga"
  from "dwh"."pnl_beban_bunga"@dwh_dev;
/
-- query ke DBLink
SELECT * FROM "dwh"."pnl_echannel"@DWH_DEV;
SELECT * FROM "dwh"."pnl_loan_avg"@DWH_DEV;
SELECT * FROM "dwh"."pnl_dpk_avg"@DWH_DEV;
SELECT * FROM "dwh"."pnl_pendapatan_bunga"@DWH_DEV;
SELECT * FROM "dwh"."pnl_beban_bunga"@DWH_DEV;
SELECT * FROM "dwh"."pnl_income_dpk"@DWH_DEV;
SELECT * FROM "dwh"."pnl_charge_loan"@DWH_DEV;
SELECT distinct "nama" FROM "dwh"."pnl_fbi"@DWH_DEV where "kode_cabang_akhir" = '108';
SELECT * FROM "dwh"."dim_branch_v2"@DWH_DEV;
SELECT * FROM "dwh"."pnl_gl_v2"@DWH_DEV;
SELECT * FROM "dwh"."pnl_ckpn"@DWH_DEV;
/
SELECT "periode", "kode_cabang_akhir", "ket_final", "nominal" FROM "dwh"."pnl_gl_v2"@DWH_DEV
WHERE "kode_cabang_akhir" = '108' AND "ket_final" = 'Transaksi Non Kredit';

SELECT * FROM BJKT_PNL_LOAN_AVG_SY;
SELECT * FROM BJKT_PNL_PENDAPATAN_BUNGA_SY;
SELECT * FROM BJKT_PNL_DPK_AVG_SY;
SELECT * FROM BJKT_PNL_GL_V2_SY;
SELECT * FROM BJKT_PNL_FBI_SY WHERE "periode" <> '2026-03-31';
/

SELECT * FROM BJKT_BRANCHES_MV;
SELECT * FROM BJKT_PNL_AVG_BAL_CREDIT_MV;
SELECT * FROM BJKT_PNL_AVG_BAL_DPK_MV;
SELECT * FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV WHERE "kode_cabang" = '108';
SELECT * FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV;
SELECT * FROM BJKT_PNL_FTP_INCOME_MV;
SELECT * FROM BJKT_PNL_FEE_BASED_INCOME_MV; -- Belum dibuat
SELECT * FROM BJKT_PNL_NII_POST_FTP_MV;
SELECT * FROM BJKT_PNL_DIRECT_OPEX_MV WHERE "kode_cabang" = '108';
SELECT * FROM BJKT_PNL_BEBAN_CKPN_MV;
/

-- Contoh query summary pnl
SELECT * FROM BJKT_PNL_SUMMARY_V 
WHERE "periode" BETWEEN TO_DATE('2026-03-29', 'YYYY-MM-DD')
                           AND TO_DATE('2026-03-31', 'YYYY-MM-DD')
      AND "kode_konsol" = '108'
    --   AND "kode_cabang" = '108'
;
-- Contoh query score card
SELECT * FROM BJKT_PNL_SCORE_CARD_V 
WHERE "periode" BETWEEN TO_DATE('2026-03-29', 'YYYY-MM-DD')
                           AND TO_DATE('2026-03-31', 'YYYY-MM-DD')
      AND "kode_konsol" = '108'
      AND "kode_cabang" = '108'
;
/

select distinct "ket_final" from BJKT_PNL_GL_V2_SY where "kode_cabang_akhir" = 108;
select * from BJKT_PNL_GL_V2_SY where "kode_cabang_akhir" = 108 and "ket_final" = 'Transaksi Non Kredit';
/

-- LOV List KC
select distinct "nama_konsol" d, "kode_konsol" r 
from BJKT_BRANCHES_MV 
where "keterangan" = 'BUKA'
order by "nama_konsol";
/

-- LOV List Cabang KC
select "nama_kantor_akhir" d, "kode_cabang_akhir" r
from BJKT_BRANCHES_MV 
where 
        "keterangan" = 'BUKA'        
    and (:P1000_KC is null or "kode_konsol" = :P1000_KC)
order by "nama_kantor_akhir";
/

-- Query MV Avg. Balance Credit
SELECT COUNT(*) FROM BJKT_PNL_AVG_BAL_CREDIT_MV
WHERE
        PERIODE     = '2026-03-31'
    AND KODE_CABANG = '108';
/

-- sample query display score card
SELECT
    'Avg. Balance Kredit Detail' AS column_name,
    730000 AS nominal,
    1 AS group_number,
    'Y' AS is_header
FROM DUAL
UNION ALL
SELECT
    'Kredit Konven' AS column_name,
    664300 AS nominal,
    1 AS group_number,
    'N' AS is_header
FROM DUAL
UNION ALL
SELECT
    'KMG' AS column_name,
    544000 AS nominal,
    1 AS group_number,
    'N' AS is_header
FROM DUAL
UNION ALL
SELECT
    'Average Balance DPK' AS column_name,
    744000 AS nominal,
    2 AS group_number,
    'Y' AS is_header
FROM DUAL
UNION ALL
SELECT
    'DPK Konven' AS column_name,
    144000 AS nominal,
    2 AS group_number,
    'N' AS is_header
FROM DUAL
ORDER BY group_number ASC, is_header DESC
;
/

-- Syariah KMG
SELECT
    *
FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
WHERE
        "cabang" = '108'
    AND "padanan" IN ('DBLM', 'Syariah')
    AND "kategori_segment" = 'KMG';

SELECT
    *
FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
WHERE
        "cabang" = '108'
    AND "padanan" IN ('DBLM', 'Syariah')
    AND "kategori_segment" = 'KPR';

SELECT
    *
FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
WHERE
        "cabang" = '108'
    AND "padanan" IN ('DBLM', 'Syariah')
    AND "kategori_segment" = 'KPR';

SELECT 
    "cabang",
    "padanan",
    SUM("pendapatan_bunga") "pendapatan_bunga"
FROM "dwh"."pnl_pendapatan_bunga"@DWH_DEV
WHERE "cabang" = '108'
GROUP BY "cabang", "padanan";


-- Intereset Income (Post FTP)
SELECT
    ((pbt."total_pen_bunga" + fc."ftp_charge_loan") / cre."total_kredit") AS post_ftp
FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV pbt
LEFT JOIN BJKT_PNL_FTP_CHARGE_MV fc
    ON fc."kode_cabang" = pbt."kode_cabang"
LEFT JOIN BJKT_PNL_AVG_BAL_CREDIT_MV cre
    ON cre."kode_cabang" = pbt."kode_cabang"
WHERE
    pbt."kode_cabang" = '108'
;
/

-- Cost of Fund (Post FTP)
SELECT
    ((bbt."total_beban_bunga" + fi."ftp_income_dpk") / dpk."total_dpk") AS "cost_of_fund"
FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV bbt
LEFT JOIN BJKT_PNL_FTP_INCOME_MV fi
    ON bbt."kode_cabang" = fi."kode_cabang"
LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
    ON bbt."kode_cabang" = dpk."kode_cabang"
WHERE
    bbt."kode_cabang" = '108'
;
/

-- Kredit of Portofolio
SELECT
    (cre."total_kredit" / (cre."total_kredit" + dpk."total_dpk")) AS "kredit_portofolio"
FROM BJKT_PNL_AVG_BAL_CREDIT_MV cre
LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
    ON cre."kode_cabang" = dpk."kode_cabang"
WHERE
    cre."kode_cabang" = '108'
;
/

-- Minimum Portofolio 1
-- Kredit_of_portofolio


-- Total Income
-- Fee Based Income + NII Post FTP
SELECT
    fbi."fbi_total",
    nii."nii_post_ftp",
    (fbi."fbi_total" + nii."nii_post_ftp") "total_income"
FROM BJKT_PNL_FEE_BASED_INCOME_MV fbi
LEFT JOIN BJKT_PNL_NII_POST_FTP_MV nii
    ON fbi."kode_cabang" = nii."kode_cabang"
WHERE
    fbi."kode_cabang" = '108'
;
/