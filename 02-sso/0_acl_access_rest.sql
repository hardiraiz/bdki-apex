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
        -- LOWER_PORT  => NULL,
        -- UPPER_PORT  => NULL,
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