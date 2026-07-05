// src/events/marketplace/order.rs — domain events
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OrderPaid {
    pub order_id: i64,
    pub player_id: i64,
    pub total: f64,
    pub payment_method: String,
    pub paid_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OrderShipped {
    pub order_id: i64,
    pub tracking_number: String,
    pub shipped_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OrderRefunded {
    pub order_id: i64,
    pub refunded_at: String,
}
