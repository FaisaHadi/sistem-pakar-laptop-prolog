# Skenario pengujian prototipe

Pembaruan sistem pakar 23 Oktober 2026: suite gabungan berisi **131 tes** (48 mesin/CLI, 42 HTTP/API, 4 siklus server, 20 integritas pengetahuan, 9 penalaran/cakupan, dan 8 pembanding kasus). Dua tes penalaran memuat 320 kombinasi status/bukti dan 135 konsultasi adaptif terarah. Angka tersebut bukan pengukuran akurasi diagnosis.

```powershell
swipl -q -s tests/main_tests.pl -s tests/web_tests.pl -s tests/knowledge_tests.pl -g run_tests -t halt
```

T01–T30 awalnya diuji pada 22 Oktober; harapan berikut telah disesuaikan dengan [R01–R14](../knowledge/aturan_diagnosa.md), khususnya bukti langsung R12–R14. Suite [main_tests.pl](main_tests.pl) tetap berisi 48 tes. Riwayat eksekusi disimpan di [hasil_pengujian.md](hasil_pengujian.md).

## Konvensi data

Pada T01–T09, gejala pada kolom `ya` bernilai ya, dan **semua gejala lain bernilai tidak**. Setiap kasus merupakan sesi baru. Data adalah fixture sintetis untuk mengisolasi aturan; tidak menyatakan bahwa semua pola tersebut sudah diamati pada perangkat nyata. I01 dan I02 diturunkan dari aturan, tidak dimasukkan sebagai jawaban pengguna.

| ID | Gejala ya | Hasil yang diharapkan | Jejak dan alasan yang harus muncul |
| --- | --- | --- | --- |
| T01 | G01, G02, G03 | D01 dan S01 | R02 melalui R01; bukti G01–G03. |
| T02 | G04, G05 | D02 dan S02 | R03 memakai G04/G05; R12 memakai G05 saja. |
| T03 | G05, G06 | D02 dan S02 | R04 memakai G05/G06; R12 memakai G05 saja. |
| T04 | G07, G08 | D03 dan S03 | R06 melalui R05; bukti G07 dan G08. |
| T05 | G07, G09 | D03 dan S03 | R07 memakai G07/G09; R13 memakai G09 saja. |
| T06 | G10, G11 | D04 dan S04 | R08; hanya G10 dan G11. |
| T07 | G12 | D04 dan S04 | R09; G12. Jangan mengarang hasil POST/kode beep. |
| T08 | G13, G14 | D05 dan S05 | R10; hanya G13 dan G14. |
| T09 | G14, G15 | D05 dan S05 | R11 memakai G14/G15; R14 memakai G15 saja. |

T01 dan T04 mencakup aturan antara. T01–T09 dan tes bukti langsung pada knowledge_tests.pl mencakup seluruh 14 aturan.

## Kasus batas dan perilaku konsultasi

Kecuali dinyatakan lain, gejala yang tidak disebut pada T10–T17 juga bernilai tidak.

| ID | Masukan/kondisi | Hasil yang diharapkan |
| --- | --- | --- |
| T10 | Semua G01–G15 tidak | Tidak ada dugaan didukung. Nyatakan belum ada pola yang cocok dalam cakupan, bukan perangkat pasti sehat. |
| T11 | G01 dan G02 ya; G03 tidak_tahu | I01 terbukti, tetapi D01 belum lengkap. Sebut G03 sebagai bukti kurang; jangan tampilkan D01 sebagai hasil yang didukung. |
| T12 | G01 dan G02 ya; G03 tidak | I01 terbukti; jalur D01 tidak terpenuhi. Penjelasan tidak menyebut G03 sebagai bukti positif. |
| T13 | G06 dan G14 ya | Tidak menghasilkan D02 atau D05 hanya dari keluhan umum tersebut. |
| T14 | G04, G05, G06 ya | D02 tampil satu kali; tiga jalur R03, R04, R12 tersimpan dengan bukti masing-masing. |
| T15 | G07, G08, G09 ya | D03 tampil satu kali; jalur R06 melalui R05, R07, dan R13, tanpa menduplikasi dugaan/saran. |
| T16 | G07, G08, G12 ya | D03 dan D04 sama-sama tampil dengan alasan dan saran masing-masing; tanpa peringkat atau persentase. |
| T17 | G07 tidak; G08 dan G09 ya | R05/R07 tidak terpenuhi, tetapi R13 mendukung D03 dari hasil tes pendinginan G09. |
| T18 | Semua jawaban yang ditanya tidak_tahu | Tidak ada dugaan didukung. Jelaskan bukti belum lengkap; jangan menyimpan semua gejala sebagai tidak. |
| T19 | Input `mungkin`, lalu jawaban valid | Input pertama ditolak dengan petunjuk tiga pilihan dan pertanyaan diulang. Tidak ada fakta jawaban untuk input tidak valid. |
| T20 | Dalam satu sesi, G05 diperlukan R03 dan R04 | Pertanyaan G05 muncul paling banyak sekali; jawaban tersimpan dipakai ulang. Tidak ada pembacaan jawaban baru saat backtracking. |
| T21 | Sesi A sesuai T01, lalu mulai sesi B sesuai T10 | Sesi B tidak mewarisi G01–G03, I01, D01, atau jejak sesi A. |
| T22 | G11 belum punya manual model atau G12 belum diperiksa | Jawaban yang sesuai adalah tidak_tahu. Kode/beep dan hasil tes tidak ditebak oleh sistem. |
| T23 | Buktikan D01 terlebih dahulu dengan jawaban T01 | Urutan permintaan bukti G01, G02, G03 sesuai R02 lalu R01. Sesudahnya pencarian D02–D05 tetap berjalan. |
| T24 | EOF saat pertanyaan menunggu jawaban | Sesi berakhir tertib sebagai konsultasi belum selesai; tidak mencetak kesimpulan lengkap atau menganggap EOF sebagai tidak. |
| T25 | G04 tidak, G05 dan G06 ya | R03 gagal, tetapi R04 dan R12 mendukung D02. Hasil tidak bergantung pada keberhasilan aturan pertama. |

## Tambahan kontrak tiga status dan penggabungan jalur

Untuk T26–T30, seluruh gejala yang tidak disebut bernilai **tidak**. Revisi T30 memeriksa bahwa bukti langsung G15 kini mendukung D05.

| ID | Masukan | Hasil yang diharapkan |
| --- | --- | --- |
| T26 | G01 tidak_tahu; G02 dan G03 ya | I01/R01 dan D01/R02 `belum_lengkap`; bukti kurang tepat G01 dengan alasan tidak_tahu. |
| T27 | G01 tidak_tahu; G02 tidak; G03 ya | I01/R01 dan jalur D01/R02 `tidak_terpenuhi`. Kekurangan agregat D01 kosong karena jalurnya gugur; catatan jalur tetap menyimpan G01 tidak_tahu dan penolak G02. |
| T28 | G04 tidak_tahu; G05 dan G06 ya | D02 `didukung` melalui R04 dan R12. R03 tetap tersimpan sebagai jalur belum_lengkap dengan kekurangan G04; kekurangan agregat D02 kosong. |
| T29 | G13, G14, G15 ya | Satu D05 `didukung` dengan tiga jalur R10, R11, dan R14, alasan per jalur, dan satu saran S05. |
| T30 | Hanya G15 ya | D05 `didukung` melalui R14 meskipun G14 tidak; saran S05 tampil dengan batas interpretasi. |

## Pemeriksaan terminal dan kontrak tambahan

Pengujian selain T01–T30 mencakup perbedaan belum_ditanya/tidak_tahu, EOF sebelum jawaban dan setelah input invalid/unknown/hipotesis didukung, kelanjutan AND setelah tidak_tahu, pembaruan jejak setelah alternatif, pemeriksaan alternatif setelah satu berhasil, tidak adanya efek samping mode tersimpan, penyimpanan idempoten, penolakan koreksi tengah sesi/nilai atau ID invalid, menu sesi baru, EOF di menu, jumlah dan status draf pengetahuan, serta alasan/saran seluruh hasil.

Fixture logika sengaja mengisi semua gejala. Pada uji terminal, gejala hanya ditanyakan bila diperlukan dalam penelusuran tujuan. Sisa premis pada jalur yang gugur boleh belum_ditanya. Ini tidak boleh menutupi premis tidak yang membuat jalur tersebut tidak_terpenuhi.

Dua pengujian bahasa tambahan memeriksa petunjuk awal, bantuan G01-G03 yang tetap tampil, padanan tiga status, jejak R02 -> R01, dan informasi kurang G03 saat tidak_tahu. Harapan jalur, urutan pertanyaan, dan fixture jawaban kini juga mengikuti revisi bukti langsung R12–R14.

## Kriteria pemeriksaan hasil

Tambahan otomatis di `web_tests.pl` memeriksa request kosong/kurang/duplikat, tipe dan ID/nilai invalid, JSON rusak, hasil positif/unknown/ganda/negatif, tidak adanya saran pada dugaan tidak didukung, konteks aturan pertanyaan, pergantian aturan alternatif, pemisahan data antarpermintaan, dan perjalanan konsultasi adaptif sampai selesai. Pada endpoint `/api/diagnose`, list jawaban kosong invalid; pada `/api/consult`, list kosong adalah awal konsultasi dan harus mengembalikan G01.

Pemeriksaan browser yang dapat diulang:

1. Awal: pilih merek/model dan mulai konsultasi. G01 dan bantuan batas pengisian terlihat tanpa membuka tombol. Buka alasan pertanyaan; D01 dan R02 → R01 harus muncul.
2. Jawab G01–G02 ya, kembali ke G02 dan ubah menjadi tidak. G03 dilewati dan pertanyaan beralih ke G04. Kembali lagi dan ubah G02 menjadi ya; G03 muncul tanpa mewarisi jawaban lama.
3. G01–G03 ya, pertanyaan berikutnya tidak: hasil D01 dengan S01, 12 jawaban dan 3 gejala dilewati. Detail aturan dilipat dan dapat dibuka; empat dugaan tidak didukung berada dalam rincian terpisah.
4. Dari hasil, pilih Tinjau jawaban dan ubah G01 menjadi tidak; jawab tidak untuk sisanya. Hasil tidak mewarisi D01, selesai setelah 10 jawaban dengan 5 gejala dilewati.
5. Mulai konsultasi baru: formulir perangkat muncul dan hitungan kembali nol. Mulai kembali; tidak ada jawaban gejala lama. Pilih jawaban, hentikan server, lalu lanjutkan. Pesan koneksi tampil dengan pilihan tetap tersimpan; hidupkan server dan tekan Coba lagi, konsultasi berlanjut.

Browser diuji secara langsung; langkah di atas bukan klaim adanya runner UI otomatis. Pengujian HTTP dijalankan oleh PLUnit dengan server pada port kosong yang dipilih otomatis dan dihentikan sesudah suite.

Setiap hasil positif harus menyebut ID gangguan, seluruh gejala positif pada jejaknya, ID aturan termasuk aturan antara, saran yang sesuai, dan status pengetahuan draf/tervalidasi yang benar. Gejala yang tidak ditanya, dijawab tidak, atau tidak_tahu tidak boleh tampil sebagai alasan positif.

Hasil aktual tercatat pada [catatan pengujian](hasil_pengujian.md). Pisahkan uji konsistensi program dari validasi teknisi atau pengukuran kinerja terhadap kasus nyata. Saat ini tidak ada hasil pengukuran akurasi maupun persentase kepastian. Seluruh pengetahuan tetap draf.


## Integritas pengetahuan dan kasus pakar

Tes salinan data menolak ID berulang, premis/kesimpulan tak dikenal, list premis kosong/berulang, siklus langsung dan tidak langsung, aturan duplikat, metadata/sumber hilang, URL tidak HTTPS, batas/saran hilang, gejala yatim, kumpulan kosong, dan status tervalidasi tanpa dukungan yang belum diterapkan. Pengetahuan produksi tidak diubah saat pengujian negatif.

Oracle independen menyatakan kontrak: D01 = G01 AND G02 AND G03; D02 = G05; D03 = (G07 AND G08) OR G09; D04 = (G10 AND G11) OR G12; D05 = (G13 AND G14) OR G15. Oracle tidak membaca aturan/3. Jalur gabungan tetap diuji sebagai penjelasan tambahan. Nilai ya/tidak/tidak_tahu/belum_ditanya menghasilkan 320 kombinasi terarah atas tiga gejala tiap kelompok, bukan seluruh kombinasi 15 gejala sekaligus. Sebanyak 135 konsultasi adaptif diuji dengan tiga jawaban pengguna, tanpa pertanyaan berulang dan maksimal 15 pertanyaan.

Tes pembanding memakai kasus sintetis yang hanya ada dalam kode tes. Dataset kasus nyata tetap kosong. Tanpa kasus, laporan harus menampilkan null untuk proporsi kecocokan; dengan fixture, ketidaksesuaian harus mengungkap label berlebih dan terlewat. Kasus tanpa peninjau/model, jawaban tidak lengkap, ID kasus berulang, serta label tak dikenal ditolak. Konteks merek tidak boleh menghasilkan model_verified=true.

Pemeriksaan browser tambahan: G05 saja mendukung D02, G09 saja mendukung D03, G15 saja mendukung D05; buka rincian untuk melihat sumber/batas/status dan arti jalur alternatif. Pilih merek tanpa rujukan khusus dan pastikan peringatannya terlihat. Ganti perangkat mereset jawaban, sedangkan koreksi gejala menelusuri ulang bukti setelahnya.
