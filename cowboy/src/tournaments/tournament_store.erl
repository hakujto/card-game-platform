-module(tournament_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, update_field/3, assert_transition/2]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#tournament{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(tournament, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(tournament, Id) end,
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
    F = fun() -> mnesia:delete({tournament, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, tournament, 1).

record_to_map(#tournament{id = Id, name = Name, description = Description, status = Status, format = Format, tournament_type = TournamentType, max_players = MaxPlayers, entry_fee = EntryFee, prize_pool = PrizePool, start_time = StartTime, end_time = EndTime, is_online = IsOnline, location = Location, rules_text = RulesText, season_id = SeasonId, organizer_id = OrganizerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"name">> => Name,
        <<"description">> => Description,
        <<"status">> => Status,
        <<"format">> => Format,
        <<"tournament_type">> => TournamentType,
        <<"max_players">> => MaxPlayers,
        <<"entry_fee">> => EntryFee,
        <<"prize_pool">> => PrizePool,
        <<"start_time">> => StartTime,
        <<"end_time">> => EndTime,
        <<"is_online">> => IsOnline,
        <<"location">> => Location,
        <<"rules_text">> => RulesText,
        <<"season_id">> => SeasonId,
        <<"organizer_id">> => OrganizerId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

update_field(Id, status, Value) ->
    F = fun() ->
        [R] = mnesia:read(tournament, Id),
        mnesia:write(R#tournament{status = Value})
    end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

allowed_transitions() ->
    [{<<"draft">>, <<"registration">>}, {<<"registration">>, <<"ongoing">>}, {<<"registration">>, <<"cancelled">>}, {<<"ongoing">>, <<"completed">>}, {<<"ongoing">>, <<"cancelled">>}].

assert_transition(From, To) ->
    case lists:member({From, To}, allowed_transitions()) of
        true  -> ok;
        false -> error({transition_not_allowed, From, To})
    end.

