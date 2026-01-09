module Report
    ( buildReport
    , renderTextReport
    , writeReports
    ) where

import Control.Monad (forM_)
import Data.Aeson (encode)
import qualified Data.ByteString.Lazy as BL
import Data.List (sortOn)
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Text.IO as TextIO
import Data.Time (getCurrentTime)
import System.Directory (createDirectoryIfMissing)
import System.FilePath ((</>))
import Types (FileMetrics (..), OutputFormat (..), Report (..), Summary (..))

buildReport :: FilePath -> [FileMetrics] -> IO Report
buildReport root metrics = do
    now <- getCurrentTime
    let summary = buildSummary metrics
    pure Report
        { reportGeneratedAt = now
        , reportRoot = root
        , reportFiles = sortOn metricsPath metrics
        , reportSummary = summary
        }

buildSummary :: [FileMetrics] -> Summary
buildSummary metrics =
    Summary
        { summaryFiles = length metrics
        , summaryLinesTotal = sum (map metricsLinesTotal metrics)
        , summaryLinesCode = sum (map metricsLinesCode metrics)
        , summaryLinesComment = sum (map metricsLinesComment metrics)
        , summaryLinesBlank = sum (map metricsLinesBlank metrics)
        , summaryFunctionCount = sum (map metricsFunctionCount metrics)
        , summaryTypeSignatureCount = sum (map metricsTypeSignatureCount metrics)
        , summaryCyclomaticComplexity = sum (map metricsCyclomaticComplexity metrics)
        }

renderTextReport :: Report -> Text
renderTextReport report =
    Text.unlines
        [ "HaskMaintain Report"
        , "Root: " <> Text.pack (reportRoot report)
        , "Generated: " <> Text.pack (show (reportGeneratedAt report))
        , ""
        , renderSummary (reportSummary report)
        , ""
        , "Per-file Metrics:"
        , Text.unlines (map renderFile (reportFiles report))
        ]

renderSummary :: Summary -> Text
renderSummary summary =
    Text.unlines
        [ "Summary"
        , "  Files analyzed: " <> Text.pack (show (summaryFiles summary))
        , "  Lines (total): " <> Text.pack (show (summaryLinesTotal summary))
        , "  Lines (code): " <> Text.pack (show (summaryLinesCode summary))
        , "  Lines (comment): " <> Text.pack (show (summaryLinesComment summary))
        , "  Lines (blank): " <> Text.pack (show (summaryLinesBlank summary))
        , "  Functions: " <> Text.pack (show (summaryFunctionCount summary))
        , "  Type signatures: " <> Text.pack (show (summaryTypeSignatureCount summary))
        , "  Cyclomatic complexity: " <> Text.pack (show (summaryCyclomaticComplexity summary))
        ]

renderFile :: FileMetrics -> Text
renderFile metrics =
    Text.unlines
        [ "- " <> Text.pack (metricsPath metrics)
        , "    Lines total: " <> Text.pack (show (metricsLinesTotal metrics))
        , "    Lines code: " <> Text.pack (show (metricsLinesCode metrics))
        , "    Lines comment: " <> Text.pack (show (metricsLinesComment metrics))
        , "    Lines blank: " <> Text.pack (show (metricsLinesBlank metrics))
        , "    Functions: " <> Text.pack (show (metricsFunctionCount metrics))
        , "    Type signatures: " <> Text.pack (show (metricsTypeSignatureCount metrics))
        , "    Cyclomatic complexity: " <> Text.pack (show (metricsCyclomaticComplexity metrics))
        ]

writeReports :: FilePath -> [OutputFormat] -> Report -> IO [FilePath]
writeReports outputDir formats report = do
    createDirectoryIfMissing True outputDir
    let formatValues = map (Text.toLower . unOutputFormat) formats
    let paths = concatMap (reportPathFor outputDir) formatValues
    forM_ paths $ \(format, path) ->
        case format of
            "text" -> TextIO.writeFile path (renderTextReport report)
            "json" -> BL.writeFile path (encode report)
            _ -> pure ()
    pure (map snd paths)

reportPathFor :: FilePath -> Text -> [(Text, FilePath)]
reportPathFor outputDir format =
    case format of
        "text" -> [(format, outputDir </> "haskmaintain-report.txt")]
        "json" -> [(format, outputDir </> "haskmaintain-report.json")]
        _ -> []
