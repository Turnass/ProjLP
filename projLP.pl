% 106658, Antonio Pinheiro Rodrigues Ortigao Delgado
:- set_prolog_flag(answer_write_options,[max_depth(0)]).
:- ["dados.pl"], ["keywords.pl"].

eventosSemSalas(Eventos) :-
     /*
     Verdade quando Eventos corresponde a lista de eventos sem sala.
     */
     findall(ID, evento(ID, _, _, _, semSala), Eventos).

eventosSemSalasDiaSemana(Dia, Eventos) :-
     /*
     Verdade quando Eventos corresponde a lista de eventos sem sala no dia da semana Dia.
     */
     findall(ID, (evento(ID, _, _, _, semSala), horario(ID, Dia, _, _, _, _)), Eventos).

eventosSemSalasPeriodo(P, Eventos) :-
     /*
     Verdade quando Eventos corresponde a lista de eventos sem sala no periodo P,
     incluindo as cadeiras semestrais.
     */
    eventosSemSalasPeriodo(P, [], E), !,
    sort(E, Eventos).

eventosSemSalasPeriodo([], Eventos, Eventos).

eventosSemSalasPeriodo([H | T], Acum, Eventos) :-
     name(H, F),
     nth0(1, F, L),
     (L == 49; L == 50) ->
     findall(ID, (evento(ID, _, _, _, semSala), (horario(ID, _, _, _, _, H); horario(ID, _, _, _, _, p1_2))), A),
     append(Acum, A, Aux),
     eventosSemSalasPeriodo(T, Aux, Eventos).

eventosSemSalasPeriodo([H | T], Acum, Eventos) :-
     name(H, F),
     nth0(1, F, L),
     (L == 51; L == 52) ->
     findall(ID, (evento(ID, _, _, _, semSala), (horario(ID, _, _, _, _, H); horario(ID, _, _, _, _, p3_4))), A),
     append(Acum, A, Aux),
     eventosSemSalasPeriodo(T, Aux, Eventos).

organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) :-
     /*
     Verdade quando EventosNoPeriodo corresponde a lista de IDs da lista
     ListaEventos no periodo Periodo.
     */
     organizaEventos(ListaEventos, Periodo, [], E), !,
     sort(E, EventosNoPeriodo).

organizaEventos([], _, EventosNoPeriodo, EventosNoPeriodo).

organizaEventos(ListaEventos, Periodo, Acum, EventosNoPeriodo) :-
     ListaEventos = [H | T],
     name(Periodo, F),
     nth0(1, F, L),
     (L == 49; L == 50),
     (horario(H, _, _, _, _, Periodo); horario(H, _, _, _, _, p1_2)),
     append([H], Acum, Aux),
     organizaEventos(T, Periodo, Aux, EventosNoPeriodo).

organizaEventos(ListaEventos, Periodo, Acum, EventosNoPeriodo) :-
     ListaEventos = [H | T],
     name(Periodo, F),
     nth0(1, F, L),
     (L == 51; L == 52),
     (horario(H, _, _, _, _, Periodo); horario(H, _, _, _, _, p3_4)),
     append([H], Acum, Aux),
     organizaEventos(T, Periodo, Aux, EventosNoPeriodo).

organizaEventos(ListaEventos, Periodo, Acum, EventosNoPeriodo) :-
     ListaEventos = [_ | T],
     organizaEventos(T, Periodo, Acum, EventosNoPeriodo).

eventosMenoresQue(Duracao, ListaEventosMenoresQue) :-
     /*
     Verdade quando ListaEventosMenoresQue corresponde a lista de eventos com
     duracao menor ou igual a Duracao.
     */
     findall(ID, (horario(ID, _, _, _, Dur, _), Dur =< Duracao), ListaEventosMenoresQue).

eventosMenoresQueBool(ID, Duracao) :-
     /*
     Verdade quando a Duracao e maior ou igual que a duraco do evento
     com id ID.
     */
     (horario(ID, _, _, _, Dur, _), Dur =< Duracao).

procuraDisciplinas(Curso, ListaDisciplinas) :-
     /*
     Verdade quando ListaDisciplinas corresponde a uma lista ordenada e sem elementos repetidos
     de todas as disciplinas do curso Curso.
     */
     findall(Disciplinas, (turno(ID, Curso, _, _), evento(ID, Disciplinas, _, _, _)), L),
     sort(L, ListaDisciplinas).

organizaDisciplinas(ListaDisciplinas, Curso, Semestres) :-
     /*
     Verdade quando Semestres correspode a uma lista com duas listas
     ambas contendo disciplinas da ListaDisciplinas que estao no curso
     Curso, sendo que, a primeira corresponde as disciplinas do primeiro
     semestre e a segunda do segundo. As duas ordenadas, sem
     elementos repetidos e abstraindo todas as disciplinas dentro
     da ListaDisciplinas.
     */
     organizaDisciplinas(ListaDisciplinas, Curso, [[], []], Semestres), !.

organizaDisciplinas([], _, Semestres, Semestres).

organizaDisciplinas(ListaDisciplinas, Curso, [Acum1, Acum2], Semestres) :-
     ListaDisciplinas = [H | T],
     evento(ID, H, _, _, _), turno(ID, Curso, _, _),  (horario(ID, _, _, _, _, p1); horario(ID, _, _, _, _, p2); horario(ID, _, _, _, _, p1_2)),
     append([H], Acum1, A),
     sort(A, Aux1),
     organizaDisciplinas(T, Curso, [Aux1, Acum2], Semestres).

organizaDisciplinas(ListaDisciplinas, Curso, [Acum1, Acum2], Semestres) :-
     ListaDisciplinas = [H | T],
     evento(ID, H, _, _, _), turno(ID, Curso, _, _), (horario(ID, _, _, _, _, p3); horario(ID, _, _, _, _, p4); horario(ID, _, _, _, _, p3_4)),
     append([H], Acum2, A),
     sort(A, Aux2),
     organizaDisciplinas(T, Curso, [Acum1, Aux2], Semestres).

horasCurso(Periodo, Curso, Ano, T) :-
     /*
     Verdade quando T corresponde a soma das horas do curso Curso
     num determinado ano Ano, no periodo Periodo (constando ainda
     com cadeiras semestrais).
     */
     name(Periodo, F),
     nth0(1, F, L),
     (L == 49; L == 50),
     findall(ID, ((horario(ID, _, _, _, Horas, Periodo); horario(ID, _, _, _, Horas, p1_2)), turno(ID, Curso, Ano, _)), IDS),
     sort(IDS, Limpa),
     findall(Horas, (member(ID, Limpa), horario(ID, _, _, _, Horas, _)), Horasfixes),
     sum_list(Horasfixes, T), !.

horasCurso(Periodo, Curso, Ano, T) :-
     name(Periodo, F),
     nth0(1, F, L),
     (L == 51; L == 52),
     findall(ID, ((horario(ID, _, _, _, Horas, Periodo); horario(ID, _, _, _, Horas, p3_4)), turno(ID, Curso, Ano, _)), IDS),
     sort(IDS, Limpa),
     findall(Horas, (member(ID, Limpa), horario(ID, _, _, _, Horas, _)), Horasfixes),
     sum_list(Horasfixes, T), !.

evolucaoHorasCurso(Curso, Evolucao) :-
     /*
     Verdade quando Evolucao corresponde ao numero total de horas
     que o curso Curso demora.
     */
     evolucaoHorasCurso(Curso, [], Evolucao), !.

evolucaoHorasCurso(a, Evolucao, Evolucao).

evolucaoHorasCurso(Curso, Acum, Evolucao) :-
     horasCurso(p1, Curso, 1, T),
     append(Acum, [(1, p1, T)], Aux1),
     horasCurso(p2, Curso, 1, T1),
     append(Aux1, [(1, p2, T1)], Aux2),
     horasCurso(p3, Curso, 1, T2),
     append(Aux2, [(1, p3, T2)], Aux3),
     horasCurso(p4, Curso, 1, T3),
     append(Aux3, [(1, p4, T3)], Aux4),
     horasCurso(p1, Curso, 2, T4),
     append(Aux4, [(2, p1, T4)], Aux5),
     horasCurso(p2, Curso, 2, T5),
     append(Aux5, [(2, p2, T5)], Aux6),
     horasCurso(p3, Curso, 2, T6),
     append(Aux6, [(2, p3, T6)], Aux7),
     horasCurso(p4, Curso, 2, T7),
     append(Aux7, [(2, p4, T7)], Aux8),
     horasCurso(p1, Curso, 3, T8),
     append(Aux8, [(3, p1, T8)], Aux9),
     horasCurso(p2, Curso, 3, T9),
     append(Aux9, [(3, p2, T9)], Aux10),
     horasCurso(p3, Curso, 3, T10),
     append(Aux10, [(3, p3, T10)], Aux11),
     horasCurso(p4, Curso, 3, T11),
     append(Aux11, [(3, p4, T11)], Evolucao),
     evolucaoHorasCurso(a, Evolucao, Evolucao).

ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
     /*
     Verdade quando Horas corresponde ao numero de horas que
     se encontra no intervalo resultante da intersecao do intervalo
     [HoraInicioEvento, HoraFimEvento] com o intervalo [HoraIncioDada, HoraFimDada].
     */
     (HoraInicioDada < HoraFimEvento, HoraFimDada > HoraInicioEvento),
     HoraFimDada =< HoraFimEvento,
     HoraInicioDada =< HoraInicioEvento,
     Horas is HoraFimDada - HoraInicioEvento, !.

ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
     (HoraInicioDada < HoraFimEvento, HoraFimDada > HoraInicioEvento),
     HoraFimDada >= HoraFimEvento,
     HoraInicioDada >= HoraInicioEvento,
     Horas is HoraFimEvento - HoraInicioDada, !.

ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
     (HoraInicioDada < HoraFimEvento, HoraFimDada > HoraInicioEvento),
     HoraFimDada =< HoraFimEvento,
     HoraInicioDada >= HoraInicioEvento,
     TempoDado is HoraFimDada - HoraInicioDada,
     Horas is TempoDado, !.

ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
     (HoraInicioDada < HoraFimEvento, HoraFimDada > HoraInicioEvento),
     HoraFimDada >= HoraFimEvento,
     HoraInicioDada =< HoraInicioEvento,
     TempoEvento is HoraFimEvento - HoraInicioEvento,
     Horas is TempoEvento, !.

numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) :-
     /*
     Verdade quando SomaHoras corresponde ao numero de horas ocupadas
     nos dias da semanda DiaSemana nas salas correspondentes ao TipoSala
     das HoraInicio as HoraFim no Periodo (constando com cadeiras semestrais).
     */
     name(Periodo, F),
     nth0(1, F, L),
     (L == 49; L == 50),
     findall(ID, (horario(ID, DiaSemana, _, _, _, Periodo); horario(ID, DiaSemana, _, _, _, p1_2)), IDS),
     findall(ID, (evento(ID, _, _, _, Sala), member(ID, IDS), salas(TipoSala, Salas), member(Sala, Salas)), IDS_FIXES),
     findall(Hora, (member(ID, IDS_FIXES), horario(ID, _, HoraInicioEvento, HoraFimEvento, _, _),
     ocupaSlot(HoraInicio, HoraFim, HoraInicioEvento, HoraFimEvento, Hora)), Horas),
     sum_list(Horas, SomaHoras), !.

numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) :-
     name(Periodo, F),
     nth0(1, F, L),
     (L == 51; L == 52),
     findall(ID, (horario(ID, DiaSemana, _, _, _, Periodo); horario(ID, DiaSemana, _, _, _, p3_4)), IDS),
     findall(ID, (evento(ID, _, _, _, Sala), member(ID, IDS), salas(TipoSala, Salas), member(Sala, Salas)), IDS_FIXES),
     findall(Hora, (member(ID, IDS_FIXES), horario(ID, _, HoraInicioEvento, HoraFimEvento, _, _),
     ocupaSlot(HoraInicio, HoraFim, HoraInicioEvento, HoraFimEvento, Hora)), Horas),
     sum_list(Horas, SomaHoras), !.

ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) :-
     /*
     Verdade quando Max corresponde a ocupacao maxima nas
     salas correspondentes ao TipoSala no intervalo de tempo
     [HoraInicio, HoraFim].
     */
     Duracao is HoraFim - HoraInicio,
     salas(TipoSala, Salas),
     length(Salas, Int),
     Max is Int * Duracao.

percentagem(SomaHoras, Max, Percentagem) :-
     /*
     Verdade quando Percentagem corresponde a (SomaHoras / Max) * 100.
     */
     Percentagem is (SomaHoras / Max) * 100.

ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados) :-
     /*
     Verdade quando Resultados correspondem aos casos
     em que DiaSemana, TipoSala e Percentagem sao, respectivamente, um dia
     da semana, um tipo de sala e a sua percentagem de ocupacao, no intervalo de tempo
     [HoraInicio, HoraFim], e supondo que a percentagem de ocupacao relativa a esses elementos
     esta acima de um dado valor critico Threshold.
     */
     findall(casosCriticos(Dia, TipoSala, Percentagem),
     (salas(TipoSala, X),
     member(Sala, X),
     member(Periodo, [p1, p2, p3, p4]),
     evento(ID, _, _, _, Sala), horario(ID, Dia, _, _, _, Periodo),
     numHorasOcupadas(Periodo, TipoSala, Dia, HoraInicio, HoraFim, SomaHoras),
     ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max),
     percentagem(SomaHoras, Max, P),
     Threshold < P, Percentagem is ceiling(P)), Tudo),
     sort(Tudo, Resultados).


split(L,0,[],L). % Predicado para dar slice a listas

split([X|Xs],N,[X|Ys],Zs) :- N > 0, N1 is N - 1, split(Xs,N1,Ys,Zs).

restricao(cab1(NomePessoa), ListaPessoas) :-
     nth1(P, ListaPessoas, NomePessoa), !,
     P =:= 4.

restricao(cab2(NomePessoa), ListaPessoas) :- 
     nth1(P, ListaPessoas, NomePessoa), !,
     P =:= 5.

restricao(lado(NomePessoa1, NomePessoa2), ListaPessoas) :- 
     nth1(P1, ListaPessoas, NomePessoa1), !,
     nth1(P2, ListaPessoas, NomePessoa2),
     ((P1 =:= P2 + 1), !; (P2 =:= P1 + 1), !).

restricao(honra(NomePessoa1, NomePessoa2), ListaPessoas) :-
     nth1(P1, ListaPessoas, NomePessoa1), !,
     nth1(P2, ListaPessoas, NomePessoa2),
     ((P1 =:= 4, P2 =:= 6), !; (P1 =:= 5, P2 =:= 3)).

restricao(naoLado(NomePessoa1, NomePessoa2), ListaPessoas) :- 
     nth1(P1, ListaPessoas, NomePessoa1), !,
     nth1(P2, ListaPessoas, NomePessoa2),
     \+ ((P1 =:= P2 + 1), !; (P2 =:= P1 + 1), !).

restricao(frente(NomePessoa1, NomePessoa2), ListaPessoas) :-
     nth1(P1, ListaPessoas, NomePessoa1), !,
     nth1(P2, ListaPessoas, NomePessoa2),
     ((P1 + 5 =:= P2); (P2 + 5 =:= P1), !).

restricao(naoFrente(NomePessoa1, NomePessoa2), ListaPessoas) :-
     nth1(P1, ListaPessoas, NomePessoa1), !,
     nth1(P2, ListaPessoas, NomePessoa2),
     \+ ((P1 + 5 =:= P2), !; (P2 + 5 =:= P1), !).

ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa) :-
     /*
     Verdade quando OcupacaoMesa e a lista resultante
     da ListaPessoas filtrada pelas restricoes da ListaRestricoes.
     */
     permutation(ListaPessoas, L),
     ocupacaoMesaAux(L, ListaRestricoes, Ocupacao),
     split(Ocupacao, 3, L1, LP1),
     split(LP1, 2, L2, L3),
     OcupacaoMesa = [L1, L2, L3].

ocupacaoMesaAux(OcupacaoMesa, [], OcupacaoMesa).

ocupacaoMesaAux(L, [H | T], OcupacaoMesa) :-
     restricao(H, L),
     ocupacaoMesaAux(L, T, OcupacaoMesa).
