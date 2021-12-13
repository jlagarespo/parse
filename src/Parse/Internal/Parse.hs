{-# OPTIONS_HADDOCK hide #-}

module Parse.Internal.Parse (parseParts, ParseTuple, parseTuple) where

import Data.List (inits, tails, find)
import Data.List.Split (splitOn)
import Data.Maybe (mapMaybe, catMaybes)

import Parse.Internal.Instances

parseParts :: [String] -> String -> Either String [String]
parseParts (part:parts@(nextPart:_)) str = do
  case dropBy part str of
    Just str' ->
      case find (beginEqual nextPart . snd) (reverse $ splits str') of
        Just (parsed, rest) -> (parsed:) <$> parseParts parts rest
        Nothing -> expected nextPart str'
    Nothing -> expected part str

parseParts [part] str =
  if str /= part
  then expected part str
  else Right []

parseParts _ _ = Right []

expected :: String -> String -> Either String a
expected what got = Left $ "Expected \"" ++ what ++ "\", instead got \"" ++ got ++ "\"."

beginEqual :: String -> String -> Bool
beginEqual str target = take (length str) target == str

dropBy :: String -> String -> Maybe String
dropBy str target =
  if str `beginEqual` target
  then Just (drop (length str) target)
  else Nothing

splits :: [a] -> [([a], [a])]
splits x = zip (inits x) (tails x)

$(parseTupleInstances [2..62])

instance ParseTuple String where
  parseTuple format str =
    case parseParts (splitOn "{}" format) str of
      Right [x] -> Right x
      Right result -> Left $ "Parsed " ++ show (length result) ++ " values, expected 1."
      Left x -> Left x
