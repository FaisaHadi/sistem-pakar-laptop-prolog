# Rancangan awal sistem

Status: **spesifikasi prototipe, 22 Oktober 2026**. Kontrak berikut diperjelas sebelum implementasi. Kesiapan perangkat lunak dinilai melalui pengujian otomatis; seluruh pengetahuan tetap **draf / belum divalidasi teknisi**. Dasar pembelajaran: M01 tentang akuisisi pengetahuan, M02 slide 37–40 tentang backward chaining, serta M03 tentang fakta, aturan, dan penjelasan sistem pakar. Lihat [referensi](referensi.md).

## Persoalan dan batas solusi

Pengguna memasukkan pengamatan mengenai satu kejadian gangguan laptop. Sistem mencoba membuktikan lima hipotesis D01–D05 melalui aturan R01–R11. Hasil berarti pola gejala sesuai dengan aturan draf. Hasil tidak menetapkan komponen yang harus diganti.

Diagnosis awal memerlukan bukti pembeda. Karena itu, sebagian pertanyaan menanyakan hasil BIOS atau pemeriksaan resmi produsen yang **sudah tersedia**. Pengguna boleh menjawab `tidak_tahu` bila pemeriksaan tidak tersedia. Cakupan ini lebih sempit untuk pengguna yang hanya mengetahui keluhan umum; kondisi tersebut ditangani sebagai bukti belum cukup.

## Komponen dan representasi

| Komponen | Rencana tanggung jawab |
| --- | --- |
| Basis pengetahuan tetap | Metadata gejala G01–G15, gangguan D01–D05, saran S01–S05, dan metadata aturan R01–R11. |
| Fakta sesi | Pasangan ID gejala dan jawaban `ya` / `tidak` / `tidak_tahu`. Tidak dicampurkan dengan kebenaran aturan permanen. |
| Mesin inferensi | Klausa Prolog untuk membuktikan hipotesis dan indikasi antara I01–I02 secara backward chaining. |
| Antarmuka terminal | Meminta jawaban gejala saat dibutuhkan, memvalidasi input, dan menampilkan hasil dalam bahasa Indonesia. |
| Penjelasan | Mengembalikan ID aturan dan gejala pendukung dari cabang pembuktian yang berhasil, termasuk aturan antara. |

Pengetahuan disimpan sebagai fakta `gejala/4` (ID, label, pertanyaan, bantuan pengguna), `gangguan/2`, `indikasi/2`, `saran/3` (gangguan, ID saran, teks), `aturan/3` (ID, kesimpulan, daftar premis AND), dan `aturan_info/3` (ID, sumber, status). Mesin Prolog membuktikan tujuan secara rekursif melalui fakta aturan tersebut. Pilihan representasi aturan sebagai data menggantikan rencana klausa diagnosis terpisah: satu tabel aturan menjadi sumber evaluasi dan penjelasan, sehingga status tiga nilai tidak tersembunyi di balik berhasil/gagal predikat.

API evaluasi: `evaluasi(Tujuan, Mode, Hasil)` dan `evaluasi_semua(Mode, HasilGangguan)`. Mode `tersimpan` tidak bertanya atau mengubah sesi; mode `tanya(Input, Output)` mengumpulkan jawaban sesuai tujuan yang diperlukan. Data jawaban berupa `jawaban/2`. Hasil menggunakan kontrak di bawah ini.

ID tampil sebagai G01, D01, I01, R01, S01 dalam dokumen. Atom Prolog memakai huruf kecil, misalnya `g01` dan `d01`; variabel memakai huruf awal kapital atau garis bawah. Penamaan mengikuti bagian Prolog M03 slide 22 dan 30, agar notasi FOL dalam materi tidak tertukar dengan sintaks Prolog.

`src/knowledge.pl` menyimpan fakta pengetahuan, sedangkan `src/main.pl` menyimpan aturan mesin backward chaining, pengelolaan sesi, dan terminal. Aplikasi serta pengujian menggunakan Prolog.

## Bahasa konsultasi

Pertanyaan memuat satu kondisi utama dan diikuti bantuan pengguna. Bantuan selalu tampil, termasuk syarat bukti yang dipindahkan dari pertanyaan panjang. Misalnya, G01 tetap memperhitungkan batas pengisian; G02 memakai informasi BIOS/UEFI; G03 memakai charger pembanding berfungsi dan kompatibel pada laptop/port sama; G11 membutuhkan panduan resmi model; G12/G15 memakai hasil pemeriksaan resmi. Pengguna tidak diminta menjalankan pemeriksaan baru atau menebak jawaban.

BIOS/UEFI dijelaskan sebagai menu pengaturan dasar sebelum sistem operasi berjalan, POST sebagai pemeriksaan awal perangkat saat dinyalakan, RAM sebagai memori kerja sementara, dan SSD/HDD sebagai penyimpanan sistem serta berkas. Sapaan pengguna memakai "Anda". Catatan definisi operasional, sumber, batas model, dan validasi tetap berada di `knowledge/daftar_gejala.md`; argumen keempat `gejala/4` hanya memuat bantuan pengguna.

| Atom status internal (tetap) | Teks terminal |
| --- | --- |
| `didukung` | Gejala sesuai dengan aturan dugaan ini |
| `belum_lengkap` | Informasi belum cukup |
| `tidak_terpenuhi` | Jawaban belum mendukung dugaan ini |

Keadaan `belum_ditanya` ditampilkan sebagai "belum ditanyakan" dan jawaban `tidak_tahu` sebagai "Anda memilih tidak_tahu" pada informasi yang kurang. Hanya lapisan tampilan yang menerjemahkan istilah ini. ID dan jejak aturan tetap terlihat untuk demo.

## Kontrak hasil evaluasi dan sesi

Daun pembuktian adalah `gejala(ID, Keadaan, Status)`. Keadaan `ya` menghasilkan `didukung`, `tidak` menghasilkan `tidak_terpenuhi`, dan `tidak_tahu` atau `belum_ditanya` menghasilkan `belum_lengkap`. `belum_ditanya` berarti fakta jawaban belum ada; bukan jawaban pengguna dan tidak disimpan sebagai `jawaban/2`.

Tujuan diagnosis atau indikasi menghasilkan `hasil(ID, Status, Jalur, Kurang)`. Setiap alternatif tetap tersimpan sebagai `jalur(IDAturan, Status, JejakPremis, KurangJalur)`. Jejak premis berisi daun gejala atau hasil indikasi secara rekursif, sehingga R02 mempertahankan hasil I01/R01, termasuk gejala yang belum diketahui. ID aturan tidak diratakan dengan menghapus batas alternatif.

| Tingkat | Kontrak status |
| --- | --- |
| AND dalam satu jalur | Jika ada premis `tidak_terpenuhi`, jalur `tidak_terpenuhi`. Jika tidak ada yang demikian tetapi ada `belum_lengkap`, jalur `belum_lengkap`. Semua premis `didukung` menghasilkan jalur `didukung`. |
| OR antarjalur | Setidaknya satu jalur `didukung` mendukung tujuan. Tanpa jalur didukung tetapi ada `belum_lengkap`, tujuan `belum_lengkap`. Jika seluruh jalur `tidak_terpenuhi`, tujuan `tidak_terpenuhi`. Semua jalur tetap dievaluasi walau satu sudah mendukung. |
| Kurang pada jalur | Daftar unik `kurang(IDGejala, tidak_tahu)` atau `kurang(IDGejala, belum_ditanya)` dari seluruh jejak turunannya. Pada jalur yang gugur, ini hanya catatan bukti yang belum tersedia, bukan syarat yang jika dilengkapi akan mengatasi premis tidak. |
| Kurang pada tujuan | Jika tujuan `belum_lengkap`, gabungkan kekurangan dari jalur yang masih `belum_lengkap` saja. Jika didukung atau semua jalur gugur, daftar ini kosong; kekurangan alternatif tetap dapat dibaca pada masing-masing jejak jalur. |

Terminal dapat berhenti menanyakan sisa premis AND sesudah menemukan premis tidak; sisa premis tetap direkam dari fakta yang tersedia dalam mode `tersimpan`. Sesudah seluruh alternatif/hipotesis ditelusuri, hasil dibangun ulang dari jawaban sesi tanpa pertanyaan tambahan, supaya jejak awal tidak tertinggal `belum_ditanya` jika gejala itu kemudian ditanyakan oleh jalur lain. Sesudah `tidak_tahu`, penelusuran premis lain tetap berjalan: T27 harus gugur bila G02 ternyata tidak.

Keadaan sesi dipisahkan dari status bukti: `aktif`, `selesai`, atau `terputus(IDGejala)`. EOF langsung menghentikan pertanyaan lewat penanganan interupsi, tanpa mengisi jawaban untuk gejala tersebut. Gejala itu tetap `belum_ditanya`, sementara status sesi mencatat interupsi. Hasil konsultasi berupa `selesai(HasilGangguan)` atau `belum_selesai(IDGejala, HasilSementara)`. Hasil sementara dihitung tanpa pertanyaan tambahan dan tidak dicetak sebagai kesimpulan akhir.

Sesi baru menghapus jawaban, hasil konsultasi tersimpan, dan status sesi sebelumnya. Indikasi serta jejak dihitung sebagai nilai hasil, bukan fakta turunan global yang dapat bocor ke sesi baru. Jawaban valid tidak diulang atau diubah saat backtracking. Evaluasi `tersimpan` adalah cuplikan saat dipanggil, bukan objek yang otomatis berubah jika jawaban ditambahkan kemudian.

## Alur konsultasi prototipe

1. Mulai sesi baru dan kosongkan jawaban serta hasil sesi sebelumnya. Tampilkan lingkup diagnosis awal dan petunjuk jawaban.
2. Ambil hipotesis D01 sampai D05 dalam urutan ID. Urutan ini hanya mengatur penelusuran yang dapat diulang, bukan tingkat kemungkinan gangguan.
3. Cari aturan yang kesimpulannya sesuai hipotesis. Periksa premis dari kiri ke kanan; untuk premis indikasi, buktikan aturan indikasi itu terlebih dahulu.
4. Untuk premis gejala, gunakan jawaban tersimpan. Jika belum ada, tanyakan gejalanya. Simpan jawaban valid satu kali per sesi.
5. Semua premis harus `ya` agar cabang aturan berhasil. Jika premis `tidak`, hentikan cabang tersebut dan coba aturan alternatif. Jika `tidak_tahu`, catat bukti belum tersedia tanpa menganggapnya `tidak`; periksa premis lainnya untuk membedakan jalur belum lengkap dari jalur yang memiliki premis tidak, lalu coba alternatif.
6. Setelah seluruh hipotesis diperiksa, bangun ulang jejak dari fakta sesi tanpa pertanyaan tambahan. Gabungkan hasil yang memiliki ID gangguan sama dan pertahankan semua jejak, baik didukung, belum lengkap, maupun tidak terpenuhi. Jangan berhenti pada dugaan pertama.
7. Tampilkan dugaan, alasan dari gejala yang dijawab `ya`, jalur aturan, saran, dan status validasinya. Sertakan kekurangan bukti pada hipotesis lain bila relevan. Akhiri sesi atau mulai sesi baru dengan data kosong.

`tidak` berarti pengguna menyatakan kondisi tidak terjadi dalam konteks pertanyaan. `tidak_tahu` berarti kondisi belum dapat dinilai. Kegagalan membuktikan `gejala_ya` tidak boleh otomatis dicatat sebagai fakta bahwa gejalanya tidak ada. Untuk rancangan ini semua premis diagnosis bersifat positif; belum diperlukan negasi sebagai kegagalan untuk menyimpulkan keadaan perangkat.

Status sebuah jalur dibedakan menjadi **didukung** (seluruh premis ya), **belum lengkap** (tanpa premis tidak, masih ada jawaban tidak diketahui/belum ditanya), dan **tidak terpenuhi** (setidaknya satu premis tidak). Status hipotesis didukung jika ada jalur berhasil; jika tidak ada yang berhasil tetapi ada jalur belum lengkap, laporkan bukti kurang. Jika semua jalurnya tidak terpenuhi, laporkan belum didukung aturan yang tersedia, tanpa menyatakan perangkat sehat.

Input di luar tiga pilihan ditanya ulang tanpa disimpan. Pertanyaan memakai pembacaan baris teks; pengguna tidak perlu memasukkan term Prolog atau tanda titik. Jika input berakhir (EOF), akhiri sesi dengan keterangan konsultasi belum selesai. Jawaban tidak diubah di tengah sesi awal ini; koreksi dilakukan dengan memulai sesi baru agar jejak tetap konsisten.

Jika lebih dari satu gangguan didukung, tampilkan semuanya sebagai dugaan yang dapat berdampingan. Tidak ada pemeringkatan, persentase, atau pengubahan jumlah gejala menjadi probabilitas. Ketika dua aturan mendukung gangguan sama, tampilkan satu dugaan dengan dua alasan/jalur, bukan dua diagnosis terpisah.

## Contoh backward chaining

Contoh terfokus pada hipotesis **D01**, bukan simulasi seluruh sesi. Anggap jawaban awal belum ada dan pengguna menjawab `ya` untuk G01, G02, dan G03 sesuai konteks definisinya.

```text
Tujuan: buktikan D01
  R02 membutuhkan I01 DAN G03
    Tujuan antara: buktikan I01
      R01 membutuhkan G01 DAN G02
        Tanya G01 (charger semula tidak mengisi) -> ya, simpan
        Tanya G02 (charger semula tidak dikenali BIOS) -> ya, simpan
      I01 terbukti melalui R01
    Tanya G03 (charger pembanding kompatibel memulihkan pengisian) -> ya, simpan
  D01 didukung melalui R02
Jejak penjelasan: R02 -> R01 -> G01, G02; serta G03
```

Pencarian dimulai dari tujuan D01, mundur ke premis R02, lalu ke R01 dan fakta jawaban. Sistem tidak memasukkan seluruh gejala terlebih dahulu untuk memicu aturan ke depan. I01 adalah ringkasan pola pengamatan, bukan diagnosis komponen tambahan.

Potongan hasil aktual untuk G01-G03 ya:

```text
D01 - Gangguan charger atau kabel dayanya: Gejala sesuai dengan aturan dugaan ini
  Jalur R02 -> R01: Gejala sesuai dengan aturan dugaan ini
  Alasan berdasarkan jawaban ya:
    G01 - Baterai tidak terisi dengan charger semula.
    G02 - Charger semula tidak dikenali BIOS/UEFI.
    G03 - Pengisian normal dengan charger pembanding.
Saran S01 (DRAF): Anda dapat mencocokkan spesifikasi charger dengan panduan resmi model laptop Anda. Mintalah teknisi memeriksa charger atau kabel semula sebelum Anda menggantinya.
```

Potongan hasil aktual ketika G03 dijawab `tidak_tahu`, dengan G01-G02 tetap ya:

```text
D01 - Gangguan charger atau kabel dayanya: Informasi belum cukup
  Jalur R02 -> R01: Informasi belum cukup
  Informasi yang belum tersedia pada jalur ini: G03 - Pengisian normal dengan charger pembanding (Anda memilih tidak_tahu).
Informasi yang belum tersedia untuk dugaan ini: G03 - Pengisian normal dengan charger pembanding (Anda memilih tidak_tahu).
```

Jika G03 dijawab `tidak`, R02 tidak terpenuhi dan D01 belum didukung, meskipun I01 terbukti. Jika G03 `tidak_tahu`, jalur D01 belum lengkap dan sistem menyebut G03 sebagai bukti yang kurang. Dalam kedua keadaan tersebut, jangan mencetak D01 sebagai dugaan yang berhasil dibuktikan. Pemeriksaan D02–D05 tetap dilanjutkan.

## Peninjauan pengetahuan setelah implementasi prototipe

- Pastikan gejala dapat dipahami pengguna tanpa menebak arti kode BIOS atau hasil diagnostik.
- Tinjau apakah kombinasi premis dan saran setiap aturan cukup untuk dugaan awal; status seluruh aturan saat ini masih draf.
- Tentukan model laptop sasaran untuk contoh demo. Tabel kode lintas merek belum disediakan.
- Periksa [skenario pengujian](../tests/skenario_pengujian.md) dan [hasil pengujian aktual](../tests/hasil_pengujian.md). Lulusnya pengujian perangkat lunak tidak menggantikan validasi pengetahuan oleh teknisi.
