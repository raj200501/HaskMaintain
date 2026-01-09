module Scanner
    ( scanForSources
    ) where

import Control.Monad (filterM, forM)
import System.Directory (doesDirectoryExist, listDirectory, pathIsSymbolicLink)
import System.FilePath ((</>), takeExtension)

scanForSources :: Bool -> FilePath -> IO [FilePath]
scanForSources followSymlinks root = do
    exists <- doesDirectoryExist root
    if exists
        then go root
        else pure []
  where
    go dir = do
        entries <- listDirectory dir
        paths <- forM entries $ \entry -> do
            let path = dir </> entry
            isDir <- doesDirectoryExist path
            isLink <- pathIsSymbolicLink path
            if isDir && (followSymlinks || not isLink)
                then go path
                else pure [path | isHaskellSource path]
        pure (concat paths)

isHaskellSource :: FilePath -> Bool
isHaskellSource path =
    case takeExtension path of
        ".hs" -> True
        ".lhs" -> True
        _ -> False
