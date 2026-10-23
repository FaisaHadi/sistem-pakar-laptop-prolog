# Hasil pengujian aktual prototipe

## Penyempurnaan sistem pakar, 23 Oktober 2026

Dasar checkout tetap `alpha-v-1.0`, commit `4537317`; perubahan lokal belum di-commit. Windows, SWI-Prolog 10.0.2 for x64-win64. Seluruh pengetahuan tetap draf dan dataset kasus nyata masih kosong.

```powershell
swipl -q -s tests/main_tests.pl -s tests/web_tests.pl -s tests/knowledge_tests.pl -g run_tests -t halt
```

Hasil aktual: **131/131 lulus, 0 gagal, exit code 0**, tanpa peringatan choicepoint. Rinciannya: 48 mesin/CLI, 42 HTTP/API, 4 siklus server, 20 integritas pengetahuan, 9 penalaran/cakupan, dan 8 pembanding kasus. Dua tes penalaran mencakup 320 kombinasi status/bukti dan 135 konsultasi adaptif terarah; ini bukan seluruh kombinasi 15 gejala sekaligus atau pengukuran akurasi perangkat nyata.

| Pemeriksaan | Hasil |
| --- | --- |
| Bukti langsung | G05 saja mendukung D02/R12; G09 saja mendukung D03/R13; G15 saja mendukung D05/R14. Bukti unknown tidak dibuat positif. |
| Struktur pengetahuan | Pengetahuan produksi valid; mutasi salinan yang berisi siklus, ID berulang, referensi tidak dikenal, metadata/batas/saran hilang, serta status tervalidasi yang belum didukung ditolak. |
| Penjelasan | Seluruh 14 aturan memiliki premis/kesimpulan, sumber, status draf, dan batas. API serta CLI memakai pembentuk penjelasan yang sama. |
| Cakupan | API menerima merek/model dan mempertahankan konteks sampai hasil; merek tanpa sumber khusus diberi peringatan. `model_verified` tetap false. Konteks invalid ditolak HTTP 400. |
| Dataset kasus | Pembanding atas dataset produksi menghasilkan `case_count: 0`, `status: belum_ada_kasus`, dan `exact_match_rate: null`. Tes pembanding memakai data sintetis terpisah. |
| Pemeriksaan tambahan | `node --check web/app.js`, validator mandiri, dan `git diff --check` lulus. |

Browser diperiksa langsung melalui browser dalam aplikasi pada port pengujian 18766. Formulir merek/model berfungsi; konsultasi Lenovo dengan hanya G05 positif menghasilkan D02. Konsultasi ASUS menampilkan peringatan rujukan khusus belum tersedia; hanya G15 positif menghasilkan D05 melalui aturan draf. Rincian pertanyaan/hasil memperlihatkan sumber, batas, serta status draf. Jalur didukung tampil lebih dahulu. Koreksi G01 dari tidak menjadi ya menelusuri ulang ke G02; mengganti perangkat mengosongkan jawaban dan hitungan. Konsultasi HP dengan hanya G15 positif juga menghasilkan D05. Ini pemeriksaan desktop, bukan klaim runner browser otomatis atau uji perangkat seluler.

Tampilan peringatan pada ringkasan hasil diperbaiki agar terbaca pada latar terang dan dikonfirmasi lewat tangkapan layar. Server pengujian dihentikan dengan sekali Ctrl+C, menampilkan `Server dihentikan.` dan keluar dengan kode 0. Catatan pengujian sebelumnya dipertahankan sebagai riwayat di bawah; harapan lama yang berbeda digantikan oleh kontrak R12–R14 saat ini.

## Ctrl+C, 23 Oktober 2026

Suite gabungan setelah penambahan handler SIGINT: **83/83 lulus, 0 gagal, exit code 0** (48 mesin/CLI, 31 HTTP/API, dan 4 siklus server). Handler SIGINT sebelumnya dipulihkan setelah server selesai atau gagal mulai. Implementasi memakai [`on_signal/3`](https://www.swi-prolog.org/pldoc/man?section=signal) untuk mengubah Ctrl+C menjadi exception yang ditangani setelah listener ditutup.

Uji langsung di terminal interaktif Windows dengan `swipl -q -s src/web_app.pl -g server -t halt`: sekali Ctrl+C menghasilkan `Server dihentikan.` dan proses keluar dengan kode 0, tanpa menu interupsi. Perintah `stop` dan EOF tetap tersedia.

## Penghentian server, 23 Oktober 2026

Suite gabungan dijalankan kembali setelah penambahan perintah terminal `stop`: **82/82 lulus, 0 gagal, exit code 0** (48 mesin/CLI, 31 HTTP/API, dan 3 penghentian server). Tes baru memeriksa listener sudah ditutup setelah `stop`, EOF, dan input lain yang diikuti `stop`.

Uji terminal interaktif memakai `swipl -q -s src/web_app.pl -g server -t halt`: endpoint `/api/questions` mengembalikan 15 gejala, lalu `stop` dan Enter menghasilkan pesan `Server dihentikan.` serta proses keluar dengan kode 0. Catatan pengujian sebelumnya dipertahankan di bawah.

## Pembaruan web, 23 Oktober 2026

Dasar checkout: `alpha-v-1.0`, commit `4537317`; perbaikan lokal belum di-commit. Lingkungan Windows, SWI-Prolog 10.0.2 for x64-win64.

```powershell
swipl -q -s tests/main_tests.pl -s tests/web_tests.pl -g run_tests -t halt
```

Hasil aktual: **79/79 lulus, 0 gagal, exit code 0**. Terdiri dari seluruh 48 tes mesin/CLI sebelumnya dan 31 tes HTTP/API. Server pengujian HTTP memakai port kosong otomatis dan dihentikan oleh cleanup suite. Pemeriksaan sintaks `web/app.js` menggunakan `node --check` juga lulus; Node bukan dependensi untuk menjalankan aplikasi.

| Pemeriksaan | Hasil aktual |
| --- | --- |
| Validasi `/api/diagnose` | List kosong/kurang, payload bukan objek, field hilang, tipe salah, ID/nilai invalid, ID duplikat dan JSON rusak menghasilkan HTTP 400 yang dapat dibaca sebagai JSON. |
| Diagnosis penuh | D01, unknown G03, D03+D04, dan permintaan berikutnya tanpa bukti lama sesuai harapan. Dugaan tidak didukung tidak memuat saran. |
| Awal `/api/consult` | List jawaban kosong valid sebagai awal konsultasi, mengembalikan G01 beserta konteks D01 dan R02 → R01. |
| Pemilihan pertanyaan | G01 tidak melewati G02/G03 menuju G04; G01 tidak_tahu tetap menanyakan G02; alternatif R04 tetap memerlukan G06 setelah R03 gugur. |
| Konsultasi negatif | Urutan G01, G04, G05, G07, G10, G12, G13, G14: selesai setelah 8 jawaban, tidak ada dugaan didukung. |
| Konsultasi D01 | G01–G03 ya dan sisanya tidak: selesai setelah 10 jawaban; D01 didukung dengan R02/R01 dan tepat G01–G03 sebagai bukti. |
| Unknown dan hasil ganda | G03 tidak_tahu menghasilkan D01 belum_lengkap tanpa saran; semua tidak_tahu menanyakan 15 gejala dan seluruh dugaan belum_lengkap; pola G07/G08/G12 mendukung D03+D04. |
| Isolasi dan koreksi | Permintaan baru memakai jawaban yang dikirim saja; hasil positif sebelumnya tidak diwariskan pada konsultasi berikutnya. |

Pemeriksaan langsung melalui browser lokal pada port 8081 mengonfirmasi bantuan G01 selalu terlihat, alasan pertanyaan berisi jalur aturan, navigasi Kembali, koreksi G02 yang mengganti jalur ke G04 dan kembali ke G03 tanpa pilihan lama, hasil D01 dengan detail dilipat/dibuka, Tinjau jawaban yang menghapus bukti lanjutan dan menghitung ulang hasil negatif, serta reset sesi. Server sempat dihentikan dengan satu jawaban dipilih: pesan koneksi tampil, jawaban tetap terpilih, dan Coba lagi melanjutkan ke G04 setelah server dihidupkan. Pintasan angka 3 juga memilih tidak_tahu. Ini pemeriksaan browser langsung, bukan suite UI otomatis atau pengujian perangkat mobile nyata.

Perbaikan awal mendapati kesalahan pada helper tes adaptif: notasi akses dict di dalam assertion dievaluasi sebelum variabel item terikat. Helper diperbaiki menggunakan `get_dict/3`; keenam skenario adaptif kemudian lulus tanpa mengubah hasil harapan.

Pengujian tetap menggunakan skenario sintetis. Tidak ada tambahan wawancara teknisi, pengujian diagnosis perangkat nyata, atau pengukuran akurasi. Seluruh pengetahuan masih draf. Catatan eksekusi 22 Oktober di bawah dipertahankan sebagai riwayat.

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
