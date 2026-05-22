CREATE OR REPLACE SYNONYM PNL_ECHANNEL_SY
FOR "dwh"."pnl_echannel"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM PNL_DPK_AVG_SY
FOR "dwh"."pnl_dpk_avg"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM PNL_LOAN_AVG_SY
FOR "dwh"."pnl_loan_avg"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM PNL_GL_SY
FOR "dwh"."pnl_gl"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM PNL_GL_V2_SY
FOR "dwh"."pnl_gl_v2"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM DIM_BRANCH_V2_SY
FOR "dwh"."dim_branch_v2"@DWH_DEV;
/

-- Materialized View list data cabang dan cabang konsolidasi
CREATE MATERIALIZED VIEW BJKT_BRANCHES_MV
BUILD IMMEDIATE
REFRESH COMPLETE
START WITH TRUNC(SYSDATE + 1) + 2/24
NEXT TRUNC(SYSDATE + 1) + 2/24
AS
SELECT
    "kode_cabang_awal"      "kode_cabang",
    "nama_kantor_akhir"     "kode_awal",
    "kode_konsol",
    "nama_konsol",
    "kode_cabang_dblm_v2"   "kode_cabang_dblm",
    "nama_cabang_dblm_v2"   "nama_cabang_dblm",
    "status_branch",
    "segmen_branch",
    "keterangan"
FROM DIM_BRANCH_V2_SY;
/
CREATE INDEX BJKT_BRANCHES_MV_I1 ON BJKT_BRANCHES_MV("kode_cabang");
/
CREATE INDEX BJKT_BRANCHES_MV_I2 ON BJKT_BRANCHES_MV("kode_konsol");
/
CREATE INDEX BJKT_BRANCHES_MV_I3 ON BJKT_BRANCHES_MV("kode_cabang_dblm");
/