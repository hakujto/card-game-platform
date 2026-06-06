#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TradeDisputeStatus {
    Open,
    UnderReview,
    Resolved,
    Escalated,
}

impl TradeDisputeStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            TradeDisputeStatus::Open => "Open",
            TradeDisputeStatus::UnderReview => "UnderReview",
            TradeDisputeStatus::Resolved => "Resolved",
            TradeDisputeStatus::Escalated => "Escalated",
        }
    }
}

impl std::fmt::Display for TradeDisputeStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TradeDisputeStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Open" => Ok(TradeDisputeStatus::Open),
            "UnderReview" => Ok(TradeDisputeStatus::UnderReview),
            "Resolved" => Ok(TradeDisputeStatus::Resolved),
            "Escalated" => Ok(TradeDisputeStatus::Escalated),
            _ => Err(format!("unknown TradeDisputeStatus: {}", s)),
        }
    }
}

impl From<String> for TradeDisputeStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TradeDisputeStatus: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TradeDisputeReason {
    ItemNotReceived,
    ItemNotAsDescribed,
    FraudSuspected,
    Other,
}

impl TradeDisputeReason {
    pub fn as_str(&self) -> &'static str {
        match self {
            TradeDisputeReason::ItemNotReceived => "ItemNotReceived",
            TradeDisputeReason::ItemNotAsDescribed => "ItemNotAsDescribed",
            TradeDisputeReason::FraudSuspected => "FraudSuspected",
            TradeDisputeReason::Other => "Other",
        }
    }
}

impl std::fmt::Display for TradeDisputeReason {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TradeDisputeReason {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "ItemNotReceived" => Ok(TradeDisputeReason::ItemNotReceived),
            "ItemNotAsDescribed" => Ok(TradeDisputeReason::ItemNotAsDescribed),
            "FraudSuspected" => Ok(TradeDisputeReason::FraudSuspected),
            "Other" => Ok(TradeDisputeReason::Other),
            _ => Err(format!("unknown TradeDisputeReason: {}", s)),
        }
    }
}

impl From<String> for TradeDisputeReason {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TradeDisputeReason: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct TradeDispute {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub status: TradeDisputeStatus,
    pub reason: TradeDisputeReason,
    pub description: String,
    pub resolution: Option<String>,
    #[serde(rename = "openedAt")]
    pub opened_at: String,
    #[serde(rename = "resolvedAt")]
    pub resolved_at: Option<String>,
    pub transaction_id: i64,
    pub opened_by_id: i64,
    pub resolved_by_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct TradeDisputeCreateRequest {
    pub status: TradeDisputeStatus,
    pub reason: TradeDisputeReason,
    pub description: String,
    pub resolution: Option<String>,
    pub opened_at: String,
    pub resolved_at: Option<String>,
    pub transaction_id: i64,
    pub opened_by_id: i64,
    pub resolved_by_id: Option<i64>,
}

impl TradeDispute {
    pub fn assert_transition(&self, to: &str) -> Result<(), String> {
        let allowed: &[(&str, &str)] = &[
            ("Open", "UnderReview"),
            ("UnderReview", "Resolved"),
            ("UnderReview", "Escalated"),
            ("Escalated", "Resolved"),
        ];
        let current = &self.status;
        if allowed.iter().any(|(from, t)| *from == current.as_str() && *t == to) {
            Ok(())
        } else {
            Err(format!("transition {} -> {} not allowed", current, to))
        }
    }
}
