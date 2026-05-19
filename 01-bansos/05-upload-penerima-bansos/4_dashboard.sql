-- list proses upload data
select
    SUBSTR(
        fu.FILE_NAME,
        INSTR(fu.FILE_NAME, '/') + 1
    )                   nama_file,
    ub.STATUS           status_upload,
    ub.MESSAGE          keterangan,
    p.NAME              program,
    ub.CREATED_BY       diupload_oleh,
    ub.CREATION_DATE    diupload_pada
from 
    BJKT_UPLOAD_BANSOS      ub,
    BJKT_FILE_UPLOAD_LOG    fu,
    BJKT_MASTER_PROGRAMS    p
where
        p.ID    = ub.PROGRAM_ID
    and ub.ID   = fu.SOURCE_ID(+)
    and p.ID    = :G_BANSOS_PROGRAM_ID
order by ub.ID desc
;
/