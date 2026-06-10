DECLARE
    l_from_date DATE;
    l_to_date   DATE;
    l_kc        VARCHAR2(200);
    l_cabang    VARCHAR2(200);
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

    FOR r IN (
        WITH
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
        cre AS (
            SELECT
                "kode_cabang",
                MAX("nama_cabang")          AS "nama_cabang",
                MAX("kode_konsol")          AS "kode_konsol",
                MAX("nama_konsol")          AS "nama_konsol",
                SUM("total_kredit")         AS "total_kredit"
            FROM BJKT_PNL_AVG_BAL_CREDIT_MV
            WHERE "periode" >= l_from_date
            AND "periode" <= l_to_date
            AND "kode_konsol" = l_kc
            AND "kode_cabang" = l_cabang
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        dpk AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("total_dpk")            AS "total_dpk"
            FROM BJKT_PNL_AVG_BAL_DPK_MV
            WHERE "periode" >= l_from_date
            AND "periode" <= l_to_date
            AND "kode_konsol" = l_kc
            AND "kode_cabang" = l_cabang
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        bbt AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("total_beban_bunga")            AS "total_beban_bunga"
            FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
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
        fbi AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("fbi_total")             AS "fbi_total"
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
                SUM("dir_opex_total")        AS "dir_opex_total"
            FROM BJKT_PNL_DIRECT_OPEX_MV
            WHERE "periode" >= l_from_date
            AND "periode" <= l_to_date
            AND "kode_konsol" = l_kc 
            AND "kode_cabang" = l_cabang
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        ckpn AS (
            SELECT
                "kode_cabang",
                "kode_konsol",
                SUM("ckpn_nominal") AS "ckpn_nominal"
            FROM BJKT_PNL_BEBAN_CKPN_MV
            WHERE "periode" >= l_from_date
            AND "periode" <= l_to_date
            AND "kode_konsol" = l_kc 
            AND "kode_cabang" = l_cabang
            GROUP BY "kode_cabang", "kode_konsol"
        ),
        cbng AS (
            SELECT DISTINCT
                "kode_cabang_akhir",
                "kode_konsol",
                "kelas_branch"
            FROM BJKT_BRANCHES_MV
            WHERE "kode_konsol" = l_kc 
            AND "kode_cabang_akhir" = l_cabang
        )
        SELECT
            pbt."kode_cabang",
            cre."nama_cabang",
            pbt."kode_konsol",
            cbng."kelas_branch",

            TO_CHAR(
                ROUND(((pbt."total_pen_bunga" + fc."ftp_charge_loan") / cre."total_kredit") * 100, 1),
                'FM9999999990.0'
            ) AS "interest_income",

            ROUND(((pbt."total_pen_bunga" + fc."ftp_charge_loan") / cre."total_kredit"), 3)
                AS "interest_income_val",

            TO_CHAR(
                ROUND(((bbt."total_beban_bunga" + fi."ftp_income_dpk") / dpk."total_dpk") * 100, 1),
                'FM9999999990.0'
            ) AS "cost_of_fund",

            ROUND(((bbt."total_beban_bunga" + fi."ftp_income_dpk") / dpk."total_dpk"), 3)
                AS "cost_of_fund_val",

            TO_CHAR(
                ROUND(cre."total_kredit" / (cre."total_kredit" + dpk."total_dpk") * 100, 1),
                'FM9999999990.0'
            ) AS "kredit_portofolio",

            ROUND(cre."total_kredit" / (cre."total_kredit" + dpk."total_dpk"), 3)
                AS "kredit_portofolio_val",
            
            ROUND(
                NVL(fbi."fbi_total", 0)
                + NVL(bbt."total_beban_bunga", 0)
                + NVL(pbt."total_pen_bunga",   0)
                + NVL(fc."ftp_charge_loan",   0)
                + NVL(fi."ftp_income_dpk",    0)
            ) AS "total_income",

            ROUND(
                NVL((opx."dir_opex_total"), 0) +
                NVL((ckpn."ckpn_nominal"), 0) +
                NVL((fbi."fbi_total"), 0)
            ) AS "min_nii_nominal",

            ROUND(
                NVL(bbt."total_beban_bunga", 0) + 
                NVL(pbt."total_pen_bunga",   0) + 
                NVL(fc."ftp_charge_loan",   0) +
                NVL(fi."ftp_income_dpk",    0) +
                NVL(fbi."fbi_total" , 0) +
                NVL(opx."dir_opex_total" , 0)
            ) AS "total_ppop"
        FROM pbt
        LEFT JOIN cre
            ON  cre."kode_cabang" = pbt."kode_cabang"
            AND cre."kode_konsol" = pbt."kode_konsol"
        LEFT JOIN dpk
            ON  dpk."kode_cabang" = pbt."kode_cabang"
            AND dpk."kode_konsol" = pbt."kode_konsol"
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
        LEFT JOIN ckpn
            ON  ckpn."kode_cabang" = pbt."kode_cabang"
            AND ckpn."kode_konsol" = pbt."kode_konsol"
        LEFT JOIN cbng
            ON  cbng."kode_cabang_akhir" = pbt."kode_cabang"
            AND cbng."kode_konsol" = pbt."kode_konsol"
        FETCH FIRST 1 ROW ONLY
    )
    LOOP
        apex_json.write('cabang', r."kode_konsol" || ' ' || r."nama_cabang");
        apex_json.write('kategori_lokasi', 'Jabodetabek');
        apex_json.write('kelas_cabang', r."kelas_branch");
        apex_json.write('interest_income', r."interest_income" || '%');
        apex_json.write('cost_of_fund', r."cost_of_fund" || '%');
        apex_json.write('kredit_portofolio', r."kredit_portofolio" || '%');
        -- apex_json.write('avg_manpower', r."avg_manpower");
        apex_json.write('minimum_nii', r."min_nii_nominal");
        apex_json.write('total_income', r."total_income");
        apex_json.write('total_ppop', r."total_ppop");
    END LOOP;

    apex_json.close_object;
    apex_json.flush;

EXCEPTION
    WHEN OTHERS THEN
        apex_json.open_object;
        apex_json.write('error', SQLERRM);
        apex_json.close_object;
END;