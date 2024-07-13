module Analyzer (analyzeDirectory) where

import System.Directory (listDirectory, doesDirectoryExist)
import System.FilePath ((</>), takeExtension)
import Control.Monad (forM_)
import Metrics (analyzeFile)

analyzeDirectory :: FilePath -> IO ()
analyzeDirectory dir = do
    contents <- listDirectory dir
    forM_ contents $ \item -> do
        let path = dir </> item
        isDir <- doesDirectoryExist path
        if isDir
            then analyzeDirectory path
            else if takeExtension path == ".hs"
                then analyzeFile path
                else return ()
