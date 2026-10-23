:- encoding(utf8).
:- module(gamaban_web, [server/0, server/1]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_json)).
:- use_module(library(lists)).
:- use_module(library(readutil)).
:- use_module(main).
:- use_module(knowledge).
:- use_module(knowledge_check).
:- use_module(explanation).

:- http_handler(root(api/questions), questions_handler, [method(get)]).
:- http_handler(root(api/knowledge), knowledge_handler, [method(get)]).
:- http_handler(root(api/diagnose), diagnose_handler, [method(post)]).
:- http_handler(root(api/consult), consult_handler, [method(post)]).
:- prolog_load_context(directory, SourceDirectory),
   directory_file_path(SourceDirectory, '../web', WebDirectory),
   absolute_file_name(WebDirectory, WebRoot, [file_type(directory)]),
   http_handler(root(.), http_reply_from_files(WebRoot, []), [prefix]).

server :- server(8080).

server(Port) :-
    setup_call_cleanup(
        on_signal(int, PreviousHandler, throw),
        catch(jalankan_server(Port), error(signal(int, _), _), true),
        on_signal(int, _, PreviousHandler)),
    format('Server dihentikan.~n', []).

jalankan_server(Port) :-
    periksa_pengetahuan,
    setup_call_cleanup(
        http_server(http_dispatch, [port(Port)]),
        ( format('Gamaban berjalan di http://localhost:~d/~n', [Port]),
          petunjuk_hentikan_server,
          tunggu_server_selesai
        ),
        http_stop_server(Port, [])).

petunjuk_hentikan_server :-
    format('Tekan Ctrl+C untuk menghentikan server (atau ketik stop lalu Enter).~n', []).

tunggu_server_selesai :-
    current_input(Input),
    read_line_to_string(Input, Line),
    ( Line == end_of_file -> true
    ; normalize_space(string(Command), Line),
      ( Command == "stop" -> true
      ; petunjuk_hentikan_server,
        tunggu_server_selesai
      )
    ).

questions_handler(_Request) :-
    findall(Question,
            ( gejala(Id, Label, Prompt, Help),
              question_dict(Id, Label, Prompt, Help, Question)
            ),
            Questions),
    reply_json_dict(_{questions: Questions}).

knowledge_handler(_Request) :-
    periksa_pengetahuan,
    data_pengetahuan(Data), reply_json_dict(Data).

question_dict(Id, Label, Prompt, Help,
              _{id: IdText, label: Label, prompt: Prompt, help: Help}) :-
    upcase_atom(Id, UpperId),
    atom_string(UpperId, IdText).

diagnose_handler(Request) :-
    catch(( read_payload(Request, Payload),
            evaluate_payload(Payload, Result),
            reply_json_dict(Result)
          ),
          Error,
          reply_api_error(Error)).

consult_handler(Request) :-
    catch(( read_payload(Request, Payload),
            validated_answers(Payload, partial, Answers),
            validated_context(Payload, Context),
            with_mutex(gamaban_diagnosis, consult_answers(Answers, Step)),
            data_cakupan(Context, Scope),
            ( Step.done == true ->
                put_dict(scope, Step.result, Scope, DiagnosisResult),
                put_dict(result, Step, DiagnosisResult, WithResult)
            ; WithResult = Step
            ),
            put_dict(scope, WithResult, Scope, Result),
            reply_json_dict(Result)
          ), Error, reply_api_error(Error)).

read_payload(Request, Payload) :-
    catch(http_read_json_dict(Request, Payload), _, throw(invalid_payload)).

reply_api_error(invalid_payload) :-
    !,
    reply_json_dict(_{error: "Jawaban konsultasi tidak lengkap atau tidak valid."},
                    [status(400)]).
reply_api_error(Error) :-
    print_message(error, Error),
    reply_json_dict(_{error: "Hasil belum dapat dibuat. Silakan coba lagi."},
                    [status(500)]).

evaluate_payload(Payload, Result) :-
    validated_answers(Payload, complete, Answers),
    validated_context(Payload, Context),
    with_mutex(gamaban_diagnosis, evaluate_answers(Answers, Data)),
    data_cakupan(Context, Scope), put_dict(scope, Data, Scope, Result).

validated_context(Payload, Context) :-
    ( get_dict(context,Payload,Input) ->
        (konteks_valid(Input,Context)->true;throw(invalid_payload))
    ; konteks_default(Context)
    ).

validated_answers(Payload, Mode, Answers) :-
    ( valid_answers(Payload, Mode, Answers) -> true ; throw(invalid_payload) ).

valid_answers(Payload, Mode, Answers) :-
    is_dict(Payload),
    get_dict(answers, Payload, Items),
    is_list(Items),
    maplist(parse_answer, Items, Answers),
    findall(Id, gejala(Id, _, _, _), ExpectedIds),
    findall(Id, member(Id-_, Answers), GivenIds),
    msort(ExpectedIds, ExpectedSorted),
    sort(GivenIds, GivenSorted),
    length(GivenIds, Count), length(GivenSorted, Count),
    ( Mode == complete -> ExpectedSorted == GivenSorted ; true ).

parse_answer(Item, Id-Answer) :-
    is_dict(Item),
    get_dict(id, Item, IdText),
    get_dict(answer, Item, AnswerText),
    string(IdText),
    string(AnswerText),
    atom_string(UpperId, IdText),
    downcase_atom(UpperId, Id),
    gejala(Id, _, _, _),
    atom_string(Answer, AnswerText),
    memberchk(Answer, [ya, tidak, tidak_tahu]).

evaluate_answers(Answers, Result) :-
    restore_answers(Answers),
    pakar_laptop:evaluasi_semua(tersimpan, Diagnoses),
    result_dict(Diagnoses, Result).

restore_answers(Answers) :-
    pakar_laptop:mulai_sesi,
    maplist(save_answer, Answers).

consult_answers(Answers, Result) :-
    restore_answers(Answers),
    pakar_laptop:langkah_konsultasi(Step),
    step_dict(Step, Data),
    length(Answers, Count),
    findall(G, gejala(G, _, _, _), Symptoms), length(Symptoms, Total),
    put_dict(_{answered_count: Count, total_questions: Total}, Data, Result).

step_dict(pertanyaan(G, D, Rules), _{done: false, question: Question}) :-
    gejala(G, Label, Prompt, Help),
    question_dict(G, Label, Prompt, Help, Base),
    gangguan(D, Name), upper_string(D, DiagnosisId),
    maplist(upper_string, Rules, RuleIds),
    maplist(penjelasan_aturan, Rules, RuleDetails),
    put_dict(_{reason: _{diagnosis_id: DiagnosisId, name: Name, rules: RuleIds,
                        rule_details: RuleDetails}},
             Base, Question).
step_dict(selesai(Diagnoses), _{done: true, result: Result}) :-
    result_dict(Diagnoses, Result).

result_dict(Diagnoses, Result) :-
    maplist(diagnosis_dict, Diagnoses, DiagnosisData),
    include(is_supported, Diagnoses, Supported),
    length(Supported, SupportedCount),
    length(Diagnoses, Total),
    Result = _{supported_count: SupportedCount,
               total_count: Total,
               knowledge_status: draf,
               draft_notice: "Hasil ini adalah dugaan awal dari pengetahuan draf, bukan diagnosis teknisi.",
               diagnoses: DiagnosisData}.

save_answer(Id-Answer) :- pakar_laptop:simpan_jawaban(Id, Answer).

is_supported(hasil(_, didukung, _, _)).

diagnosis_dict(hasil(Id, Status, Paths, Missing),
               _{id: IdText, name: Name, status: StatusText,
                 status_label: StatusLabel, paths: PathData,
                 missing: MissingData, advice: Advice,limits:Limits,
                 alternatives_notice:"Cukup satu jalur yang sesuai. Beberapa jalur untuk dugaan yang sama bukan beberapa diagnosis dan bukan persentase kepastian."}) :-
    gangguan(Id, Name),
    gangguan_batas(Id,Limits),
    atom_string(Status, StatusText),
    status_label(Status, StatusLabel),
    maplist(path_dict, Paths, PathData),
    maplist(missing_dict, Missing, MissingData),
    ( Status == didukung -> advice_dict(Id, Advice) ; Advice = null ),
    upcase_atom(Id, UpperId),
    atom_string(UpperId, IdText).

status_label(didukung, "Ada gejala yang mendukung aturan ini").
status_label(belum_lengkap, "Informasi belum cukup").
status_label(tidak_terpenuhi, "Belum ada aturan yang didukung").

path_dict(Path,
         _{rules: RuleIds, status: StatusText, status_label: StatusLabel,
           rule_details:RuleDetails,
           positive: PositiveData, rejected: RejectedData,
           missing: MissingData}) :-
    pakar_laptop:ringkas_jalur(Path, Rules, Positive, Missing, Rejected),
    maplist(upper_string, Rules, RuleIds),
    maplist(penjelasan_aturan, Rules, RuleDetails),
    Path = jalur(_, Status, _, _),
    atom_string(Status, StatusText),
    status_label(Status, StatusLabel),
    maplist(symptom_dict, Positive, PositiveData),
    maplist(symptom_dict, Rejected, RejectedData),
    maplist(missing_dict, Missing, MissingData).

symptom_dict(Id,
             _{id: IdText, label: Label}) :-
    gejala(Id, Label, _, _),
    upper_string(Id, IdText).

missing_dict(kurang(Id, Answer),
             _{id: IdText, label: Label, answer: AnswerText}) :-
    gejala(Id, Label, _, _),
    upper_string(Id, IdText),
    atom_string(Answer, AnswerText).

advice_dict(Id, _{id: AdviceIdText, text: Text}) :-
    saran(Id, AdviceId, Text),
    !,
    upper_string(AdviceId, AdviceIdText).
advice_dict(_, null).

upper_string(Atom, Text) :-
    upcase_atom(Atom, Upper),
    atom_string(Upper, Text).
