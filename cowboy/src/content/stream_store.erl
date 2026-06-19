-module(stream_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, update_field/3, assert_transition/2, find_by_tournament_id/1, find_by_streamer_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#stream{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(stream, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(stream, Id) end,
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
    F = fun() -> mnesia:delete({stream, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, stream, 1).

find_by_tournament_id(FKId) ->
    F = fun() -> mnesia:match_object(#stream{tournament_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_streamer_id(FKId) ->
    F = fun() -> mnesia:match_object(#stream{streamer_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

record_to_map(#stream{id = Id, title = Title, stream_url = StreamUrl, status = Status, platform = Platform, language = Language, is_official = IsOfficial, viewer_count_peak = ViewerCountPeak, scheduled_start = ScheduledStart, actual_start = ActualStart, ended_at = EndedAt, vod_url = VodUrl, tournament_id = TournamentId, streamer_id = StreamerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"title">> => Title,
        <<"stream_url">> => StreamUrl,
        <<"status">> => Status,
        <<"platform">> => Platform,
        <<"language">> => Language,
        <<"is_official">> => IsOfficial,
        <<"viewer_count_peak">> => ViewerCountPeak,
        <<"scheduled_start">> => ScheduledStart,
        <<"actual_start">> => ActualStart,
        <<"ended_at">> => EndedAt,
        <<"vod_url">> => VodUrl,
        <<"tournament_id">> => TournamentId,
        <<"streamer_id">> => StreamerId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

update_field(Id, status, Value) ->
    F = fun() ->
        [R] = mnesia:read(stream, Id),
        mnesia:write(R#stream{status = Value})
    end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

allowed_transitions() ->
    [{<<"scheduled">>, <<"live">>}, {<<"live">>, <<"ended">>}].

assert_transition(From, To) ->
    case lists:member({From, To}, allowed_transitions()) of
        true  -> ok;
        false -> error({transition_not_allowed, From, To})
    end.

