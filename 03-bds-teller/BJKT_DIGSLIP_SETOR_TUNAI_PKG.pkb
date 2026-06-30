CREATE OR REPLACE PACKAGE BODY BJKT_DIGSLIP_SETOR_TUNAI_PKG AS

    PROCEDURE INSERT_SETOR_TUNAI (
        P_KODE_REF                  IN OUT VARCHAR2,
        P_PARENT_ID                 IN     NUMBER DEFAULT NULL,
        P_CHECK_SYARAT_KETENTUAN    IN     VARCHAR2,
        P_EXPIRED_MINUTES           IN     NUMBER DEFAULT C_DEFAULT_EXP_MIN,
        P_OUT_ID                    OUT    NUMBER,
        P_OUT_EXPIRED_AT            OUT    TIMESTAMP,
        P_OUT_CREATION_DATE         OUT    TIMESTAMP,
        P_OUT_STEP_NO               OUT    NUMBER,
        P_OUT_ROOT_PARENT_ID        OUT    NUMBER
    ) IS
        l_setor_tunai_iface BJKT_DIGSLIP_SETOR_TUNAI%ROWTYPE;

        l_id                BJKT_DIGSLIP_SETOR_TUNAI.SETOR_TUNAI_ID%TYPE;
        l_creation_date     BJKT_DIGSLIP_SETOR_TUNAI.CREATION_DATE%TYPE;
        l_email             BJKT_DIGSLIP_SETOR_TUNAI.EMAIL_PENYETOR%TYPE;
        l_no_hp             BJKT_DIGSLIP_SETOR_TUNAI.NOMOR_HP_PENYETOR%TYPE;
        l_alamat            BJKT_DIGSLIP_SETOR_TUNAI.ALAMAT_PENYETOR%TYPE;
        l_check_pelaku      BJKT_DIGSLIP_SETOR_TUNAI.CHECK_DATA_PENYETOR%TYPE;
        l_nik               BJKT_DIGSLIP_SETOR_TUNAI.NIK_PENYETOR%TYPE;
        l_nama_nik          BJKT_DIGSLIP_SETOR_TUNAI.NAMA_NIK_PENYETOR%TYPE;
        l_hub_dg_penerima   BJKT_DIGSLIP_SETOR_TUNAI.HUB_DGN_PENERIMA%TYPE;

        l_kode_ref          VARCHAR2(6);
        l_referal_id        NUMBER;
        l_expired_at        TIMESTAMP;
        l_step_no           NUMBER;
        l_root_parent_id    NUMBER;

    BEGIN
        -- Ambil data pelaku (penyetor) dari collection
        SELECT  c001 email,
                62 || c002 no_hp,
                c003 alamat,
                c004 check_pelaku,
                c005 nik,
                c006 nama_nik,
                c007 hub_dg_penerima
          INTO  l_email,
                l_no_hp,
                l_alamat,
                l_check_pelaku,
                l_nik,
                l_nama_nik,
                l_hub_dg_penerima
          FROM  apex_collections
         WHERE  collection_name = 'BJKT_DIGSLIP_SETOR_DATA_PELAKU';

        -- Loop data penerima dari collection, insert per baris
        FOR cur_bjkt_setor_tunai IN (
            SELECT c001 norek,
                   c002 nama_penerima,
                   n001 nominal,
                   c004 berita,
                   c005 tipe_nasabah,
                   c006 tujuan_transaksi,
                   c007 sumber_dana
              FROM apex_collections
             WHERE collection_name = 'BJKT_DIGSLIP_SETOR_DATA_PENERIMA'
        )
        LOOP
            l_setor_tunai_iface.NOMOR_REKENING_PENERIMA := cur_bjkt_setor_tunai.norek;
            l_setor_tunai_iface.NAMA_PENERIMA           := cur_bjkt_setor_tunai.nama_penerima;
            l_setor_tunai_iface.NOMINAL                 := cur_bjkt_setor_tunai.nominal;
            l_setor_tunai_iface.BERITA                  := cur_bjkt_setor_tunai.berita;
            l_setor_tunai_iface.TIPE_NASABAH            := cur_bjkt_setor_tunai.tipe_nasabah;
            l_setor_tunai_iface.TUJUAN_TRANSAKSI        := cur_bjkt_setor_tunai.tujuan_transaksi;
            l_setor_tunai_iface.SUMBER_DANA             := cur_bjkt_setor_tunai.sumber_dana;
            l_setor_tunai_iface.EMAIL_PENYETOR          := l_email;
            l_setor_tunai_iface.NOMOR_HP_PENYETOR       := l_no_hp;
            l_setor_tunai_iface.ALAMAT_PENYETOR         := l_alamat;
            l_setor_tunai_iface.CHECK_DATA_PENYETOR     := l_check_pelaku;
            l_setor_tunai_iface.NIK_PENYETOR            := l_nik;
            l_setor_tunai_iface.NAMA_NIK_PENYETOR       := l_nama_nik;
            l_setor_tunai_iface.HUB_DGN_PENERIMA        := l_hub_dg_penerima;

            /* 1) Insert transaksi setor tunai (TANPA kode referal, 
            karena kode referal sekarang dikelola terpusat) */
            INSERT INTO BJKT_DIGSLIP_SETOR_TUNAI (
                NOMOR_REKENING_PENERIMA,
                NAMA_PENERIMA,
                NOMINAL,
                BERITA,
                TIPE_NASABAH,
                TUJUAN_TRANSAKSI,
                SUMBER_DANA,
                EMAIL_PENYETOR,
                NOMOR_HP_PENYETOR,
                ALAMAT_PENYETOR,
                CHECK_DATA_PENYETOR,
                NIK_PENYETOR,
                NAMA_NIK_PENYETOR,
                HUB_DGN_PENERIMA,
                CHECK_SYARAT_KETENTUAN,
                KODE_REF
            ) VALUES (
                l_setor_tunai_iface.NOMOR_REKENING_PENERIMA,
                l_setor_tunai_iface.NAMA_PENERIMA,
                l_setor_tunai_iface.NOMINAL,
                l_setor_tunai_iface.BERITA,
                l_setor_tunai_iface.TIPE_NASABAH,
                l_setor_tunai_iface.TUJUAN_TRANSAKSI,
                l_setor_tunai_iface.SUMBER_DANA,
                l_setor_tunai_iface.EMAIL_PENYETOR,
                l_setor_tunai_iface.NOMOR_HP_PENYETOR,
                l_setor_tunai_iface.ALAMAT_PENYETOR,
                l_setor_tunai_iface.CHECK_DATA_PENYETOR,
                l_setor_tunai_iface.NIK_PENYETOR,
                l_setor_tunai_iface.NAMA_NIK_PENYETOR,
                l_setor_tunai_iface.HUB_DGN_PENERIMA,
                P_CHECK_SYARAT_KETENTUAN,
                P_KODE_REF
            )
            RETURNING SETOR_TUNAI_ID, CREATION_DATE
                 INTO l_id, l_creation_date;

            /* 2) Generate kode referal via package terpusat
            apabila kode ref ada maka generate child*/
            l_kode_ref   := P_KODE_REF; 
            l_expired_at := SYSTIMESTAMP + NUMTODSINTERVAL(P_EXPIRED_MINUTES, 'MINUTE');

            BJKT_DIGSLIP_KODE_REFERAL_PKG.INSERT_REFERAL(
                P_KODE_REF           => l_kode_ref,
                P_ID_TRANSAKSI       => l_id,
                P_TIPE_TRANSAKSI     => C_TIPE_TRANSAKSI,
                P_EXPIRED_AT         => l_expired_at,
                P_ID_PARENT          => P_PARENT_ID,
                P_OUT_ID             => l_referal_id,
                P_OUT_STEP_NO        => l_step_no,
                P_OUT_ROOT_PARENT_ID => l_root_parent_id
            );

            /* 3) Simpan balik kode referal & expired_at ke tabel transaksi
            (kolom KODE_REF / EXPIRED_DATE_QR berfungsi sebagai cache
            tampilan, bukan sumber kebenaran) */
            UPDATE BJKT_DIGSLIP_SETOR_TUNAI
            SET KODE_REF         = l_kode_ref,
                EXPIRED_DATE_QR  = l_expired_at
            WHERE SETOR_TUNAI_ID = l_id;

            -- Output mengikuti baris terakhir yang diproses dalam loop
            P_OUT_ID             := l_id;
            P_OUT_EXPIRED_AT     := l_expired_at;
            P_OUT_CREATION_DATE  := l_creation_date;
            P_OUT_STEP_NO        := l_step_no;
            P_OUT_ROOT_PARENT_ID := l_root_parent_id;

            COMMIT;
        END LOOP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20010,
                'Data pelaku tidak ditemukan di collection.'
            );
    END INSERT_SETOR_TUNAI;

    PROCEDURE BUILD_EMAIL_HTML (
        P_NAMA_PENERIMA     IN  VARCHAR2,
        P_CREATION_DATE     IN  TIMESTAMP,
        P_NOREK             IN  VARCHAR2,
        P_NOMINAL           IN  NUMBER,
        P_BERITA            IN  VARCHAR2,
        P_EXPIRED_AT        IN  TIMESTAMP,
        P_KODE_REF          IN  VARCHAR2,
        P_TAHUN             IN  VARCHAR2,
        P_OUT_HTML          OUT CLOB
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
                <h2 style="margin-bottom:20px;">Hi ' || P_NAMA_PENERIMA || ',</h2>
                <p>
                    Anda baru saja melakukan Pengajuan Transaksi Setoran Tunai melalui e-Form Bank Jakarta.
                    <br>Berikut adalah detail transaksi Anda:
                </p>
                <div style="background:#f7f7f7;border-radius:12px;padding:20px;margin-top:20px;">
                    <table width="100%" cellpadding="5" cellspacing="0">
                        <tr><td>Tanggal Input</td><td align="right">' || l_creation_date_char || '</td></tr>
                        <tr><td>Jenis Transaksi</td><td align="right">Setoran Tunai</td></tr>
                        <tr><td>Nomor Rekening</td><td align="right">' || P_NOREK || '</td></tr>
                        <tr><td>Nama Penerima</td><td align="right">' || P_NAMA_PENERIMA || '</td></tr>
                        <tr><td>Jumlah (IDR)</td><td align="right"><b>' || P_NOMINAL || '</b></td></tr>
                        <tr><td>Berita</td><td align="right">' || P_BERITA || '</td></tr>
                        <tr><td>Kedaluwarsa</td><td align="right">' || l_exp_date_char || '</td></tr>
                        <tr><td>Kode Referensi</td><td align="right"><strong>' || P_KODE_REF || '</strong></td></tr>
                    </table>
                </div>
                <p style="margin-top:30px;">Harap simpan email ini sebagai referensi transaksi Anda.</p>
                <p>Silakan datang ke Kantor Cabang Bank Jakarta terdekat dan tunjukkan Kode Referensi kepada petugas.</p>
                <p>Jika Anda tidak mengenali transaksi ini, segera hubungi Call Center Bank Jakarta di 1500-351.</p>
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
        P_NAMA_PENERIMA     IN  VARCHAR2,
        P_CREATION_DATE     IN  TIMESTAMP,
        P_NOREK             IN  VARCHAR2,
        P_NOMINAL           IN  NUMBER,
        P_BERITA            IN  VARCHAR2,
        P_EXPIRED_AT        IN  TIMESTAMP,
        P_KODE_REF          IN  VARCHAR2,
        P_TAHUN             IN  VARCHAR2
    ) IS
        l_html CLOB;
    BEGIN
        BUILD_EMAIL_HTML(
            P_NAMA_PENERIMA  => P_NAMA_PENERIMA,
            P_CREATION_DATE  => P_CREATION_DATE,
            P_NOREK          => P_NOREK,
            P_NOMINAL        => P_NOMINAL,
            P_BERITA         => P_BERITA,
            P_EXPIRED_AT     => P_EXPIRED_AT,
            P_KODE_REF       => P_KODE_REF,
            P_TAHUN          => P_TAHUN,
            P_OUT_HTML       => l_html
        );

        -- APEX_MAIL.SEND(
        --     p_to        => P_EMAIL_TO,
        --     p_from      => 'no-reply@gmail.com',
        --     p_subj      => 'Testing BDKI - Pengajuan Transaksi Setor Tunai',
        --     p_body      => 'Email ini membutuhkan HTML mail client.',
        --     p_body_html => l_html
        -- );

        -- APEX_MAIL.PUSH_QUEUE;
    END SEND_EMAIL_NOTIFICATION;

    PROCEDURE CLEAR_FORM_PAGE_CACHE IS
    BEGIN
        APEX_UTIL.CLEAR_PAGE_CACHE(1000);
        APEX_UTIL.CLEAR_PAGE_CACHE(1010);
        -- APEX_UTIL.CLEAR_PAGE_CACHE(1020);
    END CLEAR_FORM_PAGE_CACHE;

    PROCEDURE PROCESS_SETOR_TUNAI_SUBMIT (
        P_KODE_REF                  IN OUT VARCHAR2,
        P_PARENT_ID                 IN     NUMBER,
        P_CHECK_SYARAT_KETENTUAN    IN     VARCHAR2,
        P_EMAIL_TO                  IN     VARCHAR2,
        P_TAHUN                     IN     VARCHAR2,
        P_EXPIRED_MINUTES           IN     NUMBER DEFAULT C_DEFAULT_EXP_MIN,
        P_OUT_ID                    OUT    NUMBER,
        P_OUT_STEP_NO               OUT    NUMBER,
        P_OUT_ROOT_PARENT_ID        OUT    NUMBER
    ) IS
        l_id                NUMBER;
        l_kode_ref          VARCHAR2(6);
        l_expired_at        TIMESTAMP;
        l_creation_date     TIMESTAMP;
        l_step_no           NUMBER;
        l_root_parent_id    NUMBER;

        v_nama_penerima     BJKT_DIGSLIP_SETOR_TUNAI.NAMA_PENERIMA%TYPE;
        v_no_rekening       BJKT_DIGSLIP_SETOR_TUNAI.NOMOR_REKENING_PENERIMA%TYPE;
        v_nominal           BJKT_DIGSLIP_SETOR_TUNAI.NOMINAL%TYPE;
        v_berita            BJKT_DIGSLIP_SETOR_TUNAI.BERITA%TYPE;
    BEGIN
        INSERT_SETOR_TUNAI(
            P_KODE_REF               => P_KODE_REF,
            P_PARENT_ID              => P_PARENT_ID,
            P_CHECK_SYARAT_KETENTUAN => P_CHECK_SYARAT_KETENTUAN,
            P_EXPIRED_MINUTES        => P_EXPIRED_MINUTES,
            P_OUT_ID                 => l_id,
            P_OUT_EXPIRED_AT         => l_expired_at,
            P_OUT_CREATION_DATE      => l_creation_date,
            P_OUT_STEP_NO            => l_step_no,
            P_OUT_ROOT_PARENT_ID     => l_root_parent_id
        );

        -- SELECT NAMA_PENERIMA, NOMOR_REKENING_PENERIMA, NOMINAL, BERITA
        -- INTO v_nama_penerima, v_no_rekening, v_nominal, v_berita
        -- FROM BJKT_DIGSLIP_SETOR_TUNAI
        -- WHERE SETOR_TUNAI_ID = l_id;

        -- SEND_EMAIL_NOTIFICATION(
        --     P_EMAIL_TO      => P_EMAIL_TO,
        --     P_NAMA_PENERIMA => v_nama_penerima,
        --     P_CREATION_DATE => l_creation_date,
        --     P_NOREK         => v_no_rekening,
        --     P_NOMINAL       => v_nominal,
        --     P_BERITA        => v_berita,
        --     P_EXPIRED_AT    => l_expired_at,
        --     P_KODE_REF      => l_kode_ref,
        --     P_TAHUN         => P_TAHUN
        -- );

        CLEAR_FORM_PAGE_CACHE;

        P_OUT_ID             := l_id;
        P_OUT_STEP_NO        := l_step_no;
        P_OUT_ROOT_PARENT_ID := l_root_parent_id;
    END PROCESS_SETOR_TUNAI_SUBMIT;

END BJKT_DIGSLIP_SETOR_TUNAI_PKG;
/