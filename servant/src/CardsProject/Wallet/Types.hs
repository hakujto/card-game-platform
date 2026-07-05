{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Wallet.Types where

import Data.Aeson (ToJSON(..), FromJSON(..), toJSON, parseJSON, withText, genericToJSON, genericParseJSON, defaultOptions, Options(..), object, (.=), Value(..), encode, decode)
import Data.Aeson.Casing (camelCase)
import Data.Text (Text)
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TLE
import qualified Data.ByteString.Lazy as BSL
import Database.SQLite.Simple (FromRow(..), ToRow(..), field)
import Database.SQLite.Simple.ToField (ToField(..))
import Database.SQLite.Simple.FromField (FromField(..), returnError, ResultError(ConversionFailed))
import Database.SQLite.Simple.Ok (Ok(..))
import GHC.Generics (Generic)

_toCamel :: String -> String
_toCamel = camelCase

