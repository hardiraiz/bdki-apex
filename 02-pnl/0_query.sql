-- list access table
select *
from "information_schema"."tables"@dwh_dev
where "table_schema" = 'dwh'
    -- and "table_name" = 'pnl_assumptions'
;
/

-- query ke DBLink
SELECT * FROM "dwh"."pnl_pendapatan_bunga"@DWH_DEV;
SELECT * FROM "dwh"."pnl_beban_bunga"@DWH_DEV;
SELECT * FROM "dwh"."pnl_income_dpk"@DWH_DEV;
SELECT * FROM "dwh"."pnl_charge_loan"@DWH_DEV;
SELECT * FROM "dwh"."pnl_fbi"@DWH_DEV;
/
SELECT * FROM BJKT_PNL_LOAN_AVG_SY;
SELECT * FROM BJKT_PNL_DPK_AVG_SY;
SELECT * FROM BJKT_PNL_GL_V2_SY;
/

select distinct "ket_final" from BJKT_PNL_GL_V2_SY where "kode_cabang_akhir" = 108;
select * from BJKT_PNL_GL_V2_SY where "kode_cabang_akhir" = 108 and "ket_final" = 'Transaksi Non Kredit';
/

select * from BJKT_BRANCHES_MV;
/


-- LOV List KC
select distinct "nama_konsol" d, "kode_konsol" r 
from BJKT_BRANCHES_MV 
where "keterangan" = 'BUKA'
order by "nama_konsol";
/

-- LOV List Cabang KC
select "nama_kantor_akhir" d, "kode_cabang_akhir" r
from BJKT_BRANCHES_MV 
where 
        "keterangan" = 'BUKA'        
    and (:P1000_KC is null or "kode_konsol" = :P1000_KC)
order by "nama_kantor_akhir";
/

-- sample query display score card
SELECT
    'Avg. Balance Kredit Detail' AS column_name,
    730000 AS nominal,
    1 AS group_number,
    'Y' AS is_header
FROM DUAL
UNION ALL
SELECT
    'Kredit Konven' AS column_name,
    664300 AS nominal,
    1 AS group_number,
    'N' AS is_header
FROM DUAL
UNION ALL
SELECT
    'KMG' AS column_name,
    544000 AS nominal,
    1 AS group_number,
    'N' AS is_header
FROM DUAL
UNION ALL
SELECT
    'Average Balance DPK' AS column_name,
    744000 AS nominal,
    2 AS group_number,
    'Y' AS is_header
FROM DUAL
UNION ALL
SELECT
    'DPK Konven' AS column_name,
    144000 AS nominal,
    2 AS group_number,
    'N' AS is_header
FROM DUAL
ORDER BY group_number ASC, is_header DESC
;
/

-- Syariah KMG
SELECT
    *
FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
WHERE
        "cabang" = '108'
    AND "padanan" IN ('DBLM', 'Syariah')
    AND "kategori_segment" = 'KMG';

SELECT
    *
FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
WHERE
        "cabang" = '108'
    AND "padanan" IN ('DBLM', 'Syariah')
    AND "kategori_segment" = 'KPR';

SELECT
    *
FROM BJKT_PNL_PENDAPATAN_BUNGA_SY
WHERE
        "cabang" = '108'
    AND "padanan" IN ('DBLM', 'Syariah')
    AND "kategori_segment" = 'KPR';