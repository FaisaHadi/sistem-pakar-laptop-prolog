:- encoding(utf8).
:- use_module('../src/main').
:- use_module('../src/knowledge').
:- use_module('../src/knowledge_check').
:- use_module('../src/explanation').
:- use_module('../src/domain_validation').
:- use_module(library(plunit)).
:- use_module(library(time)).
:- use_module(library(lists)).

kb_ubah(Key,Value,Problems) :-
    salinan_pengetahuan(Data), put_dict(Key,Data,Value,Changed),
    validasi_data(Changed,Problems).

:- begin_tests(knowledge_integrity).
test(production_knowledge_valid) :- validasi_pengetahuan([]).
test(malformed_data) :- validasi_data([], [masalah(format_data,pengetahuan)]).
test(duplicate_node) :-
    salinan_pengetahuan(D), D.gejala = [G|_],
    kb_ubah(gejala,[G|D.gejala],P), assertion(member(masalah(id_node_duplikat,g01),P)).
test(duplicate_rule_id) :-
    salinan_pengetahuan(D), D.aturan=[R|_],
    kb_ubah(aturan,[R|D.aturan],P), assertion(member(masalah(id_duplikat,aturan-r01),P)).
test(unknown_premise) :-
    salinan_pengetahuan(D), D.aturan=[_|Rs],
    kb_ubah(aturan,[aturan(r01,i01,[g99])|Rs],P),
    assertion(member(masalah(premis_tidak_dikenal,r01-g99),P)).
test(unknown_conclusion) :-
    salinan_pengetahuan(D), D.aturan=[_|Rs],
    kb_ubah(aturan,[aturan(r01,i99,[g01,g02])|Rs],P),
    assertion(member(masalah(kesimpulan_tidak_dikenal,r01-i99),P)).
test(empty_premise) :-
    salinan_pengetahuan(D), D.aturan=[_|Rs],
    kb_ubah(aturan,[aturan(r01,i01,[])|Rs],P),
    assertion(member(masalah(format_item,aturan-aturan(r01,i01,[])),P)).
test(repeated_premise) :-
    salinan_pengetahuan(D), D.aturan=[_|Rs],
    kb_ubah(aturan,[aturan(r01,i01,[g01,g01])|Rs],P), assertion(P \== []).
test(self_cycle_fails_fast) :-
    salinan_pengetahuan(D), D.aturan=[_|Rs],
    call_with_time_limit(2,kb_ubah(aturan,[aturan(r01,i01,[i01])|Rs],P)),
    assertion(member(masalah(siklus,i01),P)).
test(indirect_cycle_fails_fast) :-
    salinan_pengetahuan(D), D.aturan=[_,_|Rs],
    call_with_time_limit(2,kb_ubah(aturan,[aturan(r01,i01,[d01]),aturan(r02,d01,[i01])|Rs],P)),
    assertion(member(masalah(siklus,d01),P)).
test(duplicate_rule_body) :-
    salinan_pengetahuan(D),
    kb_ubah(aturan,[aturan(r99,d02,[g05])|D.aturan],P),
    assertion(member(masalah(aturan_duplikat,r12-r99),P)).
test(missing_rule_metadata) :-
    salinan_pengetahuan(D), D.info=[_|Is], kb_ubah(info,Is,P),
    assertion(member(masalah(metadata_aturan,r01),P)).
test(unknown_source) :-
    salinan_pengetahuan(D), D.info=[_|Is],
    kb_ubah(info,[aturan_info(r01,[b99],draf)|Is],P),
    assertion(member(masalah(sumber_tidak_dikenal,r01-b99),P)).
test(unreviewed_validated_status_rejected) :-
    salinan_pengetahuan(D), D.info=[_|Is],
    kb_ubah(info,[aturan_info(r01,[b01],tervalidasi)|Is],P), assertion(P \== []).
test(global_validated_status_rejected) :-
    kb_ubah(status,[status_pengetahuan(tervalidasi)],P),assertion(P \== []).
test(unsafe_source_url) :-
    salinan_pengetahuan(D), D.sumber=[sumber(I,T,_,M,F,B)|Ss],
    kb_ubah(sumber,[sumber(I,T,'javascript:alert(1)',M,F,B)|Ss],P), assertion(P \== []).
test(missing_rule_limits) :-
    salinan_pengetahuan(D), D.batas=[_|Bs], kb_ubah(batas,Bs,P),
    assertion(member(masalah(batas_aturan,r01),P)).
test(missing_advice) :-
    salinan_pengetahuan(D), D.saran=[_|Ss], kb_ubah(saran,Ss,P),
    assertion(member(masalah(saran_gangguan,d01),P)).
test(orphan_symptom) :-
    salinan_pengetahuan(D),
    kb_ubah(gejala,[gejala(g99,'Label','Pertanyaan','Bantuan')|D.gejala],P),
    assertion(member(masalah(gejala_tidak_digunakan,g99),P)).
test(empty_knowledge) :- kb_ubah(aturan,[],P), assertion(member(masalah(kumpulan_kosong,aturan),P)).
:- end_tests(knowledge_integrity).

% Oracle ditulis langsung dari kontrak revisi; tidak membaca aturan/3.
oracle_spec(d01,[g01,g02,g03],[[g01,g02,g03]]).
oracle_spec(d02,[g04,g05,g06],[[g05]]).
oracle_spec(d03,[g07,g08,g09],[[g07,g08],[g09]]).
oracle_spec(d04,[g10,g11,g12],[[g10,g11],[g12]]).
oracle_spec(d05,[g13,g14,g15],[[g13,g14],[g15]]).
oracle_pattern([],[],_).
oracle_pattern([G|Gs],[G-V|Rest],Values) :- member(V,Values),oracle_pattern(Gs,Rest,Values).
oracle_value(Answers,G,V) :- (memberchk(G-X,Answers)->V=X;V=tidak).
oracle_rule(Answers,Rule,N) :-
    maplist(oracle_value(Answers),Rule,Values),
    (memberchk(tidak,Values)->N=0;forall(member(V,Values),V==ya)->N=2;N=1).
oracle_expected(D,Answers,Status) :-
    oracle_spec(D,_,Rules),maplist(oracle_rule(Answers),Rules,Statuses),max_list(Statuses,N),
    nth0(N,[tidak_terpenuhi,belum_lengkap,didukung],Status).
oracle_restore(Answers) :-
    mulai_sesi,forall(gejala(G,_,_,_),
        (oracle_value(Answers,G,V),(V==belum_ditanya->true;simpan_jawaban(G,V)))).
oracle_check(Answers,Results) :-
    forall(member(hasil(D,S,Paths,_),Results),
           (oracle_expected(D,Answers,E),assertion(S==E),
            forall(member(Path,Paths),
                   (Path=jalur(_,didukung,_,_)->
                        ringkas_jalur(Path,_,Positive,[],[]),assertion(Positive\==[]),
                        forall(member(G,Positive),assertion(oracle_value(Answers,G,ya)))
                   ;true)))).
oracle_walk(Answers,Seen,Results) :-
    length(Seen,N),assertion(N=<15),langkah_konsultasi(Step),
    (Step=selesai(Results)->true
    ;Step=pertanyaan(G,_,_),assertion(\+memberchk(G,Seen)),
     oracle_value(Answers,G,V),simpan_jawaban(G,V),oracle_walk(Answers,[G|Seen],Results)).

:- begin_tests(expert_reasoning).
test(direct_battery_evidence) :-
    oracle_restore([g05-ya]),evaluasi(d02,tersimpan,hasil(d02,didukung,Paths,[])),
    assertion(member(jalur(r12,didukung,_,[]),Paths)).
test(direct_cooling_evidence) :-
    oracle_restore([g09-ya]),evaluasi(d03,tersimpan,hasil(d03,didukung,Paths,[])),
    assertion(member(jalur(r13,didukung,_,[]),Paths)).
test(direct_storage_evidence) :-
    oracle_restore([g15-ya]),evaluasi(d05,tersimpan,hasil(d05,didukung,Paths,[])),
    assertion(member(jalur(r14,didukung,_,[]),Paths)).
test(unknown_direct_evidence_not_positive) :-
    oracle_restore([g05-tidak_tahu,g09-tidak_tahu,g15-tidak_tahu]),
    evaluasi_semua(tersimpan,H),oracle_check([g05-tidak_tahu,g09-tidak_tahu,g15-tidak_tahu],H),
    assertion(\+member(hasil(_,didukung,_,_),H)).
test(independent_320_status_and_evidence_cases) :-
    findall(A,(oracle_spec(_,Gs,_),oracle_pattern(Gs,A,[ya,tidak,tidak_tahu,belum_ditanya])),Cases),
    length(Cases,320),forall(member(A,Cases),(oracle_restore(A),evaluasi_semua(tersimpan,R),oracle_check(A,R))).
test(independent_135_adaptive_consultations) :-
    findall(A,(oracle_spec(_,Gs,_),oracle_pattern(Gs,A,[ya,tidak,tidak_tahu])),Cases),
    length(Cases,135),forall(member(A,Cases),(mulai_sesi,oracle_walk(A,[],R),oracle_check(A,R))).
test(all_rules_have_explanation) :-
    forall(aturan(R,G,Ps),
           (penjelasan_aturan(R,D),assertion(D.status==draf),
            assertion(D.sources\==[]),length(Ps,N),length(D.premises,N),
            upcase_atom(G,A),atom_string(A,Text),assertion(D.conclusion.id==Text))).
test(known_brand_not_model_verified) :-
    data_cakupan(_{brand:"lenovo",model:"Model simulasi"},Scope),
    assertion(Scope.brand_has_sources==true),assertion(Scope.model_verified==false).
test(unreferenced_brand_has_warning) :-
    data_cakupan(_{brand:"asus",model:"Model simulasi"},Scope),
    assertion(Scope.brand_has_sources==false),assertion(Scope.warning\=='').
:- end_tests(expert_reasoning).

% Data berikut seluruhnya sintetis, hanya untuk menguji pembanding.
synthetic_case(Yes,Expected,C) :-
    findall(_{id:Id,answer:J},
            (gejala(G,_,_,_),atom_string(G,Id),(memberchk(G,Yes)->J="ya";J="tidak")),Answers),
    C=_{id:"sintetis-01",reviewer:"Peninjau fiktif untuk tes",review_date:"2026-10-23",
        context:_{brand:"hp",model:"Model simulasi"},answers:Answers,expected_supported:Expected}.

:- begin_tests(domain_validation).
test(no_cases_means_no_accuracy) :-
    evaluasi_dataset(_{schema_version:1,cases:[]},R),
    assertion(R.case_count==0),assertion(R.exact_match_rate==null),
    assertion(R.status==belum_ada_kasus),assertion(R.knowledge_status==draf).
test(synthetic_match) :-
    synthetic_case([g05],["d02"],C),evaluasi_dataset(_{schema_version:1,cases:[C]},R),
    assertion(R.matching_cases==1),assertion(R.exact_match_rate=:=1),
    assertion(R.knowledge_status==draf).
test(synthetic_disagreement_reports_both_directions) :-
    synthetic_case([g05],["d01"],C),evaluasi_dataset(_{schema_version:1,cases:[C]},R),
    R.results=[Case],assertion(Case.false_positive==[d02]),assertion(Case.false_negative==[d01]).
test(no_reviewer_rejected,[throws(error(dataset_validasi_tidak_valid,_))]) :-
    synthetic_case([],[],C),put_dict(reviewer,C,"",Bad),evaluasi_dataset(_{schema_version:1,cases:[Bad]},_).
test(no_model_rejected,[throws(error(dataset_validasi_tidak_valid,_))]) :-
    synthetic_case([],[],C),put_dict(context,C,_{brand:"hp",model:""},Bad),evaluasi_dataset(_{schema_version:1,cases:[Bad]},_).
test(duplicate_case_ids_rejected,[throws(error(dataset_validasi_tidak_valid,_))]) :-
    synthetic_case([],[],C),evaluasi_dataset(_{schema_version:1,cases:[C,C]},_).
test(incomplete_answers_rejected,[throws(error(dataset_validasi_tidak_valid,_))]) :-
    synthetic_case([],[],C),C.answers=[_|Rest],put_dict(answers,C,Rest,Bad),evaluasi_dataset(_{schema_version:1,cases:[Bad]},_).
test(unknown_label_rejected,[throws(error(dataset_validasi_tidak_valid,_))]) :-
    synthetic_case([],["d99"],C),evaluasi_dataset(_{schema_version:1,cases:[C]},_).
:- end_tests(domain_validation).
