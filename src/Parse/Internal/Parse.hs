module Parse.Internal.Parse (parseParts, ParseTuple, parseTuple) where

import Data.List (inits, tails)
import Data.List.Split (splitOn)
import Data.Maybe (mapMaybe, catMaybes)

import Parse.Internal.Instances

parseParts :: [String] -> String -> Either String [String]
parseParts (part:parts@(nextPart:_)) str = do
  case dropBy part str of
    Just str' ->
      let candidates = filter (beginEqual nextPart . snd) (splits str')
          (parsed, rest) = head candidates
      in if null candidates
         then Left $ "No candidates for \"" ++ part ++ "\" in \"" ++ str ++ "\"."
         else (parsed:) <$> parseParts parts rest
    Nothing -> Left $ "Expected \"" ++ part ++ "\", instead got \"" ++ str ++ "\"."

  where
    beginEqual :: String -> String -> Bool
    beginEqual "" target = target == ""
    beginEqual str target = take (length str) target == str

    dropBy :: String -> String -> Maybe String
    dropBy str target =
      if take (length str) target == str
      then Just (drop (length str) target)
      else Nothing

    splits :: [a] -> [([a], [a])]
    splits x = zip (inits x) (tails x)

parseParts _ _ = Right []

$(parseTupleInstances [2..62])

instance ParseTuple String where
  parseTuple format str =
    case parseParts (splitOn "{}" format) str of
      Right [x] -> Right x
      Right result -> Left $ "Parsed " ++ show (length result) ++ " values, expected 1."
      Left x -> Left x
