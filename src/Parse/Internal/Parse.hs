{-# OPTIONS_HADDOCK hide #-}

module Parse.Internal.Parse (parseParts, parseTuple, ParseTuple) where

import Data.List (inits, tails, find)
import Data.List.Split (splitOn)
import Data.Maybe (mapMaybe, catMaybes)

import Parse.Internal.Instances

parseParts :: [String] -> String -> Either String [String]
parseParts (part:parts@(nextPart:_)) str = do
  case dropBy part str of
    Just str' ->
      let -- First, we acquire all the possible candidates that may be the parsed result. We do so
          -- by checking which of all the possible splits happen to split somewhere that continues
          -- with our next part. Whatever comes before that is our candidate. Note that we do not
          -- consider the first split, since being empty, it will always match.
          -- TODO: Figure out some way to do this while still being able to parse empty values.
          candidates = filter (beginEqual nextPart . snd) (tail $ splits str')

          -- Then, we apply the parse function to all candidates with the following parts, and we
          -- filter out all those that fail to parse. The survivors are all valid parses.
          parseCandidates = mapMaybe (\(parsed, rest) ->
                                        case parseParts parts rest of
                                          Right r -> Just (parsed, r)
                                          Left r  -> Nothing) candidates

      -- If there are no survivors, the input does not conform to the format string, and we return
      -- an error. Otherwise, we take the last survivor (the one in which the parsed result is
      -- longest), and we return it, along with the other parsed results the survivor carried.
      in case last' parseCandidates of
           Just (parsed, rest) -> Right $ parsed:rest
           Nothing -> Left $ "No candidates for \"" ++ nextPart ++ "\" in \"" ++ str' ++ "\"."
    Nothing -> Left $ "Expected \"" ++ str ++ "\" to start with \"" ++ part ++ "\"."
parseParts _ _ = Right []

-- |Check whether the first @length a@ characters of 'b' match those of 'a'. In other words, check
-- whether 'b' begins by 'a'.
beginEqual :: String -> String -> Bool
beginEqual a b = take (length a) b == a

-- |If @a `beginEqual` b@, return the first @length a@ characters of 'b'.
dropBy :: String -> String -> Maybe String
dropBy a b =
  if a `beginEqual` b
  then Just $ drop (length a) b
  else Nothing

-- |This function's workings are best understood with an example:
-- >>> splits "hello" == [("","hello"),("h","ello"),("he","llo"),("hel","lo"),("hell","o"),("hello","")]
splits :: [a] -> [([a], [a])]
splits x = zip (inits x) (tails x)

-- |Safe version of last.
last' :: [a] -> Maybe a
last' [] = Nothing
last' x  = Just $ last x

-- |Generate 'ParseTuple' instances for up to 62-tuples (the maximum supported by GHC.)
$(parseTupleInstances [2..62])

-- |Special case because, God knows why, Haskell lacks 1-tuples.
instance ParseTuple String where
  parseTuple format str =
    case parseParts (splitOn "{}" format) str of
      Right [x] -> Right x
      Right result -> Left $ "Parsed " ++ show (length result) ++ " values, expected 1."
      Left x -> Left x
