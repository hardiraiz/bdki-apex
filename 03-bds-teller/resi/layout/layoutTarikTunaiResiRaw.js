var dd = {
    pageSize: { width: 609.45, height: 365.67 },
    pageMargins: [20, 20, 20, 20],
    defaultStyle: {
        fontSize: 8,
        font: 'Roboto' 
    },
    content: [
        { text: 'TARIKAN TUNAI', bold: true, fontSize: 10, margin: [0, 0, 0, 2] },
        
        // --- BAGIAN ATAS (50% KIRI & 50% KANAN) ---
        {
            columnGap: 15,
            columns: [
                {
                    width: '*', // KIRI
                    layout: 'noBorders',
                    table: {
                        widths: [75, 5, '*'],
                        body: [
                            ['Jenis Rekening', ':', 'TABUNGAN MONAS PEKERJA'],
                            ['Nomor Rekening', ':', '20923223274'],
                            ['Pemilik Rekening', ':', 'MAYASARI'],
                            ['Cabang Tujuan', ':', 'KANTOR CABANG PEMBANTU KAWASAN BERIKAT NUSANTARA'],
                            ['Nominal Transaksi', ':', { text: '17,000,000.00', alignment: 'right' }],
                            ['Biaya', ':', { text: '0.00', alignment: 'right' }],
                            ['Kurs', ':', { text: '1.000000', alignment: 'right' }],
                            ['Total Tarikan', ':', { text: '17,000,000.00', alignment: 'right' }],
                            ['Terbilang', ':', 'TUJUH BELAS JUTA RUPIAH']
                        ]
                    }
                },
                {
                    width: '*', // KANAN
                    layout: 'noBorders',
                    table: {
                        widths: [75, 5, '*'],
                        body: [
                            ['Cabang', ':', '108 KANTOR CABANG JUANDA'],
                            ['Tanggal/Jam', ':', '10-04-2026 / 11:30:23'],
                            ['Jenis Transaksi', ':', '2000 - TARIK TUNAI'],
                            ['Cabang Tujuan', ':', 'KANTOR CABANG JUANDA'],
                            ['Mt Uang Setoran', ':', 'IDR - RUPIAH'],
                            ['Kode Referensi', ':', 'E2T7TW'],
                            ['Teller', ':', 'DA12345678'],
                            ['Supervisor', ':', '-']
                        ]
                    }
                }
            ]
        },

        // --- BAGIAN BAWAH (ALAMAT & TANDA TANGAN) ---
        {
            columnGap: 15,
            columns: [
                // KOLOM KIRI (Data Penyetor)
                {
                    width: '*',
                    margin: [0, 10, 0, 0],
                    layout: 'noBorders',
                    table: {
                        widths: [75, 5, '*'],
                        body: [
                            ['Alamat', ':', 'JL. BINTARO PERMAI II NO. 26, KELUARAHAN BINTARO, KECAMATAN PESANGGRAHAN, JAKARTA SELATAN, DKI JAKARTA'],
                            ['No. Handphone', ':', '089812121111'],
                            ['Tujuan Penggunaan Dana', ':', '-']
                        ]
                    }
                },
                // KOLOM KANAN (Tanda Tangan)
                {
                    width: '*', 
                    margin: [0, 5, 0, 0], // Sedikit margin atas agar sejajar
                    stack: [
                        { 
                            text: 'Tarikan sah setelah divalidasi dan ditandatangani oleh Teller', 
                            alignment: 'center', 
                            margin: [0, 20, 0, 30] // Jarak margin bawah untuk area kosong tanda tangan
                        },
                        {
                            columns: [
                                { text: '--------------------------------------\nTeller', alignment: 'center' },
                                { text: '--------------------------------------\nPenyetor Depositor', alignment: 'center' }
                            ]
                        }
                    ]
                }
            ]
        }
    ]
};