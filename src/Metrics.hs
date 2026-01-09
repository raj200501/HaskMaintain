module Metrics
    ( analyzeFile
    , computeFileMetrics
    ) where

import Data.Char (isSpace)
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Text.IO as TextIO
import Language.Haskell.Exts
import Complexity (calculateCyclomaticComplexity)
import Parser (parseModule)
import Types (FileMetrics (..))

analyzeFile :: FilePath -> IO FileMetrics
analyzeFile file = do
    content <- TextIO.readFile file
    computeFileMetrics file content

computeFileMetrics :: FilePath -> Text -> IO FileMetrics
computeFileMetrics file content = do
    let linesOfFile = Text.lines content
    let (commentLines, blankLines, codeLines) = classifyLines linesOfFile
    parsed <- parseModule file
    let (functionCount, typeSigCount, complexity) =
            case parsed of
                Left _ -> (0, 0, 0)
                Right modul ->
                    let decls = case modul of
                            Module _ _ _ _ _ _ declList -> declList
                            _ -> []
                        funs = sum (map countFunctions decls)
                        typeSigs = sum (map countTypeSigs decls)
                        cyclo = calculateCyclomaticComplexity modul
                    in (funs, typeSigs, cyclo)
    pure FileMetrics
        { metricsPath = file
        , metricsLinesTotal = length linesOfFile
        , metricsLinesCode = codeLines
        , metricsLinesComment = commentLines
        , metricsLinesBlank = blankLines
        , metricsFunctionCount = functionCount
        , metricsTypeSignatureCount = typeSigCount
        , metricsCyclomaticComplexity = complexity
        }

classifyLines :: [Text] -> (Int, Int, Int)
classifyLines = go False (0, 0, 0)
  where
    go _ totals [] = totals
    go inBlock (commentAcc, blankAcc, codeAcc) (line:rest) =
        let trimmed = Text.dropWhile isSpace line
            hasBlockStart = "{-" `Text.isInfixOf` trimmed
            hasBlockEnd = "-}" `Text.isInfixOf` trimmed
            hasLineComment = "--" `Text.isPrefixOf` trimmed
            isBlank = Text.null trimmed
            (commentAcc', blankAcc', codeAcc', inBlock')
                | inBlock =
                    let nowInBlock = not hasBlockEnd
                    in (commentAcc + 1, blankAcc, codeAcc, nowInBlock)
                | isBlank = (commentAcc, blankAcc + 1, codeAcc, inBlock)
                | hasLineComment = (commentAcc + 1, blankAcc, codeAcc, inBlock)
                | hasBlockStart && Text.isPrefixOf "{-" trimmed =
                    let nowInBlock = not hasBlockEnd
                    in (commentAcc + 1, blankAcc, codeAcc, nowInBlock)
                | hasBlockStart =
                    let nowInBlock = not hasBlockEnd
                    in (commentAcc, blankAcc, codeAcc + 1, nowInBlock)
                | otherwise = (commentAcc, blankAcc, codeAcc + 1, inBlock)
        in go inBlock' (commentAcc', blankAcc', codeAcc') rest

countFunctions :: Decl SrcSpanInfo -> Int
countFunctions decl =
    case decl of
        FunBind _ matches -> length matches
        PatBind _ pat _ _ -> case pat of
            PVar _ _ -> 1
            _ -> 0
        _ -> 0

countTypeSigs :: Decl SrcSpanInfo -> Int
countTypeSigs decl =
    case decl of
        TypeSig _ names _ -> length names
        _ -> 0
