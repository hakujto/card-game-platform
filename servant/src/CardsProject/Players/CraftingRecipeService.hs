{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.CraftingRecipeService
  ( validateCraftingRecipe, disable, enable
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)

-- Domain service stub for CraftingRecipe
validateCraftingRecipe :: NewCraftingRecipe -> Either String NewCraftingRecipe
validateCraftingRecipe body = Right body

-- domain behavior stub
disable :: IO ()
disable  =
  throwIO (userError "disable not implemented")

-- domain behavior stub
enable :: IO ()
enable  =
  throwIO (userError "enable not implemented")

