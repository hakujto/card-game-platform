#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct OrderItem {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub quantity: i64,
    pub price_at_purchase: f64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub foil: i64,
    pub order_id: i64,
    pub product_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct OrderItemCreateRequest {
    pub quantity: i64,
    pub price_at_purchase: f64,
    pub foil: bool,
    pub order_id: i64,
    pub product_id: i64,
}
