module Main where

import Network.Wai.Handler.Warp (run)
import System.Environment (lookupEnv)
import CardsProject.App (app)

main :: IO ()
main = do
  portStr <- lookupEnv "PORT"
  let port = maybe 8080 read portStr
  putStrLn $ "Starting server on http://localhost:" ++ show port
  putStrLn $ "API: http://localhost:" ++ show port ++ "/api/"
  run port app
