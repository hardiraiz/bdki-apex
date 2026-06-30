create or replace FUNCTION apex_calc_days_between (
    p_date_from IN VARCHAR2,
    p_date_to   IN VARCHAR2
) RETURN VARCHAR2
IS
    v_date_from DATE;
    v_date_to   DATE;
    v_days      NUMBER;
    v_result    VARCHAR2(50);
BEGIN
    -- Jika salah satu input kosong, kembalikan 0 Days
    IF p_date_from IS NULL OR p_date_to IS NULL THEN
        RETURN '0 Days';
    END IF;

    -- Mengubah string ke tipe data DATE
    v_date_from := TO_DATE(p_date_from, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH');
    v_date_to   := TO_DATE(p_date_to, 'DD-MON-YYYY', 'NLS_DATE_LANGUAGE = ENGLISH');

    -- Kalkulasi inklusif: ditambah 1 agar tanggal yang sama dihitung 1 hari
    v_days := (v_date_to - v_date_from) + 1;

    -- Kondisi untuk menentukan akhiran Day atau Days
    -- Karena ada penambahan +1, jika tanggal sama hasilnya 1 (menggunakan 'Day')
    IF v_days = 1 OR v_days = -1 THEN
        v_result := TO_CHAR(v_days) || ' Day';
    ELSE
        v_result := TO_CHAR(v_days) || ' Days';
    END IF;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Invalid Date Format'; 
END apex_calc_days_between;
/