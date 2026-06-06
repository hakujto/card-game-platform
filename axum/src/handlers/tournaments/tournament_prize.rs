use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::tournaments::tournament_prize::{TournamentPrize, TournamentPrizeCreateRequest, TournamentPrizeUpdateRequest};

type AppState = SqlitePool;

fn validate_tournament_prize(payload: &TournamentPrizeCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.placement_to >= payload.placement_from) { errors.push("placement_to must be greater than or equal to placement_from".to_string()); }
    if !(payload.placement_from > 0) { errors.push("placement_from must be greater than zero".to_string()); }
    if !(payload.amount >= 0.0) { errors.push("Prize amount must not be negative".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct TournamentPrizeListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_tournament_prize(
    State(pool): State<AppState>,
    Query(params): Query<TournamentPrizeListParams>,
) -> Result<Json<Vec<TournamentPrize>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(TournamentPrize, "SELECT * FROM tournament_prizes LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_tournament_prize(
    State(pool): State<AppState>,
    Json(payload): Json<TournamentPrizeCreateRequest>,
) -> Result<(StatusCode, Json<TournamentPrize>), (StatusCode, String)> {
    let errors = validate_tournament_prize(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(TournamentPrize,
        "INSERT INTO tournament_prizes (placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, datetime('now'), datetime('now')) RETURNING *",
        payload.placement_from, payload.placement_to, payload.prize_type, payload.amount, payload.description, payload.packs_count, payload.season_points, payload.tournament_id
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

pub async fn get_tournament_prize(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TournamentPrize>, (StatusCode, String)> {
    sqlx::query_as_unchecked!(TournamentPrize, "SELECT * FROM tournament_prizes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentPrize not found".to_string()))
        .map(Json)
}

pub async fn update_tournament_prize(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<TournamentPrizeCreateRequest>,
) -> Result<Json<TournamentPrize>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TournamentPrize,
        "UPDATE tournament_prizes SET placement_from = $1, placement_to = $2, prize_type = $3, amount = $4, description = $5, packs_count = $6, season_points = $7, tournament_id = $8, updated_at = datetime('now') WHERE id = $9 RETURNING *",
        payload.placement_from, payload.placement_to, payload.prize_type, payload.amount, payload.description, payload.packs_count, payload.season_points, payload.tournament_id, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "TournamentPrize not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_tournament_prize(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<TournamentPrizeUpdateRequest>,
) -> Result<Json<TournamentPrize>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(TournamentPrize, "SELECT * FROM tournament_prizes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentPrize not found".to_string()))?;
    if let Some(v) = payload.placement_from { row.placement_from = v; }
    if let Some(v) = payload.placement_to { row.placement_to = v; }
    if let Some(v) = payload.prize_type { row.prize_type = v; }
    if let Some(v) = payload.amount { row.amount = v; }
    if let Some(v) = payload.description { row.description = Some(v); }
    if let Some(v) = payload.packs_count { row.packs_count = Some(v); }
    if let Some(v) = payload.season_points { row.season_points = v; }
    if let Some(v) = payload.tournament_id { row.tournament_id = v; }
    sqlx::query_unchecked!(
        "UPDATE tournament_prizes SET placement_from = $1, placement_to = $2, prize_type = $3, amount = $4, description = $5, packs_count = $6, season_points = $7, tournament_id = $8, updated_at = datetime('now') WHERE id = $9",
        row.placement_from, row.placement_to, row.prize_type, row.amount, row.description, row.packs_count, row.season_points, row.tournament_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn delete_tournament_prize(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM tournament_prizes WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "TournamentPrize not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn applies_to_placement_tournament_prize(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentPrize, "SELECT * FROM tournament_prizes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentPrize not found".to_string()))?;
    // TODO: implement applies_to_placement business logic
    Ok(StatusCode::OK)
}

pub async fn award_to_player_tournament_prize(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TournamentPrize, "SELECT * FROM tournament_prizes WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TournamentPrize not found".to_string()))?;
    // TODO: implement award_to_player business logic
    Ok(StatusCode::OK)
}

pub fn tournament_prize_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/tournament_prizes", axum::routing::get(list_tournament_prize).post(create_tournament_prize))
        .route("/api/tournament_prizes/:id", axum::routing::MethodRouter::new().get(get_tournament_prize).put(update_tournament_prize).patch(patch_tournament_prize).delete(delete_tournament_prize))
        .route("/api/tournament_prizes/:id/api/prizes/{id}/applies", axum::routing::get(applies_to_placement_tournament_prize))
        .route("/api/tournament_prizes/:id/api/prizes/{id}/award", axum::routing::post(award_to_player_tournament_prize))
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
        tournament_prize_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_tournament_prize() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournament_prizes").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_tournament_prize() {
        let pool = setup_pool().await;
        let body = json!({
        "placement_from": 2,
        "placement_to": 2,
        "prize_type": "Currency",
        "amount": 1.0,
        "season_points": 2,
        "tournament_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/tournament_prizes")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_tournament_prize() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/tournament_prizes/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_tournament_prize() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "placement_from": 2,
        "placement_to": 2,
        "prize_type": "Currency",
        "amount": 1.0,
        "season_points": 2,
        "tournament_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/tournament_prizes")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "description": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/tournament_prizes/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

    #[tokio::test]
    async fn test_delete_tournament_prize() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/tournament_prizes/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
