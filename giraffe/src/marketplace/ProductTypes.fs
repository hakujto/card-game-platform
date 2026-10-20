module cards_project.marketplace.ProductTypes

open System.Data

type ProductProductType =
    | SingleCard
    | BoosterPack
    | Bundle
    | PreconstructedDeck
    | Accessory

    static member ToString = function
        | SingleCard -> "SingleCard"
        | BoosterPack -> "BoosterPack"
        | Bundle -> "Bundle"
        | PreconstructedDeck -> "PreconstructedDeck"
        | Accessory -> "Accessory"

    static member FromString s =
        match s with
        | "SingleCard" -> SingleCard
        | "BoosterPack" -> BoosterPack
        | "Bundle" -> Bundle
        | "PreconstructedDeck" -> PreconstructedDeck
        | "Accessory" -> Accessory
        | _ -> failwithf "Unknown ProductProductType: %s" s

[<CLIMutable>]
type ProductRow = {
    Id: int64
    Name: string
    ProductType: string
    Price: decimal
    Stock: int
    Active: bool
    DiscountPercent: int
    Description: string option
    ImageUrl: string option
    Featured: bool
    CardId: int64 option
    CardSetId: int64 option
    CreatedAt: string
    UpdatedAt: string
}

type ProductDto = {
    id: int64
    name: string
    product_type: string
    price: decimal
    stock: int
    active: bool
    discount_percent: int
    description: string option
    image_url: string option
    featured: bool
    card_id: int64 option
    card_set_id: int64 option
    created_at: string
    updated_at: string
}

let productToDto (r: ProductRow) : ProductDto = {
    id = r.Id
    name = r.Name
    product_type = r.ProductType
    price = r.Price
    stock = r.Stock
    active = r.Active
    discount_percent = r.DiscountPercent
    description = r.Description
    image_url = r.ImageUrl
    featured = r.Featured
    card_id = r.CardId
    card_set_id = r.CardSetId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type ProductCreateRequest = {
    name: string
    product_type: string
    price: decimal
    stock: int
    active: bool
    discount_percent: int
    description: string option
    image_url: string option
    featured: bool
    card_id: int64 option
    card_set_id: int64 option
}

type ProductUpdateRequest = {
    name: string option
    product_type: string option
    price: decimal option
    stock: int option
    active: bool option
    discount_percent: int option
    image_url: string option option
    card_id: int64 option
    card_set_id: int64 option
}

type ProductPatchRequest = {
    name: string option
    product_type: string option
    price: decimal option
    stock: int option
    active: bool option
    discount_percent: int option
    description: string option option
    image_url: string option option
    featured: bool option
    card_id: int64 option
    card_set_id: int64 option
}

module ProductDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id, created_at, updated_at FROM products"
        conn.Query<ProductRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id, created_at, updated_at FROM products WHERE name LIKE @q OR description LIKE @q"
        conn.Query<ProductRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id, created_at, updated_at FROM products WHERE id = @id"
        conn.QueryFirstOrDefault<ProductRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: ProductCreateRequest) =
        let sql = "INSERT INTO products (name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id) VALUES (@name, @product_type, @price, @stock, @active, @discount_percent, @description, @image_url, @featured, @card_id, @card_set_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["name"] <- box dto.name
        p.["product_type"] <- box dto.product_type
        p.["price"] <- box dto.price
        p.["stock"] <- box dto.stock
        p.["active"] <- box dto.active
        p.["discount_percent"] <- box dto.discount_percent
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["image_url"] <- match dto.image_url with Some v -> box v | None -> null
        p.["featured"] <- box dto.featured
        p.["card_id"] <- match dto.card_id with Some v -> box v | None -> null
        p.["card_set_id"] <- match dto.card_set_id with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: ProductCreateRequest) =
        let sql = "UPDATE products SET name = @name, product_type = @product_type, price = @price, stock = @stock, active = @active, discount_percent = @discount_percent, description = @description, image_url = @image_url, featured = @featured, card_id = @card_id, card_set_id = @card_set_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["name"] <- box dto.name
        p.["product_type"] <- box dto.product_type
        p.["price"] <- box dto.price
        p.["stock"] <- box dto.stock
        p.["active"] <- box dto.active
        p.["discount_percent"] <- box dto.discount_percent
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["image_url"] <- match dto.image_url with Some v -> box v | None -> null
        p.["featured"] <- box dto.featured
        p.["card_id"] <- match dto.card_id with Some v -> box v | None -> null
        p.["card_set_id"] <- match dto.card_set_id with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: ProductPatchRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.name |> Option.iter (fun v -> sets.Add("name = @name"); d.["name"] <- box v)
        patch.product_type |> Option.iter (fun v -> sets.Add("product_type = @product_type"); d.["product_type"] <- box v)
        patch.price |> Option.iter (fun v -> sets.Add("price = @price"); d.["price"] <- box v)
        patch.stock |> Option.iter (fun v -> sets.Add("stock = @stock"); d.["stock"] <- box v)
        patch.active |> Option.iter (fun v -> sets.Add("active = @active"); d.["active"] <- box v)
        patch.discount_percent |> Option.iter (fun v -> sets.Add("discount_percent = @discount_percent"); d.["discount_percent"] <- box v)
        patch.description |> Option.iter (fun v -> sets.Add("description = @description"); d.["description"] <- match v with Some s -> box s | None -> null)
        patch.image_url |> Option.iter (fun v -> sets.Add("image_url = @image_url"); d.["image_url"] <- match v with Some s -> box s | None -> null)
        patch.featured |> Option.iter (fun v -> sets.Add("featured = @featured"); d.["featured"] <- box v)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        patch.card_set_id |> Option.iter (fun v -> sets.Add("card_set_id = @card_set_id"); d.["card_set_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE products SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM products WHERE id = @id"
        conn.Execute(sql, {| id = id |})
