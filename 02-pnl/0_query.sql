-- list access table
select *
from "information_schema"."tables"@DWH
where "table_schema" = 'dwh'
    -- and "table_name" = 'pnl_assumptions'
;
/
select *
  from "information_schema"."columns"@DWH
 where 1 = 1
   and "table_name" = 'dim_branch_v2';
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
  from "dwh"."pnl_beban_bunga"@DWH;
/
-- DB Link PnL
SELECT * FROM "dwh"."pnl_dpk_avg"@DWH;
SELECT * FROM "dwh"."pnl_loan_avg"@DWH;
SELECT * FROM "dwh"."pnl_gl_v2"@DWH WHERE "kode_cabang_akhir" = '108'; -- Tidak ada kode konsol
SELECT count(*) FROM "dwh"."dim_branch_v2"@DWH; 
SELECT * FROM "dwh"."pnl_ckpn"@DWH WHERE "kode_cabang" = '108'; -- Tidak ada kode konsol
SELECT * FROM "dwh"."pnl_pendapatan_bunga"@DWH;
SELECT * FROM "dwh"."pnl_beban_bunga"@DWH WHERE "cabang" = '108'; -- Tidak ada kode konsol
SELECT * FROM "dwh"."pnl_income_dpk"@DWH;
SELECT * FROM "dwh"."pnl_charge_loan"@DWH;
SELECT * FROM "dwh"."pnl_fbi"@DWH; -- Tidak ada kode konsol
SELECT * FROM "dwh"."pnl_fbi"@DWH WHERE "kode_cabang_akhir" = '108'; -- Tidak ada kode konsol
SELECT * FROM "dwh"."pnl_fbi"@DWH WHERE "nama" = '108'; -- Tidak ada kode konsol
SELECT * FROM "dwh"."pnl_opex_v2"@DWH WHERE "kode_cabang_akhir" = '108'; -- Tidak ada kode konsol
SELECT * FROM "dwh"."pnl_direct_porsi"@DWH;
SELECT * FROM "public"."pnl_direct_cabang"@DWH;

-- query ke DBLink
SELECT * FROM "dwh"."pnl_echannel"@DWH;
SELECT * FROM "dwh"."pnl_loan_avg"@DWH;
SELECT * FROM "dwh"."pnl_dpk_avg"@DWH;
SELECT * FROM "dwh"."pnl_pendapatan_bunga"@DWH;
SELECT * FROM "dwh"."pnl_beban_bunga"@DWH;
SELECT * FROM "dwh"."pnl_income_dpk"@DWH;
SELECT * FROM "dwh"."pnl_charge_loan"@DWH;
SELECT * FROM "dwh"."pnl_fbi"@DWH where "kode_cabang_akhir" = '108';
SELECT * FROM "dwh"."dim_branch_v2"@DWH;
SELECT * FROM "dwh"."pnl_gl_v2"@DWH;
SELECT * FROM "dwh"."pnl_ckpn"@DWH;
SELECT * FROM "dwh"."pnl_opex_v2"@DWH;
SELECT * FROM "dwh"."pnl_direct_porsi"@DWH;
SELECT * FROM "public"."pnl_direct_cabang"@DWH;
/
SELECT "periode", "kode_cabang_akhir", "ket_final", "nominal" FROM "dwh"."pnl_gl_v2"@DWH
WHERE "kode_cabang_akhir" = '108' AND "ket_final" = 'Transaksi Non Kredit';

SELECT * FROM BJKT_PNL_LOAN_AVG_SY;
SELECT * FROM BJKT_PNL_PENDAPATAN_BUNGA_SY;
SELECT * FROM BJKT_PNL_DPK_AVG_SY;
SELECT * FROM BJKT_PNL_GL_V2_SY;
SELECT * FROM BJKT_PNL_FBI_SY WHERE "periode" <> '2026-03-31';
SELECT * FROM BJKT_PNL_CKPN_SY WHERE "periode" <> '2026-03-31';
SELECT * FROM BJKT_PNL_CKPN_SY;
/

SELECT * FROM BJKT_BRANCHES_MV;
SELECT * FROM BJKT_PNL_AVG_BAL_CREDIT_MV;
SELECT * FROM BJKT_PNL_AVG_BAL_DPK_MV;
SELECT * FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV WHERE "kode_cabang" = '108';
SELECT * FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV;
SELECT * FROM BJKT_PNL_FTP_INCOME_MV;
SELECT * FROM BJKT_PNL_FEE_BASED_INCOME_MV WHERE "kode_cabang" = '108';
SELECT * FROM BJKT_PNL_NII_POST_FTP_MV;
SELECT * FROM BJKT_PNL_DIRECT_OPEX_MV WHERE "kode_cabang" = '108';
SELECT * FROM BJKT_PNL_BEBAN_CKPN_MV WHERE "kode_cabang" = '108';
/

-- Contoh query summary pnl
SELECT * FROM BJKT_PNL_SUMMARY_V 
WHERE "periode" BETWEEN TO_DATE('2026-03-29', 'YYYY-MM-DD')
                           AND TO_DATE('2026-03-31', 'YYYY-MM-DD')
      AND "kode_konsol" = '108'
      AND "kode_cabang" = '108'
;
SELECT * FROM BJKT_PNL_SUMMARY_VER2_V 
WHERE 
        -- "kode_konsol" = '108'
        "kode_cabang" = '108'
    AND "periode" >= TO_DATE('2025-02-02', 'YYYY-MM-DD')
    AND "periode" <  TO_DATE('2025-08-08', 'YYYY-MM-DD')
;
SELECT * FROM BJKT_PNL_SUMMARY_VER3_V 
WHERE
        "kode_konsol" = '108'
    AND "kode_cabang" = '108'
    AND "periode" >= TO_DATE('2025-02-02', 'YYYY-MM-DD')
    AND "periode" <  TO_DATE('2025-08-08', 'YYYY-MM-DD')
;
-- Contoh query score card
SELECT * FROM BJKT_PNL_SCORE_CARD_V 
WHERE 
        --   "periode" BETWEEN TO_DATE('2026-03-29', 'YYYY-MM-DD')
        --                 AND TO_DATE('2026-03-31', 'YYYY-MM-DD')
          TRUNC("periode", 'MM') >= TO_DATE('2024-01-01', 'YYYY-MM-DD')
      AND TRUNC("periode", 'MM') <= LAST_DAY(TO_DATE('2024-12-01', 'YYYY-MM-DD'))
      AND "kode_konsol" = '108'
      AND "kode_cabang" = '108'
;
-- Contoh query score card query sub menu
SELECT * FROM BJKT_PNL_SCORE_CARD_SUB_V
WHERE "periode" BETWEEN TO_DATE('2026-03-29', 'YYYY-MM-DD')
                    AND TO_DATE('2026-03-31', 'YYYY-MM-DD')
      AND "kode_konsol" = '108'
      AND "kode_cabang" = '108'
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
FROM "dwh"."pnl_pendapatan_bunga"@DWH
WHERE "cabang" = '108'
GROUP BY "cabang", "padanan";


-- Interest Income (Post FTP)
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

-- PPOP (Dir OPEX)
-- Summary(B60,B38,B37)
SELECT 
    dpx."total_dir_opex",
    fbi."fbi_total",
    nii."nii_post_ftp",
    (
        NVL(dpx."total_dir_opex", 0) +
        NVL(fbi."fbi_total", 0) +
        NVL(nii."nii_post_ftp", 0)
    ) AS "ppop_total"
FROM BJKT_PNL_DIRECT_OPEX_MV dpx
LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV fbi
    ON  dpx."kode_cabang" = fbi."kode_cabang"
    AND dpx."periode" = fbi."periode"
LEFT JOIN BJKT_PNL_NII_POST_FTP_MV nii
    ON  dpx."kode_cabang" = nii."kode_cabang"
    AND dpx."periode" = nii."periode"
WHERE
    dpx."kode_cabang" = '108'
    AND dpx."periode" BETWEEN TO_DATE('2026-03-29', 'YYYY-MM-DD')
                          AND TO_DATE('2026-03-31', 'YYYY-MM-DD')
;
/

-- PBT (Dir OPEX + Retail CKPN)
-- B71 + B70
WITH q_ppop AS (
    SELECT
        dpx."periode" AS "periode",
        dpx."kode_cabang",
        dpx."total_dir_opex",
        fbi."fbi_total",
        nii."nii_post_ftp",
        (
            NVL(dpx."total_dir_opex", 0) +
            NVL(fbi."fbi_total", 0) +
            NVL(nii."nii_post_ftp", 0)
        ) AS "ppop_nominal"
    FROM BJKT_PNL_DIRECT_OPEX_MV dpx
    LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV fbi
        ON dpx."kode_cabang" = fbi."kode_cabang"
       AND dpx."periode" = fbi."periode"
    LEFT JOIN BJKT_PNL_NII_POST_FTP_MV nii
        ON dpx."kode_cabang" = nii."kode_cabang"
       AND dpx."periode" = nii."periode"
    WHERE
            dpx."kode_cabang" = '108'
        -- AND dpx."periode" BETWEEN TO_DATE('2026-03-29', 'YYYY-MM-DD')
        --                       AND TO_DATE('2026-03-31', 'YYYY-MM-DD')
    
)
SELECT
    ckpn."periode" AS "periode",
    ckpn."kode_cabang",
    ckpn."ckpn_nominal",
    qp."ppop_nominal",
    (
        NVL(ABS(ckpn."ckpn_nominal"), 0) +
        NVL(ABS(qp."ppop_nominal"), 0)
    ) AS "pbt_nominal"
FROM BJKT_PNL_BEBAN_CKPN_MV ckpn
LEFT JOIN q_ppop qp
    ON qp."kode_cabang" = ckpn."kode_cabang"
--    AND qp."periode" = ckpn."periode"
WHERE ckpn."kode_cabang" = '108'
--   AND ckpn."periode" BETWEEN TO_DATE('2026-03-29', 'YYYY-MM-DD')
--                          AND TO_DATE('2026-03-31', 'YYYY-MM-DD')
;
/

-- Minumum NII
-- -SUM(B38,B60,B71)
-- =-SUM(C57,C79,C100)
SELECT
    fbi."periode",
    fbi."kode_cabang",

    fbi."fbi_total",
    dpx."total_dir_opex",
    ckpn."ckpn_nominal",

    (
        NVL((dpx."total_dir_opex"), 0) +
        NVL((ckpn."ckpn_nominal"), 0) +
        NVL((fbi."fbi_total"), 0)
    ) AS "min_nii_nominal"
FROM BJKT_PNL_FEE_BASED_INCOME_MV fbi
LEFT JOIN BJKT_PNL_DIRECT_OPEX_MV dpx
    ON  fbi."kode_cabang" = dpx."kode_cabang"
LEFT JOIN BJKT_PNL_BEBAN_CKPN_MV ckpn
    ON ckpn."kode_cabang" = fbi."kode_cabang"
WHERE 
    fbi."kode_cabang" = '108'
;
/


-- Total PPOP
-- sum(B37,B38,B60)
SELECT 
    npf."periode",
    npf."kode_cabang",

    npf."nii_post_ftp",
    fbi."fbi_total",
    dpx."total_dir_opex",

    (
        NVL(npf."nii_post_ftp" , 0) +
        NVL(fbi."fbi_total" , 0) +
        NVL(dpx."total_dir_opex" , 0)
    ) AS "total_ppop"
FROM BJKT_PNL_NII_POST_FTP_MV npf
LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV fbi
    ON  fbi."kode_cabang" = npf."kode_cabang"
LEFT JOIN BJKT_PNL_DIRECT_OPEX_MV dpx
    ON  dpx."kode_cabang" = npf."kode_cabang"
WHERE 
    npf."kode_cabang" = '108'
;
/

-- Minimum Portofolio 1
-- IFERROR((1-F7)*ABS(F11)/(F7*((C25+C55)/C15) + (1-F7)*((C45+C54)/C37)),0)
-- (1-KREDIT_OF_PORTOFOLIO)*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/DPK_KONVEN) + (1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_KONVEN))
-- (1-KREDIT_OF_PORTOFOLIO)*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/DPK_KONVEN) + (1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_SYARIAH))

-- IFERROR(E6*ABS(E10)/(E6*((B29+B36)/B10) + (1-E6)*((B32+B35)/B21)),0)
-- (KREDIT_OF_PORTOFOLIO*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_KONVEN) + (1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_KONVEN)), 0)
WITH
q_minimum_nii AS (
    SELECT
        fbi."periode",
        fbi."kode_cabang",

        fbi."fbi_total",
        dpx."total_dir_opex",
        ckpn."ckpn_nominal",

        (
            NVL((dpx."total_dir_opex"), 0) +
            NVL((ckpn."ckpn_nominal"), 0) +
            NVL((fbi."fbi_total"), 0)
        ) AS "min_nii_nominal"
    FROM BJKT_PNL_FEE_BASED_INCOME_MV fbi
    LEFT JOIN BJKT_PNL_DIRECT_OPEX_MV dpx
        ON  fbi."kode_cabang" = dpx."kode_cabang"
    LEFT JOIN BJKT_PNL_BEBAN_CKPN_MV ckpn
        ON ckpn."kode_cabang" = fbi."kode_cabang"
    WHERE 
        fbi."kode_cabang" = '108'
)
SELECT
    scs."kredit_portofolio_val",
    mii."min_nii_nominal",
    pbt."total_pen_bunga",
    cre."kredit_total_konven",
    bbt."total_beban_bunga",
    fi."ftp_income_dpk",
    dpk."dpk_total_konven",

    NVL(
        scs."kredit_portofolio_val" * ABS(mii."min_nii_nominal")
        /
        (
            scs."kredit_portofolio_val"
            *
            (
                (pbt."total_pen_bunga" + fi."ftp_charge_loan")
                / cre."kredit_total_konven"
            )
            +
            (
                1 - scs."kredit_portofolio_val"
            )
            *
            (
                (bbt."total_beban_bunga" + fi."ftp_income_dpk")
                / dpk."dpk_total_konven"
            )
        ),
        0
    ) AS "minimum_portofolio_1"

FROM BJKT_PNL_SCORE_CARD_SUB_V scs
LEFT JOIN q_minimum_nii mii
    ON  mii."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_PEN_BUNGA_TOTAL_MV pbt
    ON  pbt."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_FTP_CHARGE_MV fc
    ON  fc."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_AVG_BAL_CREDIT_MV cre
    ON  cre."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_BEBAN_BUNGA_TOTAL_MV bbt
    ON  bbt."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_FTP_INCOME_MV fi
    ON  fi."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
    ON  dpk."kode_cabang" = scs."kode_cabang"
WHERE
    scs."kode_cabang" = '108'
;
/

CREATE OR REPLACE VIEW BJKT_TEST_V AS
WITH
q_minimum_nii AS (
    SELECT
        fbi."periode",
        fbi."kode_cabang",
        fbi."fbi_total",
        dpx."total_dir_opex",
        ckpn."ckpn_nominal",
        (
            NVL(dpx."total_dir_opex", 0) +
            NVL(ckpn."ckpn_nominal",  0) +
            NVL(fbi."fbi_total",      0)
        ) AS "min_nii_nominal"
    FROM BJKT_PNL_FEE_BASED_INCOME_MV fbi
    LEFT JOIN BJKT_PNL_DIRECT_OPEX_MV dpx
        ON fbi."kode_cabang" = dpx."kode_cabang"
    LEFT JOIN BJKT_PNL_BEBAN_CKPN_MV ckpn
        ON ckpn."kode_cabang" = fbi."kode_cabang"
    WHERE fbi."kode_cabang" = '108'
)
SELECT
    scs."kredit_portofolio_val",
    mii."min_nii_nominal",
    pbt."total_pen_bunga",
    cre."kredit_total_konven",
    bbt."total_beban_bunga",
    fi."ftp_income_dpk",
    dpk."dpk_total_konven",
    NVL(
        scs."kredit_portofolio_val" * ABS(mii."min_nii_nominal")
        /
        (
            scs."kredit_portofolio_val"
            *
            (
                (pbt."total_pen_bunga" + fc."ftp_charge_loan")
                / NULLIF(cre."kredit_total_konven", 0)
            )
            +
            (1 - scs."kredit_portofolio_val")
            *
            (
                (bbt."total_beban_bunga" + fi."ftp_income_dpk")
                / NULLIF(dpk."dpk_total_konven", 0)
            )
        ),
        0
    ) AS "minimum_portofolio_1"
FROM BJKT_PNL_SCORE_CARD_SUB_V scs
LEFT JOIN q_minimum_nii                mii ON mii."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_PEN_BUNGA_TOTAL_MV  pbt ON pbt."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_FTP_CHARGE_MV        fc ON  fc."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_AVG_BAL_CREDIT_MV   cre ON cre."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_BEBAN_BUNGA_TOTAL_MV bbt ON bbt."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_FTP_INCOME_MV         fi ON  fi."kode_cabang" = scs."kode_cabang"
LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV       dpk ON dpk."kode_cabang" = scs."kode_cabang"
WHERE scs."kode_cabang" = '108';
/

SELECT
    "kode_cabang",
    SUM("ckpn_nominal") AS "ckpn_nominal"
FROM BJKT_PNL_BEBAN_CKPN_MV
WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
    AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
    AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
GROUP BY "kode_cabang";