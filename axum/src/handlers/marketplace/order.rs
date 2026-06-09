use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::marketplace::order::{Order, OrderCreateRequest, OrderStatus};

type AppState = SqlitePool;

fn validate_order(payload: &OrderCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((!(payload.status == OrderStatus::Paid) || payload.paid_at.is_some())) { errors.push("Paid order must have paid_at set".to_string()); }
    if !((!(payload.status == OrderStatus::Shipped) || payload.tracking_number.is_some())) { errors.push("Shipped order must have a tracking number".to_string()); }
    if !((!(payload.shipped_at.is_some()) || payload.status == OrderStatus::Shipped)) { errors.push("Validation failed: shipped_at_requires_shipped_status".to_string()); }
    if !(payload.total >= 0.0) { errors.push("Order total must not be negative".to_string()); }
    if !(payload.discount_applied <= payload.total) { errors.push("Discount applied cannot exceed order total".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct OrderListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_order(
    State(pool): State<AppState>,
    Query(params): Query<OrderListParams>,
) -> Result<Json<Vec<Order>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_order(
    State(pool): State<AppState>,
    Json(payload): Json<OrderCreateRequest>,
) -> Result<(StatusCode, Json<Order>), (StatusCode, String)> {
    let errors = validate_order(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Order,
        "INSERT INTO orders (status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, datetime('now'), datetime('now')) RETURNING *",
        payload.status, payload.total, payload.discount_applied, payload.currency, payload.payment_method, payload.payment_reference, payload.shipping_address, payload.tracking_number, payload.paid_at, payload.shipped_at, payload.player_id, payload.coupon_id
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

pub async fn get_order(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Order>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    Ok(Json(row))
}

pub async fn cancel_order(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    // TODO: implement cancel business logic
    Ok(StatusCode::OK)
}

pub async fn pay_order(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    // TODO: implement pay business logic
    Ok(StatusCode::OK)
}

pub async fn process_payment_order(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    // TODO: implement process_payment business logic
    Ok(StatusCode::OK)
}

pub async fn calculate_total_order(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    // TODO: implement calculate_total business logic
    Ok(StatusCode::OK)
}

pub async fn apply_discount_order(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    // TODO: implement apply_discount business logic
    Ok(StatusCode::OK)
}

pub async fn refund_order(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    // TODO: implement refund business logic
    Ok(StatusCode::OK)
}

pub async fn set_status_order(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<serde_json::Value>,
) -> Result<Json<Order>, (StatusCode, String)> {
    let mut row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    let value = payload["value"].as_str().unwrap_or("").to_string();
    row.status = value.clone().into();
    if value.as_str() == "Shipped" {
        // @on(status = Shipped): notify_shipped triggered
        // TODO: implement notify_shipped side-effect
    }
    sqlx::query_unchecked!(
        "UPDATE orders SET status = $1, updated_at = datetime('now') WHERE id = $2",
        row.status, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn transition_order_pending_to_paid(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Order>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    row.assert_transition("Paid").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Order,
        "UPDATE orders SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Paid", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_order_paid_to_processing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Order>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    row.assert_transition("Processing").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Order,
        "UPDATE orders SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Processing", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_order_processing_to_shipped(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Order>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    row.assert_transition("Shipped").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Order,
        "UPDATE orders SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Shipped", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_order_shipped_to_completed(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Order>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    row.assert_transition("Completed").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Order,
        "UPDATE orders SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Completed", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_order_pending_to_cancelled(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Order>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    row.assert_transition("Cancelled").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Order,
        "UPDATE orders SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Cancelled", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_order_paid_to_cancelled(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Order>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    row.assert_transition("Cancelled").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Order,
        "UPDATE orders SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Cancelled", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_order_completed_to_refunded(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Order>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Order, "SELECT * FROM orders WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Order not found".to_string()))?;
    row.assert_transition("Refunded").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Order,
        "UPDATE orders SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Refunded", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
#[allow(dead_code)]
fn hook_notify_status_change(_row: &Order) {
    // TODO: implement notify_status_change
}

pub fn order_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/orders", axum::routing::get(list_order).post(create_order))
        .route("/api/orders/:id", axum::routing::MethodRouter::new().get(get_order))
        .route("/api/orders/:id/cancel", axum::routing::delete(cancel_order))
        .route("/api/orders/:id/pay", axum::routing::post(pay_order))
        .route("/api/orders/:id/process-payment", axum::routing::post(process_payment_order))
        .route("/api/orders/:id/total", axum::routing::get(calculate_total_order))
        .route("/api/orders/:id/discount", axum::routing::patch(apply_discount_order))
        .route("/api/orders/:id/refund", axum::routing::post(refund_order))
        .route("/api/orders/:id/status", axum::routing::patch(set_status_order))
        .route("/api/orders/:id/transitions/pending-to-paid", axum::routing::patch(transition_order_pending_to_paid))
        .route("/api/orders/:id/transitions/paid-to-processing", axum::routing::patch(transition_order_paid_to_processing))
        .route("/api/orders/:id/transitions/processing-to-shipped", axum::routing::patch(transition_order_processing_to_shipped))
        .route("/api/orders/:id/transitions/shipped-to-completed", axum::routing::patch(transition_order_shipped_to_completed))
        .route("/api/orders/:id/transitions/pending-to-cancelled", axum::routing::patch(transition_order_pending_to_cancelled))
        .route("/api/orders/:id/transitions/paid-to-cancelled", axum::routing::patch(transition_order_paid_to_cancelled))
        .route("/api/orders/:id/transitions/completed-to-refunded", axum::routing::patch(transition_order_completed_to_refunded))
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
        order_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_order() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/orders").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_order() {
        let pool = setup_pool().await;
        let body = json!({
        "status": "Pending",
        "total": 1.0,
        "discount_applied": 1.0,
        "currency": "test",
        "player_id": 1,
        "coupon_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/orders")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_order() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/orders/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
