use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::tournaments::tournament::{Tournament, TournamentCreateRequest, TournamentUpdateRequest};

type AppState = SqlitePool;

fn validate_tournament(payload: &TournamentCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((payload.max_players >= 2 && payload.max_players <= 512)) { errors.push("Tournament must allow between 2 and 512 players".to_string()); }
    if !(payload.entry_fee >= 0.0) { errors.push("Entry fee must not be negative".to_string()); }
    if !(payload.prize_pool >= 0.0) { errors.push("Prize pool must not be negative".to_string()); }
    if !((!(payload.end_time.is_some()) || payload.end_time.as_deref() > Some(payload.start_time.as_str()))) { errors.push("End time must be after start time".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct TournamentListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_tournament(
    State(pool): State<AppState>,
    Query(params): Query<TournamentListParams>,
) -> Result<Json<Vec<Tournament>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Tournament,
            "SELECT * FROM tournaments WHERE (name LIKE '%' || $3 || '%' OR description LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_tournament(
    State(pool): State<AppState>,
    Json(payload): Json<TournamentCreateRequest>,
) -> Result<(StatusCode, Json<Tournament>), (StatusCode, String)> {
    let errors = validate_tournament(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Tournament,
        "INSERT INTO tournaments (name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, datetime('now'), datetime('now')) RETURNING *",
        payload.name, payload.description, payload.status, payload.format, payload.tournament_type, payload.max_players, payload.entry_fee, payload.prize_pool, payload.start_time, payload.end_time, payload.is_online, payload.location, payload.rules_text, payload.season_id, payload.organizer_id
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

pub async fn get_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Tournament>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<TournamentCreateRequest>,
) -> Result<Json<Tournament>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Tournament,
        "UPDATE tournaments SET name = $1, description = $2, status = $3, format = $4, tournament_type = $5, max_players = $6, entry_fee = $7, prize_pool = $8, start_time = $9, end_time = $10, is_online = $11, location = $12, rules_text = $13, season_id = $14, organizer_id = $15, updated_at = datetime('now') WHERE id = $16 RETURNING *",
        payload.name, payload.description, payload.status, payload.format, payload.tournament_type, payload.max_players, payload.entry_fee, payload.prize_pool, payload.start_time, payload.end_time, payload.is_online, payload.location, payload.rules_text, payload.season_id, payload.organizer_id, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<TournamentUpdateRequest>,
) -> Result<Json<Tournament>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    if let Some(v) = payload.name { row.name = v; }
    if let Some(v) = payload.description { row.description = Some(v); }
    if let Some(v) = payload.status { row.status = v; }
    if let Some(v) = payload.format { row.format = v; }
    if let Some(v) = payload.tournament_type { row.tournament_type = v; }
    if let Some(v) = payload.max_players { row.max_players = v; }
    if let Some(v) = payload.entry_fee { row.entry_fee = v; }
    if let Some(v) = payload.prize_pool { row.prize_pool = v; }
    if let Some(v) = payload.start_time { row.start_time = v; }
    if let Some(v) = payload.end_time { row.end_time = Some(v); }
    if let Some(v) = payload.is_online { row.is_online = v as i64; }
    if let Some(v) = payload.location { row.location = Some(v); }
    if let Some(v) = payload.rules_text { row.rules_text = Some(v); }
    if let Some(v) = payload.season_id { row.season_id = v; }
    if let Some(v) = payload.organizer_id { row.organizer_id = v; }
    sqlx::query_unchecked!(
        "UPDATE tournaments SET name = $1, description = $2, status = $3, format = $4, tournament_type = $5, max_players = $6, entry_fee = $7, prize_pool = $8, start_time = $9, end_time = $10, is_online = $11, location = $12, rules_text = $13, season_id = $14, organizer_id = $15, updated_at = datetime('now') WHERE id = $16",
        row.name, row.description, row.status, row.format, row.tournament_type, row.max_players, row.entry_fee, row.prize_pool, row.start_time, row.end_time, row.is_online, row.location, row.rules_text, row.season_id, row.organizer_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn start_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    // TODO: implement start business logic
    Ok(StatusCode::OK)
}

pub async fn cancel_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    // TODO: implement cancel business logic
    Ok(StatusCode::OK)
}

pub async fn complete_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    // TODO: implement complete business logic
    Ok(StatusCode::OK)
}

pub async fn generate_round_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    // TODO: implement generate_round business logic
    Ok(StatusCode::OK)
}

pub async fn calculate_prize_distribution_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    // TODO: implement calculate_prize_distribution business logic
    Ok(StatusCode::OK)
}

pub async fn register_player_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    // TODO: implement register_player business logic
    Ok(StatusCode::OK)
}

pub async fn is_full_tournament(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    // TODO: implement is_full business logic
    Ok(StatusCode::OK)
}

pub async fn transition_tournament_draft_to_registration(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Tournament>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    row.assert_transition("Registration").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Tournament,
        "UPDATE tournaments SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Registration", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_tournament_registration_to_ongoing(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Tournament>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    row.assert_transition("Ongoing").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Tournament,
        "UPDATE tournaments SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Ongoing", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_tournament_registration_to_cancelled(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Tournament>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    row.assert_transition("Cancelled").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Tournament,
        "UPDATE tournaments SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Cancelled", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_tournament_ongoing_to_completed(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Tournament>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    row.assert_transition("Completed").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Tournament,
        "UPDATE tournaments SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Completed", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_tournament_ongoing_to_cancelled(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Tournament>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Tournament, "SELECT * FROM tournaments WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Tournament not found".to_string()))?;
    row.assert_transition("Cancelled").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Tournament,
        "UPDATE tournaments SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Cancelled", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
#[allow(dead_code)]
fn hook_sync_season_stats(_row: &Tournament) {
    // TODO: implement sync_season_stats
}

#[allow(dead_code)]
fn hook_prevent_delete_if_ongoing(_row: &Tournament) {
    // TODO: implement prevent_delete_if_ongoing
}

pub fn tournament_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/tournaments", axum::routing::get(list_tournament).post(create_tournament))
        .route("/api/tournaments/:id", axum::routing::MethodRouter::new().get(get_tournament).put(update_tournament).patch(patch_tournament))
        .route("/api/tournaments/:id/start", axum::routing::post(start_tournament))
        .route("/api/tournaments/:id/cancel", axum::routing::post(cancel_tournament))
        .route("/api/tournaments/:id/complete", axum::routing::post(complete_tournament))
        .route("/api/tournaments/:id/rounds", axum::routing::post(generate_round_tournament))
        .route("/api/tournaments/:id/prizes", axum::routing::get(calculate_prize_distribution_tournament))
        .route("/api/tournaments/:id/register", axum::routing::post(register_player_tournament))
        .route("/api/tournaments/:id/full", axum::routing::get(is_full_tournament))
        .route("/api/tournaments/:id/transitions/draft-to-registration", axum::routing::patch(transition_tournament_draft_to_registration))
        .route("/api/tournaments/:id/transitions/registration-to-ongoing", axum::routing::patch(transition_tournament_registration_to_ongoing))
        .route("/api/tournaments/:id/transitions/registration-to-cancelled", axum::routing::patch(transition_tournament_registration_to_cancelled))
        .route("/api/tournaments/:id/transitions/ongoing-to-completed", axum::routing::patch(transition_tournament_ongoing_to_completed))
        .route("/api/tournaments/:id/transitions/ongoing-to-cancelled", axum::routing::patch(transition_tournament_ongoing_to_cancelled))
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
        tournament_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_tournament() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournaments").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_tournament() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournaments?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_tournament() {
        let pool = setup_pool().await;
        let body = json!({
        "name": "test",
        "status": "Draft",
        "format": "Standard",
        "tournament_type": "Swiss",
        "max_players": 2,
        "entry_fee": 1.0,
        "prize_pool": 1.0,
        "start_time": "2024-01-01T00:00:00Z",
        "is_online": false,
        "season_id": 1,
        "organizer_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/tournaments")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_tournament() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournaments/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_tournament() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "name": "test",
        "status": "Draft",
        "format": "Standard",
        "tournament_type": "Swiss",
        "max_players": 2,
        "entry_fee": 1.0,
        "prize_pool": 1.0,
        "start_time": "2024-01-01T00:00:00Z",
        "is_online": false,
        "season_id": 1,
        "organizer_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/tournaments")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "name": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/tournaments/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
