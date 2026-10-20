module cards_project.marketplace.TradeDisputeTypes

open System.Data

type TradeDisputeStatus =
    | Open
    | UnderReview
    | Resolved
    | Escalated

    static member ToString = function
        | Open -> "Open"
        | UnderReview -> "UnderReview"
        | Resolved -> "Resolved"
        | Escalated -> "Escalated"

    static member FromString s =
        match s with
        | "Open" -> Open
        | "UnderReview" -> UnderReview
        | "Resolved" -> Resolved
        | "Escalated" -> Escalated
        | _ -> failwithf "Unknown TradeDisputeStatus: %s" s

type TradeDisputeReason =
    | ItemNotReceived
    | ItemNotAsDescribed
    | FraudSuspected
    | Other

    static member ToString = function
        | ItemNotReceived -> "ItemNotReceived"
        | ItemNotAsDescribed -> "ItemNotAsDescribed"
        | FraudSuspected -> "FraudSuspected"
        | Other -> "Other"

    static member FromString s =
        match s with
        | "ItemNotReceived" -> ItemNotReceived
        | "ItemNotAsDescribed" -> ItemNotAsDescribed
        | "FraudSuspected" -> FraudSuspected
        | "Other" -> Other
        | _ -> failwithf "Unknown TradeDisputeReason: %s" s

[<CLIMutable>]
type TradeDisputeRow = {
    Id: int64
    Status: string
    Reason: string
    Description: string
    Resolution: string option
    OpenedAt: string
    ResolvedAt: string option
    TransactionId: int64
    OpenedById: int64
    ResolvedById: int64 option
    CreatedAt: string
    UpdatedAt: string
}

type TradeDisputeDto = {
    id: int64
    status: string
    reason: string
    description: string
    resolution: string option
    openedAt: string
    resolvedAt: string option
    transaction_id: int64
    opened_by_id: int64
    resolved_by_id: int64 option
    created_at: string
    updated_at: string
}

let trade_disputeToDto (r: TradeDisputeRow) : TradeDisputeDto = {
    id = r.Id
    status = r.Status
    reason = r.Reason
    description = r.Description
    resolution = r.Resolution
    openedAt = r.OpenedAt
    resolvedAt = r.ResolvedAt
    transaction_id = r.TransactionId
    opened_by_id = r.OpenedById
    resolved_by_id = r.ResolvedById
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type TradeDisputeCreateRequest = {
    status: string
    reason: string
    description: string
    resolution: string option
    opened_at: string
    resolved_at: string option
    transaction_id: int64
    opened_by_id: int64
    resolved_by_id: int64 option
}

type TradeDisputeUpdateRequest = {
    status: string option
    reason: string option
    description: string option
    resolution: string option option
    opened_at: string option
    resolved_at: string option option
    transaction_id: int64 option
    opened_by_id: int64 option
    resolved_by_id: int64 option
}

module TradeDisputeDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id, created_at, updated_at FROM trade_disputes"
        conn.Query<TradeDisputeRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id, created_at, updated_at FROM trade_disputes WHERE id = @id"
        conn.QueryFirstOrDefault<TradeDisputeRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: TradeDisputeCreateRequest) =
        let sql = "INSERT INTO trade_disputes (status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id) VALUES (@status, @reason, @description, @resolution, @opened_at, @resolved_at, @transaction_id, @opened_by_id, @resolved_by_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["status"] <- box dto.status
        p.["reason"] <- box dto.reason
        p.["description"] <- box dto.description
        p.["resolution"] <- match dto.resolution with Some v -> box v | None -> null
        p.["opened_at"] <- box dto.opened_at
        p.["resolved_at"] <- match dto.resolved_at with Some v -> box v | None -> null
        p.["transaction_id"] <- box dto.transaction_id
        p.["opened_by_id"] <- box dto.opened_by_id
        p.["resolved_by_id"] <- match dto.resolved_by_id with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: TradeDisputeCreateRequest) =
        let sql = "UPDATE trade_disputes SET status = @status, reason = @reason, description = @description, resolution = @resolution, opened_at = @opened_at, resolved_at = @resolved_at, transaction_id = @transaction_id, opened_by_id = @opened_by_id, resolved_by_id = @resolved_by_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["status"] <- box dto.status
        p.["reason"] <- box dto.reason
        p.["description"] <- box dto.description
        p.["resolution"] <- match dto.resolution with Some v -> box v | None -> null
        p.["opened_at"] <- box dto.opened_at
        p.["resolved_at"] <- match dto.resolved_at with Some v -> box v | None -> null
        p.["transaction_id"] <- box dto.transaction_id
        p.["opened_by_id"] <- box dto.opened_by_id
        p.["resolved_by_id"] <- match dto.resolved_by_id with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: TradeDisputeUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.status |> Option.iter (fun v -> sets.Add("status = @status"); d.["status"] <- box v)
        patch.reason |> Option.iter (fun v -> sets.Add("reason = @reason"); d.["reason"] <- box v)
        patch.description |> Option.iter (fun v -> sets.Add("description = @description"); d.["description"] <- box v)
        patch.resolution |> Option.iter (fun v -> sets.Add("resolution = @resolution"); d.["resolution"] <- match v with Some s -> box s | None -> null)
        patch.opened_at |> Option.iter (fun v -> sets.Add("opened_at = @opened_at"); d.["opened_at"] <- box v)
        patch.resolved_at |> Option.iter (fun v -> sets.Add("resolved_at = @resolved_at"); d.["resolved_at"] <- match v with Some s -> box s | None -> null)
        patch.transaction_id |> Option.iter (fun v -> sets.Add("transaction_id = @transaction_id"); d.["transaction_id"] <- box v)
        patch.opened_by_id |> Option.iter (fun v -> sets.Add("opened_by_id = @opened_by_id"); d.["opened_by_id"] <- box v)
        patch.resolved_by_id |> Option.iter (fun v -> sets.Add("resolved_by_id = @resolved_by_id"); d.["resolved_by_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE trade_disputes SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM trade_disputes WHERE id = @id"
        conn.Execute(sql, {| id = id |})

    let setStatus (conn: IDbConnection) (id: int64) (status: string) =
        let sql = "UPDATE trade_disputes SET status = @status, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| id = id; status = status |})
