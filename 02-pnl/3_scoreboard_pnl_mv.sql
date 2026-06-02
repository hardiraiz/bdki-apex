SET DEFINE OFF;
WITH
q_main AS (
    SELECT
        TO_CHAR(cre."periode", 'YYYY-MM-DD') AS "periode",
        cre."kode_cabang",
        cre."nama_cabang",
        cre."kode_konsol",
        cre."nama_konsol",
        
        -- Avg. Balance Credit
        cre."total_kredit",
        cre."kredit_total_konven",
        cre."kredit_konven_kmg",
        cre."kredit_konven_kpr",
        cre."kredit_konven_mikro",
        cre."kredit_konven_ukm",
        cre."kredit_total_syariah",
        cre."kredit_syariah_kmg",
        cre."kredit_syariah_kpr",
        cre."kredit_syariah_mikro",
        cre."kredit_syariah_ukm",

        -- Avg. Balance DPK
        dpk."total_dpk",
        dpk."dpk_total_konven",
        dpk."dpk_konven_giro",
        dpk."dpk_konven_tabungan",
        dpk."dpk_konven_deposito",
        dpk."dpk_total_syariah",
        dpk."dpk_syariah_giro",
        dpk."dpk_syariah_tabungan",
        dpk."dpk_syariah_deposito",

        -- Pend. Bunga
        pbt."total_pen_bunga",
        pbt."total_bunga_konven",
        pbt."bunga_konven_kmg",
        pbt."bunga_konven_kpr",
        pbt."bunga_konven_mikro",
        pbt."bunga_konven_ukm",
        pbt."total_bunga_syariah",
        pbt."bunga_syariah_kmg",
        pbt."bunga_syariah_kpr",
        pbt."bunga_syariah_mikro",
        pbt."bunga_syariah_ukm",

        -- Beban Bunga Total
        bbt."total_beban_bunga",
        bbt."beban_bunga_konven",
        bbt."beban_bunga_konven_giro",
        bbt."beban_bunga_konven_tabungan",
        bbt."beban_bunga_konven_deposito",
        bbt."beban_bunga_total_syariah",
        bbt."beban_bunga_syariah_giro",
        bbt."beban_bunga_syariah_tabungan",
        bbt."beban_bunga_syariah_deposito",

        -- FTP Income
        fi."ftp_income_dpk",

        -- FTP Charge Loan
        fc."ftp_charge_loan",

        -- Fee Based Income
        fbi."fbi_total",
        fbi."fbi_acc_maint",
        fbi."fbi_atm",
        fbi."fbi_jom",
        fbi."fbi_edc",
        fbi."fbi_cms",
        fbi."fbi_abank",
        fbi."fbi_jas_pot",
        fbi."fbi_bisnis_kartu",
        fbi."fbi_bisnis_sdb",
        fbi."fbi_kirim_uang",
        fbi."fbi_rest_biaya_kantor",
        fbi."fbi_pin_nas_pen",
        fbi."fbi_bank_garansi",
        fbi."fbi_admin_kredit",
        fbi."fbi_lainnya",

        -- NII-Post FTP
        nii."nii_post_ftp",

        -- Direct OPEX
        do."dir_opex_manpower",
        do."dir_opex_telecom",
        do."dir_opex_ofc_sup",
        do."dir_opex_per_din",
        do."dir_opex_prem_ins_ncr",
        do."dir_opex_prem_as_cr",
        do."dir_opex_tran_cr",
        do."dir_opex_tran_ncr",

        -- Beban CKPN
        ckpn."ckpn_nominal"

    FROM BJKT_PNL_AVG_BAL_CREDIT_MV cre
    LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
        ON  cre."kode_cabang"       = dpk."kode_cabang"
        AND TRUNC(cre."periode")    = TRUNC(dpk."periode")
    LEFT JOIN BJKT_PNL_PEN_BUNGA_TOTAL_MV pbt
        ON  cre."kode_cabang"       = pbt."kode_cabang"
        AND TRUNC(cre."periode")    = TRUNC(pbt."periode")
    LEFT JOIN BJKT_PNL_BEBAN_BUNGA_TOTAL_MV bbt
        ON  cre."kode_cabang"       = bbt."kode_cabang"
        AND TRUNC(cre."periode")    = TRUNC(bbt."periode")
    LEFT JOIN BJKT_PNL_FTP_INCOME_MV fi
        ON  cre."kode_cabang"       = fi."kode_cabang"
        AND TRUNC(cre."periode")    = TRUNC(fi."periode")
    LEFT JOIN BJKT_PNL_FTP_CHARGE_MV fc
        ON  cre."kode_cabang"       = fc."kode_cabang"
        AND TRUNC(cre."periode")    = TRUNC(fc."periode")
    LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV fbi
        ON  cre."kode_cabang"       = fbi."kode_cabang"
        AND TRUNC(cre."periode")    = TRUNC(fbi."periode")
    LEFT JOIN BJKT_PNL_NII_POST_FTP_MV nii
        ON  cre."kode_cabang"       = nii."kode_cabang"
        AND TRUNC(cre."periode")    = TRUNC(nii."periode")
    LEFT JOIN BJKT_PNL_DIRECT_OPEX_MV do
        ON  cre."kode_cabang"       = do."kode_cabang"
        AND TRUNC(cre."periode")    = TRUNC(do."periode")
    LEFT JOIN BJKT_PNL_BEBAN_CKPN_MV ckpn
        ON  cre."kode_cabang"       = ckpn."kode_cabang"
        AND TRUNC(cre."periode")    = TRUNC(ckpn."periode")
)
-- Final Output
-- GROUP 1 : Avg. Balance Kredit
SELECT 'Avg. Balance Kredit'    AS column_name, m."total_kredit"         AS nominal, 1 AS group_number, 'Y' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Kredit Konven'          AS column_name, m."kredit_total_konven"  AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'KMG'                    AS column_name, m."kredit_konven_kmg"    AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'KPR'                    AS column_name, m."kredit_konven_kpr"    AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Mikro'                  AS column_name, m."kredit_konven_mikro"  AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'UKM'                    AS column_name, m."kredit_konven_ukm"    AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Kredit Syariah'         AS column_name, m."kredit_total_syariah" AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'KMG'                    AS column_name, m."kredit_syariah_kmg"   AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'KPR'                    AS column_name, m."kredit_syariah_kpr"   AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Mikro'                  AS column_name, m."kredit_syariah_mikro" AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'UKM'                    AS column_name, m."kredit_syariah_ukm"   AS nominal, 1 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL

-- GROUP 2 : Avg. Balance DPK
SELECT 'Avg. Balance DPK'       AS column_name, m."total_dpk"            AS nominal, 2 AS group_number, 'Y' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'DPK Konven'             AS column_name, m."dpk_total_konven"     AS nominal, 2 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Giro'                   AS column_name, m."dpk_konven_giro"      AS nominal, 2 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Tabungan'               AS column_name, m."dpk_konven_tabungan"  AS nominal, 2 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Deposito'               AS column_name, m."dpk_konven_deposito"  AS nominal, 2 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'DPK Syariah'            AS column_name, m."dpk_total_syariah"    AS nominal, 2 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Giro'                   AS column_name, m."dpk_syariah_giro"     AS nominal, 2 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Tabungan'               AS column_name, m."dpk_syariah_tabungan" AS nominal, 2 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Deposito'               AS column_name, m."dpk_syariah_deposito" AS nominal, 2 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL

-- GROUP 3 : Pendapatan Bunga
SELECT 'Pendapatan Bunga'       AS column_name, m."total_pen_bunga"      AS nominal, 3 AS group_number, 'Y' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Bunga Konven'           AS column_name, m."total_bunga_konven"   AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'KMG'                    AS column_name, m."bunga_konven_kmg"     AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'KPR'                    AS column_name, m."bunga_konven_kpr"     AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Mikro'                  AS column_name, m."bunga_konven_mikro"   AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'UKM'                    AS column_name, m."bunga_konven_ukm"     AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Bunga Syariah'          AS column_name, m."total_bunga_syariah"  AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'KMG'                    AS column_name, m."bunga_syariah_kmg"    AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'KPR'                    AS column_name, m."bunga_syariah_kpr"    AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Mikro'                  AS column_name, m."bunga_syariah_mikro"  AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'UKM'                    AS column_name, m."bunga_syariah_ukm"    AS nominal, 3 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL

-- GROUP 4 & 5 : FTP
SELECT 'FTP Income DPK'         AS column_name, m."ftp_income_dpk"       AS nominal, 4 AS group_number, 'Y' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'FTP Charge Loan'        AS column_name, m."ftp_charge_loan"      AS nominal, 5 AS group_number, 'Y' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL

-- GROUP 5 : Direct OPEX
SELECT 'Direct OPEX'                   AS column_name, 0                          AS nominal, 6 AS group_number, 'Y' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Manpower'                      AS column_name, m."dir_opex_manpower"      AS nominal, 6 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'IT & Telecommunication'        AS column_name, m."dir_opex_telecom"       AS nominal, 6 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Office Supplies'               AS column_name, m."dir_opex_ofc_sup"       AS nominal, 6 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Perjalanan Dinas'              AS column_name, m."dir_opex_per_din"       AS nominal, 6 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Premium Insurance Non-Credit'  AS column_name, m."dir_opex_prem_ins_ncr"  AS nominal, 6 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Premi Asuransi Kredit'         AS column_name, m."dir_opex_prem_as_cr"    AS nominal, 6 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Transaksi Kredit'              AS column_name, m."dir_opex_tran_cr"       AS nominal, 6 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL
SELECT 'Transaksi Non Kredit'          AS column_name, m."dir_opex_tran_ncr"      AS nominal, 6 AS group_number, 'N' AS is_header FROM q_main m WHERE m."kode_cabang" = '108' UNION ALL

-- GROUP 6 : Beban CKPN
SELECT 'Beban CKPN'             AS column_name, m."ckpn_nominal"         AS nominal, 7 AS group_number, 'Y' AS is_header FROM q_main m WHERE m."kode_cabang" = '108'

ORDER BY group_number ASC, is_header DESC;
/
--
--
WITH
q_unpivot AS (
    SELECT
        "periode",
        "kode_cabang",
        "nama_cabang",
        "column_name",
        "nominal"

    FROM BJKT_PNL_SUMMARY_V

    UNPIVOT (
        "nominal"
        FOR "column_name" IN (

            -- GROUP 1
            "total_kredit"              AS 'AVG_BAL_KREDIT',
            "kredit_total_konven"       AS 'KREDIT_KONVEN',
            "kredit_konven_kmg"         AS 'KREDIT_KONVEN_KMG',
            "kredit_konven_kpr"         AS 'KREDIT_KONVEN_KPR',
            "kredit_konven_mikro"       AS 'KREDIT_KONVEN_MIKRO',
            "kredit_konven_ukm"         AS 'KREDIT_KONVEN_UKM',
            "kredit_total_syariah"      AS 'KREDIT_SYARIAH',
            "kredit_syariah_kmg"        AS 'KREDIT_SYARIAH_KMG',
            "kredit_syariah_kpr"        AS 'KREDIT_SYARIAH_KPR',
            "kredit_syariah_mikro"      AS 'KREDIT_SYARIAH_MIKRO',
            "kredit_syariah_ukm"        AS 'KREDIT_SYARIAH_UKM',

            -- GROUP 2
            "total_dpk"                 AS 'AVG_BAL_DPK',
            "dpk_total_konven"          AS 'DPK_KONVEN',
            "dpk_konven_giro"           AS 'DPK_KONVEN_GIRO',
            "dpk_konven_tabungan"       AS 'DPK_KONVEN_TABUNGAN',
            "dpk_konven_deposito"       AS 'DPK_KONVEN_DEPOSITO',
            "dpk_total_syariah"         AS 'DPK_SYARIAH',
            "dpk_syariah_giro"          AS 'DPK_SYARIAH_GIRO',
            "dpk_syariah_tabungan"      AS 'DPK_SYARIAH_TABUNGAN',
            "dpk_syariah_deposito"      AS 'DPK_SYARIAH_DEPOSITO',

            -- GROUP 3
            "total_pen_bunga"           AS 'PEND_BUNGA',
            "total_bunga_konven"        AS 'BUNGA_KONVEN',
            "bunga_konven_kmg"          AS 'BUNGA_KONVEN_KMG',
            "bunga_konven_kpr"          AS 'BUNGA_KONVEN_KPR',
            "bunga_konven_mikro"        AS 'BUNGA_KONVEN_MIKRO',
            "bunga_konven_ukm"          AS 'BUNGA_KONVEN_UKM',
            "total_bunga_syariah"       AS 'BUNGA_SYARIAH',
            "bunga_syariah_kmg"         AS 'BUNGA_SYARIAH_KMG',
            "bunga_syariah_kpr"         AS 'BUNGA_SYARIAH_KPR',
            "bunga_syariah_mikro"       AS 'BUNGA_SYARIAH_MIKRO',
            "bunga_syariah_ukm"         AS 'BUNGA_SYARIAH_UKM',

            -- GROUP 4
            "ftp_income_dpk"            AS 'FTP_INCOME',

            -- GROUP 5
            "ftp_charge_loan"           AS 'FTP_CHARGE',

            -- GROUP 6
            "dir_opex_manpower"         AS 'OPEX_MANPOWER',
            "dir_opex_telecom"          AS 'OPEX_TELECOM',
            "dir_opex_ofc_sup"          AS 'OPEX_OFFICE_SUPPLIES',
            "dir_opex_per_din"          AS 'OPEX_PERJALANAN_DINAS',
            "dir_opex_prem_ins_ncr"     AS 'OPEX_PREM_INS_NCR',
            "dir_opex_prem_as_cr"       AS 'OPEX_PREM_AS_CR',
            "dir_opex_tran_cr"          AS 'OPEX_TRAN_CR',
            "dir_opex_tran_ncr"         AS 'OPEX_TRAN_NCR',

            -- GROUP 7
            "ckpn_nominal"              AS 'CKPN'
        )
    )
)

SELECT
    "periode" AS "periode",
    "kode_cabang",
    "nama_cabang",

    "column_name",
    "nominal",

    CASE
        WHEN "column_name" IN (
            'AVG_BAL_KREDIT',
            'KREDIT_KONVEN',
            'KREDIT_KONVEN_KMG',
            'KREDIT_KONVEN_KPR',
            'KREDIT_KONVEN_MIKRO',
            'KREDIT_KONVEN_UKM',
            'KREDIT_SYARIAH',
            'KREDIT_SYARIAH_KMG',
            'KREDIT_SYARIAH_KPR',
            'KREDIT_SYARIAH_MIKRO',
            'KREDIT_SYARIAH_UKM'
        )
        THEN 1

        WHEN "column_name" IN (
            'AVG_BAL_DPK',
            'DPK_KONVEN',
            'DPK_KONVEN_GIRO',
            'DPK_KONVEN_TABUNGAN',
            'DPK_KONVEN_DEPOSITO',
            'DPK_SYARIAH',
            'DPK_SYARIAH_GIRO',
            'DPK_SYARIAH_TABUNGAN',
            'DPK_SYARIAH_DEPOSITO'
        )
        THEN 2

        WHEN "column_name" IN (
            'PEND_BUNGA',
            'BUNGA_KONVEN',
            'BUNGA_KONVEN_KMG',
            'BUNGA_KONVEN_KPR',
            'BUNGA_KONVEN_MIKRO',
            'BUNGA_KONVEN_UKM',
            'BUNGA_SYARIAH',
            'BUNGA_SYARIAH_KMG',
            'BUNGA_SYARIAH_KPR',
            'BUNGA_SYARIAH_MIKRO',
            'BUNGA_SYARIAH_UKM'
        )
        THEN 3

        WHEN "column_name" = 'FTP_INCOME'
        THEN 4

        WHEN "column_name" = 'FTP_CHARGE'
        THEN 5

        WHEN "column_name" LIKE 'OPEX%'
        THEN 6

        WHEN "column_name" = 'CKPN'
        THEN 7

    END AS "group_number",

    CASE
        WHEN "column_name" IN (
            'AVG_BAL_KREDIT',
            'AVG_BAL_DPK',
            'PEND_BUNGA',
            'FTP_INCOME',
            'FTP_CHARGE',
            'CKPN'
        )
        THEN 'Y'
        ELSE 'N'
    END AS "is_header"

FROM q_unpivot

WHERE "kode_cabang" = '108'

ORDER BY
    "group_number",
    "is_header" DESC,
    "column_name";