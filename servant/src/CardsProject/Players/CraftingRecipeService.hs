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

-- Domain service stub for CraftingRecipe
validateCraftingRecipe :: NewCraftingRecipe -> Either String NewCraftingRecipe
validateCraftingRecipe body = Right body

-- @invoke behavior stub (no-op)
can_craft :: Int -> IO Bool
can_craft _eid = return (error "TODO")

-- @invoke behavior stub (no-op)
execute_craft :: Int -> IO ()
execute_craft _eid = return ()

-- @invoke behavior stub (no-op)
disable :: Int -> IO ()
disable _eid = return ()

-- @invoke behavior stub (no-op)
enable :: Int -> IO ()
enable _eid = return ()

