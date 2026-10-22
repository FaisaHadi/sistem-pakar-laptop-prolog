# Menyiapkan repository untuk dibagikan

Panduan ini untuk terminal PowerShell di VS Code. Pemilik telah menyetujui [FaisaHadi/sistem-pakar-laptop-prolog](https://github.com/FaisaHadi/sistem-pakar-laptop-prolog) dengan visibilitas **private**. Repository sudah dibuat tanpa README otomatis. Isinya tetap tidak boleh memuat password, token, atau data pribadi yang tidak diperlukan. Undangan anggota dilakukan pemilik setelah memastikan akun GitHub yang benar; undangan belum dikirim.

## Berkas yang dibagikan

| Masuk Git | Alasan |
| --- | --- |
| `README.md`, `CONTRIBUTING.md`, `.gitignore` | Orientasi anggota dan aturan kerja |
| `src/main.pl`, `src/knowledge.pl` | Kode yang dibutuhkan untuk menjalankan aplikasi |
| `tests/main_tests.pl`, `tests/skenario_pengujian.md`, `tests/hasil_pengujian.md` | Pengujian, skenario, dan hasil aktual |
| `knowledge/daftar_gejala.md`, `knowledge/aturan_diagnosa.md` | Definisi gejala, aturan, dan saran |
| `docs/rancangan_awal.md`, `docs/referensi.md`, `docs/panduan_git.md`, `docs/persiapan_github.md` | Rancangan, referensi, panduan, dan pemeriksaan aktual |
| `docs/materi/README.md` | Indeks materi dosen, tanpa berkas aslinya |
| `presentation/README.md`, `video/README.md` | Kerangka rencana yang tersedia; bukan slide atau video final |

Daftar izin tidak otomatis menjadikan isi dokumen aman dibagikan: tetap baca diff. Jangan sertakan catatan pribadi atau bukti perangkat yang mengandung data pemilik.

| Tidak masuk Git saat ini | Penanganan |
| --- | --- |
| PPT/PDF materi dosen, termasuk yang tersimpan di akar proyek | Tetap simpan lokal; bagikan melalui kanal kelas yang sesuai |
| ZIP proyek, backup, file sementara, log mentah | Simpan lokal; Git menyimpan riwayat kode |
| `.vscode/`, `.idea/`, konfigurasi Codex lokal | Pengaturan pribadi; tidak diperlukan untuk menjalankan aplikasi |
| `.env`, token, password, private key | Jangan commit; aplikasi saat ini tidak memerlukan kredensial |
| Installer, executable, cache, hasil kompilasi `.qlf` | Dapat dibuat/diunduh ulang |
| Video, rekaman mentah, screenshot, laporan DOCX/PDF, slide PPTX | Di luar cakupan push awal; tambahkan path spesifik nanti bila disepakati |

Kebijakan ini tidak menghapus berkas. `.gitignore` hanya mengatur berkas yang belum dilacak; file yang sudah tracked tetap dapat masuk commit. Mengabaikan file juga tidak menghapusnya dari riwayat commit.

## 1. Periksa keadaan lokal

Dari akar proyek, jalankan:

```powershell
git --version
git rev-parse --show-toplevel
git status --short
git remote
```

Jika belum merupakan repository, pesan kegagalan `rev-parse` wajar. Setelah memastikan folder yang benar, buat repository:

```powershell
git init -b main
```

Jika sudah merupakan repository, jangan menginisialisasi ulang, mengganti remote, atau mengubah branch tanpa memeriksa keadaan yang ada. Pastikan hasil `--show-toplevel` adalah proyek ini, bukan folder induknya. Jangan membagikan keluaran remote jika URL mengandung token.

Periksa URL remote secara lokal sebelum dipakai; jangan menyalin URL dengan kredensial ke log atau percakapan. `git remote` pada contoh di atas hanya mencetak nama remote. Remote proyek ini bernama `origin`. Git di akun Windows pemilik telah diberi `safe.directory` khusus folder proyek karena metadata dibuat oleh akun sandbox; tidak ada pengecualian wildcard. Jika menemui masalah kepemilikan pada komputer lain, verifikasi lokasi dan asal repository sebelum memberi pengecualian.

## 2. Terapkan dokumentasi dan periksa file

Gabungkan README baru dengan informasi lokal terbaru. Pertahankan ketentuan tugas, referensi, dan pembagian kerja yang sudah benar. Jangan menimpa rancangan atau hasil pengujian yang lebih baru dengan salinan lama.

Setelah `.gitignore` diterapkan:

```powershell
git status --short --untracked-files=all
git ls-files
git ls-files -ci --exclude-standard
git add --dry-run -- .
```

Sesuaikan daftar path dengan folder yang memang ada. Perintah `git ls-files -ci --exclude-standard` menunjukkan file tracked yang kini cocok dengan aturan ignore. Periksa per file. Untuk mengeluarkan file yang tidak boleh dibagikan dari indeks tanpa menghapus file lokal, gunakan `git rm --cached -- "path-yang-sudah-diperiksa"`; gunakan `-r` hanya untuk folder yang memang sudah ditinjau. Jangan memakai `git rm -r --cached .` untuk mereset seluruh indeks.

Jika file rahasia pernah masuk commit, menghapusnya pada commit baru belum membersihkan riwayat. Hentikan push, cabut/ganti kredensial terkait, lalu tangani riwayat sesuai kondisi repository. Untuk materi dosen yang sudah ada pada commit lama, sepakati penanganan riwayat sebelum repository dibagikan; jangan melakukan rewrite atau force push tanpa koordinasi.

Periksa juga riwayat, reflog, dan daftar berkas historis pada repository yang sudah memiliki commit. Pada persiapan ini repository baru memiliki nol commit dan nol objek; tidak ada riwayat lama yang perlu dibersihkan. Daftar izin tidak menggantikan peninjauan isi setiap berkas yang akan dibagikan.

## 3. Tes dan periksa isi commit

```powershell
swipl -q -s tests/main_tests.pl -g run_tests -t halt
$LASTEXITCODE
git add -- README.md CONTRIBUTING.md .gitignore src tests knowledge docs presentation/README.md video/README.md
git diff --cached --name-only
git diff --cached --stat
git diff --cached
git diff --cached --check
```

Perintah staging di atas mencakup kerangka presentasi dan video yang sudah ditinjau. Tahap persiapan awal menggunakan dry-run dengan indeks kosong; setelah nama dan visibilitas disetujui pemilik, 17 path tersebut menjadi daftar commit awal. Jangan menggunakan `git add -f` untuk melewati daftar izin. File yang sebelumnya sudah staged juga harus diperiksa: staging selektif tidak otomatis mengeluarkan file tersebut.

Jika daftar dan isi sudah sesuai:

```powershell
git commit -m "docs: siapkan prototipe dan panduan kolaborasi tim"
```

## 4. Hubungkan ke GitHub

Setelah URL tujuan/pemilik dan visibilitas disepakati, gunakan repository GitHub yang terverifikasi sebagai proyek ini. Jika perlu dibuat baru, pemilik menentukan visibilitasnya dan membuat repository kosong. Jangan menambahkan README, license, atau `.gitignore` melalui GitHub pada saat pembuatan jika semuanya sudah disiapkan secara lokal. Gunakan URL sebenarnya tanpa menyisipkan token. Jangan membuat repository public berdasarkan asumsi.

Jika belum ada remote `origin`, ganti placeholder pada baris berikut:

```powershell
git remote add origin https://github.com/FaisaHadi/sistem-pakar-laptop-prolog.git
git remote get-url origin
git branch --show-current
git push -u origin main
```

Perintah push di atas berlaku setelah commit awal dibuat, branch saat ini `main`, dan repository GitHub tujuan telah dipastikan kosong. URL yang dicetak `get-url` diperiksa lokal saja dan tidak boleh memuat token. Jika `origin` sudah ada, periksa tujuan dan gunakan yang benar; jangan menimpanya otomatis. Jika remote sudah berisi commit, periksa riwayat dan integrasikan dengan alur branch/pull request yang disepakati. Jangan melakukan force push untuk mengatasi penolakan.

Setelah push, periksa daftar file di GitHub dan tambahkan akun anggota melalui pengaturan akses. Undangan dilakukan oleh pemilik setelah identitas akun dipastikan.

## 5. Cara anggota menjalankan

Anggota menerima akses repository dari pemilik, lalu menjalankan:

```powershell
git clone https://github.com/FaisaHadi/sistem-pakar-laptop-prolog.git
cd sistem-pakar-laptop-prolog
code .
swipl --version
swipl -q -s tests/main_tests.pl -g run_tests -t halt
swipl -q -s src/main.pl -g main -t halt
```

Jika `code` tidak dikenali, buka folder hasil clone melalui menu Open Folder di VS Code. File materi dosen tidak dibutuhkan untuk menjalankan aplikasi; gunakan indeks materi untuk membacanya secara terpisah.

## Saat menambah file baru

Daftar izin sengaja hanya membuka dua modul Prolog, satu file tes, dan path dokumentasi yang saat ini ditinjau. Modul, tes, Markdown, aset, atau folder baru harus ditambahkan ke `.gitignore` secara eksplisit. Periksa penyebab suatu path diabaikan dengan `git check-ignore -v --no-index -- "path-berkas"`, lalu ulangi dry-run dan tinjau diff. Jangan mengganti kebijakan ini dengan mengizinkan seluruh folder proyek. Daftar konkret hasil pemeriksaan ada pada [persiapan GitHub](persiapan_github.md).

Rujukan perilaku Git: [gitignore](https://git-scm.com/docs/gitignore), [git add](https://git-scm.com/docs/git-add), dan [panduan GitHub untuk kode lokal](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github).
