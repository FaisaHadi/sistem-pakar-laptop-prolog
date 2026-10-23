# Aturan diagnosis awal

Usulan **5 gangguan, 2 indikasi antara, dan 14 aturan**. R01 dan R05 menghasilkan indikasi antara; dua belas aturan lainnya menghasilkan dugaan gangguan. Seluruhnya berstatus **DRAF / PERLU_VALIDASI_TEKNISI**. Kaitan dengan sumber adalah dukungan sebagian terhadap gejala/pemeriksaan, bukan pernyataan bahwa produsen menerbitkan kombinasi aturan ini.

Gunakan [definisi gejala](daftar_gejala.md) dan [daftar sumber](../docs/referensi.md) saat meninjau aturan. Semua premis dalam tabel harus bernilai `ya`. Dua aturan dengan kesimpulan sama merupakan jalur alternatif (OR antaraturan), sedangkan AND berlaku di dalam satu aturan.

## Gangguan dan batas kesimpulan

| ID | Dugaan gangguan | Batas interpretasi |
| --- | --- | --- |
| D01 | Gangguan charger atau kabel dayanya | Pemeriksaan pembanding mengarah pada charger/kabel semula. Belum membedakan kerusakan, ketidakcocokan spesifikasi, dan komunikasi identifikasi charger. |
| D02 | Kondisi baterai menurun atau bermasalah | Memerlukan bukti kesehatan baterai. Bukan kesimpulan dari keluhan cepat habis saja. |
| D03 | Masalah pendinginan atau panas berlebih | Belum memastikan kipas, debu, sensor, atau bahan penghantar panas sebagai penyebab. |
| D04 | Masalah pada sistem memori kerja (RAM) | Dapat memerlukan pemeriksaan modul, slot, atau rangkaian terkait. Tidak otomatis berarti modul harus diganti. |
| D05 | Masalah pengenalan atau kondisi penyimpanan (SSD/HDD) | Dapat melibatkan media, sambungan, pengendali, atau konfigurasi. Tidak otomatis berarti data hilang atau media harus diformat. |

## Indikasi antara

| ID | Makna |
| --- | --- |
| I01 | Pola baterai tidak terisi dan charger semula tidak dikenali. |
| I02 | Pola peringatan panas berlebih dan mati atau menyala ulang mendadak saat bekerja lebih berat. |

Indikasi hanya merangkum bukti untuk pembuktian bertingkat. I01 dan I02 tidak dihitung sebagai gangguan keenam atau ketujuh dan tidak ditanyakan langsung kepada pengguna.

## Tabel aturan

| ID | Premis (IF) | Kesimpulan (THEN) | Dasar awal / yang perlu divalidasi |
| --- | --- | --- | --- |
| R01 | G01 AND G02 | I01 | B01; ringkasan observasi, perlu memeriksa konteks charger semula. |
| R02 | I01 AND G03 | D01 | B01; perlu validasi kontrol pembanding dan kecocokan charger pada model sasaran. |
| R03 | G04 AND G05 | D02 | B05; perlu validasi bahwa laporan kesehatan dan peristiwa beralih daya relevan pada kejadian yang sama. |
| R04 | G05 AND G06 | D02 | B05; perlu validasi perbandingan beban/pengaturan dan redaksi waktu pakai menurun. |
| R05 | G07 AND G08 | I02 | B02; gabungan observasi termal dan gangguan beban, bukan hubungan sebab yang sudah pasti. |
| R06 | I02 | D03 | B02; perlu validasi kecukupan pola G07 dan G08 untuk dugaan awal. |
| R07 | G07 AND G09 | D03 | B02; perlu manual interpretasi hasil diagnostik termal/kipas model sasaran. |
| R08 | G10 AND G11 | D04 | B03; wajib pemetaan kode ke manual model, tidak ada angka beep universal. |
| R09 | G12 | D04 | B06, B07 (Memory), B08 (Memory Tests); interpretasi hasil gagal tetap perlu validasi model/pakar. Satu hasil tes yang spesifik dipakai sebagai jalur tersendiri. |
| R10 | G13 AND G14 | D05 | B04; perlu validasi pembeda gangguan sambungan, konfigurasi, dan media. |
| R11 | G14 AND G15 | D05 | B04, B06, B07, B08; jalur gabungan keluhan boot dan hasil tes. |
| R12 | G05 | D02 | B05 dan B08; laporan kesehatan baterai yang secara tegas buruk/perlu diganti menjadi bukti langsung. |
| R13 | G09 | D03 | B02, B07 (Fan dan status hasil), B08 (Fan Tests); kegagalan tes kipas/pendinginan menjadi bukti langsung. |
| R14 | G15 | D05 | B04, B07 (Storage dan status hasil), B08 (Storage Tests); kegagalan tes penyimpanan menjadi bukti langsung. |

Aturan sengaja konservatif untuk demo awal. Misalnya G14 saja tidak menghasilkan D05, G06 saja tidak menghasilkan D02, dan I01 saja tidak menghasilkan D01. R12–R14 memperbaiki keadaan sebelumnya saat G05/G09/G15 positif belum mendukung dugaan tanpa gejala tambahan. Hanya hasil yang spesifik pada subsistem dihitung; warning belum konklusif, canceled, not applicable, dan hasil belum selesai diperlakukan sebagai tidak_tahu. Aturan tetap dapat gagal menangkap gangguan nyata bila bukti belum tersedia.

R01–R02 dan R05–R06 memberi contoh pembuktian bertingkat. Tidak ada siklus: indikasi hanya bergantung pada gejala, dan diagnosis hanya bergantung pada indikasi/gejala. Semua G01–G15 digunakan setidaknya sekali.

## Alasan dan saran hasil konsultasi

Nama gangguan, label indikasi, dan saran di dokumen ini sama dengan teks di `src/knowledge.pl`. Tabel premis/kesimpulan serta status draf tetap. Catatan sumber dan batas interpretasi berikut ditujukan untuk peninjau teknis.

Alasan diambil dari cabang aturan yang berhasil, bukan teks diagnosis yang mencantumkan semua gejala kelompok tersebut. Contoh: D02 melalui R04 menyebut G05 dan G06, tidak menambahkan G04 bila gejala itu tidak dijawab ya. Jika beberapa jalur berhasil, tampilkan semua jalur dan bukti uniknya tanpa menambah kepastian. R03/R04, R07, dan R11 merupakan penguatan konteks yang sebagian tercakup jalur langsung R12–R14. Jalur-jalur tersebut tidak dianggap bukti independen atau diagnosis terpisah.

| ID saran | Untuk | Saran yang ditampilkan kepada pengguna | Status dan sumber awal |
| --- | --- | --- | --- |
| S01 | D01 | Anda dapat mencocokkan spesifikasi charger dengan panduan resmi model laptop Anda. Mintalah teknisi memeriksa charger atau kabel semula sebelum Anda menggantinya. | DRAF; B01. PERLU_SUMBER_MODEL dan validasi teknisi. |
| S02 | D02 | Simpan laporan kondisi baterai yang sudah Anda miliki. Mintalah layanan resmi atau teknisi menilai apakah baterai perlu diganti dengan yang sesuai model laptop Anda. | DRAF; B05. PERLU_SUMBER_MODEL dan validasi teknisi. |
| S03 | D03 | Hentikan kegiatan berat pada laptop Anda dan biarkan laptop mendingin. Gunakan permukaan keras dengan lubang udara yang tidak tertutup. Jika keluhan berulang, mintalah teknisi menilai sistem pendinginannya. | DRAF; B02. Perlu validasi redaksi dan pemeriksaan model. |
| S04 | D04 | Simpan pola bunyi atau kedipan lampu, atau hasil pemeriksaan RAM yang sudah Anda miliki. Mintalah teknisi mencocokkannya dengan panduan resmi model laptop Anda dan memeriksa sistem memorinya. | DRAF; B03, B06. Sumber khusus tes memori/model belum lengkap. |
| S05 | D05 | Jika laptop Anda masih aman digunakan, cadangkan berkas penting Anda. Simpan informasi penyimpanan dari BIOS/UEFI atau hasil pemeriksaan yang sudah tersedia. Mintalah teknisi memeriksa penyimpanan dan sambungannya. Hindari format atau pemasangan ulang sistem sebelum masalah dan kebutuhan data Anda dinilai. | DRAF; B04. Perlu validasi penanganan data oleh teknisi. |

Saran awal dibatasi pada pengamatan, pencatatan bukti, dan rujukan. Aplikasi tidak mengarahkan pengguna membongkar baterai internal, memindahkan RAM, mengubah pengaturan boot, atau memperbarui BIOS sebagai tindakan otomatis berdasarkan aturan draf.

## Validator dan penjelasan

`src/knowledge_check.pl` memeriksa keunikan ID, referensi premis/kesimpulan, siklus, metadata/sumber, batas kesimpulan, saran, serta gejala yang tidak digunakan sebelum sesi/server dimulai. `src/knowledge_meta.pl` menyimpan URL, tanggal akses, merek sumber, dan batas setiap aturan. CLI dan web menampilkan penjelasan dari data yang sama.

Cakupan lintas merek bersyarat: tidak semua alat, tombol BIOS, dan kode berlaku pada seluruh model. R01/R02 dan R08 masih memiliki rujukan awal khusus Dell; pada merek lain pertanyaan hanya dijawab ya bila bukti model memang sesuai. Jika belum diketahui, pilih tidak_tahu.

## Agenda validasi pengetahuan

Untuk setiap R01–R14 dan S01–S05, catat sumber/manual beserta bagian relevan, identitas atau peran peninjau yang benar-benar terlibat, tanggal peninjauan, contoh kasus, alternatif penyebab, serta keputusan terima/revisi/tolak. Saat ini belum ada wawancara pakar atau pengujian perangkat nyata. Jangan mengubah status menjadi tervalidasi hanya karena skenario logikanya konsisten.

Lembar keputusan dan prosedur kasus tersedia di [validasi_pakar.md](validasi_pakar.md). Dataset nyata sengaja kosong; pembanding Prolog tidak menghasilkan angka akurasi sebelum label peninjau tersedia.
