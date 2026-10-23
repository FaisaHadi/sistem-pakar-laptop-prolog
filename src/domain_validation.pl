:- encoding(utf8).
:- module(validasi_domain_laptop,
          [ laporan/0, laporan_validasi/2, evaluasi_dataset/2 ]).
:- use_module(main).
:- use_module(knowledge).
:- use_module(explanation).
:- use_module(library(http/json)).
:- use_module(library(lists)).
:- use_module(library(date)).

:- prolog_load_context(directory,Dir),
   directory_file_path(Dir,'../knowledge/kasus_validasi.json',File),
   asserta(dataset_default(File)).

laporan :-
    dataset_default(File), laporan_validasi(File,Report),
    json_write_dict(current_output,Report,[width(0)]), nl.

laporan_validasi(File,Report) :-
    setup_call_cleanup(open(File,read,In,[encoding(utf8)]),
                       json_read_dict(In,Data),close(In)),
    evaluasi_dataset(Data,Report).

evaluasi_dataset(Data,Report) :-
    ( dataset_valid(Data,Cases) -> true
    ; throw(error(dataset_validasi_tidak_valid, evaluasi_dataset/2)) ),
    maplist(evaluasi_kasus,Cases,Results), length(Results,N),
    include(kasus_sesuai,Results,Matches), length(Matches,Correct),
    ( N == 0 -> Status = belum_ada_kasus, Agreement = null
    ; Status = hasil_perbandingan, Agreement is Correct / N ),
    Report = _{status:Status,knowledge_status:draf,case_count:N,
               matching_cases:Correct,exact_match_rate:Agreement,
               notice:"Perbandingan terhadap label peninjau pada dataset ini, bukan persentase kepastian konsultasi atau bukti akurasi pada seluruh laptop. Status pengetahuan tetap draf sampai peninjauan aturan diselesaikan.",
               results:Results}.

dataset_valid(Data,Cases) :-
    is_dict(Data), get_dict(schema_version,Data,1), get_dict(cases,Data,Cases),
    is_list(Cases), maplist(kasus_valid,Cases),
    findall(Id,(member(C,Cases),Id=C.id),Ids), sort(Ids,Set),
    length(Ids,N), length(Set,N).

teks_nonempty(S) :- string(S), normalize_space(string(T),S), T \== "".
kasus_valid(C) :-
    is_dict(C), get_dict(id,C,Id), teks_nonempty(Id),
    get_dict(reviewer,C,Reviewer), teks_nonempty(Reviewer),
    get_dict(review_date,C,Date), string(Date),
    string_length(Date,10), catch(parse_time(Date,iso_8601,_),_,fail),
    get_dict(context,C,Context), konteks_valid(Context,Clean),
    Clean.brand \== "tidak_diketahui", teks_nonempty(Clean.model),
    get_dict(answers,C,Answers), is_list(Answers), maplist(jawaban_valid,Answers),
    findall(G,(member(A,Answers),atom_string(G,A.id)),Given),
    findall(G,gejala(G,_,_,_),Expected), msort(Given,Sorted), msort(Expected,Sorted),
    get_dict(expected_supported,C,Supported), is_list(Supported),
    maplist(diagnosis_valid,Supported), sort(Supported,Set),
    length(Supported,N), length(Set,N).

jawaban_valid(A) :-
    is_dict(A), get_dict(id,A,Id), string(Id), atom_string(G,Id), gejala(G,_,_,_),
    get_dict(answer,A,Answer), memberchk(Answer,["ya","tidak","tidak_tahu"]).
diagnosis_valid(S) :- string(S), atom_string(D,S), gangguan(D,_).

evaluasi_kasus(C,Result) :-
    mulai_sesi,
    forall(member(A,C.answers),
           (atom_string(G,A.id),atom_string(J,A.answer),simpan_jawaban(G,J))),
    evaluasi_semua(tersimpan,Hasil),
    findall(D,member(hasil(D,didukung,_,_),Hasil),Actual0), sort(Actual0,Actual),
    maplist(atom_string,Expected0,C.expected_supported), sort(Expected0,Expected),
    subtract(Actual,Expected,FP), subtract(Expected,Actual,FN),
    (Actual == Expected -> Match = true ; Match = false),
    Result = _{id:C.id,reviewer:C.reviewer,review_date:C.review_date,
               context:C.context,expected:Expected,actual:Actual,
               false_positive:FP,false_negative:FN,match:Match}.

kasus_sesuai(C) :- C.match == true.

:- multifile prolog:message//1.
prolog:message(error(dataset_validasi_tidak_valid,_)) -->
    ['Dataset validasi tidak valid. Periksa ID unik, peninjau, tanggal, merek/model, 15 jawaban, dan label diagnosis sesuai knowledge/validasi_pakar.md.'].
