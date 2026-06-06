use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::marketplace::order_item::{OrderItem, OrderItemCreateRequest};

type AppState = SqlitePool;

fn validate_order_item(payload: &OrderItemCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.quantity > 0) { errors.push("Order item quantity must be greater than zero".to_string()); }
    if !(payload.price_at_purchase >= 0.0) { errors.push("Price at purchase must not be negative".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct OrderItemListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_order_item(
    State(pool): State<AppState>,
    Query(params): Query<OrderItemListParams>,
) -> Result<Json<Vec<OrderItem>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(OrderItem, "SELECT * FROM order_items LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_order_item(
    State(pool): State<AppState>,
    Json(payload): Json<OrderItemCreateRequest>,
) -> Result<(StatusCode, Json<OrderItem>), (StatusCode, String)> {
    let errors = validate_order_item(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(OrderItem,
        "INSERT INTO order_items (quantity, price_at_purchase, foil, order_id, product_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, datetime('now'), datetime('now')) RETURNING *",
        payload.quantity, payload.price_at_purchase, payload.foil, payload.order_id, payload.product_id
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

pub async fn get_order_item(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<OrderItem>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(OrderItem, "SELECT * FROM order_items WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "OrderItem not found".to_string()))
        .map(Json)
}

pub async fn delete_order_item(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM order_items WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "OrderItem not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn line_total_order_item(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(OrderItem, "SELECT * FROM order_items WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "OrderItem not found".to_string()))?;
    // TODO: implement line_total business logic
    Ok(StatusCode::OK)
}

pub fn order_item_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/order_items", axum::routing::get(list_order_item).post(create_order_item))
        .route("/api/order_items/:id", axum::routing::MethodRouter::new().get(get_order_item).delete(delete_order_item))
        .route("/api/order_items/:id/api/order-items/{id}/total", axum::routing::get(line_total_order_item))
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
        sqlx::migrate!("./migrations").run(&pool).await.unwrap();
        pool
    }

    fn app(pool: SqlitePool) -> axum::Router {
        order_item_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_order_item() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/order_items").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_order_item() {
        let pool = setup_pool().await;
        let body = json!({
        "quantity": 2,
        "price_at_purchase": 1.0,
        "foil": false,
        "order_id": 1,
        "product_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/order_items")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_order_item() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/order_items/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_delete_order_item() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/order_items/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
