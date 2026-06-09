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
    WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO,   'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC,     "kode_konsol")
      AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
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
    WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO,   'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC,     "kode_konsol")
      AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
    GROUP BY "kode_cabang", "kode_konsol"
),
pbt AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("total_pen_bunga") AS "total_pen_bunga"
    FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
    WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO,   'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC,     "kode_konsol")
      AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
    GROUP BY "kode_cabang", "kode_konsol"
),
bbt AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("total_beban_bunga") AS "total_beban_bunga"
    FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
    WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO,   'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC,     "kode_konsol")
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
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO,   'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC,     "kode_konsol")
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
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO,   'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC,     "kode_konsol")
      AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
    GROUP BY "kode_cabang", "kode_konsol"
),
fbi AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("fbi_total") AS "fbi_total"
    FROM BJKT_PNL_FEE_BASED_INCOME_MV
    WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO,   'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC,     "kode_konsol")
      AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
    GROUP BY "kode_cabang", "kode_konsol"
),
opx AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("dir_opex_total") AS "dir_opex_total"
    FROM BJKT_PNL_DIRECT_OPEX_MV
    WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO,   'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC,     "kode_konsol")
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
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO,   'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC,     "kode_konsol")
      AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
    GROUP BY "kode_cabang", "kode_konsol"
),
q_calc AS (
    SELECT
        cre."kode_cabang",
        cre."kode_konsol",
        cre."kredit_total_konven",
        cre."kredit_total_syariah",
        ROUND(
            NVL(cre."total_kredit", 0) /
            NULLIF(NVL(cre."total_kredit", 0) + NVL(dpk."total_dpk", 0), 0),
            3
        )                                                          AS "w_kredit",
        ABS(
            NVL(opx."dir_opex_total", 0) +
            NVL(ckpn."ckpn_nominal",  0) +
            NVL(fbi."fbi_total",      0)
        )                                                          AS "beban_total",
        ( NVL(pbt."total_pen_bunga", 0) + NVL(fc."ftp_charge_loan", 0) )
            / NULLIF(cre."kredit_total_konven",  0)               AS "yield_konven",
        ( NVL(pbt."total_pen_bunga", 0) + NVL(fc."ftp_charge_loan", 0) )
            / NULLIF(cre."kredit_total_syariah", 0)               AS "yield_syariah",
        ( NVL(bbt."total_beban_bunga", 0) + NVL(fi."ftp_income_dpk", 0) )
            / NULLIF(dpk."dpk_total_konven",  0)                  AS "cof_konven",
        ( NVL(bbt."total_beban_bunga", 0) + NVL(fi."ftp_income_dpk", 0) )
            / NULLIF(dpk."dpk_total_syariah", 0)                  AS "cof_syariah"
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
        NVL(
            "w_kredit" * "beban_total"
            / NULLIF("w_kredit" * "yield_konven" + (1 - "w_kredit") * "cof_konven", 0),
            0
        ) AS "min_port_1",
        NVL(
            "w_kredit" * "beban_total"
            / NULLIF("w_kredit" * "yield_syariah" + (1 - "w_kredit") * "cof_syariah", 0),
            0
        ) AS "min_port_2"
    FROM q_calc
)
SELECT
    "kode_cabang",
    "kode_konsol",

    -- Minimum Portofolio Total
    "min_port_1" + "min_port_2"                          AS "minimum_portofolio_total",

    -- Minimum Portofolio 1 (konven)
    "min_port_1"                                         AS "minimum_portofolio_1",

    -- Gap 1 (konven)
    "min_port_1" - NVL("kredit_total_konven", 0)         AS "gap_1",

    -- Minimum Portofolio 2 (syariah)
    "min_port_2"                                         AS "minimum_portofolio_2",

    -- Gap 2 (syariah)
    "min_port_2" - NVL("kredit_total_syariah", 0)        AS "gap_2",

    -- Total Gap
    (  "min_port_1" - NVL("kredit_total_konven",  0)  )
    + ("min_port_2" - NVL("kredit_total_syariah", 0)  )  AS "total_gap"

FROM q_result
ORDER BY "kode_cabang";