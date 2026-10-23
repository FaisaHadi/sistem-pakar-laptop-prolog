# Daftar gejala dan pertanyaan konsultasi

Usulan **15 gejala**, G01-G15. Setiap gejala adalah pengamatan atau hasil pemeriksaan yang Anda laporkan untuk satu kejadian gangguan laptop.

Status semua definisi: **DRAF / PERLU_VALIDASI_TEKNISI**. Makna gejala dan ID tetap. Kode sumber B01–B08 mengacu ke [referensi](../docs/referensi.md); sumber awal belum memvalidasi seluruh pertanyaan atau kombinasi diagnosis. **PERLU_SUMBER_MODEL** berarti panduan resmi model laptop sasaran belum tersedia.

## Petunjuk jawaban untuk Anda

- `ya`: kondisi sesuai dengan pengamatan atau hasil pemeriksaan yang Anda miliki.
- `tidak`: Anda sudah dapat menilai kondisi tersebut dan hasilnya tidak sesuai.
- `tidak_tahu`: Anda belum melakukan pemeriksaan, belum memahami hasilnya, fiturnya tidak tersedia, atau belum yakin.

Anda tidak perlu melakukan pemeriksaan baru atau menebak jawaban. Gunakan satu kejadian gangguan sebagai konteks sesi. **Charger semula** adalah charger yang Anda pakai saat keluhan muncul. G01-G02 merujuk charger semula; G03 merujuk charger pembanding pada laptop dan lubang pengisian (port) yang sama.

## Pertanyaan dan bantuan yang tampil di aplikasi

Pertanyaan menyampaikan satu kondisi utama. Bantuan di bawahnya tetap ditampilkan dan menjadi bagian syarat jawaban; bantuan tidak boleh dihilangkan ketika pertanyaan digunakan. Kolom bantuan menjadi argumen keempat `gejala/4` di aplikasi.

| ID | Label | Pertanyaan | Bantuan pengguna |
| --- | --- | --- | --- |
| G01 | Baterai tidak terisi dengan charger semula | Apakah baterai laptop Anda tidak terisi saat memakai charger semula? | Jawab ya hanya jika baterai belum mencapai batas pengisian yang diatur. Batas ini dapat menghentikan pengisian sebelum penuh. Jika Anda belum tahu batasnya atau belum yakin baterai sedang mengisi, pilih tidak_tahu. |
| G02 | Charger semula tidak dikenali BIOS/UEFI | Apakah BIOS/UEFI menyatakan charger semula Anda tidak dikenali? | BIOS/UEFI adalah menu pengaturan dasar laptop sebelum sistem operasi berjalan. Termasuk pesan bahwa jenis atau daya charger tidak dapat ditentukan. Gunakan informasi BIOS/UEFI yang sudah Anda lihat, bukan hanya ikon baterai di Windows. Jika model Anda tidak menampilkan informasi ini atau Anda belum mengetahuinya, pilih tidak_tahu. |
| G03 | Pengisian normal dengan charger pembanding | Apakah baterai laptop Anda kembali terisi normal dengan charger pembanding? | Jawab ya hanya berdasarkan pemeriksaan yang sudah dilakukan pada laptop dan lubang pengisian (port) yang sama. Charger pembanding harus sudah dipastikan berfungsi dan sesuai untuk model laptop Anda menurut produsen. Bentuk colokan yang sama saja tidak cukup. Jika Anda belum memiliki hasil seperti itu atau belum yakin, pilih tidak_tahu. Anda tidak perlu mencoba charger lain untuk menjawab. |
| G04 | Laptop mati saat charger dilepas | Apakah laptop Anda pernah langsung mati saat charger dilepas? | Kondisi ini dihitung jika indikator baterai sebelumnya masih menunjukkan sisa daya. Gunakan kejadian yang sudah Anda alami. Jangan mencoba melepas charger saat pekerjaan belum disimpan. Jika kondisi baterai saat itu belum Anda ketahui, pilih tidak_tahu. |
| G05 | Kondisi baterai dinyatakan buruk | Apakah pemeriksaan resmi menyatakan kondisi baterai Anda buruk atau perlu diganti? | Gunakan laporan dari BIOS atau alat resmi produsen untuk model laptop Anda. BIOS adalah menu pengaturan dasar sebelum sistem operasi berjalan. Jawab ya jika laporan secara tegas menyatakan kondisi baterai buruk atau perlu diganti. Label unknown, hasil tidak terbaca, atau permintaan kalibrasi saja tidak cukup. Jika Anda belum memiliki laporan atau belum yakin artinya, pilih tidak_tahu. |
| G06 | Waktu pemakaian baterai menurun | Apakah waktu pemakaian baterai laptop Anda jauh lebih singkat dari biasanya? | Bandingkan pengamatan yang sudah Anda miliki saat kegiatan ringan dan pengaturan laptop sebanding. Tidak ada batas menit yang berlaku untuk semua laptop. Jika Anda belum dapat membandingkannya atau belum yakin, pilih tidak_tahu. |
| G07 | Peringatan panas berlebih | Apakah laptop Anda menampilkan peringatan panas berlebih pada kejadian ini? | Gunakan peringatan dari BIOS atau alat resmi produsen. BIOS adalah menu pengaturan dasar sebelum sistem operasi berjalan. Pesan dapat memakai kata thermal, yang berkaitan dengan panas. Casing terasa hangat saja tidak cukup. Jika Anda belum dapat menilai kondisi ini atau belum yakin asal pesannya, pilih tidak_tahu. |
| G08 | Mati atau menyala ulang saat bekerja lebih berat | Apakah laptop Anda pernah mati atau menyala ulang secara mendadak saat bekerja lebih berat? | Misalnya saat menjalankan aplikasi yang lebih menuntut dibanding pemakaian biasa. Gunakan kejadian yang sudah Anda alami; Anda tidak perlu menjalankan uji beban. Jika Anda belum dapat menilainya, pilih tidak_tahu. Kejadian ini dapat memiliki penyebab lain. |
| G09 | Pemeriksaan kipas atau pendinginan bermasalah | Apakah pemeriksaan resmi melaporkan masalah kipas atau pendinginan laptop Anda? | Gunakan hasil tes resmi produsen untuk model Anda yang secara spesifik menyatakan kipas atau pendinginan gagal/bermasalah. Kipas diam saat kegiatan ringan saja tidak cukup. Status warning yang belum konklusif, tes tidak tersedia, batal, atau belum selesai berarti tidak_tahu. Jika arti hasilnya belum Anda pahami, pilih tidak_tahu. |
| G10 | Pemeriksaan awal saat menyala gagal selesai | Apakah pemeriksaan awal laptop Anda gagal selesai saat dinyalakan? | Pemeriksaan awal ini disebut POST: pemeriksaan perangkat sebelum sistem operasi mulai berjalan. Jawab ya hanya jika kegagalannya sesuai pesan atau panduan resmi produsen. Layar hitam atau Windows tidak bisa masuk saja belum cukup. Jika Anda belum dapat membedakannya, pilih tidak_tahu. |
| G11 | Kode bunyi atau lampu menunjukkan masalah RAM | Apakah bunyi atau kedipan lampu laptop Anda sesuai dengan kode masalah RAM di panduan resminya? | RAM adalah memori kerja sementara laptop. Kode dapat berupa pola bunyi beep atau kedipan lampu LED saat laptop dinyalakan. Jawab ya hanya jika pola yang sudah Anda catat cocok dengan panduan resmi untuk model laptop Anda. Bunyi saja tanpa kecocokan panduan belum cukup. Jika panduan atau kecocokannya belum diketahui, pilih tidak_tahu. |
| G12 | Pemeriksaan resmi melaporkan kesalahan RAM | Apakah pemeriksaan resmi melaporkan kesalahan RAM laptop Anda? | RAM adalah memori kerja sementara laptop. Gunakan hasil tes resmi untuk model Anda yang secara spesifik menyatakan kesalahan memori. Laptop lambat saja tidak cukup. Status warning yang belum konklusif, tes tidak tersedia, batal, atau belum selesai berarti tidak_tahu. Jika Anda belum yakin arti hasilnya, pilih tidak_tahu. |
| G13 | Penyimpanan internal tidak terlihat di BIOS/UEFI | Apakah penyimpanan internal laptop Anda tidak terlihat di BIOS/UEFI? | Penyimpanan internal (SSD/HDD) adalah tempat menyimpan sistem dan berkas. BIOS/UEFI adalah menu pengaturan dasar sebelum sistem operasi berjalan. Yang dimaksud ialah SSD/HDD yang biasanya terpasang tidak muncul di daftar perangkat penyimpanan, bukan sekadar daftar urutan mulai sistem. Gunakan informasi yang sudah Anda ketahui; jika Anda belum melihat menu yang tepat, pilih tidak_tahu. |
| G14 | Pesan perangkat untuk memulai sistem tidak ditemukan | Apakah laptop Anda menampilkan pesan bahwa perangkat untuk memulai sistem tidak ditemukan? | Contohnya No Boot Device Found, yaitu perangkat untuk memulai sistem tidak ditemukan. Tidak semua kegagalan masuk Windows termasuk kondisi ini. Jika Anda belum mengetahui pesannya atau belum yakin, pilih tidak_tahu. Pesan ini saja belum membuktikan penyimpanan rusak. |
| G15 | Pemeriksaan resmi melaporkan kesalahan penyimpanan | Apakah pemeriksaan resmi melaporkan kesalahan penyimpanan internal laptop Anda? | Penyimpanan internal (SSD/HDD) adalah tempat menyimpan sistem dan berkas. Gunakan hasil tes resmi untuk model Anda yang secara spesifik melaporkan kesalahan SSD/HDD. Keluhan lambat atau gagal masuk Windows saja tidak cukup. Status warning yang belum konklusif, tes tidak tersedia, batal, atau belum selesai berarti tidak_tahu. Jika Anda belum yakin arti hasilnya, pilih tidak_tahu. |

## Catatan teknis untuk pengembang dan peninjau

Catatan ini tidak ditampilkan saat konsultasi. Definisi operasional, batas model, sumber, dan kebutuhan validasi dipisahkan dari bantuan pengguna.

| ID | Catatan teknis |
| --- | --- |
| G01 | Kegagalan pengisian memakai charger semula pada kondisi di bawah batas pengisian yang diatur. Batas dan kondisi pengisian harus diketahui. B01; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G02 | Bukti harus berasal dari status identifikasi charger semula di BIOS/UEFI. Status unknown atau jenis/daya tidak dapat ditentukan termasuk kondisi ini. Ikon daya sistem operasi saja tidak cukup. B01; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G03 | Pemulihan pengisian pada laptop dan port yang sama dengan charger pembanding yang dipastikan berfungsi serta kompatibel menurut produsen. Perbandingan harus terkontrol; bukan instruksi pengujian baru. B01; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G04 | Kejadian historis mati langsung ketika beralih dari charger ke baterai walaupun indikator sebelumnya menunjukkan sisa daya. B05 mendukung shutdown umum; keterkaitan spesifik dengan perpindahan daya perlu ditinjau. PERLU_VALIDASI_TEKNISI. |
| G05 | Laporan kesehatan baterai dari BIOS atau alat resmi produsen dengan label buruk/perlu penggantian. Simpan label asli dan validasi artinya per model; unknown bukan bukti positif. B05; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G06 | Penurunan waktu pakai relatif terhadap kebiasaan sebelumnya pada beban ringan dan pengaturan sebanding. Pengamatan subjektif tanpa ambang menit universal. B05; PERLU_VALIDASI_TEKNISI. |
| G07 | Peringatan overheat/thermal dari BIOS atau alat resmi produsen pada kejadian yang dikonsultasikan. Kehangatan casing saja tidak cukup; tidak ada ambang suhu universal. B02; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G08 | Shutdown atau restart mendadak pada beban kerja yang lebih berat; gunakan kejadian historis, bukan uji beban baru. Tidak menetapkan hubungan sebab-akibat dengan panas. B02; PERLU_VALIDASI_TEKNISI. |
| G09 | Hasil diagnostik resmi produsen menyatakan kegagalan kipas atau sistem termal. Catat hasil/kode asli tanpa menebak artinya; kipas diam pada beban ringan saja bukan bukti. B02; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G10 | POST tidak selesai menurut pesan atau petunjuk produsen. Bedakan no POST dari no video dan no boot; layar hitam/gagal masuk OS saja tidak memadai. B03; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G11 | Pola beep/LED cocok dengan kode masalah memori pada manual resmi model yang tepat. Perlu catatan pola dan pemetaan model, tanpa kode universal lintas merek. B03; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G12 | Hasil diagnostik memori resmi produsen melaporkan error RAM/memori; bukan keluhan umum atau tes yang belum selesai. Tidak menetapkan modul tertentu rusak. B06 adalah panduan umum; B07 bagian Memory dan B08 bagian Memory Tests melengkapi konteks tes memori. Panduan model tetap diperlukan. PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G13 | SSD/HDD internal yang biasanya terpasang tidak terdeteksi pada inventaris penyimpanan BIOS/UEFI. Daftar urutan boot bukan pengganti daftar perangkat. B04; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |
| G14 | Pesan eksplisit no boot device/media, bukan seluruh kegagalan masuk OS. Tidak cukup sendiri untuk membuktikan kerusakan SSD/HDD. B04; PERLU_VALIDASI_TEKNISI. |
| G15 | Diagnostik resmi produsen melaporkan error SSD/HDD internal. Bedakan hasil gagal dari tes batal/tidak tersedia/tidak selesai. B04, B06, B07, B08; PERLU_SUMBER_MODEL; PERLU_VALIDASI_TEKNISI. |

## Kekurangan yang perlu diselesaikan

Sumber awal Dell telah dilengkapi panduan diagnostik Lenovo dan HP. Pemilihan merek/model dalam web tidak dianggap verifikasi otomatis dukungan model. Bahasa yang lebih sederhana tidak menggantikan panduan model atau validasi teknisi. Tidak ada pola beep, tombol BIOS, label kesehatan baterai, maupun ambang menit/suhu yang dianggap berlaku untuk semua laptop. G04, G06, dan G08 masih memerlukan penajaman melalui peninjauan teknisi; Rujukan tes memori B07/B08 telah ditambahkan; penerapan pada model sasaran masih perlu diperiksa.

Catatan model, pesan asli, dan hasil pemeriksaan dapat dikumpulkan saat validasi kelompok. Catatan tersebut tidak menambah jumlah gejala dan tidak perlu memuat nomor seri pribadi.
