:- encoding(utf8).
:- module(pakar_laptop,
          [ main/0, konsultasi/0, konsultasi/3,
            mulai_sesi/0, simpan_jawaban/2, jawaban/2,
            status_gejala/2, status_sesi/1, hasil_sesi/1,
            evaluasi/3, evaluasi_semua/2, ringkas_jalur/5,
            tampilkan_hasil/2 ]).

:- use_module(knowledge).
:- use_module(library(readutil)).
:- use_module(library(error)).
:- use_module(library(lists)).
:- use_module(library(apply)).

:- dynamic jawaban/2, status_sesi/1, hasil_sesi/1.

/* Pengetahuan tetap draf. Kontrak: docs/rancangan_awal.md.
   Mesin menelusuri tujuan -> aturan -> premis; tanpa skor kepastian.
   Evaluasi yang berhasil mengembalikan status, bukan menyatakan diagnosis benar.
*/

mulai_sesi :-
    retractall(jawaban(_, _)),
    retractall(hasil_sesi(_)),
    retractall(status_sesi(_)),
    assertz(status_sesi(aktif)).

gejala_valid(G) :-
    must_be(atom, G),
    ( gejala(G, _, _, _) -> true ; domain_error(id_gejala, G) ).

jawaban_valid(J) :-
    must_be(atom, J),
    ( memberchk(J, [ya, tidak, tidak_tahu]) -> true
    ; domain_error(jawaban_konsultasi, J)
    ).

simpan_jawaban(G, J) :-
    gejala_valid(G), jawaban_valid(J),
    ( status_sesi(aktif) -> true
    ; permission_error(modify, sesi_tidak_aktif, G)
    ),
    ( jawaban(G, Lama) ->
        ( Lama == J -> true ; permission_error(modify, jawaban_sesi, G) )
    ; assertz(jawaban(G, J))
    ).

status_gejala(G, Keadaan) :-
    gejala_valid(G),
    ( jawaban(G, J) -> Keadaan = J ; Keadaan = belum_ditanya ).

mode_valid(tersimpan).
mode_valid(tanya(In, Out)) :- must_be(stream, In), must_be(stream, Out).

periksa_mode(Mode) :-
    must_be(nonvar, Mode),
    ( mode_valid(Mode) -> true ; domain_error(mode_evaluasi, Mode) ).

tujuan_valid(G) :-
    must_be(atom, G),
    ( gejala(G, _, _, _) -> true
    ; gangguan(G, _) -> true
    ; indikasi(G, _) -> true
    ; domain_error(tujuan_evaluasi, G)
    ).

evaluasi(Tujuan, Mode, Hasil) :-
    tujuan_valid(Tujuan), periksa_mode(Mode),
    ( Mode == tersimpan -> buktikan(Tujuan, tersimpan, Hasil)
    ; buktikan(Tujuan, Mode, _), buktikan(Tujuan, tersimpan, Hasil)
    ).

evaluasi_semua(Mode, Hasil) :-
    periksa_mode(Mode),
    findall(D, gangguan(D, _), Ds),
    ( Mode == tersimpan -> true ; maplist(buktikan_dengan(Mode), Ds, _) ),
    % Alternatif berikutnya mungkin mengisi bukti yang tadi belum_ditanya.
    % Bangun ulang seluruh jejak dari fakta sesi, tanpa I/O tambahan.
    maplist(buktikan_dengan(tersimpan), Ds, Hasil).

buktikan_dengan(Mode, Tujuan, Hasil) :- buktikan(Tujuan, Mode, Hasil).

buktikan(G, Mode, Hasil) :-
    ( gejala(G, _, _, _) ->
        ambil_jawaban(G, Mode, Keadaan), status_daun(Keadaan, Status),
        Hasil = gejala(G, Keadaan, Status)
    ; findall(def(R, Premis), aturan(R, G, Premis), Definisi),
      maplist(buktikan_aturan(Mode), Definisi, Jalur),
      maplist(status_jalur, Jalur, StatusJalur),
      status_or(StatusJalur, Status), kurang_tujuan(Status, Jalur, Kurang),
      Hasil = hasil(G, Status, Jalur, Kurang)
    ).

buktikan_aturan(Mode, def(R, Premis), jalur(R, Status, Jejak, Kurang)) :-
    buktikan_premis(Premis, Mode, Jejak),
    maplist(status_bukti, Jejak, StatusPremis), status_and(StatusPremis, Status),
    findall(K, (member(B, Jejak), bukti_kurang(B, K)), Ks), sort(Ks, Kurang).

buktikan_premis([], _, []).
buktikan_premis([P|Ps], Mode, [B|Bs]) :-
    buktikan(P, Mode, B), status_bukti(B, Status),
    ( Status == tidak_terpenuhi -> ModeSisa = tersimpan ; ModeSisa = Mode ),
    buktikan_premis(Ps, ModeSisa, Bs).

status_bukti(gejala(_, _, S), S).
status_bukti(hasil(_, S, _, _), S).
status_jalur(jalur(_, S, _, _), S).

status_daun(ya, didukung).
status_daun(tidak, tidak_terpenuhi).
status_daun(tidak_tahu, belum_lengkap).
status_daun(belum_ditanya, belum_lengkap).

status_and(Status, Hasil) :-
    ( memberchk(tidak_terpenuhi, Status) -> Hasil = tidak_terpenuhi
    ; memberchk(belum_lengkap, Status) -> Hasil = belum_lengkap
    ; Hasil = didukung
    ).

status_or(Status, Hasil) :-
    ( memberchk(didukung, Status) -> Hasil = didukung
    ; memberchk(belum_lengkap, Status) -> Hasil = belum_lengkap
    ; Hasil = tidak_terpenuhi
    ).

kurang_tujuan(Status, Jalur, Kurang) :-
    ( Status == belum_lengkap ->
        findall(K, (member(jalur(_, belum_lengkap, _, Ks), Jalur),
                    member(K, Ks)), Semua), sort(Semua, Kurang)
    ; Kurang = []
    ).

% Turunkan kekurangan lewat indikasi; simpan catatan daun belum tersedia
% juga pada jalur gugur, tanpa menjadikannya kekurangan tujuan yang layak.
bukti_kurang(gejala(G, K, belum_lengkap), kurang(G, K)).
bukti_kurang(hasil(_, _, Jalur, _), K) :-
    member(jalur(_, _, _, Ks), Jalur), member(K, Ks).

ambil_jawaban(G, Mode, J) :-
    ( jawaban(G, Tersimpan) -> J = Tersimpan
    ; Mode == tersimpan -> J = belum_ditanya
    ; Mode = tanya(In, Out),
      ( status_sesi(aktif) -> true ; permission_error(read, sesi_tidak_aktif, G) ),
      tanya_gejala(G, In, Out, J), simpan_jawaban(G, J)
    ).

tanya_gejala(G, In, Out, J) :-
    gejala(G, _, Pertanyaan, Bantuan), upcase_atom(G, ID),
    format(Out, '~n[~w] ~w~nBantuan: ~w~n', [ID, Pertanyaan, Bantuan]),
    baca_jawaban(G, In, Out, J).

baca_jawaban(G, In, Out, J) :-
    format(Out, 'Jawab ya/tidak/tidak_tahu: ', []), flush_output(Out),
    read_line_to_string(In, Baris),
    ( Baris == end_of_file -> throw(sesi_terputus(G))
    ; normalize_space(string(Bersih), Baris),
      ( jawaban_teks(Bersih, Nilai) -> J = Nilai
      ; format(Out, 'Jawaban belum dikenali. Ketik ya, tidak, atau tidak_tahu tanpa tanda titik.~n', []),
        baca_jawaban(G, In, Out, J)
      )
    ).

% Pencocokan string tetap, tanpa membaca atau mengeksekusi term Prolog input.
jawaban_teks("ya", ya).
jawaban_teks("tidak", tidak).
jawaban_teks("tidak_tahu", tidak_tahu).

konsultasi :-
    current_input(In), current_output(Out), konsultasi(In, Out, _).

konsultasi(In, Out, HasilSesi) :-
    mulai_sesi,
    format(Out, '~nSISTEM PAKAR DIAGNOSA AWAL KERUSAKAN LAPTOP~n', []),
    format(Out, 'Pengetahuan: DRAF, belum divalidasi teknisi. Tanpa persentase kepastian.~n', []),
    format(Out, 'Gunakan satu kejadian gangguan pada laptop Anda. Jawab dari pengamatan atau hasil pemeriksaan yang sudah Anda miliki.~n', []),
    format(Out, 'ya: kondisi sesuai dengan pengamatan atau hasil pemeriksaan Anda.~n', []),
    format(Out, 'tidak: Anda sudah menilai kondisi tersebut dan hasilnya tidak sesuai.~n', []),
    format(Out, 'tidak_tahu: Anda belum melakukan pemeriksaan, belum memahami hasilnya, atau belum yakin.~n', []),
    format(Out, 'Anda tidak perlu melakukan pemeriksaan baru atau menebak jawaban.~n', []),
    format(Out, 'Charger semula adalah charger yang Anda pakai saat keluhan muncul.~n', []),
    format(Out, 'Jika masukan berakhir (EOF) saat pertanyaan, konsultasi berakhir sebagai belum selesai.~n', []),
    catch((evaluasi_semua(tanya(In, Out), Hasil), HasilSesi = selesai(Hasil)),
          sesi_terputus(G),
          (evaluasi_semua(tersimpan, Sementara),
           HasilSesi = belum_selesai(G, Sementara))),
    retractall(status_sesi(_)),
    ( HasilSesi = selesai(_) -> assertz(status_sesi(selesai))
    ; HasilSesi = belum_selesai(Putus, _), assertz(status_sesi(terputus(Putus)))
    ),
    assertz(hasil_sesi(HasilSesi)), tampilkan_hasil(Out, HasilSesi).

ringkas_jalur(Jalur, Aturan, Positif, Kurang, Penolak) :-
    Jalur = jalur(_, _, Jejak, Kurang),
    findall(R, aturan_di_jalur(Jalur, R), Rs), list_to_set(Rs, Aturan),
    findall(G, (member(B, Jejak), daun(B, G, ya)), Gs), sort(Gs, Positif),
    findall(G, (member(B, Jejak), daun(B, G, tidak)), Ns), sort(Ns, Penolak).

aturan_di_jalur(jalur(R, _, _, _), R).
aturan_di_jalur(jalur(_, _, Jejak, _), R) :-
    member(hasil(_, _, Jalur, _), Jejak),
    member(J, Jalur), aturan_di_jalur(J, R).

daun(gejala(G, K, _), G, K).
daun(hasil(_, _, Jalur, _), G, K) :-
    member(jalur(_, _, Jejak, _), Jalur), member(B, Jejak), daun(B, G, K).

tampilkan_hasil(Out, belum_selesai(G, _)) :-
    upcase_atom(G, ID), findall(X, jawaban(X, _), Jawaban), length(Jawaban, N),
    format(Out, '~nKonsultasi belum selesai: masukan berakhir (EOF) saat pertanyaan ~w. Sesi terputus.~n', [ID]),
    format(Out, 'Jawaban tersimpan: ~d/15. ~w belum Anda jawab; tidak_tahu tidak diisi otomatis.~n', [N, ID]),
    format(Out, 'Hasil sementara tidak ditampilkan sebagai kesimpulan akhir.~n', []).
tampilkan_hasil(Out, selesai(Hasil)) :-
    format(Out, '~nHASIL KONSULTASI - seluruh pengetahuan masih DRAF~n', []),
    include(hasil_didukung, Hasil, Didukung), length(Didukung, N),
    format(Out, 'Jumlah dugaan dengan gejala yang sesuai aturan: ~d.~n', [N]),
    maplist(tampilkan_diagnosa(Out), Hasil),
    format(Out, '~nHasil ini adalah dugaan awal dari pengetahuan draf. Jawaban yang belum mendukung dugaan tidak berarti laptop Anda pasti sehat.~n', []).

hasil_didukung(hasil(_, didukung, _, _)).

tampilkan_diagnosa(Out, hasil(D, Status, Jalur, Kurang)) :-
    gangguan(D, Nama), upcase_atom(D, ID),
    teks_status(Status, StatusTampil),
    format(Out, '~n~w - ~w: ~w~n', [ID, Nama, StatusTampil]),
    maplist(tampilkan_jalur(Out), Jalur),
    ( Status == didukung ->
        saran(D, S, Teks), upcase_atom(S, SID),
        format(Out, 'Saran ~w (DRAF): ~w~n', [SID, Teks])
    ; Status == belum_lengkap ->
        format(Out, 'Informasi yang belum tersedia untuk dugaan ini: ', []),
        tampilkan_kurang(Out, Kurang)
    ; format(Out, 'Belum ada jalur aturan yang sesuai dengan jawaban Anda.~n', [])
    ).

tampilkan_jalur(Out, J) :-
    J = jalur(_, Status, _, _), ringkas_jalur(J, Aturan, Positif, Kurang, Penolak),
    maplist(upcase_atom, Aturan, IDs), atomic_list_concat(IDs, ' -> ', Teks),
    teks_status(Status, StatusTampil),
    format(Out, '  Jalur ~w: ~w~n', [Teks, StatusTampil]),
    ( Status == didukung ->
        format(Out, '  Alasan berdasarkan jawaban ya:~n', []),
        maplist(tampilkan_gejala(Out), Positif)
    ; true
    ),
    ( Penolak == [] -> true
    ; maplist(upcase_atom, Penolak, Tidak), atomic_list_concat(Tidak, ', ', T),
      format(Out, '  Kondisi yang Anda jawab tidak: ~w.~n', [T])
    ),
    ( Kurang == [] -> true
    ; format(Out, '  Informasi yang belum tersedia pada jalur ini: ', []),
      tampilkan_kurang(Out, Kurang)
    ).

tampilkan_gejala(Out, G) :-
    gejala(G, Label, _, _), upcase_atom(G, ID),
    format(Out, '    ~w - ~w.~n', [ID, Label]).

tampilkan_kurang(Out, Kurang) :-
    maplist(teks_kurang, Kurang, Teks), atomic_list_concat(Teks, ', ', Gabungan),
    format(Out, '~w.~n', [Gabungan]).

teks_kurang(kurang(G, K), Teks) :-
    upcase_atom(G, ID), gejala(G, Label, _, _), teks_keadaan(K, Keadaan),
    format(atom(Teks), '~w - ~w (~w)', [ID, Label, Keadaan]).

% Hanya padanan tampilan. Atom dan aturan evaluasi tetap sama.
teks_status(didukung, 'Gejala sesuai dengan aturan dugaan ini').
teks_status(belum_lengkap, 'Informasi belum cukup').
teks_status(tidak_terpenuhi, 'Jawaban belum mendukung dugaan ini').

teks_keadaan(tidak_tahu, 'Anda memilih tidak_tahu').
teks_keadaan(belum_ditanya, 'belum ditanyakan').

main :- current_input(In), current_output(Out), ulang_konsultasi(In, Out).

ulang_konsultasi(In, Out) :-
    konsultasi(In, Out, Hasil),
    ( Hasil = selesai(_) ->
        pilihan_sesi(In, Out, Pilihan),
        ( Pilihan == baru -> ulang_konsultasi(In, Out) ; true )
    ; true
    ).

pilihan_sesi(In, Out, Pilihan) :-
    format(Out, '~nKetik baru untuk sesi baru atau selesai untuk keluar: ', []),
    flush_output(Out), read_line_to_string(In, Baris),
    ( Baris == end_of_file -> Pilihan = selesai
    ; normalize_space(string(Teks), Baris),
      ( Teks == "baru" -> Pilihan = baru
      ; Teks == "selesai" -> Pilihan = selesai
      ; format(Out, 'Pilihan belum dikenali. Ketik baru atau selesai.~n', []),
        pilihan_sesi(In, Out, Pilihan)
      )
    ).
