#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct DeckTagAssignment {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub deck_id: i64,
    pub tag_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct DeckTagAssignmentCreateRequest {
    pub deck_id: i64,
    pub tag_id: i64,
}
