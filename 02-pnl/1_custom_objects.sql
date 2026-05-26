CREATE OR REPLACE SYNONYM BJKT_PNL_ECHANNEL_SY
FOR "dwh"."pnl_echannel"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_DPK_AVG_SY
FOR "dwh"."pnl_dpk_avg"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_LOAN_AVG_SY
FOR "dwh"."pnl_loan_avg"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_GL_SY
FOR "dwh"."pnl_gl"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_GL_V2_SY
FOR "dwh"."pnl_gl_v2"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_DIM_BRANCH_V2_SY
FOR "dwh"."dim_branch_v2"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_CKPN_SY
FOR "dwh"."pnl_ckpn"@DWH_DEV;
/

CREATE OR REPLACE SYNONYM BJKT_PNL_PENDAPATAN_BUNGA_SY
FOR "dwh"."pnl_pendapatan_bunga"@DWH_DEV
/

CREATE OR REPLACE SYNONYM BJKT_PNL_INCOME_DPK_SY
FOR "dwh"."pnl_income_dpk"@DWH_DEV
/

CREATE OR REPLACE SYNONYM BJKT_PNL_CHARGE_LOAN_SY
FOR "dwh"."pnl_charge_loan"@DWH_DEV
/

CREATE OR REPLACE SYNONYM BJKT_PNL_FBI_SY
FOR "dwh"."pnl_fbi"@DWH_DEV
/

-- DROP MATERIALIZED VIEW BJKT_BRANCHES_MV;
-- /
-- Materialized View list data cabang dan cabang konsolidasi
CREATE MATERIALIZED VIEW BJKT_BRANCHES_MV
BUILD IMMEDIATE
REFRESH COMPLETE
START WITH TRUNC(SYSDATE + 1) + 2/24
NEXT TRUNC(SYSDATE + 1) + 2/24
AS
SELECT
    "kode_cabang_awal",
    "nama_kantor_awal",
    "kode_cabang_akhir",
    "nama_kantor_akhir",
    "kode_konsol",
    "nama_konsol",
    "kode_cabang_dblm_v2"   "kode_cabang_syariah",
    "nama_cabang_dblm_v2"   "nama_cabang_syariah",
    "status_branch",
    "segmen_branch",
    "keterangan"
FROM DIM_BRANCH_V2_SY;
/
CREATE INDEX BJKT_BRANCHES_MV_I1 ON BJKT_BRANCHES_MV("kode_cabang_awal", "keterangan");
/
CREATE INDEX BJKT_BRANCHES_MV_I2 ON BJKT_BRANCHES_MV("kode_cabang_akhir", "keterangan");
/
CREATE INDEX BJKT_BRANCHES_MV_I3 ON BJKT_BRANCHES_MV("kode_konsol", "keterangan");
/
CREATE INDEX BJKT_BRANCHES_MV_I4 ON BJKT_BRANCHES_MV("kode_cabang_syariah", "keterangan");
/
