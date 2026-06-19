-module(stream_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_go_live/2, handle_end/2, handle_update_viewer_peak/2, handle_duration_minutes/2, handle_transition_scheduled_to_live/2, handle_transition_live_to_ended/2, handle_transition_ended_to_live/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"PUT">>, <<"PATCH">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    Method = cowboy_req:method(Req),
    Handler = case Method of
        <<"PUT">>   -> handle_put;
        <<"PATCH">> -> handle_patch;
        _           -> handle_post
    end,
    {[{<<"application/json">>, Handler}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case stream_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

apply_projection(Map) ->
    (fun(M) -> maps:put(ended_at, maps:get(ended_at, M, undefined), maps:remove(ended_at, M)) end)((fun(M) -> maps:put(actual_start, maps:get(actual_start, M, undefined), maps:remove(actual_start, M)) end)((fun(M) -> maps:put(scheduled_start, maps:get(scheduled_start, M, undefined), maps:remove(scheduled_start, M)) end)(Map))).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            Qs = cowboy_req:parse_qs(Req),
            Q  = proplists:get_value(<<"q">>, Qs, <<"">>),
            All = stream_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(title, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(lists:map(fun apply_projection/1, Filtered)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_stream_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_stream_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = stream_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = stream_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = stream_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = stream_store:update(Updated),
    Resp = jsone:encode(apply_projection(record_to_map(Updated))),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #stream{
        id         = Id,
        title      = maps:get(<<"title">>, Params, undefined),
        stream_url = maps:get(<<"stream_url">>, Params, undefined),
        status     = maps:get(<<"status">>, Params, <<"Scheduled">>),
        platform   = maps:get(<<"platform">>, Params, <<"Twitch">>),
        language   = maps:get(<<"language">>, Params, <<"EN">>),
        is_official = maps:get(<<"is_official">>, Params, false),
        viewer_count_peak = maps:get(<<"viewer_count_peak">>, Params, 0),
        scheduled_start = maps:get(<<"scheduled_start">>, Params, undefined),
        actual_start = maps:get(<<"actual_start">>, Params, undefined),
        ended_at   = maps:get(<<"ended_at">>, Params, undefined),
        vod_url    = maps:get(<<"vod_url">>, Params, undefined),
        tournament_id = maps:get(<<"tournament_id">>, Params, undefined),
        streamer_id = maps:get(<<"streamer_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #stream{
        id         = Record#stream.id,
        title      = maps:get(<<"title">>, Params, Record#stream.title),
        stream_url = maps:get(<<"stream_url">>, Params, Record#stream.stream_url),
        status     = maps:get(<<"status">>, Params, Record#stream.status),
        platform   = maps:get(<<"platform">>, Params, Record#stream.platform),
        language   = maps:get(<<"language">>, Params, Record#stream.language),
        is_official = maps:get(<<"is_official">>, Params, Record#stream.is_official),
        viewer_count_peak = maps:get(<<"viewer_count_peak">>, Params, Record#stream.viewer_count_peak),
        scheduled_start = maps:get(<<"scheduled_start">>, Params, Record#stream.scheduled_start),
        actual_start = maps:get(<<"actual_start">>, Params, Record#stream.actual_start),
        ended_at   = maps:get(<<"ended_at">>, Params, Record#stream.ended_at),
        vod_url    = maps:get(<<"vod_url">>, Params, Record#stream.vod_url),
        tournament_id = maps:get(<<"tournament_id">>, Params, Record#stream.tournament_id),
        streamer_id = maps:get(<<"streamer_id">>, Params, Record#stream.streamer_id),
        created_at = Record#stream.created_at,
        updated_at = iso_now()
    }.

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

iso_now() ->
    {{Y,Mo,D},{H,Mi,S}} = calendar:universal_time(),
    iolist_to_binary(io_lib:format("~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ", [Y,Mo,D,H,Mi,S])).

reply_422(Req, Errors, State) ->
    Body = jsone:encode(#{<<"errors">> => Errors}),
    Req2 = cowboy_req:reply(422, #{<<"content-type">> => <<"application/json">>}, Body, Req),
    {stop, Req2, State}.

to_number(V) when is_integer(V) -> float(V);
to_number(V) when is_float(V)   -> V;
to_number(V) when is_binary(V)  ->
    try binary_to_float(V) catch _:_ -> try float(binary_to_integer(V)) catch _:_ -> 0.0 end end;
to_number(_)                    -> 0.0.

validate_stream_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"viewer_count_peak">>, M, undefined)) >= 0) of false -> {true, <<"Peak viewer count must not be negative">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_stream_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"actual_start">>, M, undefined) =/= undefined andalso maps:get(<<"actual_start">>, M, undefined) =/= null)) andalso not ((maps:get(<<"status">>, M, undefined) =:= <<"Live">>)) of true -> {true, <<"actual_start_requires_live_or_ended">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"ended_at">>, M, undefined) =/= undefined andalso maps:get(<<"ended_at">>, M, undefined) =/= null)) andalso not ((maps:get(<<"status">>, M, undefined) =:= <<"Ended">>)) of true -> {true, <<"ended_at can only be set when stream status is Ended">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_go_live(Req, State) ->
    _ = go_live_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

go_live_behavior(_Record) ->
    %% TODO: implement go_live
    ok.

handle_end(Req, State) ->
    _ = end_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

end_behavior(_Record) ->
    %% TODO: implement end
    ok.

handle_update_viewer_peak(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = update_viewer_peak_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

update_viewer_peak_behavior(_Record, _Params) ->
    %% TODO: implement update_viewer_peak(count)
    ok.

handle_duration_minutes(Req, State) ->
    Result = duration_minutes_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

duration_minutes_behavior(_Record) ->
    %% TODO: implement duration_minutes
    null.

%% ── Lifecycle transitions ────────────────────────────────────────────
handle_transition_scheduled_to_live(Req, State) ->
    %% Transition: Scheduled -> Live
    %% @on guard: [{"type":"neq","field":"stream_url","value":"null"}]
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"streamer">>, <<"admin">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Scheduled -> Live">>}), Req), State};
        true  ->
    ok = stream_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Live">>),
    ok = stream_store:update_field(maps:get(<<"id">>, State), status, <<"Live">>),
    go_live_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Live">>}), Req), State}
    end.

handle_transition_live_to_ended(Req, State) ->
    %% Transition: Live -> Ended
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"streamer">>, <<"admin">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Live -> Ended">>}), Req), State};
        true  ->
    ok = stream_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Ended">>),
    ok = stream_store:update_field(maps:get(<<"id">>, State), status, <<"Ended">>),
    end_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Ended">>}), Req), State}
    end.

handle_transition_ended_to_live(Req, State) ->
    %% Transition: Ended -> Live
    %% @deny: transition is never allowed
    {true, cowboy_req:reply(409, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"error">> => <<"Transition Ended -> Live is not allowed">>}), Req), State}.

