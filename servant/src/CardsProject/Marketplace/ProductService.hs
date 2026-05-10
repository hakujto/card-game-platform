{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Marketplace.ProductService where

import CardsProject.Marketplace.Types

-- Domain service stub for Product
validateProduct :: NewProduct -> Either String NewProduct
validateProduct body = Right body

