#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TradeListingStatus {
    Active,
    Sold,
    Expired,
    Cancelled,
    Pending,
}

impl TradeListingStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            TradeListingStatus::Active => "Active",
            TradeListingStatus::Sold => "Sold",
            TradeListingStatus::Expired => "Expired",
            TradeListingStatus::Cancelled => "Cancelled",
            TradeListingStatus::Pending => "Pending",
        }
    }
}

impl std::fmt::Display for TradeListingStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TradeListingStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Active" => Ok(TradeListingStatus::Active),
            "Sold" => Ok(TradeListingStatus::Sold),
            "Expired" => Ok(TradeListingStatus::Expired),
            "Cancelled" => Ok(TradeListingStatus::Cancelled),
            "Pending" => Ok(TradeListingStatus::Pending),
            _ => Err(format!("unknown TradeListingStatus: {}", s)),
        }
    }
}

impl From<String> for TradeListingStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TradeListingStatus: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TradeListingListingType {
    FixedPrice,
    Auction,
    TradeOffer,
}

impl TradeListingListingType {
    pub fn as_str(&self) -> &'static str {
        match self {
            TradeListingListingType::FixedPrice => "FixedPrice",
            TradeListingListingType::Auction => "Auction",
            TradeListingListingType::TradeOffer => "TradeOffer",
        }
    }
}

impl std::fmt::Display for TradeListingListingType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TradeListingListingType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "FixedPrice" => Ok(TradeListingListingType::FixedPrice),
            "Auction" => Ok(TradeListingListingType::Auction),
            "TradeOffer" => Ok(TradeListingListingType::TradeOffer),
            _ => Err(format!("unknown TradeListingListingType: {}", s)),
        }
    }
}

impl From<String> for TradeListingListingType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TradeListingListingType: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TradeListingCondition {
    Mint,
    NearMint,
    Excellent,
    Good,
    Played,
}

impl TradeListingCondition {
    pub fn as_str(&self) -> &'static str {
        match self {
            TradeListingCondition::Mint => "Mint",
            TradeListingCondition::NearMint => "NearMint",
            TradeListingCondition::Excellent => "Excellent",
            TradeListingCondition::Good => "Good",
            TradeListingCondition::Played => "Played",
        }
    }
}

impl std::fmt::Display for TradeListingCondition {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TradeListingCondition {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Mint" => Ok(TradeListingCondition::Mint),
            "NearMint" => Ok(TradeListingCondition::NearMint),
            "Excellent" => Ok(TradeListingCondition::Excellent),
            "Good" => Ok(TradeListingCondition::Good),
            "Played" => Ok(TradeListingCondition::Played),
            _ => Err(format!("unknown TradeListingCondition: {}", s)),
        }
    }
}

impl From<String> for TradeListingCondition {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TradeListingCondition: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct TradeListing {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub public_id: String,
    pub status: TradeListingStatus,
    pub listing_type: TradeListingListingType,
    pub asking_price: Option<f64>,
    pub auction_start_price: Option<f64>,
    pub auction_current_bid: Option<f64>,
    #[serde(rename = "auctionEndTime")]
    pub auction_end_time: Option<String>,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub foil: i64,
    pub condition: TradeListingCondition,
    pub quantity: i64,
    pub description: Option<String>,
    #[serde(rename = "expiresAt")]
    pub expires_at: Option<String>,
    pub seller_id: i64,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TradeListingCreateRequest {
    pub public_id: String,
    pub status: TradeListingStatus,
    pub listing_type: TradeListingListingType,
    pub asking_price: Option<f64>,
    pub auction_start_price: Option<f64>,
    pub auction_current_bid: Option<f64>,
    pub auction_end_time: Option<String>,
    pub foil: bool,
    pub condition: TradeListingCondition,
    pub quantity: i64,
    pub description: Option<String>,
    pub expires_at: Option<String>,
    pub seller_id: i64,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TradeListingUpdateRequest {
    pub public_id: Option<String>,
    pub listing_type: Option<TradeListingListingType>,
    pub asking_price: Option<f64>,
    pub auction_start_price: Option<f64>,
    pub auction_current_bid: Option<f64>,
    pub auction_end_time: Option<String>,
    pub foil: Option<bool>,
    pub condition: Option<TradeListingCondition>,
    pub quantity: Option<i64>,
    pub description: Option<String>,
    pub expires_at: Option<String>,
    pub seller_id: Option<i64>,
    pub card_id: Option<i64>,
}

impl TradeListing {
    pub fn assert_transition(&self, to: &str) -> Result<(), String> {
        let allowed: &[(&str, &str)] = &[
            ("Pending", "Active"),
            ("Active", "Sold"),
            ("Active", "Expired"),
            ("Active", "Cancelled"),
        ];
        let current = &self.status;
        if allowed.iter().any(|(from, t)| *from == current.as_str() && *t == to) {
            Ok(())
        } else {
            Err(format!("transition {} -> {} not allowed", current, to))
        }
    }
}
