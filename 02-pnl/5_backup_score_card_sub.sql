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
        SELECT *
        FROM BJKT_PNL_SCORE_CARD_SUB_V
        WHERE "kode_konsol" = l_kc
          AND "kode_cabang" = l_cabang
          AND "periode" >= l_from_date
          AND "periode" <= l_to_date
        -- WHERE "kode_konsol" = NVL(l_kc, "kode_konsol")
        --   AND "kode_cabang" = NVL(l_cabang, "kode_cabang")
        --   AND (l_from_date IS NULL OR "periode" >= l_from_date)
        --   AND (l_to_date IS NULL OR "periode" <= l_to_date)
        FETCH FIRST 1 ROW ONLY
    )
    LOOP
        apex_json.write('cabang', r."kode_konsol" || ' ' || r."nama_cabang");
        -- apex_json.write('kategori_lokasi', r."kategori_lokasi");
        -- apex_json.write('kelas_cabang', r."kelas_cabang");
        apex_json.write('interest_income', r."interest_income" || '%');
        apex_json.write('cost_of_fund', r."cost_of_fund" || '%');
        apex_json.write('kredit_portofolio', r."kredit_portofolio" || '%');
        -- apex_json.write('avg_manpower', r."avg_manpower");
        -- apex_json.write('minimum_nii', r."minimum_nii");
        apex_json.write('total_income', r."total_income");
        -- apex_json.write('total_ppop', r."total_ppop");
    END LOOP;

    apex_json.close_object;
    apex_json.flush;

EXCEPTION
    WHEN OTHERS THEN
        apex_json.open_object;
        apex_json.write('error', SQLERRM);
        apex_json.close_object;
END;