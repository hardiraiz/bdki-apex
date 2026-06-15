DECLARE
    l_from_date DATE;
    l_to_date   DATE;
    l_kc varchar(200);
    l_cabang varchar(200);
BEGIN
    IF apex_application.g_x01 IS NOT NULL THEN l_from_date := TO_DATE(apex_application.g_x01, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH'); END IF;
    IF apex_application.g_x02 IS NOT NULL THEN l_to_date := TO_DATE(apex_application.g_x02, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH') + 1; END IF;
    l_kc := apex_application.g_x03;
    l_cabang := apex_application.g_x04;
    apex_json.initialize_output;
    apex_json.open_array;
    FOR r IN (
        WITH
        q_mapping ("column_name", "column_desc", "group_number", "is_header", "is_lines", "column_number") AS (
            SELECT 'AVG_BAL_KREDIT',              'Avg. Balance Kredit Retail',                1, 'Y', 'N',  1 FROM DUAL UNION ALL
            SELECT 'KREDIT_KONVEN',               'Kredit Konven',                             1, 'N', 'N',  2 FROM DUAL UNION ALL
            SELECT 'KREDIT_KONVEN_KMG',           'KMG',                                       1, 'N', 'Y',  3 FROM DUAL UNION ALL
            SELECT 'KREDIT_KONVEN_KPR',           'KPR',                                       1, 'N', 'Y',  4 FROM DUAL UNION ALL
            SELECT 'KREDIT_KONVEN_MIKRO',         'Mikro',                                     1, 'N', 'Y',  5 FROM DUAL UNION ALL
            SELECT 'KREDIT_KONVEN_UKM',           'UKM',                                       1, 'N', 'Y',  6 FROM DUAL UNION ALL
            SELECT 'KREDIT_SYARIAH',              'Pembiayaan Syariah',                        1, 'N', 'N',  7 FROM DUAL UNION ALL
            SELECT 'KREDIT_SYARIAH_KMG',          'KMG',                                       1, 'N', 'Y',  8 FROM DUAL UNION ALL
            SELECT 'KREDIT_SYARIAH_KPR',          'KPR',                                       1, 'N', 'Y',  9 FROM DUAL UNION ALL
            SELECT 'KREDIT_SYARIAH_MIKRO',        'Mikro',                                     1, 'N', 'Y', 10 FROM DUAL UNION ALL
            SELECT 'KREDIT_SYARIAH_UKM',          'UKM',                                       1, 'N', 'Y', 11 FROM DUAL UNION ALL
            SELECT 'PEND_BUNGA',                  'Pendapatan Bunga/Margin Total',             2, 'Y', 'N', 12 FROM DUAL UNION ALL
            SELECT 'BUNGA_KONVEN',                'Pend. Bunga Konven',                        2, 'N', 'N', 13 FROM DUAL UNION ALL
            SELECT 'BUNGA_KONVEN_KMG',            'KMG',                                       2, 'N', 'Y', 14 FROM DUAL UNION ALL
            SELECT 'BUNGA_KONVEN_KPR',            'KPR',                                       2, 'N', 'Y', 15 FROM DUAL UNION ALL
            SELECT 'BUNGA_KONVEN_MIKRO',          'Mikro',                                     2, 'N', 'Y', 16 FROM DUAL UNION ALL
            SELECT 'BUNGA_KONVEN_UKM',            'UKM',                                       2, 'N', 'Y', 17 FROM DUAL UNION ALL
            SELECT 'BUNGA_SYARIAH',               'Pend. Margin Syariah',                      2, 'N', 'N', 18 FROM DUAL UNION ALL
            SELECT 'BUNGA_SYARIAH_KMG',           'KMG',                                       2, 'N', 'Y', 19 FROM DUAL UNION ALL
            SELECT 'BUNGA_SYARIAH_KPR',           'KPR',                                       2, 'N', 'Y', 20 FROM DUAL UNION ALL
            SELECT 'BUNGA_SYARIAH_MIKRO',         'Mikro',                                     2, 'N', 'Y', 21 FROM DUAL UNION ALL
            SELECT 'BUNGA_SYARIAH_UKM',           'UKM',                                       2, 'N', 'Y', 22 FROM DUAL UNION ALL
            SELECT 'AVG_BAL_DPK',                 'Average Balance DPK',                       3, 'Y', 'N', 23 FROM DUAL UNION ALL
            SELECT 'DPK_KONVEN',                  'DPK Konven',                                3, 'N', 'N', 24 FROM DUAL UNION ALL
            SELECT 'DPK_KONVEN_GIRO',             'Giro',                                      3, 'N', 'Y', 25 FROM DUAL UNION ALL
            SELECT 'DPK_KONVEN_TABUNGAN',         'Tabungan',                                  3, 'N', 'Y', 26 FROM DUAL UNION ALL
            SELECT 'DPK_KONVEN_DEPOSITO',         'Deposito',                                  3, 'N', 'Y', 27 FROM DUAL UNION ALL
            SELECT 'DPK_SYARIAH',                 'DPK Syariah',                               3, 'N', 'N', 28 FROM DUAL UNION ALL
            SELECT 'DPK_SYARIAH_GIRO',            'Giro',                                      3, 'N', 'Y', 29 FROM DUAL UNION ALL
            SELECT 'DPK_SYARIAH_TABUNGAN',        'Tabungan',                                  3, 'N', 'Y', 30 FROM DUAL UNION ALL
            SELECT 'DPK_SYARIAH_DEPOSITO',        'Deposito',                                  3, 'N', 'Y', 31 FROM DUAL UNION ALL
            SELECT 'BEBAN_BUNGA_TOTAL',           'Beban Bunga/Bagi Hasil Total',              4, 'Y', 'N', 32 FROM DUAL UNION ALL
            SELECT 'BEBAN_BUNGA_KONVEN',          'Beban Bunga Konven',                        4, 'N', 'N', 33 FROM DUAL UNION ALL
            SELECT 'BEBAN_BUNGA_KONVEN_GIRO',     'Giro',                                      4, 'N', 'Y', 34 FROM DUAL UNION ALL
            SELECT 'BEBAN_BUNGA_KONVEN_TABUNGAN', 'Tabungan',                                  4, 'N', 'Y', 35 FROM DUAL UNION ALL
            SELECT 'BEBAN_BUNGA_KONVEN_DEPOSITO', 'Deposito',                                  4, 'N', 'Y', 36 FROM DUAL UNION ALL
            SELECT 'BEBAN_BUNGA_SYARIAH',         'Beban Bagi Hasil',                          4, 'N', 'N', 37 FROM DUAL UNION ALL
            SELECT 'BEBAN_BUNGA_SYARIAH_GIRO',    'Giro',                                      4, 'N', 'Y', 38 FROM DUAL UNION ALL
            SELECT 'BEBAN_BUNGA_SYARIAH_TABUNGAN','Tabungan',                                  4, 'N', 'Y', 39 FROM DUAL UNION ALL
            SELECT 'BEBAN_BUNGA_SYARIAH_DEPOSITO','Deposito',                                  4, 'N', 'Y', 40 FROM DUAL UNION ALL
            SELECT 'FTP_INCOME',                  'FTP Income',                                5, 'Y', 'N', 41 FROM DUAL UNION ALL
            SELECT 'FTP_CHARGE',                  'FTP Charge',                                6, 'Y', 'N', 42 FROM DUAL UNION ALL
            SELECT 'NII_POST_FTP',                'NII-Post FTP',                              7, 'Y', 'N', 43 FROM DUAL UNION ALL
            SELECT 'FBI_TOTAL',                   'Fee Based Income',                             8, 'Y', 'N', 44 FROM DUAL UNION ALL
            SELECT 'FBI_ACC_MAINT',               'Account Maintenance',                          8, 'N', 'N', 45 FROM DUAL UNION ALL
            SELECT 'FBI_ATM',                     'ATM',                                          8, 'N', 'N', 46 FROM DUAL UNION ALL
            SELECT 'FBI_JOM',                     'Mobile Banking (JOM)',                         8, 'N', 'N', 47 FROM DUAL UNION ALL
            SELECT 'FBI_EDC',                     'EDC',                                          8, 'N', 'N', 48 FROM DUAL UNION ALL
            SELECT 'FBI_CMS',                     'CMS',                                          8, 'N', 'N', 49 FROM DUAL UNION ALL
            SELECT 'FBI_ABANK',                   'JakOne Bank',                                  8, 'N', 'N', 50 FROM DUAL UNION ALL
            SELECT 'FBI_JAS_POT',                 'Jasa Pemotongan',                              8, 'N', 'N', 51 FROM DUAL UNION ALL
            SELECT 'FBI_BISNIS_KARTU',            'Bisnis Kartu',                                 8, 'N', 'N', 52 FROM DUAL UNION ALL
            SELECT 'FBI_BISNIS_SDB',              'Bisnis SDB',                                   8, 'N', 'N', 53 FROM DUAL UNION ALL
            SELECT 'FBI_KIRIM_UANG',              'Kiriman Uang',                                 8, 'N', 'N', 54 FROM DUAL UNION ALL
            SELECT 'FBI_REST_BIAYA_KANTOR',       'Restitusi Biaya Kantor',                       8, 'N', 'N', 55 FROM DUAL UNION ALL
            SELECT 'FBI_PIN_NAS_PEN',             'Pinalti Nasabah & Penolakan',                  8, 'N', 'N', 56 FROM DUAL UNION ALL
            SELECT 'FBI_SINDIKASI',               'Sindikasi',                                    8, 'N', 'N', 57 FROM DUAL UNION ALL
            SELECT 'FBI_TRADE_FINANCE',           'Trade Finance',                                8, 'N', 'N', 58 FROM DUAL UNION ALL
            SELECT 'FBI_BANK_GARANSI',            'Bank Garansi',                                 8, 'N', 'N', 59 FROM DUAL UNION ALL
            SELECT 'FBI_KER_PIHAK_LAIN',          'Kerjasama Pihak Lain (komisi agen, asuransi)', 8, 'N', 'N', 60 FROM DUAL UNION ALL
            SELECT 'FBI_LAINNYA',                 'Lainnya (komisi notaris, denda tunggakan)',    8, 'N', 'N', 61 FROM DUAL UNION ALL
            SELECT 'OPEX_TOTAL',                  'Direct OPEX',                               9, 'Y', 'N', 62 FROM DUAL UNION ALL
            SELECT 'OPEX_MANPOWER',               'Manpower',                                  9, 'N', 'N', 63 FROM DUAL UNION ALL
            SELECT 'OPEX_TELECOM',                'IT & Telecommunication',                    9, 'N', 'N', 64 FROM DUAL UNION ALL
            SELECT 'OPEX_OFFICE_SUPPLIES',        'Office Supplies',                           9, 'N', 'N', 65 FROM DUAL UNION ALL
            SELECT 'OPEX_PERJALANAN_DINAS',       'Perjalanan Dinas',                          9, 'N', 'N', 66 FROM DUAL UNION ALL
            SELECT 'OPEX_SEWA',                   'Sewa (ATM, kendaraan, bangunan, dll.)',     9, 'N', 'N', 67 FROM DUAL UNION ALL
            SELECT 'OPEX_PREM_INS_NCR',           'Premium Insurance Non-Credit',              9, 'N', 'N', 68 FROM DUAL UNION ALL
            SELECT 'OPEX_PREM_AS_CR',             'Premi Asuransi Kredit',                     9, 'N', 'N', 69 FROM DUAL UNION ALL
            SELECT 'OPEX_TRAN_CR',                'Transaksi Kredit',                          9, 'N', 'N', 70 FROM DUAL UNION ALL
            SELECT 'OPEX_TRAN_NCR',               'Transaksi Non Kredit',                      9, 'N', 'N', 71 FROM DUAL UNION ALL
            SELECT 'PPOP_TOTAL',                  'PPOP (Dir OPEX)',                           10, 'Y', 'N', 72 FROM DUAL UNION ALL
            SELECT 'CKPN_RETAIL',                 'Beban CKPN (Retail. Only)',                 11, 'Y', 'N', 73 FROM DUAL UNION ALL
            SELECT 'CKPN_TOTAL',                  'Beban CKPN (Total)',                        12, 'Y', 'N', 74 FROM DUAL UNION ALL
            SELECT 'PBT_NOMINAL',                 'PBT (Dir OPEX + Retail CKPN)',              13, 'Y', 'N', 75 FROM DUAL
        ),
        cre AS (
            SELECT
                "kode_cabang",
                MAX("nama_cabang") AS "nama_cabang", MAX("kode_konsol") AS "kode_konsol",
                MAX("nama_konsol") AS "nama_konsol", SUM("total_kredit") AS "total_kredit",
                SUM("kredit_total_konven") AS "kredit_total_konven", SUM("kredit_konven_kmg") AS "kredit_konven_kmg",
                SUM("kredit_konven_kpr") AS "kredit_konven_kpr", SUM("kredit_konven_mikro")  AS "kredit_konven_mikro",
                SUM("kredit_konven_ukm") AS "kredit_konven_ukm", SUM("kredit_total_syariah") AS "kredit_total_syariah",
                SUM("kredit_syariah_kmg") AS "kredit_syariah_kmg", SUM("kredit_syariah_kpr") AS "kredit_syariah_kpr",
                SUM("kredit_syariah_mikro") AS "kredit_syariah_mikro", SUM("kredit_syariah_ukm") AS "kredit_syariah_ukm"
            FROM BJKT_PNL_AVG_BAL_CREDIT_MV
            WHERE "periode" >= l_from_date AND "periode" < l_to_date AND "kode_konsol" = l_kc AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        dpk AS (
            SELECT
                "kode_cabang", "kode_konsol",
                SUM("total_dpk") AS "total_dpk", SUM("dpk_total_konven") AS "dpk_total_konven",
                SUM("dpk_konven_giro") AS "dpk_konven_giro", SUM("dpk_konven_tabungan")  AS "dpk_konven_tabungan",
                SUM("dpk_konven_deposito") AS "dpk_konven_deposito", SUM("dpk_total_syariah") AS "dpk_total_syariah",
                SUM("dpk_syariah_giro") AS "dpk_syariah_giro", SUM("dpk_syariah_tabungan") AS "dpk_syariah_tabungan", SUM("dpk_syariah_deposito") AS "dpk_syariah_deposito"
            FROM BJKT_PNL_AVG_BAL_DPK_MV
            WHERE "periode" >= l_from_date AND "periode" < l_to_date AND "kode_konsol" = l_kc AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        pbt AS (
            SELECT
                "kode_cabang", "kode_konsol",
                SUM("total_pen_bunga") AS "total_pen_bunga", SUM("total_bunga_konven") AS "total_bunga_konven", SUM("bunga_konven_kmg") AS "bunga_konven_kmg",
                SUM("bunga_konven_kpr") AS "bunga_konven_kpr", SUM("bunga_konven_mikro") AS "bunga_konven_mikro",
                SUM("bunga_konven_ukm") AS "bunga_konven_ukm", SUM("total_bunga_syariah") AS "total_bunga_syariah",
                SUM("bunga_syariah_kmg") AS "bunga_syariah_kmg", SUM("bunga_syariah_kpr") AS "bunga_syariah_kpr",
                SUM("bunga_syariah_mikro") AS "bunga_syariah_mikro", SUM("bunga_syariah_ukm") AS "bunga_syariah_ukm"
            FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
            WHERE "periode" >= l_from_date AND "periode" < l_to_date AND "kode_konsol" = l_kc AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        bbt AS (
            SELECT
                "kode_cabang", "kode_konsol",
                SUM("total_beban_bunga") AS "total_beban_bunga", SUM("beban_bunga_konven") AS "beban_bunga_konven",
                SUM("beban_bunga_konven_giro") AS "beban_bunga_konven_giro", SUM("beban_bunga_konven_tabungan")  AS "beban_bunga_konven_tabungan",
                SUM("beban_bunga_konven_deposito") AS "beban_bunga_konven_deposito", SUM("beban_bunga_total_syariah") AS "beban_bunga_total_syariah",
                SUM("beban_bunga_syariah_giro") AS "beban_bunga_syariah_giro", SUM("beban_bunga_syariah_tabungan") AS "beban_bunga_syariah_tabungan",
                SUM("beban_bunga_syariah_deposito") AS "beban_bunga_syariah_deposito"
            FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
            WHERE "periode" >= l_from_date AND "periode" < l_to_date AND "kode_konsol" = l_kc AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        fi AS (
            SELECT
                "kode_cabang", "kode_konsol",
                SUM("ftp_income_dpk") AS "ftp_income_dpk"
            FROM BJKT_PNL_FTP_INCOME_MV
            WHERE "periode" >= l_from_date
            AND "periode" < l_to_date
            AND "kode_konsol" = l_kc
            AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        fc AS (
            SELECT
                "kode_cabang", "kode_konsol",
                SUM("ftp_charge_loan") AS "ftp_charge_loan"
            FROM BJKT_PNL_FTP_CHARGE_MV
            WHERE "periode" >= l_from_date
            AND "periode" < l_to_date
            AND "kode_konsol" = l_kc
            AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        fbi AS (
            SELECT
                "kode_cabang", "kode_konsol",
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
            WHERE "periode" >= l_from_date
            AND "periode" < l_to_date
            AND "kode_konsol" = l_kc 
            AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        opx AS (
            SELECT
                "kode_cabang", "kode_konsol",
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
            AND "periode" < l_to_date
            AND "kode_konsol" = l_kc
            AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        ckpn AS (
            SELECT
                "kode_cabang", "kode_konsol",
                SUM("ckpn_nominal") AS "ckpn_nominal"
            FROM BJKT_PNL_BEBAN_CKPN_MV
            WHERE "periode" >= l_from_date
            AND "periode" < l_to_date
            AND "kode_konsol" = l_kc
            AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        ckpn_tot AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("ckpn_nominal") AS "ckpn_nominal"
            FROM BJKT_PNL_BEBAN_CKPN_TOT_MV
            WHERE "periode" >= l_from_date
            AND "periode" <  l_to_date
            AND "kode_konsol" = l_kc
            AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        q_base AS (
            SELECT
                cre."kode_cabang", cre."nama_cabang", cre."kode_konsol", cre."nama_konsol",
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

                ROUND(dpk."total_dpk")              AS "total_dpk",
                ROUND(dpk."dpk_total_konven")       AS "dpk_total_konven",
                ROUND(dpk."dpk_konven_giro")        AS "dpk_konven_giro",
                ROUND(dpk."dpk_konven_tabungan")    AS "dpk_konven_tabungan",
                ROUND(dpk."dpk_konven_deposito")    AS "dpk_konven_deposito",
                ROUND(dpk."dpk_total_syariah")      AS "dpk_total_syariah",
                ROUND(dpk."dpk_syariah_giro")       AS "dpk_syariah_giro",
                ROUND(dpk."dpk_syariah_tabungan")   AS "dpk_syariah_tabungan",
                ROUND(dpk."dpk_syariah_deposito")   AS "dpk_syariah_deposito",

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

                ROUND(bbt."total_beban_bunga")              AS "total_beban_bunga",
                ROUND(bbt."beban_bunga_konven")             AS "beban_bunga_konven",
                ROUND(bbt."beban_bunga_konven_giro")        AS "beban_bunga_konven_giro",
                ROUND(bbt."beban_bunga_konven_tabungan")    AS "beban_bunga_konven_tabungan",
                ROUND(bbt."beban_bunga_konven_deposito")    AS "beban_bunga_konven_deposito",
                ROUND(bbt."beban_bunga_total_syariah")      AS "beban_bunga_total_syariah",
                ROUND(bbt."beban_bunga_syariah_giro")       AS "beban_bunga_syariah_giro",
                ROUND(bbt."beban_bunga_syariah_tabungan")   AS "beban_bunga_syariah_tabungan",
                ROUND(bbt."beban_bunga_syariah_deposito")   AS "beban_bunga_syariah_deposito",

                ROUND(fi."ftp_income_dpk")          AS "ftp_income_dpk",
                ROUND(fc."ftp_charge_loan")         AS "ftp_charge_loan",

                ROUND(
                    NVL(bbt."total_beban_bunga", 0) + NVL(pbt."total_pen_bunga", 0)
                    + NVL(fc."ftp_charge_loan", 0)  + NVL(fi."ftp_income_dpk", 0)
                ) AS "nii_post_ftp",

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
                NULL                                AS "fbi_sindikasi",
                NULL                                AS "fbi_trade_finance",
                ROUND(fbi."fbi_bank_garansi")       AS "fbi_bank_garansi",
                ROUND(fbi."fbi_admin_kredit")       AS "fbi_admin_kredit",
                ROUND(fbi."fbi_ker_pihak_lain")     AS "fbi_ker_pihak_lain",
                ROUND(fbi."fbi_lainnya")            AS "fbi_lainnya",

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

                ROUND(
                    (NVL(bbt."total_beban_bunga",0) + NVL(pbt."total_pen_bunga",0)
                    + NVL(fc."ftp_charge_loan",0) + NVL(fi."ftp_income_dpk",0))
                    + NVL(fbi."fbi_total",0) + NVL(opx."dir_opex_total",0)
                ) AS "ppop_total",

                ROUND(ckpn."ckpn_nominal")          AS "ckpn_nominal",
                ROUND(ckpn_tot."ckpn_nominal")      AS "ckpn_tot",

                ROUND(
                    (NVL(bbt."total_beban_bunga",0) + NVL(pbt."total_pen_bunga",0)
                    + NVL(fc."ftp_charge_loan",0) + NVL(fi."ftp_income_dpk",0))
                    + NVL(fbi."fbi_total",0) + NVL(opx."dir_opex_total",0)
                    + NVL(ckpn."ckpn_nominal",0)
                ) AS "pbt_nominal"

                FROM cre
                LEFT JOIN dpk      ON cre."kode_cabang" = dpk."kode_cabang"
                LEFT JOIN pbt      ON cre."kode_cabang" = pbt."kode_cabang"
                LEFT JOIN bbt      ON cre."kode_cabang" = bbt."kode_cabang"
                LEFT JOIN fi       ON cre."kode_cabang" = fi."kode_cabang"
                LEFT JOIN fc       ON cre."kode_cabang" = fc."kode_cabang"
                LEFT JOIN fbi      ON cre."kode_cabang" = fbi."kode_cabang"
                LEFT JOIN opx      ON cre."kode_cabang" = opx."kode_cabang"
                LEFT JOIN ckpn     ON cre."kode_cabang" = ckpn."kode_cabang"
                LEFT JOIN ckpn_tot ON cre."kode_cabang" = ckpn_tot."kode_cabang"
        )
        SELECT
            u."nominal"         AS nominal,
            m."column_desc"     AS column_name,
            m."group_number"    AS group_number,
            m."is_header"       AS is_header,
            m."is_lines"        AS is_lines
        FROM (
            SELECT "kode_cabang", "nama_cabang", "kode_konsol", "nama_konsol", "column_name", "nominal"
            FROM q_base
            UNPIVOT INCLUDE NULLS (
                "nominal" FOR "column_name" IN (
                    "total_kredit"                  AS 'AVG_BAL_KREDIT',
                    "kredit_total_konven"           AS 'KREDIT_KONVEN',
                    "kredit_konven_kmg"             AS 'KREDIT_KONVEN_KMG',
                    "kredit_konven_kpr"             AS 'KREDIT_KONVEN_KPR',
                    "kredit_konven_mikro"           AS 'KREDIT_KONVEN_MIKRO',
                    "kredit_konven_ukm"             AS 'KREDIT_KONVEN_UKM',
                    "kredit_total_syariah"          AS 'KREDIT_SYARIAH',
                    "kredit_syariah_kmg"            AS 'KREDIT_SYARIAH_KMG',
                    "kredit_syariah_kpr"            AS 'KREDIT_SYARIAH_KPR',
                    "kredit_syariah_mikro"          AS 'KREDIT_SYARIAH_MIKRO',
                    "kredit_syariah_ukm"            AS 'KREDIT_SYARIAH_UKM',
                    "total_pen_bunga"               AS 'PEND_BUNGA',
                    "total_bunga_konven"            AS 'BUNGA_KONVEN',
                    "bunga_konven_kmg"              AS 'BUNGA_KONVEN_KMG',
                    "bunga_konven_kpr"              AS 'BUNGA_KONVEN_KPR',
                    "bunga_konven_mikro"            AS 'BUNGA_KONVEN_MIKRO',
                    "bunga_konven_ukm"              AS 'BUNGA_KONVEN_UKM',
                    "total_bunga_syariah"           AS 'BUNGA_SYARIAH',
                    "bunga_syariah_kmg"             AS 'BUNGA_SYARIAH_KMG',
                    "bunga_syariah_kpr"             AS 'BUNGA_SYARIAH_KPR',
                    "bunga_syariah_mikro"           AS 'BUNGA_SYARIAH_MIKRO',
                    "bunga_syariah_ukm"             AS 'BUNGA_SYARIAH_UKM',
                    "total_dpk"                     AS 'AVG_BAL_DPK',
                    "dpk_total_konven"              AS 'DPK_KONVEN',
                    "dpk_konven_giro"               AS 'DPK_KONVEN_GIRO',
                    "dpk_konven_tabungan"           AS 'DPK_KONVEN_TABUNGAN',
                    "dpk_konven_deposito"           AS 'DPK_KONVEN_DEPOSITO',
                    "dpk_total_syariah"             AS 'DPK_SYARIAH',
                    "dpk_syariah_giro"              AS 'DPK_SYARIAH_GIRO',
                    "dpk_syariah_tabungan"          AS 'DPK_SYARIAH_TABUNGAN',
                    "dpk_syariah_deposito"          AS 'DPK_SYARIAH_DEPOSITO',
                    "total_beban_bunga"             AS 'BEBAN_BUNGA_TOTAL',
                    "beban_bunga_konven"            AS 'BEBAN_BUNGA_KONVEN',
                    "beban_bunga_konven_giro"       AS 'BEBAN_BUNGA_KONVEN_GIRO',
                    "beban_bunga_konven_tabungan"   AS 'BEBAN_BUNGA_KONVEN_TABUNGAN',
                    "beban_bunga_konven_deposito"   AS 'BEBAN_BUNGA_KONVEN_DEPOSITO',
                    "beban_bunga_total_syariah"     AS 'BEBAN_BUNGA_SYARIAH',
                    "beban_bunga_syariah_giro"      AS 'BEBAN_BUNGA_SYARIAH_GIRO',
                    "beban_bunga_syariah_tabungan"  AS 'BEBAN_BUNGA_SYARIAH_TABUNGAN',
                    "beban_bunga_syariah_deposito"  AS 'BEBAN_BUNGA_SYARIAH_DEPOSITO',
                    "ftp_income_dpk"                AS 'FTP_INCOME',
                    "ftp_charge_loan"               AS 'FTP_CHARGE',
                    "nii_post_ftp"                  AS 'NII_POST_FTP',
                    "fbi_total"                     AS 'FBI_TOTAL',
                    "fbi_acc_maint"                 AS 'FBI_ACC_MAINT',
                    "fbi_atm"                       AS 'FBI_ATM',
                    "fbi_jom"                       AS 'FBI_JOM',
                    "fbi_edc"                       AS 'FBI_EDC',
                    "fbi_cms"                       AS 'FBI_CMS',
                    "fbi_abank"                     AS 'FBI_ABANK',
                    "fbi_jas_pot"                   AS 'FBI_JAS_POT',
                    "fbi_bisnis_kartu"              AS 'FBI_BISNIS_KARTU',
                    "fbi_bisnis_sdb"                AS 'FBI_BISNIS_SDB',
                    "fbi_kirim_uang"                AS 'FBI_KIRIM_UANG',
                    "fbi_rest_biaya_kantor"         AS 'FBI_REST_BIAYA_KANTOR',
                    "fbi_pin_nas_pen"               AS 'FBI_PIN_NAS_PEN',
                    "fbi_sindikasi"                 AS 'FBI_SINDIKASI',
                    "fbi_trade_finance"             AS 'FBI_TRADE_FINANCE',
                    "fbi_bank_garansi"              AS 'FBI_BANK_GARANSI',
                    "fbi_admin_kredit"              AS 'FBI_ADMIN_KREDIT',
                    "fbi_ker_pihak_lain"            AS 'FBI_KER_PIHAK_LAIN',
                    "fbi_lainnya"                   AS 'FBI_LAINNYA',
                    "dir_opex_total"                AS 'OPEX_TOTAL',
                    "dir_opex_manpower"             AS 'OPEX_MANPOWER',
                    "dir_opex_telecom"              AS 'OPEX_TELECOM',
                    "dir_opex_ofc_sup"              AS 'OPEX_OFFICE_SUPPLIES',
                    "dir_opex_per_din"              AS 'OPEX_PERJALANAN_DINAS',
                    "dir_opex_sewa"                 AS 'OPEX_SEWA',
                    "dir_opex_prem_ins_ncr"         AS 'OPEX_PREM_INS_NCR',
                    "dir_opex_prem_as_cr"           AS 'OPEX_PREM_AS_CR',
                    "dir_opex_tran_cr"              AS 'OPEX_TRAN_CR',
                    "dir_opex_tran_ncr"             AS 'OPEX_TRAN_NCR',
                    "ckpn_nominal"                  AS 'CKPN_RETAIL',
                    "ckpn_tot"                      AS 'CKPN_TOTAL',
                    "ppop_total"                    AS 'PPOP_TOTAL',
                    "pbt_nominal"                   AS 'PBT_NOMINAL'
                )
            )
        ) u
        JOIN q_mapping m ON m."column_name" = u."column_name"
        ORDER BY u."kode_cabang", m."column_number"
    )
    LOOP
        apex_json.open_object;
        apex_json.write('column_name', r.column_name);
        apex_json.write('nominal', r.nominal);
        apex_json.write('group_number', r.group_number);
        apex_json.write('is_header', r.is_header);
        apex_json.write('is_lines', r.is_lines);
        apex_json.close_object;
    END LOOP;
    apex_json.close_array;
    apex_json.flush;
EXCEPTION
    WHEN OTHERS THEN
        htp.p('sqlerrm:' || SQLERRM);
END;