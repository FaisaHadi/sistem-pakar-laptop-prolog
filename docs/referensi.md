# Referensi dan status validasi

Tanggal pembacaan awal: **22 Oktober 2026**. PDF M03 dan salinan tambahan M04 dari pengguna dibaca pada **23 Oktober 2026**. Sumber domain B01–B06 diperiksa ulang pada 23 Oktober dan dilengkapi B07–B08 untuk Lenovo dan HP. Tidak ada wawancara teknisi, pengukuran akurasi diagnosis, atau studi kasus perangkat nyata yang telah dilakukan.

## Materi lokal

Lokasi lengkap dan tautan sumber ada pada [indeks materi](materi/README.md).

| ID | Identitas sumber | Pemakaian |
| --- | --- | --- |
| M01 | Aradea. Penalaran: Logic, Rules and Representation I. PPTX perkuliahan, tahun tidak tercantum pada sampul. | Akuisisi dan representasi pengetahuan, logika dan fakta; terutama slide 9–17. |
| M02 | Aradea. Penalaran: Logic, Rules and Representation II. PPTX perkuliahan, tahun tidak tercantum pada sampul. | Arsitektur basis pengetahuan, verifikasi/validasi, aturan dan backward chaining; terutama slide 8–9, 31–40. |
| M03 | Aradea. Penalaran: Logic, Rules and Representation III. PPTX yang dicatat sebelumnya dan PDF tambahan 55 halaman dari pengguna; tahun tidak tercantum pada sampul. | PDF halaman 6–13: sistem pakar dan penjelasan; 20–33: fakta, aturan dan query; 34: backward chaining; 38–42: list dan rekursi; 54: laporan, program dan demo pada pertemuan ke-11. |
| M04 | Deskripsi Tugas Besar Kecerdasan Buatan. Salinan PDF tambahan pengguna berjumlah dua halaman; penulis dan tahun tidak tercantum. | Halaman 1: opsi AI with PROLOG, rincian slide, demo dan video tutorial. Halaman 2: pengumpulan video ke ketua kelas dan unggahan ke kanal/playlist yang ditentukan. Mengoreksi catatan sebelumnya yang menyebut satu halaman. |

Materi mendukung metode sistem pakar. Materi tersebut tidak memberikan basis diagnosis laptop. Daftar pustaka di dalam slide tidak dianggap sebagai buku yang sudah dibaca langsung oleh kelompok.

M03 menjadi acuan pemisahan basis pengetahuan dari mesin inferensi, penjelasan jalur, fakta/aturan/query, serta penelusuran rekursif atas list premis. Representasi `aturan/3`, tiga status bukti, dan 15 gejala adalah keputusan proyek. Rancangan semula berisi 11 aturan. Revisi 23 Oktober menambah R12–R14 berdasarkan hasil pemeriksaan resmi sebagai bukti langsung; total kini 14 aturan, tetap draf. Tutorial video yang ditautkan pada PDF belum ditonton dalam pembacaan ini.

## Sumber domain yang diperiksa

Sumber resmi Dell digunakan sebagai titik awal, kemudian ditambah panduan Lenovo dan HP. Ketersediaan alat dan interpretasi pesan berbeda menurut model. Kombinasi aturan adalah representasi proyek, bukan formula diagnosis yang diterbitkan atau disetujui produsen. Tanggal berikut adalah tanggal akses; panduan B07 secara spesifik merupakan versi 5.23.2 untuk Windows, bukan klaim versi terbaru.

| ID | Sumber resmi | Dukungan yang digunakan | Keterbatasan |
| --- | --- | --- | --- |
| B01 | Dell, [Laptop Battery Not Charging: Resolve AC Adapter Issues](https://www.dell.com/support/contents/en-us/article/product-support/self-support-knowledgebase/battery-and-power/ac-adapter). | Masalah pengisian dapat terkait adaptor, baterai, port, perangkat lunak atau pengaturan. Informasi pengenalan adaptor di BIOS dan pembanding kompatibel memberi konteks G01–G03, R01–R02, S01. | Bukan validasi formula R01–R02. Model dan kondisi pembanding perlu diperiksa. |
| B02 | Dell, [How to Stop Computer and Laptop Overheating and Shut Down Issues](https://www.dell.com/support/kbdoc/en-us/000130867/how-to-troubleshoot-a-overheating-shutdown-or-thermal-issue-on-a-dell-pc). | Keluhan panas, shutdown, diagnostik kipas/termal dan ventilasi memberi konteks G07–G09, R05–R07, S03. | Tidak menetapkan penyebab fisik tertentu dari gabungan gejala. |
| B03 | Dell, [Dell Laptop Beep Codes and LED Diagnostic Codes](https://www.dell.com/support/kbdoc/en-us/000132041/understanding-beep-codes-on-a-dell-notebook-pc). | Indikator awal dan pemetaan masalah memori memberi konteks G10–G11, R08, S04. | Manual perangkat spesifik tetap diperlukan. Kode belum dimasukkan ke basis pengetahuan ini. |
| B04 | Dell, [How to Resolve Hard Drive or solid state drive Issues on your Dell Computer](https://www.dell.com/support/kbdoc/en-us/000179526/how-to-resolve-hdd-hard-drive-issues-on-your-dell-system). | Pemeriksaan BIOS dan diagnostik penyimpanan memberi konteks G13–G15, R10–R11, S05. | Masalah boot dapat juga terkait konfigurasi atau perangkat lunak. Formula aturan dan saran penanganan data perlu ditinjau. |
| B05 | Dell, [Check Laptop Battery Health](https://www.dell.com/support/contents/en-us/article/product-support/self-support-knowledgebase/battery-and-power/battery). | Pembacaan ulang berbahasa Inggris: penafsiran kesehatan baterai dan rekomendasi penanganan label Poor memberi konteks G05 dan R12. | Tidak memvalidasi rumus R03/R04 atau semua model. Label Unknown bukan bukti positif. |
| B06 | Dell, [How to Run Dell Preboot Diagnostics and Hardware Tests on Your Dell Computer](https://www.dell.com/support/kbdoc/en-us/000181163/how-to-enter-the-built-in-diagnostics-32-bit-diagnostics-supportassist-epsa-epsa-and-psa). | Rujukan umum diagnostik perangkat keras sebelum sistem operasi, untuk konteks G12, G15, R09, R11, S04. | Belum menggantikan manual tes memori/penyimpanan model tertentu atau validasi hasil tes. |
| B07 | Lenovo, [Lenovo Diagnostics Evolution 5.23.2 User Guide](https://download.lenovo.com/pccbbs/thinkvantage_en/ldiag_5.23.2_windows_user_guide.pdf). | Bagian Test Status (halaman 20), Fan (halaman 60), Memory (halaman 65–67), dan Storage membedakan tes komponen dan status hasil; konteks R09/R13/R14. | Modul bergantung pada perangkat yang didukung. Warning belum konklusif; Canceled dan Not Applicable bukan hasil gagal. Tidak memberi tabel kode BIOS universal. |
| B08 | HP, [HP PCs — Testing for hardware failures](https://support.hp.com/us-en/document/ish_2854458-2733239-16?requestedDocId=ish_3042096-2941213-16&validated=true). | Bagian Component Tests, Memory, Storage, Fan Tests, serta tabel Battery Check memberi konteks G05/G09/G12/G15 dan R09/R12–R14. | Pakai hasil tes komponen yang tepat beserta failure ID bila tersedia. Ketersediaan tes berbeda menurut versi alat/perangkat; bukan validasi lintas model. |

Semua URL, merek sumber, tanggal akses 23 Oktober 2026, dan batasnya juga tersedia sebagai fakta `sumber/6` di `src/knowledge_meta.pl`. Sumber tersebut ditampilkan pada penjelasan aturan di CLI/web. Pembacaan ulang Dell dan HP dilakukan melalui Firecrawl; halaman dukungan Lenovo membatasi akses otomatis (403), sehingga panduan PDF resmi Lenovo di atas diperiksa melalui pembaca web. Tidak ada pembatasan akses yang dilewati.

R12–R14 menyatakan dugaan pada subsistem yang secara spesifik dilaporkan bermasalah oleh tes, tanpa menentukan komponen fisik atau keputusan penggantian. Rujukan resmi mendasari revisi ini; penerimaan pakar masih menunggu [lembar peninjauan](../knowledge/validasi_pakar.md).

## Sumber dan validasi yang masih diperlukan

| ID agenda | Item terkait | Pekerjaan tersisa |
| --- | --- | --- |
| V01 | G01–G03, R01–R02, S01 | Tentukan model, batas pengisian dan spesifikasi adaptor. Pastikan pemeriksaan pembanding membedakan adaptor dari port/rangkaian. |
| V02 | G04–G06, R03–R04/R12, S02 | Validasi teknisi mengenai arti label kesehatan model sasaran dan kecukupan bukti langsung. Perjelas pengamatan waktu pakai pada kondisi sebanding. |
| V03 | G07–G09, R05–R07/R13, S03 | Cocokkan panduan tes kipas B02/B07/B08 dengan model sasaran dan tinjau penyebab alternatif shutdown. |
| V04 | G10–G12, R08–R09, S04 | Lengkapi manual pola beep/LED model; cocokkan bagian tes memori B07/B08 dengan perangkat dan pertahankan kesimpulan pada subsistem. |
| V05 | G13–G15, R10–R11/R14, S05 | Cocokkan deteksi/tes penyimpanan dengan model dan tinjau pembeda konfigurasi, konektor, pengendali, media, serta penanganan data. |
| V06 | Semua aturan dan saran | Lakukan peninjauan teknisi dengan catatan tanggal, sumber, kasus pembanding, dan keputusan. Belum ada persetujuan pakar saat dokumen ini dibuat. |

## Catatan lingkungan

SWI-Prolog 10.0.2 terdeteksi dari terminal dan query sederhana berhasil pada komputer ini. Ini adalah hasil pemeriksaan lokal, bukan klaim bahwa versi tersebut merupakan rilis terbaru. Tidak ada klaim kompatibilitas semua versi atau akurasi diagnosis.
