var dd = {
    pageSize: { width: 609.45, height: 365.67 },
    pageMargins: [20, 20, 20, 20],
    defaultStyle: {
        fontSize: 8,
        font: 'Roboto' 
    },
    content: [
        { text: 'PENERIMA SETORAN', bold: true, fontSize: 10, margin: [0, 0, 0, 2] },
        
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
                            ['Total Setoran', ':', { text: '17,000,000.00', alignment: 'right' }],
                            ['Terbilang', ':', terbilang || ''],
                            ['Keterangan', ':', 'SETOR TUNAI']
                        ]
                    }
                },
                {
                    width: '*', // KANAN
                    layout: 'noBorders',
                    table: {
                        widths: [75, 5, '*'],
                        body: [
                            ['Cabang', ':', '108 KANTOR CABANG UTAMA BALAIKOTA'],
                            ['Tanggal/Jam', ':', '20-12-2024 / 17:02:32'],
                            ['Jenis Transaksi', ':', '1000 - SETOR TUNAI'],
                            ['Mt Uang Setoran', ':', 'IDR - RUPIAH'],
                            ['Kode Referensi', ':', 'E2T7TW'],
                            ['Teller', ':', 'AR39190319'],
                            ['Supervisor', ':', '']
                        ]
                    }
                }
            ]
        },

        // --- BAGIAN BAWAH (PENYETOR & TANDA TANGAN) ---
        { text: 'PENYETOR', bold: true, fontSize: 9, margin: [0, 10, 0, 2] }, 
        {
            columnGap: 15,
            columns: [
                // KOLOM KIRI (Data Penyetor)
                {
                    width: '*', 
                    layout: 'noBorders',
                    table: {
                        widths: [75, 5, '*'],
                        body: [
                            ['Nama Penyetor', ':', 'MAYASARI'],
                            ['Alamat Penyetor', ':', 'JALAN MANDALA 1 NO 19'],
                            ['Identitas Diri', ':', 'KTP'],
                            ['No. Identitas', ':', '3175105503900009'],
                            ['No. Telp', ':', '089812121111'],
                            ['Sumber Dana', ':', ''],
                            ['Tujuan Transaksi', ':', '']
                        ]
                    }
                },
                // KOLOM KANAN (Tanda Tangan)
                {
                    width: '*', 
                    margin: [0, 5, 0, 0], // Sedikit margin atas agar sejajar
                    stack: [
                        { 
                            text: 'Setoran sah setelah divalidasi dan ditandatangani\noleh teller', 
                            alignment: 'center', 
                            margin: [0, 20, 0, 30] // Jarak margin bawah untuk area kosong tanda tangan
                        },
                        {
                            columns: [
                                { text: '--------------------------------------\nTeller', alignment: 'center' },
                                { text: '--------------------------------------\nPenyetor\nDepositor', alignment: 'center' }
                            ]
                        }
                    ]
                }
            ]
        }
    ]
};