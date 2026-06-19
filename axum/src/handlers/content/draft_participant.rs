use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::content::draft_participant::{DraftParticipant, DraftParticipantCreateRequest};

type AppState = SqlitePool;

fn validate_draft_participant(payload: &DraftParticipantCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.seat_number > 0) { errors.push("Seat number must be greater than zero".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct DraftParticipantListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_draft_participant(
    State(pool): State<AppState>,
    Query(params): Query<DraftParticipantListParams>,
) -> Result<Json<Vec<DraftParticipant>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(DraftParticipant, "SELECT * FROM draft_participants LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_draft_participant(
    State(pool): State<AppState>,
    Json(payload): Json<DraftParticipantCreateRequest>,
) -> Result<(StatusCode, Json<DraftParticipant>), (StatusCode, String)> {
    let errors = validate_draft_participant(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(DraftParticipant,
        "INSERT INTO draft_participants (seat_number, joined_at, session_id, player_id, created_at, updated_at) VALUES ($1, $2, $3, $4, datetime('now'), datetime('now')) RETURNING *",
        payload.seat_number, payload.joined_at, payload.session_id, payload.player_id
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

pub async fn get_draft_participant(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DraftParticipant>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(DraftParticipant, "SELECT * FROM draft_participants WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftParticipant not found".to_string()))?;
    Ok(Json(row))
}

pub async fn pick_card_draft_participant(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DraftParticipant, "SELECT * FROM draft_participants WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftParticipant not found".to_string()))?;
    // TODO: implement pick_card business logic
    Ok(StatusCode::OK)
}

pub async fn drafted_card_count_draft_participant(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DraftParticipant, "SELECT * FROM draft_participants WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DraftParticipant not found".to_string()))?;
    // TODO: implement drafted_card_count business logic
    Ok(StatusCode::OK)
}

pub fn draft_participant_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/draft_participants", axum::routing::get(list_draft_participant).post(create_draft_participant))
        .route("/api/draft_participants/:id", axum::routing::MethodRouter::new().get(get_draft_participant))
        .route("/api/draft_participants/:id/api/draft-participants/{id}/pick", axum::routing::post(pick_card_draft_participant))
        .route("/api/draft_participants/:id/api/draft-participants/{id}/card-count", axum::routing::get(drafted_card_count_draft_participant))
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
        draft_participant_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_draft_participant() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/draft_participants").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_draft_participant() {
        let pool = setup_pool().await;
        let body = json!({
        "seat_number": 2,
        "joined_at": "2024-01-01T00:00:00Z",
        "session_id": 1,
        "player_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/draft_participants")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_draft_participant() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/draft_participants/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
