CREATE OR REPLACE PACKAGE BODY BJKT_DIGSLIP_PELAKU_TRANSAKSI_PKG AS

    PROCEDURE INSERT_PELAKU_TRANSAKSI (
        P_CHECK_SYARAT_KETENTUAN    IN  VARCHAR2,
        P_EXPIRED_MINUTES           IN  NUMBER DEFAULT C_DEFAULT_EXP_MIN,
        P_OUT_ID                    OUT NUMBER,
        P_OUT_KODE_REF              OUT VARCHAR2,
        P_OUT_EXPIRED_AT            OUT TIMESTAMP,
        P_OUT_CREATION_DATE         OUT TIMESTAMP,
        P_OUT_REFERAL_ID            OUT NUMBER
    ) IS
        l_pelaku_trx_iface  BJKT_DIGSLIP_PELAKU_TRANSAKSI%ROWTYPE;

        l_id                BJKT_DIGSLIP_PELAKU_TRANSAKSI.PELAKU_TRANSAKSI_ID%TYPE;
        l_creation_date     BJKT_DIGSLIP_PELAKU_TRANSAKSI.CREATION_DATE%TYPE;

        l_kode_ref          VARCHAR2(6);
        l_referal_id        NUMBER;
        l_expired_at        TIMESTAMP;

        l_step_no           NUMBER;
        l_root_parent_id    NUMBER;
    BEGIN
        FOR cur_bjkt_pelaku_trx IN (
            SELECT  c001 AS jenis_pelaku,
                    c002 AS nama_lengkap,
                    c003 AS nama_alias,
                    c004 AS nik,
                    c005 AS jenis_kelamin,
                    c006 AS kewarganegaran,
                    c007 AS ibu_kandung,
                    c008 AS alamat_ktp,
                    c009 AS prov,
                    c010 AS kota_kab,
                    c011 AS kecamatan,
                    c012 AS kodepos,
                    c013 AS tipe_alamat,
                    62 || c014 AS no_hp,
                    c015 AS email,
                    c016 AS pekerjaan,
                    c017 AS tmp_kerja,
                    c018 AS ngr_domisili,
                    c019 AS sumberdana,
                    c020 AS tempat_lahir,
                    d001 AS tgl_lahir,
                    c021 AS politic_person
              FROM apex_collections
             WHERE collection_name = 'BJKT_DIGSLIP_INPUT_PELAKU_TRANSAKSI'
        )
        LOOP
            l_pelaku_trx_iface.JENIS_PELAKU         := cur_bjkt_pelaku_trx.jenis_pelaku;
            l_pelaku_trx_iface.NAMA_LENGKAP         := cur_bjkt_pelaku_trx.nama_lengkap;
            l_pelaku_trx_iface.NAMA_ALIAS           := cur_bjkt_pelaku_trx.nama_alias;
            l_pelaku_trx_iface.EMAIL                := cur_bjkt_pelaku_trx.email;
            l_pelaku_trx_iface.TEMPAT_LAHIR         := cur_bjkt_pelaku_trx.tempat_lahir;
            l_pelaku_trx_iface.TANGGAL_LAHIR        := cur_bjkt_pelaku_trx.tgl_lahir;
            l_pelaku_trx_iface.NIK                  := cur_bjkt_pelaku_trx.nik;
            l_pelaku_trx_iface.JENIS_KELAMIN        := cur_bjkt_pelaku_trx.jenis_kelamin;
            l_pelaku_trx_iface.KEWARGANEGARAAN      := cur_bjkt_pelaku_trx.kewarganegaran;
            l_pelaku_trx_iface.ALAMAT_KTP           := cur_bjkt_pelaku_trx.alamat_ktp;
            l_pelaku_trx_iface.PROVINSI             := cur_bjkt_pelaku_trx.prov;
            l_pelaku_trx_iface.KOTA_KAB             := cur_bjkt_pelaku_trx.kota_kab;
            l_pelaku_trx_iface.KECAMATAN            := cur_bjkt_pelaku_trx.kecamatan;
            l_pelaku_trx_iface.KODE_POS             := cur_bjkt_pelaku_trx.kodepos;
            l_pelaku_trx_iface.TIPE_ALAMAT          := cur_bjkt_pelaku_trx.tipe_alamat;
            l_pelaku_trx_iface.NOMOR_HP             := cur_bjkt_pelaku_trx.no_hp;
            l_pelaku_trx_iface.PEKERJAAN            := cur_bjkt_pelaku_trx.pekerjaan;
            l_pelaku_trx_iface.TEMPAT_BEKERJA       := cur_bjkt_pelaku_trx.tmp_kerja;
            l_pelaku_trx_iface.NEGARA_DOMISILI      := cur_bjkt_pelaku_trx.ngr_domisili;
            l_pelaku_trx_iface.SUMBER_DANA          := cur_bjkt_pelaku_trx.sumberdana;
            l_pelaku_trx_iface.POLITIC_PERSON       := cur_bjkt_pelaku_trx.politic_person;

            /* 1) Insert data pelaku transaksi (TANPA kode referal,
            karena kode referal sekarang dikelola terpusat) */
            INSERT INTO BJKT_DIGSLIP_PELAKU_TRANSAKSI (
                JENIS_PELAKU,
                NAMA_LENGKAP,
                NAMA_ALIAS,
                EMAIL,
                TEMPAT_LAHIR,
                TANGGAL_LAHIR,
                NIK,
                JENIS_KELAMIN,
                KEWARGANEGARAAN,
                ALAMAT_KTP,
                PROVINSI,
                KOTA_KAB,
                KECAMATAN,
                KODE_POS,
                TIPE_ALAMAT,
                NOMOR_HP,
                PEKERJAAN,
                TEMPAT_BEKERJA,
                NEGARA_DOMISILI,
                SUMBER_DANA,
                POLITIC_PERSON,
                CHECK_SYARAT_KETENTUAN
            ) VALUES (
                l_pelaku_trx_iface.JENIS_PELAKU,
                l_pelaku_trx_iface.NAMA_LENGKAP,
                l_pelaku_trx_iface.NAMA_ALIAS,
                l_pelaku_trx_iface.EMAIL,
                l_pelaku_trx_iface.TEMPAT_LAHIR,
                l_pelaku_trx_iface.TANGGAL_LAHIR,
                l_pelaku_trx_iface.NIK,
                l_pelaku_trx_iface.JENIS_KELAMIN,
                l_pelaku_trx_iface.KEWARGANEGARAAN,
                l_pelaku_trx_iface.ALAMAT_KTP,
                l_pelaku_trx_iface.PROVINSI,
                l_pelaku_trx_iface.KOTA_KAB,
                l_pelaku_trx_iface.KECAMATAN,
                l_pelaku_trx_iface.KODE_POS,
                l_pelaku_trx_iface.TIPE_ALAMAT,
                l_pelaku_trx_iface.NOMOR_HP,
                l_pelaku_trx_iface.PEKERJAAN,
                l_pelaku_trx_iface.TEMPAT_BEKERJA,
                l_pelaku_trx_iface.NEGARA_DOMISILI,
                l_pelaku_trx_iface.SUMBER_DANA,
                l_pelaku_trx_iface.POLITIC_PERSON,
                P_CHECK_SYARAT_KETENTUAN
            )
            RETURNING PELAKU_TRANSAKSI_ID, CREATION_DATE
                 INTO l_id, l_creation_date;

            /* 2) Generate kode referal ROOT via package terpusat
                  (PARENT_ID = NULL -> ini adalah titik awal flow,
                  kode referal ini nantinya dipakai sebagai PARENT_ID
                  untuk transaksi child, misal Setor Tunai) */
            l_kode_ref   := NULL; -- biar di-generate otomatis
            l_expired_at := SYSTIMESTAMP + NUMTODSINTERVAL(P_EXPIRED_MINUTES, 'MINUTE');

            BJKT_DIGSLIP_KODE_REFERAL_PKG.INSERT_REFERAL(
                P_KODE_REF           => l_kode_ref,
                P_ID_TRANSAKSI       => l_id,
                P_TIPE_TRANSAKSI     => C_TIPE_TRANSAKSI,
                P_EXPIRED_AT         => l_expired_at,
                P_ID_PARENT          => NULL,
                P_OUT_ID             => l_referal_id,
                P_OUT_STEP_NO        => l_step_no,
                P_OUT_ROOT_PARENT_ID => l_root_parent_id
            );

            /* 3) Simpan balik kode referal & expired_at ke tabel pelaku
                  (kolom KODE_REF / EXPIRED_DATE_QR berfungsi sebagai cache
                  tampilan, bukan sumber kebenaran) */
            UPDATE BJKT_DIGSLIP_PELAKU_TRANSAKSI
               SET KODE_REF        = l_kode_ref,
                   EXPIRED_DATE_QR = l_expired_at
             WHERE PELAKU_TRANSAKSI_ID = l_id;

            -- Output mengikuti baris terakhir yang diproses dalam loop
            P_OUT_ID            := l_id;
            P_OUT_KODE_REF      := l_kode_ref;
            P_OUT_EXPIRED_AT    := l_expired_at;
            P_OUT_CREATION_DATE := l_creation_date;
            P_OUT_REFERAL_ID    := l_referal_id;
        END LOOP;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Error=' || SQLERRM
            );
    END INSERT_PELAKU_TRANSAKSI;


    PROCEDURE BUILD_EMAIL_HTML (
        P_NAMA_LENGKAP      IN  VARCHAR2,
        P_CREATION_DATE     IN  TIMESTAMP,
        P_EXPIRED_AT        IN  TIMESTAMP,
        P_KODE_REF          IN  VARCHAR2,
        P_TAHUN             IN  VARCHAR2,
        P_OUT_HTML          OUT VARCHAR2
    ) IS
        l_creation_date_char VARCHAR2(255);
        l_exp_date_char      VARCHAR2(255);
    BEGIN
        l_creation_date_char := TO_CHAR(P_CREATION_DATE, 'DD Mon YYYY HH24:MI');
        l_exp_date_char      := TO_CHAR(P_EXPIRED_AT, 'DD Mon YYYY HH24:MI');

        P_OUT_HTML :=
            '<html>
            <head><meta charset="UTF-8"></head>
            <body style="font-family:Arial,Helvetica,sans-serif;background:#ffffff;color:#333;">
            <div style="max-width:600px;margin:auto;">
                <h2 style="margin-bottom:20px;">Hi ' || P_NAMA_LENGKAP || ',</h2>
                <p>
                    Anda baru saja melakukan Input Form Pelaku Transaksi melalui e-Form Bank Jakarta.
                    <br>Berikut adalah detail pengajuan Anda:
                </p>
                <div style="background:#f7f7f7;border-radius:12px;padding:20px;margin-top:20px;">
                    <table width="100%" cellpadding="5" cellspacing="0">
                        <tr><td>Tanggal Input</td><td align="right">' || l_creation_date_char || '</td></tr>
                        <tr><td>Jenis Transaksi</td><td align="right">Pelaku Transaksi</td></tr>
                        <tr><td>Nama Lengkap</td><td align="right">' || P_NAMA_LENGKAP || '</td></tr>
                        <tr><td>Kedaluwarsa</td><td align="right">' || l_exp_date_char || '</td></tr>
                        <tr><td>Kode Referensi</td><td align="right"><strong>' || P_KODE_REF || '</strong></td></tr>
                    </table>
                </div>
                <p style="margin-top:30px;">Harap simpan email ini sebagai referensi pengajuan Anda.</p>
                <p>Silakan datang ke Kantor Cabang Bank Jakarta terdekat dan tunjukkan Kode Referensi kepada petugas.</p>
                <p>Jika Anda tidak mengenali pengajuan ini, segera hubungi Call Center Bank Jakarta di 1500-351.</p>
                <p>Salam hormat,<br>Bank Jakarta</p>
                <hr>
                <p style="font-size:12px;color:#777;">
                    Copyright &copy; ' || P_TAHUN || ' <b>Bank Jakarta</b><br>
                    Bertumbuh, Berkelanjutan Bersama Jakarta
                </p>
            </div>
            </body>
            </html>';
    END BUILD_EMAIL_HTML;


    PROCEDURE SEND_EMAIL_NOTIFICATION (
        P_EMAIL_TO          IN  VARCHAR2,
        P_NAMA_LENGKAP      IN  VARCHAR2,
        P_CREATION_DATE     IN  TIMESTAMP,
        P_EXPIRED_AT        IN  TIMESTAMP,
        P_KODE_REF          IN  VARCHAR2,
        P_TAHUN             IN  VARCHAR2
    ) IS
        l_html CLOB;
    BEGIN
        BUILD_EMAIL_HTML(
            P_NAMA_LENGKAP   => P_NAMA_LENGKAP,
            P_CREATION_DATE  => P_CREATION_DATE,
            P_EXPIRED_AT     => P_EXPIRED_AT,
            P_KODE_REF       => P_KODE_REF,
            P_TAHUN          => P_TAHUN,
            P_OUT_HTML       => l_html
        );

        -- APEX_MAIL.SEND(
        --     p_to        => P_EMAIL_TO,
        --     p_from      => 'no-reply@gmail.com',
        --     p_subj      => 'Testing BDKI - Input Form Pelaku Transaksi',
        --     p_body      => 'Email ini membutuhkan HTML mail client.',
        --     p_body_html => l_html
        -- );

        -- APEX_MAIL.PUSH_QUEUE;
    END SEND_EMAIL_NOTIFICATION;

    PROCEDURE CLEAR_FORM_PAGE_CACHE IS
    BEGIN
        APEX_UTIL.CLEAR_PAGE_CACHE(3000);
        APEX_UTIL.CLEAR_PAGE_CACHE(3010);
    END CLEAR_FORM_PAGE_CACHE;


    PROCEDURE PROCESS_PELAKU_TRANSAKSI_SUBMIT (
        P_CHECK_SYARAT_KETENTUAN    IN  VARCHAR2,
        P_EMAIL_TO                  IN  VARCHAR2,
        P_NAMA_LENGKAP              IN  VARCHAR2,
        P_TAHUN                     IN  VARCHAR2,
        P_EXPIRED_MINUTES           IN  NUMBER DEFAULT C_DEFAULT_EXP_MIN,
        P_OUT_ID                    OUT NUMBER,
        P_OUT_KODE_REF              OUT VARCHAR2,
        P_OUT_REFERAL_ID            OUT NUMBER
    ) IS
        l_id             NUMBER;
        l_kode_ref       VARCHAR2(6);
        l_expired_at     TIMESTAMP;
        l_creation_date  TIMESTAMP;
        l_referal_id     NUMBER;
    BEGIN
        INSERT_PELAKU_TRANSAKSI(
            P_CHECK_SYARAT_KETENTUAN => P_CHECK_SYARAT_KETENTUAN,
            P_EXPIRED_MINUTES        => P_EXPIRED_MINUTES,
            P_OUT_ID                 => l_id,
            P_OUT_KODE_REF           => l_kode_ref,
            P_OUT_EXPIRED_AT         => l_expired_at,
            P_OUT_CREATION_DATE      => l_creation_date,
            P_OUT_REFERAL_ID         => l_referal_id
        );

        -- SEND_EMAIL_NOTIFICATION(
        --     P_EMAIL_TO      => P_EMAIL_TO,
        --     P_NAMA_LENGKAP  => P_NAMA_LENGKAP,
        --     P_CREATION_DATE => l_creation_date,
        --     P_EXPIRED_AT    => l_expired_at,
        --     P_KODE_REF      => l_kode_ref,
        --     P_TAHUN         => P_TAHUN
        -- );

        CLEAR_FORM_PAGE_CACHE;

        P_OUT_ID         := l_id;
        P_OUT_KODE_REF   := l_kode_ref;
        P_OUT_REFERAL_ID := l_referal_id;
    END PROCESS_PELAKU_TRANSAKSI_SUBMIT;

END BJKT_DIGSLIP_PELAKU_TRANSAKSI_PKG;
/