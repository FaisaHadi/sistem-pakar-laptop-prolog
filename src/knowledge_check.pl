:- encoding(utf8).
:- module(verificador_laptop,
          [ periksa_pengetahuan/0, validasi_pengetahuan/1,
            salinan_pengetahuan/1, validasi_data/2 ]).
:- use_module(knowledge).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(date)).

salinan_pengetahuan(Data) :-
    findall(gejala(I,L,P,H), gejala(I,L,P,H), Gejala),
    findall(gangguan(I,L), gangguan(I,L), Gangguan),
    findall(indikasi(I,L), indikasi(I,L), Indikasi),
    findall(aturan(I,G,Ps), aturan(I,G,Ps), Aturan),
    findall(aturan_info(I,S,V), aturan_info(I,S,V), Info),
    findall(saran(D,I,T), saran(D,I,T), Saran),
    findall(sumber(I,T,U,M,F,B), sumber(I,T,U,M,F,B), Sumber),
    findall(aturan_batas(I,T), aturan_batas(I,T), Batas),
    findall(gangguan_batas(I,T), gangguan_batas(I,T), BatasGangguan),
    findall(status_pengetahuan(S),status_pengetahuan(S),Status),
    Data = kb{gejala:Gejala, gangguan:Gangguan, indikasi:Indikasi,
              aturan:Aturan, info:Info, saran:Saran, sumber:Sumber,
              batas:Batas, batas_gangguan:BatasGangguan, status:Status}.

validasi_pengetahuan(Masalah) :-
    salinan_pengetahuan(Data), validasi_data(Data, Masalah).

periksa_pengetahuan :-
    validasi_pengetahuan(Masalah),
    ( Masalah == [] -> true
    ; throw(error(basis_pengetahuan_tidak_valid(Masalah), periksa_pengetahuan/0))
    ).

% Pemeriksa bekerja pada salinan data: tes tidak perlu mengubah fakta produksi.
validasi_data(Data, Masalah) :-
    ( ground(Data), is_dict(Data),
      forall(member(K,[gejala,gangguan,indikasi,aturan,info,saran,sumber,batas,batas_gangguan,status]),
             (get_dict(K,Data,L), is_list(L))) ->
        findall(M, temuan(Data,M), Semua), sort(Semua,Masalah)
    ; Masalah = [masalah(format_data, pengetahuan)]
    ).

teks_valid(T) :-
    (atom(T);string(T)), normalize_space(string(S),T), S \== "".
https_valid(U) :- atom(U), sub_atom(U,0,8,_,'https://'), atom_length(U,N), N > 8.
tanggal_valid(D) :-
    atom(D), atom_length(D,10), sub_atom(D,4,1,_,'-'), sub_atom(D,7,1,_,'-'),
    catch(parse_time(D,iso_8601,_),_,fail).
unik(List) :- sort(List,Set), length(List,N), length(Set,N).
node(Data,G) :- member(gejala(G,_,_,_),Data.gejala).
node(Data,G) :- member(gangguan(G,_),Data.gangguan).
node(Data,G) :- member(indikasi(G,_),Data.indikasi).
kesimpulan(Data,G) :- member(gangguan(G,_),Data.gangguan).
kesimpulan(Data,G) :- member(indikasi(G,_),Data.indikasi).

format_item(gejala,gejala(I,L,P,H)) :- atom(I), maplist(teks_valid,[L,P,H]).
format_item(gangguan,gangguan(I,L)) :- atom(I), teks_valid(L).
format_item(indikasi,indikasi(I,L)) :- atom(I), teks_valid(L).
format_item(aturan,aturan(I,G,Ps)) :-
    atom(I), atom(G), is_list(Ps), Ps \== [], maplist(atom,Ps), unik(Ps).
format_item(info,aturan_info(I,S,draf)) :-
    atom(I), is_list(S), S \== [], maplist(atom,S), unik(S).
format_item(saran,saran(D,I,T)) :- atom(D), atom(I), teks_valid(T).
format_item(sumber,sumber(I,T,U,M,F,B)) :-
    atom(I), teks_valid(T), https_valid(U), panduan_merek(M,_,_),
    tanggal_valid(F), teks_valid(B).
format_item(batas,aturan_batas(I,T)) :- atom(I), teks_valid(T).
format_item(batas_gangguan,gangguan_batas(I,T)) :- atom(I), teks_valid(T).
format_item(status,status_pengetahuan(draf)).

temuan(Data,masalah(format_item,K-Item)) :-
    member(K,[gejala,gangguan,indikasi,aturan,info,saran,sumber,batas,batas_gangguan,status]),
    get_dict(K,Data,List), member(Item,List), \+ format_item(K,Item).
temuan(Data,masalah(id_node_duplikat,G)) :-
    findall(N,node(Data,N),Nodes), member(G,Nodes),
    include(==(G),Nodes,Sama), length(Sama,N), N > 1.
temuan(Data,masalah(id_duplikat,K-I)) :-
    member(K,[aturan,sumber]), get_dict(K,Data,List),
    findall(Id,(member(T,List),compound(T),arg(1,T,Id)),Ids),
    member(I,Ids), include(==(I),Ids,Sama), length(Sama,N), N > 1.
temuan(Data,masalah(id_saran_duplikat,I)) :-
    findall(Id,member(saran(_,Id,_),Data.saran),Ids), member(I,Ids),
    include(==(I),Ids,Sama), length(Sama,N), N > 1.
temuan(Data,masalah(kesimpulan_tidak_dikenal,R-G)) :-
    member(aturan(R,G,_),Data.aturan), \+ kesimpulan(Data,G).
temuan(Data,masalah(premis_tidak_dikenal,R-G)) :-
    member(aturan(R,_,Ps),Data.aturan), is_list(Ps), member(G,Ps), \+ node(Data,G).
temuan(Data,masalah(tanpa_aturan,G)) :-
    kesimpulan(Data,G), \+ member(aturan(_,G,_),Data.aturan).
temuan(Data,masalah(gejala_tidak_digunakan,G)) :-
    member(gejala(G,_,_,_),Data.gejala),
    \+ (member(aturan(_,_,Ps),Data.aturan),is_list(Ps),memberchk(G,Ps)).
temuan(Data,masalah(siklus,G)) :-
    kesimpulan(Data,G), siklus(Data.aturan,G,[]).
temuan(Data,masalah(aturan_duplikat,R1-R2)) :-
    member(aturan(R1,G,P1),Data.aturan), member(aturan(R2,G,P2),Data.aturan),
    R1 @< R2, is_list(P1), is_list(P2), msort(P1,S), msort(P2,S).
temuan(Data,masalah(metadata_aturan,R)) :-
    member(aturan(R,_,_),Data.aturan),
    findall(I,member(aturan_info(R,_,I),Data.info),Infos), length(Infos,N), N =\= 1.
temuan(Data,masalah(metadata_tanpa_aturan,R)) :-
    member(aturan_info(R,_,_),Data.info), \+ member(aturan(R,_,_),Data.aturan).
temuan(Data,masalah(sumber_tidak_dikenal,R-S)) :-
    member(aturan_info(R,Ss,_),Data.info), is_list(Ss), member(S,Ss),
    \+ member(sumber(S,_,_,_,_,_),Data.sumber).
temuan(Data,masalah(batas_aturan,R)) :-
    member(aturan(R,_,_),Data.aturan),
    findall(T,member(aturan_batas(R,T),Data.batas),Ts), length(Ts,N), N =\= 1.
temuan(Data,masalah(batas_tanpa_aturan,R)) :-
    member(aturan_batas(R,_),Data.batas), \+ member(aturan(R,_,_),Data.aturan).
temuan(Data,masalah(saran_gangguan,D)) :-
    member(gangguan(D,_),Data.gangguan),
    findall(I,member(saran(D,I,_),Data.saran),Is), length(Is,N), N =\= 1.
temuan(Data,masalah(saran_tanpa_gangguan,D)) :-
    member(saran(D,_,_),Data.saran), \+ member(gangguan(D,_),Data.gangguan).
temuan(Data,masalah(batas_gangguan,D)) :-
    member(gangguan(D,_),Data.gangguan),
    findall(T,member(gangguan_batas(D,T),Data.batas_gangguan),Ts), length(Ts,N), N =\= 1.
temuan(Data,masalah(batas_tanpa_gangguan,D)) :-
    member(gangguan_batas(D,_),Data.batas_gangguan), \+ member(gangguan(D,_),Data.gangguan).
temuan(Data,masalah(kumpulan_kosong,K)) :-
    member(K,[gejala,gangguan,aturan,saran,sumber]), get_dict(K,Data,[]).
temuan(Data,masalah(status_pengetahuan,Status)) :-
    Status=Data.status, Status \== [status_pengetahuan(draf)].

siklus(_,G,Visited) :- memberchk(G,Visited), !.
siklus(Rules,G,Visited) :-
    member(aturan(_,G,Ps),Rules), is_list(Ps), member(P,Ps),
    siklus(Rules,P,[G|Visited]).

:- multifile prolog:message//1.
prolog:message(error(basis_pengetahuan_tidak_valid(Masalah),_)) -->
    ['Basis pengetahuan tidak valid. Periksa src/knowledge.pl dan src/knowledge_meta.pl: ~p'-[Masalah]].
