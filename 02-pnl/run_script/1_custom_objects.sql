SET DEFINE OFF;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_ECHANNEL_SY
FOR "dwh"."pnl_echannel"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_DPK_AVG_SY
FOR "dwh"."pnl_dpk_avg"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_LOAN_AVG_SY
FOR "dwh"."pnl_loan_avg"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_GL_SY
FOR "dwh"."pnl_gl"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_GL_V2_SY
FOR "dwh"."pnl_gl_v2"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_DIM_BRANCH_V2_SY
FOR "dwh"."dim_branch_v2"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_CKPN_SY
FOR "dwh"."pnl_ckpn"@DWH;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_PENDAPATAN_BUNGA_SY
FOR "dwh"."pnl_pendapatan_bunga"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_BEBAN_BUNGA_SY
FOR "dwh"."pnl_beban_bunga"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_INCOME_DPK_SY
FOR "dwh"."pnl_income_dpk"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_CHARGE_LOAN_SY
FOR "dwh"."pnl_charge_loan"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_FBI_SY
FOR "dwh"."pnl_fbi"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_OPEX_V2_SY
FOR "dwh"."pnl_opex_v2"@DWH
/

CREATE OR REPLACE SYNONYM BJKT_PNL_DIRECT_PORSI_SY
FOR "dwh"."pnl_direct_porsi"@DWH
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
    (SUM(CASE WHEN "padanan" = 'Konven' THEN "avg" ELSE NULL END) / POWER(10,6))         
        AS "kredit_total_konven",
    (SUM(CASE WHEN "padanan" = 'Konven'
                    AND "kategori_segment" = 'KMG' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_kmg",
    (SUM(CASE WHEN "padanan" = 'Konven'
                    AND "kategori_segment" = 'KPR' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_kpr",
    (SUM(CASE WHEN "padanan" = 'Konven'
                    AND "tipe_segment" = 'Mikro' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_mikro",
    (SUM(CASE WHEN "padanan" = 'Konven'
                    AND "tipe_segment" = 'UKM' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_konven_ukm",

    -- Syariah
    (SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM') THEN "avg" ELSE NULL END) / POWER(10,6))        
        AS "kredit_total_syariah",
    (SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                    AND "kategori_segment" = 'KMG' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_syariah_kmg",
    (SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                    AND "kategori_segment" = 'KPR' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_syariah_kpr",
    (SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                    AND "tipe_segment" = 'Mikro' THEN "avg" ELSE NULL END) / POWER(10,6))  
        AS "kredit_syariah_mikro",
    (SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
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
    (SUM(CASE WHEN "padanan" = 'Konven'                                              THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "total_bunga_konven",
    (SUM(CASE WHEN "padanan" = 'Konven' AND "kategori_segment" = 'KMG'               THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_kmg",
    (SUM(CASE WHEN "padanan" = 'Konven' AND "kategori_segment" = 'KPR'               THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_kpr",
    (SUM(CASE WHEN "padanan" = 'Konven' AND "tipe_segment"     = 'Mikro'             THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_mikro",
    (SUM(CASE WHEN "padanan" = 'Konven' AND "tipe_segment"     = 'UKM'               THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_konven_ukm",
    (SUM(CASE WHEN "padanan" IN ('Syariah','DBLM')                                   THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "total_bunga_syariah",
    (SUM(CASE WHEN "padanan" IN ('Syariah','DBLM') AND "kategori_segment" = 'KMG'    THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_kmg",
    (SUM(CASE WHEN "padanan" IN ('Syariah','DBLM') AND "kategori_segment" = 'KPR'    THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_kpr",
    (SUM(CASE WHEN "padanan" IN ('Syariah','DBLM') AND "tipe_segment"     = 'Mikro'  THEN "pendapatan_bunga" END) / POWER(10,6)) 
        AS "bunga_syariah_mikro",
    (SUM(CASE WHEN "padanan" IN ('Syariah','DBLM') AND "tipe_segment"     = 'UKM'    THEN "pendapatan_bunga" END) / POWER(10,6)) 
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
    "kode_cabang_akhir"                     AS "kode_cabang",
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

-- SET DEFINE OFF;
-- DROP MATERIALIZED VIEW BJKT_PNL_FEE_BASED_INCOME_MV;
-- Materialized view list data Fee Based Income V1
-- CREATE MATERIALIZED VIEW BJKT_PNL_FEE_BASED_INCOME_MV
-- BUILD IMMEDIATE
-- REFRESH COMPLETE
-- ON DEMAND
-- AS
-- SELECT 
--     TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
--     "kode_cabang_akhir"                 AS "kode_cabang",        

--     (SUM("fbi") / POWER(10,6)) 
--         AS "fbi_total",
--     (SUM(CASE WHEN "nama" = 'Account Maintenance' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_acc_maint",
--     (SUM(CASE WHEN "nama" = 'ATM FBI' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_atm",
--     (SUM(CASE WHEN "nama" = 'JakOne Mobile FBI' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_jom",
--     -- add column edc here
--     (SUM(CASE WHEN "nama" = 'EDC FBI' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_edc",
--     (SUM(CASE WHEN "nama" = 'CMS' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_cms",
--     (SUM(CASE WHEN "nama" = 'ABANK FBI' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_abank",
--     (SUM(CASE WHEN "nomor_rekening" = '432003602100' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_jas_pot",
--     SUM(CASE WHEN "nama" = 'Bisnis Kartu' THEN "fbi" ELSE NULL END) / POWER(10,6)
--         AS "fbi_bisnis_kartu",
--     (SUM(CASE WHEN "nama" = 'Bisnis SDB' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_bisnis_sdb",
--     (SUM(CASE WHEN "nama" = 'Kiriman Uang (RTGS, kliring, dll.)' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_kirim_uang",
--     (SUM(CASE WHEN "nama" = 'RESTITUSI BIAYA KANTOR' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_rest_biaya_kantor",
--     (SUM(CASE WHEN "nama" = 'Pinalty Nasabah & Penolakan' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_pin_nas_pen",
--     -- add column sindikasi here
--     -- add column trade finance here
--     (SUM(CASE WHEN "nama" = 'BANK GARANSI' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_bank_garansi",
--     (SUM(CASE WHEN "nama" = 'Admin Kredit' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_admin_kredit",
--     (SUM(CASE WHEN "nama" = 'Kerjasama Pihak Lain (komisi agen, asuransi)' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_ker_pihak_lain",
--     -- add column dividen reksa dana here
--     -- add column dividen M2M Forex & SB here
--     (SUM(CASE WHEN "nama" = 'Lainnya (komisi notaris, denda tunggakan)' THEN "fbi" ELSE NULL END) / POWER(10,6))
--         AS "fbi_lainnya"
--     -- add column collection recovery income here
-- FROM BJKT_PNL_FBI_SY
-- GROUP BY "periode", "kode_cabang_akhir";
-- /
-- CREATE INDEX BJKT_PNL_FEE_BASED_INCOME_MV_I1 ON BJKT_PNL_FEE_BASED_INCOME_MV("periode", "kode_cabang");
-- /

-- SET DEFINE OFF;
-- Materialized view list data Fee Based Income
DROP MATERIALIZED VIEW BJKT_PNL_FEE_BASED_INCOME_MV;
/
CREATE MATERIALIZED VIEW BJKT_PNL_FEE_BASED_INCOME_MV
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
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
    GROUP BY
        "periode",
        "kode_cabang_akhir",
        "kode_konsol"
);
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
            "kode_cabang_akhir"              AS "cabang",
            "kode_konsol",
            SUM("ftp_charge_loan") / 1000000 AS "ftp_charge_loan"
        FROM BJKT_PNL_CHARGE_LOAN_SY
        GROUP BY "periode", "kode_cabang_akhir", "kode_konsol"
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

-- DROP MATERIALIZED VIEW BJKT_PNL_DIRECT_OPEX_MV;
-- Materialized view list data Direct OPEX V1
-- CREATE MATERIALIZED VIEW BJKT_PNL_DIRECT_OPEX_MV
-- BUILD IMMEDIATE
-- REFRESH COMPLETE ON DEMAND
-- AS
-- SELECT
--     TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
--     "kode_cabang_akhir"                 AS "kode_cabang",
--     ((SUM(CASE WHEN "ket_final" = 'Manpower' THEN "nominal" ELSE NULL END) / POWER(10,6)))
--         AS "dir_opex_manpower",
--     ((SUM(CASE WHEN "ket_final" = 'IT & Telecommunication' THEN "nominal" ELSE NULL END) / POWER(10,6)))
--         AS "dir_opex_telecom",
--     ((SUM(CASE WHEN "ket_final" = 'Office Supplies' THEN "nominal" ELSE NULL END) / POWER(10,6)))
--         AS "dir_opex_ofc_sup",
--     -- Add column sewa atm here
--     ((SUM(CASE WHEN "ket_final" = 'Perjalanan Dinas' THEN "nominal" ELSE NULL END) / POWER(10,6)))
--         AS "dir_opex_per_din",
--     ((SUM(CASE WHEN "ket_final" = 'Premium Insurance Non-Credit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
--         AS "dir_opex_prem_ins_ncr",
--     ((SUM(CASE WHEN "ket_final" = 'Premi Asuransi Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
--         AS "dir_opex_prem_as_cr",
--     ((SUM(CASE WHEN "ket_final" = 'Transaksi Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
--         AS "dir_opex_tran_cr",
--     ((SUM(CASE WHEN "ket_final" = 'Transaksi Non Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
--         AS "dir_opex_tran_ncr"
-- FROM BJKT_PNL_GL_V2_SY
-- GROUP BY "periode", "kode_cabang_akhir";
-- /
-- CREATE INDEX BJKT_PNL_DIRECT_OPEX_MV_I1 ON BJKT_PNL_DIRECT_OPEX_MV("periode", "kode_cabang");
-- /

-- SET DEFINE OFF;
-- Materialized view list data Direct OPEX V2
DROP MATERIALIZED VIEW BJKT_PNL_DIRECT_OPEX_MV;
/
CREATE MATERIALIZED VIEW BJKT_PNL_DIRECT_OPEX_MV
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
WITH
sewa_opex_pusat AS (
    SELECT
        pg."kode_cabang_akhir",
        pg."nomor_rekening",
        pg."ket_final",
        pg."nom"
    FROM BJKT_PNL_OPEX_V2_SY pg
    WHERE pg."ket_final" = 'Sewa (kendaraan, bangunan, peralatan, dll.)'
      AND pg."nomor_rekening" IN (
            '521003600300','511003600102','501133600200',
            '501133600102','565033600500','531013600200'
      )
      AND (
            SUBSTR(pg."kode_cabang_akhir", 1, 1) IN ('9', '0')
            OR pg."kode_cabang_akhir" = '700'
      )
),
sewa_porsi AS (
    SELECT DISTINCT *
    FROM BJKT_PNL_DIRECT_PORSI_SY dp
    WHERE dp."porsi" <> '-'
),
sewa_nomxporsi AS (
    SELECT
        a."nomor_rekening",
        b."keterangan",
        SUM(a."nom")                             AS "nominal_gl",
        CAST(b."porsi" AS NUMBER)                AS "porsi",
        SUM(a."nom") * CAST(b."porsi" AS NUMBER) AS "nomxporsi_raw"
    FROM sewa_opex_pusat a
    LEFT JOIN sewa_porsi b ON a."nomor_rekening" = b."nomor_rekening"
    GROUP BY a."nomor_rekening", b."keterangan", CAST(b."porsi" AS NUMBER)
),
sewa_cabang_lain AS (
    SELECT
        pg."kode_cabang_akhir",
        SUM(pg."nom") AS "nominal_gl_cabang_raw"
    FROM BJKT_PNL_OPEX_V2_SY pg
    WHERE pg."ket_final" = 'Sewa (kendaraan, bangunan, peralatan, dll.)'
      AND (
            SUBSTR(pg."kode_cabang_akhir", 1, 1) NOT IN ('9', '0')
            OR pg."kode_cabang_akhir" <> '700'
      )
    GROUP BY pg."kode_cabang_akhir"
),
sewa_direct_cabang AS (
    SELECT DISTINCT
        pip."attribute",
        pip."keterangan",
        pip."value"
    FROM BJKT_PNL_DIRECT_CABANG_SY pip
    WHERE pip."keterangan" IN (
            'Beban Pny Aset Sw Prbt-Plkp Ktr I Oto',
            'Beban Bng Pnyst Aset Sw Kpd Pihak Berelasi',
            'Beban Sewa ATM'
    )
),
sewa_raw AS (
    SELECT
        a."attribute"                               AS "kode_cabang_akhir",
        SUM(FLOOR(b."nomxporsi_raw" * CAST(a."value" AS NUMBER)))
            + NVL(c."nominal_gl_cabang_raw", 0)    AS "sewa_raw"
    FROM sewa_direct_cabang a
    LEFT JOIN sewa_nomxporsi b   ON a."keterangan"  = b."keterangan"
    LEFT JOIN sewa_cabang_lain c ON a."attribute"   = c."kode_cabang_akhir"
    GROUP BY a."attribute", c."nominal_gl_cabang_raw"
),
opex_pusat AS (
    SELECT
        pg."kode_cabang_akhir",
        pg."nomor_rekening",
        pg."ket_final",
        pg."nom"
    FROM BJKT_PNL_OPEX_V2_SY pg
    WHERE pg."ket_final" = 'Lainnya (BBM Operasional, Pembayaran pajak, dll.)'
),
opex_cabang_pusat AS (
    SELECT * FROM opex_pusat
    WHERE SUBSTR("kode_cabang_akhir", 1, 1) IN ('9', '0')
       OR "kode_cabang_akhir" = '700'
),
opex_cabang_lain AS (
    SELECT
        "kode_cabang_akhir",
        "ket_final",
        SUM("nom") AS "nominal_gl_cabang"
    FROM opex_pusat
    WHERE SUBSTR("kode_cabang_akhir", 1, 1) NOT IN ('9', '0')
       OR "kode_cabang_akhir" <> '700'
    GROUP BY "kode_cabang_akhir", "ket_final"
),
porsi_data AS (
    SELECT DISTINCT
        "periode",
        "nomor_rekening",
        "porsi",
        "keterangan",
        CASE
            WHEN "keterangan" = 'Beban Pengisian Uang ATM'
            THEN 'Beban Transaksi Non Kredit'
            ELSE 'Beban Transaksi Kredit'
        END AS "keterangan1"
    FROM BJKT_PNL_DIRECT_PORSI_SY
    WHERE "porsi" <> '-'
      AND "keterangan" IN (
            'Beban Pengisian Uang ATM',
            'Beban Penutupan Kredit Kpd Pihak Ketiga'
      )
),
direct_cabang AS (
    SELECT DISTINCT
        "attribute",
        "keterangan",
        "value"
    FROM BJKT_PNL_DIRECT_CABANG_SY
    WHERE "keterangan" IN (
            'Beban Pengisian Uang ATM',
            'Beban Penutupan Kredit Kpd Pihak Ketiga'
    )
),
nomxporsi_data AS (
    SELECT
        a."nomor_rekening",
        b."keterangan",
        b."keterangan1",
        SUM(a."nom")                        AS "nominal_gl",
        TO_NUMBER(b."porsi")                AS "porsi",
        SUM(a."nom") * TO_NUMBER(b."porsi") AS "nomxporsi"
    FROM opex_cabang_pusat a
    JOIN porsi_data b ON a."nomor_rekening" = b."nomor_rekening"
    WHERE b."keterangan" IS NOT NULL
      AND a."nomor_rekening" IN (
            '511003600101','571113600101','531013600200',
            '527013600300','571053600100','565023600100','521003600300'
      )
    GROUP BY
        a."nomor_rekening",
        b."keterangan",
        b."keterangan1",
        TO_NUMBER(b."porsi")
),
nominal_per_cabang AS (
    SELECT
        pg."kode_cabang_akhir",
        CASE
            WHEN pg."nomor_rekening" IN (
                '571113600101','531013600200','527013600300','571053600100'
            )
            THEN 'Beban Transaksi Kredit'
            ELSE 'Beban Transaksi Non Kredit'
        END AS "keterangan1",
        SUM(pg."nom") AS "nominal_gl_cabang"
    FROM BJKT_PNL_OPEX_V2_SY pg
    WHERE pg."nomor_rekening" IN (
            '571113600101','531013600200','527013600300',
            '571053600100','565023600100','521003600300'
    )
    GROUP BY
        pg."kode_cabang_akhir",
        CASE
            WHEN pg."nomor_rekening" IN (
                '571113600101','531013600200','527013600300','571053600100'
            )
            THEN 'Beban Transaksi Kredit'
            ELSE 'Beban Transaksi Non Kredit'
        END
),
gl_summary AS (
    SELECT
        g."kode_cabang_akhir",
        SUM(CASE WHEN g."ket_final" = 'Manpower'
                 THEN g."nom" END)              AS "manpower_raw",
        SUM(CASE WHEN g."ket_final" = 'IT & Telecommunication'
                 THEN g."nom" END)              AS "telecom_raw"
    FROM BJKT_PNL_OPEX_V2_SY g
    WHERE g."ket_final" IN ('Manpower', 'IT & Telecommunication')
    GROUP BY g."kode_cabang_akhir"
),
scorecard AS (
    SELECT
        a."attribute"                           AS "kode_cabang_akhir",
        SUM(CASE WHEN b."keterangan1" = 'Beban Transaksi Kredit'
                 THEN FLOOR(b."nomxporsi" * TO_NUMBER(a."value"))
                    + FLOOR(d."nominal_gl_cabang")
                 END)                           AS "trans_kredit_raw",
        SUM(CASE WHEN b."keterangan1" = 'Beban Transaksi Non Kredit'
                 THEN FLOOR(b."nomxporsi" * TO_NUMBER(a."value"))
                    + FLOOR(d."nominal_gl_cabang")
                 END)                           AS "trans_non_kredit_raw"
    FROM direct_cabang a
    LEFT JOIN nomxporsi_data b   ON a."keterangan"  = b."keterangan"
    LEFT JOIN opex_cabang_lain c ON a."attribute"   = c."kode_cabang_akhir"
    LEFT JOIN nominal_per_cabang d
           ON b."keterangan1"   = d."keterangan1"
          AND a."attribute"     = d."kode_cabang_akhir"
    GROUP BY a."attribute"
),
premi_kredit AS (
    SELECT
        pg."kode_cabang_akhir",
        FLOOR(SUM(pg."nom"))                    AS "premi_kredit_raw"
    FROM BJKT_PNL_OPEX_V2_SY pg
    WHERE pg."nomor_rekening" = '511003600101'
      AND (
            SUBSTR(pg."kode_cabang_akhir", 1, 1) NOT IN ('9', '0')
            OR pg."kode_cabang_akhir" <> '700'
      )
    GROUP BY pg."kode_cabang_akhir"
),
hasil_utama AS (
    SELECT
        TO_DATE(o."periode", 'YYYY-MM-DD')      AS "periode",
        o."kode_cabang_akhir"                   AS "kode_cabang",
        o."kode_konsol",
        NVL(g."manpower_raw",  0)               AS "manpower_raw",
        NVL(g."telecom_raw",   0)               AS "telecom_raw",
        NVL(SUM(CASE WHEN o."ket_final" = 'Office Supplies'
                     THEN o."nom" END), 0)      AS "off_sup_raw",
        NVL(sw."sewa_raw", 0)                   AS "sewa_raw",
        NVL(SUM(CASE WHEN o."ket_final" = 'Beban Perjalanan Dinas'
                     THEN o."nom" END), 0)      AS "per_dinas_raw",
        NVL(SUM(CASE WHEN o."ket_final" = 'Premium Insurance Non-Credit'
                          AND o."ket_4" = 'Direct'
                     THEN o."nom" END), 0)      AS "prem_ins_ncr_raw",
        NVL(pk."premi_kredit_raw",  0)          AS "prem_ins_cr_raw",
        NVL(sc."trans_kredit_raw",  0)          AS "trans_kredit_raw",
        NVL(sc."trans_non_kredit_raw", 0)       AS "trans_non_kredit_raw"
    FROM BJKT_PNL_OPEX_V2_SY o
    LEFT JOIN gl_summary      g  ON o."kode_cabang_akhir" = g."kode_cabang_akhir"
    LEFT JOIN sewa_raw        sw ON o."kode_cabang_akhir" = sw."kode_cabang_akhir"
    LEFT JOIN scorecard       sc ON o."kode_cabang_akhir" = sc."kode_cabang_akhir"
    LEFT JOIN premi_kredit    pk ON o."kode_cabang_akhir" = pk."kode_cabang_akhir"
    GROUP BY
        o."periode",
        o."kode_cabang_akhir",
        o."kode_konsol",
        g."manpower_raw",
        g."telecom_raw",
        sw."sewa_raw",
        pk."premi_kredit_raw",
        sc."trans_kredit_raw",
        sc."trans_non_kredit_raw"
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
        ) / POWER(10, 6))                           AS "dir_opex_total",
    ("manpower_raw"          / POWER(10, 6))   AS "dir_opex_manpower",
    ("telecom_raw"           / POWER(10, 6))   AS "dir_opex_telecom",
    ("off_sup_raw"           / POWER(10, 6))   AS "dir_opex_ofc_sup",
    ("sewa_raw"              / POWER(10, 6))   AS "dir_opex_sewa",
    ("per_dinas_raw"         / POWER(10, 6))   AS "dir_opex_per_din",
    ("prem_ins_ncr_raw"      / POWER(10, 6))   AS "dir_opex_prem_ins_ncr",
    ("prem_ins_cr_raw"       / POWER(10, 6))   AS "dir_opex_prem_as_cr",
    ("trans_kredit_raw"      / POWER(10, 6))   AS "dir_opex_tran_cr",
    ("trans_non_kredit_raw"  / POWER(10, 6))   AS "dir_opex_tran_ncr"
FROM hasil_utama
ORDER BY "periode";
/
CREATE UNIQUE INDEX BJKT_PNL_DIRECT_OPEX_MV_PK ON BJKT_PNL_DIRECT_OPEX_MV ("periode", "kode_cabang");
/
CREATE INDEX BJKT_PNL_DIRECT_OPEX_MV_I1 ON BJKT_PNL_DIRECT_OPEX_MV ("kode_cabang");
/
CREATE INDEX BJKT_PNL_DIRECT_OPEX_MV_I2 ON BJKT_PNL_DIRECT_OPEX_MV ("periode");
/

-- Materialized view list data Beban CKPN
DROP MATERIALIZED VIEW BJKT_PNL_BEBAN_CKPN_MV;
/
CREATE MATERIALIZED VIEW BJKT_PNL_BEBAN_CKPN_MV
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
    "periode"                                  AS "periode",
    "kode_cabang"                              AS "kode_cabang",
    "kode_konsol",
    ABS((SUM("nom_ckpn") / POWER(10,6)))  AS "ckpn_nominal"
FROM BJKT_PNL_CKPN_SY
WHERE
        "tipe_segment" IN ('Konsumer', 'Mikro', 'UKM')
    -- AND "produk" = 'Konven' -- hilangkan filter produk Hardi: 10-Jun-26
GROUP BY "periode", "kode_cabang", "kode_konsol";
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
    "periode"                                  AS "periode",
    "kode_cabang"                              AS "kode_cabang",
    "kode_konsol",
    ABS((SUM("nom_ckpn") / POWER(10,6)))  AS "ckpn_nominal"
FROM BJKT_PNL_CKPN_SY
WHERE
        -- "tipe_segment" IN ('Konsumer', 'Mikro', 'UKM')
        "produk" = 'Konven'
    -- AND "produk" = 'Konven' -- hilangkan filter produk Hardi: 10-Jun-26
GROUP BY "periode", "kode_cabang", "kode_konsol";
/
CREATE INDEX BJKT_PNL_BEBAN_CKPN_TOT_MV_I1 ON BJKT_PNL_BEBAN_CKPN_TOT_MV("periode", "kode_cabang");
/

-- Table View Summary PnL
-- CREATE OR REPLACE VIEW BJKT_PNL_SUMMARY_V AS
-- SELECT
--     cre."periode" AS "periode",
--     cre."kode_cabang",
--     cre."nama_cabang",
--     cre."kode_konsol",
--     cre."nama_konsol",
    
--     -- Avg. Balance Credit
--     cre."total_kredit",
--     cre."kredit_total_konven",
--     cre."kredit_konven_kmg",
--     cre."kredit_konven_kpr",
--     cre."kredit_konven_mikro",
--     cre."kredit_konven_ukm",
--     cre."kredit_total_syariah",
--     cre."kredit_syariah_kmg",
--     cre."kredit_syariah_kpr",
--     cre."kredit_syariah_mikro",
--     cre."kredit_syariah_ukm",

--     -- Avg. Balance DPK
--     dpk."total_dpk",
--     dpk."dpk_total_konven",
--     dpk."dpk_konven_giro",
--     dpk."dpk_konven_tabungan",
--     dpk."dpk_konven_deposito",
--     dpk."dpk_total_syariah",
--     dpk."dpk_syariah_giro",
--     dpk."dpk_syariah_tabungan",
--     dpk."dpk_syariah_deposito",

--     -- Pend. Bunga
--     pbt."total_pen_bunga",
--     pbt."total_bunga_konven",
--     pbt."bunga_konven_kmg",
--     pbt."bunga_konven_kpr",
--     pbt."bunga_konven_mikro",
--     pbt."bunga_konven_ukm",
--     pbt."total_bunga_syariah",
--     pbt."bunga_syariah_kmg",
--     pbt."bunga_syariah_kpr",
--     pbt."bunga_syariah_mikro",
--     pbt."bunga_syariah_ukm",

--     -- Beban Bunga Total
--     bbt."total_beban_bunga",
--     bbt."beban_bunga_konven",
--     bbt."beban_bunga_konven_giro",
--     bbt."beban_bunga_konven_tabungan",
--     bbt."beban_bunga_konven_deposito",
--     bbt."beban_bunga_total_syariah",
--     bbt."beban_bunga_syariah_giro",
--     bbt."beban_bunga_syariah_tabungan",
--     bbt."beban_bunga_syariah_deposito",

--     -- FTP Income
--     fi."ftp_income_dpk",

--     -- FTP Charge Loan
--     fc."ftp_charge_loan",

--     -- Fee Based Income
--     fbi."fbi_total",
--     fbi."fbi_acc_maint",
--     fbi."fbi_atm",
--     fbi."fbi_jom",
--     fbi."fbi_edc",
--     fbi."fbi_cms",
--     fbi."fbi_abank",
--     fbi."fbi_jas_pot",
--     fbi."fbi_bisnis_kartu",
--     fbi."fbi_bisnis_sdb",
--     fbi."fbi_kirim_uang",
--     fbi."fbi_rest_biaya_kantor",
--     fbi."fbi_pin_nas_pen",
--     fbi."fbi_bank_garansi",
--     fbi."fbi_admin_kredit",
--     fbi."fbi_lainnya",

--     -- NII-Post FTP
--     nii."nii_post_ftp",

--     -- Direct OPEX
--     opx."dir_opex_total",
--     opx."dir_opex_manpower",
--     opx."dir_opex_telecom",
--     opx."dir_opex_ofc_sup",
--     opx."dir_opex_sewa",
--     opx."dir_opex_per_din",
--     opx."dir_opex_prem_ins_ncr",
--     opx."dir_opex_prem_as_cr",
--     opx."dir_opex_tran_cr",
--     opx."dir_opex_tran_ncr",

--     -- Beban CKPN
--     ckpn."ckpn_nominal"

-- FROM BJKT_PNL_AVG_BAL_CREDIT_MV cre
-- LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
--     ON  cre."kode_cabang"       = dpk."kode_cabang"
--     AND cre."periode"           = dpk."periode"
-- LEFT JOIN BJKT_PNL_PEN_BUNGA_TOTAL_MV pbt
--     ON  cre."kode_cabang"       = pbt."kode_cabang"
--     AND cre."periode"           = pbt."periode"
-- LEFT JOIN BJKT_PNL_BEBAN_BUNGA_TOTAL_MV bbt
--     ON  cre."kode_cabang"       = bbt."kode_cabang"
--     AND cre."periode"           = bbt."periode"
-- LEFT JOIN BJKT_PNL_FTP_INCOME_MV fi
--     ON  cre."kode_cabang"       = fi."kode_cabang"
--     AND cre."periode"           = fi."periode"
-- LEFT JOIN BJKT_PNL_FTP_CHARGE_MV fc
--     ON  cre."kode_cabang"       = fc."kode_cabang"
--     AND cre."periode"           = fc."periode"
-- LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV fbi
--     ON  cre."kode_cabang"       = fbi."kode_cabang"
--     AND cre."periode"           = fbi."periode"
-- LEFT JOIN BJKT_PNL_NII_POST_FTP_MV nii
--     ON  cre."kode_cabang"       = nii."kode_cabang"
--     AND cre."periode"           = nii."periode"
-- LEFT JOIN BJKT_PNL_DIRECT_OPEX_MV opx
--     ON  cre."kode_cabang"       = opx."kode_cabang"
--     AND cre."periode"           = opx."periode"
-- LEFT JOIN BJKT_PNL_BEBAN_CKPN_MV ckpn
--     ON  cre."kode_cabang"       = ckpn."kode_cabang"
--     AND cre."periode"           = ckpn."periode"
-- ;
-- /

-- Table view score card
-- SET DEFINE OFF;
-- CREATE OR REPLACE VIEW BJKT_PNL_SCORE_CARD_V AS
-- WITH
-- q_mapping ("column_name", "column_desc", "group_number", "is_header", "is_lines", "column_number") AS (
--     -- GROUP 1: Avg. Balance Kredit
--     SELECT 'AVG_BAL_KREDIT',              'Avg. Balance Kredit Retail',                1, 'Y', 'N',  1 FROM DUAL UNION ALL
--     SELECT 'KREDIT_KONVEN',               'Kredit Konven',                             1, 'N', 'N',  2 FROM DUAL UNION ALL
--     SELECT 'KREDIT_KONVEN_KMG',           'KMG',                                       1, 'N', 'Y',  3 FROM DUAL UNION ALL
--     SELECT 'KREDIT_KONVEN_KPR',           'KPR',                                       1, 'N', 'Y',  4 FROM DUAL UNION ALL
--     SELECT 'KREDIT_KONVEN_MIKRO',         'Mikro',                                     1, 'N', 'Y',  5 FROM DUAL UNION ALL
--     SELECT 'KREDIT_KONVEN_UKM',           'UKM',                                       1, 'N', 'Y',  6 FROM DUAL UNION ALL
--     SELECT 'KREDIT_SYARIAH',              'Pembiayaan Syariah',                        1, 'N', 'N',  7 FROM DUAL UNION ALL
--     SELECT 'KREDIT_SYARIAH_KMG',          'KMG',                                       1, 'N', 'Y',  8 FROM DUAL UNION ALL
--     SELECT 'KREDIT_SYARIAH_KPR',          'KPR',                                       1, 'N', 'Y',  9 FROM DUAL UNION ALL
--     SELECT 'KREDIT_SYARIAH_MIKRO',        'Mikro',                                     1, 'N', 'Y', 10 FROM DUAL UNION ALL
--     SELECT 'KREDIT_SYARIAH_UKM',          'UKM',                                       1, 'N', 'Y', 11 FROM DUAL UNION ALL
--     -- GROUP 2: Pendapatan Bunga
--     SELECT 'PEND_BUNGA',                  'Pendapatan Bunga Total',                    2, 'Y', 'N', 12 FROM DUAL UNION ALL
--     SELECT 'BUNGA_KONVEN',                'Pend. Bunga Konven',                        2, 'N', 'N', 13 FROM DUAL UNION ALL
--     SELECT 'BUNGA_KONVEN_KMG',            'KMG',                                       2, 'N', 'Y', 14 FROM DUAL UNION ALL
--     SELECT 'BUNGA_KONVEN_KPR',            'KPR',                                       2, 'N', 'Y', 15 FROM DUAL UNION ALL
--     SELECT 'BUNGA_KONVEN_MIKRO',          'Mikro',                                     2, 'N', 'Y', 16 FROM DUAL UNION ALL
--     SELECT 'BUNGA_KONVEN_UKM',            'UKM',                                       2, 'N', 'Y', 17 FROM DUAL UNION ALL
--     SELECT 'BUNGA_SYARIAH',               'Pend. Bunga Syariah',                       2, 'N', 'N', 18 FROM DUAL UNION ALL
--     SELECT 'BUNGA_SYARIAH_KMG',           'KMG',                                       2, 'N', 'Y', 19 FROM DUAL UNION ALL
--     SELECT 'BUNGA_SYARIAH_KPR',           'KPR',                                       2, 'N', 'Y', 20 FROM DUAL UNION ALL
--     SELECT 'BUNGA_SYARIAH_MIKRO',         'Mikro',                                     2, 'N', 'Y', 21 FROM DUAL UNION ALL
--     SELECT 'BUNGA_SYARIAH_UKM',           'UKM',                                       2, 'N', 'Y', 22 FROM DUAL UNION ALL
--     -- GROUP 3: Avg. Balance DPK
--     SELECT 'AVG_BAL_DPK',                 'Average Balance DPK',                       3, 'Y', 'N', 23 FROM DUAL UNION ALL
--     SELECT 'DPK_KONVEN',                  'DPK Konven',                                3, 'N', 'N', 24 FROM DUAL UNION ALL
--     SELECT 'DPK_KONVEN_GIRO',             'Giro',                                      3, 'N', 'Y', 25 FROM DUAL UNION ALL
--     SELECT 'DPK_KONVEN_TABUNGAN',         'Tabungan',                                  3, 'N', 'Y', 26 FROM DUAL UNION ALL
--     SELECT 'DPK_KONVEN_DEPOSITO',         'Deposito',                                  3, 'N', 'Y', 27 FROM DUAL UNION ALL
--     SELECT 'DPK_SYARIAH',                 'DPK Syariah',                               3, 'N', 'N', 28 FROM DUAL UNION ALL
--     SELECT 'DPK_SYARIAH_GIRO',            'Giro',                                      3, 'N', 'Y', 29 FROM DUAL UNION ALL
--     SELECT 'DPK_SYARIAH_TABUNGAN',        'Tabungan',                                  3, 'N', 'Y', 30 FROM DUAL UNION ALL
--     SELECT 'DPK_SYARIAH_DEPOSITO',        'Deposito',                                  3, 'N', 'Y', 31 FROM DUAL UNION ALL
--     -- GROUP 4: Beban Bunga
--     SELECT 'BEBAN_BUNGA_TOTAL',           'Beban Bunga Total',                         4, 'Y', 'N', 32 FROM DUAL UNION ALL
--     SELECT 'BEBAN_BUNGA_KONVEN',          'Beban Bunga Konven',                        4, 'N', 'N', 33 FROM DUAL UNION ALL
--     SELECT 'BEBAN_BUNGA_KONVEN_GIRO',     'Giro',                                      4, 'N', 'Y', 34 FROM DUAL UNION ALL
--     SELECT 'BEBAN_BUNGA_KONVEN_TABUNGAN', 'Tabungan',                                  4, 'N', 'Y', 35 FROM DUAL UNION ALL
--     SELECT 'BEBAN_BUNGA_KONVEN_DEPOSITO', 'Deposito',                                  4, 'N', 'Y', 36 FROM DUAL UNION ALL
--     SELECT 'BEBAN_BUNGA_SYARIAH',         'Beban Bunga Syariah',                       4, 'N', 'N', 37 FROM DUAL UNION ALL
--     SELECT 'BEBAN_BUNGA_SYARIAH_GIRO',    'Giro',                                      4, 'N', 'Y', 38 FROM DUAL UNION ALL
--     SELECT 'BEBAN_BUNGA_SYARIAH_TABUNGAN','Tabungan',                                  4, 'N', 'Y', 39 FROM DUAL UNION ALL
--     SELECT 'BEBAN_BUNGA_SYARIAH_DEPOSITO','Deposito',                                  4, 'N', 'Y', 40 FROM DUAL UNION ALL
--     -- GROUP 5-7: FTP & NII
--     SELECT 'FTP_INCOME',                  'FTP Income',                                5, 'Y', 'N', 41 FROM DUAL UNION ALL
--     SELECT 'FTP_CHARGE',                  'FTP Charge',                                6, 'Y', 'N', 42 FROM DUAL UNION ALL
--     SELECT 'NII_POST_FTP',                'NII-Post FTP',                              7, 'Y', 'N', 43 FROM DUAL UNION ALL
--     -- GROUP 8: Fee Based Income
--     SELECT 'FBI_TOTAL',                   'Fee Based Income',                          8, 'Y', 'N', 44 FROM DUAL UNION ALL
--     SELECT 'FBI_ACC_MAINT',               'Account Maintenance',                       8, 'N', 'N', 45 FROM DUAL UNION ALL
--     SELECT 'FBI_ATM',                     'ATM',                                       8, 'N', 'N', 46 FROM DUAL UNION ALL
--     SELECT 'FBI_JOM',                     'Mobile Banking (JOM)',                      8, 'N', 'N', 47 FROM DUAL UNION ALL
--     SELECT 'FBI_EDC',                     'EDC',                                       8, 'N', 'N', 48 FROM DUAL UNION ALL
--     SELECT 'FBI_CMS',                     'CMS',                                       8, 'N', 'N', 49 FROM DUAL UNION ALL
--     SELECT 'FBI_ABANK',                   'JakOne Bank',                               8, 'N', 'N', 50 FROM DUAL UNION ALL
--     SELECT 'FBI_JAS_POT',                 'Jasa Pemotongan',                           8, 'N', 'N', 51 FROM DUAL UNION ALL
--     SELECT 'FBI_BISNIS_KARTU',            'Bisnis Kartu',                              8, 'N', 'N', 52 FROM DUAL UNION ALL
--     SELECT 'FBI_BISNIS_SDB',              'Bisnis SDB',                                8, 'N', 'N', 53 FROM DUAL UNION ALL
--     SELECT 'FBI_KIRIM_UANG',              'Kiriman Uang',                              8, 'N', 'N', 54 FROM DUAL UNION ALL
--     SELECT 'FBI_REST_BIAYA_KANTOR',       'Restitusi Biaya Kantor',                    8, 'N', 'N', 55 FROM DUAL UNION ALL
--     SELECT 'FBI_PIN_NAS_PEN',             'Pinalti Nasabah & Penolakan',               8, 'N', 'N', 56 FROM DUAL UNION ALL
--     SELECT 'FBI_BANK_GARANSI',            'Bank Garansi',                              8, 'N', 'N', 57 FROM DUAL UNION ALL
--     SELECT 'FBI_ADMIN_KREDIT',            'Admin Kredit',                              8, 'N', 'N', 58 FROM DUAL UNION ALL
--     SELECT 'FBI_LAINNYA',                 'Lainnya (komisi notaris, denda tunggakan)', 8, 'N', 'N', 59 FROM DUAL UNION ALL
--     -- GROUP 9: Direct OPEX
--     SELECT 'OPEX_TOTAL',                  'Direct OPEX',                                        9, 'Y', 'N', 60 FROM DUAL UNION ALL
--     SELECT 'OPEX_MANPOWER',               'Manpower',                                           9, 'N', 'N', 61 FROM DUAL UNION ALL
--     SELECT 'OPEX_TELECOM',                'IT & Telecommunication',                             9, 'N', 'N', 62 FROM DUAL UNION ALL
--     SELECT 'OPEX_OFFICE_SUPPLIES',        'Office Supplies',                                    9, 'N', 'N', 63 FROM DUAL UNION ALL
--     SELECT 'OPEX_PERJALANAN_DINAS',       'Perjalanan Dinas',                                   9, 'N', 'N', 64 FROM DUAL UNION ALL
--     SELECT 'OPEX_SEWA',                   'Sewa (ATM, kendaraan, bangunan, peralatan, dll.)',   9, 'N', 'N', 65 FROM DUAL UNION ALL
--     SELECT 'OPEX_PREM_INS_NCR',           'Premium Insurance Non-Credit',                       9, 'N', 'N', 66 FROM DUAL UNION ALL
--     SELECT 'OPEX_PREM_AS_CR',             'Premi Asuransi Kredit',                              9, 'N', 'N', 67 FROM DUAL UNION ALL
--     SELECT 'OPEX_TRAN_CR',                'Transaksi Kredit',                                   9, 'N', 'N', 68 FROM DUAL UNION ALL
--     SELECT 'OPEX_TRAN_NCR',               'Transaksi Non Kredit',                               9, 'N', 'N', 69 FROM DUAL UNION ALL
--     -- GROUP 10: CKPN
--     SELECT 'CKPN',                        'Beban CKPN',                               10, 'Y', 'N', 70 FROM DUAL
-- )

-- SELECT /*+ RESULT_CACHE */
--     u."periode",
--     u."kode_cabang",
--     u."nama_cabang",
--     u."kode_konsol",
--     u."nama_konsol",
--     u."column_name",
--     u."nominal",
--     m."column_desc",
--     m."group_number",
--     m."is_header",
--     m."is_lines",
--     m."column_number"

-- FROM (
--     SELECT
--         "periode",
--         "kode_cabang",
--         "nama_cabang",
--         "kode_konsol",
--         "nama_konsol",
--         "column_name",
--         "nominal"
--     FROM BJKT_PNL_SUMMARY_V
--     UNPIVOT INCLUDE NULLS (
--         "nominal" FOR "column_name" IN (
--             "total_kredit"                  AS 'AVG_BAL_KREDIT',
--             "kredit_total_konven"           AS 'KREDIT_KONVEN',
--             "kredit_konven_kmg"             AS 'KREDIT_KONVEN_KMG',
--             "kredit_konven_kpr"             AS 'KREDIT_KONVEN_KPR',
--             "kredit_konven_mikro"           AS 'KREDIT_KONVEN_MIKRO',
--             "kredit_konven_ukm"             AS 'KREDIT_KONVEN_UKM',
--             "kredit_total_syariah"          AS 'KREDIT_SYARIAH',
--             "kredit_syariah_kmg"            AS 'KREDIT_SYARIAH_KMG',
--             "kredit_syariah_kpr"            AS 'KREDIT_SYARIAH_KPR',
--             "kredit_syariah_mikro"          AS 'KREDIT_SYARIAH_MIKRO',
--             "kredit_syariah_ukm"            AS 'KREDIT_SYARIAH_UKM',
--             "total_pen_bunga"               AS 'PEND_BUNGA',
--             "total_bunga_konven"            AS 'BUNGA_KONVEN',
--             "bunga_konven_kmg"              AS 'BUNGA_KONVEN_KMG',
--             "bunga_konven_kpr"              AS 'BUNGA_KONVEN_KPR',
--             "bunga_konven_mikro"            AS 'BUNGA_KONVEN_MIKRO',
--             "bunga_konven_ukm"              AS 'BUNGA_KONVEN_UKM',
--             "total_bunga_syariah"           AS 'BUNGA_SYARIAH',
--             "bunga_syariah_kmg"             AS 'BUNGA_SYARIAH_KMG',
--             "bunga_syariah_kpr"             AS 'BUNGA_SYARIAH_KPR',
--             "bunga_syariah_mikro"           AS 'BUNGA_SYARIAH_MIKRO',
--             "bunga_syariah_ukm"             AS 'BUNGA_SYARIAH_UKM',
--             "total_dpk"                     AS 'AVG_BAL_DPK',
--             "dpk_total_konven"              AS 'DPK_KONVEN',
--             "dpk_konven_giro"               AS 'DPK_KONVEN_GIRO',
--             "dpk_konven_tabungan"           AS 'DPK_KONVEN_TABUNGAN',
--             "dpk_konven_deposito"           AS 'DPK_KONVEN_DEPOSITO',
--             "dpk_total_syariah"             AS 'DPK_SYARIAH',
--             "dpk_syariah_giro"              AS 'DPK_SYARIAH_GIRO',
--             "dpk_syariah_tabungan"          AS 'DPK_SYARIAH_TABUNGAN',
--             "dpk_syariah_deposito"          AS 'DPK_SYARIAH_DEPOSITO',
--             "total_beban_bunga"             AS 'BEBAN_BUNGA_TOTAL',
--             "beban_bunga_konven"            AS 'BEBAN_BUNGA_KONVEN',
--             "beban_bunga_konven_giro"       AS 'BEBAN_BUNGA_KONVEN_GIRO',
--             "beban_bunga_konven_tabungan"   AS 'BEBAN_BUNGA_KONVEN_TABUNGAN',
--             "beban_bunga_konven_deposito"   AS 'BEBAN_BUNGA_KONVEN_DEPOSITO',
--             "beban_bunga_total_syariah"     AS 'BEBAN_BUNGA_SYARIAH',
--             "beban_bunga_syariah_giro"      AS 'BEBAN_BUNGA_SYARIAH_GIRO',
--             "beban_bunga_syariah_tabungan"  AS 'BEBAN_BUNGA_SYARIAH_TABUNGAN',
--             "beban_bunga_syariah_deposito"  AS 'BEBAN_BUNGA_SYARIAH_DEPOSITO',
--             "ftp_income_dpk"                AS 'FTP_INCOME',
--             "ftp_charge_loan"               AS 'FTP_CHARGE',
--             "nii_post_ftp"                  AS 'NII_POST_FTP',
--             "fbi_total"                     AS 'FBI_TOTAL',
--             "fbi_acc_maint"                 AS 'FBI_ACC_MAINT',
--             "fbi_atm"                       AS 'FBI_ATM',
--             "fbi_jom"                       AS 'FBI_JOM',
--             "fbi_edc"                       AS 'FBI_EDC',
--             "fbi_cms"                       AS 'FBI_CMS',
--             "fbi_abank"                     AS 'FBI_ABANK',
--             "fbi_jas_pot"                   AS 'FBI_JAS_POT',
--             "fbi_bisnis_kartu"              AS 'FBI_BISNIS_KARTU',
--             "fbi_bisnis_sdb"                AS 'FBI_BISNIS_SDB',
--             "fbi_kirim_uang"                AS 'FBI_KIRIM_UANG',
--             "fbi_rest_biaya_kantor"         AS 'FBI_REST_BIAYA_KANTOR',
--             "fbi_pin_nas_pen"               AS 'FBI_PIN_NAS_PEN',
--             "fbi_bank_garansi"              AS 'FBI_BANK_GARANSI',
--             "fbi_admin_kredit"              AS 'FBI_ADMIN_KREDIT',
--             "fbi_lainnya"                   AS 'FBI_LAINNYA',
--             "dir_opex_total"                AS 'OPEX_TOTAL',
--             "dir_opex_manpower"             AS 'OPEX_MANPOWER',
--             "dir_opex_telecom"              AS 'OPEX_TELECOM',
--             "dir_opex_ofc_sup"              AS 'OPEX_OFFICE_SUPPLIES',
--             "dir_opex_per_din"              AS 'OPEX_PERJALANAN_DINAS',
--             "dir_opex_sewa"                 AS 'OPEX_SEWA',
--             "dir_opex_prem_ins_ncr"         AS 'OPEX_PREM_INS_NCR',
--             "dir_opex_prem_as_cr"           AS 'OPEX_PREM_AS_CR',
--             "dir_opex_tran_cr"              AS 'OPEX_TRAN_CR',
--             "dir_opex_tran_ncr"             AS 'OPEX_TRAN_NCR',
--             "ckpn_nominal"                  AS 'CKPN'
--         )
--     )
-- ) u
-- JOIN q_mapping m ON m."column_name" = u."column_name"

-- ORDER BY
--     u."periode",
--     u."kode_cabang",
--     m."column_number";
-- /

-- CREATE OR REPLACE VIEW BJKT_PNL_SCORE_CARD_SUB_V AS
-- SELECT
--     pbt."periode"       AS "periode",
--     pbt."kode_cabang",
--     pbt."nama_cabang",
--     pbt."kode_konsol",
--     pbt."nama_konsol",

--     TO_CHAR(
--         (((pbt."total_pen_bunga" + fc."ftp_charge_loan") / cre."total_kredit") * 100, 1),
--         'FM9999999990.0'
--     ) AS "interest_income",

--     (((pbt."total_pen_bunga" + fc."ftp_charge_loan") / cre."total_kredit"), 3)
--         AS "interest_income_val",

--     TO_CHAR(
--         (((bbt."total_beban_bunga" + fi."ftp_income_dpk") / dpk."total_dpk") * 100, 1),
--         'FM9999999990.0'
--     ) AS "cost_of_fund",

--     (((bbt."total_beban_bunga" + fi."ftp_income_dpk") / dpk."total_dpk"), 3)
--         AS "cost_of_fund_val",

--     TO_CHAR(
--         (cre."total_kredit" / (cre."total_kredit" + dpk."total_dpk") * 100, 1),
--         'FM9999999990.0'
--     ) AS "kredit_portofolio",

--     (cre."total_kredit" / (cre."total_kredit" + dpk."total_dpk"), 3)
--         AS "kredit_portofolio_val",
    
--     (fbi."fbi_total" + nii."nii_post_ftp") 
--         AS "total_income"
-- FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV pbt
-- LEFT JOIN BJKT_PNL_AVG_BAL_CREDIT_MV cre
--     ON  cre."kode_cabang" = pbt."kode_cabang"
--     AND cre."periode"     = pbt."periode" 
-- LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
--     ON  dpk."kode_cabang" = pbt."kode_cabang"
--     AND dpk."periode"     = pbt."periode"
-- LEFT JOIN BJKT_PNL_BEBAN_BUNGA_TOTAL_MV bbt
--     ON  bbt."kode_cabang" = pbt."kode_cabang"
--     AND bbt."periode"     = pbt."periode"
-- LEFT JOIN BJKT_PNL_FTP_CHARGE_MV fc
--     ON  fc."kode_cabang" = pbt."kode_cabang"
--     AND fc."periode"     = pbt."periode"
-- LEFT JOIN BJKT_PNL_FTP_INCOME_MV fi
--     ON  fi."kode_cabang" = pbt."kode_cabang"
--     AND fi."periode"     = pbt."periode"
-- LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV fbi
--     ON  fbi."kode_cabang" = pbt."kode_cabang"
--     AND fbi."periode"     = pbt."periode"
-- LEFT JOIN BJKT_PNL_NII_POST_FTP_MV nii
--     ON  nii."kode_cabang" = pbt."kode_cabang"
--     AND nii."periode"     = pbt."periode";
-- /