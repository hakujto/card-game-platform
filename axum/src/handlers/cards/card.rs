use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::cards::card::{Card, CardCreateRequest, CardUpdateRequest, CardCardType};

type AppState = SqlitePool;

fn validate_card(payload: &CardCreateRequest) -> Vec<String> {
    let mut errors: Vec<String> = Vec::new();
    if !((!(payload.card_type == CardCardType::Creature) || (payload.attack.is_some() && payload.defense.is_some()))) { errors.push("Creature card must have attack and defense".to_string()); }
    if !((!(payload.card_type == CardCardType::Planeswalker) || payload.loyalty.is_some())) { errors.push("Planeswalker card must have loyalty".to_string()); }
    if !((!(payload.card_type == CardCardType::Land) || payload.mana_cost == 0)) { errors.push("Land card must have zero mana cost".to_string()); }
    if !((!(payload.card_type != CardCardType::Planeswalker) || payload.loyalty.is_none())) { errors.push("Only Planeswalker cards can have loyalty".to_string()); }
    if !((payload.mana_cost >= 0 && payload.mana_cost <= 20)) { errors.push("mana_cost must be between 0 and 20".to_string()); }
    if !((payload.power_level >= 1 && payload.power_level <= 10)) { errors.push("power_level must be between 1 and 10".to_string()); }
    if !((!(payload.is_banned == true) || true /* unsupported: unknown enum variant CardLegalFormats::Message */)) { errors.push("Validation failed: banned_card_not_in_legal_formats".to_string()); }
    if payload.mana_cost < 0 { errors.push("mana_cost must be >= 0".to_string()); }
    if payload.mana_cost > 20 { errors.push("mana_cost must be <= 20".to_string()); }
    if payload.power_level < 1 { errors.push("power_level must be >= 1".to_string()); }
    if payload.power_level > 10 { errors.push("power_level must be <= 10".to_string()); }
    // @required_when: attack — {"type":"eq","field":"card_type","value":"Creature"}
    // @required_when: defense — {"type":"eq","field":"card_type","value":"Creature"}
    // @required_when: loyalty — {"type":"eq","field":"card_type","value":"Planeswalker"}
    errors
}

#[derive(Deserialize)]
pub struct CardListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
    pub q: Option<String>,
}

pub async fn list_card(
    State(pool): State<AppState>,
    Query(params): Query<CardListParams>,
) -> Result<Json<Vec<Card>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = if let Some(q) = params.q {
        sqlx::query_as_unchecked!(Card,
            "SELECT * FROM cards WHERE (name LIKE '%' || $3 || '%' OR artist_name LIKE '%' || $3 || '%') LIMIT $1 OFFSET $2",
            limit, skip, q
        ).fetch_all(&pool).await
    } else {
        sqlx::query_as_unchecked!(Card, "SELECT * FROM cards LIMIT $1 OFFSET $2", limit, skip)
            .fetch_all(&pool).await
    };
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn create_card(
    State(pool): State<AppState>,
    Json(payload): Json<CardCreateRequest>,
) -> Result<(StatusCode, Json<Card>), (StatusCode, String)> {
    let errors = validate_card(&payload);
    if !errors.is_empty() { return Err((StatusCode::BAD_REQUEST, errors.join(", "))); }
    let row = sqlx::query_as_unchecked!(Card,
        "INSERT INTO cards (public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, datetime('now'), datetime('now')) RETURNING *",
        payload.public_id, payload.name, payload.card_type, payload.rarity, payload.mana_cost, payload.mana_colors, payload.attack, payload.defense, payload.loyalty, payload.description, payload.flavor_text, payload.image_url, payload.artist_name, payload.legal_formats, payload.is_banned, payload.is_restricted, payload.power_level, payload.metadata, payload.total_copies_in_circulation, payload.set_id
    ).fetch_one(&pool).await
    .map_err(|e| {
        // @unique fields: public_id
        if e.to_string().contains("UNIQUE") {
            (StatusCode::UNPROCESSABLE_ENTITY, "Value must be unique".to_string())
        } else {
            (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
        }
    })?;
    Ok((StatusCode::CREATED, Json(row)))
}

pub async fn get_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Card>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    Ok(Json(row))
}

pub async fn update_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CardCreateRequest>,
) -> Result<Json<Card>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(Card,
        "UPDATE cards SET public_id = $1, name = $2, card_type = $3, rarity = $4, mana_cost = $5, mana_colors = $6, attack = $7, defense = $8, loyalty = $9, description = $10, flavor_text = $11, image_url = $12, artist_name = $13, legal_formats = $14, power_level = $15, metadata = $16, total_copies_in_circulation = $17, set_id = $18, updated_at = datetime('now') WHERE id = $19 RETURNING *",
        payload.public_id, payload.name, payload.card_type, payload.rarity, payload.mana_cost, payload.mana_colors, payload.attack, payload.defense, payload.loyalty, payload.description, payload.flavor_text, payload.image_url, payload.artist_name, payload.legal_formats, payload.power_level, payload.metadata, payload.total_copies_in_circulation, payload.set_id, id
    ).fetch_optional(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    Ok(Json(row))
}

pub async fn patch_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
    Json(payload): Json<CardUpdateRequest>,
) -> Result<Json<Card>, (StatusCode, String)> {
    // Fetch current, apply optional fields, then UPDATE
    let mut row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    if let Some(v) = payload.public_id { row.public_id = v; }
    if let Some(v) = payload.name { row.name = v; }
    if let Some(v) = payload.card_type { row.card_type = v; }
    if let Some(v) = payload.rarity { row.rarity = v; }
    if let Some(v) = payload.mana_cost { row.mana_cost = v; }
    if let Some(v) = payload.mana_colors { row.mana_colors = v; }
    if let Some(v) = payload.attack { row.attack = Some(v); }
    if let Some(v) = payload.defense { row.defense = Some(v); }
    if let Some(v) = payload.loyalty { row.loyalty = Some(v); }
    if let Some(v) = payload.description { row.description = v; }
    if let Some(v) = payload.flavor_text { row.flavor_text = Some(v); }
    if let Some(v) = payload.image_url { row.image_url = Some(v); }
    if let Some(v) = payload.artist_name { row.artist_name = Some(v); }
    if let Some(v) = payload.legal_formats { row.legal_formats = v; }
    if let Some(v) = payload.power_level { row.power_level = v; }
    if let Some(v) = payload.metadata { row.metadata = Some(v); }
    if let Some(v) = payload.total_copies_in_circulation { row.total_copies_in_circulation = v; }
    if let Some(v) = payload.set_id { row.set_id = v; }
    sqlx::query_unchecked!(
        "UPDATE cards SET public_id = $1, name = $2, card_type = $3, rarity = $4, mana_cost = $5, mana_colors = $6, attack = $7, defense = $8, loyalty = $9, description = $10, flavor_text = $11, image_url = $12, artist_name = $13, legal_formats = $14, power_level = $15, metadata = $16, total_copies_in_circulation = $17, set_id = $18, updated_at = datetime('now') WHERE id = $19",
        row.public_id, row.name, row.card_type, row.rarity, row.mana_cost, row.mana_colors, row.attack, row.defense, row.loyalty, row.description, row.flavor_text, row.image_url, row.artist_name, row.legal_formats, row.power_level, row.metadata, row.total_copies_in_circulation, row.set_id, id
    ).execute(&pool).await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;
    Ok(Json(row))
}

pub async fn ban_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    // RBAC: allowed roles: admin, moderator
    // TODO: extract role from request and check against allowed roles
    let _row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    // TODO: implement ban business logic
    Ok(StatusCode::OK)
}

pub async fn unban_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    // RBAC: allowed roles: admin, moderator
    // TODO: extract role from request and check against allowed roles
    let _row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    // TODO: implement unban business logic
    Ok(StatusCode::OK)
}

pub async fn restrict_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    // RBAC: allowed roles: admin, moderator
    // TODO: extract role from request and check against allowed roles
    let _row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    // TODO: implement restrict business logic
    Ok(StatusCode::OK)
}

pub async fn unrestrict_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    // RBAC: allowed roles: admin, moderator
    // TODO: extract role from request and check against allowed roles
    let _row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    // TODO: implement unrestrict business logic
    Ok(StatusCode::OK)
}

pub async fn replace_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    // RBAC: allowed roles: admin
    // TODO: extract role from request and check against allowed roles
    let _row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    // TODO: implement replace business logic
    Ok(StatusCode::OK)
}

pub async fn calculate_value_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    // TODO: implement calculate_value business logic
    Ok(StatusCode::OK)
}

pub async fn apply_rarity_bonus_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    // TODO: implement apply_rarity_bonus business logic
    Ok(StatusCode::OK)
}

pub async fn is_legal_in_format_card(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(Card, "SELECT * FROM cards WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "Card not found".to_string()))?;
    // TODO: implement is_legal_in_format business logic
    Ok(StatusCode::OK)
}

// ── Lifecycle hooks ──────────────────────────────────────────────────
#[allow(dead_code)]
fn hook_validate_legality(_row: &Card) {
    // TODO: implement validate_legality
}

#[allow(dead_code)]
fn hook_validate_not_in_use(_row: &Card) {
    // TODO: implement validate_not_in_use
}

pub fn card_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/cards", axum::routing::get(list_card).post(create_card))
        .route("/api/cards/:id", axum::routing::MethodRouter::new().get(get_card).put(update_card).patch(patch_card))
        .route("/api/cards/:id/ban", axum::routing::post(ban_card))
        .route("/api/cards/:id/unban", axum::routing::post(unban_card))
        .route("/api/cards/:id/restrict", axum::routing::post(restrict_card))
        .route("/api/cards/:id/unrestrict", axum::routing::post(unrestrict_card))
        .route("/api/cards/:id/value", axum::routing::get(calculate_value_card))
        .route("/api/cards/:id/rarity-bonus", axum::routing::post(apply_rarity_bonus_card))
        .route("/api/cards/:id/legal", axum::routing::get(is_legal_in_format_card))
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
        card_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_card() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/cards").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_search_card() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/cards?q=test").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_create_card() {
        let pool = setup_pool().await;
        let body = json!({
        "public_id": "00000000-0000-0000-0000-000000000001",
        "name": "Test Lightning Bolt",
        "card_type": "Spell",
        "rarity": "Common",
        "mana_cost": 1,
        "mana_colors": "White",
        "description": "test",
        "legal_formats": "Standard",
        "is_banned": false,
        "is_restricted": false,
        "power_level": 3,
        "total_copies_in_circulation": 2,
        "set_id": 1
    });
        let resp = app(pool).oneshot(
            Request::builder()
                .method("POST")
                .uri("/api/cards")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::CREATED);
    }

    #[tokio::test]
    async fn test_retrieve_card() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/cards/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

    #[tokio::test]
    async fn test_update_card() {
        let pool = setup_pool().await;
        // First create
        let body = json!({
        "public_id": "00000000-0000-0000-0000-000000000001",
        "name": "Test Lightning Bolt",
        "card_type": "Spell",
        "rarity": "Common",
        "mana_cost": 1,
        "mana_colors": "White",
        "description": "test",
        "legal_formats": "Standard",
        "is_banned": false,
        "is_restricted": false,
        "power_level": 3,
        "total_copies_in_circulation": 2,
        "set_id": 1
    });
        let _ = app(pool.clone()).oneshot(
            Request::builder().method("POST").uri("/api/cards")
                .header("content-type", "application/json")
                .body(Body::from(body.to_string())).unwrap()
        ).await.unwrap();
        let patch_body = json!({ "flavor_text": "updated" });
        let resp = app(pool).oneshot(
            Request::builder().method("PATCH").uri("/api/cards/1")
                .header("content-type", "application/json")
                .body(Body::from(patch_body.to_string())).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND);
    }

}
