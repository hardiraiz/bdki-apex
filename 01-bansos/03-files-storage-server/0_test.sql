/*
    Masuk ke Termius atau Putty
    masuk ke folder oracle sebagai super admin karena file storage diletakkan disini
    command: sudo su - oracle

    hapus file yang ada didalam folder
    command: rm -f /home/oracle/bjkt_files/*
*/

SELECT * FROM bjkt_file_upload_log;
/
DELETE FROM bjkt_file_upload_log;
/
COMMIT;
/