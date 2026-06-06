-module(match_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, update_field/3, assert_transition/2]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#match{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(match, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(match, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, R};
        {atomic, []}  -> not_found
    end.

insert(Record) ->
    F = fun() -> mnesia:write(Record) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

update(Record) ->
    F = fun() -> mnesia:write(Record) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

delete(Id) ->
    F = fun() -> mnesia:delete({match, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, match, 1).

record_to_map(#match{id = Id, table_number = TableNumber, status = Status, player1_wins = Player1Wins, player2_wins = Player2Wins, started_at = StartedAt, ended_at = EndedAt, result_notes = ResultNotes, round_id = RoundId, player1_id = Player1Id, player2_id = Player2Id, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"table_number">> => TableNumber,
        <<"status">> => Status,
        <<"player1_wins">> => Player1Wins,
        <<"player2_wins">> => Player2Wins,
        <<"started_at">> => StartedAt,
        <<"ended_at">> => EndedAt,
        <<"result_notes">> => ResultNotes,
        <<"round_id">> => RoundId,
        <<"player1_id">> => Player1Id,
        <<"player2_id">> => Player2Id,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

update_field(Id, status, Value) ->
    F = fun() ->
        [R] = mnesia:read(match, Id),
        mnesia:write(R#match{status = Value})
    end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

allowed_transitions() ->
    [{<<"pending">>, <<"active">>}, {<<"active">>, <<"completed">>}, {<<"active">>, <<"draw">>}, {<<"pending">>, <<"b_y_e">>}].

assert_transition(From, To) ->
    case lists:member({From, To}, allowed_transitions()) of
        true  -> ok;
        false -> error({transition_not_allowed, From, To})
    end.

