# Skenario pengujian prototipe

Status: **T01–T30 diimplementasikan dalam pengujian otomatis dan lulus pada 22 Oktober 2026**. Tabel memeriksa konsekuensi logis [R01–R11](../knowledge/aturan_diagnosa.md) serta perilaku terminal, bukan akurasi diagnosis perangkat nyata. Suite [main_tests.pl](main_tests.pl) berisi 48 pengujian termasuk kasus tambahan. Hasil aktual dicatat di [hasil_pengujian.md](hasil_pengujian.md).

## Konvensi data

Pada T01–T09, gejala pada kolom `ya` bernilai ya, dan **semua gejala lain bernilai tidak**. Setiap kasus merupakan sesi baru. Data adalah fixture sintetis untuk mengisolasi aturan; tidak menyatakan bahwa semua pola tersebut sudah diamati pada perangkat nyata. I01 dan I02 diturunkan dari aturan, tidak dimasukkan sebagai jawaban pengguna.

| ID | Gejala ya | Hasil yang diharapkan | Jejak dan alasan yang harus muncul |
| --- | --- | --- | --- |
| T01 | G01, G02, G03 | D01 dan S01 | R02 melalui R01; bukti G01–G03. |
| T02 | G04, G05 | D02 dan S02 | R03; hanya G04 dan G05. |
| T03 | G05, G06 | D02 dan S02 | R04; hanya G05 dan G06. |
| T04 | G07, G08 | D03 dan S03 | R06 melalui R05; bukti G07 dan G08. |
| T05 | G07, G09 | D03 dan S03 | R07; hanya G07 dan G09. |
| T06 | G10, G11 | D04 dan S04 | R08; hanya G10 dan G11. |
| T07 | G12 | D04 dan S04 | R09; G12. Jangan mengarang hasil POST/kode beep. |
| T08 | G13, G14 | D05 dan S05 | R10; hanya G13 dan G14. |
| T09 | G14, G15 | D05 dan S05 | R11; hanya G14 dan G15. |

T01 dan T04 mencakup aturan antara, sehingga T01–T09 bersama-sama menelusuri seluruh 11 aturan.

## Kasus batas dan perilaku konsultasi

Kecuali dinyatakan lain, gejala yang tidak disebut pada T10–T17 juga bernilai tidak.

| ID | Masukan/kondisi | Hasil yang diharapkan |
| --- | --- | --- |
| T10 | Semua G01–G15 tidak | Tidak ada dugaan didukung. Nyatakan belum ada pola yang cocok dalam cakupan, bukan perangkat pasti sehat. |
| T11 | G01 dan G02 ya; G03 tidak_tahu | I01 terbukti, tetapi D01 belum lengkap. Sebut G03 sebagai bukti kurang; jangan tampilkan D01 sebagai hasil yang didukung. |
| T12 | G01 dan G02 ya; G03 tidak | I01 terbukti; jalur D01 tidak terpenuhi. Penjelasan tidak menyebut G03 sebagai bukti positif. |
| T13 | G06 dan G14 ya | Tidak menghasilkan D02 atau D05 hanya dari keluhan umum tersebut. |
| T14 | G04, G05, G06 ya | D02 tampil satu kali; dua jalur R03 dan R04 tersimpan beserta G04–G06. |
| T15 | G07, G08, G09 ya | D03 tampil satu kali; jalur R06 melalui R05 serta R07, tanpa menduplikasi gejala/saran. |
| T16 | G07, G08, G12 ya | D03 dan D04 sama-sama tampil dengan alasan dan saran masing-masing; tanpa peringkat atau persentase. |
| T17 | G07 tidak; G08 dan G09 ya | R05 dan R07 tidak terpenuhi; D03 belum didukung. Kipas gagal saja belum memiliki aturan tersendiri pada rancangan ini. |
| T18 | Semua jawaban yang ditanya tidak_tahu | Tidak ada dugaan didukung. Jelaskan bukti belum lengkap; jangan menyimpan semua gejala sebagai tidak. |
| T19 | Input `mungkin`, lalu jawaban valid | Input pertama ditolak dengan petunjuk tiga pilihan dan pertanyaan diulang. Tidak ada fakta jawaban untuk input tidak valid. |
| T20 | Dalam satu sesi, G05 diperlukan R03 dan R04 | Pertanyaan G05 muncul paling banyak sekali; jawaban tersimpan dipakai ulang. Tidak ada pembacaan jawaban baru saat backtracking. |
| T21 | Sesi A sesuai T01, lalu mulai sesi B sesuai T10 | Sesi B tidak mewarisi G01–G03, I01, D01, atau jejak sesi A. |
| T22 | G11 belum punya manual model atau G12 belum diperiksa | Jawaban yang sesuai adalah tidak_tahu. Kode/beep dan hasil tes tidak ditebak oleh sistem. |
| T23 | Buktikan D01 terlebih dahulu dengan jawaban T01 | Urutan permintaan bukti G01, G02, G03 sesuai R02 lalu R01. Sesudahnya pencarian D02–D05 tetap berjalan. |
| T24 | EOF saat pertanyaan menunggu jawaban | Sesi berakhir tertib sebagai konsultasi belum selesai; tidak mencetak kesimpulan lengkap atau menganggap EOF sebagai tidak. |
| T25 | G04 tidak, G05 dan G06 ya | R03 gagal, tetapi R04 tetap dicoba dan menghasilkan D02. Hasil tidak bergantung pada keberhasilan aturan pertama. |

## Tambahan kontrak tiga status dan penggabungan jalur

Untuk T26–T30, seluruh gejala yang tidak disebut bernilai **tidak**. Kata belum didukung di T30 diwakili status `tidak_terpenuhi`, bukan pernyataan laptop sehat.

| ID | Masukan | Hasil yang diharapkan |
| --- | --- | --- |
| T26 | G01 tidak_tahu; G02 dan G03 ya | I01/R01 dan D01/R02 `belum_lengkap`; bukti kurang tepat G01 dengan alasan tidak_tahu. |
| T27 | G01 tidak_tahu; G02 tidak; G03 ya | I01/R01 dan jalur D01/R02 `tidak_terpenuhi`. Kekurangan agregat D01 kosong karena jalurnya gugur; catatan jalur tetap menyimpan G01 tidak_tahu dan penolak G02. |
| T28 | G04 tidak_tahu; G05 dan G06 ya | D02 `didukung` melalui R04. R03 tetap tersimpan sebagai jalur belum_lengkap dengan kekurangan G04; kekurangan agregat D02 kosong. |
| T29 | G13, G14, G15 ya | Satu D05 `didukung` dengan dua jalur R10 dan R11, alasan per jalur, dan satu saran S05. |
| T30 | Hanya G15 ya | D05 `tidak_terpenuhi` karena G14 tidak. Tidak menyatakan perangkat sehat dan tidak mengeluarkan saran D05 sebagai diagnosis yang didukung. |

## Pemeriksaan terminal dan kontrak tambahan

Pengujian selain T01–T30 mencakup perbedaan belum_ditanya/tidak_tahu, EOF sebelum jawaban dan setelah input invalid/unknown/hipotesis didukung, kelanjutan AND setelah tidak_tahu, pembaruan jejak setelah alternatif, pemeriksaan alternatif setelah satu berhasil, tidak adanya efek samping mode tersimpan, penyimpanan idempoten, penolakan koreksi tengah sesi/nilai atau ID invalid, menu sesi baru, EOF di menu, jumlah dan status draf pengetahuan, serta alasan/saran seluruh hasil.

Fixture logika sengaja mengisi semua gejala. Pada uji terminal, gejala hanya ditanyakan bila diperlukan dalam penelusuran tujuan. Sisa premis pada jalur yang gugur boleh belum_ditanya. Ini tidak boleh menutupi premis tidak yang membuat jalur tersebut tidak_terpenuhi.

Dua pengujian bahasa tambahan memeriksa petunjuk awal, bantuan G01-G03 yang tetap tampil, padanan tiga status, jejak R02 -> R01, dan informasi kurang G03 saat tidak_tahu. Seluruh pemeriksaan perilaku sebelumnya tetap dipertahankan; perubahan harapan tes lama hanya pada teks tampilan.

## Kriteria pemeriksaan hasil

Setiap hasil positif harus menyebut ID gangguan, seluruh gejala positif pada jejaknya, ID aturan termasuk aturan antara, saran yang sesuai, dan status pengetahuan draf/tervalidasi yang benar. Gejala yang tidak ditanya, dijawab tidak, atau tidak_tahu tidak boleh tampil sebagai alasan positif.

Hasil aktual tercatat pada [catatan pengujian](hasil_pengujian.md). Pisahkan uji konsistensi program dari validasi teknisi atau pengukuran kinerja terhadap kasus nyata. Saat ini tidak ada hasil pengukuran akurasi maupun persentase kepastian. Seluruh pengetahuan tetap draf.
