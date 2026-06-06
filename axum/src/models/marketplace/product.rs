#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum ProductProductType {
    SingleCard,
    BoosterPack,
    Bundle,
    PreconstructedDeck,
    Accessory,
}

impl ProductProductType {
    pub fn as_str(&self) -> &'static str {
        match self {
            ProductProductType::SingleCard => "SingleCard",
            ProductProductType::BoosterPack => "BoosterPack",
            ProductProductType::Bundle => "Bundle",
            ProductProductType::PreconstructedDeck => "PreconstructedDeck",
            ProductProductType::Accessory => "Accessory",
        }
    }
}

impl std::fmt::Display for ProductProductType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for ProductProductType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "SingleCard" => Ok(ProductProductType::SingleCard),
            "BoosterPack" => Ok(ProductProductType::BoosterPack),
            "Bundle" => Ok(ProductProductType::Bundle),
            "PreconstructedDeck" => Ok(ProductProductType::PreconstructedDeck),
            "Accessory" => Ok(ProductProductType::Accessory),
            _ => Err(format!("unknown ProductProductType: {}", s)),
        }
    }
}

impl From<String> for ProductProductType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid ProductProductType: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Product {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub name: String,
    pub product_type: ProductProductType,
    pub price: f64,
    pub stock: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub active: i64,
    pub discount_percent: i64,
    pub description: Option<String>,
    pub image_url: Option<String>,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub featured: i64,
    pub card_id: Option<i64>,
    pub card_set_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct ProductCreateRequest {
    pub name: String,
    pub product_type: ProductProductType,
    pub price: f64,
    pub stock: i64,
    pub active: bool,
    pub discount_percent: i64,
    pub description: Option<String>,
    pub image_url: Option<String>,
    pub featured: bool,
    pub card_id: Option<i64>,
    pub card_set_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct ProductUpdateRequest {
    pub name: Option<String>,
    pub product_type: Option<ProductProductType>,
    pub price: Option<f64>,
    pub stock: Option<i64>,
    pub active: Option<bool>,
    pub discount_percent: Option<i64>,
    pub description: Option<String>,
    pub image_url: Option<String>,
    pub featured: Option<bool>,
    pub card_id: Option<i64>,
    pub card_set_id: Option<i64>,
}
