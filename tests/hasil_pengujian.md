# Hasil pengujian aktual prototipe

Tanggal: **22 Oktober 2026**. Lingkungan: Windows, SWI-Prolog **10.0.2 for x64-win64**.

## Hasil otomatis

Perintah dari akar proyek:

```powershell
swipl -q -s tests/main_tests.pl -g run_tests -t halt
```

Hasil eksekusi: **48 pengujian lulus, 0 gagal, exit code 0**. Tidak ada peringatan choicepoint atau kesalahan pemuatan pada eksekusi akhir suite ini.

| Cakupan | Hasil aktual |
| --- | --- |
| T01–T09 | Sembilan jalur diagnosis positif cocok, termasuk aturan antara R01 dan R05. |
| T10–T18 | Kasus negatif, unknown, jalur ganda dan diagnosis ganda sesuai harapan. |
| T19–T25 | Input invalid, penggunaan ulang jawaban, reset, belum diperiksa, urutan pertanyaan, EOF, dan alternatif setelah aturan gagal sesuai harapan. |
| T26 | D01 belum_lengkap, kekurangan G01 tidak_tahu dibawa melalui I01/R01 ke R02. |
| T27 | D01 tidak_terpenuhi; jawaban `tidak` pada G02 menentukan hasil AND walau G01 `tidak_tahu`. |
| T28 | D02 didukung R04; R03 yang belum lengkap tetap tersimpan. |
| T29 | Satu D05 dengan R10 dan R11, alasan masing-masing, satu S05. |
| T30 | D05 tidak_terpenuhi, bukan kesimpulan perangkat sehat. |
| 18 pengujian tambahan | Pemisahan keadaan jawaban/sesi, EOF parsial, aturan alternatif, pembaruan jejak, penyimpanan dan menu, ID tetap, serta alasan/saran seluruh hasil lulus. Dua pengujian bahasa tambahan memeriksa petunjuk, bantuan, padanan status, dan sesi D01 dengan G03 ya/tidak_tahu. |

Fixture logika adalah jawaban sintetis. Uji terminal di dalam PLUnit menggunakan stream teks, termasuk memaksa backtracking atas evaluasi: satu G05 hanya ditanyakan sekali dan penanda sisa input tidak ikut terbaca.

## Pemeriksaan proses terminal

Dua proses CLI terpisah dijalankan ulang setelah revisi bahasa dengan perintah aplikasi di README:

1. G01-G03 ya, kemudian jawaban tidak untuk G04, G05, G07, G10, G12, G13, G14; menu selesai. Hasil aktual satu D01 dengan tampilan "Gejala sesuai dengan aturan dugaan ini", jalur R02 -> R01, alasan G01-G03, dan saran S01. Exit code 0, stderr kosong.
2. Urutan sama, tetapi G03 tidak_tahu. D01 menampilkan "Informasi belum cukup", tetap membawa jalur R02 -> R01, dan menyebut G03 sebagai informasi yang belum tersedia. Tidak ada saran S01 sebagai hasil diagnosis. Sesi selesai, bukan terputus. Exit code 0, stderr kosong.

Pengujian EOF, reset, serta backtracking tetap dijalankan dalam suite otomatis. Versi sebelum revisi bahasa memiliki 46 pengujian; versi ini mempertahankan seluruhnya dan menambah dua pengujian tampilan tanpa melemahkan pemeriksaan perilaku.

Contoh potongan keluaran aktual ada di [README](../README.md#contoh-sesi-aktual).

## Koreksi selama pengembangan

Pemeriksaan pemuatan awal menemukan penanda komentar bersarang yang tidak disengaja pada komentar lokasi dokumen pengetahuan. Komentar diperbaiki sebelum pengujian suite. Seluruh pengujian perilaku pada suite akhir lulus; tidak ada kegagalan yang dibiarkan terbuka.

## Batas hasil

Hasil ini menunjukkan konsistensi perilaku prototipe terhadap spesifikasi. Belum ada pengujian diagnosis pada perangkat nyata, wawancara/validasi teknisi, pengukuran akurasi, maupun jaminan lintas merek/model. **Seluruh pengetahuan tetap draf.** Materi PPTX/PDF asli tidak diedit.

## Eksekusi ulang saat persiapan GitHub

Pada **22 Oktober 2026**, perintah `swipl -q -s tests/main_tests.pl -g run_tests -t halt` dijalankan ulang di Windows dengan **SWI-Prolog 10.0.2 for x64-win64**. Hasil aktual: **48/48 lulus, 0 gagal, exit code 0**. Tidak ada perubahan pada kode aplikasi, kode tes, atau teks gejala dalam pekerjaan dokumentasi ini. Riwayat eksekusi serta pemeriksaan proses terminal di bagian sebelumnya tetap dipertahankan.

Repository lokal baru dibuat pada branch `main` dan belum mempunyai commit saat pengujian ini, sehingga belum ada SHA commit yang diuji. Git yang tersedia: **2.47.0.windows.2**; VS Code yang terdeteksi: **1.142.0 x64**. Pemeriksaan daftar izin dan indeks dicatat di [persiapan GitHub](../docs/persiapan_github.md). Pengujian ini tidak menyatakan laporan, slide, video, maupun validasi teknisi telah selesai.
