create or replace package body bjkt_eform_integrations_pkg as
   l_bank_jkt  varchar2(100) := 'BJKT eForm';
   l_api_group varchar2(100) := '/service-sso/';

   procedure iface_log (
      p_log    in bjkt_api_log%rowtype,
      x_log_id out varchar2,
      x_status out varchar2
   ) is
   begin
      insert into bjkt_api_log (
         name,
         url,
         content_type,
         authorization,
         partner_id,
         time_stamp,
         signature,
         external_id,
         channel_id,
         ray_id,
         access_token,
         header,
         request,
         response,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         iface_mode,
         iface_status,
         iface_message,
         created_by,
         creation_date,
         last_update_login,
         last_updated_by,
         last_update_date
      ) values ( p_log.name,
                 p_log.url,
                 p_log.content_type,
                 p_log.authorization,
                 p_log.partner_id,
                 p_log.time_stamp,
                 p_log.signature,
                 p_log.external_id,
                 p_log.channel_id,
                 p_log.ray_id,
                 p_log.access_token,
                 p_log.header,
                 p_log.request,
                 p_log.response,
                 p_log.attribute_category,
                 p_log.attribute1,
                 p_log.attribute2,
                 p_log.attribute3,
                 p_log.attribute4,
                 p_log.attribute5,
                 p_log.attribute6,
                 p_log.attribute7,
                 p_log.attribute8,
                 p_log.attribute9,
                 p_log.attribute10,
                 p_log.attribute11,
                 p_log.attribute12,
                 p_log.attribute13,
                 p_log.attribute14,
                 p_log.attribute15,
                 p_log.iface_mode,
                 p_log.iface_status,
                 p_log.iface_message,
                 p_log.created_by,
                 sysdate, --p_log.creation_date,
                 p_log.last_update_login,
                 p_log.last_updated_by,
                 p_log.last_update_date ) returning log_id into x_log_id;

      x_status := 'SUCCESS';
      commit;
   exception
      when others then
         x_log_id := null;
         x_status := 'ERROR';
   end iface_log;

   function get_exist_token return varchar2 is
      l_access_token    varchar2(4000);
      l_timestamp_token varchar2(200);
      l_expired_in      number;
   begin
      select access_token,
             timestamp_token,
             expired_in
        into
         l_access_token,
         l_timestamp_token,
         l_expired_in
        from bjkt_access_token
       where name = l_bank_jkt
       order by id desc
       fetch first 1 row only;

      if systimestamp > ( to_timestamp_tz ( l_timestamp_token,
      'YYYY-MM-DD"T"HH24:MI:SS"Z"' ) + numtodsinterval(
         l_expired_in - 60,
         'SECOND'
      ) ) then
         return null;
      end if;

      return l_access_token;
   exception
      when others then
         return null;
   end;


   function get_access_token (
      p_timestamp in varchar2
   ) return varchar2 as
      l_timestamp          varchar2(200);
      l_client_id          varchar2(1000);
      l_private_key        varchar2(4000);
      l_url                varchar2(4000);
      l_path               varchar2(4000) default '/gateway/JWTAccessToken/1.0';
      l_wallet_path        varchar2(4000);
      l_wallet_password    varchar2(4000);
      l_clean_key          varchar2(4000);
      l_stringtosign       varchar2(4000);
      l_signature          varchar2(4000);
      l_ray_id             varchar2(20);
      l_body               clob;
      l_result_clob        clob;
      l_header             clob;
      l_token              varchar2(4000);
      l_response_code      number;
        -- L_RESPONSE_STATUS       BOOLEAN;
        -- L_RESPONSE_STATUS_CODE  VARCHAR2 (4000);
      l_response_timestamp varchar2(200);
      l_expired_in         varchar2(500);
      l_log                bjkt_api_log%rowtype;
      l_log_id             varchar2(100);
      l_log_status         varchar2(100);
   begin
      /*l_token := get_exist_token();
      if l_token is not null then
         return l_token;
      end if;
      */

        -- Continue to generate access token when existing token expired or not exists
      l_timestamp := p_timestamp;
      select client_key,
             url,
             wallet_path,
             wallet_password
        into
         l_client_id,
         l_url,
         l_wallet_path,
         l_wallet_password
        from bjkt_fnd_credential
       where name = l_bank_jkt
       fetch first 1 row only;

      /*
      l_stringtosign := l_client_id
                        || '|'
                        || l_timestamp;
      l_signature := bjkt_java_pkg.hash256(p_input => l_stringtosign);
      l_ray_id := bjkt_java_pkg.get_ray_id();
      */

      apex_web_service.g_request_headers.delete;
      apex_web_service.g_request_headers(1).name := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json';
      apex_web_service.g_request_headers(2).name := 'X-CLIENT-KEY';
      apex_web_service.g_request_headers(2).value := l_client_id;
      for i in 1..apex_web_service.g_request_headers.count loop
         l_header := l_header
                     || apex_web_service.g_request_headers(i).name
                     || ': '
                     || apex_web_service.g_request_headers(i).value
                     || chr(10);
      end loop;

      select
         json_object(
            key 'grant_type' value 'client_credentials'
         )
        into l_body
        from dual;

      l_result_clob := apex_web_service.make_rest_request(
         p_url         => l_url || l_path,
         p_http_method => 'POST',
         p_body        => l_body
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
      );

      l_response_code := apex_web_service.g_status_code;
      if l_response_code <> 200 then
         l_log.iface_status := 'ERROR';
         l_log.iface_message := 'ERROR CODE : ' || to_char(l_response_code);
         l_log.url := l_url;
         l_log.name := l_bank_jkt;
         l_log.ray_id := l_ray_id;
         l_log.access_token := l_token;
         l_log.request := l_body;
         l_log.response := l_result_clob;
         l_log.iface_mode := 'POST';
         l_log.header := l_header;
         iface_log(
            p_log    => l_log,
            x_log_id => l_log_id,
            x_status => l_log_status
         );
         return null;
      end if;

      apex_json.parse(l_result_clob);
      l_token := apex_json.get_varchar2(p_path => 'accessToken');
      insert into bjkt_access_token (
         name,
         access_token,
         timestamp_token,
         expired_in
      ) values ( l_bank_jkt,
                 l_token,
                 l_response_timestamp,
                 l_expired_in );

      commit;
      return l_token;
   exception
      when others then
         l_log.url := l_url;
         l_log.name := l_bank_jkt;
         l_log.ray_id := l_ray_id;
         l_log.access_token := l_token;
         l_log.request := l_body;
         l_log.response := l_result_clob;
         l_log.header := l_header;
         l_log.iface_status := 'ERROR';
         l_log.iface_mode := 'POST';
         l_log.iface_message := sqlerrm;
         iface_log(
            p_log    => l_log,
            x_log_id => l_log_id,
            x_status => l_log_status
         );
         return null;
   end get_access_token;

   procedure get_transaction_deposit (
      p_kode_ref in varchar2,
      r_status   out varchar2,
      r_message  out varchar2
   ) is
      l_path            varchar2(1000) default '/gateway/InternalBdsServices/1.0/scanQRTrx';
      l_timestamp       varchar2(200);
      l_token           varchar2(4000);
      l_client_id       varchar2(1000);
      l_client_key      varchar2(4000);
      l_signature       varchar2(4000);
      l_ray_id          varchar2(20);
      l_header          clob;
      l_body            clob;
      l_result_clob     clob;
      l_url             varchar2(4000);
      l_wallet_path     varchar2(4000);
      l_wallet_password varchar2(4000);
      l_response_code   number;
      l_status          boolean;
      l_status_code     varchar2(4000);
      l_log             bjkt_api_log%rowtype;
      l_log_id          varchar2(100);
      l_log_status      varchar2(100);
   begin
      select client_id,
             client_key,
             url,
             wallet_path,
             wallet_password
        into
         l_client_id,
         l_client_key,
         l_url,
         l_wallet_path,
         l_wallet_password
        from bjkt_fnd_credential
       where name = l_bank_jkt
       fetch first 1 row only;

      l_timestamp := to_char(
         systimestamp,
         'rrrr-mm-dd'
      )
                     || 'T'
                     || to_char(
         systimestamp,
         'hh24:mi:ssTZR'
      );

      l_token := get_access_token(l_timestamp);
      dbms_output.put_line('l_token get' || l_token);
      select
         json_object(
            key 'kode_referensi' value p_kode_ref
         )
        into l_body
        from dual;

      apex_web_service.g_request_headers.delete;
      apex_web_service.g_request_headers(1).name := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json';
      apex_web_service.g_request_headers(2).name := 'Authorization';
      apex_web_service.g_request_headers(2).value := 'Bearer ' || l_token;
      for i in 1..apex_web_service.g_request_headers.count loop
         l_header := l_header
                     || apex_web_service.g_request_headers(i).name
                     || ': '
                     || apex_web_service.g_request_headers(i).value
                     || chr(10);
      end loop;

      l_result_clob := apex_web_service.make_rest_request(
         p_url         => l_url || l_path,
         p_http_method => 'POST',
         p_body        => l_body
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
      );

      dbms_output.put_line('Result    ' || l_result_clob);
      apex_json.parse(l_result_clob);
      l_status := apex_json.get_boolean(p_path => 'status');
      l_status_code := apex_json.get_varchar2(p_path => 'statusCode');
      if l_status then
         null;
      else
         r_status := 'ERROR';
         r_message := 'ERROR CODE : ' || to_char(l_status_code);
         l_log.iface_status := 'ERROR';
         l_log.iface_message := 'ERROR CODE : ' || to_char(l_status_code);
         l_log.url := l_url || l_path;
         l_log.name := l_bank_jkt;
         l_log.ray_id := l_ray_id;
         l_log.access_token := l_token;
         l_log.request := l_body;
         l_log.response := l_result_clob;
         l_log.iface_mode := 'POST';
         l_log.content_type := apex_web_service.g_request_headers(1).value;
         l_log.authorization := apex_web_service.g_request_headers(2).value;
         l_log.header := l_header;
         iface_log(
            p_log    => l_log,
            x_log_id => l_log_id,
            x_status => l_log_status
         );
         return;
      end if;

      for rec in (
         select jt.*
           from
            json_table ( l_result_clob,'$'
               columns (
                -- 1. LEVEL ROOT
                  root_message varchar2 ( 255 ) path '$.message',
                  root_status varchar2 ( 10 ) path '$.status',

                -- 2. LEVEL DATA (MAIN OBJECT)
                  kode_referensi varchar2 ( 50 ) path '$.data.kode_referensi',
                  no_rekening varchar2 ( 50 ) path '$.data.no_rekening',
                  nama_nasabah varchar2 ( 150 ) path '$.data.nama',
                  nominal_setoran number path '$.data.nominal_setoran',
                  berita varchar2 ( 255 ) path '$.data.berita',
                  master_tipe_nasabah varchar2 ( 100 ) path '$.data.master_tipe_nasabah',
                  master_tujuan_transaksi varchar2 ( 100 ) path '$.data.master_tujuan_transaksi',
                  master_sumber_dana varchar2 ( 100 ) path '$.data.master_sumber_dana',
                  email_penyetor varchar2 ( 100 ) path '$.data.email_penyetor',
                  no_hp_penyetor varchar2 ( 50 ) path '$.data.no_ho_penyetor',
                  alamat_nasabah varchar2 ( 255 ) path '$.data.alamat',
                  is_pelaku_penerima_sama varchar2 ( 10 ) path '$.data.is_pelaku_penerima_sama',
                  pelaku_nik varchar2 ( 50 ) path '$.data.pelaku_nik',
                  pelaku_nama varchar2 ( 150 ) path '$.data.pelaku_nama',
                  master_pelaku_hubungan varchar2 ( 100 ) path '$.data.master_pelaku_hubungan',
                  data_created_at varchar2 ( 50 ) path '$.data.created_at',
                  data_expired_at varchar2 ( 50 ) path '$.data.expired_at',
                  data_email_send_at varchar2 ( 50 ) path '$.data.email_send_at',
                  is_exist_dwh varchar2 ( 10 ) path '$.data.is_exist_dwh',
                  nested path '$.data.data_pelaku_transaksi[*]'
                     columns (
                        p_nik varchar2 ( 50 ) path '$.nik',
                        p_master_jenis_pelaku varchar2 ( 100 ) path '$.master_jenis_pelaku_transaksi',
                        p_nama_lengkap varchar2 ( 150 ) path '$.nama_lengkap',
                        p_nama_alias varchar2 ( 150 ) path '$.nama_alias',
                        p_tempat_lahir varchar2 ( 100 ) path '$.tempat_lahir',
                        p_tanggal_lahir varchar2 ( 50 ) path '$.tanggal_lahir',
                        p_master_jenis_kelamin varchar2 ( 50 ) path '$.master_jenis_kelamin',
                        p_nama_ibu_kandung varchar2 ( 150 ) path '$.nama_ibu_kandung',
                        p_master_kewarganegaraan varchar2 ( 50 ) path '$.master_kewarganegaraan',
                        p_alamat varchar2 ( 255 ) path '$.alamat',
                        p_master_provinsi varchar2 ( 100 ) path '$.master_provinsi',
                        p_master_kab_kota varchar2 ( 100 ) path '$.master_kab_kota',
                        p_master_kecamatan varchar2 ( 100 ) path '$.master_kecamatan',
                        p_master_kelurahan varchar2 ( 100 ) path '$.master_kelurahan',
                        p_kode_pos varchar2 ( 20 ) path '$.kode_pos',
                        p_master_tipe_alamat varchar2 ( 100 ) path '$.master_tipe_alamat',
                        p_nomor_telepon varchar2 ( 50 ) path '$.nomor_telepon',
                        p_master_kategori_kontak varchar2 ( 100 ) path '$.master_kategori_kontak',
                        p_email varchar2 ( 100 ) path '$.email',
                        p_pekerjaan varchar2 ( 100 ) path '$.pekerjaan',
                        p_tempat_bekerja varchar2 ( 150 ) path '$.tempat_bekerja',
                        p_is_pep varchar2 ( 10 ) path '$.is_politically_exposed_person',
                        p_negara varchar2 ( 100 ) path '$.negara',
                        p_master_sumber_dana varchar2 ( 100 ) path '$.master_sumber_dana',
                        p_penghasilan_per_tahun number path '$.penghasilan_per_tahun',
                        p_master_penggunaan_dana varchar2 ( 100 ) path '$.master_penggunaan_dana',
                        p_master_alat_komunikasi varchar2 ( 100 ) path '$.master_alat_komunikasi',
                        p_created_at varchar2 ( 50 ) path '$.created_at'
                     )
               )
            )
         jt
      ) loop
         /*insert into bjkt_digslip_setor_tunai (
            setor_tunai_id,
            nomor_rekening_penerima,
            nama_penerima,
            nominal,
            berita,
            tipe_nasabah,
            tujuan_transaksi,
            sumber_dana,
            email_penyetor,
            nomor_hp_penyetor,
            alamat_penyetor,
            nik_penyetor,
            nama_nik_penyetor,
            hub_dgn_penerima,
            check_data_penyetor,
            check_syarat_ketentuan,
            expired_date_qr,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            kode_ref,
            qr_image,
            mime_type,
            file_name,
            work_unit_id,
            status,
            submitted_by,
            cancelled_by,
            nama_cabang,
            trace_number
         ) values ( setor_tunai_id,
                    nomor_rekening_penerima,
                    nama_penerima,
                    nominal,
                    berita,
                    tipe_nasabah,
                    tujuan_transaksi,
                    sumber_dana,
                    email_penyetor,
                    nomor_hp_penyetor,
                    alamat_penyetor,
                    nik_penyetor,
                    nama_nik_penyetor,
                    hub_dgn_penerima,
                    check_data_penyetor,
                    check_syarat_ketentuan,
                    expired_date_qr,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    kode_ref,
                    qr_image,
                    mime_type,
                    file_name,
                    work_unit_id,
                    status,
                    submitted_by,
                    cancelled_by,
                    nama_cabang,
                    trace_number );*/
         null;
      end loop;


      r_status := 'SUCCESS';
      r_message := 'Get transaction deposit successfully';
      commit;
   exception
      when others then
         r_status := 'ERROR';
         r_message := sqlerrm;
         l_log.url := l_url || l_path;
         l_log.name := l_bank_jkt;
         l_log.ray_id := l_ray_id;
         l_log.access_token := l_token;
         l_log.request := l_body;
         l_log.response := l_result_clob;
         l_log.content_type := apex_web_service.g_request_headers(1).value;
         l_log.authorization := apex_web_service.g_request_headers(2).value;
         l_log.header := l_header;
         l_log.iface_status := 'ERROR';
         l_log.iface_mode := 'POST';
         l_log.iface_message := sqlerrm;
         iface_log(
            p_log    => l_log,
            x_log_id => l_log_id,
            x_status => l_log_status
         );
   end get_transaction_deposit;

   procedure get_transaction_withdraw (
      p_kode_ref in varchar2,
      r_status   out varchar2,
      r_message  out varchar2
   ) is
      l_path            varchar2(1000) default '/gateway/InternalBdsServices/1.0/scanQRTrx';
      l_timestamp       varchar2(200);
      l_token           varchar2(4000);
      l_client_id       varchar2(1000);
      l_client_key      varchar2(4000);
      l_signature       varchar2(4000);
      l_ray_id          varchar2(20);
      l_header          clob;
      l_body            clob;
      l_result_clob     clob;
      l_url             varchar2(4000);
      l_wallet_path     varchar2(4000);
      l_wallet_password varchar2(4000);
      l_response_code   number;
      l_status          boolean;
      l_status_code     varchar2(4000);
      l_log             bjkt_api_log%rowtype;
      l_log_id          varchar2(100);
      l_log_status      varchar2(100);
      l_exist_count     number;
   begin
      select count(*)
        into l_exist_count
        from bjkt_digslip_tarik_tunai
       where kode_ref = p_kode_ref;

      if l_exist_count > 0 then
         r_status := 'ERROR';
         r_message := 'Transaction withdraw already exist';
         return; -- Langsung keluar dari procedure jika data sudah ada
      end if;

      select client_id,
             client_key,
             url,
             wallet_path,
             wallet_password
        into
         l_client_id,
         l_client_key,
         l_url,
         l_wallet_path,
         l_wallet_password
        from bjkt_fnd_credential
       where name = l_bank_jkt
       fetch first 1 row only;

      l_timestamp := to_char(
         systimestamp,
         'rrrr-mm-dd'
      )
                     || 'T'
                     || to_char(
         systimestamp,
         'hh24:mi:ssTZR'
      );

      l_token := get_access_token(l_timestamp);
      dbms_output.put_line('l_token get' || l_token);

      --l_ray_id := bjkt_java_pkg.get_ray_id();
      select
         json_object(
            key 'kode_referensi' value p_kode_ref
         )
        into l_body
        from dual;

      apex_web_service.g_request_headers.delete;
      apex_web_service.g_request_headers(1).name := 'Content-Type';
      apex_web_service.g_request_headers(1).value := 'application/json';
      apex_web_service.g_request_headers(2).name := 'Authorization';
      apex_web_service.g_request_headers(2).value := 'Bearer ' || l_token;
      for i in 1..apex_web_service.g_request_headers.count loop
         l_header := l_header
                     || apex_web_service.g_request_headers(i).name
                     || ': '
                     || apex_web_service.g_request_headers(i).value
                     || chr(10);
      end loop;

      l_result_clob := apex_web_service.make_rest_request(
         p_url         => l_url || l_path,
         p_http_method => 'POST',
         p_body        => l_body
                -- P_WALLET_PATH   => L_WALLET_PATH,
                -- P_WALLET_PWD    => L_WALLET_PASSWORD
      );

      dbms_output.put_line('Result    ' || l_result_clob);
      apex_json.parse(l_result_clob);
      l_status := apex_json.get_boolean(p_path => 'status');
      l_status_code := apex_json.get_varchar2(p_path => 'statusCode');
      if l_status then
         null;
      else
         r_status := 'ERROR';
         r_message := 'ERROR CODE : ' || to_char(l_status_code);
         l_log.iface_status := 'ERROR';
         l_log.iface_message := 'ERROR CODE : ' || to_char(l_status_code);
         l_log.url := l_url || l_path;
         l_log.name := l_bank_jkt;
         l_log.ray_id := l_ray_id;
         l_log.access_token := l_token;
         l_log.request := l_body;
         l_log.response := l_result_clob;
         l_log.iface_mode := 'POST';
         l_log.content_type := apex_web_service.g_request_headers(1).value;
         l_log.authorization := apex_web_service.g_request_headers(2).value;
         l_log.header := l_header;
         iface_log(
            p_log    => l_log,
            x_log_id => l_log_id,
            x_status => l_log_status
         );
         return;
      end if;

      for rec in (
         select jt.*
           from
            json_table ( l_result_clob,'$'
               columns (
                  status varchar2 ( 10 ) path '$.status',
                  message varchar2 ( 255 ) path '$.message',
                  kode_referensi varchar2 ( 50 ) path '$.data.kode_referensi',
                  no_rekening varchar2 ( 50 ) path '$.data.no_rekening',
                  nama varchar2 ( 150 ) path '$.data.nama',
                  email varchar2 ( 100 ) path '$.data.email',
                  no_hp_penyetor varchar2 ( 30 ) path '$.data.no_hp_penyetor',
                  alamat varchar2 ( 255 ) path '$.data.alamat',
                  nominal_tarik_tunai number path '$.data.nominal_tarik_tunai',
                  nama_kantor_cabang varchar2 ( 100 ) path '$.data.nama_kantor_cabang',
                  biaya number path '$.data.biaya',
                  master_tujuan_transaksi varchar2 ( 100 ) path '$.data.master_tujuan_transaksi',
                  created_at varchar2 ( 50 ) path '$.data.created_at',
                  expired_at varchar2 ( 50 ) path '$.data.expired_at',
                  email_send_at varchar2 ( 50 ) path '$.data.email_send_at'
               )
            )
         jt
      ) loop
         insert into bjkt_digslip_tarik_tunai (
            kode_ref,
            nomor_rekening,
            nama,
            email,
            nomor_hp,
            alamat,
            nominal_tarik,
            tujuan_penggunaan_dana,
            check_syarat_ketentuan,
            expired_date_qr,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            kantor_cabang,
            tanggal_tarik,
            status,
            submitted_by,
            cancelled_by,
            work_unit_id
         ) values ( rec.kode_referensi,
                    rec.no_rekening,
                    rec.nama,
                    rec.email,
                    rec.no_hp_penyetor,
                    rec.alamat,
                    rec.nominal_tarik_tunai,
                    rec.master_tujuan_transaksi,
                    'Y', --check_syarat_ketentuan,
                    cast(to_timestamp_tz(rec.expired_at,
                           'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"') as date),
                    null, --created_by,
                    null, --creation_date,
                    null, --last_updated_by,
                    null, --last_update_date,
                    rec.nama_kantor_cabang,
                    cast(to_timestamp_tz(rec.created_at,
                           'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"') as date),
                    null, --status,
                    null, --submitted_by,
                    null, --cancelled_by,
                    null --work_unit_id 
                     );
      end loop;

      r_status := 'SUCCESS';
      r_message := 'Get transaction withdraw successfully';
      commit;
   exception
      when others then
         r_status := 'ERROR';
         r_message := sqlerrm;
         l_log.url := l_url || l_path;
         l_log.name := l_bank_jkt;
         l_log.ray_id := l_ray_id;
         l_log.access_token := l_token;
         l_log.request := l_body;
         l_log.response := l_result_clob;
         l_log.content_type := apex_web_service.g_request_headers(1).value;
         l_log.authorization := apex_web_service.g_request_headers(2).value;
         l_log.header := l_header;
         l_log.iface_status := 'ERROR';
         l_log.iface_mode := 'POST';
         l_log.iface_message := sqlerrm;
         iface_log(
            p_log    => l_log,
            x_log_id => l_log_id,
            x_status => l_log_status
         );
   end get_transaction_withdraw;

end bjkt_eform_integrations_pkg;
/