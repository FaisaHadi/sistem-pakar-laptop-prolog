:- encoding(utf8).
:- use_module('../src/main').
:- use_module('../src/knowledge').
:- use_module(library(plunit)).
:- use_module(library(readutil)).
:- use_module(library(lists)).

% Fixture logika memuat 15 jawaban: gejala selain Ya/TidakTahu adalah tidak.
fixture(Ya, TidakTahu) :-
    mulai_sesi,
    forall(gejala(G, _, _, _),
           ((memberchk(G, Ya) -> J = ya
            ; memberchk(G, TidakTahu) -> J = tidak_tahu
            ; J = tidak), simpan_jawaban(G, J))).

cek_dugaan(Ya, TidakTahu, Harapan, Hasil) :-
    fixture(Ya, TidakTahu), evaluasi_semua(tersimpan, Hasil),
    findall(D, member(hasil(D, didukung, _, _), Hasil), Aktual),
    assertion(Aktual == Harapan).

cek_jalur(Hasil, D, Aturan, Positif) :-
    memberchk(hasil(D, didukung, Jalur, []), Hasil),
    member(J, Jalur), J = jalur(_, didukung, _, []),
    ringkas_jalur(J, Aturan, Positif, [], []).

:- meta_predicate dengan_input(+, 1, -).
dengan_input(Teks, Goal, Keluaran) :-
    setup_call_cleanup(
        open_string(Teks, In),
        with_output_to(string(Keluaran), call(Goal, In)),
        close(In)).

jalankan_konsultasi(Hasil, In) :-
    current_output(Out), konsultasi(In, Out, Hasil).

jalankan_evaluasi(D, Hasil, In) :-
    current_output(Out), evaluasi(D, tanya(In, Out), Hasil).

teks_hasil(Hasil, Teks) :-
    with_output_to(string(Teks),
                   (current_output(Out), tampilkan_hasil(Out, selesai(Hasil)))).

jumlah_teks(Teks, Potongan, N) :-
    findall(Pos, sub_string(Teks, Pos, _, _, Potongan), Posisi), length(Posisi, N).

input_d01("ya\nya\nya\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\n").
input_tidak("tidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\n").

:- begin_tests(prototipe_laptop).

test(t01) :-
    cek_dugaan([g01,g02,g03], [], [d01], H),
    once(cek_jalur(H, d01, [r02,r01], [g01,g02,g03])).
test(t02) :-
    cek_dugaan([g04,g05], [], [d02], H),
    once(cek_jalur(H, d02, [r03], [g04,g05])).
test(t03) :-
    cek_dugaan([g05,g06], [], [d02], H),
    once(cek_jalur(H, d02, [r04], [g05,g06])).
test(t04) :-
    cek_dugaan([g07,g08], [], [d03], H),
    once(cek_jalur(H, d03, [r06,r05], [g07,g08])).
test(t05) :-
    cek_dugaan([g07,g09], [], [d03], H),
    once(cek_jalur(H, d03, [r07], [g07,g09])).
test(t06) :-
    cek_dugaan([g10,g11], [], [d04], H),
    once(cek_jalur(H, d04, [r08], [g10,g11])).
test(t07) :-
    cek_dugaan([g12], [], [d04], H),
    once(cek_jalur(H, d04, [r09], [g12])).
test(t08) :-
    cek_dugaan([g13,g14], [], [d05], H),
    once(cek_jalur(H, d05, [r10], [g13,g14])).
test(t09) :-
    cek_dugaan([g14,g15], [], [d05], H),
    once(cek_jalur(H, d05, [r11], [g14,g15])).
test(t10) :-
    cek_dugaan([], [], [], H),
    forall(member(hasil(_, Status, _, []), H), assertion(Status == tidak_terpenuhi)),
    teks_hasil(H, Teks),
    assertion(sub_string(Teks, _, _, _, 'tidak berarti laptop Anda pasti sehat')).
test(t11) :-
    cek_dugaan([g01,g02], [g03], [], _),
    evaluasi(d01, tersimpan, hasil(d01, belum_lengkap, [J], [kurang(g03,tidak_tahu)])),
    ringkas_jalur(J, [r02,r01], [g01,g02], [kurang(g03,tidak_tahu)], []).
test(t12) :-
    cek_dugaan([g01,g02], [], [], _),
    evaluasi(d01, tersimpan, hasil(d01, tidak_terpenuhi, [J], [])),
    ringkas_jalur(J, [r02,r01], [g01,g02], [], [g03]).
test(t13) :- cek_dugaan([g06,g14], [], [], _).
test(t14) :-
    cek_dugaan([g04,g05,g06], [], [d02], H),
    findall(Rs-Gs, cek_jalur(H, d02, Rs, Gs), Jalur),
    assertion(Jalur == [[r03]-[g04,g05], [r04]-[g05,g06], [r12]-[g05]]).
test(t15) :-
    cek_dugaan([g07,g08,g09], [], [d03], H),
    findall(Rs-Gs, cek_jalur(H, d03, Rs, Gs), Jalur),
    assertion(Jalur == [[r06,r05]-[g07,g08], [r07]-[g07,g09], [r13]-[g09]]).
test(t16) :-
    cek_dugaan([g07,g08,g12], [], [d03,d04], H),
    once(cek_jalur(H, d03, [r06,r05], [g07,g08])),
    once(cek_jalur(H, d04, [r09], [g12])).
test(t17) :-
    cek_dugaan([g08,g09], [], [d03], _),
    evaluasi(d03, tersimpan, hasil(d03, didukung, Jalur, [])),
    assertion(Jalur = [jalur(r06,tidak_terpenuhi,_,[]),
                      jalur(r07,tidak_terpenuhi,_,[]),jalur(r13,didukung,_,[])]).
test(t18) :-
    mulai_sesi,
    atomics_to_string([tidak_tahu,tidak_tahu,tidak_tahu,tidak_tahu,tidak_tahu,
                      tidak_tahu,tidak_tahu,tidak_tahu,tidak_tahu,tidak_tahu,
                      tidak_tahu,tidak_tahu,tidak_tahu,tidak_tahu,tidak_tahu], '\n', S),
    string_concat(S, "\n", Input),
    dengan_input(Input, jalankan_konsultasi(selesai(H)), _),
    assertion(status_sesi(selesai)),
    forall(member(hasil(_, Status, _, Kurang), H),
           (assertion(Status == belum_lengkap), assertion(Kurang \== []))),
    findall(G, jawaban(G,tidak_tahu), Semua), length(Semua, 15),
    assertion(\+ jawaban(_,tidak)).
test(t19_input_invalid) :-
    mulai_sesi,
    dengan_input("mungkin\nya.\n\nYA\n  ya  \nya\nya\n",
                 jalankan_evaluasi(d01, hasil(d01,didukung,_,[])), Teks),
    jumlah_teks(Teks, 'Jawaban belum dikenali.', 4),
    findall(G-J, jawaban(G,J), Jawaban),
    assertion(Jawaban == [g01-ya,g02-ya,g03-ya]).
test(t20_jawaban_tidak_berulang_saat_backtracking) :-
    mulai_sesi,
    dengan_input("ya\nya\nya\npenanda\n", ulang_evaluasi_d02, Teks),
    jumlah_teks(Teks, '[G05]', 1),
    findall(J, jawaban(g05,J), [ya]).
test(t21_reset_sesi) :-
    input_d01(InputA),
    dengan_input(InputA, jalankan_konsultasi(selesai(HA)), _),
    assertion(member(hasil(d01,didukung,_,_), HA)),
    assertion(hasil_sesi(selesai(HA))),
    mulai_sesi,
    assertion(\+ jawaban(_,_)), assertion(\+ hasil_sesi(_)),
    assertion(status_sesi(aktif)),
    evaluasi(i01, tersimpan, hasil(i01,belum_lengkap,_,_)),
    input_tidak(InputB),
    dengan_input(InputB, jalankan_konsultasi(selesai(HB)), _),
    assertion(\+ member(hasil(_,didukung,_,_), HB)),
    findall(S, hasil_sesi(S), [_]).
test(t22_belum_diperiksa) :-
    fixture([], [g11,g12]),
    evaluasi(g11, tersimpan, gejala(g11,tidak_tahu,belum_lengkap)),
    evaluasi(g12, tersimpan, gejala(g12,tidak_tahu,belum_lengkap)),
    evaluasi(d04, tersimpan, hasil(d04,belum_lengkap,_,[kurang(g12,tidak_tahu)])).
test(t23_urutan_dan_seluruh_hipotesis) :-
    input_d01(Input),
    dengan_input(Input, jalankan_konsultasi(selesai(H)), _),
    findall(G, jawaban(G,_), Urutan),
    assertion(Urutan == [g01,g02,g03,g04,g05,g07,g09,g10,g12,g13,g14,g15]),
    findall(D, member(hasil(D,_,_,_), H), [d01,d02,d03,d04,d05]).
test(t24_eof) :-
    dengan_input("", jalankan_konsultasi(belum_selesai(g01,H)), Teks),
    assertion(status_sesi(terputus(g01))),
    assertion(\+ jawaban(_,_)),
    status_gejala(g01, belum_ditanya),
    assertion(member(hasil(d01,belum_lengkap,_,_), H)),
    assertion(sub_string(Teks,_,_,_,'Konsultasi belum selesai')),
    assertion(\+ sub_string(Teks,_,_,_,'HASIL KONSULTASI')),
    assertion(\+ sub_string(Teks,_,_,_,'[G02]')).
test(t25) :-
    cek_dugaan([g05,g06], [], [d02], H),
    memberchk(hasil(d02,didukung,[jalur(r03,tidak_terpenuhi,_,_),
                                jalur(r04,didukung,_,_),jalur(r12,didukung,_,[])],[]), H).
test(t26) :-
    cek_dugaan([g02,g03], [g01], [], _),
    evaluasi(d01, tersimpan,
             hasil(d01,belum_lengkap,[J],[kurang(g01,tidak_tahu)])),
    J = jalur(r02,belum_lengkap,
              [hasil(i01,belum_lengkap,[jalur(r01,belum_lengkap,_,_)],
                     [kurang(g01,tidak_tahu)]), _], _),
    ringkas_jalur(J,[r02,r01],[g02,g03],[kurang(g01,tidak_tahu)],[]).
test(t27) :-
    cek_dugaan([g03], [g01], [], _),
    evaluasi(d01, tersimpan, hasil(d01,tidak_terpenuhi,[J],[])),
    J = jalur(r02,tidak_terpenuhi,_,[kurang(g01,tidak_tahu)]),
    ringkas_jalur(J,[r02,r01],[g03],[kurang(g01,tidak_tahu)],[g02]).
test(t28) :-
    cek_dugaan([g05,g06], [g04], [d02], H),
    memberchk(hasil(d02,didukung,[jalur(r03,belum_lengkap,_,[kurang(g04,tidak_tahu)]),
                                jalur(r04,didukung,_,[]),jalur(r12,didukung,_,[])],[]), H),
    once(cek_jalur(H,d02,[r04],[g05,g06])).
test(t29) :-
    cek_dugaan([g13,g14,g15], [], [d05], H),
    findall(Rs-Gs, cek_jalur(H,d05,Rs,Gs), Jalur),
    assertion(Jalur == [[r10]-[g13,g14], [r11]-[g14,g15], [r14]-[g15]]),
    teks_hasil(H, Teks), jumlah_teks(Teks,'D05 - ',1),
    jumlah_teks(Teks,'Saran S05',1),
    jumlah_teks(Teks,'Jalur R10: Gejala sesuai dengan aturan dugaan ini',1),
    jumlah_teks(Teks,'Jalur R11: Gejala sesuai dengan aturan dugaan ini',1).
test(t30) :-
    cek_dugaan([g15], [], [d05], H),
    memberchk(hasil(d05,didukung,_,[]),H),
    teks_hasil(H,Teks),
    assertion(sub_string(Teks,_,_,_,'tidak berarti laptop Anda pasti sehat')),
    assertion(sub_string(Teks,_,_,_,'Saran S05')).

test(belum_ditanya_berbeda_dari_tidak_tahu) :-
    mulai_sesi,
    evaluasi(g01,tersimpan,gejala(g01,belum_ditanya,belum_lengkap)),
    assertion(\+ jawaban(g01,_)),
    simpan_jawaban(g01,tidak_tahu),
    evaluasi(g01,tersimpan,gejala(g01,tidak_tahu,belum_lengkap)),
    assertion(status_sesi(aktif)).
test(eof_setelah_tidak_tahu) :-
    dengan_input("tidak_tahu\n", jalankan_konsultasi(belum_selesai(g02,H)), _),
    assertion(jawaban(g01,tidak_tahu)), status_gejala(g02,belum_ditanya),
    assertion(status_sesi(terputus(g02))),
    memberchk(hasil(d01,belum_lengkap,_,Kurang),H),
    assertion(Kurang == [kurang(g01,tidak_tahu),kurang(g02,belum_ditanya),
                        kurang(g03,belum_ditanya)]).
test(eof_setelah_input_invalid) :-
    dengan_input("mungkin\n", jalankan_konsultasi(belum_selesai(g01,_)), Teks),
    assertion(\+ jawaban(_,_)), jumlah_teks(Teks,'Jawaban belum dikenali.',1).
test(eof_setelah_ada_hipotesis_didukung) :-
    dengan_input("ya\nya\nya\n", jalankan_konsultasi(belum_selesai(g04,H)), Teks),
    assertion(member(hasil(d01,didukung,_,_),H)),
    assertion(status_sesi(terputus(g04))),
    assertion(\+ sub_string(Teks,_,_,_,'HASIL KONSULTASI')),
    assertion(\+ sub_string(Teks,_,_,_,'Saran S01')).
test(t27_interaktif_tidak_berhenti_pada_unknown) :-
    mulai_sesi,
    dengan_input("tidak_tahu\ntidak\n",
                 jalankan_evaluasi(d01,hasil(d01,tidak_terpenuhi,_,[])), Teks),
    assertion(jawaban(g02,tidak)), status_gejala(g03,belum_ditanya),
    jumlah_teks(Teks,'[G02]',1), jumlah_teks(Teks,'[G03]',0).
test(jejak_diperbarui_sesudah_alternatif) :-
    mulai_sesi,
    dengan_input("tidak\nya\nya\n",
                 jalankan_evaluasi(d02,hasil(d02,didukung,[J1,J2,J3],[])), _),
    J1 = jalur(r03,tidak_terpenuhi,
               [gejala(g04,tidak,tidak_terpenuhi),gejala(g05,ya,didukung)],[]),
    J2 = jalur(r04,didukung,_,[]), J3 = jalur(r12,didukung,_,[]).
test(alternatif_tetap_ditanya_setelah_berhasil) :-
    mulai_sesi,
    dengan_input("ya\nya\ntidak_tahu\n",
                 jalankan_evaluasi(d02,hasil(d02,didukung,Jalur,[])), _),
    assertion(jawaban(g06,tidak_tahu)),
    assertion(Jalur = [jalur(r03,didukung,_,[]),
                      jalur(r04,belum_lengkap,_,[kurang(g06,tidak_tahu)]),
                      jalur(r12,didukung,_,[]) ]).
test(tersimpan_tidak_mengisi_jawaban) :-
    mulai_sesi, evaluasi_semua(tersimpan,H), length(H,5),
    assertion(\+ jawaban(_,_)), assertion(\+ hasil_sesi(_)).
test(jawaban_idempoten) :-
    mulai_sesi, simpan_jawaban(g01,ya), simpan_jawaban(g01,ya),
    findall(J,jawaban(g01,J),[ya]).
test(tolak_koreksi_tengah_sesi,
     [throws(error(permission_error(modify,jawaban_sesi,g01),_))]) :-
    mulai_sesi, simpan_jawaban(g01,ya), simpan_jawaban(g01,tidak).
test(tolak_nilai_jawaban_invalid,
     [throws(error(domain_error(jawaban_konsultasi,mungkin),_))]) :-
    mulai_sesi, simpan_jawaban(g01,mungkin).
test(tolak_id_gejala_invalid,
     [throws(error(domain_error(id_gejala,g99),_))]) :-
    mulai_sesi, simpan_jawaban(g99,ya).
test(menu_sesi_baru) :-
    input_d01(A), input_tidak(B),
    atomics_to_string([A,"baru\n",B,"selesai\n"], Input),
    dengan_input(Input,jalankan_main,Teks),
    jumlah_teks(Teks,'SISTEM PAKAR DIAGNOSA',2),
    assertion(status_sesi(selesai)),
    hasil_sesi(selesai(H)), assertion(\+ member(hasil(_,didukung,_,_),H)),
    assertion(jawaban(g01,tidak)).
test(menu_invalid_dan_eof_setelah_selesai) :-
    input_tidak(A), string_concat(A,"batal\n",Input),
    dengan_input(Input,jalankan_main,Teks),
    jumlah_teks(Teks,'Pilihan belum dikenali.',1), assertion(status_sesi(selesai)).
test(id_dan_pengetahuan_tetap_draf) :-
    findall(G,gejala(G,_,_,_),Gs),
    assertion(Gs == [g01,g02,g03,g04,g05,g06,g07,g08,g09,g10,g11,g12,g13,g14,g15]),
    findall(D,gangguan(D,_),[d01,d02,d03,d04,d05]),
    findall(R,aturan(R,_,_),[r01,r02,r03,r04,r05,r06,r07,r08,r09,r10,r11,r12,r13,r14]),
    findall(I,indikasi(I,_),[i01,i02]),
    assertion(status_pengetahuan(draf)),
    forall(aturan(R,_,_), assertion(aturan_info(R,_,draf))).
test(semua_hasil_punya_alasan_dan_saran) :-
    findall(G,gejala(G,_,_,_),Gs), cek_dugaan(Gs,[],[d01,d02,d03,d04,d05],H),
    teks_hasil(H,Teks),
    forall(member(hasil(D,didukung,Jalur,[]),H),
           (assertion(saran(D,_,_)),
            forall(member(J,Jalur),
                   (ringkas_jalur(J,_,Pos,[],[]), assertion(Pos \== []))))),
    jumlah_teks(Teks,'Saran S',5), jumlah_teks(Teks,'Alasan berdasarkan jawaban ya:',12),
    assertion(\+ sub_string(Teks,_,_,_,'%')).

test(bahasa_d01_ya_dan_petunjuk) :-
    input_d01(Input),
    dengan_input(Input,jalankan_konsultasi(selesai(H)),Teks),
    memberchk(hasil(d01,didukung,[J],[]),H),
    ringkas_jalur(J,[r02,r01],[g01,g02,g03],[],[]),
    assertion(sub_string(Teks,_,_,_,
                         'D01 - Gangguan charger atau kabel dayanya: Gejala sesuai dengan aturan dugaan ini')),
    assertion(sub_string(Teks,_,_,_,'Jalur R02 -> R01: Gejala sesuai dengan aturan dugaan ini')),
    assertion(sub_string(Teks,_,_,_,'Jawaban belum mendukung dugaan ini')),
    assertion(sub_string(Teks,_,_,_,'ya: kondisi sesuai')),
    assertion(sub_string(Teks,_,_,_,'tidak: Anda sudah menilai')),
    assertion(sub_string(Teks,_,_,_,'tidak_tahu: Anda belum melakukan pemeriksaan')),
    assertion(sub_string(Teks,_,_,_,'Anda tidak perlu melakukan pemeriksaan baru')),
    forall(member(G,[g01,g02,g03]),
           (gejala(G,_,_,Bantuan), assertion(sub_string(Teks,_,_,_,Bantuan)))),
    assertion(\+ sub_string(Teks,_,_,_,'PERLU_SUMBER_MODEL')),
    jumlah_teks(Teks,'Saran S01',1).

test(bahasa_d01_g03_tidak_tahu) :-
    Input = "ya\nya\ntidak_tahu\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\ntidak\n",
    dengan_input(Input,jalankan_konsultasi(selesai(H)),Teks),
    memberchk(hasil(d01,belum_lengkap,[J],[kurang(g03,tidak_tahu)]),H),
    ringkas_jalur(J,[r02,r01],[g01,g02],[kurang(g03,tidak_tahu)],[]),
    assertion(sub_string(Teks,_,_,_,
                         'D01 - Gangguan charger atau kabel dayanya: Informasi belum cukup')),
    assertion(sub_string(Teks,_,_,_,'Jalur R02 -> R01: Informasi belum cukup')),
    assertion(sub_string(Teks,_,_,_,
                         'G03 - Pengisian normal dengan charger pembanding (Anda memilih tidak_tahu)')),
    assertion(jawaban(g03,tidak_tahu)), assertion(status_sesi(selesai)),
    jumlah_teks(Teks,'Saran S01',0),
    assertion(\+ sub_string(Teks,_,_,_,': belum_lengkap')),
    assertion(\+ sub_string(Teks,_,_,_,': tidak_terpenuhi')).

:- end_tests(prototipe_laptop).

ulang_evaluasi_d02(In) :-
    current_output(Out),
    findall(H,evaluasi(d02,tanya(In,Out),H),[hasil(d02,didukung,_,[])]),
    findall(H,evaluasi(d02,tanya(In,Out),H),[hasil(d02,didukung,_,[])]),
    read_line_to_string(In,"penanda").

jalankan_main(In) :-
    setup_call_cleanup(current_input(Lama),
                       (set_input(In), main), set_input(Lama)).
