{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Content.StreamService
  ( validateStream, go_live, end, update_viewer_peak, duration_minutes
  ) where

import CardsProject.Content.Types
import Control.Exception (throwIO)
import System.IO.Error (userError)
import Data.Text (Text)
import Database.SQLite.Simple
import CardsProject.Db (withDb)

-- Domain service stub for Stream
validateStream :: NewStream -> Either String NewStream
validateStream body = Right body

-- @invoke behavior stub
go_live :: Int -> IO ()
go_live eid = do
  throwIO (userError "go_live not implemented")

-- @invoke behavior stub
end :: Int -> IO ()
end eid = do
  throwIO (userError "end not implemented")

-- @invoke behavior stub
update_viewer_peak :: Int -> IO ()
update_viewer_peak eid = do
  -- params: count: Int -- extract from body in handler when implementing
  throwIO (userError "update_viewer_peak not implemented")

-- @invoke behavior stub
duration_minutes :: Int -> IO Int
duration_minutes eid = do
  throwIO (userError "duration_minutes not implemented")

