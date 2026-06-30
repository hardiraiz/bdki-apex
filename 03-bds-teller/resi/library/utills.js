function angkaTerbilang(angka) {
    angka = Math.floor(angka);
    var bilangan = ["", "SATU", "DUA", "TIGA", "EMPAT", "LIMA", "ENAM", "TUJUH", "DELAPAN", "SEMBILAN", "SEPULUH", "SEBELAS"];
    
    if (angka < 12) {
        return bilangan[angka];
    } else if (angka < 20) {
        return terbilang(angka - 10) + " BELAS";
    } else if (angka < 100) {
        return terbilang(Math.floor(angka / 10)) + " PULUH" + terbilang(angka % 10);
    } else if (angka < 200) {
        return "SERATUS " + terbilang(angka - 100);
    } else if (angka < 1000) {
        return terbilang(Math.floor(angka / 100)) + " RATUS" + terbilang(angka % 100);
    } else if (angka < 2000) {
        return "SERIBU " + terbilang(angka - 1000);
    } else if (angka < 1000000) {
        return terbilang(Math.floor(angka / 1000)) + " RIBU" + terbilang(angka % 1000);
    } else if (angka < 1000000000) {
        return terbilang(Math.floor(angka / 1000000)) + " JUTA" + terbilang(angka % 1000000);
    } else if (angka < 1000000000000) {
        return terbilang(Math.floor(angka / 1000000000)) + " MILYAR" + terbilang(angka % 1000000000);
    } else if (angka < 1000000000000000) {
        return terbilang(Math.floor(angka / 1000000000000)) + " TRILIUN" + terbilang(angka % 1000000000000);
    }
    return "";
}