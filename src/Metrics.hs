module Metrics (analyzeFile) where

import System.IO (readFile)
import Control.Monad (forM_)
import Data.List (isPrefixOf)
import Complexity (calculateCyclomaticComplexity)

analyzeFile :: FilePath -> IO ()
analyzeFile file = do
    content <- readFile file
    let linesOfCode = length (lines content)
    let functions = length (filter (isPrefixOf " ") (lines content))
    complexity <- calculateCyclomaticComplexity file

    putStrLn $ "File: " ++ file
    putStrLn $ "Lines of Code: " ++ show linesOfCode
    putStrLn $ "Function Count: " ++ show functions
    putStrLn $ "Cyclomatic Complexity: " ++ show complexity
    putStrLn ""
