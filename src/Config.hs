module Config
    ( parseArgs
    , defaultConfig
    , normalizeFormats
    ) where

import Data.List (isPrefixOf)
import qualified Data.Text as Text
import System.Environment (getArgs)
import Types (Config (..), OutputFormat (..))

parseArgs :: IO Config
parseArgs = do
    args <- getArgs
    case applyArgsWithHelp defaultConfig args of
        Left helpText -> do
            putStrLn helpText
            pure defaultConfig { configRoot = "__help__" }
        Right config -> pure (ensureFormats config)

normalizeFormats :: [OutputFormat] -> [OutputFormat]
normalizeFormats = map (OutputFormat . Text.toLower . unOutputFormat)

applyArgs :: Config -> [String] -> Config
applyArgs config [] = config
applyArgs config ("--output-dir":dir:rest) = applyArgs (config { configOutputDir = dir }) rest
applyArgs config ("--format":fmt:rest) =
    let formats = configFormats config <> [OutputFormat (Text.pack fmt)]
    in applyArgs (config { configFormats = formats }) rest
applyArgs config ("--follow-symlinks":rest) = applyArgs (config { configFollowSymlinks = True }) rest
applyArgs config ("--help":_) = config { configRoot = "__help__" }
applyArgs config (arg:rest)
    | "-" `isPrefixOf` arg = applyArgs config rest
    | otherwise = applyArgs (config { configRoot = arg }) rest

usage :: [String]
usage =
    [ "Usage: HaskMaintain <path> [--output-dir DIR] [--format json|text] [--follow-symlinks]"
    , ""
    , "Options:"
    , "  --output-dir DIR     Directory to write reports (default: ./reports)"
    , "  --format FORMAT      Output format(s) to write. Repeat for multiple."
    , "  --follow-symlinks     Follow symlinks when scanning."
    , "  --help               Show this help text."
    ]

defaultConfig :: Config
defaultConfig = Config
    { configRoot = "."
    , configOutputDir = "reports"
    , configFormats = [OutputFormat (Text.pack "text"), OutputFormat (Text.pack "json")]
    , configFollowSymlinks = False
    }

renderHelp :: String
renderHelp = unlines usage

applyArgsWithHelp :: Config -> [String] -> Either String Config
applyArgsWithHelp config args =
    let result = applyArgs config args
    in if configRoot result == "__help__"
        then Left renderHelp
        else Right result

ensureFormats :: Config -> Config
ensureFormats config =
    let normalized = normalizeFormats (configFormats config)
    in config { configFormats = if null normalized then [OutputFormat (Text.pack "text")] else normalized }
