:- encoding(utf8).
:- module(penjelasan_laptop,
          [ penjelasan_aturan/2, data_sumber/2, data_cakupan/2,
            konteks_valid/2, konteks_default/1, data_pengetahuan/1 ]).
:- use_module(knowledge).
:- use_module(library(lists)).

huruf_besar(Id,Text) :- upcase_atom(Id,A), atom_string(A,Text).
nama_node(G,N) :- gejala(G,N,_,_), !.
nama_node(G,N) :- gangguan(G,N), !.
nama_node(G,N) :- indikasi(G,N).
data_node(G,_{id:Id,label:Name}) :- huruf_besar(G,Id), nama_node(G,Name).

data_sumber(Id,_{id:Text,title:Title,url:URL,brand:Brand,accessed:Date,limits:Limits}) :-
    sumber(Id,Title,URL,Brand,Date,Limits), huruf_besar(Id,Text).

penjelasan_aturan(Id,
                 _{id:Text,conclusion:Conclusion,premises:Premises,
                   operator:"AND",status:Status,
                   status_label:"Draf; belum divalidasi teknisi",
                   sources:Sources,limits:Limits}) :-
    aturan(Id,Goal,Conditions), aturan_info(Id,Refs,Status), aturan_batas(Id,Limits),
    huruf_besar(Id,Text), data_node(Goal,Conclusion),
    maplist(data_node,Conditions,Premises), maplist(data_sumber,Refs,Sources).

konteks_default(_{brand:"tidak_diketahui",model:""}).

konteks_valid(In,Out) :-
    is_dict(In),
    (get_dict(brand,In,Brand)->true;Brand="tidak_diketahui"),
    (get_dict(model,In,Model)->true;Model=""),
    string(Brand), atom_string(BrandId,Brand), panduan_merek(BrandId,_,_),
    string(Model), string_length(Model,N), N =< 80,
    normalize_space(string(Clean),Model),
    Out = _{brand:Brand,model:Clean}.

data_cakupan(Context,
             _{notice:Notice,device:Context,brand_label:BrandLabel,
               manufacturer_url:URL,brand_has_sources:HasSources,
               model_verified:false,warning:Warning}) :-
    atom_string(Brand,Context.brand), panduan_merek(Brand,BrandLabel,URL),
    cakupan_pengetahuan(Notice),
    ( sumber(_,_,_,Brand,_,_) ->
        HasSources = true,
        Warning = 'Ada rujukan umum untuk merek ini. Model dan kombinasi aturan belum divalidasi teknisi. Cocokkan pesan dan hasil tes dengan panduan model Anda.'
    ; HasSources = false,
      Warning = 'Belum ada rujukan khusus untuk merek yang dipilih. Hasil merupakan pencocokan aturan draf, belum menjadi diagnosis yang tervalidasi pada merek/model ini.'
    ).

data_pengetahuan(_{status:draf,scope:Scope,brands:Brands,rules:Rules,sources:Sources,
                   total_questions:Total}) :-
    findall(G,gejala(G,_,_,_),Gejala), length(Gejala,Total),
    konteks_default(Context), data_cakupan(Context,Scope),
    findall(_{id:Id,label:Label,url:URL},
            (panduan_merek(Brand,Label,URL),atom_string(Brand,Id)),Brands),
    findall(R,(aturan(Id,_,_),penjelasan_aturan(Id,R)),Rules),
    findall(S,(sumber(Id,_,_,_,_,_),data_sumber(Id,S)),Sources).
