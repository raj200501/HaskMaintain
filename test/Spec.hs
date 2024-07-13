module Main (main) where

import Analyzer (analyzeDirectory)
import Complexity (calculateCyclomaticComplexity)
import Metrics (analyzeFile)

main :: IO ()
main = do
    putStrLn "Running tests..."
    testAnalyzer
    testComplexity
    testMetrics

testAnalyzer :: IO ()
testAnalyzer = do
    putStrLn "Testing Analyzer..."
    analyzeDirectory "data"

testComplexity :: IO ()
testComplexity = do
    putStrLn "Testing Complexity..."
    complexity <- calculateCyclomaticComplexity "data/Sample.hs"
    putStrLn $ "Complexity: " ++ show complexity

testMetrics :: IO ()
testMetrics = do
    putStrLn "Testing Metrics..."
    analyzeFile "data/Sample.hs"
