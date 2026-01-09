module Types
    ( FileMetrics(..)
    , Summary(..)
    , Report(..)
    , OutputFormat(..)
    , Config(..)
    ) where

import Data.Aeson (ToJSON (..), object, (.=))
import Data.Text (Text)
import Data.Time (UTCTime)

newtype OutputFormat = OutputFormat { unOutputFormat :: Text }
    deriving (Eq, Show)

instance ToJSON OutputFormat where
    toJSON (OutputFormat fmt) = toJSON fmt

data Config = Config
    { configRoot :: FilePath
    , configOutputDir :: FilePath
    , configFormats :: [OutputFormat]
    , configFollowSymlinks :: Bool
    } deriving (Eq, Show)

data FileMetrics = FileMetrics
    { metricsPath :: FilePath
    , metricsLinesTotal :: Int
    , metricsLinesCode :: Int
    , metricsLinesComment :: Int
    , metricsLinesBlank :: Int
    , metricsFunctionCount :: Int
    , metricsTypeSignatureCount :: Int
    , metricsCyclomaticComplexity :: Int
    } deriving (Eq, Show)

instance ToJSON FileMetrics where
    toJSON metrics = object
        [ "path" .= metricsPath metrics
        , "lines" .= object
            [ "total" .= metricsLinesTotal metrics
            , "code" .= metricsLinesCode metrics
            , "comment" .= metricsLinesComment metrics
            , "blank" .= metricsLinesBlank metrics
            ]
        , "functions" .= metricsFunctionCount metrics
        , "typeSignatures" .= metricsTypeSignatureCount metrics
        , "cyclomaticComplexity" .= metricsCyclomaticComplexity metrics
        ]

data Summary = Summary
    { summaryFiles :: Int
    , summaryLinesTotal :: Int
    , summaryLinesCode :: Int
    , summaryLinesComment :: Int
    , summaryLinesBlank :: Int
    , summaryFunctionCount :: Int
    , summaryTypeSignatureCount :: Int
    , summaryCyclomaticComplexity :: Int
    } deriving (Eq, Show)

instance ToJSON Summary where
    toJSON summary = object
        [ "files" .= summaryFiles summary
        , "lines" .= object
            [ "total" .= summaryLinesTotal summary
            , "code" .= summaryLinesCode summary
            , "comment" .= summaryLinesComment summary
            , "blank" .= summaryLinesBlank summary
            ]
        , "functions" .= summaryFunctionCount summary
        , "typeSignatures" .= summaryTypeSignatureCount summary
        , "cyclomaticComplexity" .= summaryCyclomaticComplexity summary
        ]

data Report = Report
    { reportGeneratedAt :: UTCTime
    , reportRoot :: FilePath
    , reportFiles :: [FileMetrics]
    , reportSummary :: Summary
    } deriving (Eq, Show)

instance ToJSON Report where
    toJSON report = object
        [ "generatedAt" .= reportGeneratedAt report
        , "root" .= reportRoot report
        , "summary" .= reportSummary report
        , "files" .= reportFiles report
        ]
