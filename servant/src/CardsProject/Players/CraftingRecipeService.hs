{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.CraftingRecipeService
  ( validateCraftingRecipe, can_craft, execute_craft, disable, enable
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for CraftingRecipe
validateCraftingRecipe :: NewCraftingRecipe -> Either String NewCraftingRecipe
validateCraftingRecipe body = Right body

-- @invoke behavior stub
can_craft :: Int -> IO Bool
can_craft eid = do
  -- params: player_id: Int -- extract from body in handler when implementing
  throwIO (userError "can_craft not implemented")

-- @invoke behavior stub
execute_craft :: Int -> IO ()
execute_craft eid = do
  -- params: player_id: Int -- extract from body in handler when implementing
  throwIO (userError "execute_craft not implemented")

-- @invoke behavior stub
disable :: Int -> IO ()
disable eid = do
  throwIO (userError "disable not implemented")

-- @invoke behavior stub
enable :: Int -> IO ()
enable eid = do
  throwIO (userError "enable not implemented")

