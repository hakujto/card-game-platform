#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct AwardedPrize {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub final_placement: i64,
    #[serde(rename = "awardedAt")]
    pub awarded_at: String,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub claimed: i64,
    #[serde(rename = "claimedAt")]
    pub claimed_at: Option<String>,
    pub prize_id: i64,
    pub player_id: i64,
}
