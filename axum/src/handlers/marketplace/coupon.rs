use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::marketplace::coupon::{Coupon, CouponCreateRequest, CouponUpdateRequest, CouponDiscountType};

type AppState = SqlitePool;

fn validate_coupon(payload: &CouponCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.valid_until.as_str() > payload.valid_from.as_str()) { errors.push("Coupon expiry must be after its start date".to_string()); }
    if !(payload.discount_value > 0.0) { errors.push("Discount value must be greater than zero".to_string()); }
    if !((!(payload.discount_type == CouponDiscountType::Percent) || (payload.discount_value >= 1.0 && payload.discount_value <= 100.0))) { errors.push("Percent discount must be between 1 and 100".to_string()); }
    if !((!(payload.max_uses.is_some()) || payload.max_uses.map_or(true, |r| payload.uses_count <= r))) { errors.push("Coupon uses count cannot exceed max_uses".to_string()); }
    if payload.discount_value < 0.01 { errors.push("discount_value must be >= 0.01".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct CouponListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_coupon(
    State(pool): State<AppState>,
    Query(params): Query<CouponListParams>,
) -> Result<Json<Vec<Coupon>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Coupon,
            "SELECT * FROM coupons WHERE (code LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Coupon, "SELECT * FROM coupons LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_coupon(
    State(pool): State<AppState>,
    Json(payload): Json<CouponCreateRequest>,
) -> Result<(StatusCode, Json<Coupon>), (StatusCode, String)> {
    let errors = validate_coupon(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Coupon,
        "INSERT INTO coupons (code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, datetime('now'), datetime('now')) RETURNING *",
        payload.code, payload.discount_type, payload.discount_value, payload.min_order_value, payload.max_uses, payload.uses_count, payload.valid_from, payload.valid_until, payload.is_active
    ).fetch_one(&pool).await
    .map_err(|e| {
        // @unique fields: code
        if e.to_string().contains("UNIQUE") {
            (StatusCode::UNPROCESSABLE_ENTITY, "Value must be unique".to_string())
        } else {
            (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
        }
    })?;
    Ok((StatusCode::CREATED, Json(row)))
}

pub async fn get_coupon(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Coupon>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Coupon, "SELECT * FROM coupons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Coupon not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_coupon(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CouponCreateRequest>,
) -> Result<Json<Coupon>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Coupon,
        "UPDATE coupons SET code = $1, discount_type = $2, discount_value = $3, min_order_value = $4, max_uses = $5, uses_count = $6, valid_from = $7, valid_until = $8, is_active = $9, updated_at = datetime('now') WHERE id = $10 RETURNING *",
        payload.code, payload.discount_type, payload.discount_value, payload.min_order_value, payload.max_uses, payload.uses_count, payload.valid_from, payload.valid_until, payload.is_active, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "Coupon not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_coupon(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CouponUpdateRequest>,
) -> Result<Json<Coupon>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Coupon, "SELECT * FROM coupons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Coupon not found".to_string()))?;
    if let Some(v) = payload.code { row.code = v; }
    if let Some(v) = payload.discount_type { row.discount_type = v; }
    if let Some(v) = payload.discount_value { row.discount_value = v; }
    if let Some(v) = payload.min_order_value { row.min_order_value = v; }
    if let Some(v) = payload.max_uses { row.max_uses = Some(v); }
    if let Some(v) = payload.uses_count { row.uses_count = v; }
    if let Some(v) = payload.valid_from { row.valid_from = v; }
    if let Some(v) = payload.valid_until { row.valid_until = v; }
    if let Some(v) = payload.is_active { row.is_active = v as i64; }
    sqlx::query_unchecked!(
        "UPDATE coupons SET code = $1, discount_type = $2, discount_value = $3, min_order_value = $4, max_uses = $5, uses_count = $6, valid_from = $7, valid_until = $8, is_active = $9, updated_at = datetime('now') WHERE id = $10",
        row.code, row.discount_type, row.discount_value, row.min_order_value, row.max_uses, row.uses_count, row.valid_from, row.valid_until, row.is_active, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn is_valid_coupon(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Coupon, "SELECT * FROM coupons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Coupon not found".to_string()))?;
    // TODO: implement is_valid business logic
    Ok(StatusCode::OK)
}

pub async fn is_applicable_to_order_coupon(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Coupon, "SELECT * FROM coupons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Coupon not found".to_string()))?;
    // TODO: implement is_applicable_to_order business logic
    Ok(StatusCode::OK)
}

pub async fn redeem_coupon(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Coupon, "SELECT * FROM coupons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Coupon not found".to_string()))?;
    // @guard: TODO: evaluate guard condition — return 422 if not met
    // if !(guard_condition) { return Err((StatusCode::UNPROCESSABLE_ENTITY, "Guard condition not met for redeem".to_string())); }
    // TODO: implement redeem business logic
    Ok(StatusCode::OK)
}

pub async fn deactivate_coupon(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Coupon, "SELECT * FROM coupons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Coupon not found".to_string()))?;
    // TODO: implement deactivate business logic
    Ok(StatusCode::OK)
}

pub fn coupon_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/coupons", axum::routing::get(list_coupon).post(create_coupon))
        .route("/api/coupons/:id", axum::routing::MethodRouter::new().get(get_coupon).put(update_coupon).patch(patch_coupon))
        .route("/api/coupons/:id/valid", axum::routing::get(is_valid_coupon))
        .route("/api/coupons/:id/applicable", axum::routing::get(is_applicable_to_order_coupon))
        .route("/api/coupons/:id/redeem", axum::routing::post(redeem_coupon))
        .route("/api/coupons/:id/deactivate", axum::routing::post(deactivate_coupon))
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
        coupon_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_coupon() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/coupons").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_coupon() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/coupons?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_coupon() {
        let pool = setup_pool().await;
        let body = json!({
        "code": "test",
        "discount_type": "Fixed",
        "discount_value": 1.0,
        "min_order_value": 1.0,
        "uses_count": 2,
        "valid_from": "2024-01-01T00:00:00Z",
        "valid_until": "2025-12-31T23:59:59Z",
        "is_active": false
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/coupons")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_coupon() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/coupons/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_coupon() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "code": "test",
        "discount_type": "Fixed",
        "discount_value": 1.0,
        "min_order_value": 1.0,
        "uses_count": 2,
        "valid_from": "2024-01-01T00:00:00Z",
        "valid_until": "2025-12-31T23:59:59Z",
        "is_active": false
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/coupons")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "code": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/coupons/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
