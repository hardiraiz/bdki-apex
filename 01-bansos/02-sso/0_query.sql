-- List data master user sso
SELECT * FROM BJKT_USERS_SSO_INQUIRIES;
/

-- List data divisi
SELECT * FROM BJKT_DIVISIONS;
/

-- list data departemen
SELECT * FROM BJKT_DEPARTMENTS;
/

-- list data jabatan
SELECT * FROM BJKT_POSITIONS;
/

-- list data tingkatan
SELECT * FROM BJKT_LEVELS;
/

/*
    list data unit kerja (list kantor cabang ada disini)
    Work Unit Category
    - 1 : Grup
    - 2 : Kantor Pusat, Cabang, Divisi, Unit kerja
    - 3 : Cabang Pembantu 
    - 4 : Komisaris, Direksi, Staff Ahli, Dewan Pengawas Syariah, dll 
*/
SELECT 
    * 
FROM BJKT_WORK_UNITS 
WHERE 
    PARENT_BRANCH_CODE = 724 AND STATUS_DATA = 1;
/

SELECT 
    par.WORK_UNIT_ID    parent_id,
    par.BRANCH_CODE     parent_code,
    par.WORK_UNIT_NAME  parent_name,
    chl.WORK_UNIT_ID    child_id,
    chl.BRANCH_CODE     child_code,
    chl.WORK_UNIT_NAME  child_name
FROM 
    BJKT_WORK_UNITS par,
    BJKT_WORK_UNITS chl
WHERE
        par.BRANCH_CODE = chl.PARENT_BRANCH_CODE
    and par.WORK_UNIT_ID = 724
    and par.STATUS_DATA = 1;
/

SELECT ID_UNIT_KERJA FROM BJKT_USERS_SSO_INQUIRIES
WHERE USERNAME = 'AK80450625'; -- 724
/
SELECT WORK_UNIT_ID, BRANCH_CODE, WORK_UNIT_NAME
FROM BJKT_WORK_UNITS
WHERE WORK_UNIT_ID = 724; -- BRANCH_CODE = 914
/
SELECT WORK_UNIT_ID, BRANCH_CODE, WORK_UNIT_NAME, PARENT_BRANCH_CODE
FROM BJKT_WORK_UNITS
WHERE PARENT_BRANCH_CODE = 914; -- BRANCH_CODE = 914
/

-- list data model unit kerja
SELECT * FROM BJKT_MODEL_WORK_UNITS;
/

SELECT * FROM BJKT_BRANCHES_MV;
/