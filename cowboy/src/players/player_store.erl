-module(player_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#player{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(player, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(player, Id) end,
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
    F = fun() -> mnesia:delete({player, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, player, 1).

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

