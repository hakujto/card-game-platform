use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::cards::deck_sideboard_card::{DeckSideboardCard, DeckSideboardCardCreateRequest, DeckSideboardCardUpdateRequest};

type AppState = SqlitePool;

fn validate_deck_sideboard_card(payload: &DeckSideboardCardCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((payload.quantity >= 1 && payload.quantity <= 4)) { errors.push("Sideboard card quantity must be between 1 and 4 copies".to_string()); }
    errors
}

#[derive(Deserialize)]
pub struct DeckSideboardCardListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_deck_sideboard_card(
    State(pool): State<AppState>,
    Query(params): Query<DeckSideboardCardListParams>,
) -> Result<Json<Vec<DeckSideboardCard>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(DeckSideboardCard, "SELECT * FROM deck_sideboard_cards LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_deck_sideboard_card(
    State(pool): State<AppState>,
    Json(payload): Json<DeckSideboardCardCreateRequest>,
) -> Result<(StatusCode, Json<DeckSideboardCard>), (StatusCode, String)> {
    let errors = validate_deck_sideboard_card(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(DeckSideboardCard,
        "INSERT INTO deck_sideboard_cards (quantity, deck_id, card_id, created_at, updated_at) VALUES ($1, $2, $3, datetime('now'), datetime('now')) RETURNING *",
        payload.quantity, payload.deck_id, payload.card_id
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

pub async fn get_deck_sideboard_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<DeckSideboardCard>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(DeckSideboardCard, "SELECT * FROM deck_sideboard_cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DeckSideboardCard not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_deck_sideboard_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<DeckSideboardCardUpdateRequest>,
) -> Result<Json<DeckSideboardCard>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(DeckSideboardCard, "SELECT * FROM deck_sideboard_cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DeckSideboardCard not found".to_string()))?;
    if let Some(v) = payload.quantity { row.quantity = v; }
    if let Some(v) = payload.deck_id { row.deck_id = v; }
    if let Some(v) = payload.card_id { row.card_id = v; }
    sqlx::query_unchecked!(
        "UPDATE deck_sideboard_cards SET quantity = $1, deck_id = $2, card_id = $3, updated_at = datetime('now') WHERE id = $4",
        row.quantity, row.deck_id, row.card_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn delete_deck_sideboard_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let result = sqlx::query_unchecked!("DELETE FROM deck_sideboard_cards WHERE id = $1", id)
        .execute(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    if result.rows_affected() == 0 {
        return Err((StatusCode::NOT_FOUND, "DeckSideboardCard not found".to_string()));
    }
    Ok(StatusCode::NO_CONTENT)
}

pub async fn increment_deck_sideboard_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DeckSideboardCard, "SELECT * FROM deck_sideboard_cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DeckSideboardCard not found".to_string()))?;
    // TODO: implement increment business logic
    Ok(StatusCode::OK)
}

pub async fn decrement_deck_sideboard_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(DeckSideboardCard, "SELECT * FROM deck_sideboard_cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "DeckSideboardCard not found".to_string()))?;
    // TODO: implement decrement business logic
    Ok(StatusCode::OK)
}

pub fn deck_sideboard_card_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/deck_sideboard_cards", axum::routing::get(list_deck_sideboard_card).post(create_deck_sideboard_card))
        .route("/api/deck_sideboard_cards/:id", axum::routing::MethodRouter::new().get(get_deck_sideboard_card).patch(patch_deck_sideboard_card).delete(delete_deck_sideboard_card))
        .route("/api/deck_sideboard_cards/:id/api/sideboard-cards/{id}/increment", axum::routing::patch(increment_deck_sideboard_card))
        .route("/api/deck_sideboard_cards/:id/api/sideboard-cards/{id}/decrement", axum::routing::patch(decrement_deck_sideboard_card))
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
        deck_sideboard_card_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_deck_sideboard_card() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/deck_sideboard_cards").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_deck_sideboard_card() {
        let pool = setup_pool().await;
        let body = json!({
        "quantity": 2,
        "deck_id": 1,
        "card_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/deck_sideboard_cards")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_deck_sideboard_card() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/deck_sideboard_cards/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_delete_deck_sideboard_card() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().method("DELETE").uri("/api/deck_sideboard_cards/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NO_CONTENT || resp.status() == StatusCode::NOT_FOUND);
    }

}
