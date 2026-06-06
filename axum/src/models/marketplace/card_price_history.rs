#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct CardPriceHistory {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub price_date: String,
    pub avg_price: f64,
    pub min_price: f64,
    pub max_price: f64,
    pub volume: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub foil: i64,
    pub card_id: i64,
}
