use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::tournaments::tournament_registration::{TournamentRegistration, TournamentRegistrationCreateRequest};

type AppState = SqlitePool;

fn validate_tournament_registration(payload: &TournamentRegistrationCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.points_earned >= 0) { errors.push("Points earned must not be negative".to_string()); }
    if !((!(payload.final_standing.is_some()) || payload.final_standing.map_or(false, |v| v > 0))) { errors.push("Final standing must be greater than zero".to_string()); }
    if !((!(payload.seed.is_some()) || payload.seed.map_or(false, |v| v > 0))) { errors.push("Seed must be greater than zero".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct TournamentRegistrationListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_tournament_registration(
    State(pool): State<AppState>,
    Query(params): Query<TournamentRegistrationListParams>,
) -> Result<Json<Vec<TournamentRegistration>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(TournamentRegistration, "SELECT * FROM tournament_registrations LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_tournament_registration(
    State(pool): State<AppState>,
    Json(payload): Json<TournamentRegistrationCreateRequest>,
) -> Result<(StatusCode, Json<TournamentRegistration>), (StatusCode, String)> {
    let errors = validate_tournament_registration(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(TournamentRegistration,
        "INSERT INTO tournament_registrations (status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, datetime('now'), datetime('now')) RETURNING *",
        payload.status, payload.seed, payload.final_standing, payload.points_earned, payload.registered_at, payload.tournament_id, payload.player_id, payload.deck_id
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

pub async fn get_tournament_registration(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    headers: axum::http::HeaderMap,
) -> Result<Json<TournamentRegistration>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TournamentRegistration, "SELECT * FROM tournament_registrations WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentRegistration not found".to_string()))?;
    let uid = headers.get("x-user-id").and_then(|v| v.to_str().ok()).and_then(|s| s.parse::<i64>().ok());
    if uid.map(|u| u != row.player_id).unwrap_or(true) {
        return Err((StatusCode::FORBIDDEN, "You do not own this resource.".to_string()));
    }
    Ok(Json(row))
}

pub async fn withdraw_tournament_registration(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentRegistration, "SELECT * FROM tournament_registrations WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentRegistration not found".to_string()))?;
    // TODO: implement withdraw business logic
    Ok(StatusCode::OK)
}

pub async fn disqualify_tournament_registration(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentRegistration, "SELECT * FROM tournament_registrations WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentRegistration not found".to_string()))?;
    // TODO: implement disqualify business logic
    Ok(StatusCode::OK)
}

pub async fn promote_from_waitlist_tournament_registration(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentRegistration, "SELECT * FROM tournament_registrations WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentRegistration not found".to_string()))?;
    // TODO: implement promote_from_waitlist business logic
    Ok(StatusCode::OK)
}

pub fn tournament_registration_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/tournament_registrations", axum::routing::get(list_tournament_registration).post(create_tournament_registration))
        .route("/api/tournament_registrations/:id", axum::routing::MethodRouter::new().get(get_tournament_registration))
        .route("/api/tournament_registrations/:id/api/registrations/{id}/withdraw", axum::routing::post(withdraw_tournament_registration))
        .route("/api/tournament_registrations/:id/api/registrations/{id}/disqualify", axum::routing::post(disqualify_tournament_registration))
        .route("/api/tournament_registrations/:id/api/registrations/{id}/promote", axum::routing::post(promote_from_waitlist_tournament_registration))
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
        tournament_registration_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_tournament_registration() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournament_registrations").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_tournament_registration() {
        let pool = setup_pool().await;
        let body = json!({
        "status": "Registered",
        "points_earned": 2,
        "registered_at": "2024-01-01T00:00:00Z",
        "tournament_id": 1,
        "player_id": 1,
        "deck_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/tournament_registrations")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_tournament_registration() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().header("x-user-id", "1").uri("/api/tournament_registrations/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
