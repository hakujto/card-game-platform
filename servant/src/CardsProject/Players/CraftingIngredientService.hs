{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.CraftingIngredientService
  ( validateCraftingIngredient
  ) where

import CardsProject.Players.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)

-- Domain service stub for CraftingIngredient
validateCraftingIngredient :: NewCraftingIngredient -> Either String NewCraftingIngredient
validateCraftingIngredient body = Right body

