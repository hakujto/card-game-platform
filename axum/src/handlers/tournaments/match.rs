use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::tournaments::r#match::{Match, MatchCreateRequest, MatchStatus};

type AppState = SqlitePool;

fn validate_match(payload: &MatchCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((!(payload.status == MatchStatus::BYE) || payload.player2_id.is_none())) { errors.push("BYE match must not have a second player".to_string()); }
    if !((!(payload.ended_at.is_some()) || payload.ended_at.as_deref() > payload.started_at.as_deref())) { errors.push("Match end time must be after start time".to_string()); }
    if !((!(payload.status == MatchStatus::Completed) || payload.started_at.is_some())) { errors.push("Completed match must have a start time".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct MatchListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_match(
    State(pool): State<AppState>,
    Query(params): Query<MatchListParams>,
) -> Result<Json<Vec<Match>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_match(
    State(pool): State<AppState>,
    Json(payload): Json<MatchCreateRequest>,
) -> Result<(StatusCode, Json<Match>), (StatusCode, String)> {
    let errors = validate_match(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Match,
        "INSERT INTO matches (table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, datetime('now'), datetime('now')) RETURNING *",
        payload.table_number, payload.status, payload.player1_wins, payload.player2_wins, payload.started_at, payload.ended_at, payload.result_notes, payload.round_id, payload.player1_id, payload.player2_id
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

pub async fn get_match(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Match>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))
        .map(Json)
}

pub async fn record_result_match(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))?;
    // TODO: implement record_result business logic
    // TODO: determine_winner(&_row) // @after
    Ok(StatusCode::OK)
}

pub async fn finalize_result_match(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))?;
    // TODO: implement finalize_result business logic
    // TODO: determine_winner(&_row) // @after
    Ok(StatusCode::OK)
}

pub async fn determine_winner_match(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))?;
    // TODO: implement determine_winner business logic
    Ok(StatusCode::OK)
}

pub async fn concede_match(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))?;
    // TODO: implement concede business logic
    Ok(StatusCode::OK)
}

pub async fn draw_match(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))?;
    // TODO: implement draw business logic
    Ok(StatusCode::OK)
}

pub async fn transition_match_pending_to_active(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Match>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))?;
    row.assert_transition("Active").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Match,
        "UPDATE matches SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Active", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_match_active_to_completed(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Match>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))?;
    row.assert_transition("Completed").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Match,
        "UPDATE matches SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Completed", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_match_active_to_draw(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Match>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))?;
    row.assert_transition("Draw").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Match,
        "UPDATE matches SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "Draw", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub async fn transition_match_pending_to_bye(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Match>, (StatusCode, String)> {
    // RBAC: @require([object Object])
    let row = sqlx::query_as_unchecked!(Match, "SELECT * FROM matches WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Match not found".to_string()))?;
    row.assert_transition("BYE").map_err(|e| (StatusCode::UNPROCESSABLE_ENTITY, e))?;
    let updated = sqlx::query_as_unchecked!(Match,
        "UPDATE matches SET status = $1, updated_at = datetime('now') WHERE id = $2 RETURNING *",
        "BYE", id
    ).fetch_one(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(updated))
}

pub fn match_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/matches", axum::routing::get(list_match).post(create_match))
        .route("/api/matches/:id", axum::routing::MethodRouter::new().get(get_match))
        .route("/api/matches/:id/record", axum::routing::post(record_result_match))
        .route("/api/matches/:id/finalize", axum::routing::post(finalize_result_match))
        .route("/api/matches/:id/winner", axum::routing::get(determine_winner_match))
        .route("/api/matches/:id/concede", axum::routing::post(concede_match))
        .route("/api/matches/:id/draw", axum::routing::post(draw_match))
        .route("/api/matches/:id/transitions/pending-to-active", axum::routing::patch(transition_match_pending_to_active))
        .route("/api/matches/:id/transitions/active-to-completed", axum::routing::patch(transition_match_active_to_completed))
        .route("/api/matches/:id/transitions/active-to-draw", axum::routing::patch(transition_match_active_to_draw))
        .route("/api/matches/:id/transitions/pending-to-bye", axum::routing::patch(transition_match_pending_to_bye))
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
        match_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_match() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/matches").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_match() {
        let pool = setup_pool().await;
        let body = json!({
        "status": "Pending",
        "player1_wins": 2,
        "player2_wins": 2,
        "round_id": 1,
        "player1_id": 1,
        "player2_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/matches")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_match() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/matches/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
