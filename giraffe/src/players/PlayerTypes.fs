module cards_project.players.PlayerTypes

open System.Data

type PlayerRank =
    | Bronze
    | Silver
    | Gold
    | Platinum
    | Diamond
    | Master
    | Grandmaster

    static member ToString = function
        | Bronze -> "Bronze"
        | Silver -> "Silver"
        | Gold -> "Gold"
        | Platinum -> "Platinum"
        | Diamond -> "Diamond"
        | Master -> "Master"
        | Grandmaster -> "Grandmaster"

    static member FromString s =
        match s with
        | "Bronze" -> Bronze
        | "Silver" -> Silver
        | "Gold" -> Gold
        | "Platinum" -> Platinum
        | "Diamond" -> Diamond
        | "Master" -> Master
        | "Grandmaster" -> Grandmaster
        | _ -> failwithf "Unknown PlayerRank: %s" s

type PlayerPreferredFormat =
    | Standard
    | Extended
    | Legacy
    | Vintage
    | Commander
    | Draft

    static member ToString = function
        | Standard -> "Standard"
        | Extended -> "Extended"
        | Legacy -> "Legacy"
        | Vintage -> "Vintage"
        | Commander -> "Commander"
        | Draft -> "Draft"

    static member FromString s =
        match s with
        | "Standard" -> Standard
        | "Extended" -> Extended
        | "Legacy" -> Legacy
        | "Vintage" -> Vintage
        | "Commander" -> Commander
        | "Draft" -> Draft
        | _ -> failwithf "Unknown PlayerPreferredFormat: %s" s

[<CLIMutable>]
type PlayerRow = {
    Id: int64
    PublicId: string
    DisplayName: string
    Rank: string
    Rating: int
    PeakRating: int
    Bio: string option
    CountryCode: string option
    AvatarUrl: string option
    PreferredFormat: string option
    ContactEmail: string option
    WinRateCached: float option
    IsVerified: bool
    LastActiveAt: string option
    UserId: int64 option
    CreatedAt: string
    UpdatedAt: string
}

type PlayerDto = {
    id: int64
    public_id: string
    display_name: string
    rank: string
    rating: int
    peak_rating: int
    bio: string option
    country_code: string option
    avatar_url: string option
    preferred_format: string option
    contact_email: string option
    win_rate_cached: float option
    is_verified: bool
    lastActiveAt: string option
    user_id: int64 option
    created_at: string
    updated_at: string
}

let playerToDto (r: PlayerRow) : PlayerDto = {
    id = r.Id
    public_id = r.PublicId
    display_name = r.DisplayName
    rank = r.Rank
    rating = r.Rating
    peak_rating = r.PeakRating
    bio = r.Bio
    country_code = r.CountryCode
    avatar_url = r.AvatarUrl
    preferred_format = r.PreferredFormat
    contact_email = r.ContactEmail
    win_rate_cached = r.WinRateCached
    is_verified = r.IsVerified
    lastActiveAt = r.LastActiveAt
    user_id = r.UserId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type PlayerCreateRequest = {
    public_id: string
    display_name: string
    rank: string
    rating: int
    peak_rating: int
    bio: string option
    country_code: string option
    avatar_url: string option
    preferred_format: string option
    contact_email: string option
    win_rate_cached: float option
    is_verified: bool
    last_active_at: string option
    user_id: int64 option
}

type PlayerUpdateRequest = {
    public_id: string option
    display_name: string option
    rank: string option
    contact_email: string option option
    win_rate_cached: float option option
    is_verified: bool option
    last_active_at: string option option
    user_id: int64 option
}

type PlayerPatchRequest = {
    public_id: string option
    display_name: string option
    rank: string option
    bio: string option option
    country_code: string option option
    avatar_url: string option option
    preferred_format: string option option
    contact_email: string option option
    win_rate_cached: float option option
    is_verified: bool option
    last_active_at: string option option
    user_id: int64 option
}

// hook: after_create
let initialize_collection (entity: PlayerRow) =
    // TODO: implement initialize_collection hook
    entity

// hook: after_update
let update_rank (entity: PlayerRow) =
    // TODO: implement update_rank hook
    entity

module PlayerDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id, created_at, updated_at FROM players"
        conn.Query<PlayerRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id, created_at, updated_at FROM players WHERE display_name LIKE @q"
        conn.Query<PlayerRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id, created_at, updated_at FROM players WHERE id = @id"
        conn.QueryFirstOrDefault<PlayerRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: PlayerCreateRequest) =
        let sql = "INSERT INTO players (public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id) VALUES (@public_id, @display_name, @rank, @rating, @peak_rating, @bio, @country_code, @avatar_url, @preferred_format, @contact_email, @win_rate_cached, @is_verified, @last_active_at, @user_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["public_id"] <- box dto.public_id
        p.["display_name"] <- box dto.display_name
        p.["rank"] <- box dto.rank
        p.["rating"] <- box dto.rating
        p.["peak_rating"] <- box dto.peak_rating
        p.["bio"] <- match dto.bio with Some v -> box v | None -> null
        p.["country_code"] <- match dto.country_code with Some v -> box v | None -> null
        p.["avatar_url"] <- match dto.avatar_url with Some v -> box v | None -> null
        p.["preferred_format"] <- match dto.preferred_format with Some v -> box v | None -> null
        p.["contact_email"] <- match dto.contact_email with Some v -> box v | None -> null
        p.["win_rate_cached"] <- match dto.win_rate_cached with Some v -> box v | None -> null
        p.["is_verified"] <- box dto.is_verified
        p.["last_active_at"] <- match dto.last_active_at with Some v -> box v | None -> null
        p.["user_id"] <- match dto.user_id with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: PlayerCreateRequest) =
        let sql = "UPDATE players SET public_id = @public_id, display_name = @display_name, rank = @rank, rating = @rating, peak_rating = @peak_rating, bio = @bio, country_code = @country_code, avatar_url = @avatar_url, preferred_format = @preferred_format, contact_email = @contact_email, win_rate_cached = @win_rate_cached, is_verified = @is_verified, last_active_at = @last_active_at, user_id = @user_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["public_id"] <- box dto.public_id
        p.["display_name"] <- box dto.display_name
        p.["rank"] <- box dto.rank
        p.["rating"] <- box dto.rating
        p.["peak_rating"] <- box dto.peak_rating
        p.["bio"] <- match dto.bio with Some v -> box v | None -> null
        p.["country_code"] <- match dto.country_code with Some v -> box v | None -> null
        p.["avatar_url"] <- match dto.avatar_url with Some v -> box v | None -> null
        p.["preferred_format"] <- match dto.preferred_format with Some v -> box v | None -> null
        p.["contact_email"] <- match dto.contact_email with Some v -> box v | None -> null
        p.["win_rate_cached"] <- match dto.win_rate_cached with Some v -> box v | None -> null
        p.["is_verified"] <- box dto.is_verified
        p.["last_active_at"] <- match dto.last_active_at with Some v -> box v | None -> null
        p.["user_id"] <- match dto.user_id with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: PlayerPatchRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.public_id |> Option.iter (fun v -> sets.Add("public_id = @public_id"); d.["public_id"] <- box v)
        patch.display_name |> Option.iter (fun v -> sets.Add("display_name = @display_name"); d.["display_name"] <- box v)
        patch.rank |> Option.iter (fun v -> sets.Add("rank = @rank"); d.["rank"] <- box v)
        patch.bio |> Option.iter (fun v -> sets.Add("bio = @bio"); d.["bio"] <- match v with Some s -> box s | None -> null)
        patch.country_code |> Option.iter (fun v -> sets.Add("country_code = @country_code"); d.["country_code"] <- match v with Some s -> box s | None -> null)
        patch.avatar_url |> Option.iter (fun v -> sets.Add("avatar_url = @avatar_url"); d.["avatar_url"] <- match v with Some s -> box s | None -> null)
        patch.preferred_format |> Option.iter (fun v -> sets.Add("preferred_format = @preferred_format"); d.["preferred_format"] <- match v with Some s -> box s | None -> null)
        patch.contact_email |> Option.iter (fun v -> sets.Add("contact_email = @contact_email"); d.["contact_email"] <- match v with Some s -> box s | None -> null)
        patch.win_rate_cached |> Option.iter (fun v -> sets.Add("win_rate_cached = @win_rate_cached"); d.["win_rate_cached"] <- match v with Some s -> box s | None -> null)
        patch.is_verified |> Option.iter (fun v -> sets.Add("is_verified = @is_verified"); d.["is_verified"] <- box v)
        patch.last_active_at |> Option.iter (fun v -> sets.Add("last_active_at = @last_active_at"); d.["last_active_at"] <- match v with Some s -> box s | None -> null)
        patch.user_id |> Option.iter (fun v -> sets.Add("user_id = @user_id"); d.["user_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE players SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM players WHERE id = @id"
        conn.Execute(sql, {| id = id |})
