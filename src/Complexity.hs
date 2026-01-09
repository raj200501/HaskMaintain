module Complexity
    ( calculateCyclomaticComplexity
    , complexityForModule
    , complexityForDecl
    ) where

import Language.Haskell.Exts

calculateCyclomaticComplexity :: Module SrcSpanInfo -> Int
calculateCyclomaticComplexity = complexityForModule

complexityForModule :: Module SrcSpanInfo -> Int
complexityForModule modul =
    case modul of
        Module _ _ _ _ _ _ decls -> sum (map complexityForDecl decls)
        _ -> 0

complexityForDecl :: Decl SrcSpanInfo -> Int
complexityForDecl decl =
    case decl of
        FunBind _ matches -> sum (map complexityForMatch matches)
        PatBind _ _ rhs binds -> complexityForRhs rhs + maybe 0 complexityForBinds binds
        _ -> 1

complexityForMatch :: Match SrcSpanInfo -> Int
complexityForMatch match =
    case match of
        Match _ _ _ rhs binds -> complexityForRhs rhs + maybe 0 complexityForBinds binds
        InfixMatch _ _ _ _ rhs binds -> complexityForRhs rhs + maybe 0 complexityForBinds binds

complexityForRhs :: Rhs SrcSpanInfo -> Int
complexityForRhs rhs =
    case rhs of
        UnGuardedRhs _ exp' -> complexityForExp exp'
        GuardedRhss _ rhss -> sum (map complexityForGuardedRhs rhss)

complexityForGuardedRhs :: GuardedRhs SrcSpanInfo -> Int
complexityForGuardedRhs (GuardedRhs _ stmts exp') =
    1 + sum (map complexityForStmt stmts) + complexityForExp exp'

complexityForBinds :: Binds SrcSpanInfo -> Int
complexityForBinds binds =
    case binds of
        BDecls _ decls -> sum (map complexityForDecl decls)
        _ -> 0

complexityForStmt :: Stmt SrcSpanInfo -> Int
complexityForStmt stmt =
    case stmt of
        Generator _ _ exp' -> 1 + complexityForExp exp'
        Qualifier _ exp' -> complexityForExp exp'
        LetStmt _ binds -> complexityForBinds binds
        RecStmt _ stmts -> sum (map complexityForStmt stmts)

complexityForExp :: Exp SrcSpanInfo -> Int
complexityForExp exp' =
    case exp' of
        If _ cond thenExp elseExp ->
            1 + complexityForExp cond + complexityForExp thenExp + complexityForExp elseExp
        MultiIf _ guarded ->
            1 + sum (map complexityForGuardedRhs guarded)
        Case _ exp'' alts ->
            1 + complexityForExp exp'' + sum (map complexityForAlt alts)
        LambdaCase _ alts -> 1 + sum (map complexityForAlt alts)
        Let _ binds exp'' -> complexityForBinds binds + complexityForExp exp''
        Do _ stmts -> 1 + sum (map complexityForStmt stmts)
        MDo _ stmts -> 1 + sum (map complexityForStmt stmts)
        ListComp _ exp'' stmts -> 1 + complexityForExp exp'' + sum (map complexityForStmt stmts)
        ParComp _ exp'' stmts -> 1 + complexityForExp exp'' + sum (map (sum . map complexityForStmt) stmts)
        ExpTypeSig _ exp'' _ -> complexityForExp exp''
        App _ left right -> complexityForExp left + complexityForExp right
        InfixApp _ left _ right -> complexityForExp left + complexityForExp right
        Lambda _ _ body -> complexityForExp body
        Tuple _ _ exps -> sum (map complexityForExp exps)
        List _ exps -> sum (map complexityForExp exps)
        Paren _ exp'' -> complexityForExp exp''
        LeftSection _ exp'' _ -> complexityForExp exp''
        RightSection _ _ exp'' -> complexityForExp exp''
        AsPat _ _ exp'' -> complexityForExp exp''
        WildCard _ -> 1
        RecConstr _ _ fields -> sum (map complexityForField fields)
        RecUpdate _ exp'' fields -> complexityForExp exp'' + sum (map complexityForField fields)
        EnumFrom _ exp'' -> complexityForExp exp''
        EnumFromTo _ start end -> complexityForExp start + complexityForExp end
        EnumFromThen _ start next -> complexityForExp start + complexityForExp next
        EnumFromThenTo _ start next end -> complexityForExp start + complexityForExp next + complexityForExp end
        NegApp _ exp'' -> complexityForExp exp''
        _ -> 1

complexityForAlt :: Alt SrcSpanInfo -> Int
complexityForAlt (Alt _ _ rhs binds) =
    1 + complexityForRhs rhs + maybe 0 complexityForBinds binds

complexityForField :: FieldUpdate SrcSpanInfo -> Int
complexityForField field =
    case field of
        FieldUpdate _ _ exp' -> complexityForExp exp'
        FieldPun _ _ -> 1
        FieldWildcard _ -> 1
