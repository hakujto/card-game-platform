module cards_project.marketplace.CouponTypes

open System.Data

type CouponDiscountType =
    | Percent
    | Fixed

    static member ToString = function
        | Percent -> "Percent"
        | Fixed -> "Fixed"

    static member FromString s =
        match s with
        | "Percent" -> Percent
        | "Fixed" -> Fixed
        | _ -> failwithf "Unknown CouponDiscountType: %s" s

[<CLIMutable>]
type CouponRow = {
    Id: int64
    Code: string
    DiscountType: string
    DiscountValue: decimal
    MinOrderValue: decimal
    MaxUses: int64 option
    UsesCount: int
    ValidFrom: string
    ValidUntil: string
    IsActive: bool
    CreatedAt: string
    UpdatedAt: string
}

type CouponDto = {
    id: int64
    code: string
    discount_type: string
    discount_value: decimal
    min_order_value: decimal
    valid_from: string
    valid_until: string
    is_active: bool
    created_at: string
    updated_at: string
}

let couponToDto (r: CouponRow) : CouponDto = {
    id = r.Id
    code = r.Code
    discount_type = r.DiscountType
    discount_value = r.DiscountValue
    min_order_value = r.MinOrderValue
    valid_from = r.ValidFrom
    valid_until = r.ValidUntil
    is_active = r.IsActive
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type CouponCreateRequest = {
    code: string
    discount_type: string
    discount_value: decimal
    min_order_value: decimal
    max_uses: int option
    uses_count: int
    valid_from: string
    valid_until: string
    is_active: bool
}

type CouponUpdateRequest = {
    code: string option
    discount_type: string option
    discount_value: decimal option
    min_order_value: decimal option
    max_uses: int option option
    uses_count: int option
    valid_from: string option
    valid_until: string option
    is_active: bool option
}

module CouponDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active, created_at, updated_at FROM coupons"
        conn.Query<CouponRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active, created_at, updated_at FROM coupons WHERE code LIKE @q"
        conn.Query<CouponRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active, created_at, updated_at FROM coupons WHERE id = @id"
        conn.QueryFirstOrDefault<CouponRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: CouponCreateRequest) =
        let sql = "INSERT INTO coupons (code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active) VALUES (@code, @discount_type, @discount_value, @min_order_value, @max_uses, @uses_count, @valid_from, @valid_until, @is_active); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["code"] <- box dto.code
        p.["discount_type"] <- box dto.discount_type
        p.["discount_value"] <- box dto.discount_value
        p.["min_order_value"] <- box dto.min_order_value
        p.["max_uses"] <- match dto.max_uses with Some v -> box v | None -> null
        p.["uses_count"] <- box dto.uses_count
        p.["valid_from"] <- box dto.valid_from
        p.["valid_until"] <- box dto.valid_until
        p.["is_active"] <- box dto.is_active
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: CouponCreateRequest) =
        let sql = "UPDATE coupons SET code = @code, discount_type = @discount_type, discount_value = @discount_value, min_order_value = @min_order_value, max_uses = @max_uses, uses_count = @uses_count, valid_from = @valid_from, valid_until = @valid_until, is_active = @is_active, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["code"] <- box dto.code
        p.["discount_type"] <- box dto.discount_type
        p.["discount_value"] <- box dto.discount_value
        p.["min_order_value"] <- box dto.min_order_value
        p.["max_uses"] <- match dto.max_uses with Some v -> box v | None -> null
        p.["uses_count"] <- box dto.uses_count
        p.["valid_from"] <- box dto.valid_from
        p.["valid_until"] <- box dto.valid_until
        p.["is_active"] <- box dto.is_active
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: CouponUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.code |> Option.iter (fun v -> sets.Add("code = @code"); d.["code"] <- box v)
        patch.discount_type |> Option.iter (fun v -> sets.Add("discount_type = @discount_type"); d.["discount_type"] <- box v)
        patch.discount_value |> Option.iter (fun v -> sets.Add("discount_value = @discount_value"); d.["discount_value"] <- box v)
        patch.min_order_value |> Option.iter (fun v -> sets.Add("min_order_value = @min_order_value"); d.["min_order_value"] <- box v)
        patch.max_uses |> Option.iter (fun v -> sets.Add("max_uses = @max_uses"); d.["max_uses"] <- match v with Some s -> box s | None -> null)
        patch.uses_count |> Option.iter (fun v -> sets.Add("uses_count = @uses_count"); d.["uses_count"] <- box v)
        patch.valid_from |> Option.iter (fun v -> sets.Add("valid_from = @valid_from"); d.["valid_from"] <- box v)
        patch.valid_until |> Option.iter (fun v -> sets.Add("valid_until = @valid_until"); d.["valid_until"] <- box v)
        patch.is_active |> Option.iter (fun v -> sets.Add("is_active = @is_active"); d.["is_active"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE coupons SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM coupons WHERE id = @id"
        conn.Execute(sql, {| id = id |})
