insert into BJKT_FND_CREDENTIAL
    ( name, description, url, version, client_id, client_key )
values
    ('BJKT', 'Bank Jakarta Credential', 'http://10.114.40.11:38001', '1.0', 'APEX', 'dAb2VerDdx3Q7U6TEqu8oKE0bMhXeuft');

COMMIT;
/


DECLARE
    L_TIMESTAMP VARCHAR2 (200);
    L_TOKEN     VARCHAR2 (4000);
BEGIN
    L_TIMESTAMP := TO_CHAR (SYSTIMESTAMP, 'rrrr-mm-dd') 
                        || 'T'
                        || TO_CHAR (SYSTIMESTAMP, 'hh24:mi:ssTZR');

    L_TOKEN := APX_SSO_INTEGRATIONS.GET_ACCESS_TOKEN(L_TIMESTAMP);

    DBMS_OUTPUT.PUT_LINE('TOKEN: ' || L_TOKEN);
END;
/

DECLARE
  P_INPUT VARCHAR2(200);
  v_Return VARCHAR2(200);
BEGIN
  P_INPUT := NULL;
  v_Return := DEV.BJKT_JAVA_PKG.HASH256(
    P_INPUT => 'APEX|2025-01-20T10:42:42+07:00');
  DBMS_OUTPUT.PUT_LINE('v_Return = ' || v_Return);
  --:v_Return := v_Return;
  -- Rollback;
end;
/

SELECT * FROM BJKT_API_LOG ORDER BY LOG_ID DESC;
/

BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace(
    host => '10.114.43.159',
    ace  => xs$ace_type(
              privilege_list => xs$name_list('connect','resolve'),
              principal_name => 'DEV',
              principal_type => xs_acl.ptype_db
            )
  );

  COMMIT;
END;
/
BEGIN
  DBMS_NETWORK_ACL_ADMIN.append_host_ace(
    host => 'api.agify.io',
    ace  => xs$ace_type(
              privilege_list => xs$name_list('connect', 'resolve'),
              principal_name => 'APEX_240200',
              principal_type => xs_acl.ptype_db
           )
  );

  COMMIT;
END;
/
/
-- Jalankan sebagai SYSDBA
SELECT HOST, LOWER_PORT, UPPER_PORT, ACL 
FROM DBA_NETWORK_ACLS
WHERE HOST = '10.114.40.11';
/

-- Cek privilege user
SELECT ACL, PRINCIPAL, PRIVILEGE, IS_GRANT
FROM DBA_NETWORK_ACL_PRIVILEGES
-- WHERE PRINCIPAL = 'YOUR_DB_USER'
; -- ganti dengan user Oracle Anda
/
-- Jalankan di SQL Workshop APEX atau SQL*Plus
SELECT USER FROM DUAL;

-- Atau lebih detail
SELECT SYS_CONTEXT('USERENV', 'SESSION_USER')  AS SESSION_USER,
       SYS_CONTEXT('USERENV', 'CURRENT_USER')  AS CURRENT_USER,
       SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS CURRENT_SCHEMA
FROM DUAL;
/

SELECT USER FROM DUAL;
/

-- Ganti 'YOUR_SCHEMA' dengan hasil Step 1
BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
        HOST        => 'api.agify.io',
        ACE         => XS$ACE_TYPE (
                            PRIVILEGE_LIST => XS$NAME_LIST('connect', 'resolve'),
                            PRINCIPAL_NAME => 'SYS',  -- ganti dengan hasil Step 1
                            PRINCIPAL_TYPE => XS_ACL.PTYPE_DB
                       )
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('ACL berhasil ditambahkan.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => 'api.agify.io',
    lower_port => 80,
    upper_port => 443,
    ace => xs$ace_type(
      privilege_list => xs$name_list('http', 'connect', 'resolve'),
      principal_name => 'DEV',
      principal_type => xs_acl.ptype_db
    )
  );
  COMMIT;
END;
/

-- Jalankan sebagai SYSDBA
-- Cek semua ACL yang ada
SELECT HOST, LOWER_PORT, UPPER_PORT, ACL
FROM DBA_NETWORK_ACLS;
/

-- Cek privilege semua user
SELECT ACL, PRINCIPAL, PRIVILEGE, IS_GRANT
FROM DBA_NETWORK_ACL_PRIVILEGES;
/

-- Jalankan di SQL Workshop APEX
SELECT USER                                         AS DB_USER,
       SYS_CONTEXT('USERENV', 'SESSION_USER')       AS SESSION_USER,
       SYS_CONTEXT('USERENV', 'CURRENT_USER')       AS CURRENT_USER,
       SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')     AS CURRENT_SCHEMA,
       SYS_CONTEXT('USERENV', 'PROXY_USER')         AS PROXY_USER
FROM DUAL;
/

-- Jalankan sebagai SYSDBA
-- Tambahkan APEX_PUBLIC_USER
BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
        HOST        => '10.114.40.11',
        -- LOWER_PORT  => 38001,
        -- UPPER_PORT  => 38001,
        ACE         => XS$ACE_TYPE (
                            PRIVILEGE_LIST => XS$NAME_LIST('connect', 'resolve'),
                            PRINCIPAL_NAME => 'APEX_PUBLIC_USER',
                            PRINCIPAL_TYPE => XS_ACL.PTYPE_DB
                       )
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('ACL APEX_PUBLIC_USER berhasil ditambahkan.');
END;
/
-- Hasil ACL biasanya berformat: sys:xdb:default-19c-ace$
-- Hapus menggunakan REMOVE_HOST_ACE
BEGIN
    DBMS_NETWORK_ACL_ADMIN.REMOVE_HOST_ACE (
        HOST        => '10.114.40.11',
        LOWER_PORT  => NULL,
        UPPER_PORT  => NULL,
        ACE         => XS$ACE_TYPE (
                            PRIVILEGE_LIST => XS$NAME_LIST('connect', 'resolve'),
                            PRINCIPAL_NAME => 'APEX_PUBLIC_USER',
                            PRINCIPAL_TYPE => XS_ACL.PTYPE_DB
                       )
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('ACL berhasil dihapus.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Tambahkan APEX_240200 (versi APEX yang digunakan berdasarkan error message)
BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
        HOST        => '10.114.40.11',
        -- LOWER_PORT  => 38001,
        -- UPPER_PORT  => 38001,
        ACE         => XS$ACE_TYPE (
                            PRIVILEGE_LIST => XS$NAME_LIST('connect', 'resolve'),
                            PRINCIPAL_NAME => 'APEX_240200',
                            PRINCIPAL_TYPE => XS_ACL.PTYPE_DB
                       )
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('ACL APEX_240200 berhasil ditambahkan.');
END;
/
-- Hasil ACL biasanya berformat: sys:xdb:default-19c-ace$
-- Hapus menggunakan REMOVE_HOST_ACE
BEGIN
    DBMS_NETWORK_ACL_ADMIN.REMOVE_HOST_ACE (
        HOST        => '10.114.40.11',
        LOWER_PORT  => NULL,
        UPPER_PORT  => NULL,
        ACE         => XS$ACE_TYPE (
                            PRIVILEGE_LIST => XS$NAME_LIST('connect', 'resolve'),
                            PRINCIPAL_NAME => 'APEX_240200',
                            PRINCIPAL_TYPE => XS_ACL.PTYPE_DB
                       )
    );
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('ACL berhasil dihapus.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

SELECT * FROM V$VERSION;
/

DELETE FROM BJKT_ACCESS_TOKEN;
/
DELETE FROM BJKT_API_LOG;
/
COMMIT;
/

SELECT LOG_ID, IFACE_STATUS, IFACE_MESSAGE, RESPONSE FROM BJKT_API_LOG ORDER BY LOG_ID DESC FETCH FIRST ROW ONLY;
/

SELECT * FROM BJKT_API_LOG ORDER BY LOG_ID DESC FETCH FIRST ROW ONLY;
/

SELECT CLIENT_ID,
       CLIENT_KEY,
       URL,
       WALLET_PATH,
       WALLET_PASSWORD
FROM BJKT_FND_CREDENTIAL
FETCH FIRST 1 ROW ONLY;
/

SELECT * FROM BJKT_FND_CREDENTIAL;
/

select COUNT(*) from BJKT_DIVISIONS;
/

select COUNT(*) from BJKT_DEPARTMENTS;
/

select COUNT(*) from BJKT_POSITIONS;
/

select COUNT(*) from BJKT_LEVELS;
/

select COUNT(*) from BJKT_WORK_UNITS;
/

select COUNT(*) from BJKT_MODEL_WORK_UNITS;
/