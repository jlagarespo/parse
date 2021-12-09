module Parse.Internal.Instances where

import Control.Monad
import Data.List.Split (splitOn)
import Language.Haskell.TH

-- Dear future self,
-- You're looking at this file because the parseTupleInstance function finally broke.
-- It's not fixable. You have to rewrite it.
-- Sincerely, past self.

class ParseTuple a where
  parseTuple :: String -> String -> Either String a

parseTupleInstance :: Int -> Q Dec
parseTupleInstance n = do
  unless (n > 0) $
    fail $ "Non-positive size: " ++ show n

  doParse <- [|parseParts (splitOn "{}" format) str|]
  invalidLengthL <- [p|Right result|]
  invalidLengthR <- [|Left $ "Parsed " ++ show (length result) ++ " values, expected " ++
                      show n ++ "."|]
  parseErrorL <- [p|Left x|]
  parseErrorR <- [|Left x|]

  let vars = [mkName ('t' : show n) | n <- [1..n]]
      tupleSignature = foldl (\acc var -> AppT acc (ConT $ mkName "String")) (TupleT n) vars
        -- foldl (\acc var -> AppT acc (VarT var)) (TupleT n) vars
      parseList = ListP $ map VarP vars
      parse = TupE $ map (Just . -- AppE (VarE $ mkName "read")
                          VarE) vars
      -- context = map (AppT (ConT $ mkName "Read") . VarT) vars
      iDecl = InstanceD Nothing [] -- context
              (AppT (ConT $ mkName "ParseTuple") tupleSignature) [parseDecl]
      parseDecl =
        -- `parseTuple` function
        FunD (mkName "parseTuple")
        -- only has one clause
        [Clause
          -- Arguments: format and str
          [VarP $ mkName "format", VarP $ mkName "str"]
          -- Body
          (NormalB
           (CaseE doParse
           [ Match (ConP (mkName "Right") [parseList])
                   (NormalB (AppE (ConE $ mkName "Right") parse)) []
           , Match invalidLengthL (NormalB invalidLengthR) []
           , Match parseErrorL (NormalB parseErrorR) [] ]))
          -- Where
          []]

  pure iDecl

parseTupleInstances :: [Int] -> Q [Dec]
parseTupleInstances = mapM parseTupleInstance
