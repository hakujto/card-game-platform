use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::players::player::{Player, PlayerCreateRequest, PlayerUpdateRequest};

type AppState = SqlitePool;

fn validate_player(payload: &PlayerCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((payload.rating >= 0 && payload.rating <= 9999)) { errors.push("Rating must be between 0 and 9999".to_string()); }
    if !(payload.peak_rating >= payload.rating) { errors.push("Peak rating must be greater than or equal to current rating".to_string()); }
    if !(!payload.display_name.is_empty()) { errors.push("Display name must not be empty".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct PlayerListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_player(
    State(pool): State<AppState>,
    Query(params): Query<PlayerListParams>,
) -> Result<Json<Vec<Player>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Player,
            "SELECT * FROM players WHERE (display_name LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Player, "SELECT * FROM players LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_player(
    State(pool): State<AppState>,
    Json(payload): Json<PlayerCreateRequest>,
) -> Result<(StatusCode, Json<Player>), (StatusCode, String)> {
    let errors = validate_player(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Player,
        "INSERT INTO players (display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, last_active_at, user_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, datetime('now'), datetime('now')) RETURNING *",
        payload.display_name, payload.rank, payload.rating, payload.peak_rating, payload.bio, payload.country_code, payload.avatar_url, payload.preferred_format, payload.is_verified, payload.last_active_at, payload.user_id
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

pub async fn get_player(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Player>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Player, "SELECT * FROM players WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Player not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_player(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<PlayerUpdateRequest>,
) -> Result<Json<Player>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Player, "SELECT * FROM players WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Player not found".to_string()))?;
    if let Some(v) = payload.display_name { row.display_name = v; }
    if let Some(v) = payload.rank { row.rank = v; }
    if let Some(v) = payload.rating { row.rating = v; }
    if let Some(v) = payload.peak_rating { row.peak_rating = v; }
    if let Some(v) = payload.bio { row.bio = Some(v); }
    if let Some(v) = payload.country_code { row.country_code = Some(v); }
    if let Some(v) = payload.avatar_url { row.avatar_url = Some(v); }
    if let Some(v) = payload.preferred_format { row.preferred_format = Some(v); }
    if let Some(v) = payload.is_verified { row.is_verified = v as i64; }
    if let Some(v) = payload.last_active_at { row.last_active_at = Some(v); }
    if let Some(v) = payload.user_id { row.user_id = Some(v); }
    sqlx::query_unchecked!(
        "UPDATE players SET display_name = $1, rank = $2, rating = $3, peak_rating = $4, bio = $5, country_code = $6, avatar_url = $7, preferred_format = $8, is_verified = $9, last_active_at = $10, user_id = $11, updated_at = datetime('now') WHERE id = $12",
        row.display_name, row.rank, row.rating, row.peak_rating, row.bio, row.country_code, row.avatar_url, row.preferred_format, row.is_verified, row.last_active_at, row.user_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn promote_player(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Player, "SELECT * FROM players WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Player not found".to_string()))?;
    // TODO: implement promote business logic
    Ok(StatusCode::OK)
}

pub async fn demote_player(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Player, "SELECT * FROM players WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Player not found".to_string()))?;
    // TODO: implement demote business logic
    Ok(StatusCode::OK)
}

pub async fn record_win_player(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Player, "SELECT * FROM players WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Player not found".to_string()))?;
    // TODO: implement record_win business logic
    Ok(StatusCode::OK)
}

pub async fn record_loss_player(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Player, "SELECT * FROM players WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Player not found".to_string()))?;
    // TODO: implement record_loss business logic
    Ok(StatusCode::OK)
}

pub async fn win_rate_player(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Player, "SELECT * FROM players WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Player not found".to_string()))?;
    // TODO: implement win_rate business logic
    Ok(StatusCode::OK)
}

pub async fn verify_player(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Player, "SELECT * FROM players WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Player not found".to_string()))?;
    // TODO: implement verify business logic
    Ok(StatusCode::OK)
}

pub async fn update_rating_player(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Player, "SELECT * FROM players WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Player not found".to_string()))?;
    // TODO: implement update_rating business logic
    Ok(StatusCode::OK)
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
#[allow(dead_code)]
fn hook_update_rank(_row: &Player) {
    // TODO: implement update_rank
}

pub fn player_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/players", axum::routing::get(list_player).post(create_player))
        .route("/api/players/:id", axum::routing::MethodRouter::new().get(get_player).patch(patch_player))
        .route("/api/players/:id/promote", axum::routing::post(promote_player))
        .route("/api/players/:id/demote", axum::routing::post(demote_player))
        .route("/api/players/:id/win", axum::routing::post(record_win_player))
        .route("/api/players/:id/loss", axum::routing::post(record_loss_player))
        .route("/api/players/:id/win-rate", axum::routing::get(win_rate_player))
        .route("/api/players/:id/verify", axum::routing::post(verify_player))
        .route("/api/players/:id/rating", axum::routing::patch(update_rating_player))
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
        player_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_player() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/players").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_player() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/players?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_player() {
        let pool = setup_pool().await;
        let body = json!({
        "display_name": "test",
        "rank": "Bronze",
        "rating": 2,
        "peak_rating": 2,
        "is_verified": false,
        "user_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/players")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_player() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/players/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_player() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "display_name": "test",
        "rank": "Bronze",
        "rating": 2,
        "peak_rating": 2,
        "is_verified": false,
        "user_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/players")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "display_name": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/players/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
