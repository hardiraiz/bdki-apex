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
        ABS(ROUND(SUM(
            CASE WHEN "ket_final" IN (
                'Manpower',
                'IT & Telecommunication',
                'Office Supplies',
                'Perjalanan Dinas',
                'Premium Insurance Non-Credit',
                'Premi Asuransi Kredit',
                'Transaksi Kredit',
                'Transaksi Non Kredit'
            ) THEN "nominal" END
        ) / POWER(10,6))) "dir_total_opex",
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
        ROUND(SUM(CASE WHEN "ket_final" = 'Transaksi Non Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_tran_ncr"
    FROM BJKT_PNL_GL_V2_SY
    WHERE 
            "kode_cabang_akhir" = '108'
        AND "periode" = '2026-03-31'
    GROUP BY "periode", "kode_cabang_akhir"
;
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
    -- "periode",
    -- "cabang",
    -- "nama_kantor_akhir",
    -- ABS(ROUND("ftp_charge_loan" / POWER(10, 6))) AS "ftp_charge_loan"
    *
FROM BJKT_PNL_CHARGE_LOAN_SY
-- WHERE
--         "cabang" = '108'
--     AND "periode" = '2026-03-31'
;
/

-- Fee Based Income
