/*
    Data transaksi bank berdasarkan periode
    - periode: Tahun-Bulan transaksi
    - channel: Jenis Channel Transaksi (ATM)
    - kode_cabang
    - cif_trx: Jumlah cif/nasabah unik yang melakukan transaksi
    - freq_trx: Frekuensi/jumlah transaksi
    - fbi: Fee Based Income yang dihasilkan
    - mdr: Merchant Discount Rate

    Bisa digunakan untuk:
    - Aktifitas transaksi ATM per cabang
    - Jumlah nasabah aktif menggunakan ATM
    - Intensitas transaksi
    - Pendapatan fee dari transaksi ATM
*/
select * from "dwh"."pnl_echannel"@DWH_DEV;
/


/*
    data funding/simpanan
    Data portofolio Dana Pihak Ketika (DPK) atau saldo rata-rata simpanan bank berdasarkan
    - kantor/cabang
    - kategori produk,
    - segmentasi nasabah,
    - dan jenis produk perbankan.

    | Kolom               | Arti                              |
    | ------------------- | --------------------------------- |
    | `periode`           | Tanggal snapshot data             |
    | `kode_konsol`       | Kode kantor induk/konsolidasi     |
    | `nama_konsol`       | Nama kantor konsolidasi           |
    | `cabang`            | Kode cabang                       |
    | `nama_kantor_akhir` | Nama cabang/KCP                   |
    | `kategori`          | Jenis simpanan                    |
    | `segmentasi`        | Segmen nasabah                    |
    | `produk`            | Jenis produk bank                 |
    | `cabang_padanan`    | Cabang relasi/mapping tertentu    |
    | `avg`               | Average balance / saldo rata-rata |
*/
select * from "dwh"."pnl_dpk_avg"@DWH_DEV;
/
-- avg balance DPK
select
    "periode",
    "kode_konsol",
    "nama_konsol",
    "kategori",
    SUM("avg") total
from "dwh"."pnl_dpk_avg"@DWH_DEV
where "kode_konsol" = 101
group by "periode", "kode_konsol", "nama_konsol", "kategori"
order by "kategori";
/

/*
    lending/kredit
    Data portofolio kredit/pinjaman bank berdasarkan 
    - cabang,
    - tipe segmen nasabah,
    - kategori pembiayaan,
    - jenis produk,
    - dan rata-rata outstanding pinjaman (avg).

    | Kolom               | Arti                           |
    | ------------------- | ------------------------------ |
    | `periode`           | Tanggal snapshot data          |
    | `kode_konsol`       | Kode kantor induk/konsolidasi  |
    | `nama_konsol`       | Nama kantor konsolidasi        |
    | `cabang`            | Kode cabang                    |
    | `nama_kantor_akhir` | Nama cabang                    |
    | `tipe_segment`      | Jenis segmen kredit            |
    | `kategori_segment`  | Kategori pembiayaan            |
    | `produk`            | Jenis produk kredit            |
    | `padanan`           | Mapping produk                 |
    | `avg`               | Average outstanding kredit     |

*/
select * from "dwh"."pnl_loan_avg"@DWH_DEV;
/
-- balance avg kredit detail
select 
    "periode",
    "kode_konsol", 
    "nama_konsol",
    "tipe_segment",
    "kategori_segment",
    SUM("avg") total
from "dwh"."pnl_loan_avg"@DWH_DEV
where 
        "kode_konsol" = 101 
    and "padanan" = 'Konven'
group by 
    "periode", 
    "kode_konsol", 
    "nama_konsol",
    "kategori_segment",
    "tipe_segment"
-- order by "tipe_segment" asc
;

-- pend bunga total syariah, flagging pend bunga dengan beban bunga?
select 
    "periode",
    "kode_konsol", 
    "nama_konsol",
    'Syariah' "produk",
    SUM("avg") total
from PNL_LOAN_AVG_SY
where "kode_konsol" = 101 and "padanan" = 'DBLM'
group by "periode", "kode_konsol", "nama_konsol", "padanan"
;

/*
    data rekening pendapatan bank (general ledger/COA accounting) 
    yang berisi informasi pendapatan bunga berdasarkan jenis akun dan klasifikasi laporan keuangan.

    | Kolom               | Arti                     |
    | ------------------- | ------------------------ |
    | `periode`           | Tanggal laporan          |
    | `kode_cabang_akhir` | Kode cabang/unit         |
    | `nomor_rekening`    | Nomor akun GL/COA        |
    | `nama`              | Nama akun pendapatan     |
    | `ket_1`             | Kelompok utama laporan   |
    | `ket_2`             | Sub kategori level 2     |
    | `ket_3`             | Sub kategori level 3     |
    | `ket_4`             | Detail kategori          |
    | `nom`               | Nominal saldo/pendapatan |
*/
select * from "dwh"."pnl_gl"@DWH_DEV where "ket_1" LIKE '%Pendapatan%' 
-- and "ket_2" LIKE '%Syar%';
/

select * from "dwh"."pnl_gl_v2"@DWH_DEV;
/

select * from "dwh"."dim_branch_v2"@DWH_DEV;
/

select *
  from "information_schema"."tables"@dwh_dev
 where "table_schema" = 'dwh';
/