# Peninjauan pakar dan kasus pembanding

Status 23 Oktober 2026: **BELUM ADA PENINJAUAN TEKNISI ATAU KASUS NYATA BERLABEL**. Pengguna mengonfirmasi kondisi ini. Pemeriksaan dokumen produsen dan kelulusan tes program tidak menggantikan peninjauan tersebut. Seluruh aturan dan saran tetap draf.

## Urutan peninjauan

1. Minta teknisi yang benar-benar terlibat meninjau batas lima dugaan, definisi gejala, dan sumber dalam `src/knowledge_meta.pl`. Catat nama/peran sesuai persetujuannya, tanggal, merek/model, serta versi kode yang ditinjau.
2. Tinjau setiap aturan dan saran. Catat keputusan **terima / revisi / tolak**, alasan, bagian manual yang relevan, serta penyebab alternatif. Peninjauan boleh berbeda menurut model; satu model tidak mewakili seluruh merek.
3. Dahulukan R12–R14 sebagai revisi bukti langsung, lalu R02, R06, R08, dan R10 sebagai pola yang membutuhkan konteks/pembeda lebih lanjut. R03/R04, R07, dan R11 dipertahankan sebagai jalur gabungan; sesudah jalur langsung ditambahkan, jalur gabungan bukan bukti independen untuk menaikkan kepastian.
4. Kumpulkan kasus pembanding dengan izin. Simpan pengamatan satu kejadian, hasil tes asli yang relevan, serta kesimpulan teknisi yang dibuat tanpa menyalin hasil program. Hilangkan nomor seri, kontak pemilik, dan informasi pribadi.
5. Masukkan kasus berlabel ke `knowledge/kasus_validasi.json`, jalankan pembanding di bawah, dan tinjau setiap ketidaksesuaian. Jangan mengubah label pakar hanya agar tes cocok dengan program.

## Lembar keputusan

Isi tanda pisah hanya setelah peninjauan terjadi; tabel ini bukan daftar persetujuan.

| Item | Fokus | Peninjau dan tanggal | Keputusan serta alasan | Model / sumber / kasus |
| --- | --- | --- | --- | --- |
| R01 | Makna pengenalan adaptor di BIOS | — | Menunggu | — |
| R02 | Kontrol pembanding kompatibel pada port sama | — | Menunggu | — |
| R03 | Mati saat beralih daya dan laporan baterai | — | Menunggu | — |
| R04 | Waktu pakai dengan kondisi sebanding | — | Menunggu | — |
| R05 | Peringatan termal dan kejadian beban | — | Menunggu | — |
| R06 | Kecukupan pola termal untuk dugaan | — | Menunggu | — |
| R07 | Peringatan dan hasil tes pendinginan | — | Menunggu | — |
| R08 | Kode POST/RAM per model | — | Menunggu | — |
| R09 | Hasil tes memori yang spesifik | — | Menunggu | — |
| R10 | Inventaris penyimpanan BIOS dan pesan boot | — | Menunggu | — |
| R11 | Pesan boot dan hasil tes penyimpanan | — | Menunggu | — |
| R12 | Laporan resmi baterai buruk/perlu diganti | — | Menunggu | — |
| R13 | Hasil tes resmi kipas/pendinginan gagal | — | Menunggu | — |
| R14 | Hasil tes resmi penyimpanan gagal | — | Menunggu | — |
| S01 | Batas saran charger | — | Menunggu | — |
| S02 | Batas saran baterai | — | Menunggu | — |
| S03 | Batas saran pendinginan | — | Menunggu | — |
| S04 | Batas saran memori | — | Menunggu | — |
| S05 | Batas saran penyimpanan dan data | — | Menunggu | — |

## Format kasus

Dataset produksi sengaja berisi `{"schema_version":1,"cases":[]}`. Setiap kasus memerlukan ID unik, merek/model yang diketahui, peninjau, tanggal `YYYY-MM-DD`, seluruh 15 jawaban, dan list label `expected_supported` dari peninjau. Gunakan ID huruf kecil `g01`–`g15` dan `d01`–`d05`. Nilai jawaban: `ya`, `tidak`, `tidak_tahu`. Informasi yang belum diperiksa diberi `tidak_tahu`, bukan dibuat negatif.

`expected_supported` berisi dugaan dalam cakupan yang seharusnya didukung berdasarkan bukti kasus menurut peninjau. List boleh kosong atau memuat beberapa dugaan. Kasus di luar lima kategori perlu ditandai dalam catatan peninjauan; list kosong tidak berarti laptop sehat. Sertakan kasus positif, negatif, bukti kurang, beberapa gangguan, dan perbedaan model yang relevan. Tidak ada jumlah minimum kasus yang diklaim sebagai ketentuan dosen.

Contoh berikut **sintetis untuk menjelaskan format**, bukan kasus nyata dan tidak dihitung sebagai validasi. Jangan menyalinnya sebagai bukti persetujuan teknisi.

```json
{
  "id": "CONTOH-SINTETIS",
  "reviewer": "SIMULASI, bukan peninjau nyata",
  "review_date": "2026-10-23",
  "context": {"brand": "hp", "model": "Model simulasi"},
  "answers": [
    {"id":"g01","answer":"tidak_tahu"},
    {"id":"g02","answer":"tidak_tahu"},
    {"id":"g03","answer":"tidak_tahu"},
    {"id":"g04","answer":"tidak_tahu"},
    {"id":"g05","answer":"ya"},
    {"id":"g06","answer":"tidak_tahu"},
    {"id":"g07","answer":"tidak_tahu"},
    {"id":"g08","answer":"tidak_tahu"},
    {"id":"g09","answer":"tidak_tahu"},
    {"id":"g10","answer":"tidak_tahu"},
    {"id":"g11","answer":"tidak_tahu"},
    {"id":"g12","answer":"tidak_tahu"},
    {"id":"g13","answer":"tidak_tahu"},
    {"id":"g14","answer":"tidak_tahu"},
    {"id":"g15","answer":"tidak_tahu"}
  ],
  "expected_supported": ["d02"]
}
```

Masukkan objek kasus nyata ke list `cases`, lalu dari akar proyek:

```powershell
swipl -q -s src/domain_validation.pl -g laporan -t halt
```

Laporan menampilkan label harapan/aktual, label berlebih (`false_positive`), label yang terlewat (`false_negative`), dan proporsi kasus dengan kecocokan tepat. Tanpa kasus, `status` adalah `belum_ada_kasus` dan `exact_match_rate` adalah `null`, bukan nol atau nilai akurasi buatan. Data tanpa peninjau/model, jawaban tidak lengkap, ID kasus berulang, serta label tidak dikenal ditolak. Dataset sintetis hanya ada dalam tes program, terpisah dari dataset ini.

Proporsi kecocokan hanya menggambarkan dataset yang dimasukkan. Laporan tidak otomatis menaikkan status aturan menjadi tervalidasi. Sebelum status berubah, seluruh bukti peninjauan harus dicatat, revisi aturan ditelusuri, dan dukungan status tervalidasi pada validator serta tampilan harus disesuaikan dengan bukti tersebut; saat ini validator sengaja hanya menerima status draf.
