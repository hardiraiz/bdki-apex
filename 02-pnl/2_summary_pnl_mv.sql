SELECT
    TO_CHAR(cre."periode", 'YYYY-MM-DD') AS "periode",
    cre."kode_cabang",
    cre."nama_cabang",
    cre."kode_konsol",
    cre."nama_konsol",
    
    -- Avg. Balance Credit
    cre."total_kredit",
    cre."kredit_total_konven",
    cre."kredit_konven_kmg",
    cre."kredit_konven_kpr",
    cre."kredit_konven_mikro",
    cre."kredit_konven_ukm",
    cre."kredit_total_syariah",
    cre."kredit_syariah_kmg",
    cre."kredit_syariah_kpr",
    cre."kredit_syariah_mikro",
    cre."kredit_syariah_ukm",

    -- Avg. Balance DPK
    dpk."total_dpk",
    dpk."dpk_total_konven",
    dpk."dpk_konven_giro",
    dpk."dpk_konven_tabungan",
    dpk."dpk_konven_deposito",
    dpk."dpk_total_syariah",
    dpk."dpk_syariah_giro",
    dpk."dpk_syariah_tabungan",
    dpk."dpk_syariah_deposito",

    -- Pend. Bunga
    pbt."total_pen_bunga",
    pbt."total_bunga_konven",
    pbt."bunga_konven_kmg",
    pbt."bunga_konven_kpr",
    pbt."bunga_konven_mikro",
    pbt."bunga_konven_ukm",
    pbt."total_bunga_syariah",
    pbt."bunga_syariah_kmg",
    pbt."bunga_syariah_kpr",
    pbt."bunga_syariah_mikro",
    pbt."bunga_syariah_ukm",

    -- Beban Bunga Total
    bbt."total_beban_bunga",
    bbt."beban_bunga_konven",
    bbt."beban_bunga_konven_giro",
    bbt."beban_bunga_konven_tabungan",
    bbt."beban_bunga_konven_deposito",
    bbt."beban_bunga_total_syariah",
    bbt."beban_bunga_syariah_giro",
    bbt."beban_bunga_syariah_tabungan",
    bbt."beban_bunga_syariah_deposito",

    -- FTP Income
    fi."ftp_income_dpk",

    -- FTP Charge Loan
    fc."ftp_charge_loan",

    -- Fee Based Income
    fbi."fbi_total",
    fbi."fbi_acc_maint",
    fbi."fbi_atm",
    fbi."fbi_jom",
    fbi."fbi_edc",
    fbi."fbi_cms",
    fbi."fbi_abank",
    fbi."fbi_jas_pot",
    fbi."fbi_bisnis_kartu",
    fbi."fbi_bisnis_sdb",
    fbi."fbi_kirim_uang",
    fbi."fbi_rest_biaya_kantor",
    fbi."fbi_pin_nas_pen",
    fbi."fbi_bank_garansi",
    fbi."fbi_admin_kredit",
    fbi."fbi_lainnya",

    -- NII-Post FTP
    nii."nii_post_ftp",

    -- Direct OPEX
    do."dir_opex_manpower",
    do."dir_opex_telecom",
    do."dir_opex_ofc_sup",
    do."dir_opex_per_din",
    do."dir_opex_prem_ins_ncr",
    do."dir_opex_prem_as_cr",
    do."dir_opex_tran_cr",
    do."dir_opex_tran_ncr",

    -- Beban CKPN
    ckpn."ckpn_nominal"

FROM BJKT_PNL_AVG_BAL_CREDIT_MV cre
LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV dpk
    ON  cre."kode_cabang"       = dpk."kode_cabang"
    AND TRUNC(cre."periode")    = TRUNC(dpk."periode")
LEFT JOIN BJKT_PNL_PEN_BUNGA_TOTAL_MV pbt
    ON  cre."kode_cabang"       = pbt."kode_cabang"
    AND TRUNC(cre."periode")    = TRUNC(pbt."periode")
LEFT JOIN BJKT_PNL_BEBAN_BUNGA_TOTAL_MV bbt
    ON  cre."kode_cabang"       = bbt."kode_cabang"
    AND TRUNC(cre."periode")    = TRUNC(bbt."periode")
LEFT JOIN BJKT_PNL_FTP_INCOME_MV fi
    ON  cre."kode_cabang"       = fi."kode_cabang"
    AND TRUNC(cre."periode")    = TRUNC(fi."periode")
LEFT JOIN BJKT_PNL_FTP_CHARGE_MV fc
    ON  cre."kode_cabang"       = fc."kode_cabang"
    AND TRUNC(cre."periode")    = TRUNC(fc."periode")
LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV fbi
    ON  cre."kode_cabang"       = fbi."kode_cabang"
    AND TRUNC(cre."periode")    = TRUNC(fbi."periode")
LEFT JOIN BJKT_PNL_NII_POST_FTP_MV nii
    ON  cre."kode_cabang"       = nii."kode_cabang"
    AND TRUNC(cre."periode")    = TRUNC(nii."periode")
LEFT JOIN BJKT_PNL_DIRECT_OPEX_MV do
    ON  cre."kode_cabang"       = do."kode_cabang"
    AND TRUNC(cre."periode")    = TRUNC(do."periode")
LEFT JOIN BJKT_PNL_BEBAN_CKPN_MV ckpn
    ON  cre."kode_cabang"       = ckpn."kode_cabang"
    AND TRUNC(cre."periode")    = TRUNC(ckpn."periode")
WHERE
    cre."kode_cabang" = '108';
/

