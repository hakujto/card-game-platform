// src/events/marketplace/trade_transaction.rs — domain events
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TransactionCompleted {
    pub transaction_id: i64,
    pub buyer_id: i64,
    pub seller_id: i64,
    pub final_price: f64,
    pub completed_at: String,
}
