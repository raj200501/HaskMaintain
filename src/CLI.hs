module CLI
    ( runCLI
    ) where

import Config (parseArgs)
import Analyzer (analyzeWithConfig)
import Types (Config (..))

runCLI :: IO ()
runCLI = do
    config <- parseArgs
    if configRoot config == "__help__"
        then pure ()
        else do
            _ <- analyzeWithConfig config
            putStrLn "Report generated."
