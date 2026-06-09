WITH spine AS (
    -- Kumpulkan semua kombinasi kode_cabang + periode dari SEMUA MV
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_AVG_BAL_CREDIT_MV
    UNION
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_AVG_BAL_DPK_MV
    UNION
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_PEN_BUNGA_TOTAL_MV
    UNION
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_BEBAN_BUNGA_TOTAL_MV
    UNION
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_FTP_INCOME_MV
    UNION
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_FTP_CHARGE_MV
    UNION
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_FEE_BASED_INCOME_MV
    UNION
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_NII_POST_FTP_MV
    UNION
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_DIRECT_OPEX_MV
    UNION
    SELECT "kode_cabang", "periode" FROM BJKT_PNL_BEBAN_CKPN_MV
),

-- Ambil metadata cabang dari MV manapun yang memiliki data
cabang_meta AS (
    SELECT DISTINCT "kode_cabang"
    FROM BJKT_PNL_AVG_BAL_CREDIT_MV
    UNION
    SELECT DISTINCT "kode_cabang"
    FROM BJKT_PNL_AVG_BAL_DPK_MV
    -- Tambahkan MV lain jika metadata cabang bisa berbeda-beda
)

SELECT
    s."periode",
    s."kode_cabang",
    -- Ambil metadata dari MV manapun yang tersedia (COALESCE)
    COALESCE(cre."nama_cabang",  dpk."nama_cabang",  pbt."nama_cabang",
             bbt."nama_cabang",  fi."nama_cabang",   fc."nama_cabang")                          AS "nama_cabang",
    COALESCE(cre."kode_konsol",  dpk."kode_konsol",  pbt."kode_konsol",
             bbt."kode_konsol",  fi."kode_konsol",   fc."kode_konsol")                          AS "kode_konsol",
    COALESCE(cre."nama_konsol",  dpk."nama_konsol",  pbt."nama_konsol",
             bbt."nama_konsol",  fi."nama_konsol",   fc."nama_konsol")                          AS "nama_konsol",

    -- ── Avg. Balance Credit ───────────────────────────────────────────
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

    -- ── Avg. Balance DPK ──────────────────────────────────────────────
    dpk."total_dpk",
    dpk."dpk_total_konven",
    dpk."dpk_konven_giro",
    dpk."dpk_konven_tabungan",
    dpk."dpk_konven_deposito",
    dpk."dpk_total_syariah",
    dpk."dpk_syariah_giro",
    dpk."dpk_syariah_tabungan",
    dpk."dpk_syariah_deposito",

    -- ── Pend. Bunga ───────────────────────────────────────────────────
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

    -- ── Beban Bunga Total ─────────────────────────────────────────────
    bbt."total_beban_bunga",
    bbt."beban_bunga_konven",
    bbt."beban_bunga_konven_giro",
    bbt."beban_bunga_konven_tabungan",
    bbt."beban_bunga_konven_deposito",
    bbt."beban_bunga_total_syariah",
    bbt."beban_bunga_syariah_giro",
    bbt."beban_bunga_syariah_tabungan",
    bbt."beban_bunga_syariah_deposito",

    -- ── FTP Income ────────────────────────────────────────────────────
    fi."ftp_income_dpk",

    -- ── FTP Charge Loan ───────────────────────────────────────────────
    fc."ftp_charge_loan",

    -- ── Fee Based Income ──────────────────────────────────────────────
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

    -- ── NII-Post FTP ──────────────────────────────────────────────────
    nii."nii_post_ftp",

    -- ── Direct OPEX ───────────────────────────────────────────────────
    opx."dir_opex_total",
    opx."dir_opex_manpower",
    opx."dir_opex_telecom",
    opx."dir_opex_ofc_sup",
    opx."dir_opex_sewa",
    opx."dir_opex_per_din",
    opx."dir_opex_prem_ins_ncr",
    opx."dir_opex_prem_as_cr",
    opx."dir_opex_tran_cr",
    opx."dir_opex_tran_ncr",

    -- ── Beban CKPN ────────────────────────────────────────────────────
    ckpn."ckpn_nominal"

FROM spine s

LEFT JOIN BJKT_PNL_AVG_BAL_CREDIT_MV     cre  ON cre."kode_cabang"  = s."kode_cabang"  AND cre."periode"  = s."periode"
LEFT JOIN BJKT_PNL_AVG_BAL_DPK_MV        dpk  ON dpk."kode_cabang"  = s."kode_cabang"  AND dpk."periode"  = s."periode"
LEFT JOIN BJKT_PNL_PEN_BUNGA_TOTAL_MV    pbt  ON pbt."kode_cabang"  = s."kode_cabang"  AND pbt."periode"  = s."periode"
LEFT JOIN BJKT_PNL_BEBAN_BUNGA_TOTAL_MV  bbt  ON bbt."kode_cabang"  = s."kode_cabang"  AND bbt."periode"  = s."periode"
LEFT JOIN BJKT_PNL_FTP_INCOME_MV         fi   ON fi."kode_cabang"   = s."kode_cabang"  AND fi."periode"   = s."periode"
LEFT JOIN BJKT_PNL_FTP_CHARGE_MV         fc   ON fc."kode_cabang"   = s."kode_cabang"  AND fc."periode"   = s."periode"
LEFT JOIN BJKT_PNL_FEE_BASED_INCOME_MV   fbi  ON fbi."kode_cabang"  = s."kode_cabang"  AND fbi."periode"  = s."periode"
LEFT JOIN BJKT_PNL_NII_POST_FTP_MV       nii  ON nii."kode_cabang"  = s."kode_cabang"  AND nii."periode"  = s."periode"
LEFT JOIN BJKT_PNL_DIRECT_OPEX_MV        opx  ON opx."kode_cabang"  = s."kode_cabang"  AND opx."periode"  = s."periode"
LEFT JOIN BJKT_PNL_BEBAN_CKPN_MV         ckpn ON ckpn."kode_cabang" = s."kode_cabang"  AND ckpn."periode" = s."periode"

-- ── Filter Range Periode ──────────────────────────────────────────────
WHERE
        s."kode_cabang" = '108'
    AND s."periode" BETWEEN TO_DATE('2026-01-01', 'YYYY-MM-DD')
                        AND TO_DATE('2026-06-01', 'YYYY-MM-DD')

ORDER BY s."periode", s."kode_cabang"
;