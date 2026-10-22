:- encoding(utf8).
:- module(gamaban_web, [server/0, server/1]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_json)).
:- use_module(library(lists)).
:- use_module(main).
:- use_module(knowledge).

:- http_handler(root(api/questions), questions_handler, [method(get)]).
:- http_handler(root(api/diagnose), diagnose_handler, [method(post)]).
:- prolog_load_context(directory, SourceDirectory),
   directory_file_path(SourceDirectory, '../web', WebDirectory),
   absolute_file_name(WebDirectory, WebRoot, [file_type(directory)]),
   http_handler(root(.), http_reply_from_files(WebRoot, []), [prefix]).

server :- server(8080).

server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    format('Gamaban berjalan di http://localhost:~d/~n', [Port]),
    thread_get_message(stop).

questions_handler(_Request) :-
    findall(Question,
            ( gejala(Id, Label, Prompt, Help),
              question_dict(Id, Label, Prompt, Help, Question)
            ),
            Questions),
    reply_json_dict(_{questions: Questions}).

question_dict(Id, Label, Prompt, Help,
              _{id: IdText, label: Label, prompt: Prompt, help: Help}) :-
    upcase_atom(Id, UpperId),
    atom_string(UpperId, IdText).

diagnose_handler(Request) :-
    catch(( http_read_json_dict(Request, Payload),
            evaluate_payload(Payload, Result),
            reply_json_dict(Result)
          ),
          _,
          reply_json_dict(_{error: "Jawaban konsultasi tidak lengkap atau tidak valid."},
                          [status(400)])).

evaluate_payload(Payload, Result) :-
    get_dict(answers, Payload, Items),
    is_list(Items),
    maplist(parse_answer, Items, Answers),
    findall(Id, gejala(Id, _, _, _), ExpectedIds),
    findall(Id, member(Id-_, Answers), GivenIds),
    msort(ExpectedIds, ExpectedSorted),
    msort(GivenIds, GivenSorted),
    ExpectedSorted == GivenSorted,
    with_mutex(gamaban_diagnosis,
               evaluate_answers(Answers, Result)).

parse_answer(Item, Id-Answer) :-
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
    pakar_laptop:mulai_sesi,
    maplist(save_answer, Answers),
    pakar_laptop:evaluasi_semua(tersimpan, Diagnoses),
    maplist(diagnosis_dict, Diagnoses, DiagnosisData),
    include(is_supported, Diagnoses, Supported),
    length(Supported, SupportedCount),
    Result = _{supported_count: SupportedCount,
               total_count: 5,
               draft_notice: "Hasil ini adalah dugaan awal dari pengetahuan draf, bukan diagnosis teknisi.",
               diagnoses: DiagnosisData}.

save_answer(Id-Answer) :- pakar_laptop:simpan_jawaban(Id, Answer).

is_supported(hasil(_, didukung, _, _)).

diagnosis_dict(hasil(Id, Status, Paths, Missing),
               _{id: IdText, name: Name, status: StatusText,
                 status_label: StatusLabel, paths: PathData,
                 missing: MissingData, advice: Advice}) :-
    gangguan(Id, Name),
    atom_string(Status, StatusText),
    status_label(Status, StatusLabel),
    maplist(path_dict, Paths, PathData),
    maplist(missing_dict, Missing, MissingData),
    advice_dict(Id, Advice),
    upcase_atom(Id, UpperId),
    atom_string(UpperId, IdText).

status_label(didukung, "Ada gejala yang mendukung aturan ini").
status_label(belum_lengkap, "Informasi belum cukup").
status_label(tidak_terpenuhi, "Belum ada aturan yang didukung").

path_dict(Path,
         _{rules: RuleIds, status: StatusText, status_label: StatusLabel,
           positive: PositiveData, rejected: RejectedData,
           missing: MissingData}) :-
    pakar_laptop:ringkas_jalur(Path, Rules, Positive, Missing, Rejected),
    maplist(upper_string, Rules, RuleIds),
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
advice_dict(_, @(null)).

upper_string(Atom, Text) :-
    upcase_atom(Atom, Upper),
    atom_string(Upper, Text).
