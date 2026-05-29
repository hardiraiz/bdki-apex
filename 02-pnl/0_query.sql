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
SELECT * FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV;
SELECT * FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV;
SELECT * FROM BJKT_PNL_FTP_INCOME_MV;
SELECT * FROM BJKT_PNL_FEE_BASED_INCOME_MV WHERE "kode_cabang" = '108'; -- Belum dibuat
SELECT * FROM BJKT_PNL_NII_POST_FTP_MV;
SELECT * FROM BJKT_PNL_DIRECT_OPEX_MV;
SELECT * FROM BJKT_PNL_BEBAN_CKPN_MV;


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