-module(trade_dispute_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, update_field/3, assert_transition/2, find_by_transaction_id/1, find_by_opened_by_id/1, find_by_resolved_by_id/1, delete_by_transaction_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#trade_dispute{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(trade_dispute, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(trade_dispute, Id) end,
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
    F = fun() -> mnesia:delete({trade_dispute, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, trade_dispute, 1).

find_by_transaction_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_dispute{transaction_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_opened_by_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_dispute{opened_by_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_resolved_by_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_dispute{resolved_by_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

delete_by_transaction_id(FKId) ->
    Records = find_by_transaction_id(FKId),
    lists:foreach(fun(R) -> delete(maps:get(<<"id">>, R)) end, Records).

record_to_map(#trade_dispute{id = Id, status = Status, reason = Reason, description = Description, resolution = Resolution, opened_at = OpenedAt, resolved_at = ResolvedAt, transaction_id = TransactionId, opened_by_id = OpenedById, resolved_by_id = ResolvedById, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"status">> => Status,
        <<"reason">> => Reason,
        <<"description">> => Description,
        <<"resolution">> => Resolution,
        <<"opened_at">> => OpenedAt,
        <<"resolved_at">> => ResolvedAt,
        <<"transaction_id">> => TransactionId,
        <<"opened_by_id">> => OpenedById,
        <<"resolved_by_id">> => ResolvedById,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

update_field(Id, status, Value) ->
    F = fun() ->
        [R] = mnesia:read(trade_dispute, Id),
        mnesia:write(R#trade_dispute{status = Value})
    end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

allowed_transitions() ->
    [{<<"open">>, <<"under_review">>}, {<<"under_review">>, <<"resolved">>}, {<<"under_review">>, <<"escalated">>}, {<<"escalated">>, <<"resolved">>}].

assert_transition(From, To) ->
    case lists:member({From, To}, allowed_transitions()) of
        true  -> ok;
        false -> error({transition_not_allowed, From, To})
    end.

