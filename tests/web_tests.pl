:- encoding(utf8).
:- use_module('../src/web_app').
:- use_module('../src/knowledge').
:- use_module(library(plunit)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_open)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).

:- dynamic test_port/1.

start_test_server :-
    http_server(http_dispatch, [port(Port)]),
    assertz(test_port(Port)).

stop_test_server :-
    retract(test_port(Port)),
    http_stop_server(Port, []).

api_request(Path, Body, Status, Data) :-
    test_port(Port),
    format(atom(URL), 'http://127.0.0.1:~d~w', [Port, Path]),
    setup_call_cleanup(
        http_open(URL, In, [post(Body), status_code(Status)]),
        json_read_dict(In, Data),
        close(In)).

answers_payload(Yes, Unknown, _{answers: Items}) :-
    findall(_{id: Upper, answer: Answer},
            (gejala(Id, _, _, _), upcase_atom(Id, Upper),
             (memberchk(Id, Yes) -> Answer = ya
             ; memberchk(Id, Unknown) -> Answer = tidak_tahu
             ; Answer = tidak)), Items).

expect_invalid(Payload) :-
    api_request('/api/diagnose', json(Payload), Status, Data),
    assertion(Status == 400),
    assertion(string(Data.error)).

:- begin_tests(web_api, [setup(start_test_server), cleanup(stop_test_server)]).

test(empty_answers) :- expect_invalid(_{answers: []}).
test(non_object_payload) :- expect_invalid([]).
test(missing_answers) :- expect_invalid(_{}).
test(wrong_answers_type) :- expect_invalid(_{answers: "ya"}).
test(non_object_item) :- expect_invalid(_{answers: [42]}).
test(missing_item_field) :- expect_invalid(_{answers: [_{id: "G01"}]}).
test(invalid_id) :-
    answers_payload([], [], Payload), Payload.answers = [_|Rest],
    expect_invalid(_{answers: [_{id: "G99", answer: "ya"}|Rest]}).
test(invalid_answer) :-
    answers_payload([], [], Payload), Payload.answers = [_|Rest],
    expect_invalid(_{answers: [_{id: "G01", answer: "mungkin"}|Rest]}).
test(duplicate_id) :-
    answers_payload([], [], Payload), Payload.answers = [First,_|Rest],
    expect_invalid(_{answers: [First,First|Rest]}).
test(missing_one_answer) :-
    answers_payload([], [], Payload), Payload.answers = [_|Rest],
    expect_invalid(_{answers: Rest}).
test(malformed_json) :-
    api_request('/api/diagnose', atom('application/json', '{broken'), Status, Data),
    assertion(Status == 400), assertion(string(Data.error)).

test(d01_supported) :-
    answers_payload([g01,g02,g03], [], Payload),
    api_request('/api/diagnose', json(Payload), Status, Data),
    assertion(Status == 200), assertion(Data.supported_count == 1),
    Data.diagnoses = [D01|_],
    assertion(D01.id == "D01"), assertion(D01.status == "didukung"),
    D01.paths = [Path], assertion(Path.rules == ["R02","R01"]),
    assertion(D01.advice.id == "S01").

test(d01_unknown) :-
    answers_payload([g01,g02], [g03], Payload),
    api_request('/api/diagnose', json(Payload), 200, Data),
    Data.diagnoses = [D01|_],
    assertion(D01.status == "belum_lengkap"),
    D01.missing = [Missing], assertion(Missing.id == "G03").

test(multiple_diagnoses) :-
    answers_payload([g07,g08,g12], [], Payload),
    api_request('/api/diagnose', json(Payload), 200, Data),
    findall(Id, (member(D, Data.diagnoses), D.status == "didukung", Id = D.id), Ids),
    assertion(Ids == ["D03","D04"]).

test(next_request_does_not_inherit_answers) :-
    answers_payload([g01,g02,g03], [], First),
    api_request('/api/diagnose', json(First), 200, _),
    answers_payload([], [], Second),
    api_request('/api/diagnose', json(Second), 200, Data),
    assertion(Data.supported_count == 0).

test(unsupported_has_no_advice) :-
    answers_payload([], [], Payload),
    api_request('/api/diagnose', json(Payload), 200, Data),
    forall(member(D, Data.diagnoses), assertion(D.advice == null)).

test(partial_start_and_reason) :-
    api_request('/api/consult', json(_{answers: []}), 200, Data),
    assertion(Data.done == false), assertion(Data.question.id == "G01"),
    assertion(Data.question.reason.diagnosis_id == "D01"),
    assertion(Data.question.reason.rules == ["R02","R01"]),
    assertion(Data.answered_count == 0), assertion(Data.total_questions == 15),
    assertion(string(Data.question.help)).

test(negative_skips_irrelevant_premises) :-
    api_request('/api/consult', json(_{answers: [_{id: "G01", answer: "tidak"}]}), 200, Data),
    assertion(Data.question.id == "G04"),
    assertion(Data.question.reason.rules == ["R03"]).

test(unknown_does_not_skip_and_premises) :-
    api_request('/api/consult', json(_{answers: [_{id: "G01", answer: "tidak_tahu"}]}), 200, Data),
    assertion(Data.question.id == "G02").

test(negative_after_unknown_rejects_path) :-
    api_request('/api/consult', json(_{answers: [_{id: "G01", answer: "tidak_tahu"},
                                              _{id: "G02", answer: "tidak"}]}), 200, Data),
    assertion(Data.question.id == "G04").

test(alternative_after_rejected_rule) :-
    api_request('/api/consult', json(_{answers: [_{id: "G01", answer: "tidak"},
                                              _{id: "G04", answer: "tidak"},
                                              _{id: "G05", answer: "ya"}]}), 200, Data),
    assertion(Data.question.id == "G06"),
    assertion(Data.question.reason.rules == ["R04"]).

test(partial_duplicate_rejected) :-
    api_request('/api/consult', json(_{answers: [_{id: "G01", answer: "ya"},
                                              _{id: "g01", answer: "tidak"}]}), Status, Data),
    assertion(Status == 400), assertion(string(Data.error)).

test(partial_unknown_id_rejected) :-
    api_request('/api/consult', json(_{answers: [_{id: "G99", answer: "ya"}]}), Status, Data),
    assertion(Status == 400), assertion(string(Data.error)).

test(partial_invalid_value_rejected) :-
    api_request('/api/consult', json(_{answers: [_{id: "G01", answer: "mungkin"}]}), Status, Data),
    assertion(Status == 400), assertion(string(Data.error)).

test(partial_missing_answers_rejected) :-
    api_request('/api/consult', json(_{}), Status, Data),
    assertion(Status == 400), assertion(string(Data.error)).

test(adaptive_all_negative) :-
    walk_consult([], [], [], Ids, Data),
    assertion(Ids == ["G01","G04","G05","G07","G09","G10","G12","G13","G14","G15"]),
    assertion(Data.done == true), assertion(Data.answered_count == 10),
    assertion(Data.result.supported_count == 0),
    forall(member(D, Data.result.diagnoses), assertion(D.status == "tidak_terpenuhi")).

test(adaptive_d01_and_skipped_answers) :-
    walk_consult(["G01","G02","G03"], [], [], Ids, Data),
    assertion(Ids == ["G01","G02","G03","G04","G05","G07","G09","G10","G12","G13","G14","G15"]),
    assertion(Data.answered_count == 12), assertion(Data.result.supported_count == 1),
    Data.result.diagnoses = [D01|_], assertion(D01.status == "didukung"),
    D01.paths = [Path], assertion(Path.rules == ["R02","R01"]),
    findall(G, (member(S, Path.positive), G = S.id), Positive),
    assertion(Positive == ["G01","G02","G03"]).

test(adaptive_incomplete_d01) :-
    walk_consult(["G01","G02"], ["G03"], [], _, Data),
    Data.result.diagnoses = [D01|_], assertion(D01.status == "belum_lengkap"),
    D01.missing = [Missing], assertion(Missing.id == "G03"),
    assertion(Missing.answer == "tidak_tahu"), assertion(D01.advice == null).

test(adaptive_all_unknown) :-
    findall(Upper, (gejala(Id,_,_,_), upcase_atom(Id, Atom), atom_string(Atom, Upper)), All),
    walk_consult([], All, [], Ids, Data), length(Ids, 15),
    assertion(Data.result.supported_count == 0),
    forall(member(D, Data.result.diagnoses), assertion(D.status == "belum_lengkap")).

test(adaptive_multiple_diagnoses) :-
    walk_consult(["G07","G08","G12"], [], [], _, Data),
    findall(Id, (member(D, Data.result.diagnoses), D.status == "didukung", Id = D.id), Ids),
    assertion(Ids == ["D03","D04"]).

test(corrected_session_has_no_stale_evidence) :-
    walk_consult(["G01","G02","G03"], [], [], _, First),
    assertion(First.result.supported_count == 1),
    walk_consult([], [], [], _, Second),
    assertion(Second.result.supported_count == 0),
    Second.result.diagnoses = [D01|_], D01.paths = [Path],
    assertion(Path.positive == []).

test(direct_battery_diagnosis) :-
    answers_payload([g05],[],P), api_request('/api/diagnose',json(P),200,D),
    assertion(D.supported_count==1),once((member(Found,D.diagnoses),Found.id=="D02")),
    assertion(Found.status=="didukung"),assertion(Found.advice.id=="S02").
test(direct_cooling_diagnosis) :-
    walk_consult(["G09"],[],[],_,D),
    assertion(D.result.supported_count==1),once((member(Found,D.result.diagnoses),Found.id=="D03")),
    assertion(Found.status=="didukung").
test(direct_storage_diagnosis) :-
    walk_consult(["G15"],[],[],_,D),
    assertion(D.result.supported_count==1),once((member(Found,D.result.diagnoses),Found.id=="D05")),
    assertion(Found.status=="didukung").
test(rule_sources_and_limits_in_result) :-
    answers_payload([g05],[],P),api_request('/api/diagnose',json(P),200,D),
    assertion(D.knowledge_status=="draf"),
    once((member(Found,D.diagnoses),Found.id=="D02")),once((member(Path,Found.paths),Path.rules==["R12"])),
    Path.rule_details=[Rule],assertion(Rule.status=="draf"),
    assertion(Rule.sources\==[]),assertion(string(Rule.limits)),
    assertion(string(Found.limits)),assertion(string(Found.alternatives_notice)).
test(knowledge_endpoint_has_brands_and_rule_metadata) :-
    test_port(Port),format(atom(URL),'http://127.0.0.1:~d/api/knowledge',[Port]),
    setup_call_cleanup(http_open(URL,In,[]),json_read_dict(In,D),close(In)),
    assertion(D.status=="draf"),length(D.rules,14),length(D.sources,8),
    assertion(D.total_questions==15),assertion(D.scope.model_verified==false),
    once((member(B,D.brands),B.id=="lenovo")).
test(context_is_normalized_and_not_model_certification) :-
    api_request('/api/consult',json(_{answers:[],context:_{brand:"lenovo",model:"  Model simulasi  "}}),200,D),
    assertion(D.scope.device.model=="Model simulasi"),
    assertion(D.scope.brand_has_sources==true),assertion(D.scope.model_verified==false),
    assertion(D.question.reason.rule_details\==[]).
test(unreferenced_brand_disclosed) :-
    api_request('/api/consult',json(_{answers:[],context:_{brand:"asus"}}),200,D),
    assertion(D.scope.brand_has_sources==false),assertion(string(D.scope.warning)).
test(invalid_context_rejected) :-
    api_request('/api/consult',json(_{answers:[],context:"lenovo"}),400,D),assertion(string(D.error)).
test(unknown_brand_rejected) :-
    answers_payload([],[],P),put_dict(context,P,_{brand:"made_up"},Bad),expect_invalid(Bad).
test(oversized_model_rejected) :-
    length(Cs,81),maplist(=(0'a),Cs),string_codes(Model,Cs),
    api_request('/api/consult',json(_{answers:[],context:_{brand:"hp",model:Model}}),400,D),
    assertion(string(D.error)).
test(completed_consult_keeps_device_context) :-
    answers_payload([],[],P),put_dict(context,P,_{brand:"hp",model:"Model simulasi"},Payload),
    api_request('/api/consult',json(Payload),200,D),
    assertion(D.done==true),assertion(D.result.scope.device.brand=="hp").

:- end_tests(web_api).

:- begin_tests(web_server).

test(stop_closes_http_listener) :-
    run_server_with_input("stop\n", Port),
    assertion(\+ http_current_server(_, Port)).

test(eof_closes_http_listener) :-
    run_server_with_input("", Port),
    assertion(\+ http_current_server(_, Port)).

test(other_input_then_stop) :-
    run_server_with_input("\nselesai\n  stop  \n", Port),
    assertion(\+ http_current_server(_, Port)).

test(startup_failure_restores_signal_handler) :-
    \+ run_server_with_input("", invalid_port).

:- end_tests(web_server).

run_server_with_input(Text, Port) :-
    current_input(PreviousInput),
    on_signal(int, PreviousHandler, PreviousHandler),
    setup_call_cleanup(
        open_string(Text, Input),
        setup_call_cleanup(
            set_input(Input),
            with_output_to(string(_), server(Port)),
            set_input(PreviousInput)),
        ( close(Input),
          on_signal(int, CurrentHandler, CurrentHandler),
          assertion(CurrentHandler == PreviousHandler)
        )).

% Menjalankan konsultasi lewat HTTP: pertanyaan berikutnya hanya dari server.
% Harapan urutan dan hasil ditetapkan eksplisit pada skenario di atas.
walk_consult(Yes, Unknown, Answers, Ids, Data) :-
    api_request('/api/consult', json(_{answers: Answers}), 200, Step),
    ( Step.done == true -> Ids = [], Data = Step
    ; Id = Step.question.id,
      length(Answers, N), assertion(N < 15),
      assertion(\+ (member(A, Answers), get_dict(id, A, Id))),
      (memberchk(Id, Yes) -> Value = "ya"
      ; memberchk(Id, Unknown) -> Value = "tidak_tahu"
      ; Value = "tidak"),
      append(Answers, [_{id: Id, answer: Value}], Next),
      Ids = [Id|Rest], walk_consult(Yes, Unknown, Next, Rest, Data)
    ).
