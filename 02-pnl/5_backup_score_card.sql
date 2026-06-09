DECLARE
    l_from_date DATE;
    l_to_date   DATE;
    l_kc varchar(200);
    l_cabang varchar(200);
BEGIN

    IF apex_application.g_x01 IS NOT NULL THEN
        l_from_date := TO_DATE(apex_application.g_x01, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH');
    END IF;
    IF apex_application.g_x02 IS NOT NULL THEN
        l_to_date := TO_DATE(apex_application.g_x02, 'DD-MONTH-YYYY', 'NLS_DATE_LANGUAGE=ENGLISH');
    END IF;
    l_kc := apex_application.g_x03;
    l_cabang := apex_application.g_x04;

    apex_json.initialize_output;
    apex_json.open_array;

    FOR r IN (
        SELECT "column_desc" as column_name
              , "nominal" as nominal
              , "group_number" as group_number
              , "is_header" as is_header
              , "is_lines" as is_lines
        FROM BJKT_PNL_SCORE_CARD_V
        WHERE 1=1
          AND "kode_konsol" = l_kc
        --   AND "kode_cabang" = l_cabang
          AND "periode" >= l_from_date
          AND "periode" <= l_to_date
        -- AND "kode_konsol" = nvl(l_kc, "kode_konsol")
        AND "kode_cabang" = nvl(l_cabang, "kode_cabang")
        --   AND (
        --         l_from_date IS NULL
        --         OR "periode" >= l_from_date
        --       )
        --   AND (
        --         l_to_date IS NULL
        --         OR "periode" <= l_to_date
        --       )
        -- ORDER BY "group_number" ASC, "is_header" DESC
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