# Referensi dan status validasi

Tanggal pembacaan: **22 Oktober 2026**. Daftar ini hanya memuat sumber yang benar-benar diperiksa. Tidak ada wawancara teknisi, pengukuran akurasi, atau studi kasus perangkat nyata yang telah dilakukan.

## Materi lokal

Lokasi lengkap dan tautan sumber ada pada [indeks materi](materi/README.md).

| ID | Identitas sumber | Pemakaian |
| --- | --- | --- |
| M01 | Aradea. Penalaran: Logic, Rules and Representation I. PPTX perkuliahan, tahun tidak tercantum pada sampul. | Akuisisi dan representasi pengetahuan, logika dan fakta; terutama slide 9–17. |
| M02 | Aradea. Penalaran: Logic, Rules and Representation II. PPTX perkuliahan, tahun tidak tercantum pada sampul. | Arsitektur basis pengetahuan, verifikasi/validasi, aturan dan backward chaining; terutama slide 8–9, 31–40. |
| M03 | Aradea. Penalaran: Logic, Rules and Representation III. PPTX perkuliahan, tahun tidak tercantum pada sampul. | Sistem pakar, sintaks Prolog, query dan inferensi; slide 6–13, 20–34. Ketentuan tugas pada slide 54. |
| M04 | Deskripsi Tugas Besar Kecerdasan Buatan. PDF satu halaman, penulis dan tahun tidak tercantum. | Opsi AI with PROLOG, rincian slide, demo dan video tutorial. |

Materi mendukung metode sistem pakar. Materi tersebut tidak memberikan basis diagnosis laptop. Daftar pustaka di dalam slide tidak dianggap sebagai buku yang sudah dibaca langsung oleh kelompok.

## Sumber domain yang diperiksa

Sumber resmi Dell digunakan sebagai titik awal. Penerapan lintas merek dan kombinasi aturan yang diusulkan masih perlu validasi. Tanggal publikasi tidak diisi karena tidak diverifikasi secara konsisten; tanggal di atas adalah tanggal akses.

| ID | Sumber resmi | Dukungan yang digunakan | Keterbatasan |
| --- | --- | --- | --- |
| B01 | Dell, [Laptop Battery Not Charging: Resolve AC Adapter Issues](https://www.dell.com/support/contents/en-us/article/product-support/self-support-knowledgebase/battery-and-power/ac-adapter). | Masalah pengisian dapat terkait adaptor, baterai, port, perangkat lunak atau pengaturan. Informasi pengenalan adaptor di BIOS dan pembanding kompatibel memberi konteks G01–G03, R01–R02, S01. | Bukan validasi formula R01–R02. Model dan kondisi pembanding perlu diperiksa. |
| B02 | Dell, [How to Stop Computer and Laptop Overheating and Shut Down Issues](https://www.dell.com/support/kbdoc/en-us/000130867/how-to-troubleshoot-a-overheating-shutdown-or-thermal-issue-on-a-dell-pc). | Keluhan panas, shutdown, diagnostik kipas/termal dan ventilasi memberi konteks G07–G09, R05–R07, S03. | Tidak menetapkan penyebab fisik tertentu dari gabungan gejala. |
| B03 | Dell, [Dell Laptop Beep Codes and LED Diagnostic Codes](https://www.dell.com/support/kbdoc/en-us/000132041/understanding-beep-codes-on-a-dell-notebook-pc). | Indikator awal dan pemetaan masalah memori memberi konteks G10–G11, R08, S04. | Manual perangkat spesifik tetap diperlukan. Kode belum dimasukkan ke basis pengetahuan ini. |
| B04 | Dell, [How to Resolve Hard Drive or solid state drive Issues on your Dell Computer](https://www.dell.com/support/kbdoc/en-us/000179526/how-to-resolve-hdd-hard-drive-issues-on-your-dell-system). | Pemeriksaan BIOS dan diagnostik penyimpanan memberi konteks G13–G15, R10–R11, S05. | Masalah boot dapat juga terkait konfigurasi atau perangkat lunak. Formula aturan dan saran penanganan data perlu ditinjau. |
| B05 | Dell, [Batterijstatus van laptop controleren: Batterijconditie testen in Windows](https://www.dell.com/support/contents/nl-nl/article/product-support/self-support-knowledgebase/battery-and-power/battery). | Halaman yang dibaca berbahasa Belanda akibat pengalihan situs. Bagian status kesehatan, penurunan waktu pakai, dan metode BIOS/diagnostik memberi konteks G04–G06, R03–R04, S02. | Redaksi G04 lebih spesifik daripada pembahasan shutdown umum di sumber. Perbandingan beban G06 dan interpretasi label memerlukan validasi. |
| B06 | Dell, [How to Run Dell Preboot Diagnostics and Hardware Tests on Your Dell Computer](https://www.dell.com/support/kbdoc/en-us/000181163/how-to-enter-the-built-in-diagnostics-32-bit-diagnostics-supportassist-epsa-epsa-and-psa). | Rujukan umum diagnostik perangkat keras sebelum sistem operasi, untuk konteks G12, G15, R09, R11, S04. | Belum menggantikan manual tes memori/penyimpanan model tertentu atau validasi hasil tes. |

## Sumber dan validasi yang masih diperlukan

| ID agenda | Item terkait | Pekerjaan tersisa |
| --- | --- | --- |
| V01 | G01–G03, R01–R02, S01 | Tentukan model, batas pengisian dan spesifikasi adaptor. Pastikan pemeriksaan pembanding membedakan adaptor dari port/rangkaian. |
| V02 | G04–G06, R03–R04, S02 | Validasi teknisi mengenai penurunan baterai dan arti label kesehatan pada model sasaran. Perjelas pengamatan waktu pakai dengan kondisi sebanding. |
| V03 | G07–G09, R05–R07, S03 | Cari manual pesan termal/tes kipas model sasaran dan tinjau penyebab alternatif shutdown. |
| V04 | G10–G12, R08–R09, S04 | Lengkapi manual pola beep/LED dan sumber khusus diagnostik memori; validasi bahwa kesimpulan tetap pada subsistem. |
| V05 | G13–G15, R10–R11, S05 | Lengkapi manual deteksi/tes penyimpanan dan tinjau pembeda konfigurasi, konektor, pengendali, media, serta penanganan data. |
| V06 | Semua aturan dan saran | Lakukan peninjauan teknisi dengan catatan tanggal, sumber, kasus pembanding, dan keputusan. Belum ada persetujuan pakar saat dokumen ini dibuat. |

## Catatan lingkungan

SWI-Prolog 10.0.2 terdeteksi dari terminal dan query sederhana berhasil pada komputer ini. Ini adalah hasil pemeriksaan lokal, bukan klaim bahwa versi tersebut merupakan rilis terbaru. Tidak ada klaim kompatibilitas semua versi atau akurasi diagnosis.
