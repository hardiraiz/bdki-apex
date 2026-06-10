/*
    -- START SCHEDULER --
    Scheduler => Tanggal 1–5 Jam 03:00 AM
*/ 
BEGIN
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(job_name => 'JOB_MV_REFRESH_MONTHLY');
    EXCEPTION
        WHEN OTHERS THEN NULL;
    END;

    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_MV_REFRESH_MONTHLY',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN BJKT_PNL_REFRESH_DATA_PKG.REFRESH_ALL_REGISTERED; END;',

        start_date      => TRUNC(SYSDATE, 'MM') + INTERVAL '3' HOUR,

        repeat_interval => 'FREQ=MONTHLY; BYMONTHDAY=1,2,3,4,5; BYHOUR=3; BYMINUTE=0; BYSECOND=0',

        end_date        => NULL,
        enabled         => TRUE,
        auto_drop       => FALSE,
        comments        => 'Refresh semua Materialized View terdaftar, tanggal 1-5 jam 03:00'
    );

    DBMS_OUTPUT.PUT_LINE('Scheduler JOB_MV_REFRESH_MONTHLY berhasil dibuat.');
END;
/
/
/*
    -- END SCHEDULER --
*/ 

/*
    -- START --
    Query Monitoring
*/
-- Cek status job scheduler
SELECT
    job_name,
    enabled,
    state,
    last_start_date,
    last_run_duration,
    next_run_date,
    run_count,
    failure_count
FROM dba_scheduler_jobs
WHERE job_name = 'JOB_MV_REFRESH_MONTHLY';
/
-- Cek configurasi refresh MV
SELECT * FROM BJKT_PNL_REFRESH_CONFIG;
/
-- Cek history log refresh MV
SELECT
    mv_name,
    TO_CHAR(refresh_start, 'DD-MON-YYYY HH24:MI:SS')   AS start_time,
    TO_CHAR(refresh_end,   'DD-MON-YYYY HH24:MI:SS')   AS end_time,
    duration_sec,
    status,
    error_message
FROM BJKT_PNL_REFRESH_LOG
ORDER BY refresh_start DESC;
/
-- Cek MV mana yang sering gagal
SELECT
    mv_name,
    COUNT(*)                                     AS total_run,
    SUM(CASE WHEN status = 'SUCCESS' THEN 1 END) AS success_count,
    SUM(CASE WHEN status = 'FAILED'  THEN 1 END) AS failed_count,
    ROUND(AVG(duration_sec), 2)                  AS avg_duration_sec
FROM BJKT_PNL_REFRESH_LOG
GROUP BY mv_name
ORDER BY failed_count DESC NULLS LAST;
/
/*
    -- END --
    Query Monitoring
*/