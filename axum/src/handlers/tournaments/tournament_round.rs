use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::tournaments::tournament_round::{TournamentRound, TournamentRoundCreateRequest, TournamentRoundStatus};

type AppState = SqlitePool;

fn validate_tournament_round(payload: &TournamentRoundCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((!(payload.ended_at.is_some()) || payload.ended_at.as_deref() > payload.started_at.as_deref())) { errors.push("Round end time must be after start time".to_string()); }
    if !((!(payload.status == TournamentRoundStatus::Completed) || payload.started_at.is_some())) { errors.push("Completed round must have a start time".to_string()); }
    if !(payload.round_number > 0) { errors.push("Round number must be greater than zero".to_string()); }
    if !(payload.time_limit_minutes > 0) { errors.push("Round time limit must be greater than zero".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct TournamentRoundListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_tournament_round(
    State(pool): State<AppState>,
    Query(params): Query<TournamentRoundListParams>,
) -> Result<Json<Vec<TournamentRound>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(TournamentRound, "SELECT * FROM tournament_rounds LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_tournament_round(
    State(pool): State<AppState>,
    Json(payload): Json<TournamentRoundCreateRequest>,
) -> Result<(StatusCode, Json<TournamentRound>), (StatusCode, String)> {
    let errors = validate_tournament_round(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(TournamentRound,
        "INSERT INTO tournament_rounds (round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, datetime('now'), datetime('now')) RETURNING *",
        payload.round_number, payload.status, payload.started_at, payload.ended_at, payload.time_limit_minutes, payload.tournament_id
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

pub async fn get_tournament_round(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TournamentRound>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TournamentRound, "SELECT * FROM tournament_rounds WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentRound not found".to_string()))?;
    Ok(Json(row))
}

pub async fn start_tournament_round(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentRound, "SELECT * FROM tournament_rounds WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentRound not found".to_string()))?;
    // TODO: implement start business logic
    Ok(StatusCode::OK)
}

pub async fn complete_tournament_round(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentRound, "SELECT * FROM tournament_rounds WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentRound not found".to_string()))?;
    // TODO: implement complete business logic
    Ok(StatusCode::OK)
}

pub async fn generate_pairings_tournament_round(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentRound, "SELECT * FROM tournament_rounds WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentRound not found".to_string()))?;
    // TODO: implement generate_pairings business logic
    Ok(StatusCode::OK)
}

pub async fn is_time_expired_tournament_round(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentRound, "SELECT * FROM tournament_rounds WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentRound not found".to_string()))?;
    // TODO: implement is_time_expired business logic
    Ok(StatusCode::OK)
}

pub fn tournament_round_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/tournament_rounds", axum::routing::get(list_tournament_round).post(create_tournament_round))
        .route("/api/tournament_rounds/:id", axum::routing::MethodRouter::new().get(get_tournament_round))
        .route("/api/tournament_rounds/:id/api/rounds/{id}/start", axum::routing::post(start_tournament_round))
        .route("/api/tournament_rounds/:id/api/rounds/{id}/complete", axum::routing::post(complete_tournament_round))
        .route("/api/tournament_rounds/:id/api/rounds/{id}/pairings", axum::routing::post(generate_pairings_tournament_round))
        .route("/api/tournament_rounds/:id/api/rounds/{id}/time-expired", axum::routing::get(is_time_expired_tournament_round))
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
        tournament_round_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_tournament_round() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournament_rounds").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_tournament_round() {
        let pool = setup_pool().await;
        let body = json!({
        "round_number": 2,
        "status": "Pending",
        "time_limit_minutes": 2,
        "tournament_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/tournament_rounds")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_tournament_round() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournament_rounds/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
