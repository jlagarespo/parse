module Parse where

import Data.List.Split (splitOn)

import Parse.Internal.Parse

-- |Parse @str@ according to the @format@, and return a tuple of parsed fields. It can fail with an
-- error. Parsable fields in the format string are denoted with @"{}"@, and they will match anything
parse :: ParseTuple a => String -> String -> a
parse format str =
  case parseTuple format str of
    Left err -> error err
    Right x  -> x

-- |Safe variant of @parse@ which returns a @Maybe@ monad instead of failing with an error.
parseMaybe :: ParseTuple a => String -> String -> Maybe a
parseMaybe format str =
  case parseTuple format str of
    Left _  -> Nothing
    Right x -> Just x

-- |Safe variant of @parse@ which returns an @Either@ monad instead of failing with an error. The
-- @Left@ (error) constructor carries a @String@ that contains information about the error.
parseEither :: ParseTuple a => String -> String -> Either String a
parseEither = parseTuple

-- |Parse @str@ according to the @format@, and return a list of parsed fields. It can fail with an
-- error. Parsable fields in the format string are denoted with @"{}"@, and they will match anything
-- until the next block of the format string matches something in @str@.
parseList :: String -> String -> [String]
parseList format str =
  case parseListEither format str of
    Left err -> error err
    Right x  -> x

-- |Safe variant of @parseList@ which returns a @Maybe@ monad instead of failing with an error.
parseListMaybe :: String -> String -> Maybe [String]
parseListMaybe format str =
  case parseListEither format str of
    Left _  -> Nothing
    Right x -> Just x

-- |Safe variant of @parseList@ which returns an @Either@ monad instead of failing with an
-- error. The @Left@ (error) constructor carries a @String@ that contains information about the
-- error.
parseListEither :: String -> String -> Either String [String]
parseListEither format = parseParts (splitOn "{}" format)
