-- KREDIT
    SELECT
        "periode",
        "cabang",
        "nama_kantor_akhir",

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
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah' OR "padanan" = 'DBLM' THEN "avg" ELSE NULL END) / POWER(10,6))        
            AS "kredit_total_syariah",
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah' OR "padanan" = 'DBLM'
                        AND "kategori_segment" = 'KMG' THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_syariah_kmg",
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah' OR "padanan" = 'DBLM'
                        AND "kategori_segment" = 'KPR' THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_syariah_kpr",
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah' OR "padanan" = 'DBLM'
                        AND "tipe_segment" = 'Mikro' THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_syariah_mikro",
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah' OR "padanan" = 'DBLM'
            AND "tipe_segment" = 'UKM' THEN "avg" ELSE NULL END) / POWER(10,6))  AS "kredit_syariah_ukm"

    FROM BJKT_PNL_LOAN_AVG_SY
    WHERE
            "cabang"  = '108'
        AND "periode" = '2026-03-31'
        AND (
                "kategori_segment" IN ('KMG', 'KPR')
             OR "tipe_segment"     IN ('Mikro', 'UKM')
            )
    GROUP BY
        "periode",
        "cabang",
        "nama_kantor_akhir"
;
/

-- DPK
    SELECT
        "periode",
        "cabang",
        "nama_kantor_akhir",

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
        ROUND(SUM(CASE WHEN "produk" = 'Syariah' OR "produk" = 'DBLM' THEN "avg" ELSE NULL END) / POWER(10,6))        
            AS "dpk_total_syariah",
        ROUND(SUM(CASE WHEN "produk" = 'Syariah' OR "produk" = 'DBLM'
                        AND "kategori" = 'Giro' THEN "avg" ELSE NULL END) / POWER(10,6))    
            AS "dpk_syariah_giro",
        ROUND(SUM(CASE WHEN "produk" = 'Syariah' OR "produk" = 'DBLM'
                        AND "kategori" = 'Tabungan' THEN "avg" ELSE NULL END) / POWER(10,6))    
            AS "dpk_syariah_tabungan",
        ROUND(SUM(CASE WHEN "produk" = 'Syariah' OR "produk" = 'DBLM'
                        AND "kategori" = 'Deposito' THEN "avg" ELSE NULL END) / POWER(10,6))    
            AS "dpk_syariah_deposito"

    FROM BJKT_PNL_DPK_AVG_SY
    WHERE
            "cabang"  = '108'
        AND "periode" = '2026-03-31'
        AND "kategori" IN ('Giro', 'Tabungan', 'Deposito')
    GROUP BY
        "periode",
        "cabang",
        "nama_kantor_akhir"
;
/

SET DEFINE OFF;
-- Direct OPEX
    SELECT
        "periode",
        "kode_cabang_akhir" AS "cabang",
        -- ABS(ROUND(SUM(
        --     CASE WHEN "ket_final" IN (
        --         'Manpower',
        --         'IT & Telecommunication',
        --         'Office Supplies',
        --         'Perjalanan Dinas',
        --         'Premium Insurance Non-Credit',
        --         'Premi Asuransi Kredit',
        --         'Transaksi Kredit',
        --         'Transaksi Non Kredit'
        --     ) THEN "nominal" END
        -- ) / POWER(10,6))) "dir_total_opex",
        ROUND(SUM("nominal") / POWER(10,6)) AS "dir_total_opex",
        ROUND(SUM(CASE WHEN "ket_final" = 'Manpower' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_manpower",
        ROUND(SUM(CASE WHEN "ket_final" = 'IT & Telecommunication' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_telecom",
        ROUND(SUM(CASE WHEN "ket_final" = 'Office Supplies' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_ofc_sup",
        -- Add column sewa atm here
        ROUND(SUM(CASE WHEN "ket_final" = 'Perjalanan Dinas' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_per_din",
        ROUND(SUM(CASE WHEN "ket_final" = 'Premium Insurance Non-Credit' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_prem_ins_ncr",
        ROUND(SUM(CASE WHEN "ket_final" = 'Premi Asuransi Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_prem_as_cr",
        ROUND(SUM(CASE WHEN "ket_final" = 'Transaksi Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_tran_cr",
        (SUM(CASE WHEN "ket_final" = 'Transaksi Non Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_tran_ncr"
    FROM BJKT_PNL_GL_V2_SY
    WHERE 
            "kode_cabang_akhir" = '108'
        -- AND "periode" = '2026-03-31'
    GROUP BY "periode", "kode_cabang_akhir"
;

select * from BJKT_PNL_GL_V2_SY where "kode_cabang_akhir" = '108' AND "ket_final" = 'Transaksi Non Kredit'
/

-- Beban CKPN
    SELECT
        "kode_cabang" "cabang",
        ROUND(SUM("nom_ckpn") / POWER(10,6)) "ckpn_nominal"
    FROM BJKT_PNL_CKPN_SY
    WHERE
            "kode_cabang" = '108'
        AND "tipe_segment" IN ('Konsumer', 'Mikro', 'UKM')
        AND "produk" = 'Konven'
    GROUP BY "kode_cabang"
;
/

-- Pend. Bunga
    SELECT
        "periode",
        "cabang",
        "nama_kantor_akhir",

        ROUND(SUM("pendapatan_bunga") / POWER(10,6))                                                             
            AS "total_pen_bunga",

        -- KONVEN
        ROUND(SUM(CASE WHEN "padanan" = 'Konven' THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))           
            AS "total_bunga_konven",
        ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                        AND "kategori_segment" = 'KMG'  THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_konven_kmg",
        ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                        AND "kategori_segment" = 'KPR'  THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_konven_kpr",
        ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                        AND "tipe_segment"    = 'Mikro' THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_konven_mikro",
        ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                        AND "tipe_segment"    = 'UKM'   THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_konven_ukm",

        -- SYARIAH
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah' OR "padanan" = 'DBLM' THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))          
            AS "total_bunga_syariah",
        ROUND(SUM(CASE WHEN ("padanan" = 'Syariah' OR "padanan" = 'DBLM')
                        AND "kategori_segment" = 'KMG'  THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_syariah_kmg",
        ROUND(SUM(CASE WHEN ("padanan" = 'Syariah' OR "padanan" = 'DBLM')
                        AND "kategori_segment" = 'KPR'  THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_syariah_kpr",
        ROUND(SUM(CASE WHEN ("padanan" = 'Syariah' OR "padanan" = 'DBLM')
                        AND "tipe_segment"    = 'Mikro' THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_syariah_mikro",
        ROUND(SUM(CASE WHEN ("padanan" = 'Syariah' OR "padanan" = 'DBLM')
                        AND "tipe_segment"    = 'UKM'   THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_syariah_ukm"
    FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
    WHERE
            "cabang" = '108'
        AND "periode" = '2026-03-31'
        AND (
                "kategori_segment" IN ('KMG', 'KPR')
            OR  "tipe_segment"     IN ('Mikro', 'UKM')
            )
    GROUP BY
        "periode",
        "cabang",
        "nama_kantor_akhir"
;
/

-- FTP Income
    SELECT
        "periode",
        "cabang",
        "nama_kantor_akhir",
        ROUND("ftp_income_dpk" / POWER(10, 6)) AS "ftp_income_dpk"
    FROM BJKT_PNL_INCOME_DPK_SY
    WHERE 
            "cabang" = '108'
        AND "periode" = '2026-03-31'
;
/

-- FTP Charge
SELECT 
    "periode",
    "kode_cabang_akhir",
    "nama_kantor_akhir",
    ABS(ROUND("ftp_charge_loan" / POWER(10, 6))) AS "ftp_charge_loan"
FROM BJKT_PNL_CHARGE_LOAN_SY
WHERE
        "kode_cabang_akhir" = '108'
    AND "periode" = '2026-03-31'
;
/

-- Beban Bunga
SELECT
    "periode",
    "cabang",
    "nama_kantor_akhir",

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
WHERE
        "cabang"  = '108'
    -- AND "periode" = '2026-03-31'
    AND "kategori" IN ('Giro', 'Tabungan', 'Deposito')
GROUP BY
    "periode",
    "cabang",
    "nama_kantor_akhir"
;
/

-- NII-Post FTP
WITH
pend_bunga AS (
    SELECT
        "periode",
        "cabang",
        SUM("pendapatan_bunga") / POWER(10,6) AS "total_pen_bunga"
    FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
    WHERE "kategori_segment" IN ('KMG', 'KPR') OR "tipe_segment" IN ('Mikro', 'UKM')
    GROUP BY "periode", "cabang"
),
beban_bunga AS (
    SELECT 
        "periode",
        "cabang",
        SUM("beban_bunga") / POWER(10,6) AS "total_beban_bunga"
    FROM BJKT_PNL_BEBAN_BUNGA_SY
    WHERE "kategori" IN ('Giro', 'Tabungan', 'Deposito')
    GROUP BY "periode", "cabang"
),
ftp_charge AS (
    SELECT 
        "periode",
        "kode_cabang_akhir" AS "cabang",
        ("ftp_charge_loan" / POWER(10, 6)) AS "ftp_charge_loan"
    FROM BJKT_PNL_CHARGE_LOAN_SY
),
ftp_income AS (
    SELECT
        "periode",
        "cabang",
        "nama_kantor_akhir",
        ("ftp_income_dpk" / POWER(10, 6)) AS "ftp_income_dpk"
    FROM BJKT_PNL_INCOME_DPK_SY
)
SELECT
    bb."cabang",
    bb."total_beban_bunga",
    pb."total_pen_bunga",
    fc."ftp_charge_loan",
    fi."ftp_income_dpk",
    ROUND (
        NVL(bb."total_beban_bunga", 0)
      + NVL(pb."total_pen_bunga", 0)
      + NVL(fc."ftp_charge_loan", 0)
      + NVL(fi."ftp_income_dpk", 0)
    ) AS "nii_post_ftp"
FROM 
    beban_bunga bb
LEFT JOIN pend_bunga pb
    ON  bb."cabang" = pb."cabang"
    AND bb."periode" = pb."periode"
LEFT JOIN ftp_charge fc
    ON  bb."cabang"  = fc."cabang"
    AND bb."periode" = fc."periode"
LEFT JOIN ftp_income fi
    ON  bb."cabang"  = fi."cabang"
    AND bb."periode" = fi."periode"
WHERE
    bb."cabang" = '108' and bb."periode" = '2026-03-31'
;
/

-- Fee Based Income
SET DEFINE OFF;
/
SELECT 
    "kode_cabang_akhir",

    ROUND(SUM("fbi") / POWER(10,6)) 
        AS "fbi_total",
    SUM(CASE WHEN "nama" = 'Account Maintenance' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_acc_maint",
    SUM(CASE WHEN "nama" = 'ATM FBI' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_atm",
    SUM(CASE WHEN "nama" = 'JakOne Mobile FBI' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_jom",
    -- add column edc here
    SUM(CASE WHEN "nama" = 'CMS' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_cms",
    SUM(CASE WHEN "nomor_rekening" = '432003602100' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_jas_pot",
    SUM(CASE WHEN "nama" = 'Bisnis Kartu' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_bisnis_kartu",
    SUM(CASE WHEN "nama" = 'Bisnis SDB' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_bisnis_sdb",
    SUM(CASE WHEN "nama" = 'Kiriman Uang (RTGS, kliring, dll.)' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_kirim_uang",
    SUM(CASE WHEN "nama" = 'RESTITUSI BIAYA KANTOR' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_rest_biaya_kantor",
    SUM(CASE WHEN "nama" = 'Pinalty Nasabah & Penolakan' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_pin_nas_pen",
    -- add column sindikasi here
    -- add column trade finance here
    SUM(CASE WHEN "nama" = 'BANK GARANSI' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_bank_garansi",
    SUM(CASE WHEN "nama" = 'Admin Kredit' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_admin_kredit",
    SUM(CASE WHEN "nama" = 'Kerjasama Pihak Lain (komisi agen, asuransi)' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_ker_pihak_lain",
    -- add column dividen reksa dana here
    -- add column dividen M2M Forex & SB here
    SUM(CASE WHEN "nama" = 'Lainnya (komisi notaris, denda tunggakan)' THEN "fbi" ELSE NULL END) / POWER(10,6)
        AS "fbi_lainnya"
    -- add column collection recovery income here
FROM BJKT_PNL_FBI_SY
WHERE
        "kode_cabang_akhir" = '108'
    AND "periode" = '2026-03-31'
GROUP BY 
    "kode_cabang_akhir"
;

SELECT 
    -- SUM("fbi") total_fbi,
    *
FROM BJKT_PNL_FBI_SY 
WHERE "kode_cabang_akhir" = '108' 
    AND "nama" = 'ATM FBI';