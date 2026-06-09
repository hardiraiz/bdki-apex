WITH
bbt AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("total_beban_bunga") AS "total_beban_bunga"
    FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
    WHERE "periode" >= l_from_date
    AND "periode" <= l_to_date
    AND "kode_konsol" = l_kc
    AND "kode_cabang" = l_cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
pbt AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        MAX("nama_cabang"),
        SUM("total_pen_bunga")      AS "total_pen_bunga"
    FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
    WHERE "periode" >= l_from_date
    AND "periode" <= l_to_date
    AND "kode_konsol" = l_kc
    AND "kode_cabang" = l_cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
fc AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("ftp_charge_loan") AS "ftp_charge_loan"
    FROM BJKT_PNL_FTP_CHARGE_MV
    WHERE "periode" >= l_from_date
    AND "periode" <= l_to_date
    AND "kode_konsol" = l_kc
    AND "kode_cabang" = l_cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
fi AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("ftp_income_dpk") AS "ftp_income_dpk"
    FROM BJKT_PNL_FTP_INCOME_MV
    WHERE "periode" >= l_from_date
    AND "periode" <= l_to_date
    AND "kode_konsol" = l_kc
    AND "kode_cabang" = l_cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
fbi AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("fbi_total") AS "fbi_total"
    FROM BJKT_PNL_FEE_BASED_INCOME_MV
    WHERE "periode" >= l_from_date
    AND "periode" <= l_to_date
    AND "kode_konsol" = l_kc 
    AND "kode_cabang" = l_cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
opx AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("dir_opex_total") AS "dir_opex_total"
    FROM BJKT_PNL_DIRECT_OPEX_MV
    WHERE "periode" >= l_from_date
    AND "periode" <= l_to_date
    AND "kode_konsol" = l_kc 
    AND "kode_cabang" = l_cabang
    GROUP BY "kode_cabang", "kode_konsol"
),
q_calc AS (
    SELECT
        pbt."kode_konsol",
        pbt."kode_cabang",
        -1 * (
            NVL(bbt."total_beban_bunga", 0) + 
            NVL(pbt."total_pen_bunga",   0) + 
            NVL(fc."ftp_charge_loan",   0) +
            NVL(fi."ftp_income_dpk",    0) +
            NVL(fbi."fbi_total" , 0) +
            NVL(opx."dir_opex_total" , 0)
        ) AS "total_ppop"
    FROM pbt
    LEFT JOIN bbt
        ON  bbt."kode_cabang" = pbt."kode_cabang"
        AND bbt."kode_konsol" = pbt."kode_konsol"
    LEFT JOIN fc
        ON  fc."kode_cabang" = pbt."kode_cabang"
        AND fc."kode_konsol" = pbt."kode_konsol"
    LEFT JOIN fi
        ON  fi."kode_cabang" = pbt."kode_cabang"
        AND fi."kode_konsol" = pbt."kode_konsol"
    LEFT JOIN fbi
        ON  fbi."kode_cabang" = pbt."kode_cabang"
        AND fbi."kode_konsol" = pbt."kode_konsol"
    LEFT JOIN opx
        ON  opx."kode_cabang" = pbt."kode_cabang"
        AND opx."kode_konsol" = pbt."kode_konsol"
),
q_rows AS (
    
)