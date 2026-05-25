select * from BJKT_UPLOAD_BANSOS order by id desc;
/
select * from BJKT_FILE_UPLOAD_LOG order by id desc;
/
select * from BJKT_BANSOS_RECIPIENTS_STG order by id desc;
/
select * from BJKT_HISTORY_BANSOS_RECIPIENTS order by id desc;
/
select * from BJKT_BANSOS_RECIPIENTS_ERR order by id desc;
/
select ID, NAMA, ERROR_COLUMNS, ERROR_DETAILS_JSON from BJKT_BANSOS_RECIPIENTS_ERR order by id desc;
/
select * from BJKT_CAL_BANSOS_RECIPIENTS_V;
/

delete from BJKT_BANSOS_RECIPIENTS_STG;
/
delete from BJKT_BANSOS_RECIPIENTS_ERR;
/
delete from BJKT_UPLOAD_BANSOS;
/
delete from BJKT_FILE_UPLOAD_LOG;
/
delete from BJKT_HISTORY_BANSOS_RECIPIENTS;
/
commit;
/

ALTER TABLE BJKT_BANSOS_RECIPIENTS_STG 
    DROP CONSTRAINT BJKT_BANSOS_RECIPIENTS_STG_C1;
/
ALTER TABLE BJKT_BANSOS_RECIPIENTS_STG 
    ADD CONSTRAINT BJKT_BANSOS_RECIPIENTS_STG_C1 
    CHECK (STATUS IN ('PENDING','VALID','ERROR','LOADED','SKIPPED'));
/
ALTER TABLE BJKT_UPLOAD_BANSOS ADD (
    SKIPPED_ROWS  NUMBER DEFAULT 0
);
/
ALTER TABLE BJKT_HISTORY_BANSOS_RECIPIENTS DROP (
    USER_APPROVE_ID
);
/
ALTER TABLE BJKT_HISTORY_BANSOS_RECIPIENTS ADD (
    USER_APPROVER VARCHAR2(200)
);
ALTER TABLE BJKT_BANSOS_RECIPIENTS_ERR ADD (
    LAST_UPDATE_DATE    TIMESTAMP,
    LAST_UPDATED_BY     VARCHAR2(200)
);
/

SELECT
    ROW_NUMBER() OVER (ORDER BY t.ID) AS NO,
    t.ID,
    t.NAMA,
    t.JEN_KELAMIN,
    t.TEMPAT_LAHIR,
    t.TANGGAL_LAHIR,
    t.NO_IDENTITAS,
    t.NAMA_IBU_KANDUNG_WALI,
    t.STATUS_KAWIN,
    t.AGAMA,
    t.PENDIDIKAN,
    t.ALAMAT_KTP,
    t.ALAMAT_DOMISILI,
    t.RT,
    t.RW,
    t.KELURAHAN,
    t.KECAMATAN,
    t.KOTA,
    t.PROPINSI,
    t.KODE_POS,
    t.STATUS_RUMAH,
    t.TELP_HP,
    t.PEKERJAAN_BIDANG_USAHA,
    t.KODE_PROFESI,
    t.STATUS_PEKERJAAN,
    t.NAMA_INSTANSI,
    t.ALAMAT_INSTANSI,
    t.KODE_POS_INSTANSI,
    t.NO_TELP_INSTANSI,
    t.SUAMI_ISTRI,
    t.NAMA_PIHAK_DIHUBUNGI,
    t.HUBUNGAN,
    t.ALAMAT,
    t.KOTA_DOMISILI,
    t.PROPINSI_DOMISILI,
    t.TELPON,
    t.STATUS_INSTANSI,
    t.NOMOR_INSTANSI,
    t.TOTAL_DANA,
    LISTAGG(
        REPLACE(jt.err_value, '\"', '"'), '<br>'
    ) WITHIN GROUP (ORDER BY jt.err_value) AS KETERANGAN_VALIDASI
FROM BJKT_BANSOS_RECIPIENTS_ERR t
CROSS JOIN JSON_TABLE(
    t.ERROR_DETAILS_JSON,
    '$[*]'
    COLUMNS (err_value VARCHAR2(1000) PATH '$.*')
) jt
WHERE t.PROGRAM_ID = 41
GROUP BY
    t.ID, t.NAMA, t.JEN_KELAMIN, t.TEMPAT_LAHIR, t.TANGGAL_LAHIR,
    t.NO_IDENTITAS, t.NAMA_IBU_KANDUNG_WALI, t.STATUS_KAWIN, t.AGAMA,
    t.PENDIDIKAN, t.ALAMAT_KTP, t.ALAMAT_DOMISILI, t.RT, t.RW,
    t.KELURAHAN, t.KECAMATAN, t.KOTA, t.PROPINSI, t.KODE_POS,
    t.STATUS_RUMAH, t.TELP_HP, t.PEKERJAAN_BIDANG_USAHA, t.KODE_PROFESI,
    t.STATUS_PEKERJAAN, t.NAMA_INSTANSI, t.ALAMAT_INSTANSI, t.KODE_POS_INSTANSI,
    t.NO_TELP_INSTANSI, t.SUAMI_ISTRI, t.NAMA_PIHAK_DIHUBUNGI, t.HUBUNGAN,
    t.ALAMAT, t.KOTA_DOMISILI, t.PROPINSI_DOMISILI, t.TELPON,
    t.STATUS_INSTANSI, t.NOMOR_INSTANSI, t.TOTAL_DANA;
/

SELECT * FROM BJKT_MASTER_CODES_V WHERE CATEGORY = 'HUBUNGAN';
/

SELECT * FROM "dwh"."master_kjp"@DWH_DEV;
/

WITH
-- =============================================
-- CTE 1: Agregasi Kredit
-- =============================================
cte_kredit AS (
    SELECT
        "periode",
        "cabang",
        "nama_kantor_akhir",

        ROUND(SUM("avg") / POWER(10,6))                                                            
            AS "total_kredit",

        -- Konven
        ROUND(SUM(CASE WHEN "padanan" = 'Konven' THEN "avg" ELSE NULL END) / POWER(10,6))         
            AS "kredit_total_konven",
        ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                        AND "kategori_segment" = 'KMG'  THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_konven_kmg",
        ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                        AND "kategori_segment" = 'KPR'  THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_konven_kpr",
        ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                        AND "tipe_segment"    = 'Mikro' THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_konven_mikro",
        ROUND(SUM(CASE WHEN "padanan" = 'Konven'
                        AND "tipe_segment"    = 'UKM'   THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_konven_ukm",

        -- Syariah
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah' THEN "avg" ELSE NULL END) / POWER(10,6))        
            AS "kredit_total_syariah",
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah'
                        AND "kategori_segment" = 'KMG'  THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_syariah_kmg",
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah'
                        AND "kategori_segment" = 'KPR'  THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_syariah_kpr",
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah'
                        AND "tipe_segment"    = 'Mikro' THEN "avg" ELSE NULL END) / POWER(10,6))  
            AS "kredit_syariah_mikro",
        ROUND(SUM(CASE WHEN "padanan" = 'Syariah'
            AND "tipe_segment"    = 'UKM'   THEN "avg" ELSE NULL END) / POWER(10,6))  AS "kredit_syariah_ukm"

    FROM PNL_LOAN_AVG_SY
    WHERE
            "cabang"  = '101'
        AND "periode" = '2026-03-31'
        AND (
                "kategori_segment" IN ('KMG', 'KPR')
             OR "tipe_segment"     IN ('Mikro', 'UKM')
            )
    GROUP BY
        "periode",
        "cabang",
        "nama_kantor_akhir"
),
-- =============================================
-- CTE 2: Agregasi DPK
-- =============================================
cte_dpk AS (
    SELECT
        "periode",
        "cabang",
        "nama_kantor_akhir",

        ROUND(SUM("avg") / POWER(10,6))                                                           
            AS "total_dpk",

        -- DPK Konven
        ROUND(SUM(CASE WHEN "produk" = 'Konven' THEN "avg" ELSE NULL END) / POWER(10,6))         
            AS "dpk_total_konven",
        ROUND(SUM(CASE WHEN "produk" = 'Konven'
                        AND "kategori" = 'Giro'      THEN "avg" ELSE NULL END) / POWER(10,6))    
            AS "dpk_konven_giro",
        ROUND(SUM(CASE WHEN "produk" = 'Konven'
                        AND "kategori" = 'Tabungan'  THEN "avg" ELSE NULL END) / POWER(10,6))    
            AS "dpk_konven_tabungan",
        ROUND(SUM(CASE WHEN "produk" = 'Konven'
                        AND "kategori" = 'Deposito'  THEN "avg" ELSE NULL END) / POWER(10,6))    
            AS "dpk_konven_deposito",

        -- DPK Syariah
        ROUND(SUM(CASE WHEN "produk" = 'Syariah' THEN "avg" ELSE NULL END) / POWER(10,6))        
            AS "dpk_total_syariah",
        ROUND(SUM(CASE WHEN "produk" = 'Syariah'
                        AND "kategori" = 'Giro'      THEN "avg" ELSE NULL END) / POWER(10,6))    
            AS "dpk_syariah_giro",
        ROUND(SUM(CASE WHEN "produk" = 'Syariah'
                        AND "kategori" = 'Tabungan'  THEN "avg" ELSE NULL END) / POWER(10,6))    
            AS "dpk_syariah_tabungan",
        ROUND(SUM(CASE WHEN "produk" = 'Syariah'
                        AND "kategori" = 'Deposito'  THEN "avg" ELSE NULL END) / POWER(10,6))    
            AS "dpk_syariah_deposito"

    FROM PNL_DPK_AVG_SY
    WHERE
            "cabang"  = '101'
        AND "periode" = '2026-03-31'
        AND "kategori" IN ('Giro', 'Tabungan', 'Deposito')
    GROUP BY
        "periode",
        "cabang",
        "nama_kantor_akhir"
)
-- =============================================
-- FINAL: JOIN hasil agregasi (1 row per kantor)
-- =============================================
SELECT
    k."periode",
    k."cabang",
    k."nama_kantor_akhir",

    -- Kredit
    k."total_kredit",
    k."kredit_total_konven",
    k."kredit_konven_kmg",
    k."kredit_konven_kpr",
    k."kredit_konven_mikro",
    k."kredit_konven_ukm",
    k."kredit_total_syariah",
    k."kredit_syariah_kmg",
    k."kredit_syariah_kpr",
    k."kredit_syariah_mikro",
    k."kredit_syariah_ukm",

    -- DPK
    d."total_dpk",
    d."dpk_total_konven",
    d."dpk_konven_giro",
    d."dpk_konven_tabungan",
    d."dpk_konven_deposito",
    d."dpk_total_syariah",
    d."dpk_syariah_giro",
    d."dpk_syariah_tabungan",
    d."dpk_syariah_deposito"

FROM cte_kredit k
INNER JOIN cte_dpk d
    ON  k."periode"           = d."periode"
    AND k."cabang"            = d."cabang"
    AND k."nama_kantor_akhir" = d."nama_kantor_akhir"

ORDER BY
    k."nama_kantor_akhir";
/