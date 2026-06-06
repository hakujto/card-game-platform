#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct DraftParticipant {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub seat_number: i64,
    #[serde(rename = "joinedAt")]
    pub joined_at: String,
    pub session_id: i64,
    pub player_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct DraftParticipantCreateRequest {
    pub seat_number: i64,
    pub joined_at: String,
    pub session_id: i64,
    pub player_id: i64,
}
