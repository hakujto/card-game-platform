-module(player_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_patch/2, handle_promote/2, handle_demote/2, handle_record_win/2, handle_record_loss/2, handle_win_rate/2, handle_verify/2, handle_update_rating/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"PATCH">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    Method = cowboy_req:method(Req),
    Handler = case Method of
        <<"PATCH">> -> handle_patch;
        _           -> handle_post
    end,
    {[{<<"application/json">>, Handler}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case player_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

apply_projection(Map) ->
    (fun(M) -> maps:put(last_active_at, maps:get(last_active_at, M, undefined), maps:remove(last_active_at, M)) end)((fun(M) -> maps:put(created_at, maps:get(created_at, M, undefined), maps:remove(created_at, M)) end)(Map)).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            Qs = cowboy_req:parse_qs(Req),
            Q  = proplists:get_value(<<"q">>, Qs, <<"">>),
            All = player_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(display_name, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(lists:map(fun apply_projection/1, Filtered)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_player_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_player_fields(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = player_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = player_store:insert(Record),
    initialize_collection_hook(Record),
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
    {ok, ExistingRecord} = player_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = player_store:update(Updated),
    update_rank_hook(Updated),
    Resp = jsone:encode(apply_projection(record_to_map(Updated))),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #player{
        id         = Id,
        public_id  = maps:get(<<"public_id">>, Params, undefined),
        display_name = maps:get(<<"display_name">>, Params, undefined),
        rank       = maps:get(<<"rank">>, Params, <<"Bronze">>),
        rating     = maps:get(<<"rating">>, Params, 1000),
        peak_rating = maps:get(<<"peak_rating">>, Params, 1000),
        bio        = maps:get(<<"bio">>, Params, undefined),
        country_code = maps:get(<<"country_code">>, Params, undefined),
        avatar_url = maps:get(<<"avatar_url">>, Params, undefined),
        preferred_format = maps:get(<<"preferred_format">>, Params, undefined),
        contact_email = maps:get(<<"contact_email">>, Params, undefined),
        win_rate_cached = maps:get(<<"win_rate_cached">>, Params, undefined),
        is_verified = maps:get(<<"is_verified">>, Params, false),
        last_active_at = maps:get(<<"last_active_at">>, Params, undefined),
        user_id    = maps:get(<<"user_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #player{
        id         = Record#player.id,
        public_id  = maps:get(<<"public_id">>, Params, Record#player.public_id),
        display_name = maps:get(<<"display_name">>, Params, Record#player.display_name),
        rank       = maps:get(<<"rank">>, Params, Record#player.rank),
        bio        = maps:get(<<"bio">>, Params, Record#player.bio),
        country_code = maps:get(<<"country_code">>, Params, Record#player.country_code),
        avatar_url = maps:get(<<"avatar_url">>, Params, Record#player.avatar_url),
        preferred_format = maps:get(<<"preferred_format">>, Params, Record#player.preferred_format),
        contact_email = maps:get(<<"contact_email">>, Params, Record#player.contact_email),
        win_rate_cached = maps:get(<<"win_rate_cached">>, Params, Record#player.win_rate_cached),
        is_verified = maps:get(<<"is_verified">>, Params, Record#player.is_verified),
        last_active_at = maps:get(<<"last_active_at">>, Params, Record#player.last_active_at),
        user_id    = maps:get(<<"user_id">>, Params, Record#player.user_id),
        created_at = Record#player.created_at,
        updated_at = iso_now()
    }.

record_to_map(#player{id = Id, public_id = PublicId, display_name = DisplayName, rank = Rank, rating = Rating, peak_rating = PeakRating, bio = Bio, country_code = CountryCode, avatar_url = AvatarUrl, preferred_format = PreferredFormat, contact_email = ContactEmail, win_rate_cached = WinRateCached, is_verified = IsVerified, last_active_at = LastActiveAt, user_id = UserId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"public_id">> => PublicId,
        <<"display_name">> => DisplayName,
        <<"rank">> => Rank,
        <<"rating">> => Rating,
        <<"peak_rating">> => PeakRating,
        <<"bio">> => Bio,
        <<"country_code">> => CountryCode,
        <<"avatar_url">> => AvatarUrl,
        <<"preferred_format">> => PreferredFormat,
        <<"contact_email">> => ContactEmail,
        <<"win_rate_cached">> => WinRateCached,
        <<"is_verified">> => IsVerified,
        <<"last_active_at">> => LastActiveAt,
        <<"user_id">> => UserId,
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

%% ── Lifecycle hooks ──────────────────────────────────────────────────
initialize_collection_hook(Record) ->
    %% TODO: implement initialize_collection
    Record.

update_rank_hook(Record) ->
    %% TODO: implement update_rank
    Record.

to_number(V) when is_integer(V) -> float(V);
to_number(V) when is_float(V)   -> V;
to_number(V) when is_binary(V)  ->
    try binary_to_float(V) catch _:_ -> try float(binary_to_integer(V)) catch _:_ -> 0.0 end end;
to_number(_)                    -> 0.0.

validate_player_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"rating">>, M, undefined)) >= 0 andalso to_number(maps:get(<<"rating">>, M, undefined)) =< 9999) of false -> {true, <<"Rating must be between 0 and 9999">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"peak_rating">>, M, undefined)) >= to_number(maps:get(<<"rating">>, M, undefined))) of false -> {true, <<"Peak rating must be greater than or equal to current rating">>}; _ -> false end end,
        fun() -> case (maps:get(<<"display_name">>, M, undefined) =/= undefined andalso maps:get(<<"display_name">>, M, undefined) =/= null) of false -> {true, <<"Display name must not be empty">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_player_fields(M) ->
    Checks = [
        fun() -> case maps:get(<<"country_code">>, M, undefined) of undefined -> false; _V -> case re:run(maps:get(<<"country_code">>, M, undefined), <<"[A-Z]{2}">>) of nomatch -> {true, <<"country_code does not match pattern">>}; _ -> false end end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_promote(Req, State) ->
    Result = promote_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

promote_behavior(_Record) ->
    %% TODO: implement promote
    null.

handle_demote(Req, State) ->
    Result = demote_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

demote_behavior(_Record) ->
    %% TODO: implement demote
    null.

handle_record_win(Req, State) ->
    _ = record_win_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

record_win_behavior(_Record) ->
    %% TODO: implement record_win
    ok.

handle_record_loss(Req, State) ->
    _ = record_loss_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

record_loss_behavior(_Record) ->
    %% TODO: implement record_loss
    ok.

handle_win_rate(Req, State) ->
    Result = win_rate_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

win_rate_behavior(_Record) ->
    %% TODO: implement win_rate
    null.

handle_verify(Req, State) ->
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"admin">>]) of
        false -> cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for verify">>}), Req), {stop, Req, State};
        true  ->
    _ = verify_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}
    end.

verify_behavior(_Record) ->
    %% TODO: implement verify
    ok.

handle_update_rating(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = update_rating_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

update_rating_behavior(_Record, _Params) ->
    %% TODO: implement update_rating(delta)
    ok.

