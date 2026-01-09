module Analyzer
    ( analyzeDirectory
    , analyzeWithConfig
    ) where

import Control.Monad (forM)
import System.FilePath (normalise)
import qualified Data.Text as Text
import Config (normalizeFormats)
import Metrics (analyzeFile)
import Report (buildReport, writeReports)
import Scanner (scanForSources)
import Types (Config (..), OutputFormat (..))

analyzeDirectory :: FilePath -> IO [FilePath]
analyzeDirectory dir = analyzeWithConfig Config
    { configRoot = dir
    , configOutputDir = "reports"
    , configFormats = normalizeFormats [OutputFormat (Text.pack "text"), OutputFormat (Text.pack "json")]
    , configFollowSymlinks = False
    }

analyzeWithConfig :: Config -> IO [FilePath]
analyzeWithConfig config = do
    let root = normalise (configRoot config)
    sources <- scanForSources (configFollowSymlinks config) root
    metrics <- forM sources analyzeFile
    report <- buildReport root metrics
    writeReports (configOutputDir config) (configFormats config) report
