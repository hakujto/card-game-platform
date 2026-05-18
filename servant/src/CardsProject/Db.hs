{-# LANGUAGE OverloadedStrings #-}
module CardsProject.Db (withDb, initDb) where

import Database.SQLite.Simple
import System.Environment (lookupEnv)
import Data.Maybe (fromMaybe)

dbPath :: IO FilePath
dbPath = fromMaybe "db/cards-project.db" <$> lookupEnv "DATABASE_PATH"

withDb :: (Connection -> IO a) -> IO a
withDb action = do
  path <- dbPath
  conn <- open path
  result <- action conn
  close conn
  return result

initDb :: IO ()
initDb = withDb $ \conn -> do
  putStrLn "Database initialized."
