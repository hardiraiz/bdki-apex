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
),
q_result AS (
    SELECT
        -- 1. Metadata Cabang & Konsol
        cre."kode_cabang",
        cre."kode_konsol",
        cre."kredit_total_konven",
        cre."kredit_total_syariah",
        dpk."dpk_total_konven",
        dpk."dpk_total_syariah",

        -- 2. Kolom Kalkulasi Minimum Portofolio Kredit Konven
        -- MINIMUM_PORTO_KRE_KONVEN
        -- KREDIT_OF_PORTOFOLIO*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_KONVEN)+(1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_KONVEN))
        ROUND(
            NVL(cre_por."cre_por_val", 0)*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_konven", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_konven", 0)))
        ) AS "min_port_1",

        -- 3. Kolom Kalkulasi Gap Kredit Konven
        -- GAP_KRE_KONVEN =
        -- KREDIT_KONVEN-MINIMUM_PORTO_KRE_KONVEN
        ROUND (
            NVL(cre."kredit_total_konven", 0) -
            (NVL(cre_por."cre_por_val", 0)*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_konven", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_konven", 0))))
        ) AS "gap_kre_konven",

        -- 4. Kolom Kalkulasi Minimum Portofolio Kredit Syariah
        -- MINIMUM_PORTO_KRE_SYARIAH =
        -- (KREDIT_OF_PORTOFOLIO*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_SYARIAH)+(1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_SYARIAH))
        ROUND(
            NVL(cre_por."cre_por_val", 0)*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_syariah", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_syariah", 0)))
        ) AS "min_port_2",

        -- 5. Kolom Kalkulasi Gap Kredit Syariah
        -- GAP_KRE_SYARIAH =
        -- KREDIT_SYARIAH-MINIMUM_PORTO_KRE_SYARIAH
        ROUND(
            NVL(cre."kredit_total_syariah", 0) -
            NVL(cre_por."cre_por_val", 0)*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_syariah", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_syariah", 0)))
        ) AS "gap_kre_syariah",

        -- 6. Kolom Kalkulasi Minimum Portofolio DPK Konven
        -- MINIMUM_PORTO_DPK_KONVEN =
        -- (1-KREDIT_OF_PORTOFOLIO)*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_KONVEN)+(1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_KONVEN))
        ROUND(
            (1-NVL(cre_por."cre_por_val", 0))*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_konven", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_konven", 0)))
        ) AS "min_dpk_1",

        -- 7. Kolom Kalkulasi Gap DPK Konven
        -- GAP_DPK_KONVEN =
        -- DPK_KONVEN - MINIMUM_PORTO_DPK_KONVEN
        ROUND(
            NVL(dpk."dpk_total_konven", 0) -
            (1-NVL(cre_por."cre_por_val", 0))*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_konven", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_konven", 0)))
        ) AS "gap_dpk_konven",

        -- 8. Kolom Kalkulasi Minimum Portofolio DPK Syariah
        -- MINIMUM_PORTO_DPK_SYARIAH =
        -- (1-KREDIT_OF_PORTOFOLIO)*ABS(MINIMUM_NII)/(KREDIT_OF_PORTOFOLIO*((PEND_BUNGA_TOTAL+FTP_CHARGE_LOAN)/KREDIT_SYARIAH)+(1-KREDIT_OF_PORTOFOLIO)*((BEBAN_BUNGA_TOTAL+FTP_INCOME)/DPK_SYARIAH))
        ROUND(
            (1-NVL(cre_por."cre_por_val", 0))*NVL(min_nii."min_nii_val", 0)/(NVL(cre_por."cre_por_val", 0)*((NVL(pbt."total_pen_bunga", 0)+NVL(fc."ftp_charge_loan", 0))/NVL(cre."kredit_total_syariah", 0))+(1-NVL(cre_por."cre_por_val", 0))*((NVL(bbt."total_beban_bunga", 0)+NVL(fi."ftp_income_dpk", 0))/NVL(dpk."dpk_total_syariah", 0)))
        ) AS "min_dpk_2",

        -- 9. Kolom Kalkulasi Gap DPK Konven
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
),
q_rows AS (
    -- Row total
    SELECT
        "kode_cabang", "kode_konsol",
        'CRE_TOTAL'     AS "column_name",
        TO_CHAR(ROUND("min_port_1" + "min_port_2"))
                        AS "minimum_portofolio",
        TO_CHAR(ABS(ROUND(
            ("min_port_1" - NVL("kredit_total_konven",  0)) +
            ("min_port_2" - NVL("kredit_total_syariah", 0))
        )))             AS "gap",
        1               AS "sort_order",
        'Y'             AS "is_header"
    FROM q_result

    UNION ALL

    -- Row konven
    SELECT
        "kode_cabang", "kode_konsol",
        'CRE_KONVEN'    AS "column_name",
        TO_CHAR(ROUND("min_port_1"))
                        AS "minimum_portofolio",
        TO_CHAR(ABS(ROUND("min_port_1" - NVL("kredit_total_konven", 0))))
                        AS "gap",
        2               AS "sort_order",
        'N'             AS "is_header"
    FROM q_result

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'                   AS "column_name",
        'Portfolio split N/A'   AS "minimum_portofolio",
        NULL                    AS "gap",
        2 + n.rn                AS "sort_order",
        'N'                     AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 4
    ) n

    UNION ALL

    -- Row syariah (perbaikan: tambah TO_CHAR + ROUND)
    SELECT
        "kode_cabang", "kode_konsol",
        'CRE_SYARIAH'   AS "column_name",
        TO_CHAR(ROUND("min_port_2"))
                        AS "minimum_portofolio",
        TO_CHAR(ABS(ROUND("min_port_2" - NVL("kredit_total_syariah", 0))))
                        AS "gap",
        7               AS "sort_order",
        'N'             AS "is_header"
    FROM q_result

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'                   AS "column_name",
        'Portfolio split N/A'   AS "minimum_portofolio",
        NULL                    AS "gap",
        7 + n.rn                AS "sort_order",
        'N'                     AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 4
    ) n

    UNION ALL

    SELECT
        "kode_cabang", "kode_konsol",
        '---'           AS "column_name",
        'N/A'           AS "minimum_portofolio",
        'N/A'           AS "gap",
        12              AS "sort_order",
        'Y'             AS "is_header"
    FROM q_result

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'           AS "column_name",
        'N/A'           AS "minimum_portofolio",
        'N/A'           AS "gap",
        12 + n.rn       AS "sort_order",
        'N'             AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 10
    ) n

    UNION ALL

    -- Row total minimum DPK
    SELECT
        "kode_cabang", "kode_konsol",
        'TOTAL_DPK' AS "column_name",
        TO_CHAR(ROUND("min_dpk_1" + "min_dpk_2"))
                        AS "minimum_portofolio",
        TO_CHAR(ABS(ROUND(
            ("min_dpk_1" - NVL("dpk_total_konven",  0)) +
            ("min_dpk_2" - NVL("dpk_total_syariah", 0))
        )))              AS "gap",
        23               AS "sort_order",
        'Y'              AS "is_header"
    FROM q_result

    UNION ALL

    -- Row minimum DPK konven
    SELECT
        "kode_cabang", "kode_konsol",
        'DPK_KONVEN' AS "column_name",
        TO_CHAR(ROUND("min_dpk_1"))
                        AS "minimum_portofolio",
        TO_CHAR(ABS(ROUND("min_dpk_1" - NVL("dpk_total_konven", 0))))
                        AS "gap",
        24                AS "sort_order",
        'N'               AS "is_header"
    FROM q_result

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'                   AS "column_name",
        'Portfolio split N/A'   AS "minimum_portofolio",
        NULL                    AS "gap",
        24 + n.rn               AS "sort_order",
        'N'                     AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 3
    ) n

    UNION ALL

    -- Row minimum DPK syariah
    SELECT
        "kode_cabang", "kode_konsol",
        'DPK_SYARIAH'   AS "column_name",
        TO_CHAR(ROUND("min_dpk_2"))
                        AS "minimum_portofolio",
        TO_CHAR(ABS(ROUND("min_dpk_2" - NVL("dpk_total_syariah", 0))))
                        AS "gap",
        28              AS "sort_order",
        'N'             AS "is_header"
    FROM q_result

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'                   AS "column_name",
        'Portfolio split N/A'   AS "minimum_portofolio",
        NULL                    AS "gap",
        28 + n.rn               AS "sort_order",
        'N'                     AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 3
    ) n

    UNION ALL

    SELECT
        "kode_cabang", "kode_konsol",
        '---'           AS "column_name",
        'N/A'           AS "minimum_portofolio",
        'N/A'           AS "gap",
        32              AS "sort_order",
        'Y'             AS "is_header"
    FROM q_result

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'           AS "column_name",
        'N/A'           AS "minimum_portofolio",
        'N/A'           AS "gap",
        32 + n.rn       AS "sort_order",
        'N'             AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 8
    ) n

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'           AS "column_name",
        'N/A'           AS "minimum_portofolio",
        'N/A'           AS "gap",
        41 + n.rn       AS "sort_order",
        'Y'             AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 4
    ) n

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'           AS "column_name",
        'N/A'           AS "minimum_portofolio",
        'N/A'           AS "gap",
        46 + n.rn       AS "sort_order",
        'N'             AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 18
    ) n

    UNION ALL

    SELECT
        "kode_cabang", "kode_konsol",
        '---'           AS "column_name",
        'N/A'           AS "minimum_portofolio",
        'N/A'           AS "gap",
        65              AS "sort_order",
        'Y'             AS "is_header"
    FROM q_result

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'           AS "column_name",
        'N/A'           AS "minimum_portofolio",
        'N/A'           AS "gap",
        65 + n.rn       AS "sort_order",
        'N'             AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 9
    ) n

    UNION ALL

    SELECT
        r."kode_cabang", r."kode_konsol",
        '---'           AS "column_name",
        'N/A'           AS "minimum_portofolio",
        'N/A'           AS "gap",
        75 + n.rn       AS "sort_order",
        'Y'             AS "is_header"
    FROM q_result r
    CROSS JOIN (
        SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 4
    ) n
)
SELECT
    "minimum_portofolio" as minimum_portofolio,
    "gap" as gap,
    "is_header" as is_header
FROM q_rows
ORDER BY
    "kode_cabang",
    "kode_konsol",
    "sort_order"