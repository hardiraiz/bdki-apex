(async function() {
    try {
        const response = await apex.server.process('GET_TARIK_TUNAI', {
            x01: null
        });

        const d = response.data[0]; 
        const urlLogo = '#APP_FILES#icons/app-icon-512.png'; 
        const logoBase64 = await getBase64FromUrl(urlLogo);

        let dataSetoran = {
            namaPenarik:      d.NAMA_PENARIK,
            nomorRekening:    d.NOMOR_REKENING,
            noTelp:           d.NO_TELP,
            email:            d.EMAIL,
            nominal:          (d.NOMINAL_TRANSAKSI || 0).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
            tanggal:          d.TANGGAL_TRANSAKSI,
            jam:              d.JAM_TRANSAKSI,
            kodeCabang:       d.KODE_CABANG,
            petugas:          d.PETUGAS,
            kodeReferensi:    d.KODE_REFERENSI,
            logo:             logoBase64,
            totalTarikanRaw:  d.NOMINAL_TRANSAKSI || 0
        };

        let docDefinition = generateLayoutTarikTunaiV2(dataSetoran); 
        pdfMake.createPdf(docDefinition).open();

    } catch (error) {
        alert("Gagal mengambil data atau mencetak: " + error.message);
    }
})();