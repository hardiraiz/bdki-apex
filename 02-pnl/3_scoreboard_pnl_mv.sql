-- SET DEFINE OFF;
-- Main query
WITH
q_unpivot AS (
    SELECT
        "periode",
        "kode_cabang",
        "nama_cabang",
        "kode_konsol",
        "nama_konsol",
        "column_name",
        "nominal"

    FROM BJKT_PNL_SUMMARY_V

    UNPIVOT INCLUDE NULLS (
        "nominal"
        FOR "column_name" IN (

            -- GROUP 1: Avg. Balance Kredit
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

            -- GROUP 2: Pend. Bunga Total
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

            -- GROUP 3: Average Balance DPK
            "total_dpk"                 AS 'AVG_BAL_DPK',
            "dpk_total_konven"          AS 'DPK_KONVEN',
            "dpk_konven_giro"           AS 'DPK_KONVEN_GIRO',
            "dpk_konven_tabungan"       AS 'DPK_KONVEN_TABUNGAN',
            "dpk_konven_deposito"       AS 'DPK_KONVEN_DEPOSITO',
            "dpk_total_syariah"         AS 'DPK_SYARIAH',
            "dpk_syariah_giro"          AS 'DPK_SYARIAH_GIRO',
            "dpk_syariah_tabungan"      AS 'DPK_SYARIAH_TABUNGAN',
            "dpk_syariah_deposito"      AS 'DPK_SYARIAH_DEPOSITO',

            -- GROUP 4: Beban Bunga Total
            "total_beban_bunga"             AS 'BEBAN_BUNGA_TOTAL',
            "beban_bunga_konven"            AS 'BEBAN_BUNGA_KONVEN',
            "beban_bunga_konven_giro"       AS 'BEBAN_BUNGA_KONVEN_GIRO',
            "beban_bunga_konven_tabungan"   AS 'BEBAN_BUNGA_KONVEN_TABUNGAN',
            "beban_bunga_konven_deposito"   AS 'BEBAN_BUNGA_KONVEN_DEPOSITO',
            "beban_bunga_total_syariah"     AS 'BEBAN_BUNGA_SYARIAH',
            "beban_bunga_syariah_giro"      AS 'BEBAN_BUNGA_SYARIAH_GIRO',
            "beban_bunga_syariah_tabungan"  AS 'BEBAN_BUNGA_SYARIAH_TABUNGAN',
            "beban_bunga_syariah_deposito"  AS 'BEBAN_BUNGA_SYARIAH_DEPOSITO',

            -- GROUP 5: FTP Income
            "ftp_income_dpk"            AS 'FTP_INCOME',

            -- GROUP 6: FTP Charge
            "ftp_charge_loan"           AS 'FTP_CHARGE',

            -- GROUP 7: NII-Post FTP
            "nii_post_ftp"              AS 'NII_POST_FTP',

            -- GROUP 8: Fee Based Income
            "fbi_total"             AS 'FBI_TOTAL',
            "fbi_acc_maint"         AS 'FBI_ACC_MAINT',
            "fbi_atm"               AS 'FBI_ATM',
            "fbi_jom"               AS 'FBI_JOM',
            "fbi_edc"               AS 'FBI_EDC',
            "fbi_cms"               AS 'FBI_CMS',
            "fbi_abank"             AS 'FBI_ABANK',
            "fbi_jas_pot"           AS 'FBI_JAS_POT',
            "fbi_bisnis_kartu"      AS 'FBI_BISNIS_KARTU',
            "fbi_bisnis_sdb"        AS 'FBI_BISNIS_SDB',
            "fbi_kirim_uang"        AS 'FBI_KIRIM_UANG',
            "fbi_rest_biaya_kantor" AS 'FBI_REST_BIAYA_KANTOR',
            "fbi_pin_nas_pen"       AS 'FBI_PIN_NAS_PEN',
            "fbi_bank_garansi"      AS 'FBI_BANK_GARANSI',
            "fbi_admin_kredit"      AS 'FBI_ADMIN_KREDIT',
            "fbi_lainnya"           AS 'FBI_LAINNYA',

            -- GROUP 9: Direct OPEX
            "dir_opex_manpower"         AS 'OPEX_MANPOWER',
            "dir_opex_telecom"          AS 'OPEX_TELECOM',
            "dir_opex_ofc_sup"          AS 'OPEX_OFFICE_SUPPLIES',
            "dir_opex_per_din"          AS 'OPEX_PERJALANAN_DINAS',
            "dir_opex_prem_ins_ncr"     AS 'OPEX_PREM_INS_NCR',
            "dir_opex_prem_as_cr"       AS 'OPEX_PREM_AS_CR',
            "dir_opex_tran_cr"          AS 'OPEX_TRAN_CR',
            "dir_opex_tran_ncr"         AS 'OPEX_TRAN_NCR',

            -- GROUP 11: Beban CKPN
            "ckpn_nominal"              AS 'CKPN'
        )
    )
)

SELECT
    "periode",
    "kode_cabang",
    "nama_cabang",
    "kode_konsol",
    "nama_konsol",
    "column_name",
    "nominal",

        -- COLUMN DESC
    CASE
        -- GROUP 1: Avg. Balance Kredit
        WHEN "column_name" = 'AVG_BAL_KREDIT'   THEN 'Avg. Balance Kredit Retail'
        WHEN "column_name" = 'KREDIT_KONVEN'    THEN 'Kredit Konven'
        WHEN "column_name" = 'KREDIT_SYARIAH'   THEN 'Pembiayaan Syariah'

        -- GROUP 2: Pendapatan Bunga
        WHEN "column_name" = 'PEND_BUNGA'       THEN 'Pendapatan Bunga Total'
        WHEN "column_name" = 'BUNGA_KONVEN'     THEN 'Pend. Bunga Konven'
        WHEN "column_name" = 'BUNGA_SYARIAH'    THEN 'Pend. Bunga Syariah'
        
        -- GROUP 3: Avg. Balance DPK
        WHEN "column_name" = 'AVG_BAL_DPK'      THEN 'Average Balance DPK'
        WHEN "column_name" = 'DPK_KONVEN'       THEN 'DPK Konven'
        WHEN "column_name" = 'DPK_SYARIAH'      THEN 'DPK Syariah'

        -- GROUP 4: Beban Bunga
        WHEN "column_name" = 'BEBAN_BUNGA_TOTAL'    THEN 'Beban Bunga Total'
        WHEN "column_name" = 'BEBAN_BUNGA_KONVEN'   THEN 'Beban Bunga Konven'
        WHEN "column_name" = 'BEBAN_BUNGA_SYARIAH'  THEN 'Beban Bunga Syariah'

        -- Subgroup: Produk DPK (dipakai bersama Konven & Syariah)
        WHEN "column_name" IN (
            'DPK_KONVEN_GIRO',
            'DPK_SYARIAH_GIRO',
            'BEBAN_BUNGA_KONVEN_GIRO',
            'BEBAN_BUNGA_SYARIAH_GIRO'
        ) THEN 'Giro'

        WHEN "column_name" IN (
            'DPK_KONVEN_TABUNGAN',
            'DPK_SYARIAH_TABUNGAN',
            'BEBAN_BUNGA_KONVEN_TABUNGAN',
            'BEBAN_BUNGA_SYARIAH_TABUNGAN'
        ) THEN 'Tabungan'

        WHEN "column_name" IN (
            'DPK_KONVEN_DEPOSITO',
            'DPK_SYARIAH_DEPOSITO',
            'BEBAN_BUNGA_KONVEN_DEPOSITO',
            'BEBAN_BUNGA_SYARIAH_DEPOSITO'
        ) THEN 'Deposito'

        -- Subgroup: Produk Kredit (dipakai bersama Konven & Syariah)
        WHEN "column_name" IN (
            'KREDIT_KONVEN_KMG',
            'KREDIT_SYARIAH_KMG',
            'BUNGA_KONVEN_KMG',
            'BUNGA_SYARIAH_KMG'
        ) THEN 'KMG'

        WHEN "column_name" IN (
            'KREDIT_KONVEN_KPR',
            'KREDIT_SYARIAH_KPR',
            'BUNGA_KONVEN_KPR',
            'BUNGA_SYARIAH_KPR'
        ) THEN 'KPR'

        WHEN "column_name" IN (
            'KREDIT_KONVEN_MIKRO',
            'KREDIT_SYARIAH_MIKRO',
            'BUNGA_KONVEN_MIKRO',
            'BUNGA_SYARIAH_MIKRO'
        ) THEN 'Mikro'

        WHEN "column_name" IN (
            'KREDIT_KONVEN_UKM',
            'KREDIT_SYARIAH_UKM',
            'BUNGA_KONVEN_UKM',
            'BUNGA_SYARIAH_UKM'
        ) THEN 'UKM'

        -- GROUP 5-7: FTP & NII
        WHEN "column_name" = 'FTP_INCOME'              THEN 'FTP Income'
        WHEN "column_name" = 'FTP_CHARGE'              THEN 'FTP Charge'
        WHEN "column_name" = 'NII_POST_FTP'            THEN 'NII-Post FTP'

        -- GROUP 8: Fee Based Income
        WHEN "column_name" = 'FBI_TOTAL'               THEN 'Fee Based Income'
        WHEN "column_name" = 'FBI_ACC_MAINT'           THEN 'Account Maintenance'
        WHEN "column_name" = 'FBI_ATM'                 THEN 'ATM'
        WHEN "column_name" = 'FBI_JOM'                 THEN 'Mobile Banking (JOM)'
        WHEN "column_name" = 'FBI_EDC'                 THEN 'EDC'
        WHEN "column_name" = 'FBI_CMS'                 THEN 'CMS'
        WHEN "column_name" = 'FBI_ABANK'               THEN 'JakOne Bank'
        WHEN "column_name" = 'FBI_JAS_POT'             THEN 'Jasa Pemotongan'
        WHEN "column_name" = 'FBI_BISNIS_KARTU'        THEN 'Bisnis Kartu'
        WHEN "column_name" = 'FBI_BISNIS_SDB'          THEN 'Bisnis SDB'
        WHEN "column_name" = 'FBI_KIRIM_UANG'          THEN 'Kiriman Uang'
        WHEN "column_name" = 'FBI_REST_BIAYA_KANTOR'   THEN 'Restitusi Biaya Kantor'
        WHEN "column_name" = 'FBI_PIN_NAS_PEN'         THEN 'Pinalti Nasabah & Penolakan'
        WHEN "column_name" = 'FBI_BANK_GARANSI'        THEN 'Bank Garansi'
        WHEN "column_name" = 'FBI_ADMIN_KREDIT'        THEN 'Admin Kredit'
        WHEN "column_name" = 'FBI_LAINNYA'             THEN 'Lainnya (komisi notaris, denda tunggakan)'

        -- GROUP 9: Direct OPEX
        WHEN "column_name" = 'OPEX_MANPOWER'           THEN 'Manpower'
        WHEN "column_name" = 'OPEX_TELECOM'            THEN 'IT & Telecommunication'
        -- masukkan sewa disini
        WHEN "column_name" = 'OPEX_OFFICE_SUPPLIES'    THEN 'Office Supplies'
        WHEN "column_name" = 'OPEX_PERJALANAN_DINAS'   THEN 'Perjalanan Dinas'
        WHEN "column_name" = 'OPEX_PREM_INS_NCR'       THEN 'Premium Insurance Non-Credit'
        WHEN "column_name" = 'OPEX_PREM_AS_CR'         THEN 'Premi Asuransi Kredit'
        WHEN "column_name" = 'OPEX_TRAN_CR'            THEN 'Transaksi Kredit'
        WHEN "column_name" = 'OPEX_TRAN_NCR'           THEN 'Transaksi Non Kredit'

        -- GROUP 10: PPOP
        -- GROUP 11: CKPN
        WHEN "column_name" = 'CKPN'                    THEN 'Beban CKPN'
        -- GROUP 12: PBT

        ELSE "column_name"  -- fallback
    END AS "column_desc",

    -- GROUP NUMBER
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
        ) THEN 1

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
        ) THEN 2

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
        ) THEN 3

        WHEN "column_name" IN (
            'BEBAN_BUNGA_TOTAL',
            'BEBAN_BUNGA_KONVEN',
            'BEBAN_BUNGA_KONVEN_GIRO',
            'BEBAN_BUNGA_KONVEN_TABUNGAN',
            'BEBAN_BUNGA_KONVEN_DEPOSITO',
            'BEBAN_BUNGA_SYARIAH',
            'BEBAN_BUNGA_SYARIAH_GIRO',
            'BEBAN_BUNGA_SYARIAH_TABUNGAN',
            'BEBAN_BUNGA_SYARIAH_DEPOSITO'
        ) THEN 4

        WHEN "column_name" = 'FTP_INCOME'   THEN 5
        WHEN "column_name" = 'FTP_CHARGE'   THEN 6
        WHEN "column_name" = 'NII_POST_FTP' THEN 7

        WHEN "column_name" IN (
            'FBI_TOTAL',
            'FBI_ACC_MAINT',
            'FBI_ATM',
            'FBI_JOM',
            'FBI_EDC',
            'FBI_CMS',
            'FBI_ABANK',
            'FBI_JAS_POT',
            'FBI_BISNIS_KARTU',
            'FBI_BISNIS_SDB',
            'FBI_KIRIM_UANG',
            'FBI_REST_BIAYA_KANTOR',
            'FBI_PIN_NAS_PEN',
            'FBI_BANK_GARANSI',
            'FBI_ADMIN_KREDIT',
            'FBI_LAINNYA'
        ) THEN 8

        WHEN "column_name" LIKE 'OPEX%' THEN 9
        WHEN "column_name" = 'CKPN'     THEN 10

    END AS "group_number",

    -- IS HEADER
    CASE
        WHEN "column_name" IN (
            'AVG_BAL_KREDIT',
            'AVG_BAL_DPK',
            'PEND_BUNGA',
            'BEBAN_BUNGA_TOTAL',
            'FTP_INCOME',
            'FTP_CHARGE',
            'NII_POST_FTP',
            'FBI_TOTAL',
            'CKPN'
        ) THEN 'Y'
        ELSE 'N'
    END AS "is_header",

    -- IS LINES
    CASE
        WHEN "column_name" IN (
            'KREDIT_KONVEN_KMG',
            'KREDIT_KONVEN_KPR',
            'KREDIT_KONVEN_MIKRO',
            'KREDIT_KONVEN_UKM',
            'KREDIT_SYARIAH_KMG',
            'KREDIT_SYARIAH_KPR',
            'KREDIT_SYARIAH_MIKRO',
            'KREDIT_SYARIAH_UKM',
            'BUNGA_KONVEN_KMG',
            'BUNGA_KONVEN_KPR',
            'BUNGA_KONVEN_MIKRO',
            'BUNGA_KONVEN_UKM',
            'BUNGA_SYARIAH_KMG',
            'BUNGA_SYARIAH_KPR',
            'BUNGA_SYARIAH_MIKRO',
            'BUNGA_SYARIAH_UKM',
            'DPK_KONVEN_GIRO',
            'DPK_KONVEN_TABUNGAN',
            'DPK_KONVEN_DEPOSITO',
            'DPK_SYARIAH_GIRO',
            'DPK_SYARIAH_TABUNGAN',
            'DPK_SYARIAH_DEPOSITO',
            'BEBAN_BUNGA_KONVEN_GIRO',
            'BEBAN_BUNGA_KONVEN_TABUNGAN',
            'BEBAN_BUNGA_KONVEN_DEPOSITO',
            'BEBAN_BUNGA_SYARIAH_GIRO',
            'BEBAN_BUNGA_SYARIAH_TABUNGAN',
            'BEBAN_BUNGA_SYARIAH_DEPOSITO'
        ) THEN 'Y'
        ELSE 'N'
    END AS "is_lines"

FROM q_unpivot
WHERE "kode_cabang" = '108'
ORDER BY
    "group_number",
    "is_header" DESC,
    "column_name";
/
-- 
-- query for Branch Rations, posible action
SELECT
    TO_CHAR(
        ROUND(((pbt."total_pen_bunga" + fc."ftp_charge_loan") / cre."total_kredit") * 100, 1),
        'FM9999999990.0'
    ) AS "interest_income",

    TO_CHAR(
        ROUND(((bbt."total_beban_bunga" + fi."ftp_income_dpk") / dpk."total_dpk") * 100, 1),
        'FM9999999990.0'
    ) AS "cost_of_fund",

    TO_CHAR(
        ROUND(cre."total_kredit" / (cre."total_kredit" + dpk."total_dpk") * 100, 1),
        'FM9999999990.0'
    ) AS "kredit_portofolio",

    (fbi."fbi_total" + nii."nii_post_ftp") 
        AS "total_income"
FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV pbt
LEFT JOIN BJKT_PNL_AVG_BAL_CREDIT_MV cre
    ON  cre."kode_cabang" = pbt."kode_cabang"
    AND cre."periode"     = pbt."periode" 
LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
    ON  dpk."kode_cabang" = pbt."kode_cabang"
    AND dpk."periode"     = pbt."periode"
LEFT JOIN BJKT_PNL_BEBAN_BUNGA_TOTAL_MV bbt
    ON  bbt."kode_cabang" = pbt."kode_cabang"
    AND bbt."periode"     = pbt."periode"
LEFT JOIN BJKT_PNL_FTP_CHARGE_MV fc
    ON  fc."kode_cabang" = pbt."kode_cabang"
    AND fc."periode"     = pbt."periode"
LEFT JOIN BJKT_PNL_FTP_INCOME_MV fi
    ON  fi."kode_cabang" = pbt."kode_cabang"
    AND fi."periode"     = pbt."periode"
LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV fbi
    ON  fbi."kode_cabang" = pbt."kode_cabang"
    AND fbi."periode"     = pbt."periode"
LEFT JOIN BJKT_PNL_NII_POST_FTP_MV nii
    ON  nii."kode_cabang" = pbt."kode_cabang"
    AND nii."periode"     = pbt."periode"
WHERE
    pbt."kode_cabang" = '108';
/