module Main (main) where

import Analyzer (analyzeWithConfig)
import Complexity (complexityForDecl)
import Config (defaultConfig)
import Metrics (computeFileMetrics)
import Scanner (scanForSources)
import Types (Config (..), OutputFormat (..))
import Language.Haskell.Exts (ParseResult (..), parseDecl)
import System.Directory (doesFileExist, removePathForcibly)
import System.FilePath ((</>))
import Test.Hspec
import qualified Data.List as List
import qualified Data.Text as Text
import qualified Data.Text.IO as TextIO

main :: IO ()
main = hspec $ do
    describe "Scanner" $ do
        it "finds Haskell sources recursively" $ do
            files <- scanForSources False "data/fixtures/basic"
            files `shouldSatisfy` any (List.isSuffixOf "Example.hs")

    describe "Metrics" $ do
        it "counts lines and functions for a simple file" $ do
            content <- TextIO.readFile "data/fixtures/basic/Example.hs"
            metrics <- computeFileMetrics "data/fixtures/basic/Example.hs" content
            metricsLinesTotal metrics `shouldBe` 10
            metricsLinesBlank metrics `shouldBe` 2
            metricsLinesComment metrics `shouldBe` 3
            metricsLinesCode metrics `shouldBe` 5
            metricsFunctionCount metrics `shouldBe` 2
            metricsTypeSignatureCount metrics `shouldBe` 2

    describe "Complexity" $ do
        it "computes complexity for a declaration" $ do
            case parseDecl "example x = if x > 0 then x else 0" of
                ParseOk decl -> complexityForDecl decl `shouldBe` 2
                _ -> expectationFailure "Failed to parse declaration"

    describe "Analyzer" $ do
        it "writes text and json reports" $ do
            let outputDir = "test-output/reports"
            let config = defaultConfig
                    { configRoot = "data/fixtures/basic"
                    , configOutputDir = outputDir
                    , configFormats = [OutputFormat (Text.pack "text"), OutputFormat (Text.pack "json")]
                    }
            _ <- analyzeWithConfig config
            let textReport = outputDir </> "haskmaintain-report.txt"
            let jsonReport = outputDir </> "haskmaintain-report.json"
            textExists <- doesFileExist textReport
            jsonExists <- doesFileExist jsonReport
            textExists `shouldBe` True
            jsonExists `shouldBe` True
            removePathForcibly "test-output"
