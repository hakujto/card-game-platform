use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::cards::deck::{Deck, DeckCreateRequest, DeckUpdateRequest};

type AppState = SqlitePool;

fn validate_deck(payload: &DeckCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !(payload.wins >= 0) { errors.push("Deck wins count must not be negative".to_string()); }
    if !(payload.losses >= 0) { errors.push("Deck losses count must not be negative".to_string()); }
    if !(payload.draws >= 0) { errors.push("Deck draws count must not be negative".to_string()); }
    if !((!(payload.is_tournament_legal == true) || payload.is_public == true)) { errors.push("Tournament-legal deck must be made public".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct DeckListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_deck(
    State(pool): State<AppState>,
    Query(params): Query<DeckListParams>,
) -> Result<Json<Vec<Deck>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Deck,
            "SELECT * FROM decks WHERE (name LIKE '%' || $3 || '%' OR description LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_deck(
    State(pool): State<AppState>,
    Json(payload): Json<DeckCreateRequest>,
) -> Result<(StatusCode, Json<Deck>), (StatusCode, String)> {
    let errors = validate_deck(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Deck,
        "INSERT INTO decks (name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, datetime('now'), datetime('now')) RETURNING *",
        payload.name, payload.description, payload.format, payload.is_public, payload.is_tournament_legal, payload.archetype, payload.wins, payload.losses, payload.draws, payload.player_id
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

pub async fn get_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Deck>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<DeckCreateRequest>,
) -> Result<Json<Deck>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Deck,
        "UPDATE decks SET name = $1, description = $2, format = $3, is_public = $4, is_tournament_legal = $5, archetype = $6, wins = $7, losses = $8, draws = $9, player_id = $10, updated_at = datetime('now') WHERE id = $11 RETURNING *",
        payload.name, payload.description, payload.format, payload.is_public, payload.is_tournament_legal, payload.archetype, payload.wins, payload.losses, payload.draws, payload.player_id, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<DeckUpdateRequest>,
) -> Result<Json<Deck>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    if let Some(v) = payload.name { row.name = v; }
    if let Some(v) = payload.description { row.description = Some(v); }
    if let Some(v) = payload.format { row.format = v; }
    if let Some(v) = payload.is_public { row.is_public = v as i64; }
    if let Some(v) = payload.is_tournament_legal { row.is_tournament_legal = v as i64; }
    if let Some(v) = payload.archetype { row.archetype = Some(v); }
    if let Some(v) = payload.wins { row.wins = v; }
    if let Some(v) = payload.losses { row.losses = v; }
    if let Some(v) = payload.draws { row.draws = v; }
    if let Some(v) = payload.player_id { row.player_id = v; }
    sqlx::query_unchecked!(
        "UPDATE decks SET name = $1, description = $2, format = $3, is_public = $4, is_tournament_legal = $5, archetype = $6, wins = $7, losses = $8, draws = $9, player_id = $10, updated_at = datetime('now') WHERE id = $11",
        row.name, row.description, row.format, row.is_public, row.is_tournament_legal, row.archetype, row.wins, row.losses, row.draws, row.player_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn delete_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM decks WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "Deck not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn validate_size_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    // TODO: implement validate_size business logic
    Ok(StatusCode::OK)
}

pub async fn add_card_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    // TODO: implement add_card business logic
    Ok(StatusCode::OK)
}

pub async fn remove_card_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    // TODO: implement remove_card business logic
    Ok(StatusCode::OK)
}

pub async fn win_rate_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    // TODO: implement win_rate business logic
    Ok(StatusCode::OK)
}

pub async fn clone_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    // TODO: implement clone business logic
    Ok(StatusCode::OK)
}

pub async fn publish_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    // TODO: implement publish business logic
    Ok(StatusCode::OK)
}

pub async fn unpublish_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    // TODO: implement unpublish business logic
    Ok(StatusCode::OK)
}

pub async fn certify_tournament_legal_deck(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Deck, "SELECT * FROM decks WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Deck not found".to_string()))?;
    // TODO: implement certify_tournament_legal business logic
    Ok(StatusCode::OK)
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
#[allow(dead_code)]
fn hook_recalculate_tournament_legal(_row: &Deck) {
    // TODO: implement recalculate_tournament_legal
}

pub fn deck_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/decks", axum::routing::get(list_deck).post(create_deck))
        .route("/api/decks/:id", axum::routing::MethodRouter::new().get(get_deck).put(update_deck).patch(patch_deck).delete(delete_deck))
        .route("/api/decks/:id/validate", axum::routing::get(validate_size_deck))
        .route("/api/decks/:id/cards", axum::routing::post(add_card_deck))
        .route("/api/decks/:id/cards/{card_id}", axum::routing::delete(remove_card_deck))
        .route("/api/decks/:id/win-rate", axum::routing::get(win_rate_deck))
        .route("/api/decks/:id/clone", axum::routing::post(clone_deck))
        .route("/api/decks/:id/publish", axum::routing::post(publish_deck))
        .route("/api/decks/:id/unpublish", axum::routing::post(unpublish_deck))
        .route("/api/decks/:id/certify", axum::routing::post(certify_tournament_legal_deck))
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
        deck_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_deck() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/decks").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_deck() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/decks?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_deck() {
        let pool = setup_pool().await;
        let body = json!({
        "name": "test",
        "format": "Standard",
        "is_public": false,
        "is_tournament_legal": false,
        "wins": 2,
        "losses": 2,
        "draws": 2,
        "player_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/decks")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_deck() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/decks/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_deck() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "name": "test",
        "format": "Standard",
        "is_public": false,
        "is_tournament_legal": false,
        "wins": 2,
        "losses": 2,
        "draws": 2,
        "player_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/decks")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "name": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/decks/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

    #[tokio::test]
    async fn test_delete_deck() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/decks/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
