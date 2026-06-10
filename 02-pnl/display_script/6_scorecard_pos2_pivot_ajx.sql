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
                SUM("total_pen_bunga") AS "total_pen_bunga"
            FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
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
        opx AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("dir_opex_total")        AS "dir_opex_total",
                SUM("dir_opex_manpower")     AS "dir_opex_manpower",
                SUM("dir_opex_telecom")      AS "dir_opex_telecom",
                SUM("dir_opex_ofc_sup")      AS "dir_opex_ofc_sup",
                SUM("dir_opex_sewa")         AS "dir_opex_sewa",
                SUM("dir_opex_per_din")      AS "dir_opex_per_din",
                SUM("dir_opex_prem_ins_ncr") AS "dir_opex_prem_ins_ncr",
                SUM("dir_opex_prem_as_cr")   AS "dir_opex_prem_as_cr",
                SUM("dir_opex_tran_cr")      AS "dir_opex_tran_cr",
                SUM("dir_opex_tran_ncr")     AS "dir_opex_tran_ncr"
            FROM BJKT_PNL_DIRECT_OPEX_MV
            WHERE "periode" >= l_from_date
              AND "periode" <  l_to_date
              AND "kode_konsol" = NVL(l_kc,     "kode_konsol")
              AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        -- Hitung semua nilai kalkulasi sekali
        q_calc AS (
            SELECT
                opx."kode_cabang",
                opx."kode_konsol",

                -- Optimasi Total = -NII + CKPN
                ROUND(
                    -1 * (
                        NVL(fbi."fbi_total",          0) +
                        NVL(bbt."total_beban_bunga",  0) +
                        NVL(pbt."total_pen_bunga",    0) +
                        NVL(fc."ftp_charge_loan",     0) +
                        NVL(fi."ftp_income_dpk",      0)
                    ) + NVL(ckpn."ckpn_nominal", 0)
                ) AS "optimasi_total",

                -- Komponen non-manpower (untuk menghitung optimasi_manpower)
                ROUND(
                    NVL(opx."dir_opex_telecom",      0) +
                    NVL(opx."dir_opex_ofc_sup",      0) +
                    NVL(opx."dir_opex_sewa",         0) +
                    NVL(opx."dir_opex_per_din",      0) +
                    NVL(opx."dir_opex_prem_ins_ncr", 0) +
                    NVL(opx."dir_opex_prem_as_cr",   0) +
                    NVL(opx."dir_opex_tran_cr",      0) +
                    NVL(opx."dir_opex_tran_ncr",     0)
                ) AS "non_manpower_total",

                -- Detail OPEX
                ROUND(opx."dir_opex_telecom")       AS "dir_opex_telecom",
                ROUND(opx."dir_opex_ofc_sup")       AS "dir_opex_ofc_sup",
                ROUND(opx."dir_opex_sewa")          AS "dir_opex_sewa",
                ROUND(opx."dir_opex_per_din")       AS "dir_opex_per_din",
                ROUND(opx."dir_opex_prem_ins_ncr")  AS "dir_opex_prem_ins_ncr",
                ROUND(opx."dir_opex_prem_as_cr")    AS "dir_opex_prem_as_cr",
                ROUND(opx."dir_opex_tran_cr")       AS "dir_opex_tran_cr",
                ROUND(opx."dir_opex_tran_ncr")      AS "dir_opex_tran_ncr"

            FROM opx
            LEFT JOIN fbi  ON fbi."kode_konsol"  = opx."kode_konsol" AND fbi."kode_cabang"  = opx."kode_cabang"
            LEFT JOIN bbt  ON bbt."kode_konsol"  = opx."kode_konsol" AND bbt."kode_cabang"  = opx."kode_cabang"
            LEFT JOIN pbt  ON pbt."kode_konsol"  = opx."kode_konsol" AND pbt."kode_cabang"  = opx."kode_cabang"
            LEFT JOIN fi   ON fi."kode_konsol"   = opx."kode_konsol" AND fi."kode_cabang"   = opx."kode_cabang"
            LEFT JOIN fc   ON fc."kode_konsol"   = opx."kode_konsol" AND fc."kode_cabang"   = opx."kode_cabang"
            LEFT JOIN ckpn ON ckpn."kode_konsol" = opx."kode_konsol" AND ckpn."kode_cabang" = opx."kode_cabang"
        ),
        q_rows AS (
            -- Blok 1: Header sort 1
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                1              AS "sort_order",
                'Y'            AS "is_header"
            FROM q_calc

            UNION ALL

            -- Blok 1: Detail sort 2–11
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                1 + n.rn       AS "sort_order",
                'N'            AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 10) n

            UNION ALL

            -- Blok 2: Header sort 12
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                12             AS "sort_order",
                'Y'            AS "is_header"
            FROM q_calc

            UNION ALL

            -- Blok 2: Detail sort 13–22
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                12 + n.rn      AS "sort_order",
                'N'            AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 10) n

            UNION ALL

            -- Blok 3: Header sort 23
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                23             AS "sort_order",
                'Y'            AS "is_header"
            FROM q_calc

            UNION ALL

            -- Blok 3: Detail sort 24–31
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                23 + n.rn      AS "sort_order",
                'N'            AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 8) n

            UNION ALL

            -- Blok 4: Header sort 32
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                32             AS "sort_order",
                'Y'            AS "is_header"
            FROM q_calc

            UNION ALL

            -- Blok 4: Detail sort 33–40
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                32 + n.rn      AS "sort_order",
                'N'            AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 8) n

            UNION ALL

            -- Blok 5: Header sort 38–41
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                41 + n.rn      AS "sort_order",
                'Y'            AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 4) n

            UNION ALL

            -- Blok 6: Detail sort 43–57
            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                46 + n.rn      AS "sort_order",
                'N'            AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 15) n

            UNION ALL

            -- Optimasi Total (Header)
            SELECT
                "kode_cabang", "kode_konsol",
                'Optimasi Total'                                        AS "column_name",
                TO_CHAR("optimasi_total")                               AS "maximum_cost",
                'Max headcount'                                         AS "intervension",
                62                                                      AS "sort_order",
                'Y'                                                     AS "is_header"
            FROM q_calc

            UNION ALL

            -- Optimasi Manpower
            SELECT
                "kode_cabang", "kode_konsol",
                'Optimasi Manpower'                                     AS "column_name",
                TO_CHAR("optimasi_total" - "non_manpower_total")        AS "maximum_cost",
                'As-Is'                                                 AS "intervension",
                63                                                      AS "sort_order",
                'N'                                                     AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                'IT & Telecommunication'    AS "column_name",
                TO_CHAR("dir_opex_telecom") AS "maximum_cost",
                'As-Is'                     AS "intervension",
                64                          AS "sort_order",
                'N'                         AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                'Office Supplies'           AS "column_name",
                TO_CHAR("dir_opex_ofc_sup") AS "maximum_cost",
                'As-Is'                     AS "intervension",
                65                          AS "sort_order",
                'N'                         AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                'Sewa'                      AS "column_name",
                TO_CHAR("dir_opex_sewa")    AS "maximum_cost",
                'As-Is'                     AS "intervension",
                66                          AS "sort_order",
                'N'                         AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                'Perjalanan Dinas'           AS "column_name",
                TO_CHAR("dir_opex_per_din")  AS "maximum_cost",
                'As-Is'                      AS "intervension",
                67                           AS "sort_order",
                'N'                          AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                'Premi Asuransi Non-Kredit'      AS "column_name",
                TO_CHAR("dir_opex_prem_ins_ncr") AS "maximum_cost",
                'As-Is'                          AS "intervension",
                68                               AS "sort_order",
                'N'                              AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                'Premi Asuransi Kredit'         AS "column_name",
                TO_CHAR("dir_opex_prem_as_cr")  AS "maximum_cost",
                'As-Is'                         AS "intervension",
                69                              AS "sort_order",
                'N'                             AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                'Transaksi Kredit'          AS "column_name",
                TO_CHAR("dir_opex_tran_cr") AS "maximum_cost",
                'As-Is'                     AS "intervension",
                70                          AS "sort_order",
                'N'                         AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                'Transaksi Non-Kredit'       AS "column_name",
                TO_CHAR("dir_opex_tran_ncr") AS "maximum_cost",
                'As-Is'                      AS "intervension",
                71                           AS "sort_order",
                'N'                          AS "is_header"
            FROM q_calc

            UNION ALL

            SELECT "kode_cabang", "kode_konsol",
                '---'          AS "column_name",
                'N/A'          AS "maximum_cost",
                'N/A'          AS "intervension",
                71 + n.rn      AS "sort_order",
                'Y'            AS "is_header"
            FROM q_calc
            CROSS JOIN (SELECT LEVEL AS rn FROM DUAL CONNECT BY LEVEL <= 3) n
        )
        SELECT
            "maximum_cost" as maximum_cost,
            "intervension" as intervension,
            "is_header" as is_header
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