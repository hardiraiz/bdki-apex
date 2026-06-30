(async function() {
    try {
        const response = await apex.server.process('GET_SETOR_TUNAI', {
            x01: null
        });

        const d = response.data[0]; 
        let dataSetoran = {
            jenisRekening:    d.JENIS_REKENING,
            cabang:           d.CABANG,
            nomorRekening:    d.NOMOR_REKENING,
            tanggalJam:       d.TANGGAL_TRANSAKSI,
            pemilikRekening:  d.PEMILIK_REKENING,
            jenisTransaksi:   d.JENIS_TRANSAKSI,
            cabangTujuan:     d.CABANG_TUJUAN,
            nominalTransaksi: d.NOMINAL_TRANSAKSI.toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
            mataUang:         d.MT_UANG_TRANSAKSI,
            kodeReferensi:    d.KODE_REFERENSI,
            kurs:             d.KURS.toLocaleString('id-ID', { minimumFractionDigits: 6, maximumFractionDigits: 6 }),
            teller:           d.TELLER,
            totalSetoran:     d.TOTAL_TRANSAKSI.toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
            totalSetoranRaw:  d.TOTAL_TRANSAKSI,
            supervisor:       d.SUPERVISOR,
            keterangan:       d.KETERANGAN,
            namaPenyetor:     d.NAMA_PENYETOR,
            alamatPenyetor:   d.ALAMAT_PENYETOR,
            identitasDiri:    d.JENIS_IDENTITAS,
            noIdentitas:      d.NO_IDENTITAS,
            noTelp:           d.NO_TELP,
            sumberDana:       d.SUMBER_DANA,
            tujuanTransaksi:  d.TUJUAN_TRANSAKSI
        };

        let docDefinition = generateLayoutSetorTunai(dataSetoran);
        // pdfMake.createPdf(docDefinition).download('slip_setoran_tunai_' + dataSetoran.nomorRekening + '.pdf');
        pdfMake.createPdf(docDefinition).open();

    } catch (error) {
        alert("Gagal mengambil data atau mencetak: " + error.message);
    }
})();