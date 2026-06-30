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

        SUM(CASE WHEN "nama" = 'ATM'
                 THEN "fbi" END) AS "fbi_atm",

        SUM(CASE WHEN "nama" = 'JakOne Mobile'
                 THEN "fbi" END) AS "fbi_jom",

        SUM(CASE WHEN "nama" = 'EDC'
                 THEN "fbi" END) AS "fbi_edc",

        SUM(CASE WHEN "nama" = 'CMS'
                 THEN "fbi" END) AS "fbi_cms",

        SUM(CASE WHEN "nama" = 'ABANK'
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
        NVL(SUM(CASE WHEN o."ket_final" = 'Manpower'
                     THEN o."nominal" END), 0)  AS "manpower_raw",
        NVL(SUM(CASE WHEN o."ket_final" = 'IT & Telecommunication'
                     THEN o."nominal" END), 0)  AS "telecom_raw",
        NVL(SUM(CASE WHEN o."ket_final" = 'Office Supplies'
                     THEN o."nominal" END), 0)  AS "off_sup_raw",
        NVL(sw."sewa_raw", 0)                   AS "sewa_raw",
        NVL(SUM(CASE WHEN o."ket_final" = 'Perjalanan Dinas'
                     THEN o."nominal" END), 0)  AS "per_dinas_raw",
        NVL(SUM(CASE WHEN o."ket_final" = 'Premium Insurance Non-Credit'
                     THEN o."nominal" END), 0)  AS "prem_ins_ncr_raw",
        NVL(pk."premi_kredit_raw",  0)          AS "prem_ins_cr_raw",
        NVL(sc."trans_kredit_raw",  0)          AS "trans_kredit_raw",
        NVL(sc."trans_non_kredit_raw", 0)       AS "trans_non_kredit_raw"
    FROM BJKT_PNL_GL_V2_SY o
    LEFT JOIN sewa_raw        sw ON o."kode_cabang_akhir" = sw."kode_cabang_akhir"
    LEFT JOIN scorecard       sc ON o."kode_cabang_akhir" = sc."kode_cabang_akhir"
    LEFT JOIN premi_kredit    pk ON o."kode_cabang_akhir" = pk."kode_cabang_akhir"
    GROUP BY
        o."periode",
        o."kode_cabang_akhir",
        o."kode_konsol",
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
FROM hasil_utama
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
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "kode_cabang"                       AS "kode_cabang",
    "kode_konsol",
    (SUM("nominal_ckpn"))               AS "ckpn_nominal"
FROM BJKT_PNL_CKPN_SY
WHERE "tipe_segment" <> 'Commercial'
GROUP BY "periode", "kode_konsol", "kode_cabang";
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
    TO_DATE("periode", 'YYYY-MM-DD')    AS "periode",
    "kode_cabang"                       AS "kode_cabang",
    "kode_konsol",
    (SUM("nominal_ckpn"))               AS "ckpn_nominal"
FROM BJKT_PNL_CKPN_SY
GROUP BY "periode", "kode_cabang", "kode_konsol";
/
CREATE INDEX BJKT_PNL_BEBAN_CKPN_TOT_MV_I1 ON BJKT_PNL_BEBAN_CKPN_TOT_MV("periode", "kode_cabang");
/