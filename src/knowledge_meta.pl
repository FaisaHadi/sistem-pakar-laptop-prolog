:- encoding(utf8).
:- module(metadata_laptop,
          [ sumber/6, aturan_batas/2, gangguan_batas/2,
            panduan_merek/3, cakupan_pengetahuan/1 ]).

% Tanggal akses, bukan tanggal publikasi atau persetujuan pakar.
% Sumber mendukung gejala/interpretasi tes; kombinasi aturan tetap draf.
sumber(b01, 'Dell: masalah adaptor dan pengisian',
       'https://www.dell.com/support/contents/en-us/article/product-support/self-support-knowledgebase/battery-and-power/ac-adapter',
       dell, '2026-10-23',
       'Pengenalan adaptor di BIOS tidak tersedia pada semua model. Kecocokan spesifikasi pembanding harus dipastikan.').
sumber(b02, 'Dell: panas berlebih dan pemeriksaan kipas',
       'https://www.dell.com/support/kbdoc/en-us/000130867/how-to-troubleshoot-a-overheating-shutdown-or-thermal-issue-on-a-dell-pc',
       dell, '2026-10-23',
       'Mendukung konteks panas dan hasil tes kipas; belum menentukan komponen fisik penyebabnya.').
sumber(b03, 'Dell: kode bunyi dan lampu diagnostik',
       'https://www.dell.com/support/kbdoc/en-us/000132041/understanding-beep-codes-on-a-dell-notebook-pc',
       dell, '2026-10-23',
       'Pola kode bergantung pada model. Tidak menjadi tabel kode universal lintas merek.').
sumber(b04, 'Dell: masalah HDD dan SSD',
       'https://www.dell.com/support/kbdoc/en-us/000179526/how-to-resolve-hdd-hard-drive-issues-on-your-dell-system',
       dell, '2026-10-23',
       'Kegagalan boot juga dapat berasal dari konfigurasi atau perangkat lunak. Error tes penyimpanan perlu penanganan tersendiri.').
sumber(b05, 'Dell: kondisi kesehatan baterai',
       'https://www.dell.com/support/contents/en-us/article/product-support/self-support-knowledgebase/battery-and-power/battery',
       dell, '2026-10-23',
       'Arti label kesehatan harus sesuai alat dan model; unknown bukan laporan baterai buruk.').
sumber(b06, 'Dell: diagnostik perangkat keras sebelum boot',
       'https://www.dell.com/support/kbdoc/en-us/000181163/how-to-enter-the-built-in-diagnostics-32-bit-diagnostics-supportassist-epsa-epsa-and-psa',
       dell, '2026-10-23',
       'Panduan umum diagnostik. Error harus menunjuk subsistem yang dimaksud, bukan sekadar tes batal.').
sumber(b07, 'Lenovo Diagnostics Evolution 5.23.2: panduan pengguna',
       'https://download.lenovo.com/pccbbs/thinkvantage_en/ldiag_5.23.2_windows_user_guide.pdf',
       lenovo, '2026-10-23',
       'Panduan versi Windows ini menjelaskan tes memori, penyimpanan dan kipas. Modul yang tersedia bergantung pada perangkat yang didukung.').
sumber(b08, 'HP: pengujian kegagalan perangkat keras',
       'https://support.hp.com/us-en/document/ish_2854458-2733239-16?requestedDocId=ish_3042096-2941213-16&validated=true',
       hp, '2026-10-23',
       'Jenis tes berbeda menurut alat dan perangkat. Gunakan hasil komponen dan failure ID yang sesuai, bukan hasil batal atau belum selesai.').

panduan_merek(dell, 'Dell', 'https://www.dell.com/support/home/').
panduan_merek(lenovo, 'Lenovo', 'https://pcsupport.lenovo.com/').
panduan_merek(hp, 'HP', 'https://support.hp.com/').
panduan_merek(asus, 'ASUS', 'https://www.asus.com/support/').
panduan_merek(acer, 'Acer', 'https://www.acer.com/support/').
panduan_merek(lainnya, 'Merek lainnya', '').
panduan_merek(tidak_diketahui, 'Belum diketahui', '').

cakupan_pengetahuan('Konsultasi lintas merek bersyarat: jawab dari pengamatan dan hasil pemeriksaan resmi untuk model yang sama. Tombol BIOS, pengenalan adaptor, kode lampu, serta jenis tes tidak dianggap sama pada semua laptop. Rujukan khusus yang tersedia berasal dari Dell, Lenovo, dan HP; merek/model lain masih memerlukan sumber tambahan. Semua aturan masih draf, belum divalidasi teknisi.').

gangguan_batas(d01, 'Belum membedakan kerusakan charger, kabel, ketidakcocokan daya, atau komunikasi identifikasi. Tidak memastikan komponen yang harus diganti.').
gangguan_batas(d02, 'Tidak memastikan jenis kerusakan atau keputusan penggantian baterai. Label kesehatan harus ditafsirkan sesuai model.').
gangguan_batas(d03, 'Tidak menentukan apakah penyebabnya kipas, saluran udara, sensor, atau bagian pendingin lain.').
gangguan_batas(d04, 'Tidak membedakan modul RAM, slot, atau rangkaian terkait. Tidak otomatis berarti modul harus diganti.').
gangguan_batas(d05, 'Tidak membedakan media, sambungan, pengendali, dan konfigurasi. Tidak menyatakan data hilang atau media harus diformat.').

aturan_batas(r01, 'Merangkum dua pengamatan; belum menyimpulkan kerusakan charger. Informasi pengenalan adaptor di BIOS harus tersedia pada model tersebut.').
aturan_batas(r02, 'Pembanding harus berfungsi dan kompatibel pada laptop serta port yang sama. Rujukan awal khusus Dell; penerapan model lain perlu dicocokkan.').
aturan_batas(r03, 'Pengamatan mati saat beralih daya dan laporan baterai harus merujuk kejadian/perangkat yang sama.').
aturan_batas(r04, 'Waktu pakai dibandingkan pada beban dan pengaturan sebanding. Tidak memakai batas menit universal.').
aturan_batas(r05, 'Peringatan termal dan shutdown membentuk pola, belum menetapkan hubungan sebab yang pasti.').
aturan_batas(r06, 'Pola termal mendukung dugaan awal, tanpa menentukan bagian pendingin yang rusak.').
aturan_batas(r07, 'Peringatan termal dan error pemeriksaan harus benar-benar berkaitan dengan pendinginan.').
aturan_batas(r08, 'Kode bunyi/lampu wajib cocok dengan manual resmi model yang tepat. Layar hitam saja bukan bukti POST gagal atau RAM rusak.').
aturan_batas(r09, 'Tes resmi harus selesai dan secara spesifik melaporkan kesalahan memori. Tes tidak tersedia atau batal berarti tidak_tahu.').
aturan_batas(r10, 'Perangkat tidak terlihat di daftar penyimpanan BIOS, bukan hanya di urutan boot. Penyebab dapat berupa konfigurasi atau sambungan.').
aturan_batas(r11, 'Gabungan keluhan boot dan error tes penyimpanan. Hasil tes sendiri juga diperiksa melalui R14.').
aturan_batas(r12, 'Bukti langsung berupa laporan resmi kesehatan baterai buruk/perlu diganti. Belum memutuskan penggantian tanpa penilaian teknisi.').
aturan_batas(r13, 'Bukti langsung berupa hasil tes resmi yang spesifik pada kipas/pendinginan; kipas diam saat beban ringan tidak cukup.').
aturan_batas(r14, 'Bukti langsung berupa hasil tes resmi kesalahan penyimpanan; keluhan lambat atau gagal boot saja tidak cukup.').
