# Sistem Pakar Diagnosa Awal Kerusakan Laptop

Proyek tugas besar kelompok mata kuliah Kecerdasan Buatan. Aplikasi terminal menggunakan **SWI-Prolog**, fakta dan aturan, serta **backward chaining** untuk mencocokkan jawaban pengguna dengan dugaan gangguan laptop. Hasil memuat status, jalur aturan, alasan, informasi yang kurang, dan saran untuk dugaan yang didukung.

**Status per 22 Oktober 2026: prototipe terminal sudah diimplementasikan dan bahasa konsultasi sudah direvisi. Seluruh pengetahuan masih DRAF, belum divalidasi teknisi atau diuji sebagai diagnosis pada perangkat nyata.** Hasil program bukan diagnosis final dan tidak memakai persentase kepastian.

## Untuk anggota yang baru bergabung

1. Baca status dan batas cakupan di bawah.
2. Pasang Git dan SWI-Prolog, lalu clone repository melalui URL yang dibagikan pemilik.
3. Buka folder hasil clone di VS Code dan jalankan aplikasi serta tes dari akar proyek.
4. Baca dokumen pengetahuan dan rancangan sebelum mengubah kode.
5. Ikuti [panduan kontribusi](CONTRIBUTING.md) dan [panduan Git](docs/panduan_git.md).

## Kondisi proyek saat ini

| Bagian | Kondisi |
| --- | --- |
| Aplikasi | Konsultasi melalui terminal; belum ada antarmuka web atau desktop |
| Basis pengetahuan | 15 gejala G01–G15, 5 gangguan D01–D05, 2 indikasi I01–I02, 11 aturan R01–R11, 5 saran S01–S05 |
| Penalaran | Backward chaining; memeriksa aturan alternatif dan mempertahankan jalur bukti |
| Jawaban | `ya`, `tidak`, `tidak_tahu`; disimpan dalam memori selama satu sesi |
| Sesi | Input invalid ditanya ulang, jawaban digunakan kembali, sesi baru mereset data, EOF saat pertanyaan menandai sesi terputus |
| Bahasa | Pertanyaan dan bantuan pengguna disinkronkan dengan dokumentasi; catatan teknis dipisahkan |
| Pengujian | Dijalankan ulang saat persiapan Git pada 22 Oktober 2026: 48/48 lulus, exit code 0, SWI-Prolog 10.0.2 for x64-win64 |
| Validasi pengetahuan | Belum dilakukan oleh teknisi; sumber khusus model laptop masih perlu dilengkapi |
| Luaran tugas | Kerangka slide dan video tersedia; laporan akhir, slide final, dan rekaman belum dinyatakan selesai. Pembagian anggota dan jadwal kalender belum ditetapkan |

Angka di atas berasal dari eksekusi ulang aktual pada komputer lokal saat penyiapan dokumentasi Git. Riwayat sebelumnya dipertahankan dalam [hasil pengujian](tests/hasil_pengujian.md). Pada eksekusi ini belum ada commit, sehingga tidak ada SHA commit yang dapat dicatat. Jalankan tes lagi di komputer masing-masing; kelulusan tes tidak membuktikan ketepatan diagnosis perangkat nyata.

## Ketentuan dosen dan keputusan proyek

Rincian ini mengikuti M04 halaman 1 dan M03 slide 54. Identitas berkas, bagian materi, dan riwayat pembacaan tercatat pada [indeks materi](docs/materi/README.md) serta [referensi](docs/referensi.md).

| Asal | Ketentuan atau keputusan |
| --- | --- |
| M04, petunjuk teknis | Kelompok memilih opsi tugas yang berbeda. Jika jumlah kelompok lebih dari empat, opsi boleh sama tetapi persoalan kasus harus berbeda. Koordinasi pilihan dilakukan oleh kelompok di kelas. |
| M04, AI with PROLOG | Mengembangkan sistem cerdas dengan Logic, Rules and Representation melalui logic programming Prolog. Penugasan pertemuan 8, pengumpulan pertemuan 11. |
| M04, rincian 1-4 | Slide menjelaskan unduh/instalasi tools, pengenalan lingkungan kerja, persoalan kasus, dan solusi penyelesaiannya. |
| M04, rincian 5 dan catatan | Demo aplikasi. Semua bagian dikemas menjadi video tutorial, dikumpulkan kepada ketua kelas dan diunggah ke kanal YouTube Artificial Intelligence Siliwangi, playlist Tutorial. |
| M03, slide 54 | Sistem pakar bertema bebas berdasarkan materi AI-6 sampai AI-8; laporan dan program dikumpulkan serta didemokan pada pertemuan ke-11. Laporan tetap dicatat sebagai keluaran sesuai slide ini. |
| Keputusan proyek | Diagnosis awal laptop dengan SWI-Prolog, terminal, fakta/aturan, backward chaining, dugaan beserta alasan dan saran. |
| Target awal kelompok | 5 gangguan, 15 gejala, 2 indikasi antara, 11 aturan, dan 5 saran. Jumlah ini cakupan proyek, bukan syarat jumlah minimum dari dosen. |

Tanggal kalender, format laporan, durasi video, nama anggota, dan penanggung jawab belum tersedia dalam ketentuan yang dibaca. Tim perlu melengkapinya melalui koordinasi, tanpa menganggap prototipe yang lulus tes berarti seluruh luaran tugas sudah selesai.

## Perangkat kerja

| Perangkat | Fungsi |
| --- | --- |
| SWI-Prolog | Menjalankan aplikasi dan pengujian `plunit` |
| VS Code | Mengedit kode dan membuka terminal proyek |
| Ekstensi Codex | Membantu pengerjaan; tidak dibutuhkan oleh aplikasi saat dijalankan |
| Git dan GitHub | Menyimpan riwayat perubahan dan berbagi pekerjaan tim |

Tidak diperlukan Node.js, Python, database, API key, atau akun Codex untuk menjalankan kode Prolog saat ini. Unduh SWI-Prolog dari [situs resminya](https://www.swi-prolog.org/download/stable) dan Git dari [situs Git](https://git-scm.com/downloads). Versi minimum SWI-Prolog belum ditetapkan; catat versi yang benar-benar dipakai saat tes.

Pada terminal PowerShell di VS Code:

```powershell
git --version
swipl --version
```

Jika `swipl` tidak dikenali, pastikan folder `bin` instalasi SWI-Prolog masuk PATH, lalu buka ulang terminal/VS Code. Jangan menyalin installer atau folder instalasi SWI-Prolog ke repository.

Pada komputer persiapan, versi yang diperiksa adalah SWI-Prolog 10.0.2, Git 2.47.0.windows.2, dan VS Code 1.142.0 x64. Tidak ada instalasi atau penggantian dependensi. Buka folder proyek lewat **File > Open Folder** di VS Code, lalu gunakan terminal PowerShell dari akar proyek; pengaturan `.vscode/` pribadi tidak diperlukan dan tidak dibagikan.

## Menjalankan aplikasi dan tes

Jalankan dari folder yang berisi `README.md`, `src/`, dan `tests/`:

```powershell
# Aplikasi terminal
swipl -q -s src/main.pl -g main -t halt

# Seluruh pengujian
swipl -q -s tests/main_tests.pl -g run_tests -t halt
$LASTEXITCODE
```

Ketik jawaban dengan huruf kecil, tanpa tanda titik, lalu tekan Enter. `ya` berarti kondisi sesuai dengan pengamatan atau hasil pemeriksaan; `tidak` berarti sudah dinilai tidak sesuai; `tidak_tahu` berarti belum diperiksa, belum memahami hasil, atau belum yakin. Gunakan satu kejadian gangguan dan baca bantuan setiap pertanyaan. Tidak perlu melakukan pemeriksaan baru selama konsultasi.

Sesudah hasil muncul, ketik `baru` untuk mengosongkan data dan memulai sesi berikutnya, atau `selesai` untuk keluar. Jawaban tidak dapat dikoreksi di tengah sesi; mulai sesi baru jika ada salah input yang sudah diterima. EOF ketika pertanyaan berlangsung mengakhiri sesi sebagai belum selesai, bukan mengisi jawaban otomatis.

## Cakupan dugaan

| ID | Nama dalam aplikasi |
| --- | --- |
| D01 | Gangguan charger atau kabel dayanya |
| D02 | Kondisi baterai menurun atau bermasalah |
| D03 | Masalah pendinginan atau panas berlebih |
| D04 | Masalah pada sistem memori kerja (RAM) |
| D05 | Masalah pengenalan atau kondisi penyimpanan (SSD/HDD) |

Sistem belum mencakup seluruh kerusakan laptop. Sebagian pertanyaan membutuhkan informasi BIOS/UEFI, panduan model, atau hasil alat pemeriksaan resmi yang sudah tersedia. Keluhan umum seperti lambat atau layar hitam tidak otomatis menjadi bukti kerusakan komponen.

## Cara penalaran bekerja

`src/knowledge.pl` menyimpan metadata dan aturan sebagai data, misalnya:

```prolog
aturan(r01, i01, [g01, g02]).
aturan(r02, d01, [i01, g03]).
```

Mesin `buktikan` dalam `src/main.pl` mulai dari tujuan D01, menelusuri R02 menuju I01 dan G03, lalu menelusuri R01 menuju G01 dan G02. Jawaban gejala menjadi fakta sesi. Bila G01–G03 dijawab `ya`, I01 lalu D01 didukung. Tampilan `R02 -> R01` menunjukkan urutan penelusuran dari tujuan.

| Status internal | Tampilan | Makna |
| --- | --- | --- |
| `didukung` | Gejala sesuai dengan aturan dugaan ini | Ada setidaknya satu jalur yang seluruh premisnya didukung |
| `belum_lengkap` | Informasi belum cukup | Belum ada jalur didukung, tetapi ada jalur tanpa premis penolak yang buktinya belum lengkap |
| `tidak_terpenuhi` | Jawaban belum mendukung dugaan ini | Seluruh jalur memiliki premis yang tidak terpenuhi |

Pada aturan AND, satu premis tidak terpenuhi menggugurkan jalur meskipun ada jawaban `tidak_tahu`. Pertanyaan lanjutan pada jalur itu dapat dilewati; aturan alternatif tetap diperiksa. `belum_ditanya` berbeda dari jawaban `tidak_tahu`. Jejak dibangun ulang dari jawaban yang terkumpul agar bukti dari aturan alternatif ikut tercermin. Dugaan yang sama ditampilkan sekali dengan jalur-jalurnya. **Tidak ada dugaan yang didukung bukan berarti laptop sehat.**

## Dua skenario demo

Ini simulasi untuk memahami aturan, bukan hasil pemeriksaan laptop nyata. Jawab menurut ID pertanyaan yang muncul; sebagian gejala sengaja tidak ditanyakan.

| Skenario | Jawaban | Hasil harapan D01 |
| --- | --- | --- |
| Bukti lengkap | G01, G02, G03 = `ya`; pertanyaan lain = `tidak` | Didukung melalui R02 → R01; alasan G01–G03 dan saran S01 |
| Bukti belum lengkap | G01, G02 = `ya`; G03 = `tidak_tahu`; pertanyaan lain = `tidak` | Informasi belum cukup; kekurangan G03; tanpa saran S01 |

## Contoh sesi aktual

Potongan keluaran berikut dicatat saat pemeriksaan terminal pada revisi bahasa tanggal 22 Oktober 2026. Kode dan teks gejala tersebut tidak diubah dalam persiapan Git ini. Urutan jawaban sesi pertama: G01-G03 `ya`, lalu `tidak` untuk G04, G05, G07, G10, G12, G13, G14; setelah hasil pilih `selesai`.

```text
D01 - Gangguan charger atau kabel dayanya: Gejala sesuai dengan aturan dugaan ini
  Jalur R02 -> R01: Gejala sesuai dengan aturan dugaan ini
  Alasan berdasarkan jawaban ya:
    G01 - Baterai tidak terisi dengan charger semula.
    G02 - Charger semula tidak dikenali BIOS/UEFI.
    G03 - Pengisian normal dengan charger pembanding.
Saran S01 (DRAF): Anda dapat mencocokkan spesifikasi charger dengan panduan resmi model laptop Anda. Mintalah teknisi memeriksa charger atau kabel semula sebelum Anda menggantinya.
```

Pada sesi kedua hanya G03 diubah menjadi `tidak_tahu`:

```text
D01 - Gangguan charger atau kabel dayanya: Informasi belum cukup
  Jalur R02 -> R01: Informasi belum cukup
  Informasi yang belum tersedia pada jalur ini: G03 - Pengisian normal dengan charger pembanding (Anda memilih tidak_tahu).
Informasi yang belum tersedia untuk dugaan ini: G03 - Pengisian normal dengan charger pembanding (Anda memilih tidak_tahu).
```

Kedua sesi selesai. Jawaban `tidak_tahu` berbeda dari belum ditanyakan atau sesi yang terputus karena EOF. Riwayatnya tersimpan dalam [hasil pengujian](tests/hasil_pengujian.md); dua skenario bahasa ini juga termasuk suite 48 tes yang dijalankan ulang saat persiapan Git.

## Peta berkas dan urutan baca

| Berkas | Peran |
| --- | --- |
| `src/main.pl` | Mesin inferensi, input, sesi, dan tampilan hasil |
| `src/knowledge.pl` | Gejala, gangguan, indikasi, aturan, sumber aturan, serta saran |
| `knowledge/daftar_gejala.md` | Pertanyaan, bantuan pengguna, definisi teknis, dan batas bukti |
| `knowledge/aturan_diagnosa.md` | Aturan, nama hasil, saran, serta batas interpretasi |
| `docs/rancangan_awal.md` | Rancangan dan kontrak evaluasi; harus mengikuti implementasi terbaru |
| `docs/referensi.md` | Sumber pengetahuan dan bagian yang masih perlu dilengkapi |
| `CONTRIBUTING.md`, `docs/panduan_git.md` | Alur branch, review, pemeriksaan indeks, dan publikasi oleh pemilik |
| `docs/persiapan_github.md` | Pemeriksaan aktual Git, daftar berkas yang dibagikan/dikecualikan, dan langkah yang masih tertunda |
| `tests/main_tests.pl` | Tes otomatis |
| `tests/skenario_pengujian.md` | Skenario dan hasil harapan |
| `tests/hasil_pengujian.md` | Catatan eksekusi aktual |
| `docs/materi/README.md` | Indeks materi perkuliahan; berkas asli dibagikan terpisah |
| `presentation/README.md`, `video/README.md` | Kerangka luaran yang tersedia; belum ada slide final atau rekaman |

Baca gejala dan aturan sebelum mengubah pengetahuan, lalu rancangan dan tes sebelum mengubah mesin inferensi. Materi asli dosen disimpan lokal dan dibagikan melalui kanal kelas yang sesuai; berkas PPT/PDF tersebut tidak ikut clone dan tidak dibutuhkan saat menjalankan aplikasi.

## Repository dan akses tim

Repository tim: [FaisaHadi/sistem-pakar-laptop-prolog](https://github.com/FaisaHadi/sistem-pakar-laptop-prolog), dengan visibilitas **private** yang telah disetujui pemilik. Branch utama `main`; remote lokal `origin` mengarah ke repository ini. Daftar izin `.gitignore` dibatasi ke 17 path sumber, tes, dan dokumentasi yang sudah ditinjau. Berkas baru memerlukan penambahan izin secara sengaja. [Hasil persiapan Git](docs/persiapan_github.md) mempertahankan catatan keadaan awal sebelum commit.

Anggota memerlukan akses dari pemilik karena repository private. Akun anggota belum ditentukan dan undangan belum dikirim. Setelah akses tersedia:

```powershell
git clone https://github.com/FaisaHadi/sistem-pakar-laptop-prolog.git
cd sistem-pakar-laptop-prolog
code .
swipl -q -s tests/main_tests.pl -g run_tests -t halt
swipl -q -s src/main.pl -g main -t halt
```

## Pekerjaan berikutnya

- Semua anggota mencoba dua skenario demo dan menjelaskan alur pembuktiannya.
- Lengkapi sumber khusus model serta lakukan peninjauan teknisi; catat hasil apa adanya.
- Konfirmasi pembagian tugas, ketentuan pengumpulan, dan kesiapan laporan, slide, serta video.
- Pertahankan sinkronisasi dokumentasi dan kode setiap kali ada perubahan.

Untuk berbagi kode, gunakan daftar berkas yang diizinkan dalam `.gitignore` dan periksa isi commit sesuai [panduan Git](docs/panduan_git.md). Materi PPT/PDF dosen, installer, ZIP sementara, video mentah, konfigurasi pribadi, dan kredensial tidak termasuk paket sumber yang diunggah saat ini.
