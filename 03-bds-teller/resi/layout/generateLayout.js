async function getBase64FromUrl(url) {
    try {
        const response = await fetch(url);
        const blob = await response.blob();
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result);
            reader.onerror = reject;
            reader.readAsDataURL(blob);
        });
    } catch (error) {
        console.warn("Gagal memuat logo: ", error);
        return null;
    }
}

function generateLayoutSetorTunai(data) {
    const d = data || {};
    let terbilang = angkaTerbilang(d.totalSetoranRaw);
    if (terbilang) { terbilang = terbilang + ' RUPIAH' };

    return {
        pageSize: { width: 609.45, height: 365.67 },
        pageMargins: [20, 20, 20, 20],
        defaultStyle: {
            fontSize: 8,
            font: 'Roboto' 
        },
        content: [
            { text: 'PENERIMA SETORAN', bold: true, fontSize: 10, margin: [0, 0, 0, 2] },
            {
                columnGap: 15,
                columns: [
                    {
                        width: '*',
                        layout: 'noBorders',
                        table: {
                            widths: [75, 5, '*'],
                            body: [
                                ['Jenis Rekening', ':', d.jenisRekening || ''],
                                ['Nomor Rekening', ':', d.nomorRekening || ''],
                                ['Pemilik Rekening', ':', d.pemilikRekening || ''],
                                ['Cabang Tujuan', ':', d.cabangTujuan || ''],
                                ['Nominal Transaksi', ':', { text: 'Rp ' + d.nominalTransaksi || '0,00', alignment: 'right' }],
                                ['Kurs', ':', { text: 'Rp ' + d.kurs || '0,00', alignment: 'right' }],
                                ['Total Setoran', ':', { text: 'Rp ' + d.totalSetoran || '0,00', alignment: 'right' }],
                                ['Terbilang', ':', terbilang || ''],
                                ['Keterangan', ':', d.keterangan || '']
                            ]
                        }
                    },
                    {
                        width: '*', 
                        layout: 'noBorders',
                        table: {
                            widths: [75, 5, '*'],
                            body: [
                                ['Cabang', ':', d.cabang || ''],
                                ['Tanggal/Jam', ':', d.tanggalJam || ''],
                                ['Jenis Transaksi', ':', d.jenisTransaksi || ''],
                                ['Mt Uang Setoran', ':', d.mataUang || ''],
                                ['Kode Referensi', ':', d.kodeReferensi || ''],
                                ['Teller', ':', d.teller || ''],
                                ['Supervisor', ':', d.supervisor || '']
                            ]
                        }
                    }
                ]
            },

            { text: 'PENYETOR', bold: true, fontSize: 9, margin: [0, 10, 0, 2] }, 
            {
                columnGap: 15,
                columns: [
                    {
                        width: '*', 
                        layout: 'noBorders',
                        table: {
                            widths: [75, 5, '*'],
                            body: [
                                ['Nama Penyetor', ':', d.namaPenyetor || ''],
                                ['Alamat Penyetor', ':', d.alamatPenyetor || ''],
                                ['Identitas Diri', ':', d.identitasDiri || ''],
                                ['No. Identitas', ':', d.noIdentitas || ''],
                                ['No. Telp', ':', d.noTelp || ''],
                                ['Sumber Dana', ':', d.sumberDana || ''],
                                ['Tujuan Transaksi', ':', d.tujuanTransaksi || '']
                            ]
                        }
                    },
                    {
                        width: '*', 
                        margin: [0, 5, 0, 0],
                        stack: [
                            { 
                                text: 'Setoran sah setelah divalidasi dan ditandatangani\noleh teller', 
                                alignment: 'center', 
                                margin: [0, 20, 0, 30] 
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
}

function generateLayoutTarikTunai(data) {
    const d = data || {};
    let terbilang = angkaTerbilang(d.totalTarikanRaw);
    if (terbilang) { terbilang = terbilang + 'RUPIAH' };

    return {
        pageSize: { width: 609.45, height: 365.67 },
        pageMargins: [20, 20, 20, 20],
        defaultStyle: {
            fontSize: 8,
            font: 'Roboto' 
        },
        content: [
            { text: 'TARIKAN TUNAI', bold: true, fontSize: 10, margin: [0, 0, 0, 2] },
            {
                columnGap: 15,
                columns: [
                    {
                        width: '*',
                        layout: 'noBorders',
                        table: {
                            widths: [75, 5, '*'],
                            body: [
                                ['Jenis Rekening', ':', d.jenisRekening || '-'],
                                ['Nomor Rekening', ':', d.nomorRekening || '-'],
                                ['Pemilik Rekening', ':', d.pemilikRekening || '-'],
                                ['Cabang Tujuan', ':', d.cabangTujuan || '-'],
                                ['Nominal Transaksi', ':', { text: d.nominalTransaksi || '0,00', alignment: 'right' }],
                                ['Biaya', ':', { text: d.biaya || '0,00', alignment: 'right' }],
                                ['Kurs', ':', { text: d.kurs || '0,00', alignment: 'right' }],
                                ['Total Tarikan', ':', { text: d.totalTarikan || '0,00', alignment: 'right' }],
                                ['Terbilang', ':', terbilang || '-']
                            ]
                        }
                    },
                    {
                        width: '*',
                        layout: 'noBorders',
                        table: {
                            widths: [75, 5, '*'],
                            body: [
                                ['Cabang', ':', d.cabang || '-'],
                                ['Tanggal/Jam', ':', d.tanggalJam || '-'],
                                ['Jenis Transaksi', ':', d.jenisTransaksi || '-'],
                                ['Cabang Tujuan', ':', d.konsolTujuan || '-'],
                                ['Mt Uang Setoran', ':', d.mataUang || '-'],
                                ['Kode Referensi', ':', d.kodeReferensi || '-'],
                                ['Teller', ':', d.teller || '-'],
                                ['Supervisor', ':', d.supervisor || '-']
                            ]
                        }
                    }
                ]
            },

            {
                columnGap: 15,
                columns: [
                    {
                        width: '*',
                        margin: [0, 10, 0, 0],
                        layout: 'noBorders',
                        table: {
                            widths: [75, 5, '*'],
                            body: [
                                ['Alamat', ':', d.alamatPenarik || '-'],
                                ['No. Handphone', ':', d.noTelp || '-'],
                                ['Tujuan Penggunaan Dana', ':', d.tujuanPengDana || '-']
                            ]
                        }
                    },
                    {
                        width: '*', 
                        margin: [0, 5, 0, 0],
                        stack: [
                            { 
                                text: 'Tarikan sah setelah divalidasi dan ditandatangani oleh Teller', 
                                alignment: 'center', 
                                margin: [0, 20, 0, 30]
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
}

function generateLayoutTarikTunaiV2(data) {
    const d = data || {};

    return {
        pageSize: { width: 609.45, height: 365.67 },
        pageMargins: [20, 20, 20, 20],
        defaultStyle: {
            fontSize: 10,
            font: 'Roboto' 
        },
        content: [
            ...(d.logo ? [{ 
                image: d.logo, 
                width: 70, 
                alignment: 'right',
                margin: [0, -20, 0, 0]
            }] : []),

            { 
                text: 'DATA PENARIK', 
                bold: true,
                fontSize: 12, 
                alignment: 'left',
                margin: [0, (d.logo ? -35 : 0), 0, 5] 
            },

            {
                columnGap: 15,
                columns: [
                    {
                        width: '*',
                        layout: 'noBorders',
                        table: {
                            widths: [85, 5, '*'],
                            body: [
                                ['Nama', ':', d.namaPenarik || '-'],
                                ['Nomor Rekening', ':', d.nomorRekening || '-'],
                                ['No. Handphone', ':', d.noTelp || '-'],
                                ['Email', ':', d.email || '-'],
                                ['Nominal Penarikan', ':', 'Rp ' + d.nominal || '0,00'],
                                ['Biaya', ':', 'Rp ' + d.biaya || '0,00']
                            ]
                        }
                    },
                    {
                        width: '*',
                        layout: 'noBorders',
                        table: {
                            widths: [85, 5, '*'],
                            body: [
                                ['Tanggal', ':', d.tanggal || '-'],
                                ['Pukul', ':', d.jam || '-'],
                                ['Kode Cabang', ':', d.kodeCabang || '-'],
                                ['User Petugas', ':', d.petugas || '-'],
                                ['Kode Referensi', ':', d.kodeReferensi || '-']
                            ]
                        }
                    }
                ]
            },

            {
                text: 'Transaksi ini tunduk dan patuh pada ketentuan otoritas yang berlaku',
                alignment: 'left',
                margin: [0, 20, 0, 60]
            },
            {
                columns: [
                    { width: '*', text: '' }, // Pendorong ke kanan
                    { 
                        width: 'auto', 
                        columns: [
                            { 
                                width: 'auto',
                                text: '--------------------------------------\n' + (d.namaPenarik || 'NAMA PENARIK'), 
                                alignment: 'center'
                            }
                        ]
                    }
                ]
            }
        ]
    };
}

function generateLayoutTransfer(data) {
    const d = data || {};

    return {
        pageSize: { width: 609.45, height: 365.67 },
        pageMargins: [20, 20, 20, 20],
        defaultStyle: {
            fontSize: 8,
            font: 'Roboto' 
        },
        content: [
            ...(d.logo ? [{ 
                image: d.logo, 
                width: 70, 
                alignment: 'right',
                margin: [0, -20, 0, 0]
            }] : []),

            { 
                text: 'DATA PENGIRIM', 
                bold: true,
                fontSize: 10, 
                alignment: 'left',
                margin: [0, (d.logo ? -35 : 0), 0, 5] 
            },

            {
                columnGap: 15,
                columns: [
                    {
                        width: '*',
                        layout: 'noBorders',
                        table: {
                            widths: [75, 5, '*'],
                            body: [
                                ['Nama', ':', d.namaPengirim || '-'],
                                ['Nomor Rekening', ':', d.nomorRekPengirim || '-'],
                                ['No. Handphone', ':', d.noTelp || '-'],
                                ['E-Mail', ':', d.email || '-'],
                                ['Nominal Transfer', ':', { text: 'Rp ' + d.nominalTransaksi || '0,00', alignment: 'right' }],
                                ['Biaya Transfer', ':', { text: 'Rp ' + d.biayaTransaksi || '0,00', alignment: 'right' }],
                                ['Total Transfer', ':', { text: 'Rp ' + d.totalTransaksi || '0,00', alignment: 'right' }]
                            ]
                        }
                    },
                    {
                        width: '*',
                        layout: 'noBorders',
                        table: {
                            widths: [75, 5, '*'],
                            body: [
                                ['Jenis Transaksi', ':', d.jenisTransaksi || '-'],
                                ['Tanggal', ':', d.tanggalTransaksi || '-'],
                                ['Jam', ':', d.jamTransaksi || '-'],
                                ['Kode Cabang', ':', d.cabang || '-'],
                                ['User Petugas', ':', d.petugas || '-'],
                                ['Kode Referensi', ':', d.kodeReferensi || '-']
                            ]
                        }
                    }
                ]
            },

            { text: 'DATA PENERIMA', bold: true, fontSize: 9, margin: [0, 10, 0, 5] }, 
            {
                columnGap: 15,
                columns: [
                    {
                        width: '*',
                        layout: 'noBorders',
                        table: {
                            widths: [75, 5, '*'],
                            body: [
                                ['Nama', ':', d.namaPenerima || '-'],
                                ['Nomor Rekening', ':', d.nomorRekPenerima || '-'],
                                ['Nama Bank', ':', d.namaBankPenerima || '-']
                            ]
                        }
                    },
                    {
                        width: '*', 
                        margin: [0, 5, 0, 0],
                        stack: [
                            { 
                                text: 'Transaksi ini tunduk dan patuh pada ketentuan otoritas yang berlaku', 
                                alignment: 'center', 
                                margin: [0, 10, 0, 30]
                            },
                            {
                                columns: [
                                    { text: '--------------------------------------\n' + (d.namaPengirim || 'NAMA PENGIRIM'), alignment: 'center' }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    };
}