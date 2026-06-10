DECLARE
    l_from_date DATE;
    l_to_date   DATE;
    l_kc        VARCHAR2(200);
    l_cabang    VARCHAR2(200);

    l_jml_konsol NUMBER;
    l_jml_cabang NUMBER;
    l_jml_ppop NUMBER;
    l_jml_pbt NUMBER;

    l_tot_cabang NUMBER;
BEGIN

    IF apex_application.g_x01 IS NOT NULL THEN
        l_from_date := TO_DATE(apex_application.g_x01, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH');
    END IF;

    IF apex_application.g_x02 IS NOT NULL THEN
        l_to_date := TO_DATE(apex_application.g_x02, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH');
    END IF;

    l_kc     := apex_application.g_x03;
    l_cabang := apex_application.g_x04;

    apex_json.open_object;
    SELECT
        COUNT(DISTINCT "kode_konsol")       AS jml_konsol,
        COUNT(DISTINCT "kode_cabang_akhir") AS tot_cabang,
        COUNT(DISTINCT CASE
            WHEN "kode_konsol" = NVL(l_kc, "kode_konsol") 
             AND "kode_cabang_akhir" = NVL(l_cabang,  "kode_cabang_akhir")
            THEN "kode_cabang_akhir"
        END)                                AS jml_cabang
    INTO
        l_jml_konsol,
        l_tot_cabang,
        l_jml_cabang
    FROM BJKT_BRANCHES_MV;

    WITH 
    pbt AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("total_pen_bunga")      AS "total_pen_bunga"
        FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
        WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
          AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
          AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
          AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    ),
    bbt AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("total_beban_bunga")            AS "total_beban_bunga"
        FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
        WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
          AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
          AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
          AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    ),
    fi AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("ftp_income_dpk") AS "ftp_income_dpk"
        FROM BJKT_PNL_FTP_INCOME_MV
        WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
          AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
          AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
          AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    ),
    fc AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("ftp_charge_loan") AS "ftp_charge_loan"
        FROM BJKT_PNL_FTP_CHARGE_MV
        WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
          AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
          AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
          AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    ),
    fbi AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("fbi_total")             AS "fbi_total"
        FROM BJKT_PNL_FEE_BASED_INCOME_MV
        WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
          AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
          AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol") 
          AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    ),
    opx AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("dir_opex_total")        AS "dir_opex_total"
        FROM BJKT_PNL_DIRECT_OPEX_MV
        WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
          AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
          AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
          AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    ),
    ckpn AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("ckpn_nominal") AS "ckpn_nominal"
        FROM BJKT_PNL_BEBAN_CKPN_MV
        WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
          AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
          AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
          AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    )
    SELECT
        -- PPOP (Dir OPEX)
        ROUND(SUM((
            (
                  NVL(bbt."total_beban_bunga", 0)
                + NVL(pbt."total_pen_bunga",   0)
                + NVL(fc."ftp_charge_loan",   0)
                + NVL(fi."ftp_income_dpk",    0)
            ) +
            NVL(fbi."fbi_total", 0) +
            NVL(opx."dir_opex_total", 0)
        ))) AS "ppop_total",
        -- PBT (Dir OPEX)
        ROUND(SUM((
            (
                  NVL(bbt."total_beban_bunga", 0)
                + NVL(pbt."total_pen_bunga",   0)
                + NVL(fc."ftp_charge_loan",   0)
                + NVL(fi."ftp_income_dpk",    0)
            ) +
            NVL(fbi."fbi_total", 0) +
            NVL(opx."dir_opex_total", 0) +
            NVL(ckpn."ckpn_nominal", 0)
        ))) AS "pbt_nominal"
    INTO l_jml_ppop
       , l_jml_pbt
    FROM pbt
    LEFT JOIN bbt  ON pbt."kode_cabang" = bbt."kode_cabang"  AND pbt."kode_konsol" = bbt."kode_konsol"
    LEFT JOIN fi   ON pbt."kode_cabang" = fi."kode_cabang"   AND pbt."kode_konsol" = fi."kode_konsol"
    LEFT JOIN fc   ON pbt."kode_cabang" = fc."kode_cabang"   AND pbt."kode_konsol" = fc."kode_konsol"
    LEFT JOIN fbi  ON pbt."kode_cabang" = fbi."kode_cabang"  AND pbt."kode_konsol" = fbi."kode_konsol"
    LEFT JOIN opx  ON pbt."kode_cabang" = opx."kode_cabang"  AND pbt."kode_konsol" = opx."kode_konsol"
    LEFT JOIN ckpn ON pbt."kode_cabang" = ckpn."kode_cabang" AND pbt."kode_konsol" = ckpn."kode_konsol";
    apex_json.write('jml_konsol', l_jml_konsol);
    apex_json.write('jml_cabang', l_jml_cabang);
    apex_json.write('total_cabang', l_tot_cabang);
    apex_json.write('jml_ppop', l_jml_ppop);
    apex_json.write('jml_pbt', l_jml_pbt);

    apex_json.close_object;
    apex_json.flush;

EXCEPTION
    WHEN OTHERS THEN
        apex_json.open_object;
        apex_json.write('error', SQLERRM);
        apex_json.close_object;
END;