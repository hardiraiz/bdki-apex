-- ## 1. Buat directory folder di server Oracle ##
/*
    mkdir -p /home/oracle/bjkt_files
    chmod 755 /home/oracle/bjkt_files
*/

-- ## 2. Buat Directory di Database Oracle LOGIN SEBAGAI SYS ##
CREATE OR REPLACE DIRECTORY BJKT_FILES_DIR AS '/home/oracle/bjkt_files';
/

GRANT READ, WRITE ON DIRECTORY BJKT_FILES_DIR TO DEV;
/

-- ## 3. Cek apakah directory berhasil dibuat ##
SELECT * FROM all_directories WHERE directory_name = 'BJKT_FILES_DIR';
/