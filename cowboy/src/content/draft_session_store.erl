-module(draft_session_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, update_field/3, assert_transition/2, find_by_card_set_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#draft_session{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(draft_session, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(draft_session, Id) end,
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
    F = fun() -> mnesia:delete({draft_session, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, draft_session, 1).

find_by_card_set_id(FKId) ->
    F = fun() -> mnesia:match_object(#draft_session{card_set_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

record_to_map(#draft_session{id = Id, status = Status, draft_type = DraftType, pack_contents = PackContents, seats = Seats, time_per_pick_seconds = TimePerPickSeconds, completed_at = CompletedAt, card_set_id = CardSetId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"status">> => Status,
        <<"draft_type">> => DraftType,
        <<"pack_contents">> => PackContents,
        <<"seats">> => Seats,
        <<"time_per_pick_seconds">> => TimePerPickSeconds,
        <<"completed_at">> => CompletedAt,
        <<"card_set_id">> => CardSetId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

update_field(Id, status, Value) ->
    F = fun() ->
        [R] = mnesia:read(draft_session, Id),
        mnesia:write(R#draft_session{status = Value})
    end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

allowed_transitions() ->
    [{<<"waiting_for_players">>, <<"drafting">>}, {<<"drafting">>, <<"completed">>}, {<<"drafting">>, <<"abandoned">>}, {<<"waiting_for_players">>, <<"abandoned">>}].

assert_transition(From, To) ->
    case lists:member({From, To}, allowed_transitions()) of
        true  -> ok;
        false -> error({transition_not_allowed, From, To})
    end.

