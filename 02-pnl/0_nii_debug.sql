SELECT *
FROM (
    WITH
    pend_bunga AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("total_pen_bunga") AS "total_pen_bunga"
        FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
        WHERE
                "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
            AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
            AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
            AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    ),
    beban_bunga AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("total_beban_bunga") AS "total_beban_bunga"
        FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
        WHERE
                "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
            AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
            AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
            AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    ),
    ftp_charge AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("ftp_charge_loan") AS "ftp_charge_loan"
        FROM BJKT_PNL_FTP_CHARGE_MV
        WHERE
                "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
            AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
            AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
            AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    ),
    ftp_income AS (
        SELECT
            "kode_cabang",
            "kode_konsol",
            SUM("ftp_income_dpk") AS "ftp_income_dpk"
        FROM BJKT_PNL_FTP_INCOME_MV
        WHERE
                "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
            AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
            AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
            AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
        GROUP BY "kode_cabang", "kode_konsol"
    )
    SELECT
        bb."kode_cabang",
        bb."kode_konsol",
        ROUND(
            NVL(bb."total_beban_bunga", 0)
          + NVL(pb."total_pen_bunga",   0)
          + NVL(fc."ftp_charge_loan",   0)
          + NVL(fi."ftp_income_dpk",    0)
        )                                   AS "nii_post_ftp"
    FROM
        beban_bunga bb
    LEFT JOIN pend_bunga pb
        ON  bb."kode_cabang"    = pb."kode_cabang"
        AND bb."kode_konsol"    = pb."kode_konsol"
    LEFT JOIN ftp_charge fc
        ON  bb."kode_cabang"    = fc."kode_cabang"
        AND bb."kode_konsol"    = fc."kode_konsol"
    LEFT JOIN ftp_income fi
        ON  bb."kode_cabang"    = fi."kode_cabang"
        AND bb."kode_konsol"    = fi."kode_konsol"
);
