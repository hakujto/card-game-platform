use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::content::draft_session::{DraftSession, DraftSessionCreateRequest, DraftSessionStatus};

type AppState = SqlitePool;

fn validate_draft_session(payload: &DraftSessionCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((payload.seats >= 2 && payload.seats <= 16)) { errors.push("Draft session must have between 2 and 16 seats".to_string()); }
    if !((!(payload.completed_at.is_some()) || payload.status == DraftSessionStatus::Completed)) { errors.push("completed_at can only be set when draft status is Completed".to_string()); }
    if !(payload.time_per_pick_seconds > 0) { errors.push("Time per pick must be greater than zero".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct DraftSessionListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_draft_session(
    State(pool): State<AppState>,
    Query(params): Query<DraftSessionListParams>,
) -> Result<Json<Vec<DraftSession>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_draft_session(
    State(pool): State<AppState>,
    Json(payload): Json<DraftSessionCreateRequest>,
) -> Result<(StatusCode, Json<DraftSession>), (StatusCode, String)> {
    let errors = validate_draft_session(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(DraftSession,
        "INSERT INTO draft_sessions (status, draft_type, seats, time_per_pick_seconds, completed_at, card_set_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, datetime('now'), datetime('now')) RETURNING *",
        payload.status, payload.draft_type, payload.seats, payload.time_per_pick_seconds, payload.completed_at, payload.card_set_id
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

pub async fn get_draft_session(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DraftSession>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftSession not found".to_string()))
        .map(Json)
}

pub async fn start_draft_session(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftSession not found".to_string()))?;
    // TODO: implement start business logic
    Ok(StatusCode::OK)
}

pub async fn abandon_draft_session(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftSession not found".to_string()))?;
    // TODO: implement abandon business logic
    Ok(StatusCode::OK)
}

pub async fn complete_draft_session(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftSession not found".to_string()))?;
    // TODO: implement complete business logic
    Ok(StatusCode::OK)
}

pub async fn is_full_draft_session(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftSession not found".to_string()))?;
    // TODO: implement is_full business logic
    Ok(StatusCode::OK)
}

pub async fn transition_draft_session_waitingforplayers_to_drafting(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DraftSession>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftSession not found".to_string()))?;
    row.assert_transition("Drafting").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(DraftSession,
        "UPDATE draft_sessions SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Drafting", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_draft_session_drafting_to_completed(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DraftSession>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftSession not found".to_string()))?;
    row.assert_transition("Completed").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(DraftSession,
        "UPDATE draft_sessions SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Completed", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_draft_session_drafting_to_abandoned(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DraftSession>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftSession not found".to_string()))?;
    row.assert_transition("Abandoned").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(DraftSession,
        "UPDATE draft_sessions SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Abandoned", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_draft_session_waitingforplayers_to_abandoned(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DraftSession>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(DraftSession, "SELECT * FROM draft_sessions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftSession not found".to_string()))?;
    row.assert_transition("Abandoned").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(DraftSession,
        "UPDATE draft_sessions SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Abandoned", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub fn draft_session_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/draft_sessions", axum::routing::get(list_draft_session).post(create_draft_session))
        .route("/api/draft_sessions/:id", axum::routing::MethodRouter::new().get(get_draft_session))
        .route("/api/draft_sessions/:id/api/draft-sessions/{id}/start", axum::routing::post(start_draft_session))
        .route("/api/draft_sessions/:id/api/draft-sessions/{id}/abandon", axum::routing::post(abandon_draft_session))
        .route("/api/draft_sessions/:id/api/draft-sessions/{id}/complete", axum::routing::post(complete_draft_session))
        .route("/api/draft_sessions/:id/api/draft-sessions/{id}/full", axum::routing::get(is_full_draft_session))
        .route("/api/draft_sessions/:id/transitions/waitingforplayers-to-drafting", axum::routing::patch(transition_draft_session_waitingforplayers_to_drafting))
        .route("/api/draft_sessions/:id/transitions/drafting-to-completed", axum::routing::patch(transition_draft_session_drafting_to_completed))
        .route("/api/draft_sessions/:id/transitions/drafting-to-abandoned", axum::routing::patch(transition_draft_session_drafting_to_abandoned))
        .route("/api/draft_sessions/:id/transitions/waitingforplayers-to-abandoned", axum::routing::patch(transition_draft_session_waitingforplayers_to_abandoned))
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
        draft_session_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_draft_session() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/draft_sessions").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_draft_session() {
        let pool = setup_pool().await;
        let body = json!({
        "status": "WaitingForPlayers",
        "draft_type": "Booster",
        "seats": 2,
        "time_per_pick_seconds": 2,
        "card_set_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/draft_sessions")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_draft_session() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/draft_sessions/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
