#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum CouponDiscountType {
    Percent,
    Fixed,
}

impl CouponDiscountType {
    pub fn as_str(&self) -> &'static str {
        match self {
            CouponDiscountType::Percent => "Percent",
            CouponDiscountType::Fixed => "Fixed",
        }
    }
}

impl std::fmt::Display for CouponDiscountType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for CouponDiscountType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Percent" => Ok(CouponDiscountType::Percent),
            "Fixed" => Ok(CouponDiscountType::Fixed),
            _ => Err(format!("unknown CouponDiscountType: {}", s)),
        }
    }
}

impl From<String> for CouponDiscountType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid CouponDiscountType: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Coupon {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub code: String,
    pub discount_type: CouponDiscountType,
    pub discount_value: f64,
    pub min_order_value: f64,
    #[serde(skip_serializing)]
    pub max_uses: Option<i64>,
    #[serde(skip_serializing)]
    pub uses_count: i64,
    pub valid_from: String,
    pub valid_until: String,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_active: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct CouponCreateRequest {
    pub code: String,
    pub discount_type: CouponDiscountType,
    pub discount_value: f64,
    pub min_order_value: f64,
    pub max_uses: Option<i64>,
    pub uses_count: i64,
    pub valid_from: String,
    pub valid_until: String,
    pub is_active: bool,
}

#[derive(Debug, serde::Deserialize)]
pub struct CouponUpdateRequest {
    pub code: Option<String>,
    pub discount_type: Option<CouponDiscountType>,
    pub discount_value: Option<f64>,
    pub min_order_value: Option<f64>,
    pub max_uses: Option<i64>,
    pub uses_count: Option<i64>,
    pub valid_from: Option<String>,
    pub valid_until: Option<String>,
    pub is_active: Option<bool>,
}
