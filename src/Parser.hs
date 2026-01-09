module Parser
    ( parseModule
    ) where

import Language.Haskell.Exts

parseModule :: FilePath -> IO (Either String (Module SrcSpanInfo))
parseModule file = do
    parseResult <- parseFileWithMode (parseMode file) file
    pure $ case parseResult of
        ParseOk modul -> Right modul
        ParseFailed loc err -> Left (show loc <> ": " <> err)

parseMode :: FilePath -> ParseMode
parseMode file = defaultParseMode
    { parseFilename = file
    , extensions = map EnableExtension enabledExtensions
    }

enabledExtensions :: [Extension]
enabledExtensions =
    [ ScopedTypeVariables
    , TupleSections
    , MultiWayIf
    , LambdaCase
    , DeriveFunctor
    , DeriveFoldable
    , DeriveTraversable
    , DeriveGeneric
    , DeriveAnyClass
    , DeriveDataTypeable
    , FlexibleContexts
    , FlexibleInstances
    , MultiParamTypeClasses
    , FunctionalDependencies
    , GeneralizedNewtypeDeriving
    , NamedFieldPuns
    , RecordWildCards
    , OverloadedStrings
    ]
