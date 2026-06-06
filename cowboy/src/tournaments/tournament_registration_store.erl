-module(tournament_registration_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#tournament_registration{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(tournament_registration, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(tournament_registration, Id) end,
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
    F = fun() -> mnesia:delete({tournament_registration, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, tournament_registration, 1).

record_to_map(#tournament_registration{id = Id, status = Status, seed = Seed, final_standing = FinalStanding, points_earned = PointsEarned, registered_at = RegisteredAt, tournament_id = TournamentId, player_id = PlayerId, deck_id = DeckId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"status">> => Status,
        <<"seed">> => Seed,
        <<"final_standing">> => FinalStanding,
        <<"points_earned">> => PointsEarned,
        <<"registered_at">> => RegisteredAt,
        <<"tournament_id">> => TournamentId,
        <<"player_id">> => PlayerId,
        <<"deck_id">> => DeckId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

