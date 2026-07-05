{-# LANGUAGE DeriveGeneric #-}
module CardsProject.Marketplace.Events where

import Data.Aeson (ToJSON, FromJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data OrderPaid = OrderPaid
  { orderId :: Int
  , playerId :: Int
  , total :: Double
  , paymentMethod :: Text
  , paidAt :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON OrderPaid
instance FromJSON OrderPaid

data OrderShipped = OrderShipped
  { orderId :: Int
  , trackingNumber :: Text
  , shippedAt :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON OrderShipped
instance FromJSON OrderShipped

data OrderRefunded = OrderRefunded
  { orderId :: Int
  , refundedAt :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON OrderRefunded
instance FromJSON OrderRefunded

data TransactionCompleted = TransactionCompleted
  { transactionId :: Int
  , buyerId :: Int
  , sellerId :: Int
  , finalPrice :: Double
  , completedAt :: Text
  } deriving (Show, Eq, Generic)

instance ToJSON TransactionCompleted
instance FromJSON TransactionCompleted

