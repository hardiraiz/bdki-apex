SET DEFINE OFF;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_ECHANNEL_SY
FOR "pnl"."pnl_echannel"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_DPK_AVG_SY
FOR "pnl"."pnl_dpk_avg"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_LOAN_AVG_SY
FOR "pnl"."pnl_loan_avg"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_GL_SY
FOR "pnl"."pnl_gl"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_GL_V2_SY
FOR "pnl"."pnl_gl_v2"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_DIM_BRANCH_V2_SY
FOR "dwh"."dim_branch_v2"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_CKPN_SY
FOR "pnl"."pnl_ckpn"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_PENDAPATAN_BUNGA_SY
FOR "pnl"."pnl_pendapatan_bunga"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_BEBAN_BUNGA_SY
FOR "pnl"."pnl_beban_bunga"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_INCOME_DPK_SY
FOR "pnl"."pnl_income_dpk"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_CHARGE_LOAN_SY
FOR "pnl"."pnl_charge_loan"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_FBI_SY
FOR "pnl"."pnl_fbi"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_DIRECT_OPEX_SY
FOR "pnl"."pnl_direct_opex"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_OPEX_V2_SY
FOR "pnl"."pnl_opex_v2"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_DIRECT_PORSI_SY
FOR "pnl"."pnl_direct_porsi"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_DIRECT_CABANG_SY
FOR "public"."pnl_direct_cabang"@DWH
/

-- Materialized View list data cabang dan cabang konsolidasi
DROP MATERIALIZED VIEW BJKT_BRANCHES_MV;
/
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
    "kelas_branch",
    "segmen_branch",
    "keterangan"
FROM BJKT_DIM_BRANCH_V2_SY;
/
CREATE INDEX BJKT_BRANCHES_MV_I1 ON BJKT_BRANCHES_MV("kode_cabang_awal", "keterangan");
/
CREATE INDEX BJKT_BRANCHES_MV_I2 ON BJKT_BRANCHES_MV("kode_cabang_akhir", "keterangan");
/
CREATE INDEX BJKT_BRANCHES_MV_I3 ON BJKT_BRANCHES_MV("kode_konsol", "keterangan");
/
CREATE INDEX BJKT_BRANCHES_MV_I4 ON BJKT_BRANCHES_MV("kode_cabang_syariah", "keterangan");
/

-- Materialized view list data Avg. Balance Credit
DROP MATERIALIZED VIEW BJKT_PNL_AVG_BAL_CREDIT_MV;
/
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

-- Materialized View Avg. Balance DPK
DROP MATERIALIZED VIEW BJKT_PNL_AVG_BAL_DPK_MV;
/
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

    (SUM("avg") / POWER(10,6))                                                           
        AS "total_dpk",

    -- DPK Konven
    (SUM(CASE WHEN "produk" = 'Konven' THEN "avg" ELSE NULL END) / POWER(10,6))         
        AS "dpk_total_konven",
    (SUM(CASE WHEN "produk" = 'Konven'
                    AND "kategori" = 'Giro' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_konven_giro",
    (SUM(CASE WHEN "produk" = 'Konven'
                    AND "kategori" = 'Tabungan' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_konven_tabungan",
    (SUM(CASE WHEN "produk" = 'Konven'
                    AND "kategori" = 'Deposito' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_konven_deposito",

    -- DPK Syariah
    (SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM') THEN "avg" ELSE NULL END) / POWER(10,6))        
        AS "dpk_total_syariah",
    (SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
                    AND "kategori" = 'Giro' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_syariah_giro",
    (SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
                    AND "kategori" = 'Tabungan' THEN "avg" ELSE NULL END) / POWER(10,6))    
        AS "dpk_syariah_tabungan",
    (SUM(CASE WHEN "produk" IN ('Syariah', 'DBLM')
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

-- Materialized view list data Pend. Bunga total
DROP MATERIALIZED VIEW BJKT_PNL_PEN_BUNGA_TOTAL_MV;
/
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

    (SUM("pendapatan_bunga") / POWER(10,6))                                                                                      
        AS "total_pen_bunga",
    (SUM(CASE WHEN "produk" = 'Konven'                                              THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "total_bunga_konven",
    (SUM(CASE WHEN "produk" = 'Konven' AND "kategori_segment" = 'KMG'               THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_kmg",
    (SUM(CASE WHEN "produk" = 'Konven' AND "kategori_segment" = 'KPR'               THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_kpr",
    (SUM(CASE WHEN "produk" = 'Konven' AND "tipe_segment"     = 'Mikro'             THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_mikro",
    (SUM(CASE WHEN "produk" = 'Konven' AND "tipe_segment"     = 'UKM'               THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_ukm",
    (SUM(CASE WHEN "produk" IN ('Syariah','DBLM')                                   THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "total_bunga_syariah",
    (SUM(CASE WHEN "produk" IN ('Syariah','DBLM') AND "kategori_segment" = 'KMG'    THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_kmg",
    (SUM(CASE WHEN "produk" IN ('Syariah','DBLM') AND "kategori_segment" = 'KPR'    THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_kpr",
    (SUM(CASE WHEN "produk" IN ('Syariah','DBLM') AND "tipe_segment"     = 'Mikro'  THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_mikro",
    (SUM(CASE WHEN "produk" IN ('Syariah','DBLM') AND "tipe_segment"     = 'UKM'    THEN "pendapatan_bunga" END) / POWER(10,6)) 
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

-- Materialized view list data Beban Bunga total
DROP MATERIALIZED VIEW BJKT_PNL_BEBAN_BUNGA_TOTAL_MV;
/
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

    (SUM("beban_bunga") / POWER(10,6))                                                           
        AS "total_beban_bunga",

    -- DPK Konven
    (SUM(CASE WHEN "produk" = 'k' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))         
        AS "beban_bunga_konven",
    (SUM(CASE WHEN "produk" = 'k' AND "kategori" = 'Giro' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_konven_giro",
    (SUM(CASE WHEN "produk" = 'k' AND "kategori" = 'Tabungan' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_konven_tabungan",
    (SUM(CASE WHEN "produk" = 'k' AND "kategori" = 'Deposito' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_konven_deposito",

    -- DPK Syariah
    (SUM(CASE WHEN "produk" = 's' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))        
        AS "beban_bunga_total_syariah",
    (SUM(CASE WHEN "produk" = 's' AND "kategori" = 'Giro' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_syariah_giro",
    (SUM(CASE WHEN "produk" = 's' AND "kategori" = 'Tabungan' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_syariah_tabungan",
    (SUM(CASE WHEN "produk" = 's' AND "kategori" = 'Deposito' THEN "beban_bunga" ELSE NULL END) / POWER(10,6))    
        AS "beban_bunga_syariah_deposito"
FROM BJKT_PNL_BEBAN_BUNGA_SY
WHERE "kategori" IN ('Giro', 'Tabungan', 'Deposito')
GROUP BY "periode", "cabang", "nama_kantor_akhir", "kode_konsol", "nama_konsol";
/
CREATE INDEX BJKT_PNL_BEBAN_BUNGA_TOTAL_MV_I1 ON BJKT_PNL_BEBAN_BUNGA_TOTAL_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_BEBAN_BUNGA_TOTAL_MV_I2 ON BJKT_PNL_BEBAN_BUNGA_TOTAL_MV("periode", "kode_cabang");
/

-- Materialized view list data FTP Income
DROP MATERIALIZED VIEW BJKT_PNL_FTP_INCOME_MV;
/
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
    ("ftp_income_dpk" / POWER(10, 6)) AS "ftp_income_dpk"
FROM BJKT_PNL_INCOME_DPK_SY;
/
CREATE INDEX BJKT_PNL_FTP_INCOME_MV_I1 ON BJKT_PNL_FTP_INCOME_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_FTP_INCOME_MV_I2 ON BJKT_PNL_FTP_INCOME_MV("periode", "kode_cabang");
/

-- Materialized view list data FTP Charge
DROP MATERIALIZED VIEW BJKT_PNL_FTP_CHARGE_MV;
/
CREATE MATERIALIZED VIEW BJKT_PNL_FTP_CHARGE_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')        AS "periode",
    "cabang"                                AS "kode_cabang",
    "nama_kantor_akhir"                     AS "nama_cabang",
    "kode_konsol"                           AS "kode_konsol",
    "nama_konsol"                           AS "nama_konsol",
    ("ftp_charge_loan" / POWER(10, 6)) AS "ftp_charge_loan"
FROM BJKT_PNL_CHARGE_LOAN_SY;
/
CREATE INDEX BJKT_PNL_FTP_CHARGE_MV_I1 ON BJKT_PNL_FTP_CHARGE_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_FTP_CHARGE_MV_I2 ON BJKT_PNL_FTP_CHARGE_MV("periode", "kode_cabang");
/

-- Materialized view list data Fee Based Income
DROP MATERIALIZED VIEW BJKT_PNL_FEE_BASED_INCOME_MV;
/
CREATE MATERIALIZED VIEW BJKT_PNL_FEE_BASED_INCOME_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "kode_cabang_akhir"                 AS "kode_cabang",
    "kode_konsol",

    SUM("fbi") / POWER(10,6) AS "fbi_total",

    SUM(CASE WHEN "nama" = 'Account Maintenance'
                THEN "fbi" END) / POWER(10,6) AS "fbi_acc_maint",

    SUM(CASE WHEN "nama" = 'ATM'
                THEN "fbi" END) / POWER(10,6) AS "fbi_atm",

    SUM(CASE WHEN "nama" = 'JakOne Mobile'
                THEN "fbi" END) / POWER(10,6) AS "fbi_jom",

    SUM(CASE WHEN "nama" = 'EDC'
                THEN "fbi" END) / POWER(10,6) AS "fbi_edc",

    SUM(CASE WHEN "nama" = 'CMS'
                THEN "fbi" END) / POWER(10,6) AS "fbi_cms",

    SUM(CASE WHEN "nama" = 'ABANK'
                THEN "fbi" END) / POWER(10,6) AS "fbi_abank",

    SUM(CASE WHEN "nama" = 'Jasa Pemotongan'
                THEN "fbi" END) / POWER(10,6) AS "fbi_jas_pot",

    SUM(CASE WHEN "nama" = 'Bisnis Kartu'
                THEN "fbi" END) / POWER(10,6) AS "fbi_bisnis_kartu",

    SUM(CASE WHEN "nama" = 'Bisnis SDB'
                THEN "fbi" END) / POWER(10,6) AS "fbi_bisnis_sdb",

    SUM(CASE WHEN "nama" = 'Kiriman Uang (RTGS, kliring, dll.)'
                THEN "fbi" END) / POWER(10,6) AS "fbi_kirim_uang",

    SUM(CASE WHEN "nama" = 'RESTITUSI BIAYA KANTOR'
                THEN "fbi" END) / POWER(10,6) AS "fbi_rest_biaya_kantor",

    SUM(CASE WHEN "nama" = 'Pinalty Nasabah & Penolakan'
                THEN "fbi" END) / POWER(10,6) AS "fbi_pin_nas_pen",

    SUM(CASE WHEN "nama" = 'BANK GARANSI'
                THEN "fbi" END) / POWER(10,6) AS "fbi_bank_garansi",

    SUM(CASE WHEN "nama" = 'Admin Kredit'
                THEN "fbi" END) / POWER(10,6) AS "fbi_admin_kredit",

    SUM(CASE WHEN "nama" = 'Kerjasama Pihak Lain (komisi agen, asuransi)'
                THEN "fbi" END) / POWER(10,6) AS "fbi_ker_pihak_lain",

    SUM(CASE WHEN "nama" = 'M2M Forex & SB'
                THEN "fbi" END) / POWER(10,6) AS "fbi_m2m_frx_sb",

    SUM(CASE WHEN "nama" = 'Lainnya (komisi notaris, denda tunggakan)'
                THEN "fbi" END) / POWER(10,6) AS "fbi_lainnya"

FROM BJKT_PNL_FBI_SY
GROUP BY
    "periode",
    "kode_cabang_akhir",
    "kode_konsol";
/
CREATE INDEX BJKT_PNL_FEE_BASED_INCOME_MV_I1 ON BJKT_PNL_FEE_BASED_INCOME_MV("periode", "kode_konsol", "kode_cabang");
/
CREATE INDEX BJKT_PNL_FEE_BASED_INCOME_MV_I2 ON BJKT_PNL_FEE_BASED_INCOME_MV("periode", "kode_cabang");
/

-- Materialized view list data NII Post FTP
DROP MATERIALIZED VIEW BJKT_PNL_NII_POST_FTP_MV;
/
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
            "kode_konsol",
            SUM("pendapatan_bunga") / 1000000 AS "total_pen_bunga"
        FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
        WHERE
                "kategori_segment" IN ('KMG', 'KPR')
            OR  "tipe_segment"     IN ('Mikro', 'UKM')
        GROUP BY "periode", "cabang", "kode_konsol"
    ),
    beban_bunga AS (
        SELECT
            "periode",
            "cabang",
            "kode_konsol",
            SUM("beban_bunga") / 1000000 AS "total_beban_bunga"
        FROM BJKT_PNL_BEBAN_BUNGA_SY
        WHERE "kategori" IN ('Giro', 'Tabungan', 'Deposito')
        GROUP BY "periode", "cabang", "kode_konsol"
    ),
    ftp_charge AS (
        SELECT
            "periode",
            "cabang"                         AS "cabang",
            "kode_konsol",
            SUM("ftp_charge_loan") / 1000000 AS "ftp_charge_loan"
        FROM BJKT_PNL_CHARGE_LOAN_SY
        GROUP BY "periode", "cabang", "kode_konsol"
    ),
    ftp_income AS (
        SELECT
            "periode",
            "cabang",
            "kode_konsol",
            SUM("ftp_income_dpk") / 1000000 AS "ftp_income_dpk"
        FROM BJKT_PNL_INCOME_DPK_SY
        GROUP BY "periode", "cabang", "kode_konsol"
    )
    SELECT
        TO_DATE(bb."periode", 'YYYY-MM-DD') AS "periode",
        bb."cabang"                         AS "kode_cabang",
        bb."kode_konsol",
        (
            NVL(bb."total_beban_bunga", 0)
          + NVL(pb."total_pen_bunga",   0)
          + NVL(fc."ftp_charge_loan",   0)
          + NVL(fi."ftp_income_dpk",    0)
        )                                   AS "nii_post_ftp"
    FROM
        beban_bunga bb
    LEFT JOIN pend_bunga pb
        ON  bb."cabang"         = pb."cabang"
        AND bb."kode_konsol"    = pb."kode_konsol"
        AND bb."periode"        = pb."periode"
    LEFT JOIN ftp_charge fc
        ON  bb."cabang"         = fc."cabang"
        AND bb."kode_konsol"    = fc."kode_konsol"
        AND bb."periode"        = fc."periode"
    LEFT JOIN ftp_income fi
        ON  bb."cabang"         = fi."cabang"
        AND bb."kode_konsol"    = fi."kode_konsol"
        AND bb."periode"        = fi."periode"
);
/
CREATE INDEX BJKT_PNL_NII_POST_FTP_MV_I1 ON BJKT_PNL_NII_POST_FTP_MV("periode", "kode_cabang");
/

-- Materialized view list data Direct OPEX V2
DROP MATERIALIZED VIEW BJKT_PNL_DIRECT_OPEX_MV;
/
CREATE MATERIALIZED VIEW BJKT_PNL_DIRECT_OPEX_MV
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
WITH
q_main AS (
    SELECT
        TO_DATE("periode", 'YYYY-MM-DD')      AS "periode",
        "kode_cabang_akhir"                   AS "kode_cabang",
        "kode_konsol",
        NVL(SUM(CASE WHEN "ket_final" = 'Manpower'
                     THEN "nominal" END), 0)  AS "manpower_raw",
        NVL(SUM(CASE WHEN "ket_final" = 'IT & Telecommunication'
                     THEN "nominal" END), 0)  AS "telecom_raw",
        NVL(SUM(CASE WHEN "ket_final" = 'Office Supplies'
                     THEN "nominal" END), 0)  AS "off_sup_raw",
        NVL(SUM(CASE WHEN "ket_final" = 'Sewa (ATM, kendaraan, bangunan)'
                     THEN "nominal" END), 0)  AS "sewa_raw",
        NVL(SUM(CASE WHEN "ket_final" = 'Perjalanan Dinas'
                     THEN "nominal" END), 0)  AS "per_dinas_raw",
        NVL(SUM(CASE WHEN "ket_final" = 'Premium Insurance Non-Credit'
                     THEN "nominal" END), 0)  AS "prem_ins_ncr_raw",
        NVL(SUM(CASE WHEN "ket_final" = 'Beban Premi Asuransi Kredit'
                     THEN "nominal" END), 0)  AS "prem_ins_cr_raw",
        NVL(SUM(CASE WHEN "ket_final" = 'Beban Transaksi Kredit'
                     THEN "nominal" END), 0)  AS "trans_kredit_raw",
        NVL(SUM(CASE WHEN "ket_final" = 'Beban Transaksi Non Kredit'
                     THEN "nominal" END), 0)  AS "trans_non_kredit_raw"
    FROM BJKT_PNL_DIRECT_OPEX_SY
    GROUP BY
        "periode",
        "kode_cabang_akhir",
        "kode_konsol"
)
SELECT
    "periode" AS "periode",
    "kode_cabang",
    "kode_konsol",
    (
        (
            "manpower_raw"
          + "telecom_raw"
          + "off_sup_raw"
          + "sewa_raw"
          + "per_dinas_raw"
          + "prem_ins_ncr_raw"
          + "prem_ins_cr_raw"
          + "trans_kredit_raw"
          + "trans_non_kredit_raw"
        ) / POWER(10, 6))                      AS "dir_opex_total",
    ("manpower_raw"          / POWER(10, 6))   AS "dir_opex_manpower",
    ("telecom_raw"           / POWER(10, 6))   AS "dir_opex_telecom",
    ("off_sup_raw"           / POWER(10, 6))   AS "dir_opex_ofc_sup",
    ("sewa_raw"              / POWER(10, 6))   AS "dir_opex_sewa",
    ("per_dinas_raw"         / POWER(10, 6))   AS "dir_opex_per_din",
    ("prem_ins_ncr_raw"      / POWER(10, 6))   AS "dir_opex_prem_ins_ncr",
    ("prem_ins_cr_raw"       / POWER(10, 6))   AS "dir_opex_prem_as_cr",
    ("trans_kredit_raw"      / POWER(10, 6))   AS "dir_opex_tran_cr",
    ("trans_non_kredit_raw"  / POWER(10, 6))   AS "dir_opex_tran_ncr"
FROM q_main
ORDER BY "periode";
/
CREATE UNIQUE INDEX BJKT_PNL_DIRECT_OPEX_MV_PK ON BJKT_PNL_DIRECT_OPEX_MV ("periode", "kode_cabang");
/
CREATE INDEX BJKT_PNL_DIRECT_OPEX_MV_I1 ON BJKT_PNL_DIRECT_OPEX_MV ("kode_cabang");
/
CREATE INDEX BJKT_PNL_DIRECT_OPEX_MV_I2 ON BJKT_PNL_DIRECT_OPEX_MV ("periode");
/

DROP MATERIALIZED VIEW BJKT_PNL_BEBAN_CKPN_MV;
/
-- Materialized view list data Beban CKPN V2
CREATE MATERIALIZED VIEW BJKT_PNL_BEBAN_CKPN_MV
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    TO_DATE("tanggal_data", 'YYYY-MM-DD')   AS "periode",
    "kode_cabang"                           AS "kode_cabang",
    "kode_konsol",
    (SUM("nominal_ckpn") / 1000000)         AS "ckpn_nominal"
FROM BJKT_PNL_CKPN_SY
WHERE "tipe_segment" <> 'Commercial'
GROUP BY "tanggal_data", "kode_konsol", "kode_cabang";
/
CREATE INDEX BJKT_PNL_BEBAN_CKPN_MV_I1 ON BJKT_PNL_BEBAN_CKPN_MV("periode", "kode_cabang");
/

-- Materialized view list data Beban CKPN
DROP MATERIALIZED VIEW BJKT_PNL_BEBAN_CKPN_TOT_MV;
/
CREATE MATERIALIZED VIEW BJKT_PNL_BEBAN_CKPN_TOT_MV
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    TO_DATE("tanggal_data", 'YYYY-MM-DD')   AS "periode",
    "kode_cabang"                           AS "kode_cabang",
    "kode_konsol",
    (SUM("nominal_ckpn") / 1000000)         AS "ckpn_nominal"
FROM BJKT_PNL_CKPN_SY
GROUP BY "tanggal_data", "kode_cabang", "kode_konsol";
/
CREATE INDEX BJKT_PNL_BEBAN_CKPN_TOT_MV_I1 ON BJKT_PNL_BEBAN_CKPN_TOT_MV("periode", "kode_cabang");
/