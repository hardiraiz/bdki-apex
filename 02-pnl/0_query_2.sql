-- RUMUS = IFERROR(E6*ABS(E10)/(E6*((B29+B36)/B10) + (1-E6)*((B32+B35)/B21)),0)
-- IFERROR(Kredit of Portfolio Branch Ratios*ABS(Minimum NII Possible Action 1)/(Kredit of Portfolio Branch Ratios*((Pend. Bunga Total+FTP Charge)/Kredit Konven Avg. Balance Kredit Retail) + (1-Kredit of Portfolio Branch Ratios)*((Beban Bunga Total+FTP Income)/DPK Konven Average Balance DPK)),0)
WITH
cte_kredit_portofolio AS (
    SELECT
        (cre."total_kredit" / (cre."total_kredit" + dpk."total_dpk")) AS "kredit_portofolio"
    FROM BJKT_PNL_AVG_BAL_CREDIT_MV cre
    LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
        ON cre."kode_cabang" = dpk."kode_cabang"
    WHERE
        cre."kode_cabang" = '108'
)

SELECT
    ckp.*
FROM cte_kredit_portofolio ckp;