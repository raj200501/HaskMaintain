module Complexity (calculateCyclomaticComplexity) where

import Language.Haskell.Exts (parseFile, Module(..), Decl(..))

calculateCyclomaticComplexity :: FilePath -> IO Int
calculateCyclomaticComplexity file = do
    parseResult <- parseFile file
    case parseResult of
        ParseOk (Module _ _ _ _ _ _ decls) -> return $ sum (map complexityOfDecl decls)
        _ -> return 0

complexityOfDecl :: Decl -> Int
complexityOfDecl (FunBind matches) = length matches
complexityOfDecl _ = 1
