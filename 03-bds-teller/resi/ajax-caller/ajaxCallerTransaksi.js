(async function() {
    try {
        const response = await apex.server.process('GET_TARIK_TUNAI', {
            x01: null
        });

        const d = response.data[0]; 

        const urlLogo = '#APP_FILES#icons/app-icon-512.png'; 
        const logoBase64 = await getBase64FromUrl(urlLogo);

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
            biaya:            d.BIAYA_TRANSAKSI.toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
            kodeReferensi:    d.KODE_REFERENSI,
            kurs:             d.KURS.toLocaleString('id-ID', { minimumFractionDigits: 6, maximumFractionDigits: 6 }),
            teller:           d.TELLER,
            totalTarikan:     d.TOTAL_TRANSAKSI.toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
            totalTarikanRaw:  d.TOTAL_TRANSAKSI,
            supervisor:       d.SUPERVISOR,
            alamatPenarik:    d.ALAMAT_PENYETOR,
            noTelp:           d.NO_TELP,
            tujuanPengDana:   d.TUJUAN_PENG_DANA,
            logo:             logoBase64
        };

        let docDefinition = generateLayoutTransaksi(dataSetoran);
        // pdfMake.createPdf(docDefinition).download('slip_setoran_tunai_' + dataSetoran.nomorRekening + '.pdf');
        pdfMake.createPdf(docDefinition).open();

    } catch (error) {
        alert("Gagal mengambil data atau mencetak: " + error.message);
    }
})();