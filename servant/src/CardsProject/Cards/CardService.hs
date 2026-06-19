{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Cards.CardService
  ( validateCard, ban, unban, restrict, unrestrict, calculate_value, apply_rarity_bonus, is_legal_in_format
  ) where

import CardsProject.Cards.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for Card
validateCard :: NewCard -> Either String NewCard
validateCard body
  | not ((bCardManaCost body >= 0 && bCardManaCost body <= 20)) = Left "mana_cost must be between 0 and 20"
  | not ((bCardPowerLevel body >= 1 && bCardPowerLevel body <= 10)) = Left "power_level must be between 1 and 10"
  | not (not ((bCardIsBanned body == True && bCardIsRestricted body == True))) = Left "Card cannot be both banned and restricted at the same time"
  | otherwise = validateCardImplies body

validateCardImplies :: NewCard -> Either String NewCard
validateCardImplies body
  | (bCardCardType body == CardCardTypeType_Creature) && not (bCardAttack body /= Nothing && bCardDefense body /= Nothing) = Left "Creature card must have attack and defense"
  | (bCardCardType body == CardCardTypeType_Planeswalker) && not (bCardLoyalty body /= Nothing) = Left "Planeswalker card must have loyalty"
  | (bCardCardType body == CardCardTypeType_Land) && not (bCardManaCost body == 0) = Left "Land card must have zero mana cost"
  | (bCardCardType body /= CardCardTypeType_Planeswalker) && not (bCardLoyalty body == Nothing) = Left "Only Planeswalker cards can have loyalty"
  | (bCardIsBanned body == True) && not (True) = Left "banned card not in legal formats"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
ban :: Int -> IO ()
ban _eid = throwIO (userError "ban not implemented")

-- @invoke behavior stub (no-op)
unban :: Int -> IO ()
unban _eid = throwIO (userError "unban not implemented")

-- @invoke behavior stub (no-op)
restrict :: Int -> IO ()
restrict _eid = throwIO (userError "restrict not implemented")

-- @invoke behavior stub (no-op)
unrestrict :: Int -> IO ()
unrestrict _eid = throwIO (userError "unrestrict not implemented")

-- @invoke behavior stub (no-op)
calculate_value :: Int -> IO Text
calculate_value _eid = throwIO (userError "calculate_value not implemented")

-- @invoke behavior stub (no-op)
apply_rarity_bonus :: Int -> IO Text
apply_rarity_bonus _eid = throwIO (userError "apply_rarity_bonus not implemented")

-- @invoke behavior stub (no-op)
is_legal_in_format :: Int -> IO Bool
is_legal_in_format _eid = throwIO (userError "is_legal_in_format not implemented")

-- ── Lifecycle hooks ─────────────────────────────────────────────────

-- TODO: implement validate_legality
validateLegalityHook :: a -> IO ()
validateLegalityHook _ = return ()

-- TODO: implement validate_not_in_use
validateNotInUseHook :: a -> IO ()
validateNotInUseHook _ = return ()

