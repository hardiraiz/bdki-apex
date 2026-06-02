/*
    START
    AVG Balance Kredit
*/
--
-- kredit avg. total
--
select 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and (
            "kategori_segment" IN ('KMG', 'KPR') or 
            "tipe_segment" IN ('Mikro', 'UKM')
        )
group by "periode", "nama_kantor_akhir", "cabang";
/
--
-- kredit konven total
--
select 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "padanan",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and (
            "kategori_segment" IN ('KMG', 'KPR') or 
            "tipe_segment" IN ('Mikro', 'UKM')
        )
    and "padanan" = 'Konven'
group by "periode", "nama_kantor_akhir", "cabang", "padanan";
/
-- kredit konven KMG
select 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "kategori_segment",
    "padanan",
    ROUND("avg" / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori_segment" = 'KMG'
    and "padanan" = 'Konven';
/
-- kredit konven KPR
select 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "kategori_segment",
    "padanan",
    ROUND("avg" / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori_segment" = 'KPR'
    and "padanan" = 'Konven';
/
-- kredit konven Mikro
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "tipe_segment" = 'Mikro'
    and "padanan" = 'Konven'
group by 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan"
/
-- kredit konven UKM
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "tipe_segment" = 'UKM'
    and "padanan" = 'Konven'
group by 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan";
/
--
-- kredit syariah total
--
select 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "padanan",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and (
            "kategori_segment" IN ('KMG', 'KPR') or 
            "tipe_segment" IN ('Mikro', 'UKM')
        )
    and "padanan" = 'Syariah'
group by "periode", "nama_kantor_akhir", "cabang", "padanan";
/
-- pembiayaan syariah KMG
select 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "kategori_segment",
    "padanan",
    ROUND("avg" / POWER(10,6)) total
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori_segment" = 'KMG'
    and "padanan" = 'Syariah';
/
-- pembiayaan syariah KPR
select 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "kategori_segment",
    "padanan",
    ROUND("avg" / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori_segment" = 'KPR'
    and "padanan" = 'Syariah';
/
-- pembiayaan syariah Mikro
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "tipe_segment" = 'Mikro'
    and "padanan" = 'Syariah'
group by 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan"
/
-- pembiayaan syariah UKM
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "tipe_segment" = 'UKM'
    and "padanan" = 'Syariah'
group by 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan";
/
/*
    END
    AVG Balance Kredit
*/
/*
    START
    Average Balance DPK
*/
-- 
-- DPK Total
-- 
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori" IN ('Giro', 'Tabungan', 'Deposito')
group by
    "periode",
    "cabang",
    "nama_kantor_akhir";
/
-- 
-- DPK Konven Total
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori" IN ('Giro', 'Tabungan', 'Deposito')
    and "produk" = 'Konven'
group by
    "periode",
    "cabang",
    "nama_kantor_akhir";
/
-- DPK Konven Giro
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori" = 'Giro'
    and "produk" = 'Konven'
group by
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori";
/
-- DPK Konven Tabungan
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori" = 'Tabungan'
    and "produk" = 'Konven'
group by
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori";
/
-- DPK Konven Deposito
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori" = 'Deposito'
    and "produk" = 'Konven'
group by
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori";
/
-- 
-- DPK Konven Total
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori" IN ('Giro', 'Tabungan', 'Deposito')
    and "produk" = 'Syariah'
group by
    "periode",
    "cabang",
    "nama_kantor_akhir";
/
-- DPK Syariah Giro
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori" = 'Giro'
    and "produk" = 'Syariah'
group by
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori";
/
-- DPK Syariah Tabungan
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori" = 'Tabungan'
    and "produk" = 'Syariah'
group by
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori";
/
-- DPK Syariah Deposito
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from BJKT_PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori" = 'Deposito'
    and "produk" = 'Syariah'
group by
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori";
/
/*
    END
    Average Balance DPK
*/
/*
    START
    Pendapatan Bunga Total
*/
-- pendapatan bunga konvensional KMG
select 
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "kategori_segment",
    "padanan",
    (("avg" * 0.92/100)/POWER(10,6)) total
from BJKT_PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "periode" = '2026-03-31'
    and "kategori_segment" = 'KMG'
    and "padanan" = 'Konven';
/
/*
    END
    Pendapatan Bunga Total
*/