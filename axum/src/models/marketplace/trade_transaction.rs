#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TradeTransactionStatus {
    Pending,
    Completed,
    Disputed,
    Refunded,
}

impl TradeTransactionStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            TradeTransactionStatus::Pending => "Pending",
            TradeTransactionStatus::Completed => "Completed",
            TradeTransactionStatus::Disputed => "Disputed",
            TradeTransactionStatus::Refunded => "Refunded",
        }
    }
}

impl std::fmt::Display for TradeTransactionStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TradeTransactionStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Pending" => Ok(TradeTransactionStatus::Pending),
            "Completed" => Ok(TradeTransactionStatus::Completed),
            "Disputed" => Ok(TradeTransactionStatus::Disputed),
            "Refunded" => Ok(TradeTransactionStatus::Refunded),
            _ => Err(format!("unknown TradeTransactionStatus: {}", s)),
        }
    }
}

impl From<String> for TradeTransactionStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TradeTransactionStatus: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct TradeTransaction {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub final_price: f64,
    pub platform_fee: f64,
    pub status: TradeTransactionStatus,
    #[serde(rename = "completedAt")]
    pub completed_at: Option<String>,
    pub listing_id: i64,
    pub buyer_id: i64,
    pub seller_id: i64,
}

#[derive(Debug, sqlx::FromRow, serde::Serialize)]
pub struct TradeTransactionAuditLog {
    pub id: i64,
    pub record_id: i64,
    pub field: String,
    pub old_value: Option<String>,
    pub new_value: Option<String>,
    pub changed_at: String,
}
