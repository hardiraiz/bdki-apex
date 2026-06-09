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
        -- ROUND(SUM("nominal") / POWER(10,6)) AS "dir_total_opex",
        ROUND(SUM(CASE WHEN "ket_final" = 'Manpower' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_manpower",
        ROUND(SUM(CASE WHEN "ket_final" = 'IT & Telecommunication' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_telecom",
        ROUND(SUM(CASE WHEN "ket_final" = 'Office Supplies' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_ofc_sup",
        ROUND(SUM(CASE WHEN "ket_final" = 'Sewa (kendaraan, bangunan, peralatan, dll.)' AND "ket_4" = 'Direct' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_ofc_sup",
        ROUND(SUM(CASE WHEN "ket_final" = 'Perjalanan Dinas' AND "ket_4" = 'Direct' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_per_din",
        ROUND(SUM(CASE WHEN "ket_final" = 'Premium Insurance Non-Credit' AND "ket_4" = 'Direct' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_prem_ins_ncr",
        ROUND(SUM(CASE WHEN "ket_final" = 'Premi Asuransi Kredit' AND "ket_4" = 'Direct' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_prem_as_cr",
        ROUND(SUM(CASE WHEN "ket_final" = 'Transaksi Kredit' AND "ket_4" = 'Direct' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_tran_cr",
        (SUM(CASE WHEN "ket_final" = 'Transaksi Non Kredit' AND "ket_3" = 'Beban Transaksi Non Kredit' THEN "nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_tran_ncr"
    FROM BJKT_PNL_GL_V2_SY
    WHERE 
            "kode_cabang_akhir" = '108'
        -- AND "periode" = '2026-03-31'
    GROUP BY "periode", "kode_cabang_akhir"
;

-- Direc OPEX New
WITH
-- CTE 1: Sewa - data cabang pusat (porsi)
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

-- CTE 2: Sewa - porsi distribusi
sewa_porsi AS (
    SELECT DISTINCT *
    FROM BJKT_PNL_DIRECT_PORSI_SY dp
    WHERE dp."porsi" <> '-'
),

-- CTE 3: Sewa - hitung nomxporsi RAW
sewa_nomxporsi AS (
    SELECT
        a."nomor_rekening",
        b."keterangan",
        SUM(a."nom")                            AS "nominal_gl",
        CAST(b."porsi" AS NUMBER)               AS "porsi",
        SUM(a."nom") * CAST(b."porsi" AS NUMBER) AS "nomxporsi_raw"
    FROM sewa_opex_pusat a
    LEFT JOIN sewa_porsi b ON a."nomor_rekening" = b."nomor_rekening"
    GROUP BY a."nomor_rekening", b."keterangan", CAST(b."porsi" AS NUMBER)
),

-- CTE 4: Sewa - nominal GL cabang non-pusat (RAW)
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

-- CTE 5: Sewa - direct cabang
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

-- CTE 6: Sewa - hasil RAW per cabang
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

-- CTE 7: Lainnya - data cabang pusat
opex_pusat AS (
    SELECT
        pg."kode_cabang_akhir",
        pg."nomor_rekening",
        pg."ket_final",
        pg."nom"
    FROM BJKT_PNL_OPEX_V2_SY pg
    WHERE pg."ket_final" = 'Lainnya (BBM Operasional, Pembayaran pajak, dll.)'
),

-- CTE 8: Lainnya - cabang pusat filter
opex_cabang_pusat AS (
    SELECT * FROM opex_pusat
    WHERE SUBSTR("kode_cabang_akhir", 1, 1) IN ('9', '0')
       OR "kode_cabang_akhir" = '700'
),

-- CTE 9: Lainnya - cabang non-pusat
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

-- CTE 10: Porsi transaksi
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

-- CTE 11: Direct cabang transaksi
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

-- CTE 12: nomxporsi transaksi RAW
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

-- CTE 13: Nominal GL per cabang per keterangan transaksi
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

-- CTE 14: Manpower & Telecom RAW
gl_summary AS (
    SELECT
        g."kode_cabang_akhir",
        SUM(CASE WHEN g."ket_final" = 'Manpower'
                 THEN g."nominal" END)              AS "manpower_raw",
        SUM(CASE WHEN g."ket_final" = 'IT & Telecommunication'
                 THEN g."nominal" END)              AS "telecom_raw"
    FROM BJKT_PNL_GL_V2_SY g
    WHERE g."ket_final" IN ('Manpower', 'IT & Telecommunication')
    GROUP BY g."kode_cabang_akhir"
),

-- CTE 15: Scorecard transaksi kredit & non kredit RAW
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

-- CTE 16: Premi asuransi kredit RAW
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

-- CTE 17: Gabung semua nilai RAW
hasil_utama AS (
    SELECT
        TO_DATE(o."periode", 'YYYY-MM-DD')      AS "periode",
        o."kode_cabang_akhir"                   AS "kode_cabang",
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
    WHERE o."kode_cabang_akhir" = '108'
    GROUP BY
        o."periode",
        o."kode_cabang_akhir",
        g."manpower_raw",
        g."telecom_raw",
        sw."sewa_raw",
        pk."premi_kredit_raw",
        sc."trans_kredit_raw",
        sc."trans_non_kredit_raw"
)

-- SELECT akhir: ROUND hanya satu kali di sini
SELECT
    "periode",
    "kode_cabang",
    ROUND(
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
        ) / POWER(10, 6))                           AS "total_dir_opex",
    ROUND("manpower_raw"          / POWER(10, 6))   AS "dir_opex_manpower",
    ROUND("telecom_raw"           / POWER(10, 6))   AS "dir_opex_telecom",
    ROUND("off_sup_raw"           / POWER(10, 6))   AS "dir_opex_off_sup",
    ROUND("sewa_raw"              / POWER(10, 6))   AS "dir_opex_sewa",
    ROUND("per_dinas_raw"         / POWER(10, 6))   AS "dir_opex_beb_per_dinas",
    ROUND("prem_ins_ncr_raw"      / POWER(10, 6))   AS "dir_opex_prem_ins_ncr",
    ROUND("prem_ins_cr_raw"       / POWER(10, 6))   AS "dir_opex_prem_ins_cr",
    ROUND("trans_kredit_raw"      / POWER(10, 6))   AS "dir_opex_trans_kredit",
    ROUND("trans_non_kredit_raw"  / POWER(10, 6))   AS "dir_opex_trans_non_kredit"

FROM hasil_utama
ORDER BY "periode";
/

select * from BJKT_PNL_GL_V2_SY where "kode_cabang_akhir" = '108' AND "ket_final" LIKE '%S%';
select distinct "ket_final" from BJKT_PNL_GL_V2_SY;
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


-- DIRECT OPEX (NEW)
-- Sintaks Direct OPEX (Sewa)
SELECT 
    a."attribute" AS "kode_cabang",
    ROUND((SUM(FLOOR(b."nomxporsi" * CAST(a."value" AS NUMBER))) + c."nominal_gl_cabang") / POWER(10,6)) AS "dir_opex_sewa"
FROM (
    SELECT DISTINCT * 
    FROM BJKT_PNL_DIRECT_CABANG_SY pip 
    WHERE pip."keterangan" IN (
        'Beban Pny Aset Sw Prbt-Plkp Ktr I Oto',
        'Beban Bng Pnyst Aset Sw Kpd Pihak Berelasi',
        'Beban Sewa ATM'
    )
) a
LEFT JOIN (
    SELECT 
        a."nomor_rekening",
        b."keterangan",
        SUM(a."nom") AS "nominal_gl",
        CAST(b."porsi" AS NUMBER) AS "porsi",
        SUM(a."nom") * CAST(b."porsi" AS NUMBER) AS "nomxporsi"
    FROM (
        SELECT * 
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
    ) a
    LEFT JOIN (
        SELECT DISTINCT * 
        FROM BJKT_PNL_DIRECT_PORSI_SY dp 
        WHERE dp."porsi" <> '-'
    ) b ON a."nomor_rekening" = b."nomor_rekening"
    GROUP BY a."nomor_rekening", b."keterangan", CAST(b."porsi" AS NUMBER)
) b ON a."keterangan" = b."keterangan"
LEFT JOIN (
    SELECT 
        pg."kode_cabang_akhir",
        SUM(pg."nom") AS "nominal_gl_cabang"
    FROM BJKT_PNL_OPEX_V2_SY pg
    WHERE pg."ket_final" = 'Sewa (kendaraan, bangunan, peralatan, dll.)'
    AND (
        SUBSTR(pg."kode_cabang_akhir", 1, 1) NOT IN ('9', '0') 
        OR pg."kode_cabang_akhir" <> '700'
    )
    GROUP BY pg."kode_cabang_akhir"
    ORDER BY pg."kode_cabang_akhir"
) c ON a."attribute" = c."kode_cabang_akhir"
WHERE a."attribute" = '108'
GROUP BY a."attribute", c."nominal_gl_cabang";
/
-- Direct OPEX (Premi Asuransi Kredit, Transaksi Kredit, Transaksi Non Kredit)
SELECT
    a."attribute" AS "kode_cabang",
    b."keterangan1",
    ROUND(FLOOR(b."nomxporsi" * TO_NUMBER(a."value")) / POWER(10,6))
    + ROUND(FLOOR(d."nominal_gl_cabang") / POWER(10,6)) AS "angka_scorecard"
FROM (
    SELECT DISTINCT *
    FROM BJKT_PNL_DIRECT_CABANG_SY pip
    WHERE pip."keterangan" IN (
        'Beban Pengisian Uang ATM',
        'Beban Penutupan Kredit Kpd Pihak Ketiga'
    )
) a
LEFT JOIN (
    SELECT
        a."nomor_rekening",
        b."keterangan",
        b."keterangan1",
        SUM(a."nom") AS "nominal_gl",
        TO_NUMBER(b."porsi") AS "porsi",
        SUM(a."nom") * TO_NUMBER(b."porsi") AS "nomxporsi"
    FROM (
        SELECT *
        FROM BJKT_PNL_OPEX_V2_SY pg
        WHERE pg."ket_final" = 'Lainnya (BBM Operasional, Pembayaran pajak, dll.)'
          AND pg."nomor_rekening" IN (
                '511003600101','571113600101','531013600200',
                '527013600300','571053600100','565023600100','521003600300'
          )
          AND (
                SUBSTR(pg."kode_cabang_akhir", 1, 1) IN ('9', '0')
                OR pg."kode_cabang_akhir" = '700'
          )
    ) a
    LEFT JOIN (
        SELECT DISTINCT
            "periode",
            CASE
                WHEN "keterangan" = 'Beban Pengisian Uang ATM'
                THEN 'Beban Transaksi Non Kredit'
                ELSE 'Beban Transaksi Kredit'
            END AS "keterangan1",
            "keterangan",
            "nomor_rekening",
            "porsi"
        FROM BJKT_PNL_DIRECT_PORSI_SY dp
        WHERE "porsi" <> '-'
          AND "keterangan" IN (
                'Beban Pengisian Uang ATM',
                'Beban Penutupan Kredit Kpd Pihak Ketiga'
          )
    ) b ON a."nomor_rekening" = b."nomor_rekening"
    WHERE b."keterangan" IS NOT NULL  -- ✅ alias eksplisit
    GROUP BY
        a."nomor_rekening",
        b."keterangan",
        b."keterangan1",
        TO_NUMBER(b."porsi")           -- ✅ eksplisit, bukan posisi angka
) b ON a."keterangan" = b."keterangan"
LEFT JOIN (
    SELECT
        pg."kode_cabang_akhir",
        pg."ket_final",
        SUM(pg."nom") AS "nominal_gl_cabang"
    FROM BJKT_PNL_OPEX_V2_SY pg
    WHERE pg."ket_final" = 'Lainnya (BBM Operasional, Pembayaran pajak, dll.)'
      AND (
            SUBSTR(pg."kode_cabang_akhir", 1, 1) NOT IN ('9', '0')
            OR pg."kode_cabang_akhir" <> '700'
      )
    GROUP BY
        pg."kode_cabang_akhir",
        pg."ket_final"
    -- ✅ ORDER BY dihapus, tidak valid di subquery Oracle
) c ON a."attribute" = c."kode_cabang_akhir"
LEFT JOIN (
    SELECT
        pg."kode_cabang_akhir",
        CASE
            WHEN pg."nomor_rekening" IN (
                '571113600101','531013600200','527013600300','571053600100'
            )
            THEN 'Beban Transaksi Kredit'
            ELSE 'Beban Transaksi Non Kredit'
        END AS "keterangan1",          -- ✅ alias tanpa prefix pg.
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
    -- ✅ ORDER BY dihapus
) d ON b."keterangan1" = d."keterangan1"
     AND a."attribute" = d."kode_cabang_akhir"
WHERE a."attribute" = 108

UNION

SELECT
    pg."kode_cabang_akhir",
    'Beban Premi Asuransi Kredit' AS "keterangan1",
    ROUND(FLOOR(SUM(pg."nom")) / POWER(10,6)) AS "angka_scorecard"  -- ✅ alias ditambahkan
FROM BJKT_PNL_OPEX_V2_SY pg
WHERE pg."nomor_rekening" IN ('511003600101')
  AND (
        SUBSTR(pg."kode_cabang_akhir", 1, 1) NOT IN ('9', '0')
        OR pg."kode_cabang_akhir" <> '700'
      )
  AND pg."kode_cabang_akhir" = '108'
GROUP BY
    pg."kode_cabang_akhir"
ORDER BY 1;
/
-- Manpower, IT & Telecommunication
SELECT
    ROUND(SUM(CASE WHEN g."ket_final" = 'Manpower' THEN g."nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_manpower",
    ROUND(SUM(CASE WHEN g."ket_final" = 'IT & Telecommunication' THEN g."nominal" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_telecom"
FROM BJKT_PNL_GL_V2_SY g
WHERE g."kode_cabang_akhir" = '108';
/
-- 
SELECT
    TO_DATE(o."periode", 'YYYY-MM-DD')  AS "periode",
    o."kode_cabang_akhir"               AS "kode_cabang",

    -- Add Manpower here
    -- Add IT & Telecomunication here
    ROUND(SUM(CASE WHEN o."ket_final" = 'Office Supplies' THEN o."nom" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_off_sup",
    -- Add sewa here
    ROUND(SUM(CASE WHEN o."ket_final" = 'Beban Perjalanan Dinas' THEN o."nom" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_beb_per_dinas",
    ROUND(SUM(CASE WHEN o."ket_final" = 'Premium Insurance Non-Credit' AND o."ket_4" = 'Direct' THEN o."nom" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_prem_ins_ncr",
    ROUND(SUM(CASE WHEN o."ket_final" = 'Premium Insurance Non-Credit' AND o."ket_4" = 'Direct' THEN o."nom" ELSE NULL END) / POWER(10,6))
            AS "dir_opex_beb_per_dinas"
-- Add Premi Asuransi Kredit here
-- Add Transaksi Kredit here 
-- Add Transaksi Non Kredit here

FROM BJKT_PNL_OPEX_V2_SY o
WHERE o."kode_cabang_akhir" = '108'
GROUP BY o."periode", o."kode_cabang_akhir";

