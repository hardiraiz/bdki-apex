async function prosesCetakPdf(appFilesPath, kodeRef) {
    if (!kodeRef) {
        alert("Kode referensi wajib diisi.");
        return;
    }

    const urlLogo = appFilesPath + 'icons/app-icon-512.png'; 
    const logoBase64 = await getBase64FromUrl(urlLogo);
    
    let prefix = kodeRef.substring(0, 2);
    if (prefix === 'TT') {
        try {
            const response = await apex.server.process('GET_TARIK_TUNAI', { x01: kodeRef });
            const d = response.data[0]; 
            let dataSetoran = {
                namaPenarik:      d.NAMA_PENARIK,
                nomorRekening:    d.NOMOR_REKENING,
                noTelp:           d.NO_TELP,
                email:            d.EMAIL,
                nominal:          (d.NOMINAL_TRANSAKSI || 0).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                biaya:            (d.BIAYA || 0).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
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
    } else if (prefix === 'ST') {
        try {
            const response = await apex.server.process('GET_SETOR_TUNAI', { x01: kodeRef });
            const d = response.data[0]; 
            let dataSetoran = {
                jenisRekening:    (d.JENIS_REKENING || '-').toUpperCase(),
                cabang:           (d.CABANG || '-').toUpperCase(),
                nomorRekening:    (d.NOMOR_REKENING || '-'),
                tanggalJam:       (d.TANGGAL_TRANSAKSI || '-').toUpperCase(),
                pemilikRekening:  (d.PEMILIK_REKENING || '-').toUpperCase(),
                jenisTransaksi:   (d.JENIS_TRANSAKSI || '-').toUpperCase(),
                cabangTujuan:     (d.CABANG_TUJUAN || '-').toUpperCase(),
                nominalTransaksi: (d.NOMINAL_TRANSAKSI || 0).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                mataUang:         (d.MT_UANG_TRANSAKSI || '-').toUpperCase(),
                kodeReferensi:    (d.KODE_REFERENSI || '-').toUpperCase(),
                kurs:             (d.KURS || 0).toLocaleString('id-ID', { minimumFractionDigits: 6, maximumFractionDigits: 6 }),
                teller:           (d.TELLER || '-').toUpperCase(),
                totalSetoran:     (d.TOTAL_TRANSAKSI || 0).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                totalSetoranRaw:  d.TOTAL_TRANSAKSI,
                supervisor:       (d.SUPERVISOR || '-').toUpperCase(),
                keterangan:       (d.KETERANGAN || '-').toUpperCase(),
                namaPenyetor:     (d.NAMA_PENYETOR || '-').toUpperCase(),
                alamatPenyetor:   (d.ALAMAT_PENYETOR || '-').toUpperCase(),
                identitasDiri:    (d.JENIS_IDENTITAS || '-').toUpperCase(),
                noIdentitas:      (d.NO_IDENTITAS || '-').toUpperCase(),
                noTelp:           (d.NO_TELP || '-').toUpperCase(),
                sumberDana:       (d.SUMBER_DANA || '-').toUpperCase(),
                tujuanTransaksi:  (d.TUJUAN_TRANSAKSI || '-').toUpperCase()
            };

            let docDefinition = generateLayoutSetorTunai(dataSetoran);
            pdfMake.createPdf(docDefinition).open();

        } catch (error) { 
            alert("Gagal mengambil data atau mencetak: " + error.message); 
        }
    } else if (prefix === 'TF') {
        try {
            const response = await apex.server.process('GET_TRANSFER', { x01: kodeRef });
            const d = response.data[0]; 
            let dataSetoran = {
                namaPengirim:       (d.NAMA_PENGIRIM || '-').toUpperCase(),
                nomorRekPengirim:   (d.NO_REK_PENGIRIM || '-'),
                noTelp:             (d.NO_TELP || '-').toUpperCase(),
                email:              (d.EMAIL || '-').toUpperCase(),
                nominalTransaksi:   (d.NOMINAL_TRANSAKSI || 0).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                biayaTransaksi:     (d.BIAYA_TRANSAKSI || 0).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                totalTransaksi:     (d.TOTAL_TRANSAKSI || 0).toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
                jenisTransaksi:     (d.JENIS_TRANSAKSI || '-').toUpperCase(),
                tanggalTransaksi:   (d.TANGGAL_TRANSAKSI || '-').toUpperCase(),
                jamTransaksi:       (d.JAM_TRANSAKSI || '-').toUpperCase(),
                cabang:             (d.CABANG || '-').toUpperCase(),
                petugas:            (d.PETUGAS || '-').toUpperCase(),
                kodeReferensi:      (d.KODE_REFERENSI || '-').toUpperCase(),
                namaPenerima:       (d.NAMA_PENERIMA || '-').toUpperCase(),
                nomorRekPenerima:   (d.NO_REK_PENERIMA || '-'),
                namaBankPenerima:   (d.NAMA_BANK_PENERIMA || '-').toUpperCase(),
                logo:               logoBase64,
            };

            let docDefinition = generateLayoutTransfer(dataSetoran);
            pdfMake.createPdf(docDefinition).open();

        } catch (error) { 
            alert("Gagal mengambil data atau mencetak: " + error.message); 
        }
    }
}