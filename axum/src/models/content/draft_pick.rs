#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct DraftPick {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub pick_number: i64,
    pub pack_number: i64,
    #[serde(rename = "pickedAt")]
    pub picked_at: String,
    pub participant_id: i64,
    pub card_id: i64,
}
