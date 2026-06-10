WITH 
cre AS (
    SELECT
        "kode_cabang",
        MAX("nama_cabang")          AS "nama_cabang",
        MAX("kode_konsol")          AS "kode_konsol",
        MAX("nama_konsol")          AS "nama_konsol",
        SUM("total_kredit")         AS "total_kredit",
        SUM("kredit_total_konven")  AS "kredit_total_konven",
        SUM("kredit_konven_kmg")    AS "kredit_konven_kmg",
        SUM("kredit_konven_kpr")    AS "kredit_konven_kpr",
        SUM("kredit_konven_mikro")  AS "kredit_konven_mikro",
        SUM("kredit_konven_ukm")    AS "kredit_konven_ukm",
        SUM("kredit_total_syariah") AS "kredit_total_syariah",
        SUM("kredit_syariah_kmg")   AS "kredit_syariah_kmg",
        SUM("kredit_syariah_kpr")   AS "kredit_syariah_kpr",
        SUM("kredit_syariah_mikro") AS "kredit_syariah_mikro",
        SUM("kredit_syariah_ukm")   AS "kredit_syariah_ukm"
    FROM BJKT_PNL_AVG_BAL_CREDIT_MV
    WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
      AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
    GROUP BY "kode_cabang", "kode_konsol"
),
dpk AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("total_dpk")            AS "total_dpk",
        SUM("dpk_total_konven")     AS "dpk_total_konven",
        SUM("dpk_konven_giro")      AS "dpk_konven_giro",
        SUM("dpk_konven_tabungan")  AS "dpk_konven_tabungan",
        SUM("dpk_konven_deposito")  AS "dpk_konven_deposito",
        SUM("dpk_total_syariah")    AS "dpk_total_syariah",
        SUM("dpk_syariah_giro")     AS "dpk_syariah_giro",
        SUM("dpk_syariah_tabungan") AS "dpk_syariah_tabungan",
        SUM("dpk_syariah_deposito") AS "dpk_syariah_deposito"
    FROM BJKT_PNL_AVG_BAL_DPK_MV
    WHERE "periode" >= TO_DATE(:P1000_PERIOD_FROM, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH')
      AND "periode" <  TO_DATE(:P1000_PERIOD_TO, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1
      AND "kode_konsol" = NVL(:P1000_KC, "kode_konsol")
      AND "kode_cabang" = NVL(:P1000_CABANG, "kode_cabang")
    GROUP BY "kode_cabang", "kode_konsol"
),
pbt AS (
    SELECT
        "kode_cabang",
        "kode_konsol",
        SUM("total_pen_bunga")      AS "total_pen_bunga",
        SUM("total_bunga_konven")   AS "total_bunga_konven",
        SUM("bunga_konven_kmg")     AS "bunga_konven_kmg",
        SUM("bunga_konven_kpr")     AS "bunga_konven_kpr",
        SUM("bunga_konven_mikro")   AS "bunga_konven_mikro",
        SUM("bunga_konven_ukm")     AS "bunga_konven_ukm",
        SUM("total_bunga_syariah")  AS "total_bunga_syariah",
        SUM("bunga_syariah_kmg")    AS "bunga_syariah_kmg",
        SUM("bunga_syariah_kpr")    AS "bunga_syariah_kpr",
        SUM("bunga_syariah_mikro")  AS "bunga_syariah_mikro",
        SUM("bunga_syariah_ukm")    AS "bunga_syariah_ukm"
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
        SUM("total_beban_bunga")            AS "total_beban_bunga",
        SUM("beban_bunga_konven")           AS "beban_bunga_konven",
        SUM("beban_bunga_konven_giro")      AS "beban_bunga_konven_giro",
        SUM("beban_bunga_konven_tabungan")  AS "beban_bunga_konven_tabungan",
        SUM("beban_bunga_konven_deposito")  AS "beban_bunga_konven_deposito",
        SUM("beban_bunga_total_syariah")    AS "beban_bunga_total_syariah",
        SUM("beban_bunga_syariah_giro")     AS "beban_bunga_syariah_giro",
        SUM("beban_bunga_syariah_tabungan") AS "beban_bunga_syariah_tabungan",
        SUM("beban_bunga_syariah_deposito") AS "beban_bunga_syariah_deposito"
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
        SUM("fbi_total")             AS "fbi_total",
        SUM("fbi_acc_maint")         AS "fbi_acc_maint",
        SUM("fbi_atm")               AS "fbi_atm",
        SUM("fbi_jom")               AS "fbi_jom",
        SUM("fbi_edc")               AS "fbi_edc",
        SUM("fbi_cms")               AS "fbi_cms",
        SUM("fbi_abank")             AS "fbi_abank",
        SUM("fbi_jas_pot")           AS "fbi_jas_pot",
        SUM("fbi_bisnis_kartu")      AS "fbi_bisnis_kartu",
        SUM("fbi_bisnis_sdb")        AS "fbi_bisnis_sdb",
        SUM("fbi_kirim_uang")        AS "fbi_kirim_uang",
        SUM("fbi_rest_biaya_kantor") AS "fbi_rest_biaya_kantor",
        SUM("fbi_pin_nas_pen")       AS "fbi_pin_nas_pen",
        SUM("fbi_bank_garansi")      AS "fbi_bank_garansi",
        SUM("fbi_admin_kredit")      AS "fbi_admin_kredit",
        SUM("fbi_ker_pihak_lain")    AS "fbi_ker_pihak_lain",
        SUM("fbi_lainnya")           AS "fbi_lainnya"
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
    ROW_NUMBER() OVER (ORDER BY cre."kode_cabang") AS "No",
    cre."kode_cabang",
    cre."nama_cabang",
    cre."kode_konsol",
    cre."nama_konsol",

    -- Avg. Balance Kredit
    ROUND(cre."total_kredit")           AS "total_kredit",
    ROUND(cre."kredit_total_konven")    AS "kredit_total_konven",
    ROUND(cre."kredit_konven_kmg")      AS "kredit_konven_kmg",
    ROUND(cre."kredit_konven_kpr")      AS "kredit_konven_kpr",
    ROUND(cre."kredit_konven_mikro")    AS "kredit_konven_mikro",
    ROUND(cre."kredit_konven_ukm")      AS "kredit_konven_ukm",
    ROUND(cre."kredit_total_syariah")   AS "kredit_total_syariah",
    ROUND(cre."kredit_syariah_kmg")     AS "kredit_syariah_kmg",
    ROUND(cre."kredit_syariah_kpr")     AS "kredit_syariah_kpr",
    ROUND(cre."kredit_syariah_mikro")   AS "kredit_syariah_mikro",
    ROUND(cre."kredit_syariah_ukm")     AS "kredit_syariah_ukm",

    -- Avg. Balance DPK
    ROUND(dpk."total_dpk")              AS "total_dpk",
    ROUND(dpk."dpk_total_konven")       AS "dpk_total_konven",
    ROUND(dpk."dpk_konven_giro")        AS "dpk_konven_giro",
    ROUND(dpk."dpk_konven_tabungan")    AS "dpk_konven_tabungan",
    ROUND(dpk."dpk_konven_deposito")    AS "dpk_konven_deposito",
    ROUND(dpk."dpk_total_syariah")      AS "dpk_total_syariah",
    ROUND(dpk."dpk_syariah_giro")       AS "dpk_syariah_giro",
    ROUND(dpk."dpk_syariah_tabungan")   AS "dpk_syariah_tabungan",
    ROUND(dpk."dpk_syariah_deposito")   AS "dpk_syariah_deposito",

    -- Pendapatan Bunga
    ROUND(pbt."total_pen_bunga")        AS "total_pen_bunga",
    ROUND(pbt."total_bunga_konven")     AS "total_bunga_konven",
    ROUND(pbt."bunga_konven_kmg")       AS "bunga_konven_kmg",
    ROUND(pbt."bunga_konven_kpr")       AS "bunga_konven_kpr",
    ROUND(pbt."bunga_konven_mikro")     AS "bunga_konven_mikro",
    ROUND(pbt."bunga_konven_ukm")       AS "bunga_konven_ukm",
    ROUND(pbt."total_bunga_syariah")    AS "total_bunga_syariah",
    ROUND(pbt."bunga_syariah_kmg")      AS "bunga_syariah_kmg",
    ROUND(pbt."bunga_syariah_kpr")      AS "bunga_syariah_kpr",
    ROUND(pbt."bunga_syariah_mikro")    AS "bunga_syariah_mikro",
    ROUND(pbt."bunga_syariah_ukm")      AS "bunga_syariah_ukm",

    -- Beban Bunga
    ROUND(bbt."total_beban_bunga")              AS "total_beban_bunga",
    ROUND(bbt."beban_bunga_konven")             AS "beban_bunga_konven",
    ROUND(bbt."beban_bunga_konven_giro")        AS "beban_bunga_konven_giro",
    ROUND(bbt."beban_bunga_konven_tabungan")    AS "beban_bunga_konven_tabungan",
    ROUND(bbt."beban_bunga_konven_deposito")    AS "beban_bunga_konven_deposito",
    ROUND(bbt."beban_bunga_total_syariah")      AS "beban_bunga_total_syariah",
    ROUND(bbt."beban_bunga_syariah_giro")       AS "beban_bunga_syariah_giro",
    ROUND(bbt."beban_bunga_syariah_tabungan")   AS "beban_bunga_syariah_tabungan",
    ROUND(bbt."beban_bunga_syariah_deposito")   AS "beban_bunga_syariah_deposito",

    -- FTP
    ROUND(fi."ftp_income_dpk")          AS "ftp_income_dpk",
    ROUND(fc."ftp_charge_loan")         AS "ftp_charge_loan",

    -- NII-Post FTP
    ROUND(
        NVL(bbt."total_beban_bunga", 0) + NVL(pbt."total_pen_bunga", 0)
        + NVL(fc."ftp_charge_loan", 0) + NVL(fi."ftp_income_dpk", 0)
    ) AS "nii_post_ftp",

    -- Fee Based Income
    ROUND(fbi."fbi_total")              AS "fbi_total",
    ROUND(fbi."fbi_acc_maint")          AS "fbi_acc_maint",
    ROUND(fbi."fbi_atm")                AS "fbi_atm",
    ROUND(fbi."fbi_jom")                AS "fbi_jom",
    ROUND(fbi."fbi_edc")                AS "fbi_edc",
    ROUND(fbi."fbi_cms")                AS "fbi_cms",
    ROUND(fbi."fbi_abank")              AS "fbi_abank",
    ROUND(fbi."fbi_jas_pot")            AS "fbi_jas_pot",
    ROUND(fbi."fbi_bisnis_kartu")       AS "fbi_bisnis_kartu",
    ROUND(fbi."fbi_bisnis_sdb")         AS "fbi_bisnis_sdb",
    ROUND(fbi."fbi_kirim_uang")         AS "fbi_kirim_uang",
    ROUND(fbi."fbi_rest_biaya_kantor")  AS "fbi_rest_biaya_kantor",
    ROUND(fbi."fbi_pin_nas_pen")        AS "fbi_pin_nas_pen",
    ROUND(fbi."fbi_bank_garansi")       AS "fbi_bank_garansi",
    ROUND(fbi."fbi_admin_kredit")       AS "fbi_admin_kredit",
    ROUND(fbi."fbi_ker_pihak_lain")     AS "fbi_ker_pihak_lain",
    ROUND(fbi."fbi_lainnya")            AS "fbi_lainnya",

    -- Direct OPEX
    ROUND(opx."dir_opex_total")         AS "dir_opex_total",
    ROUND(opx."dir_opex_manpower")      AS "dir_opex_manpower",
    ROUND(opx."dir_opex_telecom")       AS "dir_opex_telecom",
    ROUND(opx."dir_opex_ofc_sup")       AS "dir_opex_ofc_sup",
    ROUND(opx."dir_opex_sewa")          AS "dir_opex_sewa",
    ROUND(opx."dir_opex_per_din")       AS "dir_opex_per_din",
    ROUND(opx."dir_opex_prem_ins_ncr")  AS "dir_opex_prem_ins_ncr",
    ROUND(opx."dir_opex_prem_as_cr")    AS "dir_opex_prem_as_cr",
    ROUND(opx."dir_opex_tran_cr")       AS "dir_opex_tran_cr",
    ROUND(opx."dir_opex_tran_ncr")      AS "dir_opex_tran_ncr",

    -- PPOP (sudah ada alias)
    ROUND(
        (NVL(bbt."total_beban_bunga",0) + NVL(pbt."total_pen_bunga",0)
        + NVL(fc."ftp_charge_loan",0) + NVL(fi."ftp_income_dpk",0))
        + NVL(fbi."fbi_total",0) + NVL(opx."dir_opex_total",0)
    ) AS "ppop_total",

    -- CKPN
    ROUND(ckpn."ckpn_nominal")          AS "ckpn_nominal",

    -- PBT (sudah ada alias)
    ROUND(
        (NVL(bbt."total_beban_bunga",0) + NVL(pbt."total_pen_bunga",0)
        + NVL(fc."ftp_charge_loan",0) + NVL(fi."ftp_income_dpk",0))
        + NVL(fbi."fbi_total",0) + NVL(opx."dir_opex_total",0)
        + NVL(ckpn."ckpn_nominal",0)
    ) AS "pbt_nominal"

FROM cre
LEFT JOIN dpk  ON cre."kode_cabang" = dpk."kode_cabang" AND cre."kode_konsol"  = dpk."kode_konsol"
LEFT JOIN pbt  ON cre."kode_cabang" = pbt."kode_cabang" AND cre."kode_konsol"  = pbt."kode_konsol"
LEFT JOIN bbt  ON cre."kode_cabang" = bbt."kode_cabang" AND cre."kode_konsol"  = bbt."kode_konsol"
LEFT JOIN fi   ON cre."kode_cabang" = fi."kode_cabang" AND cre."kode_konsol"   = fi."kode_konsol"
LEFT JOIN fc   ON cre."kode_cabang" = fc."kode_cabang" AND cre."kode_konsol"   = fc."kode_konsol"
LEFT JOIN fbi  ON cre."kode_cabang" = fbi."kode_cabang" AND cre."kode_konsol"  = fbi."kode_konsol"
LEFT JOIN opx  ON cre."kode_cabang" = opx."kode_cabang" AND cre."kode_konsol"  = opx."kode_konsol"
LEFT JOIN ckpn ON cre."kode_cabang" = ckpn."kode_cabang" AND cre."kode_konsol" = ckpn."kode_konsol"
;