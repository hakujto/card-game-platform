{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.CraftingRecipeService
  ( validateCraftingRecipe, can_craft, execute_craft, disable, enable
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import Database.SQLite.Simple.FromField ()
import CardsProject.Db (withDb)

-- Domain service for CraftingRecipe
validateCraftingRecipe :: NewCraftingRecipe -> Either String NewCraftingRecipe
validateCraftingRecipe body
  | not (bCraftingRecipeDustCost body > 0) = Left "Crafting recipe must have a dust cost greater than zero"
  | otherwise = Right body

-- @invoke behavior stub (no-op)
can_craft :: Int -> IO Bool
can_craft _eid = throwIO (userError "can_craft not implemented")

-- @invoke behavior stub (no-op)
execute_craft :: Int -> IO ()
execute_craft _eid = throwIO (userError "execute_craft not implemented")

-- @invoke behavior stub (no-op)
disable :: Int -> IO ()
disable _eid = throwIO (userError "disable not implemented")

-- @invoke behavior stub (no-op)
enable :: Int -> IO ()
enable _eid = throwIO (userError "enable not implemented")

