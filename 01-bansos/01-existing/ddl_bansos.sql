create sequence tbl_dwh_master_kjp_id_seq;

alter sequence tbl_dwh_master_kjp_id_seq owner to devfo;

create sequence tbl_dwh_master_kjp_id_seq1;

alter sequence tbl_dwh_master_kjp_id_seq1 owner to devfo;

create table if not exists migrations
(
    id        serial
        primary key,
    migration varchar(255) not null,
    batch     integer      not null
);

alter table migrations
    owner to devfo;

create table if not exists menu_has_roles
(
    id      bigserial
        primary key,
    menu_id integer not null,
    role_id integer not null
);

alter table menu_has_roles
    owner to devfo;

create table if not exists menus
(
    id         integer      not null
        primary key,
    name       varchar(255) not null,
    route      varchar(255),
    icon       varchar(255),
    parent_id  integer      not null,
    "order"    integer      not null,
    created_at timestamp(0),
    updated_at timestamp(0),
    deleted_at timestamp(0)
);

alter table menus
    owner to devfo;

create table if not exists users
(
    id                bigserial
        primary key,
    name              varchar(255)                       not null,
    nrik              varchar(255)                       not null
        constraint users_nrik_unique
            unique,
    username          varchar(255)                       not null
        constraint users_username_unique
            unique,
    email             varchar(255)                       not null
        constraint users_email_unique
            unique,
    password          varchar(255)                       not null,
    tanggal_lahir     date,
    foto              text,
    id_unit_kerja     integer                            not null,
    status_data       integer default 1                  not null,
    is_blokir         smallint,
    ip_address        varchar(255),
    session_id        text,
    last_seen         timestamp(0),
    last_activity     timestamp(0),
    expired_password  date    default '1970-01-01'::date not null,
    created_by        bigint,
    updated_by        bigint,
    email_verified_at timestamp(0),
    remember_token    varchar(100),
    created_at        timestamp(0),
    updated_at        timestamp(0)
);

alter table users
    owner to devfo;

create table if not exists password_resets
(
    email      varchar(255) not null,
    token      varchar(255) not null,
    created_at timestamp(0)
);

alter table password_resets
    owner to devfo;

create index if not exists password_resets_email_index
    on password_resets (email);

create table if not exists failed_jobs
(
    id         bigserial
        primary key,
    uuid       varchar(255)                           not null
        constraint failed_jobs_uuid_unique
            unique,
    connection text                                   not null,
    queue      text                                   not null,
    payload    text                                   not null,
    exception  text                                   not null,
    failed_at  timestamp(0) default CURRENT_TIMESTAMP not null
);

alter table failed_jobs
    owner to devfo;

create table if not exists personal_access_tokens
(
    id             bigserial
        primary key,
    tokenable_type varchar(255) not null,
    tokenable_id   bigint       not null,
    name           varchar(255) not null,
    token          varchar(64)  not null
        constraint personal_access_tokens_token_unique
            unique,
    abilities      text,
    last_used_at   timestamp(0),
    created_at     timestamp(0),
    updated_at     timestamp(0)
);

alter table personal_access_tokens
    owner to devfo;

create index if not exists personal_access_tokens_tokenable_type_tokenable_id_index
    on personal_access_tokens (tokenable_type, tokenable_id);

create table if not exists tbl_master_unit_kerja
(
    id          bigserial
        primary key,
    nama        varchar(100)                   not null,
    singkatan   varchar(10)                    not null,
    status_data smallint default '1'::smallint not null,
    created_at  timestamp(0),
    updated_at  timestamp(0)
);

alter table tbl_master_unit_kerja
    owner to devfo;

create table if not exists users_log_activities
(
    id               bigserial
        primary key,
    ip_access        varchar(255) not null,
    id_user          bigint       not null
        constraint users_log_activities_id_user_foreign
            references users,
    activity_content text         not null,
    url              text         not null,
    operating_system varchar(255) not null,
    device_type      varchar(255) not null,
    browser_name     varchar(255) not null,
    method           varchar(255) not null,
    created_at       timestamp(0),
    updated_at       timestamp(0)
);

alter table users_log_activities
    owner to devfo;

create table if not exists tbl_master_divisi
(
    id            bigserial
        primary key,
    unit_kerja_id integer      not null,
    nama_divisi   varchar(255) not null,
    created_at    timestamp(0),
    updated_at    timestamp(0)
);

alter table tbl_master_divisi
    owner to devfo;

create table if not exists tbl_master_departemen
(
    id              bigserial
        primary key,
    unit_kerja_id   integer not null,
    divisi_id       integer not null,
    nama_departemen text    not null,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_departemen
    owner to devfo;

create table if not exists tbl_master_jenis_kelamin
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_jenis_kelamin_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_jenis_kelamin
    owner to devfo;

create table if not exists tbl_master_kebangsaan
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_kebangsaan_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_kebangsaan
    owner to devfo;

create table if not exists tbl_master_status_kawin
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_status_kawin_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_status_kawin
    owner to devfo;

create table if not exists tbl_master_agama
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_agama_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_agama
    owner to devfo;

create table if not exists tbl_master_pendidikan
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_pendidikan_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_pendidikan
    owner to devfo;

create table if not exists tbl_master_pekerjaan
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_pekerjaan_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_pekerjaan
    owner to devfo;

create table if not exists tbl_master_profesi
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_profesi_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_profesi
    owner to devfo;

create table if not exists tbl_master_status_pekerjaan
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_status_pekerjaan_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_status_pekerjaan
    owner to devfo;

create table if not exists tbl_master_hubungan_keluarga
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_hubungan_keluarga_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_hubungan_keluarga
    owner to devfo;

create table if not exists tbl_master_status_rumah
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_status_rumah_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_status_rumah
    owner to devfo;

create table if not exists tbl_master_status_proses
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_status_proses_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_status_proses
    owner to devfo;

create table if not exists tbl_master_status_distribusi
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_status_distribusi_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_status_distribusi
    owner to devfo;

create table if not exists tbl_master_status_dana
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_status_dana_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_status_dana
    owner to devfo;

create table if not exists tbl_master_status_penerima
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_status_penerima_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_status_penerima
    owner to devfo;

create table if not exists tbl_master_program
(
    id                bigserial
        primary key,
    kode              varchar(255)                                   not null,
    nama              varchar(255)                                   not null,
    tahun             integer                                        not null,
    tahap             integer                                        not null,
    anggaran          double precision default '0'::double precision not null,
    kepgub            varchar(255)                                   not null,
    status_data       smallint         default '1'::smallint         not null,
    id_user_request   bigint           default '2'::bigint           not null
        constraint tbl_master_program_id_user_request_foreign
            references users,
    created_at        timestamp(0),
    updated_at        timestamp(0),
    nomor_rekening_ss text,
    nama_rekening_ss  text
);

alter table tbl_master_program
    owner to devfo;

create table if not exists tbl_history_penerima_bansos
(
    id                              bigserial
        primary key,
    nama                            text                                         not null,
    kode_master_jenis_kelamin       varchar(255)                                 not null,
    kode_master_kebangsaan          varchar(255)                                 not null,
    tempat_lahir                    text                                         not null,
    tanggal_lahir                   text                                         not null,
    no_identitas                    varchar(255)                                 not null,
    nama_ibu_atau_wali              text                                         not null,
    kode_master_agama               varchar(255)                                 not null,
    kode_master_pendidikan          varchar(255)                                 not null,
    alamat_ktp                      text                                         not null,
    alamat_domisili                 text                                         not null,
    rt                              varchar(255)                                 not null,
    rw                              varchar(255)                                 not null,
    kelurahan                       text                                         not null,
    kecamatan                       text                                         not null,
    kota                            text                                         not null,
    provinsi                        text                                         not null,
    kode_pos                        varchar(255)                                 not null,
    no_telepon                      varchar(255)                                 not null,
    nama_instansi                   text                                         not null,
    alamat_instansi                 text                                         not null,
    kode_pos_instansi               varchar(255)                                 not null,
    no_telepon_instansi             varchar(255)                                 not null,
    nama_pihak_dihubungi            text                                         not null,
    kode_master_hubungan_keluarga   varchar(255)                                 not null,
    alamat_pihak_dihubungi          text                                         not null,
    kota_pihak_dihubungi            text                                         not null,
    provinsi_dihubungi              text                                         not null,
    no_telepon_dihubungi            varchar(255)                                 not null,
    kode_master_status_kawin        varchar(255)                                 not null,
    kode_master_status_rumah        varchar(255)                                 not null,
    kode_master_pekerjaan           varchar(255)                                 not null,
    kode_master_profesi             varchar(255)                                 not null,
    kode_master_status_pekerjaan    varchar(255)                                 not null,
    suami_istri                     text,
    kode_master_status_proses       varchar(255) default '0'::character varying  not null,
    kode_master_status_distribusi   varchar(255) default '00'::character varying not null,
    kode_master_status_dana         varchar(255) default '3'::character varying  not null,
    kode_master_status_rekening     varchar(255) default '3'::character varying  not null,
    kode_master_program             varchar(255)                                 not null,
    id_user_approve                 bigint,
    kode_upload                     varchar(255)                                 not null,
    tanggal_upload                  timestamp(0)                                 not null,
    flag_validasi                   boolean      default false                   not null,
    keterangan_validasi             json                                         not null,
    nominal_dana                    double precision,
    no_rekening                     varchar(255),
    kode_master_status_penerima     text         default '00'::text              not null,
    no_kartu_atm                    varchar(255),
    penanggung_jawab_distribusi     text,
    lokasi_distribusi               text,
    tanggal_proses                  json,
    id_user_request                 bigint       default '0'::bigint             not null
        constraint tbl_history_penerima_bansos_id_user_request_foreign
            references users,
    is_approve_upload_dana          boolean      default false                   not null,
    created_at                      timestamp(0),
    updated_at                      timestamp(0),
    nomor_instansi                  text,
    kode_master_jenis_instansi      text,
    kode_master_status_debit_kredit text,
    kode_master_lokasi_distribusi   text,
    total_dana                      double precision
);

alter table tbl_history_penerima_bansos
    owner to devfo;

create table if not exists permissions
(
    id         integer      not null
        primary key,
    name       varchar(255) not null,
    guard_name varchar(255) not null,
    created_at timestamp(0),
    updated_at timestamp(0),
    constraint permissions_name_guard_name_unique
        unique (name, guard_name)
);

alter table permissions
    owner to devfo;

create table if not exists roles
(
    id         integer      not null
        primary key,
    name       varchar(255) not null,
    guard_name varchar(255) not null,
    created_at timestamp(0),
    updated_at timestamp(0),
    constraint roles_name_guard_name_unique
        unique (name, guard_name)
);

alter table roles
    owner to devfo;

create table if not exists model_has_permissions
(
    permission_id bigint       not null
        constraint model_has_permissions_permission_id_foreign
            references permissions
            on delete cascade,
    model_type    varchar(255) not null,
    model_id      bigint       not null,
    primary key (permission_id, model_id, model_type)
);

alter table model_has_permissions
    owner to devfo;

create index if not exists model_has_permissions_model_id_model_type_index
    on model_has_permissions (model_id, model_type);

create table if not exists model_has_roles
(
    role_id    bigint       not null
        constraint model_has_roles_role_id_foreign
            references roles
            on delete cascade,
    model_type varchar(255) not null,
    model_id   bigint       not null,
    primary key (role_id, model_id, model_type)
);

alter table model_has_roles
    owner to devfo;

create index if not exists model_has_roles_model_id_model_type_index
    on model_has_roles (model_id, model_type);

create table if not exists role_has_permissions
(
    permission_id bigint not null
        constraint role_has_permissions_permission_id_foreign
            references permissions
            on delete cascade,
    role_id       bigint not null
        constraint role_has_permissions_role_id_foreign
            references roles
            on delete cascade,
    primary key (permission_id, role_id)
);

alter table role_has_permissions
    owner to devfo;

create table if not exists tbl_master_status_rekening
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_status_rekening_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_status_rekening
    owner to devfo;

create table if not exists tbl_master_block_wali
(
    id              bigserial
        primary key,
    kode            varchar(255)                   not null,
    deskripsi       varchar(255)                   not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '2'::bigint   not null
        constraint tbl_master_block_wali_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_block_wali
    owner to devfo;

create table if not exists tbl_history_upload
(
    id                  bigserial
        primary key,
    nama_file           text                       not null,
    kode_upload         text                       not null,
    kode_master_program text                       not null,
    status_upload       text   default '0'::text   not null,
    ket_status_upload   text,
    id_user_request     bigint default '2'::bigint not null,
    created_at          timestamp(0),
    updated_at          timestamp(0)
);

alter table tbl_history_upload
    owner to devfo;

create table if not exists jobs
(
    id           bigserial
        primary key,
    queue        varchar(255) not null,
    payload      text         not null,
    attempts     smallint     not null,
    reserved_at  integer,
    available_at integer      not null,
    created_at   integer      not null
);

alter table jobs
    owner to devfo;

create index if not exists jobs_queue_index
    on jobs (queue);

create table if not exists tbl_dwh_master_kjp
(
    id         bigint default nextval('tbl_dwh_master_kjp_id_seq1'::regclass) not null
        primary key,
    nik        varchar(255)                                                   not null,
    norek      varchar(255)                                                   not null,
    nama_bv    varchar(255)                                                   not null,
    created_at timestamp(0),
    updated_at timestamp(0)
);

alter table tbl_dwh_master_kjp
    owner to devfo;

alter sequence tbl_dwh_master_kjp_id_seq1 owned by tbl_dwh_master_kjp.id;

create table if not exists tbl_master_jenis_instansi
(
    id              bigserial
        primary key,
    kode            text                           not null,
    deskripsi       text                           not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '0'::bigint   not null
        constraint tbl_master_jenis_instansi_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_jenis_instansi
    owner to devfo;

create table if not exists tbl_master_status_debit_kredit
(
    id              bigserial
        primary key,
    kode            text                           not null,
    deskripsi       text                           not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '0'::bigint   not null
        constraint tbl_master_status_debit_kredit_id_user_request_foreign
            references users,
    is_debit        boolean  default false         not null,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_status_debit_kredit
    owner to devfo;

create table if not exists tbl_master_lokasi_distribusi
(
    id              bigserial
        primary key,
    kode            text                           not null,
    nama            text                           not null,
    deskripsi       text                           not null,
    status_data     smallint default '1'::smallint not null,
    id_user_request bigint   default '0'::bigint   not null
        constraint tbl_master_lokasi_distribusi_id_user_request_foreign
            references users,
    created_at      timestamp(0),
    updated_at      timestamp(0)
);

alter table tbl_master_lokasi_distribusi
    owner to devfo;

