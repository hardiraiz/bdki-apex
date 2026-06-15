SELECT SYS_CONTEXT('USERENV', 'SESSION_USER') AS username
FROM dual;
/

BEGIN
    BJKT_PNL_FILTER_CTX_PKG.SET_USER_CONTEXT(
        p_username    => :APP_USER,
        p_feature     => 'SUMMARY',
        p_start_date  => :P1000_PERIOD_FROM,
        p_end_date    => :P1000_PERIOD_TO,
        p_kode_konsol => :P1000_KC,
        p_kode_cabang => :P1000_CABANG
    );
END;
/

BEGIN
    BJKT_PNL_FILTER_CTX_PKG.SET_USER_CONTEXT(
        p_username    => :APP_USER,
        p_feature     => 'SCORECARD',
        p_start_date  => :P1000_PERIOD_FROM,
        p_end_date    => :P1000_PERIOD_TO,
        p_kode_konsol => :P1000_KC,
        p_kode_cabang => :P1000_CABANG
    );
END;
/

SELECT
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SUMMARY_USERNAME')    AS username,
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SUMMARY_START_DATE')  AS start_date,
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SUMMARY_END_DATE')    AS end_date,
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SUMMARY_KODE_KONSOL') AS kode_konsol,
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SUMMARY_KODE_CABANG') AS kode_cabang
FROM DUAL;
/

SELECT
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SCORECARD_USERNAME')    AS username,
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SCORECARD_START_DATE')  AS start_date,
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SCORECARD_END_DATE')    AS end_date,
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SCORECARD_KODE_KONSOL') AS kode_konsol,
    SYS_CONTEXT('BJKT_PNL_FILTER_CTX', 'SCORECARD_KODE_CABANG') AS kode_cabang
FROM DUAL;
/

SELECT * FROM BJKT_PNL_SUMMARY_V2_V;
/