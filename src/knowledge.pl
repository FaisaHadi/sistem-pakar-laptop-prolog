:- encoding(utf8).
:- module(pengetahuan_laptop,
          [ gejala/4, gangguan/2, indikasi/2, aturan/3,
            aturan_info/3, saran/3, status_pengetahuan/1 ]).
:- reexport(knowledge_meta).

/* Pengetahuan DRAF; dokumentasi penjelas berada di knowledge/.
   Belum divalidasi teknisi.
   Atom huruf kecil memetakan ID dokumen tanpa mengubah identitasnya.
   aturan(ID, Kesimpulan, PremisAND) dibuktikan secara backward chaining.
*/
status_pengetahuan(draf).

gejala(g01, 'Baterai tidak terisi dengan charger semula',
       'Apakah baterai laptop Anda tidak terisi saat memakai charger semula?',
       'Jawab ya hanya jika baterai belum mencapai batas pengisian yang diatur. Batas ini dapat menghentikan pengisian sebelum penuh. Jika Anda belum tahu batasnya atau belum yakin baterai sedang mengisi, pilih tidak_tahu.').
gejala(g02, 'Charger semula tidak dikenali BIOS/UEFI',
       'Apakah BIOS/UEFI menyatakan charger semula Anda tidak dikenali?',
       'BIOS/UEFI adalah menu pengaturan dasar laptop sebelum sistem operasi berjalan. Termasuk pesan bahwa jenis atau daya charger tidak dapat ditentukan. Gunakan informasi BIOS/UEFI yang sudah Anda lihat, bukan hanya ikon baterai di Windows. Jika model Anda tidak menampilkan informasi ini atau Anda belum mengetahuinya, pilih tidak_tahu.').
gejala(g03, 'Pengisian normal dengan charger pembanding',
       'Apakah baterai laptop Anda kembali terisi normal dengan charger pembanding?',
       'Jawab ya hanya berdasarkan pemeriksaan yang sudah dilakukan pada laptop dan lubang pengisian (port) yang sama. Charger pembanding harus sudah dipastikan berfungsi dan sesuai untuk model laptop Anda menurut produsen. Bentuk colokan yang sama saja tidak cukup. Jika Anda belum memiliki hasil seperti itu atau belum yakin, pilih tidak_tahu. Anda tidak perlu mencoba charger lain untuk menjawab.').
gejala(g04, 'Laptop mati saat charger dilepas',
       'Apakah laptop Anda pernah langsung mati saat charger dilepas?',
       'Kondisi ini dihitung jika indikator baterai sebelumnya masih menunjukkan sisa daya. Gunakan kejadian yang sudah Anda alami. Jangan mencoba melepas charger saat pekerjaan belum disimpan. Jika kondisi baterai saat itu belum Anda ketahui, pilih tidak_tahu.').
gejala(g05, 'Kondisi baterai dinyatakan buruk',
       'Apakah pemeriksaan resmi menyatakan kondisi baterai Anda buruk atau perlu diganti?',
       'Gunakan laporan dari BIOS atau alat resmi produsen untuk model laptop Anda. BIOS adalah menu pengaturan dasar sebelum sistem operasi berjalan. Jawab ya jika laporan secara tegas menyatakan kondisi baterai buruk atau perlu diganti. Label unknown, hasil tidak terbaca, atau permintaan kalibrasi saja tidak cukup. Jika Anda belum memiliki laporan atau belum yakin artinya, pilih tidak_tahu.').
gejala(g06, 'Waktu pemakaian baterai menurun',
       'Apakah waktu pemakaian baterai laptop Anda jauh lebih singkat dari biasanya?',
       'Bandingkan pengamatan yang sudah Anda miliki saat kegiatan ringan dan pengaturan laptop sebanding. Tidak ada batas menit yang berlaku untuk semua laptop. Jika Anda belum dapat membandingkannya atau belum yakin, pilih tidak_tahu.').
gejala(g07, 'Peringatan panas berlebih',
       'Apakah laptop Anda menampilkan peringatan panas berlebih pada kejadian ini?',
       'Gunakan peringatan dari BIOS atau alat resmi produsen. BIOS adalah menu pengaturan dasar sebelum sistem operasi berjalan. Pesan dapat memakai kata thermal, yang berkaitan dengan panas. Casing terasa hangat saja tidak cukup. Jika Anda belum dapat menilai kondisi ini atau belum yakin asal pesannya, pilih tidak_tahu.').
gejala(g08, 'Mati atau menyala ulang saat bekerja lebih berat',
       'Apakah laptop Anda pernah mati atau menyala ulang secara mendadak saat bekerja lebih berat?',
       'Misalnya saat menjalankan aplikasi yang lebih menuntut dibanding pemakaian biasa. Gunakan kejadian yang sudah Anda alami; Anda tidak perlu menjalankan uji beban. Jika Anda belum dapat menilainya, pilih tidak_tahu. Kejadian ini dapat memiliki penyebab lain.').
gejala(g09, 'Pemeriksaan kipas atau pendinginan bermasalah',
       'Apakah pemeriksaan resmi melaporkan masalah kipas atau pendinginan laptop Anda?',
       'Gunakan hasil tes resmi produsen untuk model Anda yang secara spesifik menyatakan kipas atau pendinginan gagal/bermasalah. Kipas diam saat kegiatan ringan saja tidak cukup. Status warning yang belum konklusif, tes tidak tersedia, batal, atau belum selesai berarti tidak_tahu. Jika arti hasilnya belum Anda pahami, pilih tidak_tahu.').
gejala(g10, 'Pemeriksaan awal saat menyala gagal selesai',
       'Apakah pemeriksaan awal laptop Anda gagal selesai saat dinyalakan?',
       'Pemeriksaan awal ini disebut POST: pemeriksaan perangkat sebelum sistem operasi mulai berjalan. Jawab ya hanya jika kegagalannya sesuai pesan atau panduan resmi produsen. Layar hitam atau Windows tidak bisa masuk saja belum cukup. Jika Anda belum dapat membedakannya, pilih tidak_tahu.').
gejala(g11, 'Kode bunyi atau lampu menunjukkan masalah RAM',
       'Apakah bunyi atau kedipan lampu laptop Anda sesuai dengan kode masalah RAM di panduan resminya?',
       'RAM adalah memori kerja sementara laptop. Kode dapat berupa pola bunyi beep atau kedipan lampu LED saat laptop dinyalakan. Jawab ya hanya jika pola yang sudah Anda catat cocok dengan panduan resmi untuk model laptop Anda. Bunyi saja tanpa kecocokan panduan belum cukup. Jika panduan atau kecocokannya belum diketahui, pilih tidak_tahu.').
gejala(g12, 'Pemeriksaan resmi melaporkan kesalahan RAM',
       'Apakah pemeriksaan resmi melaporkan kesalahan RAM laptop Anda?',
       'RAM adalah memori kerja sementara laptop. Gunakan hasil tes resmi untuk model Anda yang secara spesifik menyatakan kesalahan memori. Laptop lambat saja tidak cukup. Status warning yang belum konklusif, tes tidak tersedia, batal, atau belum selesai berarti tidak_tahu. Jika Anda belum yakin arti hasilnya, pilih tidak_tahu.').
gejala(g13, 'Penyimpanan internal tidak terlihat di BIOS/UEFI',
       'Apakah penyimpanan internal laptop Anda tidak terlihat di BIOS/UEFI?',
       'Penyimpanan internal (SSD/HDD) adalah tempat menyimpan sistem dan berkas. BIOS/UEFI adalah menu pengaturan dasar sebelum sistem operasi berjalan. Yang dimaksud ialah SSD/HDD yang biasanya terpasang tidak muncul di daftar perangkat penyimpanan, bukan sekadar daftar urutan mulai sistem. Gunakan informasi yang sudah Anda ketahui; jika Anda belum melihat menu yang tepat, pilih tidak_tahu.').
gejala(g14, 'Pesan perangkat untuk memulai sistem tidak ditemukan',
       'Apakah laptop Anda menampilkan pesan bahwa perangkat untuk memulai sistem tidak ditemukan?',
       'Contohnya No Boot Device Found, yaitu perangkat untuk memulai sistem tidak ditemukan. Tidak semua kegagalan masuk Windows termasuk kondisi ini. Jika Anda belum mengetahui pesannya atau belum yakin, pilih tidak_tahu. Pesan ini saja belum membuktikan penyimpanan rusak.').
gejala(g15, 'Pemeriksaan resmi melaporkan kesalahan penyimpanan',
       'Apakah pemeriksaan resmi melaporkan kesalahan penyimpanan internal laptop Anda?',
       'Penyimpanan internal (SSD/HDD) adalah tempat menyimpan sistem dan berkas. Gunakan hasil tes resmi untuk model Anda yang secara spesifik melaporkan kesalahan SSD/HDD. Keluhan lambat atau gagal masuk Windows saja tidak cukup. Status warning yang belum konklusif, tes tidak tersedia, batal, atau belum selesai berarti tidak_tahu. Jika Anda belum yakin arti hasilnya, pilih tidak_tahu.').

gangguan(d01, 'Gangguan charger atau kabel dayanya').
gangguan(d02, 'Kondisi baterai menurun atau bermasalah').
gangguan(d03, 'Masalah pendinginan atau panas berlebih').
gangguan(d04, 'Masalah pada sistem memori kerja (RAM)').
gangguan(d05, 'Masalah pengenalan atau kondisi penyimpanan (SSD/HDD)').

indikasi(i01, 'Pola baterai tidak terisi dan charger semula tidak dikenali.').
indikasi(i02, 'Pola peringatan panas berlebih dan mati atau menyala ulang mendadak saat bekerja lebih berat.').

aturan(r01, i01, [g01, g02]).
aturan(r02, d01, [i01, g03]).
aturan(r03, d02, [g04, g05]).
aturan(r04, d02, [g05, g06]).
aturan(r05, i02, [g07, g08]).
aturan(r06, d03, [i02]).
aturan(r07, d03, [g07, g09]).
aturan(r08, d04, [g10, g11]).
aturan(r09, d04, [g12]).
aturan(r10, d05, [g13, g14]).
aturan(r11, d05, [g14, g15]).
% Hasil pemeriksaan resmi yang spesifik merupakan bukti langsung.
% Jalur gabungan lama dipertahankan untuk menjelaskan konteks pengamatan;
% beberapa jalur yang sesuai tidak dihitung sebagai peningkatan kepastian.
aturan(r12, d02, [g05]).
aturan(r13, d03, [g09]).
aturan(r14, d05, [g15]).

aturan_info(r01, [b01], draf).
aturan_info(r02, [b01], draf).
aturan_info(r03, [b05], draf).
aturan_info(r04, [b05], draf).
aturan_info(r05, [b02], draf).
aturan_info(r06, [b02], draf).
aturan_info(r07, [b02], draf).
aturan_info(r08, [b03], draf).
aturan_info(r09, [b06, b07, b08], draf).
aturan_info(r10, [b04], draf).
aturan_info(r11, [b04, b06, b07, b08], draf).
aturan_info(r12, [b05, b08], draf).
aturan_info(r13, [b02, b07, b08], draf).
aturan_info(r14, [b04, b07, b08], draf).

saran(d01, s01,
      'Anda dapat mencocokkan spesifikasi charger dengan panduan resmi model laptop Anda. Mintalah teknisi memeriksa charger atau kabel semula sebelum Anda menggantinya.').
saran(d02, s02,
      'Simpan laporan kondisi baterai yang sudah Anda miliki. Mintalah layanan resmi atau teknisi menilai apakah baterai perlu diganti dengan yang sesuai model laptop Anda.').
saran(d03, s03,
      'Hentikan kegiatan berat pada laptop Anda dan biarkan laptop mendingin. Gunakan permukaan keras dengan lubang udara yang tidak tertutup. Jika keluhan berulang, mintalah teknisi menilai sistem pendinginannya.').
saran(d04, s04,
      'Simpan pola bunyi atau kedipan lampu, atau hasil pemeriksaan RAM yang sudah Anda miliki. Mintalah teknisi mencocokkannya dengan panduan resmi model laptop Anda dan memeriksa sistem memorinya.').
saran(d05, s05,
      'Jika laptop Anda masih aman digunakan, cadangkan berkas penting Anda. Simpan informasi penyimpanan dari BIOS/UEFI atau hasil pemeriksaan yang sudah tersedia. Mintalah teknisi memeriksa penyimpanan dan sambungannya. Hindari format atau pemasangan ulang sistem sebelum masalah dan kebutuhan data Anda dinilai.').
