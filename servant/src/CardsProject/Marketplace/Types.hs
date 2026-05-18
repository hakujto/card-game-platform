{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.Types where

import Data.Aeson (ToJSON(..), FromJSON(..), toJSON, parseJSON, withText, genericToJSON, genericParseJSON, defaultOptions, Options(..))
import Data.Aeson.Casing (camelCase)
import Data.Text (Text)
import Database.SQLite.Simple (FromRow(..), ToRow(..), field)
import Database.SQLite.Simple.ToField (ToField(..))
import Database.SQLite.Simple.FromField (FromField(..), returnError, ResultError(ConversionFailed))
import Database.SQLite.Simple.Ok (Ok(..))
import GHC.Generics (Generic)

_toCamel :: String -> String
_toCamel = camelCase

data ProductProductTypeType
  = ProductProductTypeType_SingleCard
  | ProductProductTypeType_BoosterPack
  | ProductProductTypeType_Bundle
  | ProductProductTypeType_PreconstructedDeck
  | ProductProductTypeType_Accessory
  deriving (Show, Eq, Generic)

instance ToJSON ProductProductTypeType where
  toJSON v = case v of
    ProductProductTypeType_SingleCard -> toJSON ("SingleCard" :: Text)
    ProductProductTypeType_BoosterPack -> toJSON ("BoosterPack" :: Text)
    ProductProductTypeType_Bundle -> toJSON ("Bundle" :: Text)
    ProductProductTypeType_PreconstructedDeck -> toJSON ("PreconstructedDeck" :: Text)
    ProductProductTypeType_Accessory -> toJSON ("Accessory" :: Text)
instance FromJSON ProductProductTypeType where
  parseJSON = withText "ProductProductTypeType" $ \txt ->
    if txt == "SingleCard" then pure ProductProductTypeType_SingleCard
    else if txt == "BoosterPack" then pure ProductProductTypeType_BoosterPack
    else if txt == "Bundle" then pure ProductProductTypeType_Bundle
    else if txt == "PreconstructedDeck" then pure ProductProductTypeType_PreconstructedDeck
    else if txt == "Accessory" then pure ProductProductTypeType_Accessory
    else fail ("Unknown ProductProductTypeType: " ++ show txt)

instance ToField ProductProductTypeType where
  toField ProductProductTypeType_SingleCard = toField ("SingleCard" :: Text)
  toField ProductProductTypeType_BoosterPack = toField ("BoosterPack" :: Text)
  toField ProductProductTypeType_Bundle = toField ("Bundle" :: Text)
  toField ProductProductTypeType_PreconstructedDeck = toField ("PreconstructedDeck" :: Text)
  toField ProductProductTypeType_Accessory = toField ("Accessory" :: Text)

instance FromField ProductProductTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "SingleCard" then return ProductProductTypeType_SingleCard
    else if txt == "BoosterPack" then return ProductProductTypeType_BoosterPack
    else if txt == "Bundle" then return ProductProductTypeType_Bundle
    else if txt == "PreconstructedDeck" then return ProductProductTypeType_PreconstructedDeck
    else if txt == "Accessory" then return ProductProductTypeType_Accessory
    else returnError ConversionFailed f ("Unknown ProductProductTypeType: " ++ show txt)

_productOpts :: Options
_productOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 7 }

data Product = Product
  { productId :: Int
  , productName :: Text
  , productProductType :: ProductProductTypeType
  , productPrice :: Text
  , productStock :: Int
  , productActive :: Bool
  , productDiscountPercent :: Int
  , productDescription :: Maybe Text
  , productImageUrl :: Maybe Text
  , productFeatured :: Bool
  , productCardId :: Maybe Int
  , productCardSetId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Product where
  toJSON = genericToJSON _productOpts
instance FromJSON Product where
  parseJSON = genericParseJSON _productOpts

instance FromRow Product where
  fromRow = Product <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newProductOpts :: Options
_newProductOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 8 }

data NewProduct = NewProduct
  { bProductName :: Text
  , bProductProductType :: ProductProductTypeType
  , bProductPrice :: Text
  , bProductStock :: Int
  , bProductActive :: Bool
  , bProductDiscountPercent :: Int
  , bProductDescription :: Maybe Text
  , bProductImageUrl :: Maybe Text
  , bProductFeatured :: Bool
  , bProductCardId :: Maybe Int
  , bProductCardSetId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewProduct where
  toJSON = genericToJSON _newProductOpts
instance FromJSON NewProduct where
  parseJSON = genericParseJSON _newProductOpts

instance ToRow NewProduct where
  toRow b = [toField (bProductName b), toField (bProductProductType b), toField (bProductPrice b), toField (bProductStock b), toField (bProductActive b), toField (bProductDiscountPercent b), toField (bProductDescription b), toField (bProductImageUrl b), toField (bProductFeatured b), toField (bProductCardId b), toField (bProductCardSetId b)]

data OrderStatusType
  = OrderStatusType_Pending
  | OrderStatusType_Paid
  | OrderStatusType_Processing
  | OrderStatusType_Shipped
  | OrderStatusType_Completed
  | OrderStatusType_Cancelled
  | OrderStatusType_Refunded
  deriving (Show, Eq, Generic)

instance ToJSON OrderStatusType where
  toJSON v = case v of
    OrderStatusType_Pending -> toJSON ("Pending" :: Text)
    OrderStatusType_Paid -> toJSON ("Paid" :: Text)
    OrderStatusType_Processing -> toJSON ("Processing" :: Text)
    OrderStatusType_Shipped -> toJSON ("Shipped" :: Text)
    OrderStatusType_Completed -> toJSON ("Completed" :: Text)
    OrderStatusType_Cancelled -> toJSON ("Cancelled" :: Text)
    OrderStatusType_Refunded -> toJSON ("Refunded" :: Text)
instance FromJSON OrderStatusType where
  parseJSON = withText "OrderStatusType" $ \txt ->
    if txt == "Pending" then pure OrderStatusType_Pending
    else if txt == "Paid" then pure OrderStatusType_Paid
    else if txt == "Processing" then pure OrderStatusType_Processing
    else if txt == "Shipped" then pure OrderStatusType_Shipped
    else if txt == "Completed" then pure OrderStatusType_Completed
    else if txt == "Cancelled" then pure OrderStatusType_Cancelled
    else if txt == "Refunded" then pure OrderStatusType_Refunded
    else fail ("Unknown OrderStatusType: " ++ show txt)

instance ToField OrderStatusType where
  toField OrderStatusType_Pending = toField ("Pending" :: Text)
  toField OrderStatusType_Paid = toField ("Paid" :: Text)
  toField OrderStatusType_Processing = toField ("Processing" :: Text)
  toField OrderStatusType_Shipped = toField ("Shipped" :: Text)
  toField OrderStatusType_Completed = toField ("Completed" :: Text)
  toField OrderStatusType_Cancelled = toField ("Cancelled" :: Text)
  toField OrderStatusType_Refunded = toField ("Refunded" :: Text)

instance FromField OrderStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Pending" then return OrderStatusType_Pending
    else if txt == "Paid" then return OrderStatusType_Paid
    else if txt == "Processing" then return OrderStatusType_Processing
    else if txt == "Shipped" then return OrderStatusType_Shipped
    else if txt == "Completed" then return OrderStatusType_Completed
    else if txt == "Cancelled" then return OrderStatusType_Cancelled
    else if txt == "Refunded" then return OrderStatusType_Refunded
    else returnError ConversionFailed f ("Unknown OrderStatusType: " ++ show txt)

data OrderPaymentMethodType
  = OrderPaymentMethodType_Card
  | OrderPaymentMethodType_PayPal
  | OrderPaymentMethodType_Crypto
  | OrderPaymentMethodType_PlatformCredits
  deriving (Show, Eq, Generic)

instance ToJSON OrderPaymentMethodType where
  toJSON v = case v of
    OrderPaymentMethodType_Card -> toJSON ("Card" :: Text)
    OrderPaymentMethodType_PayPal -> toJSON ("PayPal" :: Text)
    OrderPaymentMethodType_Crypto -> toJSON ("Crypto" :: Text)
    OrderPaymentMethodType_PlatformCredits -> toJSON ("PlatformCredits" :: Text)
instance FromJSON OrderPaymentMethodType where
  parseJSON = withText "OrderPaymentMethodType" $ \txt ->
    if txt == "Card" then pure OrderPaymentMethodType_Card
    else if txt == "PayPal" then pure OrderPaymentMethodType_PayPal
    else if txt == "Crypto" then pure OrderPaymentMethodType_Crypto
    else if txt == "PlatformCredits" then pure OrderPaymentMethodType_PlatformCredits
    else fail ("Unknown OrderPaymentMethodType: " ++ show txt)

instance ToField OrderPaymentMethodType where
  toField OrderPaymentMethodType_Card = toField ("Card" :: Text)
  toField OrderPaymentMethodType_PayPal = toField ("PayPal" :: Text)
  toField OrderPaymentMethodType_Crypto = toField ("Crypto" :: Text)
  toField OrderPaymentMethodType_PlatformCredits = toField ("PlatformCredits" :: Text)

instance FromField OrderPaymentMethodType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Card" then return OrderPaymentMethodType_Card
    else if txt == "PayPal" then return OrderPaymentMethodType_PayPal
    else if txt == "Crypto" then return OrderPaymentMethodType_Crypto
    else if txt == "PlatformCredits" then return OrderPaymentMethodType_PlatformCredits
    else returnError ConversionFailed f ("Unknown OrderPaymentMethodType: " ++ show txt)

_orderOpts :: Options
_orderOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 5 }

data Order = Order
  { orderId :: Int
  , orderStatus :: OrderStatusType
  , orderTotal :: Text
  , orderDiscountApplied :: Text
  , orderCurrency :: Text
  , orderPaymentMethod :: Maybe OrderPaymentMethodType
  , orderPaymentReference :: Maybe Text
  , orderShippingAddress :: Maybe Text
  , orderTrackingNumber :: Maybe Text
  , orderCreatedAt :: Text
  , orderPaidAt :: Maybe Text
  , orderShippedAt :: Maybe Text
  , orderPlayerId :: Maybe Int
  , orderItemsId :: Maybe Int
  , orderCouponId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Order where
  toJSON = genericToJSON _orderOpts
instance FromJSON Order where
  parseJSON = genericParseJSON _orderOpts

instance FromRow Order where
  fromRow = Order <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newOrderOpts :: Options
_newOrderOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 6 }

data NewOrder = NewOrder
  { bOrderStatus :: OrderStatusType
  , bOrderTotal :: Text
  , bOrderDiscountApplied :: Text
  , bOrderCurrency :: Text
  , bOrderPaymentMethod :: Maybe OrderPaymentMethodType
  , bOrderPaymentReference :: Maybe Text
  , bOrderShippingAddress :: Maybe Text
  , bOrderTrackingNumber :: Maybe Text
  , bOrderCreatedAt :: Text
  , bOrderPaidAt :: Maybe Text
  , bOrderShippedAt :: Maybe Text
  , bOrderPlayerId :: Maybe Int
  , bOrderItemsId :: Maybe Int
  , bOrderCouponId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewOrder where
  toJSON = genericToJSON _newOrderOpts
instance FromJSON NewOrder where
  parseJSON = genericParseJSON _newOrderOpts

instance ToRow NewOrder where
  toRow b = [toField (bOrderStatus b), toField (bOrderTotal b), toField (bOrderDiscountApplied b), toField (bOrderCurrency b), toField (bOrderPaymentMethod b), toField (bOrderPaymentReference b), toField (bOrderShippingAddress b), toField (bOrderTrackingNumber b), toField (bOrderCreatedAt b), toField (bOrderPaidAt b), toField (bOrderShippedAt b), toField (bOrderPlayerId b), toField (bOrderItemsId b), toField (bOrderCouponId b)]

_orderItemOpts :: Options
_orderItemOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 9 }

data OrderItem = OrderItem
  { orderItemId :: Int
  , orderItemQuantity :: Int
  , orderItemPriceAtPurchase :: Text
  , orderItemFoil :: Bool
  , orderItemOrderId :: Maybe Int
  , orderItemProductId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON OrderItem where
  toJSON = genericToJSON _orderItemOpts
instance FromJSON OrderItem where
  parseJSON = genericParseJSON _orderItemOpts

instance FromRow OrderItem where
  fromRow = OrderItem <$> field <*> field <*> field <*> field <*> field <*> field

_newOrderItemOpts :: Options
_newOrderItemOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 10 }

data NewOrderItem = NewOrderItem
  { bOrderItemQuantity :: Int
  , bOrderItemPriceAtPurchase :: Text
  , bOrderItemFoil :: Bool
  , bOrderItemOrderId :: Maybe Int
  , bOrderItemProductId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewOrderItem where
  toJSON = genericToJSON _newOrderItemOpts
instance FromJSON NewOrderItem where
  parseJSON = genericParseJSON _newOrderItemOpts

instance ToRow NewOrderItem where
  toRow b = [toField (bOrderItemQuantity b), toField (bOrderItemPriceAtPurchase b), toField (bOrderItemFoil b), toField (bOrderItemOrderId b), toField (bOrderItemProductId b)]

data CouponDiscountTypeType
  = CouponDiscountTypeType_Percent
  | CouponDiscountTypeType_Fixed
  deriving (Show, Eq, Generic)

instance ToJSON CouponDiscountTypeType where
  toJSON v = case v of
    CouponDiscountTypeType_Percent -> toJSON ("Percent" :: Text)
    CouponDiscountTypeType_Fixed -> toJSON ("Fixed" :: Text)
instance FromJSON CouponDiscountTypeType where
  parseJSON = withText "CouponDiscountTypeType" $ \txt ->
    if txt == "Percent" then pure CouponDiscountTypeType_Percent
    else if txt == "Fixed" then pure CouponDiscountTypeType_Fixed
    else fail ("Unknown CouponDiscountTypeType: " ++ show txt)

instance ToField CouponDiscountTypeType where
  toField CouponDiscountTypeType_Percent = toField ("Percent" :: Text)
  toField CouponDiscountTypeType_Fixed = toField ("Fixed" :: Text)

instance FromField CouponDiscountTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Percent" then return CouponDiscountTypeType_Percent
    else if txt == "Fixed" then return CouponDiscountTypeType_Fixed
    else returnError ConversionFailed f ("Unknown CouponDiscountTypeType: " ++ show txt)

_couponOpts :: Options
_couponOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 6 }

data Coupon = Coupon
  { couponId :: Int
  , couponCode :: Text
  , couponDiscountType :: CouponDiscountTypeType
  , couponDiscountValue :: Text
  , couponMinOrderValue :: Text
  , couponMaxUses :: Maybe Int
  , couponUsesCount :: Int
  , couponValidFrom :: Text
  , couponValidUntil :: Text
  , couponIsActive :: Bool
  } deriving (Show, Generic)

instance ToJSON Coupon where
  toJSON = genericToJSON _couponOpts
instance FromJSON Coupon where
  parseJSON = genericParseJSON _couponOpts

instance FromRow Coupon where
  fromRow = Coupon <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newCouponOpts :: Options
_newCouponOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 7 }

data NewCoupon = NewCoupon
  { bCouponCode :: Text
  , bCouponDiscountType :: CouponDiscountTypeType
  , bCouponDiscountValue :: Text
  , bCouponMinOrderValue :: Text
  , bCouponMaxUses :: Maybe Int
  , bCouponUsesCount :: Int
  , bCouponValidFrom :: Text
  , bCouponValidUntil :: Text
  , bCouponIsActive :: Bool
  } deriving (Show, Generic)

instance ToJSON NewCoupon where
  toJSON = genericToJSON _newCouponOpts
instance FromJSON NewCoupon where
  parseJSON = genericParseJSON _newCouponOpts

instance ToRow NewCoupon where
  toRow b = [toField (bCouponCode b), toField (bCouponDiscountType b), toField (bCouponDiscountValue b), toField (bCouponMinOrderValue b), toField (bCouponMaxUses b), toField (bCouponUsesCount b), toField (bCouponValidFrom b), toField (bCouponValidUntil b), toField (bCouponIsActive b)]

data TradelistingListingTypeType
  = TradelistingListingTypeType_FixedPrice
  | TradelistingListingTypeType_Auction
  | TradelistingListingTypeType_TradeOffer
  deriving (Show, Eq, Generic)

instance ToJSON TradelistingListingTypeType where
  toJSON v = case v of
    TradelistingListingTypeType_FixedPrice -> toJSON ("FixedPrice" :: Text)
    TradelistingListingTypeType_Auction -> toJSON ("Auction" :: Text)
    TradelistingListingTypeType_TradeOffer -> toJSON ("TradeOffer" :: Text)
instance FromJSON TradelistingListingTypeType where
  parseJSON = withText "TradelistingListingTypeType" $ \txt ->
    if txt == "FixedPrice" then pure TradelistingListingTypeType_FixedPrice
    else if txt == "Auction" then pure TradelistingListingTypeType_Auction
    else if txt == "TradeOffer" then pure TradelistingListingTypeType_TradeOffer
    else fail ("Unknown TradelistingListingTypeType: " ++ show txt)

instance ToField TradelistingListingTypeType where
  toField TradelistingListingTypeType_FixedPrice = toField ("FixedPrice" :: Text)
  toField TradelistingListingTypeType_Auction = toField ("Auction" :: Text)
  toField TradelistingListingTypeType_TradeOffer = toField ("TradeOffer" :: Text)

instance FromField TradelistingListingTypeType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "FixedPrice" then return TradelistingListingTypeType_FixedPrice
    else if txt == "Auction" then return TradelistingListingTypeType_Auction
    else if txt == "TradeOffer" then return TradelistingListingTypeType_TradeOffer
    else returnError ConversionFailed f ("Unknown TradelistingListingTypeType: " ++ show txt)

data TradelistingConditionType
  = TradelistingConditionType_Mint
  | TradelistingConditionType_NearMint
  | TradelistingConditionType_Excellent
  | TradelistingConditionType_Good
  | TradelistingConditionType_Played
  deriving (Show, Eq, Generic)

instance ToJSON TradelistingConditionType where
  toJSON v = case v of
    TradelistingConditionType_Mint -> toJSON ("Mint" :: Text)
    TradelistingConditionType_NearMint -> toJSON ("NearMint" :: Text)
    TradelistingConditionType_Excellent -> toJSON ("Excellent" :: Text)
    TradelistingConditionType_Good -> toJSON ("Good" :: Text)
    TradelistingConditionType_Played -> toJSON ("Played" :: Text)
instance FromJSON TradelistingConditionType where
  parseJSON = withText "TradelistingConditionType" $ \txt ->
    if txt == "Mint" then pure TradelistingConditionType_Mint
    else if txt == "NearMint" then pure TradelistingConditionType_NearMint
    else if txt == "Excellent" then pure TradelistingConditionType_Excellent
    else if txt == "Good" then pure TradelistingConditionType_Good
    else if txt == "Played" then pure TradelistingConditionType_Played
    else fail ("Unknown TradelistingConditionType: " ++ show txt)

instance ToField TradelistingConditionType where
  toField TradelistingConditionType_Mint = toField ("Mint" :: Text)
  toField TradelistingConditionType_NearMint = toField ("NearMint" :: Text)
  toField TradelistingConditionType_Excellent = toField ("Excellent" :: Text)
  toField TradelistingConditionType_Good = toField ("Good" :: Text)
  toField TradelistingConditionType_Played = toField ("Played" :: Text)

instance FromField TradelistingConditionType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Mint" then return TradelistingConditionType_Mint
    else if txt == "NearMint" then return TradelistingConditionType_NearMint
    else if txt == "Excellent" then return TradelistingConditionType_Excellent
    else if txt == "Good" then return TradelistingConditionType_Good
    else if txt == "Played" then return TradelistingConditionType_Played
    else returnError ConversionFailed f ("Unknown TradelistingConditionType: " ++ show txt)

data TradelistingStatusType
  = TradelistingStatusType_Active
  | TradelistingStatusType_Sold
  | TradelistingStatusType_Expired
  | TradelistingStatusType_Cancelled
  | TradelistingStatusType_Pending
  deriving (Show, Eq, Generic)

instance ToJSON TradelistingStatusType where
  toJSON v = case v of
    TradelistingStatusType_Active -> toJSON ("Active" :: Text)
    TradelistingStatusType_Sold -> toJSON ("Sold" :: Text)
    TradelistingStatusType_Expired -> toJSON ("Expired" :: Text)
    TradelistingStatusType_Cancelled -> toJSON ("Cancelled" :: Text)
    TradelistingStatusType_Pending -> toJSON ("Pending" :: Text)
instance FromJSON TradelistingStatusType where
  parseJSON = withText "TradelistingStatusType" $ \txt ->
    if txt == "Active" then pure TradelistingStatusType_Active
    else if txt == "Sold" then pure TradelistingStatusType_Sold
    else if txt == "Expired" then pure TradelistingStatusType_Expired
    else if txt == "Cancelled" then pure TradelistingStatusType_Cancelled
    else if txt == "Pending" then pure TradelistingStatusType_Pending
    else fail ("Unknown TradelistingStatusType: " ++ show txt)

instance ToField TradelistingStatusType where
  toField TradelistingStatusType_Active = toField ("Active" :: Text)
  toField TradelistingStatusType_Sold = toField ("Sold" :: Text)
  toField TradelistingStatusType_Expired = toField ("Expired" :: Text)
  toField TradelistingStatusType_Cancelled = toField ("Cancelled" :: Text)
  toField TradelistingStatusType_Pending = toField ("Pending" :: Text)

instance FromField TradelistingStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Active" then return TradelistingStatusType_Active
    else if txt == "Sold" then return TradelistingStatusType_Sold
    else if txt == "Expired" then return TradelistingStatusType_Expired
    else if txt == "Cancelled" then return TradelistingStatusType_Cancelled
    else if txt == "Pending" then return TradelistingStatusType_Pending
    else returnError ConversionFailed f ("Unknown TradelistingStatusType: " ++ show txt)

_tradelistingOpts :: Options
_tradelistingOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 12 }

data Tradelisting = Tradelisting
  { tradelistingId :: Int
  , tradelistingListingType :: TradelistingListingTypeType
  , tradelistingAskingPrice :: Maybe Text
  , tradelistingAuctionStartPrice :: Maybe Text
  , tradelistingAuctionCurrentBid :: Maybe Text
  , tradelistingAuctionEndTime :: Maybe Text
  , tradelistingFoil :: Bool
  , tradelistingCondition :: TradelistingConditionType
  , tradelistingQuantity :: Int
  , tradelistingStatus :: TradelistingStatusType
  , tradelistingDescription :: Maybe Text
  , tradelistingCreatedAt :: Text
  , tradelistingExpiresAt :: Maybe Text
  , tradelistingSellerId :: Maybe Int
  , tradelistingCardId :: Maybe Int
  , tradelistingBidsId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON Tradelisting where
  toJSON = genericToJSON _tradelistingOpts
instance FromJSON Tradelisting where
  parseJSON = genericParseJSON _tradelistingOpts

instance FromRow Tradelisting where
  fromRow = Tradelisting <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newTradelistingOpts :: Options
_newTradelistingOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 13 }

data NewTradelisting = NewTradelisting
  { bTradelistingListingType :: TradelistingListingTypeType
  , bTradelistingAskingPrice :: Maybe Text
  , bTradelistingAuctionStartPrice :: Maybe Text
  , bTradelistingAuctionCurrentBid :: Maybe Text
  , bTradelistingAuctionEndTime :: Maybe Text
  , bTradelistingFoil :: Bool
  , bTradelistingCondition :: TradelistingConditionType
  , bTradelistingQuantity :: Int
  , bTradelistingStatus :: TradelistingStatusType
  , bTradelistingDescription :: Maybe Text
  , bTradelistingCreatedAt :: Text
  , bTradelistingExpiresAt :: Maybe Text
  , bTradelistingSellerId :: Maybe Int
  , bTradelistingCardId :: Maybe Int
  , bTradelistingBidsId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewTradelisting where
  toJSON = genericToJSON _newTradelistingOpts
instance FromJSON NewTradelisting where
  parseJSON = genericParseJSON _newTradelistingOpts

instance ToRow NewTradelisting where
  toRow b = [toField (bTradelistingListingType b), toField (bTradelistingAskingPrice b), toField (bTradelistingAuctionStartPrice b), toField (bTradelistingAuctionCurrentBid b), toField (bTradelistingAuctionEndTime b), toField (bTradelistingFoil b), toField (bTradelistingCondition b), toField (bTradelistingQuantity b), toField (bTradelistingStatus b), toField (bTradelistingDescription b), toField (bTradelistingCreatedAt b), toField (bTradelistingExpiresAt b), toField (bTradelistingSellerId b), toField (bTradelistingCardId b), toField (bTradelistingBidsId b)]

_tradeBidOpts :: Options
_tradeBidOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 8 }

data TradeBid = TradeBid
  { tradeBidId :: Int
  , tradeBidAmount :: Text
  , tradeBidPlacedAt :: Text
  , tradeBidIsWinning :: Bool
  , tradeBidListingId :: Maybe Int
  , tradeBidBidderId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON TradeBid where
  toJSON = genericToJSON _tradeBidOpts
instance FromJSON TradeBid where
  parseJSON = genericParseJSON _tradeBidOpts

instance FromRow TradeBid where
  fromRow = TradeBid <$> field <*> field <*> field <*> field <*> field <*> field

_newTradeBidOpts :: Options
_newTradeBidOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 9 }

data NewTradeBid = NewTradeBid
  { bTradeBidAmount :: Text
  , bTradeBidPlacedAt :: Text
  , bTradeBidIsWinning :: Bool
  , bTradeBidListingId :: Maybe Int
  , bTradeBidBidderId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewTradeBid where
  toJSON = genericToJSON _newTradeBidOpts
instance FromJSON NewTradeBid where
  parseJSON = genericParseJSON _newTradeBidOpts

instance ToRow NewTradeBid where
  toRow b = [toField (bTradeBidAmount b), toField (bTradeBidPlacedAt b), toField (bTradeBidIsWinning b), toField (bTradeBidListingId b), toField (bTradeBidBidderId b)]

data TradeTransactionStatusType
  = TradeTransactionStatusType_Pending
  | TradeTransactionStatusType_Completed
  | TradeTransactionStatusType_Disputed
  | TradeTransactionStatusType_Refunded
  deriving (Show, Eq, Generic)

instance ToJSON TradeTransactionStatusType where
  toJSON v = case v of
    TradeTransactionStatusType_Pending -> toJSON ("Pending" :: Text)
    TradeTransactionStatusType_Completed -> toJSON ("Completed" :: Text)
    TradeTransactionStatusType_Disputed -> toJSON ("Disputed" :: Text)
    TradeTransactionStatusType_Refunded -> toJSON ("Refunded" :: Text)
instance FromJSON TradeTransactionStatusType where
  parseJSON = withText "TradeTransactionStatusType" $ \txt ->
    if txt == "Pending" then pure TradeTransactionStatusType_Pending
    else if txt == "Completed" then pure TradeTransactionStatusType_Completed
    else if txt == "Disputed" then pure TradeTransactionStatusType_Disputed
    else if txt == "Refunded" then pure TradeTransactionStatusType_Refunded
    else fail ("Unknown TradeTransactionStatusType: " ++ show txt)

instance ToField TradeTransactionStatusType where
  toField TradeTransactionStatusType_Pending = toField ("Pending" :: Text)
  toField TradeTransactionStatusType_Completed = toField ("Completed" :: Text)
  toField TradeTransactionStatusType_Disputed = toField ("Disputed" :: Text)
  toField TradeTransactionStatusType_Refunded = toField ("Refunded" :: Text)

instance FromField TradeTransactionStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Pending" then return TradeTransactionStatusType_Pending
    else if txt == "Completed" then return TradeTransactionStatusType_Completed
    else if txt == "Disputed" then return TradeTransactionStatusType_Disputed
    else if txt == "Refunded" then return TradeTransactionStatusType_Refunded
    else returnError ConversionFailed f ("Unknown TradeTransactionStatusType: " ++ show txt)

_tradeTransactionOpts :: Options
_tradeTransactionOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 16 }

data TradeTransaction = TradeTransaction
  { tradeTransactionId :: Int
  , tradeTransactionFinalPrice :: Text
  , tradeTransactionPlatformFee :: Text
  , tradeTransactionStatus :: TradeTransactionStatusType
  , tradeTransactionCompletedAt :: Maybe Text
  , tradeTransactionListingId :: Maybe Int
  , tradeTransactionBuyerId :: Maybe Int
  , tradeTransactionSellerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON TradeTransaction where
  toJSON = genericToJSON _tradeTransactionOpts
instance FromJSON TradeTransaction where
  parseJSON = genericParseJSON _tradeTransactionOpts

instance FromRow TradeTransaction where
  fromRow = TradeTransaction <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newTradeTransactionOpts :: Options
_newTradeTransactionOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 17 }

data NewTradeTransaction = NewTradeTransaction
  { bTradeTransactionFinalPrice :: Text
  , bTradeTransactionPlatformFee :: Text
  , bTradeTransactionStatus :: TradeTransactionStatusType
  , bTradeTransactionCompletedAt :: Maybe Text
  , bTradeTransactionListingId :: Maybe Int
  , bTradeTransactionBuyerId :: Maybe Int
  , bTradeTransactionSellerId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewTradeTransaction where
  toJSON = genericToJSON _newTradeTransactionOpts
instance FromJSON NewTradeTransaction where
  parseJSON = genericParseJSON _newTradeTransactionOpts

instance ToRow NewTradeTransaction where
  toRow b = [toField (bTradeTransactionFinalPrice b), toField (bTradeTransactionPlatformFee b), toField (bTradeTransactionStatus b), toField (bTradeTransactionCompletedAt b), toField (bTradeTransactionListingId b), toField (bTradeTransactionBuyerId b), toField (bTradeTransactionSellerId b)]

_cardPriceHistoryOpts :: Options
_cardPriceHistoryOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 16 }

data CardPriceHistory = CardPriceHistory
  { cardPriceHistoryId :: Int
  , cardPriceHistoryPriceDate :: Text
  , cardPriceHistoryAvgPrice :: Text
  , cardPriceHistoryMinPrice :: Text
  , cardPriceHistoryMaxPrice :: Text
  , cardPriceHistoryVolume :: Int
  , cardPriceHistoryFoil :: Bool
  , cardPriceHistoryCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON CardPriceHistory where
  toJSON = genericToJSON _cardPriceHistoryOpts
instance FromJSON CardPriceHistory where
  parseJSON = genericParseJSON _cardPriceHistoryOpts

instance FromRow CardPriceHistory where
  fromRow = CardPriceHistory <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newCardPriceHistoryOpts :: Options
_newCardPriceHistoryOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 17 }

data NewCardPriceHistory = NewCardPriceHistory
  { bCardPriceHistoryPriceDate :: Text
  , bCardPriceHistoryAvgPrice :: Text
  , bCardPriceHistoryMinPrice :: Text
  , bCardPriceHistoryMaxPrice :: Text
  , bCardPriceHistoryVolume :: Int
  , bCardPriceHistoryFoil :: Bool
  , bCardPriceHistoryCardId :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewCardPriceHistory where
  toJSON = genericToJSON _newCardPriceHistoryOpts
instance FromJSON NewCardPriceHistory where
  parseJSON = genericParseJSON _newCardPriceHistoryOpts

instance ToRow NewCardPriceHistory where
  toRow b = [toField (bCardPriceHistoryPriceDate b), toField (bCardPriceHistoryAvgPrice b), toField (bCardPriceHistoryMinPrice b), toField (bCardPriceHistoryMaxPrice b), toField (bCardPriceHistoryVolume b), toField (bCardPriceHistoryFoil b), toField (bCardPriceHistoryCardId b)]

data TradeDisputeReasonType
  = TradeDisputeReasonType_ItemNotReceived
  | TradeDisputeReasonType_ItemNotAsDescribed
  | TradeDisputeReasonType_FraudSuspected
  | TradeDisputeReasonType_Other
  deriving (Show, Eq, Generic)

instance ToJSON TradeDisputeReasonType where
  toJSON v = case v of
    TradeDisputeReasonType_ItemNotReceived -> toJSON ("ItemNotReceived" :: Text)
    TradeDisputeReasonType_ItemNotAsDescribed -> toJSON ("ItemNotAsDescribed" :: Text)
    TradeDisputeReasonType_FraudSuspected -> toJSON ("FraudSuspected" :: Text)
    TradeDisputeReasonType_Other -> toJSON ("Other" :: Text)
instance FromJSON TradeDisputeReasonType where
  parseJSON = withText "TradeDisputeReasonType" $ \txt ->
    if txt == "ItemNotReceived" then pure TradeDisputeReasonType_ItemNotReceived
    else if txt == "ItemNotAsDescribed" then pure TradeDisputeReasonType_ItemNotAsDescribed
    else if txt == "FraudSuspected" then pure TradeDisputeReasonType_FraudSuspected
    else if txt == "Other" then pure TradeDisputeReasonType_Other
    else fail ("Unknown TradeDisputeReasonType: " ++ show txt)

instance ToField TradeDisputeReasonType where
  toField TradeDisputeReasonType_ItemNotReceived = toField ("ItemNotReceived" :: Text)
  toField TradeDisputeReasonType_ItemNotAsDescribed = toField ("ItemNotAsDescribed" :: Text)
  toField TradeDisputeReasonType_FraudSuspected = toField ("FraudSuspected" :: Text)
  toField TradeDisputeReasonType_Other = toField ("Other" :: Text)

instance FromField TradeDisputeReasonType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "ItemNotReceived" then return TradeDisputeReasonType_ItemNotReceived
    else if txt == "ItemNotAsDescribed" then return TradeDisputeReasonType_ItemNotAsDescribed
    else if txt == "FraudSuspected" then return TradeDisputeReasonType_FraudSuspected
    else if txt == "Other" then return TradeDisputeReasonType_Other
    else returnError ConversionFailed f ("Unknown TradeDisputeReasonType: " ++ show txt)

data TradeDisputeStatusType
  = TradeDisputeStatusType_Open
  | TradeDisputeStatusType_UnderReview
  | TradeDisputeStatusType_Resolved
  | TradeDisputeStatusType_Escalated
  deriving (Show, Eq, Generic)

instance ToJSON TradeDisputeStatusType where
  toJSON v = case v of
    TradeDisputeStatusType_Open -> toJSON ("Open" :: Text)
    TradeDisputeStatusType_UnderReview -> toJSON ("UnderReview" :: Text)
    TradeDisputeStatusType_Resolved -> toJSON ("Resolved" :: Text)
    TradeDisputeStatusType_Escalated -> toJSON ("Escalated" :: Text)
instance FromJSON TradeDisputeStatusType where
  parseJSON = withText "TradeDisputeStatusType" $ \txt ->
    if txt == "Open" then pure TradeDisputeStatusType_Open
    else if txt == "UnderReview" then pure TradeDisputeStatusType_UnderReview
    else if txt == "Resolved" then pure TradeDisputeStatusType_Resolved
    else if txt == "Escalated" then pure TradeDisputeStatusType_Escalated
    else fail ("Unknown TradeDisputeStatusType: " ++ show txt)

instance ToField TradeDisputeStatusType where
  toField TradeDisputeStatusType_Open = toField ("Open" :: Text)
  toField TradeDisputeStatusType_UnderReview = toField ("UnderReview" :: Text)
  toField TradeDisputeStatusType_Resolved = toField ("Resolved" :: Text)
  toField TradeDisputeStatusType_Escalated = toField ("Escalated" :: Text)

instance FromField TradeDisputeStatusType where
  fromField f = do
    txt <- fromField f :: Ok Text
    if txt == "Open" then return TradeDisputeStatusType_Open
    else if txt == "UnderReview" then return TradeDisputeStatusType_UnderReview
    else if txt == "Resolved" then return TradeDisputeStatusType_Resolved
    else if txt == "Escalated" then return TradeDisputeStatusType_Escalated
    else returnError ConversionFailed f ("Unknown TradeDisputeStatusType: " ++ show txt)

_tradeDisputeOpts :: Options
_tradeDisputeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 12 }

data TradeDispute = TradeDispute
  { tradeDisputeId :: Int
  , tradeDisputeReason :: TradeDisputeReasonType
  , tradeDisputeDescription :: Text
  , tradeDisputeStatus :: TradeDisputeStatusType
  , tradeDisputeResolution :: Maybe Text
  , tradeDisputeOpenedAt :: Text
  , tradeDisputeResolvedAt :: Maybe Text
  , tradeDisputeTransactionId :: Maybe Int
  , tradeDisputeOpenedById :: Maybe Int
  , tradeDisputeResolvedById :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON TradeDispute where
  toJSON = genericToJSON _tradeDisputeOpts
instance FromJSON TradeDispute where
  parseJSON = genericParseJSON _tradeDisputeOpts

instance FromRow TradeDispute where
  fromRow = TradeDispute <$> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field <*> field

_newTradeDisputeOpts :: Options
_newTradeDisputeOpts = defaultOptions
  { fieldLabelModifier = _toCamel . drop 13 }

data NewTradeDispute = NewTradeDispute
  { bTradeDisputeReason :: TradeDisputeReasonType
  , bTradeDisputeDescription :: Text
  , bTradeDisputeStatus :: TradeDisputeStatusType
  , bTradeDisputeResolution :: Maybe Text
  , bTradeDisputeOpenedAt :: Text
  , bTradeDisputeResolvedAt :: Maybe Text
  , bTradeDisputeTransactionId :: Maybe Int
  , bTradeDisputeOpenedById :: Maybe Int
  , bTradeDisputeResolvedById :: Maybe Int
  } deriving (Show, Generic)

instance ToJSON NewTradeDispute where
  toJSON = genericToJSON _newTradeDisputeOpts
instance FromJSON NewTradeDispute where
  parseJSON = genericParseJSON _newTradeDisputeOpts

instance ToRow NewTradeDispute where
  toRow b = [toField (bTradeDisputeReason b), toField (bTradeDisputeDescription b), toField (bTradeDisputeStatus b), toField (bTradeDisputeResolution b), toField (bTradeDisputeOpenedAt b), toField (bTradeDisputeResolvedAt b), toField (bTradeDisputeTransactionId b), toField (bTradeDisputeOpenedById b), toField (bTradeDisputeResolvedById b)]

