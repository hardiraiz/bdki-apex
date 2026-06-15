DECLARE
    l_from_date DATE;
    l_to_date   DATE;
    l_kc varchar(200);
    l_cabang varchar(200);
BEGIN

    IF apex_application.g_x01 IS NOT NULL THEN
        l_from_date := TO_DATE(apex_application.g_x01, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH');
    END IF;
    IF apex_application.g_x02 IS NOT NULL THEN
        l_to_date := TO_DATE(apex_application.g_x02, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1;
    END IF;
    l_kc := apex_application.g_x03;
    l_cabang := apex_application.g_x04;

    apex_json.initialize_output;
    apex_json.open_array;

    FOR r IN (
        WITH
        cre AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                MAX("nama_cabang")          AS "nama_cabang",
                MAX("nama_konsol")          AS "nama_konsol",
                SUM("total_kredit")         AS "total_kredit",
                SUM("kredit_total_konven")  AS "kredit_total_konven",
                SUM("kredit_total_syariah") AS "kredit_total_syariah"
            FROM BJKT_PNL_AVG_BAL_CREDIT_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        dpk AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("total_dpk")         AS "total_dpk",
                SUM("dpk_total_konven")  AS "dpk_total_konven",
                SUM("dpk_total_syariah") AS "dpk_total_syariah"
            FROM BJKT_PNL_AVG_BAL_DPK_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        pbt AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("total_pen_bunga") AS "total_pen_bunga"
            FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        bbt AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("total_beban_bunga") AS "total_beban_bunga"
            FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        fi AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("ftp_income_dpk") AS "ftp_income_dpk"
            FROM BJKT_PNL_FTP_INCOME_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        fc AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("ftp_charge_loan") AS "ftp_charge_loan"
            FROM BJKT_PNL_FTP_CHARGE_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        fbi AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("fbi_total") AS "fbi_total"
            FROM BJKT_PNL_FEE_BASED_INCOME_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        opx AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("dir_opex_total") AS "dir_opex_total"
            FROM BJKT_PNL_DIRECT_OPEX_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        ckpn AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("ckpn_nominal") AS "ckpn_nominal"
            FROM BJKT_PNL_BEBAN_CKPN_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        q_calc AS (
            SELECT
                cre."kode_cabang",
                cre."kode_konsol",
                cre."kredit_total_konven",
                cre."kredit_total_syariah",
                dpk."dpk_total_konven",
                dpk."dpk_total_syariah",
                ROUND(
                    NVL(cre."total_kredit", 0) /
                    NULLIF(NVL(cre."total_kredit", 0) + NVL(dpk."total_dpk", 0), 0),
                    3
                ) AS "w_kredit",
                (1 - ROUND(
                    NVL(cre."total_kredit", 0) /
                    NULLIF(NVL(cre."total_kredit", 0) + NVL(dpk."total_dpk", 0), 0),
                    3
                )) AS "w_dpk",
                ABS(
                    NVL(opx."dir_opex_total", 0) +
                    NVL(ckpn."ckpn_nominal",  0) +
                    NVL(fbi."fbi_total",      0)
                ) AS "beban_total",
                ( NVL(pbt."total_pen_bunga", 0) + NVL(fc."ftp_charge_loan", 0) )
                    / NULLIF(cre."kredit_total_konven",  0)     AS "yield_konven",
                ( NVL(pbt."total_pen_bunga", 0) + NVL(fc."ftp_charge_loan", 0) )
                    / NULLIF(cre."kredit_total_syariah", 0)     AS "yield_syariah",
                ( NVL(bbt."total_beban_bunga", 0) + NVL(fi."ftp_income_dpk", 0) )
                    / NULLIF(dpk."dpk_total_konven",  0)        AS "cof_konven",
                ( NVL(bbt."total_beban_bunga", 0) + NVL(fi."ftp_income_dpk", 0) )
                    / NULLIF(dpk."dpk_total_syariah", 0)        AS "cof_syariah",

                -- Yield kredit konven, tapi basis DPK konven (untuk rumus min DPK)
                ( NVL(pbt."total_pen_bunga", 0) + NVL(fc."ftp_charge_loan", 0) )
                    / NULLIF(dpk."dpk_total_konven", 0)  AS "yield_konven_dpk"
                
            FROM cre
            LEFT JOIN dpk  ON cre."kode_cabang" = dpk."kode_cabang"  AND cre."kode_konsol" = dpk."kode_konsol"
            LEFT JOIN pbt  ON cre."kode_cabang" = pbt."kode_cabang"  AND cre."kode_konsol" = pbt."kode_konsol"
            LEFT JOIN bbt  ON cre."kode_cabang" = bbt."kode_cabang"  AND cre."kode_konsol" = bbt."kode_konsol"
            LEFT JOIN fc   ON cre."kode_cabang" = fc."kode_cabang"   AND cre."kode_konsol" = fc."kode_konsol"
            LEFT JOIN fi   ON cre."kode_cabang" = fi."kode_cabang"   AND cre."kode_konsol" = fi."kode_konsol"
            LEFT JOIN fbi  ON cre."kode_cabang" = fbi."kode_cabang"  AND cre."kode_konsol" = fbi."kode_konsol"
            LEFT JOIN opx  ON cre."kode_cabang" = opx."kode_cabang"  AND cre."kode_konsol" = opx."kode_konsol"
            LEFT JOIN ckpn ON cre."kode_cabang" = ckpn."kode_cabang" AND cre."kode_konsol" = ckpn."kode_konsol"
        ),
        -- CTE kedua untuk menghitung min_port sekali, lalu gap & total referensi dari sini
        q_result AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                "kredit_total_konven",
                "kredit_total_syariah",
                "dpk_total_konven",
                "dpk_total_syariah",

                -- Min AVG. Kredit Konven
                NVL(
                    "w_kredit" * "beban_total"
                    / NULLIF("w_kredit" * "yield_konven" + (1 - "w_kredit") * "cof_konven", 0),
                    0
                ) AS "min_port_1",

                -- Min AVG. Kredit Syariah
                NVL(
                    "w_kredit" * "beban_total"
                    / NULLIF("w_kredit" * "yield_syariah" + (1 - "w_kredit") * "cof_syariah", 0),
                    0
                ) AS "min_port_2",

                -- Minimum DPK 1 (konven)
                NVL(
                    (1 - "w_kredit") * "beban_total"
                    / NULLIF(
                        "w_kredit"       * ("yield_konven_dpk") +
                        (1 - "w_kredit") * "cof_konven",
                        0
                    ),
                    0
                ) AS "min_dpk_1",

                -- Minimum DPK 2 (syariah)
                NVL(
                    (1 - "w_kredit") * "beban_total"
                    / NULLIF(
                        "w_kredit"       * ("yield_konven_dpk") +
                        (1 - "w_kredit") * "cof_syariah",
                        0
                    ),
                    0
                ) AS "min_dpk_2"
            FROM q_calc
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
                SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 17
            ) n

            UNION ALL

            SELECT
                "kode_cabang", "kode_konsol",
                '---'           AS "column_name",
                'N/A'           AS "minimum_portofolio",
                'N/A'           AS "gap",
                64              AS "sort_order",
                'Y'             AS "is_header"
            FROM q_result

            UNION ALL

            SELECT
                r."kode_cabang", r."kode_konsol",
                '---'           AS "column_name",
                'N/A'           AS "minimum_portofolio",
                'N/A'           AS "gap",
                64 + n.rn       AS "sort_order",
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
                74 + n.rn       AS "sort_order",
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
    )
    LOOP
        apex_json.open_object;

        apex_json.write('minimum_portofolio', r.minimum_portofolio);
        apex_json.write('gap', r.gap);
        apex_json.write('is_header', r.is_header);

        apex_json.close_object;

    END LOOP;

    apex_json.close_array;
    apex_json.flush;
EXCEPTION
    WHEN OTHERS THEN
        htp.p('sqlerrm:' || SQLERRM);
END;