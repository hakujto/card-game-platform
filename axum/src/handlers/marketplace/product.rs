use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::marketplace::product::{Product, ProductCreateRequest, ProductUpdateRequest};

type AppState = SqlitePool;

fn validate_product(payload: &ProductCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.price > 0.0) { errors.push("Product price must be greater than zero".to_string()); }
    if !(payload.stock >= 0) { errors.push("Product stock must not be negative".to_string()); }
    if !((payload.discount_percent >= 0 && payload.discount_percent <= 100)) { errors.push("Product discount percent must be between 0 and 100".to_string()); }
    if payload.discount_percent < 0 { errors.push("discount_percent must be >= 0".to_string()); }
    if payload.discount_percent > 100 { errors.push("discount_percent must be <= 100".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct ProductListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_product(
    State(pool): State<AppState>,
    Query(params): Query<ProductListParams>,
) -> Result<Json<Vec<Product>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Product,
            "SELECT * FROM products WHERE (name LIKE '%' || $3 || '%' OR description LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Product, "SELECT * FROM products LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_product(
    State(pool): State<AppState>,
    Json(payload): Json<ProductCreateRequest>,
) -> Result<(StatusCode, Json<Product>), (StatusCode, String)> {
    let errors = validate_product(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Product,
        "INSERT INTO products (name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, datetime('now'), datetime('now')) RETURNING *",
        payload.name, payload.product_type, payload.price, payload.stock, payload.active, payload.discount_percent, payload.description, payload.image_url, payload.featured, payload.card_id, payload.card_set_id
    ).fetch_one(&pool).await
    .map_err(|e| {
        if e.to_string().contains("UNIQUE") {
            (StatusCode::UNPROCESSABLE_ENTITY, "Value must be unique".to_string())
        } else {
            (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
        }
    })?;
    Ok((StatusCode::CREATED, Json(row)))
}

pub async fn get_product(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Product>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Product, "SELECT * FROM products WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Product not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_product(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<ProductCreateRequest>,
) -> Result<Json<Product>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Product,
        "UPDATE products SET name = $1, product_type = $2, price = $3, stock = $4, active = $5, discount_percent = $6, description = $7, image_url = $8, featured = $9, card_id = $10, card_set_id = $11, updated_at = datetime('now') WHERE id = $12 RETURNING *",
        payload.name, payload.product_type, payload.price, payload.stock, payload.active, payload.discount_percent, payload.description, payload.image_url, payload.featured, payload.card_id, payload.card_set_id, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "Product not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_product(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<ProductUpdateRequest>,
) -> Result<Json<Product>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Product, "SELECT * FROM products WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Product not found".to_string()))?;
    if let Some(v) = payload.name { row.name = v; }
    if let Some(v) = payload.product_type { row.product_type = v; }
    if let Some(v) = payload.price { row.price = v; }
    if let Some(v) = payload.stock { row.stock = v; }
    if let Some(v) = payload.active { row.active = v as i64; }
    if let Some(v) = payload.discount_percent { row.discount_percent = v; }
    if let Some(v) = payload.description { row.description = Some(v); }
    if let Some(v) = payload.image_url { row.image_url = Some(v); }
    if let Some(v) = payload.featured { row.featured = v as i64; }
    if let Some(v) = payload.card_id { row.card_id = Some(v); }
    if let Some(v) = payload.card_set_id { row.card_set_id = Some(v); }
    sqlx::query_unchecked!(
        "UPDATE products SET name = $1, product_type = $2, price = $3, stock = $4, active = $5, discount_percent = $6, description = $7, image_url = $8, featured = $9, card_id = $10, card_set_id = $11, updated_at = datetime('now') WHERE id = $12",
        row.name, row.product_type, row.price, row.stock, row.active, row.discount_percent, row.description, row.image_url, row.featured, row.card_id, row.card_set_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn activate_product(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Product, "SELECT * FROM products WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Product not found".to_string()))?;
    // TODO: implement activate business logic
    Ok(StatusCode::OK)
}

pub async fn deactivate_product(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Product, "SELECT * FROM products WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Product not found".to_string()))?;
    // TODO: implement deactivate business logic
    Ok(StatusCode::OK)
}

pub async fn apply_discount_product(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Product, "SELECT * FROM products WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Product not found".to_string()))?;
    // TODO: implement apply_discount business logic
    Ok(StatusCode::OK)
}

pub async fn restock_product(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Product, "SELECT * FROM products WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Product not found".to_string()))?;
    // TODO: implement restock business logic
    Ok(StatusCode::OK)
}

pub async fn effective_price_product(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Product, "SELECT * FROM products WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Product not found".to_string()))?;
    // TODO: implement effective_price business logic
    Ok(StatusCode::OK)
}

pub async fn is_in_stock_product(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Product, "SELECT * FROM products WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Product not found".to_string()))?;
    // TODO: implement is_in_stock business logic
    Ok(StatusCode::OK)
}

pub fn product_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/products", axum::routing::get(list_product).post(create_product))
        .route("/api/products/:id", axum::routing::MethodRouter::new().get(get_product).put(update_product).patch(patch_product))
        .route("/api/products/:id/activate", axum::routing::post(activate_product))
        .route("/api/products/:id/deactivate", axum::routing::post(deactivate_product))
        .route("/api/products/:id/discount", axum::routing::patch(apply_discount_product))
        .route("/api/products/:id/restock", axum::routing::post(restock_product))
        .route("/api/products/:id/effective-price", axum::routing::get(effective_price_product))
        .route("/api/products/:id/in-stock", axum::routing::get(is_in_stock_product))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::{Request, StatusCode};
    use serde_json::json;
    use tower::ServiceExt;
    use sqlx::SqlitePool;

    async fn setup_pool() -> SqlitePool {
        let pool = SqlitePool::connect(":memory:").await.unwrap();
        sqlx::query("PRAGMA foreign_keys = OFF").execute(&pool).await.unwrap();
        sqlx::migrate!("./migrations").run(&pool).await.unwrap();
        pool
    }

    fn app(pool: SqlitePool) -> axum::Router {
        product_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_product() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/products").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_product() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/products?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_product() {
        let pool = setup_pool().await;
        let body = json!({
        "name": "test",
        "product_type": "SingleCard",
        "price": 1.0,
        "stock": 2,
        "active": false,
        "discount_percent": 2,
        "featured": false,
        "card_id": 1,
        "card_set_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/products")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_product() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/products/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_product() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "name": "test",
        "product_type": "SingleCard",
        "price": 1.0,
        "stock": 2,
        "active": false,
        "discount_percent": 2,
        "featured": false,
        "card_id": 1,
        "card_set_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/products")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "description": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/products/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
