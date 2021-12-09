module Parse where

import Data.List (inits, tails)
import Data.List.Split (splitOn)
import Data.Maybe (mapMaybe, catMaybes)

import Instances

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


parseList :: String -> String -> [String]
parseList format str =
  case parseListEither format str of
    Left err -> error err
    Right x  -> x

parseListEither :: String -> String -> Either String [String]
parseListEither format = parseParts (splitOn "{}" format)

parseListMaybe :: ParseTuple a => String -> String -> Maybe a
parseListMaybe format str =
  case parseTuple format str of
    Left _  -> Nothing
    Right x -> Just x


$(parseTupleInstances [2..62])

instance ParseTuple String where
  parseTuple format str =
    case parseListEither format str of
      Right [x] -> Right x
      Right result -> Left $ "Parsed " ++ show (length result) ++ " values, expected 1."
      Left x -> Left x


parse :: ParseTuple a => String -> String -> a
parse format str =
  case parseTuple format str of
    Left err -> error err
    Right x  -> x

parseMaybe :: ParseTuple a => String -> String -> Maybe a
parseMaybe format str =
  case parseTuple format str of
    Left _  -> Nothing
    Right x -> Just x

safeParse :: ParseTuple a => String -> String -> Maybe a
safeParse = parseMaybe

parseEither :: ParseTuple a => String -> String -> Either String a
parseEither = parseTuple
