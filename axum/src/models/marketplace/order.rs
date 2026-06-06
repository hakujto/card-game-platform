#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum OrderStatus {
    Pending,
    Paid,
    Processing,
    Shipped,
    Completed,
    Cancelled,
    Refunded,
}

impl OrderStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            OrderStatus::Pending => "Pending",
            OrderStatus::Paid => "Paid",
            OrderStatus::Processing => "Processing",
            OrderStatus::Shipped => "Shipped",
            OrderStatus::Completed => "Completed",
            OrderStatus::Cancelled => "Cancelled",
            OrderStatus::Refunded => "Refunded",
        }
    }
}

impl std::fmt::Display for OrderStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for OrderStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Pending" => Ok(OrderStatus::Pending),
            "Paid" => Ok(OrderStatus::Paid),
            "Processing" => Ok(OrderStatus::Processing),
            "Shipped" => Ok(OrderStatus::Shipped),
            "Completed" => Ok(OrderStatus::Completed),
            "Cancelled" => Ok(OrderStatus::Cancelled),
            "Refunded" => Ok(OrderStatus::Refunded),
            _ => Err(format!("unknown OrderStatus: {}", s)),
        }
    }
}

impl From<String> for OrderStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid OrderStatus: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum OrderPaymentMethod {
    Card,
    PayPal,
    Crypto,
    PlatformCredits,
}

impl OrderPaymentMethod {
    pub fn as_str(&self) -> &'static str {
        match self {
            OrderPaymentMethod::Card => "Card",
            OrderPaymentMethod::PayPal => "PayPal",
            OrderPaymentMethod::Crypto => "Crypto",
            OrderPaymentMethod::PlatformCredits => "PlatformCredits",
        }
    }
}

impl std::fmt::Display for OrderPaymentMethod {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for OrderPaymentMethod {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Card" => Ok(OrderPaymentMethod::Card),
            "PayPal" => Ok(OrderPaymentMethod::PayPal),
            "Crypto" => Ok(OrderPaymentMethod::Crypto),
            "PlatformCredits" => Ok(OrderPaymentMethod::PlatformCredits),
            _ => Err(format!("unknown OrderPaymentMethod: {}", s)),
        }
    }
}

impl From<String> for OrderPaymentMethod {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid OrderPaymentMethod: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Order {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub status: OrderStatus,
    pub total: f64,
    pub discount_applied: f64,
    pub currency: String,
    pub payment_method: Option<OrderPaymentMethod>,
    pub payment_reference: Option<String>,
    pub shipping_address: Option<String>,
    pub tracking_number: Option<String>,
    #[serde(rename = "paidAt")]
    pub paid_at: Option<String>,
    #[serde(rename = "shippedAt")]
    pub shipped_at: Option<String>,
    pub player_id: i64,
    pub coupon_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct OrderCreateRequest {
    pub status: OrderStatus,
    pub total: f64,
    pub discount_applied: f64,
    pub currency: String,
    pub payment_method: Option<OrderPaymentMethod>,
    pub payment_reference: Option<String>,
    pub shipping_address: Option<String>,
    pub tracking_number: Option<String>,
    pub paid_at: Option<String>,
    pub shipped_at: Option<String>,
    pub player_id: i64,
    pub coupon_id: Option<i64>,
}

impl Order {
    pub fn assert_transition(&self, to: &str) -> Result<(), String> {
        let allowed: &[(&str, &str)] = &[
            ("Pending", "Paid"),
            ("Paid", "Processing"),
            ("Processing", "Shipped"),
            ("Shipped", "Completed"),
            ("Pending", "Cancelled"),
            ("Paid", "Cancelled"),
            ("Completed", "Refunded"),
        ];
        let current = &self.status;
        if allowed.iter().any(|(from, t)| *from == current.as_str() && *t == to) {
            Ok(())
        } else {
            Err(format!("transition {} -> {} not allowed", current, to))
        }
    }
}
