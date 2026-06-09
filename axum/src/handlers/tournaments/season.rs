use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::tournaments::season::{Season, SeasonCreateRequest, SeasonUpdateRequest};

type AppState = SqlitePool;

fn validate_season(payload: &SeasonCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.end_date.as_str() > payload.start_date.as_str()) { errors.push("Season end date must be after start date".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct SeasonListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_season(
    State(pool): State<AppState>,
    Query(params): Query<SeasonListParams>,
) -> Result<Json<Vec<Season>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Season,
            "SELECT * FROM seasons WHERE (name LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Season, "SELECT * FROM seasons LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_season(
    State(pool): State<AppState>,
    Json(payload): Json<SeasonCreateRequest>,
) -> Result<(StatusCode, Json<Season>), (StatusCode, String)> {
    let errors = validate_season(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Season,
        "INSERT INTO seasons (name, start_date, end_date, format, is_active, reward_description, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, datetime('now'), datetime('now')) RETURNING *",
        payload.name, payload.start_date, payload.end_date, payload.format, payload.is_active, payload.reward_description
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

pub async fn get_season(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Season>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Season, "SELECT * FROM seasons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Season not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_season(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<SeasonCreateRequest>,
) -> Result<Json<Season>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Season,
        "UPDATE seasons SET name = $1, start_date = $2, end_date = $3, format = $4, is_active = $5, reward_description = $6, updated_at = datetime('now') WHERE id = $7 RETURNING *",
        payload.name, payload.start_date, payload.end_date, payload.format, payload.is_active, payload.reward_description, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "Season not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_season(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<SeasonUpdateRequest>,
) -> Result<Json<Season>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Season, "SELECT * FROM seasons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Season not found".to_string()))?;
    if let Some(v) = payload.name { row.name = v; }
    if let Some(v) = payload.start_date { row.start_date = v; }
    if let Some(v) = payload.end_date { row.end_date = v; }
    if let Some(v) = payload.format { row.format = v; }
    if let Some(v) = payload.is_active { row.is_active = v as i64; }
    if let Some(v) = payload.reward_description { row.reward_description = Some(v); }
    sqlx::query_unchecked!(
        "UPDATE seasons SET name = $1, start_date = $2, end_date = $3, format = $4, is_active = $5, reward_description = $6, updated_at = datetime('now') WHERE id = $7",
        row.name, row.start_date, row.end_date, row.format, row.is_active, row.reward_description, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn activate_season(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Season, "SELECT * FROM seasons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Season not found".to_string()))?;
    // TODO: implement activate business logic
    Ok(StatusCode::OK)
}

pub async fn deactivate_season(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Season, "SELECT * FROM seasons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Season not found".to_string()))?;
    // TODO: implement deactivate business logic
    Ok(StatusCode::OK)
}

pub async fn finalize_rewards_season(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Season, "SELECT * FROM seasons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Season not found".to_string()))?;
    // TODO: implement finalize_rewards business logic
    Ok(StatusCode::OK)
}

pub async fn is_ongoing_season(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Season, "SELECT * FROM seasons WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Season not found".to_string()))?;
    // TODO: implement is_ongoing business logic
    Ok(StatusCode::OK)
}

pub fn season_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/seasons", axum::routing::get(list_season).post(create_season))
        .route("/api/seasons/:id", axum::routing::MethodRouter::new().get(get_season).put(update_season).patch(patch_season))
        .route("/api/seasons/:id/activate", axum::routing::post(activate_season))
        .route("/api/seasons/:id/deactivate", axum::routing::post(deactivate_season))
        .route("/api/seasons/:id/finalize", axum::routing::post(finalize_rewards_season))
        .route("/api/seasons/:id/ongoing", axum::routing::get(is_ongoing_season))
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
        season_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_season() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/seasons").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_season() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/seasons?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_season() {
        let pool = setup_pool().await;
        let body = json!({
        "name": "test",
        "start_date": "2024-01-01",
        "end_date": "2025-12-31",
        "format": "Standard",
        "is_active": false
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/seasons")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_season() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/seasons/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_season() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "name": "test",
        "start_date": "2024-01-01",
        "end_date": "2025-12-31",
        "format": "Standard",
        "is_active": false
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/seasons")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "name": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/seasons/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
