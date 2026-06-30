// SAMPLE CALL TARIK TUNAI
try {
    let dataSetoran = {
        jenisRekening:    'TABUNGAN MONAS PEKERJA',
        cabang:           '108 KANTOR CABANG UTAMA BALAIKOTA',
        nomorRekening:    '20923223274',
        tanggalJam:       '20-12-2024 / 17:02:32',
        pemilikRekening:  'MAYASARI',
        jenisTransaksi:   '1000 - SETOR TUNAI',
        cabangTujuan:     'KANTOR CABANG PEMBANTU KAWASAN BERIKAT NUSANTARA',
        
        nominalTransaksi: '17,000,000.00',
        mataUang:         'IDR - RUPIAH',
        biaya:            '0.00',
        kodeReferensi:    'E2T7TW',
        kurs:             '1.000000',
        teller:           'AR39190319',
        totalSetoran:     '17,000,000.00',
        supervisor:       null,
        keterangan:       null,
        
        namaPenyetor:     'MAYASARI',
        alamatPenyetor:   'JALAN MANDALA 1 NO 19',
        identitasDiri:    'KTP',
        noIdentitas:      '3175105503900009',
        noTelp:           '089812121111',
        sumberDana:       null,
        tujuanTransaksi:  null
    };

    let docDefinition = buatLayoutSetoran(dataSetoran);

    let namaFile = 'Slip_Setoran_' + (dataSetoran.nomorRekening || 'Blank') + '.pdf';
    pdfMake.createPdf(docDefinition).download(namaFile);

} catch (error) {
    alert("Gagal mencetak dokumen: " + error.message);
}

// SAMPLE CALL SETOR TUNAI
try {
    let dataSetoran = {
        jenisRekening:    'TABUNGAN MONAS PEKERJA',
        cabang:           '108 KANTOR CABANG UTAMA BALAIKOTA',
        nomorRekening:    '20923223274',
        tanggalJam:       '20-12-2024 / 17:02:32',
        pemilikRekening:  'MAYASARI',
        jenisTransaksi:   '1000 - SETOR TUNAI',
        cabangTujuan:     'KANTOR CABANG PEMBANTU KAWASAN BERIKAT NUSANTARA',
        
        nominalTransaksi: '17,000,000.00',
        mataUang:         'IDR - RUPIAH',
        biaya:            '0.00',
        kodeReferensi:    'E2T7TW',
        kurs:             '1.000000',
        teller:           'AR39190319',
        totalSetoran:     '17,000,000.00',
        supervisor:       null,
        keterangan:       null,
        
        namaPenyetor:     'MAYASARI',
        alamatPenyetor:   'JALAN MANDALA 1 NO 19',
        identitasDiri:    'KTP',
        noIdentitas:      '3175105503900009',
        noTelp:           '089812121111',
        sumberDana:       null,
        tujuanTransaksi:  null
    };

    let docDefinition = buatLayoutSetoran(dataSetoran);

    let namaFile = 'Slip_Setoran_' + (dataSetoran.nomorRekening || 'Blank') + '.pdf';
    pdfMake.createPdf(docDefinition).download(namaFile);

} catch (error) {
    alert("Gagal mencetak dokumen: " + error.message);
}

// CALL WITH PAGE PARAM
try {
    let dataSetoran = {
        jenisRekening:    apex.item('P_JENIS_REKENING').getValue(),
        cabang:           apex.item('P_CABANG').getValue(),
        nomorRekening:    apex.item('P_NOMOR_REKENING').getValue(),
        tanggalJam:       apex.item('P_TANGGAL_JAM').getValue(),
        pemilikRekening:  apex.item('P_PEMILIK_REKENING').getValue(),
        jenisTransaksi:   apex.item('P_JENIS_TRANSAKSI').getValue(),
        cabangTujuan:     apex.item('P_CABANG_TUJUAN').getValue(),
        
        nominalTransaksi: apex.item('P_NOMINAL').getValue(),
        mataUang:         apex.item('P_MATA_UANG').getValue(),
        biaya:            apex.item('P_BIAYA').getValue(),
        kodeReferensi:    apex.item('P_REFERENSI').getValue(),
        kurs:             apex.item('P_KURS').getValue(),
        teller:           apex.item('P_TELLER').getValue(),
        totalSetoran:     apex.item('P_TOTAL').getValue(),
        supervisor:       apex.item('P_SUPERVISOR').getValue(),
        keterangan:       apex.item('P_KETERANGAN').getValue(),
        
        namaPenyetor:     apex.item('P_NAMA_PENYETOR').getValue(),
        alamatPenyetor:   apex.item('P_ALAMAT_PENYETOR').getValue(),
        identitasDiri:    apex.item('P_IDENTITAS').getValue(),
        noIdentitas:      apex.item('P_NO_IDENTITAS').getValue(),
        noTelp:           apex.item('P_NO_TELP').getValue(),
        sumberDana:       apex.item('P_SUMBER_DANA').getValue(),
        tujuanTransaksi:  apex.item('P_TUJUAN_TRANSAKSI').getValue()
    };

    let docDefinition = buatLayoutSetoran(dataSetoran);

    let namaFile = 'Slip_Setoran_' + (dataSetoran.nomorRekening || 'Blank') + '.pdf';
    pdfMake.createPdf(docDefinition).download(namaFile);

} catch (error) {
    alert("Gagal mencetak dokumen: " + error.message);
}