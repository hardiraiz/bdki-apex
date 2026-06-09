WITH
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
    WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
      AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
    GROUP BY "kode_cabang", "kode_konsol"
)
SELECT
    -- optimasi total
    (-1 * (
        NVL(fbi."fbi_total", 0)
        + NVL(bbt."total_beban_bunga", 0)
        + NVL(pbt."total_pen_bunga", 0)
        + NVL(fc."ftp_charge_loan", 0)
        + NVL(fi."ftp_income_dpk", 0)
    ) + ckpn."ckpn_nominal") AS "optimasi_total",
    (
        (
            (-1 * (
                NVL(fbi."fbi_total", 0)
                + NVL(bbt."total_beban_bunga", 0)
                + NVL(pbt."total_pen_bunga", 0)
                + NVL(fc."ftp_charge_loan", 0)
                + NVL(fi."ftp_income_dpk", 0)
            ) + ckpn."ckpn_nominal")
        ) -
        (
            NVL(opx."dir_opex_telecom", 0) +
            NVL(opx."dir_opex_ofc_sup", 0) +
            NVL(opx."dir_opex_sewa", 0) +
            NVL(opx."dir_opex_per_din", 0) +
            NVL(opx."dir_opex_prem_ins_ncr", 0) +
            NVL(opx."dir_opex_prem_as_cr", 0) +
            NVL(opx."dir_opex_tran_cr", 0) +
            NVL(opx."dir_opex_tran_ncr", 0)
        )
    ) AS "optimasi_manpower",

    opx."dir_opex_telecom",
    opx."dir_opex_ofc_sup",
    opx."dir_opex_sewa",
    opx."dir_opex_per_din",
    opx."dir_opex_prem_ins_ncr",
    opx."dir_opex_prem_as_cr",
    opx."dir_opex_tran_cr",
    opx."dir_opex_tran_ncr"

FROM opx
LEFT JOIN fbi ON fbi."kode_konsol" = opx."kode_konsol" AND fbi."kode_cabang" = opx."kode_cabang"
LEFT JOIN bbt ON bbt."kode_konsol" = opx."kode_konsol" AND bbt."kode_cabang" = opx."kode_cabang"
LEFT JOIN pbt ON pbt."kode_konsol" = opx."kode_konsol" AND pbt."kode_cabang" = opx."kode_cabang"
LEFT JOIN fi ON fi."kode_konsol" = opx."kode_konsol" AND fi."kode_cabang" = opx."kode_cabang"
LEFT JOIN fc ON fc."kode_konsol" = opx."kode_konsol" AND fc."kode_cabang" = opx."kode_cabang"
LEFT JOIN ckpn ON ckpn."kode_konsol" = opx."kode_konsol" AND ckpn."kode_cabang" = opx."kode_cabang"
;