#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct DeckSideboardCard {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub quantity: i64,
    pub deck_id: i64,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct DeckSideboardCardCreateRequest {
    pub quantity: i64,
    pub deck_id: i64,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct DeckSideboardCardUpdateRequest {
    pub quantity: Option<i64>,
    pub deck_id: Option<i64>,
    pub card_id: Option<i64>,
}
