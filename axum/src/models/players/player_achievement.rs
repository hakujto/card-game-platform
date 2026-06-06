#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct PlayerAchievement {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    #[serde(rename = "earnedAt")]
    pub earned_at: String,
    pub progress: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_completed: i64,
    pub player_id: i64,
    pub achievement_id: i64,
}
