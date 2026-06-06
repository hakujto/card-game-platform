#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct TradeBid {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub amount: f64,
    #[serde(rename = "placedAt")]
    pub placed_at: String,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_winning: i64,
    pub listing_id: i64,
    pub bidder_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TradeBidCreateRequest {
    pub amount: f64,
    pub placed_at: String,
    pub is_winning: bool,
    pub listing_id: i64,
    pub bidder_id: i64,
}
