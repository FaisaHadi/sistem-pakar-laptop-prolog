# Panduan kontribusi tim

Proyek memakai SWI-Prolog, VS Code, dan Git. Codex dapat membantu menulis atau meninjau perubahan, tetapi anggota tetap perlu memahami kode dan memeriksa hasilnya.

## Alur kerja

Repository tim adalah [FaisaHadi/sistem-pakar-laptop-prolog](https://github.com/FaisaHadi/sistem-pakar-laptop-prolog), bersifat private, dengan branch utama `main`. Anggota perlu memperoleh akses dari pemilik sebelum clone/pull/push. Tinjau daftar berkas pada [hasil persiapan](docs/persiapan_github.md); jangan menjalankan perintah ke URL contoh atau remote lain.

1. Pastikan pekerjaan lokal sudah tersimpan atau di-commit sebelum berpindah branch.
2. Perbarui branch utama sesuai nama default repository. Contoh berikut mengasumsikan `main`:

   ```powershell
   git switch main
   git pull --ff-only
   git switch -c docs/perjelas-panduan-demo
   ```

3. Kerjakan satu perubahan yang jelas per branch. Gunakan awalan `docs/`, `fix/`, atau `feat/` sesuai pekerjaan.
4. Periksa perbedaan dengan `git diff`. Bila kode, pengetahuan, atau teks yang diuji berubah, jalankan tes:

   ```powershell
   swipl -q -s tests/main_tests.pl -s tests/web_tests.pl -s tests/knowledge_tests.pl -g run_tests -t halt
   $LASTEXITCODE
   ```

5. Stage berkas yang memang dikerjakan, kemudian periksa sebelum commit:

   ```powershell
   git add README.md
   git diff --cached --stat
   git diff --cached
   git commit -m "docs: perjelas panduan demo"
   git push -u origin docs/perjelas-panduan-demo
   ```

6. Buat pull request berisi tujuan, perubahan, dan hasil pemeriksaan aktual. Minta anggota lain meninjau sebelum merge. Jika `pull --ff-only` gagal, periksa perbedaan branch bersama tim; jangan memaksa push atau menghapus pekerjaan lokal.

## Hal yang harus dijaga

- Pertahankan ID G01–G15, D01–D05, I01–I02, R01–R14, dan S01–S05 pada revisi bahasa.
- Sinkronkan pertanyaan/bantuan dengan `knowledge/daftar_gejala.md` dan `src/knowledge.pl`; sinkronkan aturan/nama hasil/saran dengan `knowledge/aturan_diagnosa.md`.
- Perubahan makna gejala atau premis aturan harus dijelaskan dan ditinjau tim, beserta sumber dan perubahan skenario uji.
- Jangan menyamakan `tidak_tahu`, `belum_ditanya`, dan sesi terputus. Jangan menghapus pemeriksaan perilaku dalam tes hanya agar tes lulus.
- Pengetahuan tetap draf sampai ada bukti validasi yang dapat dicatat. Tes perangkat lunak tidak menggantikan validasi pengetahuan.
- Jangan menambahkan persentase kepastian tanpa rancangan dan dasar yang disepakati.
- Jangan commit kredensial, percakapan pribadi, data perangkat milik orang lain, atau path komputer pribadi yang tidak diperlukan.
- `.gitignore` memakai daftar izin path spesifik, termasuk untuk Markdown. Saat menambah modul, tes, dokumentasi, atau aset yang diperlukan, tambahkan path secara sengaja dan periksa hasil `git add --dry-run`. Catatan privat dan berkas lokal tidak boleh dibuka izinnya hanya karena ekstensinya Markdown.

## Saat menggunakan Codex

Jelaskan tujuan dan batas perubahan. Minta Codex membaca aturan proyek yang berlaku, kode dan dokumentasi terkait, serta melaporkan hasil tes yang benar-benar dijalankan. Jangan menaruh token atau password di prompt atau berkas. Hindari dua anggota mengubah file yang sama secara bersamaan tanpa koordinasi.

Nama anggota, penanggung jawab bagian, jadwal, dan aturan merge final ditentukan oleh tim; dokumen ini tidak menetapkannya sepihak.

Perubahan pengetahuan harus lolos `src/knowledge_check.pl` dan suite `tests/knowledge_tests.pl`. Aturan baru memerlukan sumber dan batas interpretasi di `src/knowledge_meta.pl`. Ikuti `knowledge/validasi_pakar.md`; contoh sintetis tidak dimasukkan sebagai kasus nyata.
