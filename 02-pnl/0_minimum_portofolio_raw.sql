WITH
pbt AS (
    -- PEND_BUNGA_TOTAL
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("total_pen_bunga")      AS "total_pen_bunga"
    FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
    WHERE "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kc
    AND "kode_cabang" = :cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
cre AS (
    SELECT
        "kode_cabang",
        MAX("nama_cabang")          AS "nama_cabang",
        MAX("kode_konsol")          AS "kode_konsol",
        MAX("nama_konsol")          AS "nama_konsol",
        SUM("total_kredit")         AS "total_kredit",
        SUM("kredit_total_konven")  AS "kredit_total_konven", -- KREDIT_KONVEN
        SUM("kredit_total_syariah") AS "kredit_total_syariah" -- KREDIT_SYARIAH
    FROM BJKT_PNL_AVG_BAL_CREDIT_MV
    WHERE "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kc
    AND "kode_cabang" = :cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
dpk AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("total_dpk")            AS "total_dpk",
        SUM("dpk_total_konven")     AS "dpk_total_konven", -- DPK_KONVEN
        SUM("dpk_total_syariah")    AS "dpk_total_syariah" -- DPK_SYARIAH
    FROM BJKT_PNL_AVG_BAL_DPK_MV
    WHERE "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kc
    AND "kode_cabang" = :cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
bbt AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("total_beban_bunga")            AS "total_beban_bunga" -- BEBAN_BUNGA_TOTAL
    FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
    WHERE "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kc
    AND "kode_cabang" = :cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
fi AS (
    -- FTP_INCOME
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("ftp_income_dpk") AS "ftp_income_dpk"
    FROM BJKT_PNL_FTP_INCOME_MV
    WHERE "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kc
    AND "kode_cabang" = :cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
fc AS (
    -- FTP_CHARGE_LOAN
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("ftp_charge_loan") AS "ftp_charge_loan"
    FROM BJKT_PNL_FTP_CHARGE_MV
    WHERE "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kc
    AND "kode_cabang" = :cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
fbi AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("fbi_total")             AS "fbi_total"
    FROM BJKT_PNL_FEE_BASED_INCOME_MV
    WHERE "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kc 
    AND "kode_cabang" = :cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
opx AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("dir_opex_total")        AS "dir_opex_total"
    FROM BJKT_PNL_DIRECT_OPEX_MV
    WHERE "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kc 
    AND "kode_cabang" = :cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
ckpn AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("ckpn_nominal") AS "ckpn_nominal"
    FROM BJKT_PNL_BEBAN_CKPN_MV
    WHERE "periode" >= TO_DATE(:from_date, 'YYYY-MM-DD')
    AND "periode" <= TO_DATE(:to_date, 'YYYY-MM-DD')
    AND "kode_konsol" = :kc 
    AND "kode_cabang" = :cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
cre_por AS (
    -- KREDIT_OF_PORTOFOLIO
    SELECT
        cre."kode_cabang",
        cre."kode_konsol",
        NVL(cre."total_kredit", 0) / NULLIF((NVL(cre."total_kredit", 0) + NVL(dpk."total_dpk", 0)), 0)
            AS "cre_por_val"
    FROM cre
    LEFT JOIN dpk
        ON  dpk."kode_cabang" = cre."kode_cabang"
        AND dpk."kode_konsol" = cre."kode_konsol"
),
min_nii AS (
    -- MINIMUM_NII
    SELECT
        opx."kode_cabang",
        opx."kode_konsol",
        ABS(
            NVL((opx."dir_opex_total"), 0) +
            NVL((ckpn."ckpn_nominal"), 0) +
            NVL((fbi."fbi_total"), 0)
        ) AS "min_nii_val"
    FROM opx
    LEFT JOIN fbi
        ON  fbi."kode_cabang" = opx."kode_cabang"
        AND fbi."kode_konsol" = opx."kode_konsol"
    LEFT JOIN ckpn
        ON  ckpn."kode_cabang" = opx."kode_cabang"
        AND ckpn."kode_konsol" = opx."kode_konsol" 
)

SELECT
    -- 1. Metadata Cabang & Konsol
    cre."kode_cabang",
    cre."nama_cabang",
    cre."kode_konsol",
    cre."nama_konsol",

    -- 2. Menampilkan Seluruh Nilai Komponen Rumus (Sesuai Permintaan)
    -- NVL(cre_por."cre_por_val", 0)     AS "kredit_of_portofolio",
    -- NVL(min_nii."min_nii_val", 0)     AS "abs_minimum_nii",
    -- NVL(pbt."total_pen_bunga", 0)     AS "pend_bunga_total",
    -- NVL(fc."ftp_charge_loan", 0)      AS "ftp_charge_loan",
    -- NVL(cre."kredit_total_konven", 0) AS "kredit_konven",
    -- NVL(cre."kredit_total_syariah", 0) AS "kredit_syariah",
    -- NVL(bbt."total_beban_bunga", 0)   AS "beban_bunga_total",
    -- NVL(fi."ftp_income_dpk", 0)       AS "ftp_income",
    -- NVL(dpk."dpk_total_konven", 0)    AS "dpk_konven",
    -- NVL(dpk."dpk_total_syariah", 0)    AS "dpk_syariah",

    -- 3. Kolom Kalkulasi Minimum Portofolio Kredit Konven
    -- MINIMUM_PORTO_KRE_KONVEN
    -- KREDIT_OF_PORTOFOLIO*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_KONVEN)+(1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_KONVEN))
    ROUND(
        NVL(cre_por."cre_por_val", 0)*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_konven", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_konven", 0)))
    ) AS "min_por_kre_konven",

    -- 4. Kolom Kalkulasi Gap Kredit Konven
    -- GAP_KRE_KONVEN =
    -- KREDIT_KONVEN-MINIMUM_PORTO_KRE_KONVEN
    ROUND (
        NVL(cre."kredit_total_konven", 0) -
        (NVL(cre_por."cre_por_val", 0)*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_konven", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_konven", 0))))
    ) AS "gap_kre_konven",

    -- 5. Kolom Kalkulasi Minimum Portofolio Kredit Syariah
    -- MINIMUM_PORTO_KRE_SYARIAH =
    -- (KREDIT_OF_PORTOFOLIO*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_SYARIAH)+(1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_SYARIAH))
    ROUND(
        NVL(cre_por."cre_por_val", 0)*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_syariah", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_syariah", 0)))
    ) AS "min_por_kre_syariah",

    -- 6. Kolom Kalkulasi Gap Kredit Syariah
    -- GAP_KRE_SYARIAH =
    -- KREDIT_SYARIAH-MINIMUM_PORTO_KRE_SYARIAH
    ROUND(
        NVL(cre."kredit_total_syariah", 0) -
        NVL(cre_por."cre_por_val", 0)*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_syariah", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_syariah", 0)))
    ) AS "gap_kre_syariah",

    -- 7. Kolom Kalkulasi Minimum Portofolio DPK Konven
    -- MINIMUM_PORTO_DPK_KONVEN =
    -- (1-KREDIT_OF_PORTOFOLIO)*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_KONVEN)+(1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_KONVEN))
    ROUND(
        (1-NVL(cre_por."cre_por_val", 0))*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_konven", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_konven", 0)))
    ) AS "min_por_dpk_konven",

    -- 8. Kolom Kalkulasi Gap DPK Konven
    -- GAP_DPK_KONVEN =
    -- DPK_KONVEN - MINIMUM_PORTO_DPK_KONVEN
    ROUND(
        NVL(dpk."dpk_total_konven", 0) -
        (1-NVL(cre_por."cre_por_val", 0))*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_konven", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_konven", 0)))
    ) AS "gap_dpk_konven",

    -- 9. Kolom Kalkulasi Minimum Portofolio DPK Syariah
    -- MINIMUM_PORTO_DPK_SYARIAH =
    -- (1-KREDIT_OF_PORTOFOLIO)*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_SYARIAH)+(1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_SYARIAH))
    ROUND(
        (1-NVL(cre_por."cre_por_val", 0))*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_syariah", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_syariah", 0)))
    ) AS "min_por_dpk_syariah",

    -- 8. Kolom Kalkulasi Gap DPK Konven
    -- GAP_DPK_SYARIAH =
    -- DPK_SYARIAH - MINIMUM_PORTO_DPK_SYARIAH
    ROUND(
        NVL(dpk."dpk_total_syariah", 0) -
        (1-NVL(cre_por."cre_por_val", 0))*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_syariah", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_syariah", 0)))
    ) AS "gap_dpk_syariah"

FROM cre
LEFT JOIN cre_por ON cre."kode_cabang" = cre_por."kode_cabang" AND cre."kode_konsol" = cre_por."kode_konsol"
LEFT JOIN min_nii ON cre."kode_cabang" = min_nii."kode_cabang" AND cre."kode_konsol" = min_nii."kode_konsol"
LEFT JOIN pbt     ON cre."kode_cabang" = pbt."kode_cabang"     AND cre."kode_konsol" = pbt."kode_konsol"
LEFT JOIN bbt     ON cre."kode_cabang" = bbt."kode_cabang"     AND cre."kode_konsol" = bbt."kode_konsol"
LEFT JOIN fi      ON cre."kode_cabang" = fi."kode_cabang"      AND cre."kode_konsol" = fi."kode_konsol"
LEFT JOIN fc      ON cre."kode_cabang" = fc."kode_cabang"      AND cre."kode_konsol" = fc."kode_konsol"
LEFT JOIN dpk     ON cre."kode_cabang" = dpk."kode_cabang"     AND cre."kode_konsol" = dpk."kode_konsol"
;