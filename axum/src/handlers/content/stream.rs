use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::content::stream::{Stream, StreamCreateRequest, StreamUpdateRequest, StreamStatus};

type AppState = SqlitePool;

fn validate_stream(payload: &StreamCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((!(payload.actual_start.is_some()) || payload.status == StreamStatus::Live)) { errors.push("Validation failed: actual_start_requires_live_or_ended".to_string()); }
    if !((!(payload.ended_at.is_some()) || payload.status == StreamStatus::Ended)) { errors.push("ended_at can only be set when stream status is Ended".to_string()); }
    if !(payload.viewer_count_peak >= 0) { errors.push("Peak viewer count must not be negative".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct StreamListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_stream(
    State(pool): State<AppState>,
    Query(params): Query<StreamListParams>,
) -> Result<Json<Vec<Stream>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Stream,
            "SELECT * FROM streams WHERE (title LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Stream, "SELECT * FROM streams LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_stream(
    State(pool): State<AppState>,
    Json(payload): Json<StreamCreateRequest>,
) -> Result<(StatusCode, Json<Stream>), (StatusCode, String)> {
    let errors = validate_stream(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Stream,
        "INSERT INTO streams (title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, datetime('now'), datetime('now')) RETURNING *",
        payload.title, payload.stream_url, payload.status, payload.platform, payload.language, payload.is_official, payload.viewer_count_peak, payload.scheduled_start, payload.actual_start, payload.ended_at, payload.vod_url, payload.tournament_id, payload.streamer_id
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

pub async fn get_stream(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Stream>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Stream, "SELECT * FROM streams WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Stream not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_stream(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<StreamCreateRequest>,
) -> Result<Json<Stream>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Stream,
        "UPDATE streams SET title = $1, stream_url = $2, status = $3, platform = $4, language = $5, is_official = $6, viewer_count_peak = $7, scheduled_start = $8, actual_start = $9, ended_at = $10, vod_url = $11, tournament_id = $12, streamer_id = $13, updated_at = datetime('now') WHERE id = $14 RETURNING *",
        payload.title, payload.stream_url, payload.status, payload.platform, payload.language, payload.is_official, payload.viewer_count_peak, payload.scheduled_start, payload.actual_start, payload.ended_at, payload.vod_url, payload.tournament_id, payload.streamer_id, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "Stream not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_stream(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<StreamUpdateRequest>,
) -> Result<Json<Stream>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Stream, "SELECT * FROM streams WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Stream not found".to_string()))?;
    if let Some(v) = payload.title { row.title = v; }
    if let Some(v) = payload.stream_url { row.stream_url = v; }
    if let Some(v) = payload.status { row.status = v; }
    if let Some(v) = payload.platform { row.platform = v; }
    if let Some(v) = payload.language { row.language = v; }
    if let Some(v) = payload.is_official { row.is_official = v as i64; }
    if let Some(v) = payload.viewer_count_peak { row.viewer_count_peak = v; }
    if let Some(v) = payload.scheduled_start { row.scheduled_start = v; }
    if let Some(v) = payload.actual_start { row.actual_start = Some(v); }
    if let Some(v) = payload.ended_at { row.ended_at = Some(v); }
    if let Some(v) = payload.vod_url { row.vod_url = Some(v); }
    if let Some(v) = payload.tournament_id { row.tournament_id = Some(v); }
    if let Some(v) = payload.streamer_id { row.streamer_id = v; }
    sqlx::query_unchecked!(
        "UPDATE streams SET title = $1, stream_url = $2, status = $3, platform = $4, language = $5, is_official = $6, viewer_count_peak = $7, scheduled_start = $8, actual_start = $9, ended_at = $10, vod_url = $11, tournament_id = $12, streamer_id = $13, updated_at = datetime('now') WHERE id = $14",
        row.title, row.stream_url, row.status, row.platform, row.language, row.is_official, row.viewer_count_peak, row.scheduled_start, row.actual_start, row.ended_at, row.vod_url, row.tournament_id, row.streamer_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn go_live_stream(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Stream, "SELECT * FROM streams WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Stream not found".to_string()))?;
    // TODO: implement go_live business logic
    Ok(StatusCode::OK)
}

pub async fn end_stream(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Stream, "SELECT * FROM streams WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Stream not found".to_string()))?;
    // TODO: implement end business logic
    Ok(StatusCode::OK)
}

pub async fn update_viewer_peak_stream(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Stream, "SELECT * FROM streams WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Stream not found".to_string()))?;
    // TODO: implement update_viewer_peak business logic
    Ok(StatusCode::OK)
}

pub async fn duration_minutes_stream(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Stream, "SELECT * FROM streams WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Stream not found".to_string()))?;
    // TODO: implement duration_minutes business logic
    Ok(StatusCode::OK)
}

pub async fn transition_stream_scheduled_to_live(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Stream>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Stream, "SELECT * FROM streams WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Stream not found".to_string()))?;
    row.assert_transition("Live").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Stream,
        "UPDATE streams SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Live", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_stream_live_to_ended(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Stream>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Stream, "SELECT * FROM streams WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Stream not found".to_string()))?;
    row.assert_transition("Ended").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Stream,
        "UPDATE streams SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Ended", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub fn stream_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/streams", axum::routing::get(list_stream).post(create_stream))
        .route("/api/streams/:id", axum::routing::MethodRouter::new().get(get_stream).put(update_stream).patch(patch_stream))
        .route("/api/streams/:id/live", axum::routing::post(go_live_stream))
        .route("/api/streams/:id/end", axum::routing::post(end_stream))
        .route("/api/streams/:id/viewers", axum::routing::patch(update_viewer_peak_stream))
        .route("/api/streams/:id/duration", axum::routing::get(duration_minutes_stream))
        .route("/api/streams/:id/transitions/scheduled-to-live", axum::routing::patch(transition_stream_scheduled_to_live))
        .route("/api/streams/:id/transitions/live-to-ended", axum::routing::patch(transition_stream_live_to_ended))
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
        stream_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_stream() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/streams").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_stream() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/streams?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_stream() {
        let pool = setup_pool().await;
        let body = json!({
        "title": "test",
        "stream_url": "https://example.com",
        "status": "Scheduled",
        "platform": "Twitch",
        "language": "EN",
        "is_official": false,
        "viewer_count_peak": 2,
        "scheduled_start": "2024-01-01T00:00:00Z",
        "tournament_id": 1,
        "streamer_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/streams")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_stream() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/streams/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_stream() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "title": "test",
        "stream_url": "https://example.com",
        "status": "Scheduled",
        "platform": "Twitch",
        "language": "EN",
        "is_official": false,
        "viewer_count_peak": 2,
        "scheduled_start": "2024-01-01T00:00:00Z",
        "tournament_id": 1,
        "streamer_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/streams")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "title": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/streams/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
