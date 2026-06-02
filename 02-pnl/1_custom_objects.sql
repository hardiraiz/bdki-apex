CREATE OR REPLACE SYNONYM BJKT_PNL_ECHANNEL_SY
FOR "dwh"."pnl_echannel"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_DPK_AVG_SY
FOR "dwh"."pnl_dpk_avg"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_LOAN_AVG_SY
FOR "dwh"."pnl_loan_avg"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_GL_SY
FOR "dwh"."pnl_gl"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_GL_V2_SY
FOR "dwh"."pnl_gl_v2"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_DIM_BRANCH_V2_SY
FOR "dwh"."dim_branch_v2"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_CKPN_SY
FOR "dwh"."pnl_ckpn"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_PENDAPATAN_BUNGA_SY
FOR "dwh"."pnl_pendapatan_bunga"@DWH_DEV
/

CREATE OR REPLACE SYNONYM BJKT_PNL_BEBAN_BUNGA_SY
FOR "dwh"."pnl_beban_bunga"@DWH_DEV
/

CREATE OR REPLACE SYNONYM BJKT_PNL_INCOME_DPK_SY
FOR "dwh"."pnl_income_dpk"@DWH_DEV
/

CREATE OR REPLACE SYNONYM BJKT_PNL_CHARGE_LOAN_SY
FOR "dwh"."pnl_charge_loan"@DWH_DEV
/

CREATE OR REPLACE SYNONYM BJKT_PNL_FBI_SY
FOR "dwh"."pnl_fbi"@DWH_DEV
/

-- DROP MATERIALIZED VIEW BJKT_BRANCHES_MV;
-- /
-- Materialized View list data cabang dan cabang konsolidasi
CREATE MATERIALIZED VIEW BJKT_BRANCHES_MV
BUILD IMMEDIATE
REFRESH COMPLETE
START WITH TRUNC(SYSDATE + 1) + 2/24
NEXT TRUNC(SYSDATE + 1) + 2/24
AS
SELECT
    "kode_cabang_awal",
    "nama_kantor_awal",
    "kode_cabang_akhir",
    "nama_kantor_akhir",
    "kode_konsol",
    "nama_konsol",
    "kode_cabang_dblm_v2"   "kode_cabang_syariah",
    "nama_cabang_dblm_v2"   "nama_cabang_syariah",
    "status_branch",
    "segmen_branch",
    "keterangan"
FROM DIM_BRANCH_V2_SY;
/
CREATE INDEX BJKT_BRANCHES_MV_I1 ON BJKT_BRANCHES_MV("kode_cabang_awal", "keterangan");
/
CREATE INDEX BJKT_BRANCHES_MV_I2 ON BJKT_BRANCHES_MV("kode_cabang_akhir", "keterangan");
/
CREATE INDEX BJKT_BRANCHES_MV_I3 ON BJKT_BRANCHES_MV("kode_konsol", "keterangan");
/
CREATE INDEX BJKT_BRANCHES_MV_I4 ON BJKT_BRANCHES_MV("kode_cabang_syariah", "keterangan");
/

-- DROP MATERIALIZED VIEW BJKT_PNL_AVG_BAL_CREDIT_MV;
-- Materialized view list data Avg. Balance Credit
CREATE MATERIALIZED VIEW BJKT_PNL_AVG_BAL_CREDIT_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "cabang"                            AS "kode_cabang",
    "nama_kantor_akhir"                 AS "nama_cabang",
    "kode_konsol"                       AS "kode_konsol",
    "nama_konsol"                       AS "nama_konsol",

    ROUND(SUM("avg") / POWER(10,6))                                                            
        AS "total_kredit",

    -- Konven
    ROUND(SUM(CASE WHEN "padanan" = 'Konven' THEN "avg" ELSE NULL END) / POWER(10,6))         
        AS "kredit_total_konven",
    ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                    AND "kategori_segment" = 'KMG' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_kmg",
    ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                    AND "kategori_segment" = 'KPR' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_kpr",
    ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                    AND "tipe_segment" = 'Mikro' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_mikro",
    ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                    AND "tipe_segment" = 'UKM' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_ukm",

    -- Syariah
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM') THEN "avg" ELSE NULL END) / POWER(10,6))        
        AS "kredit_total_syariah",
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                    AND "kategori_segment" = 'KMG' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_syariah_kmg",
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                    AND "kategori_segment" = 'KPR' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_syariah_kpr",
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                    AND "tipe_segment" = 'Mikro' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_syariah_mikro",
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
        AND "tipe_segment" = 'UKM' THEN "avg" ELSE NULL END) / POWER(10,6))  AS "kredit_syariah_ukm"

FROM BJKT_PNL_LOAN_AVG_SY
WHERE
        "kategori_segment" IN ('KMG', 'KPR') 
    OR "tipe_segment"      IN ('Mikro', 'UKM')
GROUP BY
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kode_konsol",
    "nama_konsol";
/
CREATE INDEX BJKT_PNL_AVG_BAL_CREDIT_MV_I1 ON BJKT_PNL_AVG_BAL_CREDIT_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_AVG_BAL_CREDIT_MV_I2 ON BJKT_PNL_AVG_BAL_CREDIT_MV("periode", "kode_cabang");
/

-- DROP MATERIALIZED VIEW BJKT_PNL_AVG_BAL_DPK_MV;
-- Materialized View Avg. Balance DPK
CREATE MATERIALIZED VIEW BJKT_PNL_AVG_BAL_DPK_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "cabang"                            AS "kode_cabang",
    "nama_kantor_akhir"                 AS "nama_cabang",
    "kode_konsol"                       AS "kode_konsol",
    "nama_konsol"                       AS "nama_konsol",

    ROUND(SUM("avg") / POWER(10,6))                                                           
        AS "total_dpk",

    -- DPK Konven
    ROUND(SUM(CASE WHEN "produk" = 'Konven' THEN "avg" ELSE NULL END) / POWER(10,6))         
        AS "dpk_total_konven",
    ROUND(SUM(CASE WHEN "produk" = 'Konven'
                    AND "kategori" = 'Giro' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_konven_giro",
    ROUND(SUM(CASE WHEN "produk" = 'Konven'
                    AND "kategori" = 'Tabungan' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_konven_tabungan",
    ROUND(SUM(CASE WHEN "produk" = 'Konven'
                    AND "kategori" = 'Deposito' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_konven_deposito",

    -- DPK Syariah
    ROUND(SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM') THEN "avg" ELSE NULL END) / POWER(10,6))        
        AS "dpk_total_syariah",
    ROUND(SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
                    AND "kategori" = 'Giro' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_syariah_giro",
    ROUND(SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
                    AND "kategori" = 'Tabungan' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_syariah_tabungan",
    ROUND(SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
                    AND "kategori" = 'Deposito' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_syariah_deposito"

FROM BJKT_PNL_DPK_AVG_SY
WHERE
    "kategori" IN ('Giro', 'Tabungan', 'Deposito')
GROUP BY
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kode_konsol",
    "nama_konsol";
/
CREATE INDEX BJKT_PNL_AVG_BAL_DPK_MV_I1 ON BJKT_PNL_AVG_BAL_DPK_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_AVG_BAL_DPK_MV_I2 ON BJKT_PNL_AVG_BAL_DPK_MV("periode", "kode_cabang");
/

-- DROP MATERIALIZED VIEW BJKT_PNL_PEN,_BUNGA_TOTAL_MV;
-- Materialized view list data Pend. Bunga total
CREATE MATERIALIZED VIEW BJKT_PNL_PEN_BUNGA_TOTAL_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "cabang"                            AS "kode_cabang",
    "nama_kantor_akhir"                 AS "nama_cabang",
    "kode_konsol"                       AS "kode_konsol",
    "nama_konsol"                       AS "nama_konsol",

    ROUND(SUM("pendapatan_bunga") / POWER(10,6))                                                                                      
        AS "total_pen_bunga",
    ROUND(SUM(CASE WHEN "padanan" = 'Konven'                                              THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "total_bunga_konven",
    ROUND(SUM(CASE WHEN "padanan" = 'Konven' AND "kategori_segment" = 'KMG'               THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_kmg",
    ROUND(SUM(CASE WHEN "padanan" = 'Konven' AND "kategori_segment" = 'KPR'               THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_kpr",
    ROUND(SUM(CASE WHEN "padanan" = 'Konven' AND "tipe_segment"     = 'Mikro'             THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_mikro",
    ROUND(SUM(CASE WHEN "padanan" = 'Konven' AND "tipe_segment"     = 'UKM'               THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_ukm",
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah','DBLM')                                   THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "total_bunga_syariah",
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah','DBLM') AND "kategori_segment" = 'KMG'    THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_kmg",
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah','DBLM') AND "kategori_segment" = 'KPR'    THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_kpr",
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah','DBLM') AND "tipe_segment"     = 'Mikro'  THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_mikro",
    ROUND(SUM(CASE WHEN "padanan" IN ('Syariah','DBLM') AND "tipe_segment"     = 'UKM'    THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_ukm"
FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
WHERE
        "kategori_segment" IN ('KMG','KPR')
    OR  "tipe_segment"     IN ('Mikro','UKM')
GROUP BY "periode", "cabang", "nama_kantor_akhir", "kode_konsol", "nama_konsol";
/
CREATE INDEX BJKT_PNL_PEN_BUNGA_TOTAL_MV_I1 ON BJKT_PNL_PEN_BUNGA_TOTAL_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_PEN_BUNGA_TOTAL_MV_I2 ON BJKT_PNL_PEN_BUNGA_TOTAL_MV("periode", "kode_cabang");
/

-- DROP MATERIALIZED VIEW BJKT_PNL_BEBAN_BUNGA_TOTAL_MV;
-- Materialized view list data Beban Bunga total
CREATE MATERIALIZED VIEW BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "cabang"                            AS "kode_cabang",
    "nama_kantor_akhir"                 AS "nama_cabang",
    "kode_konsol"                       AS "kode_konsol",
    "nama_konsol"                       AS "nama_konsol",

    ROUND(SUM("beban_bunga") / POWER(10,6))                                                           
        AS "total_beban_bunga",

    -- DPK Konven
    ROUND(SUM(CASE WHEN "produk" = 'k' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))         
        AS "beban_bunga_konven",
    ROUND(SUM(CASE WHEN "produk" = 'k' AND "kategori" = 'Giro' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_konven_giro",
    ROUND(SUM(CASE WHEN "produk" = 'k' AND "kategori" = 'Tabungan' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_konven_tabungan",
    ROUND(SUM(CASE WHEN "produk" = 'k' AND "kategori" = 'Deposito' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_konven_deposito",

    -- DPK Syariah
    ROUND(SUM(CASE WHEN "produk" = 's' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))        
        AS "beban_bunga_total_syariah",
    ROUND(SUM(CASE WHEN "produk" = 's' AND "kategori" = 'Giro' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_syariah_giro",
    ROUND(SUM(CASE WHEN "produk" = 's' AND "kategori" = 'Tabungan' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_syariah_tabungan",
    ROUND(SUM(CASE WHEN "produk" = 's' AND "kategori" = 'Deposito' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_syariah_deposito"
FROM BJKT_PNL_BEBAN_BUNGA_SY
WHERE "kategori" IN ('Giro', 'Tabungan', 'Deposito')
GROUP BY "periode", "cabang", "nama_kantor_akhir", "kode_konsol", "nama_konsol";
/
CREATE INDEX BJKT_PNL_BEBAN_BUNGA_TOTAL_MV_I1 ON BJKT_PNL_BEBAN_BUNGA_TOTAL_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_BEBAN_BUNGA_TOTAL_MV_I2 ON BJKT_PNL_BEBAN_BUNGA_TOTAL_MV("periode", "kode_cabang");
/

-- DROP MATERIALIZED VIEW BJKT_PNL_FTP_INCOME_MV;
-- Materialized view list data FTP Income
CREATE MATERIALIZED VIEW BJKT_PNL_FTP_INCOME_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "cabang"                            AS "kode_cabang",
    "nama_kantor_akhir"                 AS "nama_cabang",
    "kode_konsol"                       AS "kode_konsol",
    "nama_konsol"                       AS "nama_konsol",
    ROUND("ftp_income_dpk" / POWER(10, 6)) AS "ftp_income_dpk"
FROM BJKT_PNL_INCOME_DPK_SY;
/
CREATE INDEX BJKT_PNL_FTP_INCOME_MV_I1 ON BJKT_PNL_FTP_INCOME_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_FTP_INCOME_MV_I2 ON BJKT_PNL_FTP_INCOME_MV("periode", "kode_cabang");
/

-- DROP MATERIALIZED VIEW BJKT_PNL_FTP_CHARGE_MV
-- Materialized view list data FTP Charge
CREATE MATERIALIZED VIEW BJKT_PNL_FTP_CHARGE_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')        AS "periode",
    "kode_cabang_akhir"                     AS "kode_cabang",
    "nama_kantor_akhir"                     AS "nama_cabang",
    "kode_konsol"                           AS "kode_konsol",
    "nama_konsol"                           AS "nama_konsol",
    ROUND("ftp_charge_loan" / POWER(10, 6)) AS "ftp_charge_loan"
FROM BJKT_PNL_CHARGE_LOAN_SY;
/
CREATE INDEX BJKT_PNL_FTP_CHARGE_MV_I1 ON BJKT_PNL_FTP_CHARGE_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_FTP_CHARGE_MV_I2 ON BJKT_PNL_FTP_CHARGE_MV("periode", "kode_cabang");
/

-- SET DEFINE OFF;
-- DROP MATERIALIZED VIEW BJKT_PNL_FEE_BASED_INCOME_MV;
-- Materialized view list data Fee Based Income
CREATE MATERIALIZED VIEW BJKT_PNL_FEE_BASED_INCOME_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT 
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "kode_cabang_akhir"                 AS "kode_cabang",        

    ROUND(SUM("fbi") / POWER(10,6)) 
        AS "fbi_total",
    ROUND(SUM(CASE WHEN "nama" = 'Account Maintenance' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_acc_maint",
    ROUND(SUM(CASE WHEN "nama" = 'ATM FBI' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_atm",
    ROUND(SUM(CASE WHEN "nama" = 'JakOne Mobile FBI' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_jom",
    -- add column edc here
    ROUND(SUM(CASE WHEN "nama" = 'EDC FBI' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_edc",
    ROUND(SUM(CASE WHEN "nama" = 'CMS' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_cms",
    ROUND(SUM(CASE WHEN "nama" = 'ABANK FBI' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_abank",
    ROUND(SUM(CASE WHEN "nomor_rekening" = '432003602100' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_jas_pot",
    SUM(CASE WHEN "nama" = 'Bisnis Kartu' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_bisnis_kartu",
    ROUND(SUM(CASE WHEN "nama" = 'Bisnis SDB' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_bisnis_sdb",
    ROUND(SUM(CASE WHEN "nama" = 'Kiriman Uang (RTGS, kliring, dll.)' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_kirim_uang",
    ROUND(SUM(CASE WHEN "nama" = 'RESTITUSI BIAYA KANTOR' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_rest_biaya_kantor",
    ROUND(SUM(CASE WHEN "nama" = 'Pinalty Nasabah & Penolakan' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_pin_nas_pen",
    -- add column sindikasi here
    -- add column trade finance here
    ROUND(SUM(CASE WHEN "nama" = 'BANK GARANSI' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_bank_garansi",
    ROUND(SUM(CASE WHEN "nama" = 'Admin Kredit' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_admin_kredit",
    ROUND(SUM(CASE WHEN "nama" = 'Kerjasama Pihak Lain (komisi agen, asuransi)' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_ker_pihak_lain",
    -- add column dividen reksa dana here
    -- add column dividen M2M Forex & SB here
    ROUND(SUM(CASE WHEN "nama" = 'Lainnya (komisi notaris, denda tunggakan)' THEN "fbi" ELSE NULL END) / POWER(10,6))
        AS "fbi_lainnya"
    -- add column collection recovery income here
FROM BJKT_PNL_FBI_SY
GROUP BY "periode", "kode_cabang_akhir";
/
CREATE INDEX BJKT_PNL_FEE_BASED_INCOME_MV_I1 ON BJKT_PNL_FEE_BASED_INCOME_MV("periode", "kode_cabang");
/

-- DROP MATERIALIZED VIEW BJKT_PNL_NII_POST_FTP_MV;
-- Materialized view list data NII Post FTP
CREATE MATERIALIZED VIEW BJKT_PNL_NII_POST_FTP_MV
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT *
FROM (
    WITH
    pend_bunga AS (
        SELECT
            "periode",
            "cabang",
            SUM("pendapatan_bunga") / 1000000 AS "total_pen_bunga"
        FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
        WHERE
                "kategori_segment" IN ('KMG', 'KPR')
            OR  "tipe_segment"     IN ('Mikro', 'UKM')
        GROUP BY "periode", "cabang"
    ),
    beban_bunga AS (
        SELECT
            "periode",
            "cabang",
            SUM("beban_bunga") / 1000000 AS "total_beban_bunga"
        FROM BJKT_PNL_BEBAN_BUNGA_SY
        WHERE "kategori" IN ('Giro', 'Tabungan', 'Deposito')
        GROUP BY "periode", "cabang"
    ),
    ftp_charge AS (
        SELECT
            "periode",
            "kode_cabang_akhir"              AS "cabang",
            SUM("ftp_charge_loan") / 1000000 AS "ftp_charge_loan"
        FROM BJKT_PNL_CHARGE_LOAN_SY
        GROUP BY "periode", "kode_cabang_akhir"
    ),
    ftp_income AS (
        SELECT
            "periode",
            "cabang",
            SUM("ftp_income_dpk") / 1000000 AS "ftp_income_dpk"
        FROM BJKT_PNL_INCOME_DPK_SY
        GROUP BY "periode", "cabang"
    )
    SELECT
        TO_DATE(bb."periode", 'YYYY-MM-DD') AS "periode",
        bb."cabang"                         AS "kode_cabang",
        ROUND(
            NVL(bb."total_beban_bunga", 0)
          + NVL(pb."total_pen_bunga",   0)
          + NVL(fc."ftp_charge_loan",   0)
          + NVL(fi."ftp_income_dpk",    0)
        )                                   AS "nii_post_ftp"
    FROM
        beban_bunga bb
    LEFT JOIN pend_bunga pb
        ON  bb."cabang"  = pb."cabang"
        AND bb."periode" = pb."periode"
    LEFT JOIN ftp_charge fc
        ON  bb."cabang"  = fc."cabang"
        AND bb."periode" = fc."periode"
    LEFT JOIN ftp_income fi
        ON  bb."cabang"  = fi."cabang"
        AND bb."periode" = fi."periode"
);
/
CREATE INDEX BJKT_PNL_NII_POST_FTP_MV_I1 ON BJKT_PNL_NII_POST_FTP_MV("periode", "kode_cabang");
/

-- DROP MATERIALIZED VIEW BJKT_PNL_DIRECT_OPEX_MV;
-- Materialized view list data Direct OPEX
CREATE MATERIALIZED VIEW BJKT_PNL_DIRECT_OPEX_MV
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "kode_cabang_akhir"                 AS "kode_cabang",
    (ROUND(SUM(CASE WHEN "ket_final" = 'Manpower' THEN "nominal" ELSE NULL END) / POWER(10,6)))
        AS "dir_opex_manpower",
    (ROUND(SUM(CASE WHEN "ket_final" = 'IT & Telecommunication' THEN "nominal" ELSE NULL END) / POWER(10,6)))
        AS "dir_opex_telecom",
    (ROUND(SUM(CASE WHEN "ket_final" = 'Office Supplies' THEN "nominal" ELSE NULL END) / POWER(10,6)))
        AS "dir_opex_ofc_sup",
    -- Add column sewa atm here
    (ROUND(SUM(CASE WHEN "ket_final" = 'Perjalanan Dinas' THEN "nominal" ELSE NULL END) / POWER(10,6)))
        AS "dir_opex_per_din",
    (ROUND(SUM(CASE WHEN "ket_final" = 'Premium Insurance Non-Credit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
        AS "dir_opex_prem_ins_ncr",
    (ROUND(SUM(CASE WHEN "ket_final" = 'Premi Asuransi Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
        AS "dir_opex_prem_as_cr",
    (ROUND(SUM(CASE WHEN "ket_final" = 'Transaksi Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
        AS "dir_opex_tran_cr",
    (ROUND(SUM(CASE WHEN "ket_final" = 'Transaksi Non Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
        AS "dir_opex_tran_ncr"
FROM BJKT_PNL_GL_V2_SY
GROUP BY "periode", "kode_cabang_akhir";
/
CREATE INDEX BJKT_PNL_DIRECT_OPEX_MV_I1 ON BJKT_PNL_DIRECT_OPEX_MV("periode", "kode_cabang");
/

-- DROP MATERIALIZED VIEW BJKT_PNL_BEBAN_CKPN_MV;
-- Materialized view list data Beban CKPN
CREATE MATERIALIZED VIEW BJKT_PNL_BEBAN_CKPN_MV
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')        AS "periode",
    "kode_cabang"                           AS "kode_cabang",
    (ROUND(SUM("nom_ckpn") / POWER(10,6)))  AS "ckpn_nominal"
FROM BJKT_PNL_CKPN_SY
WHERE
        "tipe_segment" IN ('Konsumer', 'Mikro', 'UKM')
    AND "produk" = 'Konven'
GROUP BY "periode", "kode_cabang";
/
CREATE INDEX BJKT_PNL_BEBAN_CKPN_MV_I1 ON BJKT_PNL_BEBAN_CKPN_MV("periode", "kode_cabang");
/

-- Table View Summary PnL
CREATE OR REPLACE VIEW BJKT_PNL_SUMMARY_V AS
SELECT
    cre."periode" AS "periode",
    cre."kode_cabang",
    cre."nama_cabang",
    cre."kode_konsol",
    cre."nama_konsol",
    
    -- Avg. Balance Credit
    cre."total_kredit",
    cre."kredit_total_konven",
    cre."kredit_konven_kmg",
    cre."kredit_konven_kpr",
    cre."kredit_konven_mikro",
    cre."kredit_konven_ukm",
    cre."kredit_total_syariah",
    cre."kredit_syariah_kmg",
    cre."kredit_syariah_kpr",
    cre."kredit_syariah_mikro",
    cre."kredit_syariah_ukm",

    -- Avg. Balance DPK
    dpk."total_dpk",
    dpk."dpk_total_konven",
    dpk."dpk_konven_giro",
    dpk."dpk_konven_tabungan",
    dpk."dpk_konven_deposito",
    dpk."dpk_total_syariah",
    dpk."dpk_syariah_giro",
    dpk."dpk_syariah_tabungan",
    dpk."dpk_syariah_deposito",

    -- Pend. Bunga
    pbt."total_pen_bunga",
    pbt."total_bunga_konven",
    pbt."bunga_konven_kmg",
    pbt."bunga_konven_kpr",
    pbt."bunga_konven_mikro",
    pbt."bunga_konven_ukm",
    pbt."total_bunga_syariah",
    pbt."bunga_syariah_kmg",
    pbt."bunga_syariah_kpr",
    pbt."bunga_syariah_mikro",
    pbt."bunga_syariah_ukm",

    -- Beban Bunga Total
    bbt."total_beban_bunga",
    bbt."beban_bunga_konven",
    bbt."beban_bunga_konven_giro",
    bbt."beban_bunga_konven_tabungan",
    bbt."beban_bunga_konven_deposito",
    bbt."beban_bunga_total_syariah",
    bbt."beban_bunga_syariah_giro",
    bbt."beban_bunga_syariah_tabungan",
    bbt."beban_bunga_syariah_deposito",

    -- FTP Income
    fi."ftp_income_dpk",

    -- FTP Charge Loan
    fc."ftp_charge_loan",

    -- Fee Based Income
    fbi."fbi_total",
    fbi."fbi_acc_maint",
    fbi."fbi_atm",
    fbi."fbi_jom",
    fbi."fbi_edc",
    fbi."fbi_cms",
    fbi."fbi_abank",
    fbi."fbi_jas_pot",
    fbi."fbi_bisnis_kartu",
    fbi."fbi_bisnis_sdb",
    fbi."fbi_kirim_uang",
    fbi."fbi_rest_biaya_kantor",
    fbi."fbi_pin_nas_pen",
    fbi."fbi_bank_garansi",
    fbi."fbi_admin_kredit",
    fbi."fbi_lainnya",

    -- NII-Post FTP
    nii."nii_post_ftp",

    -- Direct OPEX
    0 "dir_opex_total",
    opx."dir_opex_manpower",
    opx."dir_opex_telecom",
    opx."dir_opex_ofc_sup",
    opx."dir_opex_per_din",
    opx."dir_opex_prem_ins_ncr",
    opx."dir_opex_prem_as_cr",
    opx."dir_opex_tran_cr",
    opx."dir_opex_tran_ncr",

    -- Beban CKPN
    ckpn."ckpn_nominal"

FROM BJKT_PNL_AVG_BAL_CREDIT_MV cre
LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
    ON  cre."kode_cabang"       = dpk."kode_cabang"
    AND cre."periode"           = dpk."periode"
LEFT JOIN BJKT_PNL_PEN_BUNGA_TOTAL_MV pbt
    ON  cre."kode_cabang"       = pbt."kode_cabang"
    AND cre."periode"           = pbt."periode"
LEFT JOIN BJKT_PNL_BEBAN_BUNGA_TOTAL_MV bbt
    ON  cre."kode_cabang"       = bbt."kode_cabang"
    AND cre."periode"           = bbt."periode"
LEFT JOIN BJKT_PNL_FTP_INCOME_MV fi
    ON  cre."kode_cabang"       = fi."kode_cabang"
    AND cre."periode"           = fi."periode"
LEFT JOIN BJKT_PNL_FTP_CHARGE_MV fc
    ON  cre."kode_cabang"       = fc."kode_cabang"
    AND cre."periode"           = fc."periode"
LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV fbi
    ON  cre."kode_cabang"       = fbi."kode_cabang"
    AND cre."periode"           = fbi."periode"
LEFT JOIN BJKT_PNL_NII_POST_FTP_MV nii
    ON  cre."kode_cabang"       = nii."kode_cabang"
    AND cre."periode"           = nii."periode"
LEFT JOIN BJKT_PNL_DIRECT_OPEX_MV opx
    ON  cre."kode_cabang"       = opx."kode_cabang"
    AND cre."periode"           = opx."periode"
LEFT JOIN BJKT_PNL_BEBAN_CKPN_MV ckpn
    ON  cre."kode_cabang"       = ckpn."kode_cabang"
    AND cre."periode"           = ckpn."periode"
;
/

-- Table view score card
CREATE OR REPLACE VIEW BJKT_PNL_SCORE_CARD_V AS
WITH q_unpivot AS (
    SELECT
        "periode" AS "periode",
        "kode_cabang",
        "nama_cabang",
        "kode_konsol",
        "nama_konsol",
        "column_name",
        "nominal"
    FROM BJKT_PNL_SUMMARY_V
    
    UNPIVOT (
        "nominal"
        FOR "column_name" IN (

            -- GROUP 1
            "total_kredit"              AS 'AVG_BAL_KREDIT',
            "kredit_total_konven"       AS 'KREDIT_KONVEN',
            "kredit_konven_kmg"         AS 'KREDIT_KONVEN_KMG',
            "kredit_konven_kpr"         AS 'KREDIT_KONVEN_KPR',
            "kredit_konven_mikro"       AS 'KREDIT_KONVEN_MIKRO',
            "kredit_konven_ukm"         AS 'KREDIT_KONVEN_UKM',
            "kredit_total_syariah"      AS 'KREDIT_SYARIAH',
            "kredit_syariah_kmg"        AS 'KREDIT_SYARIAH_KMG',
            "kredit_syariah_kpr"        AS 'KREDIT_SYARIAH_KPR',
            "kredit_syariah_mikro"      AS 'KREDIT_SYARIAH_MIKRO',
            "kredit_syariah_ukm"        AS 'KREDIT_SYARIAH_UKM',

            -- GROUP 2
            "total_dpk"                 AS 'AVG_BAL_DPK',
            "dpk_total_konven"          AS 'DPK_KONVEN',
            "dpk_konven_giro"           AS 'DPK_KONVEN_GIRO',
            "dpk_konven_tabungan"       AS 'DPK_KONVEN_TABUNGAN',
            "dpk_konven_deposito"       AS 'DPK_KONVEN_DEPOSITO',
            "dpk_total_syariah"         AS 'DPK_SYARIAH',
            "dpk_syariah_giro"          AS 'DPK_SYARIAH_GIRO',
            "dpk_syariah_tabungan"      AS 'DPK_SYARIAH_TABUNGAN',
            "dpk_syariah_deposito"      AS 'DPK_SYARIAH_DEPOSITO',

            -- GROUP 3
            "total_pen_bunga"           AS 'PEND_BUNGA',
            "total_bunga_konven"        AS 'BUNGA_KONVEN',
            "bunga_konven_kmg"          AS 'BUNGA_KONVEN_KMG',
            "bunga_konven_kpr"          AS 'BUNGA_KONVEN_KPR',
            "bunga_konven_mikro"        AS 'BUNGA_KONVEN_MIKRO',
            "bunga_konven_ukm"          AS 'BUNGA_KONVEN_UKM',
            "total_bunga_syariah"       AS 'BUNGA_SYARIAH',
            "bunga_syariah_kmg"         AS 'BUNGA_SYARIAH_KMG',
            "bunga_syariah_kpr"         AS 'BUNGA_SYARIAH_KPR',
            "bunga_syariah_mikro"       AS 'BUNGA_SYARIAH_MIKRO',
            "bunga_syariah_ukm"         AS 'BUNGA_SYARIAH_UKM',

            -- GROUP 4
            "ftp_income_dpk"            AS 'FTP_INCOME',

            -- GROUP 5
            "ftp_charge_loan"           AS 'FTP_CHARGE',

            -- GROUP 6
            "dir_opex_total"            AS 'DIRECT_OPEX',
            "dir_opex_manpower"         AS 'OPEX_MANPOWER',
            "dir_opex_telecom"          AS 'OPEX_TELECOM',
            "dir_opex_ofc_sup"          AS 'OPEX_OFFICE_SUPPLIES',
            "dir_opex_per_din"          AS 'OPEX_PERJALANAN_DINAS',
            "dir_opex_prem_ins_ncr"     AS 'OPEX_PREM_INS_NCR',
            "dir_opex_prem_as_cr"       AS 'OPEX_PREM_AS_CR',
            "dir_opex_tran_cr"          AS 'OPEX_TRAN_CR',
            "dir_opex_tran_ncr"         AS 'OPEX_TRAN_NCR',

            -- GROUP 7
            "ckpn_nominal"              AS 'CKPN'
        )
    )
)

SELECT
    "periode" AS "periode",
    "kode_cabang",
    "nama_cabang",
    "kode_konsol",
    "nama_konsol",
    "column_name",
    "nominal",

    CASE
        WHEN "column_name" IN (
            'AVG_BAL_KREDIT',
            'KREDIT_KONVEN',
            'KREDIT_KONVEN_KMG',
            'KREDIT_KONVEN_KPR',
            'KREDIT_KONVEN_MIKRO',
            'KREDIT_KONVEN_UKM',
            'KREDIT_SYARIAH',
            'KREDIT_SYARIAH_KMG',
            'KREDIT_SYARIAH_KPR',
            'KREDIT_SYARIAH_MIKRO',
            'KREDIT_SYARIAH_UKM'
        )
        THEN 1

        WHEN "column_name" IN (
            'AVG_BAL_DPK',
            'DPK_KONVEN',
            'DPK_KONVEN_GIRO',
            'DPK_KONVEN_TABUNGAN',
            'DPK_KONVEN_DEPOSITO',
            'DPK_SYARIAH',
            'DPK_SYARIAH_GIRO',
            'DPK_SYARIAH_TABUNGAN',
            'DPK_SYARIAH_DEPOSITO'
        )
        THEN 2

        WHEN "column_name" IN (
            'PEND_BUNGA',
            'BUNGA_KONVEN',
            'BUNGA_KONVEN_KMG',
            'BUNGA_KONVEN_KPR',
            'BUNGA_KONVEN_MIKRO',
            'BUNGA_KONVEN_UKM',
            'BUNGA_SYARIAH',
            'BUNGA_SYARIAH_KMG',
            'BUNGA_SYARIAH_KPR',
            'BUNGA_SYARIAH_MIKRO',
            'BUNGA_SYARIAH_UKM'
        )
        THEN 3

        WHEN "column_name" = 'FTP_INCOME'
        THEN 4

        WHEN "column_name" = 'FTP_CHARGE'
        THEN 5

        WHEN "column_name" LIKE 'OPEX%'
        THEN 6

        WHEN "column_name" = 'CKPN'
        THEN 7
    END AS "group_number",

    CASE
        WHEN "column_name" IN (
            'AVG_BAL_KREDIT',
            'AVG_BAL_DPK',
            'PEND_BUNGA',
            'FTP_INCOME',
            'FTP_CHARGE',
            'CKPN',
            'DIRECT_OPEX'
        )
        THEN 'Y'
        ELSE 'N'
    END AS "is_header"

FROM q_unpivot;
/