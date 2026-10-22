# Pemeriksaan persiapan GitHub

Catatan persiapan lokal **22 Oktober 2026**, sebelum commit/publikasi. Ini merekam keadaan pada saat pemeriksaan, bukan status yang otomatis mengikuti perubahan berikutnya.

## Bahan dokumentasi

Lokasi ekstraksi `paket_git_ai` yang ditunjukkan dan ZIP di Downloads diperiksa. Keduanya hanya memuat `PETUNJUK_PENERAPAN.md`; folder `files/` tidak tersedia dalam salinan tersebut. Empat usulan yang disebut petunjuk sudah ada di proyek: `README.md`, `CONTRIBUTING.md`, `.gitignore`, dan `docs/panduan_git.md`. Dokumen lokal itu digabungkan dengan implementasi dan catatan proyek terbaru, tanpa menyalin versi lama di atas kode atau teks pengetahuan.

Tidak ditemukan `AGENTS.md` pada proyek atau direktori induk yang diperiksa. Tidak ada nama anggota, akun GitHub, tenggat kalender, atau bukti validasi teknisi yang ditambahkan.

## Keadaan repository dan riwayat

- Sebelum persiapan: folder proyek bukan repository dan tidak berada dalam repository induk.
- `git init -b main` membuat repository lokal di akar proyek ini.
- Branch: `main`, belum ada commit. Remote: belum ada.
- Hasil `git rev-list --all --count`: **0**. Reflog kosong; `git count-objects -v` menunjukkan **0 objek** dan **0 pack**. Tidak ada riwayat lama atau objek commit yang dapat mengandung materi/rahasia dari proyek ini.
- Berkas tracked dan staged kosong. Tidak ada berkas yang perlu dikeluarkan dari indeks. Tidak dilakukan reset indeks, penghapusan berkas, commit, push, perubahan remote, atau undangan anggota.
- Metadata `.git` dibuat oleh akun sandbox. Penyesuaian pemilik ditolak Windows; Git akun pemilik kemudian diberi pengecualian `safe.directory` hanya untuk path proyek ini, tanpa wildcard. Konfigurasi identitas dan kredensial Git tidak diubah atau ditampilkan.

Riwayat kosong tidak membuktikan seluruh isi berkas bebas dari data privat. Isi kandidat tetap perlu ditinjau sebelum commit; daftar izin hanya membatasi path yang boleh ikut.

## Perangkat dan pengujian aktual

| Pemeriksaan | Hasil |
| --- | --- |
| SWI-Prolog | 10.0.2 for x64-win64 |
| Git | 2.47.0.windows.2 |
| VS Code CLI | 1.142.0 x64; versi berhasil dicetak, dengan peringatan akses Crashpad pada pemanggilan CLI |
| Tes | `swipl -q -s tests/main_tests.pl -g run_tests -t halt` |
| Hasil tes | **48/48 lulus, 0 gagal, exit code 0** |
| Dependensi | Tidak ada instalasi/penggantian dependensi; aplikasi dan tes memakai pustaka bawaan SWI-Prolog |

Riwayat pengujian terdahulu tetap ada di [hasil pengujian](../tests/hasil_pengujian.md). Kode aplikasi, kode tes, ID, aturan, teks gejala, dan materi asli tidak direvisi pada pekerjaan dokumentasi ini. Seluruh pengetahuan tetap draf.

## Daftar izin untuk push awal

Hanya path berikut dibuka oleh `.gitignore`; berkas baru memerlukan izin spesifik dan peninjauan isi. Daftar ini merupakan kandidat commit, belum staged.

| Kandidat masuk Git | Alasan |
| --- | --- |
| `.gitignore` | Kebijakan daftar izin |
| `README.md` | Orientasi, ketentuan tugas, menjalankan dan mengetes |
| `CONTRIBUTING.md` | Alur kerja dan review tim |
| `src/main.pl` | Mesin dan terminal prototipe |
| `src/knowledge.pl` | Pengetahuan draf yang dibutuhkan aplikasi |
| `tests/main_tests.pl` | Pengujian otomatis |
| `tests/skenario_pengujian.md` | Skenario dan harapan hasil |
| `tests/hasil_pengujian.md` | Riwayat hasil aktual |
| `knowledge/daftar_gejala.md` | Pertanyaan, bantuan, catatan teknis |
| `knowledge/aturan_diagnosa.md` | Aturan, interpretasi, dan saran |
| `docs/rancangan_awal.md` | Kontrak evaluasi dan sesi |
| `docs/referensi.md` | Sumber yang benar-benar dipakai dan agenda validasi |
| `docs/panduan_git.md` | Panduan berbagi dan publikasi oleh pemilik |
| `docs/persiapan_github.md` | Catatan pemeriksaan ini |
| `docs/materi/README.md` | Indeks sumber lokal, tanpa materi asli |
| `presentation/README.md` | Kerangka slide, belum slide final |
| `video/README.md` | Kerangka video, belum rekaman |

## Berkas lokal yang dikecualikan

| Path yang ada | Alasan |
| --- | --- |
| `docs/materi/AI-6 Penalaran - Logic, Rules and Representation - I.pptx` | Materi asli dosen, tidak dibagikan lewat repository |
| `docs/materi/AI-7 Penalaran - Logic, Rules and Representation - II.pptx` | Materi asli dosen |
| `docs/materi/AI-8 Penalaran - Logic, Rules and Representation - III.pptx` | Materi asli dosen |
| `docs/materi/xAI-8 Deskripsi Tugas Besar.pdf` | Ketentuan asli dosen; ringkasan dan indeks tetap dibagikan |
| `knowledge_temp_2.zip` | Arsip salinan sementara |
| `temp_1.zip` | Arsip sementara |
| `temp_2.zip` | Arsip sementara |
| `debug.log` | Log lokal, tidak dibutuhkan aplikasi |

Pola pengecualian juga mencakup installer, `.qlf`/output kompilasi, cache, video/slide/laporan biner, `.vscode/`/konfigurasi pribadi, `.env`/kunci privat, dan catatan privat. Direktori metadata `.git/` bukan isi commit. Berkas yang dikecualikan tetap berada di disk.

## Verifikasi daftar dan tautan

Perintah yang dipakai untuk memeriksa kandidat tanpa staging:

```powershell
git add --dry-run -- .
git ls-files --others --exclude-standard
git ls-files --others --ignored --exclude-standard
git ls-files -ci --exclude-standard
git diff --cached --name-status
```

Hasil aktual:

- `git add --dry-run -- .` berhasil dan menampilkan **17 path**, tepat sama dengan daftar izin di atas. Tidak ada staging nyata; tracked dan staged tetap **0**.
- `git ls-files --others --ignored --exclude-standard` menampilkan **8 berkas lokal** pada tabel pengecualian. Tidak ada file tracked yang cocok aturan ignore, sehingga tidak diperlukan `git rm --cached`.
- **22 path virtual** diuji dengan `git check-ignore --no-index`, tanpa membuat file contoh. Kredensial, konfigurasi pribadi, catatan Markdown baru/privat, backup, ZIP, installer, cache, hasil kompilasi, video/slide biner, serta modul/tes baru yang belum diizinkan semuanya diabaikan.
- **27 tautan lokal Markdown** diperiksa: target ada, ikut kandidat Git, dan anchor cocok. Satu anchor lama pada riwayat pengujian diperbaiki dengan memulihkan bagian contoh sesi aktual di README. Tautan ke PPT/PDF yang sengaja tidak ikut clone diubah menjadi nama sumber pada indeks, tanpa menghapus identitas atau rujukan halamannya.
- **11 URL eksternal** diperiksa dengan HTTP HEAD. Lima URL GitHub Docs/Git/SWI-Prolog memberi HTTP 200. Enam URL Dell memberi HTTP 403 dari lingkungan pemeriksaan, sehingga keteraksesannya perlu dicoba melalui browser; hasil ini tidak membuktikan referensinya hilang. URL sumber dipertahankan.
- Peninjauan isi kandidat dan pemeriksaan pola token GitHub, AWS access key, private key, serta penetapan kredensial menghasilkan **0 temuan pola**. Nilai rahasia tidak dicetak. Pemeriksaan pola tidak menjamin semua jenis data privat dapat dikenali.

Tidak ada pemeriksaan identitas GitHub/remote atau riwayat server karena URL tujuan belum tersedia. Daftar ini siap untuk peninjauan pemilik sebelum staging dan commit awal, bukan bukti bahwa publikasi telah dilakukan.

## Langkah publikasi yang masih diperlukan

Pemilik memberikan URL GitHub yang terverifikasi untuk proyek ini dan memilih visibilitas. Setelah tujuan jelas, tinjau isi serta daftar file, stage path yang disetujui, buat commit awal, lalu gunakan remote yang benar. Jika remote memiliki riwayat, periksa dan integrasikan terlebih dahulu. Tidak ada force push atau pembuatan repository public berdasarkan asumsi. Ikuti [panduan Git](panduan_git.md).

Laporan akhir, slide final, rekaman video, penetapan tugas anggota, dan validasi teknisi masih menjadi pekerjaan tim. Pemeriksaan berbagi sumber ini tidak menyatakan seluruh keluaran tugas sudah siap dikumpulkan.

## Persetujuan tujuan dan penyiapan commit awal

Setelah pemeriksaan lokal di atas, pemilik menyetujui nama **sistem-pakar-laptop-prolog** dan visibilitas **private** di akun **FaisaHadi**. Akun autentikasi Git lokal juga diverifikasi sebagai FaisaHadi, tanpa mencetak kredensial. API GitHub berhasil membuat repository kosong dengan respons HTTP 201; metadata nama dan private diperiksa sebelum penyiapan push.

Repository: [FaisaHadi/sistem-pakar-laptop-prolog](https://github.com/FaisaHadi/sistem-pakar-laptop-prolog). Remote `origin` ditambahkan ke `https://github.com/FaisaHadi/sistem-pakar-laptop-prolog.git`; tidak ada remote sebelumnya yang diganti. Publikasi awal menggunakan 17 path yang telah ditinjau, branch `main`, tanpa force push. Catatan nol commit/indeks kosong di bagian sebelumnya adalah keadaan sebelum persetujuan ini, bukan keadaan repository sesudah commit awal.

README dan panduan tim kini memuat URL clone yang benar. Anggota belum diundang; nama akun anggota masih perlu ditentukan pemilik. Hash commit dan kesesuaian branch lokal/remote diperiksa melalui Git setelah unggahan, tanpa mengubah kode atau status draf pengetahuan.
