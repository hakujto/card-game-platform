-module(card_set_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_is_legal_in_standard/2, handle_is_legal_in_format/2, handle_card_count_by_rarity/2, handle_rotate_out/2]).

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
            case card_set_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            Qs = cowboy_req:parse_qs(Req),
            Q  = proplists:get_value(<<"q">>, Qs, <<"">>),
            All = card_set_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(name, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(Filtered),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_card_set_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_card_set_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = card_set_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = card_set_store:insert(Record),
    Resp   = jsone:encode(record_to_map(Record)),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = card_set_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = card_set_store:update(Updated),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #card_set{
        id         = Id,
        name       = maps:get(<<"name">>, Params, undefined),
        code       = maps:get(<<"code">>, Params, undefined),
        release_date = maps:get(<<"release_date">>, Params, undefined),
        rotation_date = maps:get(<<"rotation_date">>, Params, undefined),
        set_type   = maps:get(<<"set_type">>, Params, <<"Expansion">>),
        total_cards = maps:get(<<"total_cards">>, Params, undefined),
        is_rotated = maps:get(<<"is_rotated">>, Params, false),
        description = maps:get(<<"description">>, Params, undefined),
        logo_url   = maps:get(<<"logo_url">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #card_set{
        id         = Record#card_set.id,
        name       = maps:get(<<"name">>, Params, Record#card_set.name),
        code       = maps:get(<<"code">>, Params, Record#card_set.code),
        release_date = maps:get(<<"release_date">>, Params, Record#card_set.release_date),
        rotation_date = maps:get(<<"rotation_date">>, Params, Record#card_set.rotation_date),
        set_type   = maps:get(<<"set_type">>, Params, Record#card_set.set_type),
        total_cards = maps:get(<<"total_cards">>, Params, Record#card_set.total_cards),
        is_rotated = maps:get(<<"is_rotated">>, Params, Record#card_set.is_rotated),
        description = maps:get(<<"description">>, Params, Record#card_set.description),
        logo_url   = maps:get(<<"logo_url">>, Params, Record#card_set.logo_url),
        created_at = Record#card_set.created_at,
        updated_at = iso_now()
    }.

record_to_map(#card_set{id = Id, name = Name, code = Code, release_date = ReleaseDate, rotation_date = RotationDate, set_type = SetType, total_cards = TotalCards, is_rotated = IsRotated, description = Description, logo_url = LogoUrl, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"name">> => Name,
        <<"code">> => Code,
        <<"release_date">> => ReleaseDate,
        <<"rotation_date">> => RotationDate,
        <<"set_type">> => SetType,
        <<"total_cards">> => TotalCards,
        <<"is_rotated">> => IsRotated,
        <<"description">> => Description,
        <<"logo_url">> => LogoUrl,
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

validate_card_set_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"total_cards">>, M, undefined)) > 0) of false -> {true, <<"Card set must have at least one card">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_card_set_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"rotation_date">>, M, undefined) =/= undefined andalso maps:get(<<"rotation_date">>, M, undefined) =/= null)) andalso not ((maps:get(<<"rotation_date">>, M, undefined) > maps:get(<<"release_date">>, M, undefined))) of true -> {true, <<"Rotation date must be after release date">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"is_rotated">>, M, undefined) =:= true)) andalso not ((maps:get(<<"rotation_date">>, M, undefined) =/= undefined andalso maps:get(<<"rotation_date">>, M, undefined) =/= null)) of true -> {true, <<"Rotated set must have a rotation date">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_is_legal_in_standard(Req, State) ->
    Result = is_legal_in_standard_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

is_legal_in_standard_behavior(_Record) ->
    %% TODO: implement is_legal_in_standard
    null.

handle_is_legal_in_format(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = is_legal_in_format_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

is_legal_in_format_behavior(_Record, _Params) ->
    %% TODO: implement is_legal_in_format(format)
    null.

handle_card_count_by_rarity(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = card_count_by_rarity_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

card_count_by_rarity_behavior(_Record, _Params) ->
    %% TODO: implement card_count_by_rarity(rarity)
    null.

handle_rotate_out(Req, State) ->
    _ = rotate_out_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

rotate_out_behavior(_Record) ->
    %% TODO: implement rotate_out
    ok.

