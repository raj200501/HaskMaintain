module Main where

import System.Environment (getArgs)
import Analyzer (analyzeDirectory)

main :: IO ()
main = do
    args <- getArgs
    case args of
        [dir] -> analyzeDirectory dir
        _     -> putStrLn "Usage: HaskMaintain <path-to-codebase>"
