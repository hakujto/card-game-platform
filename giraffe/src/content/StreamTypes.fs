module cards_project.content.StreamTypes

open System.Data

type StreamStatus =
    | Scheduled
    | Live
    | Ended

    static member ToString = function
        | Scheduled -> "Scheduled"
        | Live -> "Live"
        | Ended -> "Ended"

    static member FromString s =
        match s with
        | "Scheduled" -> Scheduled
        | "Live" -> Live
        | "Ended" -> Ended
        | _ -> failwithf "Unknown StreamStatus: %s" s

type StreamPlatform =
    | Twitch
    | YouTube
    | KickStream
    | Platform

    static member ToString = function
        | Twitch -> "Twitch"
        | YouTube -> "YouTube"
        | KickStream -> "KickStream"
        | Platform -> "Platform"

    static member FromString s =
        match s with
        | "Twitch" -> Twitch
        | "YouTube" -> YouTube
        | "KickStream" -> KickStream
        | "Platform" -> Platform
        | _ -> failwithf "Unknown StreamPlatform: %s" s

type StreamLanguage =
    | EN
    | DE
    | FR
    | IT
    | ES
    | JP
    | PT

    static member ToString = function
        | EN -> "EN"
        | DE -> "DE"
        | FR -> "FR"
        | IT -> "IT"
        | ES -> "ES"
        | JP -> "JP"
        | PT -> "PT"

    static member FromString s =
        match s with
        | "EN" -> EN
        | "DE" -> DE
        | "FR" -> FR
        | "IT" -> IT
        | "ES" -> ES
        | "JP" -> JP
        | "PT" -> PT
        | _ -> failwithf "Unknown StreamLanguage: %s" s

[<CLIMutable>]
type StreamRow = {
    Id: int64
    Title: string
    StreamUrl: string
    Status: string
    Platform: string
    Language: string
    IsOfficial: bool
    ViewerCountPeak: int
    ScheduledStart: string
    ActualStart: string option
    EndedAt: string option
    VodUrl: string option
    TournamentId: int64 option
    StreamerId: int64
    CreatedAt: string
    UpdatedAt: string
}

type StreamDto = {
    id: int64
    title: string
    stream_url: string
    status: string
    platform: string
    language: string
    is_official: bool
    viewer_count_peak: int
    scheduledStart: string
    actualStart: string option
    endedAt: string option
    vod_url: string option
    tournament_id: int64 option
    streamer_id: int64
    created_at: string
    updated_at: string
}

let streamToDto (r: StreamRow) : StreamDto = {
    id = r.Id
    title = r.Title
    stream_url = r.StreamUrl
    status = r.Status
    platform = r.Platform
    language = r.Language
    is_official = r.IsOfficial
    viewer_count_peak = r.ViewerCountPeak
    scheduledStart = r.ScheduledStart
    actualStart = r.ActualStart
    endedAt = r.EndedAt
    vod_url = r.VodUrl
    tournament_id = r.TournamentId
    streamer_id = r.StreamerId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type StreamCreateRequest = {
    title: string
    stream_url: string
    status: string
    platform: string
    language: string
    is_official: bool
    viewer_count_peak: int
    scheduled_start: string
    actual_start: string option
    ended_at: string option
    vod_url: string option
    tournament_id: int64 option
    streamer_id: int64
}

type StreamUpdateRequest = {
    title: string option
    stream_url: string option
    status: string option
    platform: string option
    language: string option
    is_official: bool option
    viewer_count_peak: int option
    scheduled_start: string option
    actual_start: string option option
    ended_at: string option option
    vod_url: string option option
    tournament_id: int64 option
    streamer_id: int64 option
}

module StreamDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id, created_at, updated_at FROM streams"
        conn.Query<StreamRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id, created_at, updated_at FROM streams WHERE title LIKE @q"
        conn.Query<StreamRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id, created_at, updated_at FROM streams WHERE id = @id"
        conn.QueryFirstOrDefault<StreamRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: StreamCreateRequest) =
        let sql = "INSERT INTO streams (title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id) VALUES (@title, @stream_url, @status, @platform, @language, @is_official, @viewer_count_peak, @scheduled_start, @actual_start, @ended_at, @vod_url, @tournament_id, @streamer_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["title"] <- box dto.title
        p.["stream_url"] <- box dto.stream_url
        p.["status"] <- box dto.status
        p.["platform"] <- box dto.platform
        p.["language"] <- box dto.language
        p.["is_official"] <- box dto.is_official
        p.["viewer_count_peak"] <- box dto.viewer_count_peak
        p.["scheduled_start"] <- box dto.scheduled_start
        p.["actual_start"] <- match dto.actual_start with Some v -> box v | None -> null
        p.["ended_at"] <- match dto.ended_at with Some v -> box v | None -> null
        p.["vod_url"] <- match dto.vod_url with Some v -> box v | None -> null
        p.["tournament_id"] <- match dto.tournament_id with Some v -> box v | None -> null
        p.["streamer_id"] <- box dto.streamer_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: StreamCreateRequest) =
        let sql = "UPDATE streams SET title = @title, stream_url = @stream_url, status = @status, platform = @platform, language = @language, is_official = @is_official, viewer_count_peak = @viewer_count_peak, scheduled_start = @scheduled_start, actual_start = @actual_start, ended_at = @ended_at, vod_url = @vod_url, tournament_id = @tournament_id, streamer_id = @streamer_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["title"] <- box dto.title
        p.["stream_url"] <- box dto.stream_url
        p.["status"] <- box dto.status
        p.["platform"] <- box dto.platform
        p.["language"] <- box dto.language
        p.["is_official"] <- box dto.is_official
        p.["viewer_count_peak"] <- box dto.viewer_count_peak
        p.["scheduled_start"] <- box dto.scheduled_start
        p.["actual_start"] <- match dto.actual_start with Some v -> box v | None -> null
        p.["ended_at"] <- match dto.ended_at with Some v -> box v | None -> null
        p.["vod_url"] <- match dto.vod_url with Some v -> box v | None -> null
        p.["tournament_id"] <- match dto.tournament_id with Some v -> box v | None -> null
        p.["streamer_id"] <- box dto.streamer_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: StreamUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.title |> Option.iter (fun v -> sets.Add("title = @title"); d.["title"] <- box v)
        patch.stream_url |> Option.iter (fun v -> sets.Add("stream_url = @stream_url"); d.["stream_url"] <- box v)
        patch.status |> Option.iter (fun v -> sets.Add("status = @status"); d.["status"] <- box v)
        patch.platform |> Option.iter (fun v -> sets.Add("platform = @platform"); d.["platform"] <- box v)
        patch.language |> Option.iter (fun v -> sets.Add("language = @language"); d.["language"] <- box v)
        patch.is_official |> Option.iter (fun v -> sets.Add("is_official = @is_official"); d.["is_official"] <- box v)
        patch.viewer_count_peak |> Option.iter (fun v -> sets.Add("viewer_count_peak = @viewer_count_peak"); d.["viewer_count_peak"] <- box v)
        patch.scheduled_start |> Option.iter (fun v -> sets.Add("scheduled_start = @scheduled_start"); d.["scheduled_start"] <- box v)
        patch.actual_start |> Option.iter (fun v -> sets.Add("actual_start = @actual_start"); d.["actual_start"] <- match v with Some s -> box s | None -> null)
        patch.ended_at |> Option.iter (fun v -> sets.Add("ended_at = @ended_at"); d.["ended_at"] <- match v with Some s -> box s | None -> null)
        patch.vod_url |> Option.iter (fun v -> sets.Add("vod_url = @vod_url"); d.["vod_url"] <- match v with Some s -> box s | None -> null)
        patch.tournament_id |> Option.iter (fun v -> sets.Add("tournament_id = @tournament_id"); d.["tournament_id"] <- box v)
        patch.streamer_id |> Option.iter (fun v -> sets.Add("streamer_id = @streamer_id"); d.["streamer_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE streams SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM streams WHERE id = @id"
        conn.Execute(sql, {| id = id |})

    let setStatus (conn: IDbConnection) (id: int64) (status: string) =
        let sql = "UPDATE streams SET status = @status, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| id = id; status = status |})
