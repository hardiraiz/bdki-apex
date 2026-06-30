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
        cbg AS (
            SELECT "kode_cabang_akhir" AS "kode_cabang", "kode_konsol"
            FROM BJKT_BRANCHES_MV
            WHERE "kode_konsol" = l_kc AND "kode_cabang_akhir" = l_cabang
            GROUP BY "kode_cabang_akhir", "kode_konsol"
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
        pbt AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                MAX("nama_cabang")          AS "nama_cabang",
                SUM("total_pen_bunga")      AS "total_pen_bunga"
            FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
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
        q_calc AS (
            SELECT
                pbt."kode_konsol",
                pbt."kode_cabang",
                ROUND(-1 * (
                    NVL(bbt."total_beban_bunga", 0) +
                    NVL(pbt."total_pen_bunga",   0) +
                    NVL(fc."ftp_charge_loan",    0) +
                    NVL(fi."ftp_income_dpk",     0) +
                    NVL(fbi."fbi_total",         0) +
                    NVL(opx."dir_opex_total",    0)
                )) AS "total_ppop"
            FROM cbg 
            LEFT JOIN pbt ON pbt."kode_cabang" = cbg."kode_cabang" AND pbt."kode_konsol" = cbg."kode_konsol"
            LEFT JOIN bbt ON bbt."kode_cabang" = cbg."kode_cabang" AND bbt."kode_konsol" = cbg."kode_konsol"
            LEFT JOIN fc  ON fc."kode_cabang"  = cbg."kode_cabang" AND fc."kode_konsol"  = cbg."kode_konsol"
            LEFT JOIN fi  ON fi."kode_cabang"  = cbg."kode_cabang" AND fi."kode_konsol"  = cbg."kode_konsol"
            LEFT JOIN fbi ON fbi."kode_cabang" = cbg."kode_cabang" AND fbi."kode_konsol" = cbg."kode_konsol"
            LEFT JOIN opx ON opx."kode_cabang" = cbg."kode_cabang" AND opx."kode_konsol" = cbg."kode_konsol"
        ),
        q_rows AS (
            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                1 AS "sort_order", 'Y' AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                1 + n.rn AS "sort_order", 'N' AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 10) n

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                12 AS "sort_order", 'Y' AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                12 + n.rn AS "sort_order", 'N' AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 10) n

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                23 AS "sort_order", 'Y' AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                23 + n.rn AS "sort_order", 'N' AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 8) n

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                32 AS "sort_order", 'Y' AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                32 + n.rn AS "sort_order", 'N' AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 8) n

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                40 + n.rn AS "sort_order", 'Y' AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 4) n

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                44 + n.rn AS "sort_order", 'N' AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 19) n

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                64 AS "sort_order", 'Y' AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                65 + n.rn AS "sort_order", 'N' AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 9) n

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                74 AS "sort_order", 'Y' AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT
                "kode_cabang",
                "kode_konsol",
                'Total PPOP'              AS "column_name",
                TO_CHAR("total_ppop")     AS "maximum_cost",
                'As-Is'                   AS "intervension",
                75                        AS "sort_order",
                'Y'                       AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                76 AS "sort_order", 'Y' AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---' AS "column_name", 'N/A' AS "maximum_cost", 'N/A' AS "intervension",
                77 AS "sort_order", 'Y' AS "is_header"
            FROM q_calc
        )
        SELECT
            "maximum_cost"  AS maximum_cost,
            "intervension"  AS intervension,
            "is_header"     AS is_header
        FROM q_rows
        ORDER BY
            "kode_konsol",
            "kode_cabang",
            "sort_order"
    )
    LOOP

        apex_json.open_object;

        apex_json.write('maximum_cost', r.maximum_cost);
        apex_json.write('intervension', r.intervension);
        apex_json.write('is_header', r.is_header);

        apex_json.close_object;

    END LOOP;

    apex_json.close_array;
    apex_json.flush;
EXCEPTION
    WHEN OTHERS THEN
        htp.p('sqlerrm:' || SQLERRM);
END;