SET DEFINE OFF;

WITH
-- Credit
cte_kredit AS (
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
),
-- DPK
cte_dpk AS (
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
            "cabang"  = '108'
        AND "periode" = '2026-03-31'
        AND "kategori" IN ('Giro', 'Tabungan', 'Deposito')
    GROUP BY
        "periode",
        "cabang",
        "nama_kantor_akhir"
),
-- Direct OPEX
cte_dir_opx AS (
    SELECT
        "periode",
        "kode_cabang_akhir" AS "cabang",
        ABS(ROUND(SUM(CASE WHEN "ket_final" = 'Manpower' THEN "nominal" ELSE NULL END) / POWER(10,6)))
            AS "dir_opex_manpower",
        ABS(ROUND(SUM(CASE WHEN "ket_final" = 'IT & Telecommunication' THEN "nominal" ELSE NULL END) / POWER(10,6)))
            AS "dir_opex_telecom",
        ABS(ROUND(SUM(CASE WHEN "ket_final" = 'Office Supplies' THEN "nominal" ELSE NULL END) / POWER(10,6)))
            AS "dir_opex_ofc_sup",
        -- Add column sewa atm here
        ABS(ROUND(SUM(CASE WHEN "ket_final" = 'Perjalanan Dinas' THEN "nominal" ELSE NULL END) / POWER(10,6)))
            AS "dir_opex_per_din",
        ABS(ROUND(SUM(CASE WHEN "ket_final" = 'Premium Insurance Non-Credit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
            AS "dir_opex_prem_ins_ncr",
        ABS(ROUND(SUM(CASE WHEN "ket_final" = 'Premi Asuransi Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
            AS "dir_opex_prem_as_cr",
        ABS(ROUND(SUM(CASE WHEN "ket_final" = 'Transaksi Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
            AS "dir_opex_tran_cr",
        ABS(ROUND(SUM(CASE WHEN "ket_final" = 'Transaksi Non Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6)))
            AS "dir_opex_tran_ncr"
    FROM BJKT_PNL_GL_V2_SY
    WHERE 
            "kode_cabang_akhir" = '108'
        AND "periode" = '2026-03-31'
    GROUP BY "periode", "kode_cabang_akhir"
),
-- CKPN
cte_beb_ckpn AS (
    SELECT
        "kode_cabang" "cabang",
        ABS(ROUND(SUM("nom_ckpn") / POWER(10,6))) "ckpn_nominal"
    FROM BJKT_PNL_CKPN_SY
    WHERE
            "kode_cabang" = '108'
        AND "tipe_segment" IN ('Konsumer', 'Mikro', 'UKM')
        AND "produk" = 'Konven'
    GROUP BY "kode_cabang"
),
-- Pend. Bunga
cte_pen_bunga AS (
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
                        AND "tipe_segment"     = 'Mikro' THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_konven_mikro",
        ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                        AND "tipe_segment"     = 'UKM'   THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_konven_ukm",

        -- SYARIAH
        ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM') THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))          
            AS "total_bunga_syariah",
        ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                        AND "kategori_segment" = 'KMG'  THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_syariah_kmg",
        ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                        AND "kategori_segment" = 'KPR'  THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_syariah_kpr",
        ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                        AND "tipe_segment"     = 'Mikro' THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
            AS "bunga_syariah_mikro",
        ROUND(SUM(CASE WHEN "padanan" IN ('Syariah', 'DBLM')
                        AND "tipe_segment"     = 'UKM'   THEN "pendapatan_bunga" ELSE NULL END) / POWER(10,6))    
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
),
-- FTP Income
cte_ftp_income AS (
    SELECT
        "periode",
        "cabang",
        "nama_kantor_akhir",
        ROUND("ftp_income_dpk" / POWER(10, 6)) AS "ftp_income_dpk"
    FROM BJKT_PNL_INCOME_DPK_SY
    WHERE 
            "cabang" = '108'
        AND "periode" = '2026-03-31'
),
-- FTP Charge Loan
cte_ftp_charge AS (
    SELECT 
        "periode",
        "kode_cabang_akhir",
        "nama_kantor_akhir",
        ABS(ROUND("ftp_charge_loan" / POWER(10, 6))) AS "ftp_charge_loan"
    FROM BJKT_PNL_CHARGE_LOAN_SY
    WHERE
            "kode_cabang_akhir" = '108'
        AND "periode" = '2026-03-31'
)

-- Main Query
SELECT
    cre."periode",
    cre."cabang",
    cre."nama_kantor_akhir",

    -- Kredit
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

    -- DPK
    dpk."total_dpk",
    dpk."dpk_total_konven",
    dpk."dpk_konven_giro",
    dpk."dpk_konven_tabungan",
    dpk."dpk_konven_deposito",
    dpk."dpk_total_syariah",
    dpk."dpk_syariah_giro",
    dpk."dpk_syariah_tabungan",
    dpk."dpk_syariah_deposito",

    -- PEND. BUNGA
    cpb."total_pen_bunga",
    cpb."total_bunga_konven",
    cpb."bunga_konven_kmg",
    cpb."bunga_konven_kpr",
    cpb."bunga_konven_mikro",
    cpb."bunga_konven_ukm",
    cpb."total_bunga_syariah",
    cpb."bunga_syariah_kmg",
    cpb."bunga_syariah_kpr",
    cpb."bunga_syariah_mikro",
    cpb."bunga_syariah_ukm",

    -- FTP Income
    cfi."ftp_income_dpk",

    -- FTP Charge Loan
    cfc."ftp_charge_loan",

    -- DIRECT OPEX
    opx."dir_opex_manpower",
    opx."dir_opex_telecom",
    opx."dir_opex_ofc_sup",
        -- Add column sewa atm here
    opx."dir_opex_per_din",
    opx."dir_opex_prem_ins_ncr",
    opx."dir_opex_prem_as_cr",
    opx."dir_opex_tran_cr",
    opx."dir_opex_tran_ncr",

    -- Beban CKPN
    bck."ckpn_nominal"

FROM cte_kredit cre
LEFT JOIN cte_dpk dpk
    ON  cre."periode" = dpk."periode"
    AND cre."cabang"  = dpk."cabang"
LEFT JOIN cte_pen_bunga cpb
    ON  cre."periode" = cpb."periode"
    AND cre."cabang"  = cpb."cabang"
LEFT JOIN cte_dir_opx opx
    ON  cre."periode" = opx."periode"
    AND cre."cabang"  = dpk."cabang"
LEFT JOIN cte_beb_ckpn bck
    ON cre."cabang" = bck."cabang"
LEFT JOIN cte_ftp_income cfi
    ON  cre."periode" = cfi."periode"
    AND cre."cabang" = cfi."cabang"
LEFT JOIN cte_ftp_charge cfc
    ON  cre."periode" = cfc."periode"
    AND cre."cabang" = cfc."cabang"
ORDER BY
    cre."nama_kantor_akhir";
/