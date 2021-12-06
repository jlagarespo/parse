module Parse where

import Data.List (inits, tails)
import Data.List.Split (splitOn)
import Data.Maybe (mapMaybe, catMaybes)

parse :: String -> String -> [String]
parse format str = parse' (splitOn "{}" format) str
  where
    parse' :: [String] -> String -> [String]
    parse' (part:parts@(nextPart:_)) str = do
      case dropBy part str of
        Just str' ->
          let candidates = filter (beginEqual nextPart . snd) (splits str')
              (parsed, rest) = head candidates
          in if null candidates
             then error $ "No candidates for \"" ++ part ++ "\" in \"" ++ str ++ "\"."
             else parsed:parse' parts rest
        Nothing -> error $ "Expected \"" ++ part ++ "\", instead got \"" ++ str ++ "\"."
    parse' _ _ = []

dropBy :: String -> String -> Maybe String
dropBy str target =
  if take (length str) target == str
  then Just (drop (length str) target)
  else Nothing

beginEqual :: String -> String -> Bool
beginEqual "" target = target == ""
beginEqual str target = take (length str) target == str

splits :: [a] -> [([a], [a])]
splits x = zip (inits x) (tails x)
