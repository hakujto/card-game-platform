{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Players.CraftingIngredientService where

import CardsProject.Players.Types

-- Domain service stub for CraftingIngredient
validateCraftingIngredient :: NewCraftingIngredient -> Either String NewCraftingIngredient
validateCraftingIngredient body = Right body

