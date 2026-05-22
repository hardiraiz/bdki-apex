-- list kategori_segment
select distinct "kategori_segment"
from PNL_LOAN_AVG_SY
where "padanan" = 'Konven';
/

-- list cabang dan cabang konsol
select
    "kode_cabang_awal"      "kode_cabang",
    "nama_kantor_akhir"     "kode_awal",
    "kode_konsol",
    "nama_konsol",
    "kode_cabang_dblm_v2"   "kode_cabang_dblm",
    "nama_cabang_dblm_v2"   "nama_cabang_dblm",
    "status_branch",
    "segmen_branch",
    "keterangan"
from DIM_BRANCH_V2_SY
/

/*
    START
    AVG Balance Kredit
*/
-- kredit konven KMG
select 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "kategori_segment",
    "padanan",
    ROUND("avg" / POWER(10,6)) "total"
from PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
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
from PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
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
from PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
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
from PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "tipe_segment" = 'UKM'
    and "padanan" = 'Konven'
group by 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan";
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
from PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "kategori_segment" = 'KMG'
    and "padanan" = 'DBLM';
-- pembiayaan syariah KPR
select 
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "kategori_segment",
    "padanan",
    ROUND("avg" / POWER(10,6)) "total"
from PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "kategori_segment" = 'KPR'
    and "padanan" = 'DBLM';
/
-- pembiayaan syariah Mikro
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "tipe_segment",
    "padanan",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "tipe_segment" = 'Mikro'
    and "padanan" = 'DBLM'
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
from PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "tipe_segment" = 'UKM'
    and "padanan" = 'DBLM'
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
-- DPK Konven Giro
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from PNL_DPK_AVG_SY
where 
        "cabang" = 101
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
from PNL_DPK_AVG_SY
where 
        "cabang" = 101
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
from PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "kategori" = 'Deposito'
    and "produk" = 'Konven'
group by
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori";
/

-- DPK Syariah Giro
select
    "periode",
    "cabang",
    "nama_kantor_akhir",
    "kategori",
    ROUND(SUM("avg") / POWER(10,6)) "total"
from PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "kategori" = 'Giro'
    and "produk" = 'DBLM'
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
from PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "kategori" = 'Tabungan'
    and "produk" = 'DBLM'
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
from PNL_DPK_AVG_SY
where 
        "cabang" = 101
    and "kategori" = 'Deposito'
    and "produk" = 'DBLM'
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
from PNL_LOAN_AVG_SY 
where 
        "cabang" = 101
    and "kategori_segment" = 'KMG'
    and "padanan" = 'Konven';
/
/*
    END
    Pendapatan Bunga Total
*/