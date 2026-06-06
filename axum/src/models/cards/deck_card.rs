#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct DeckCard {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub quantity: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_commander: i64,
    pub deck_id: i64,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct DeckCardCreateRequest {
    pub quantity: i64,
    pub is_commander: bool,
    pub deck_id: i64,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct DeckCardUpdateRequest {
    pub quantity: Option<i64>,
    pub is_commander: Option<bool>,
    pub deck_id: Option<i64>,
    pub card_id: Option<i64>,
}
