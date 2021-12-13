{-# OPTIONS_HADDOCK show-extensions #-}

-- |
-- Module      : Parse
-- Description : Top-level module that exports several parse functions.
-- Copyright   : (c) Jacob Lagares Pozo, 2021
-- License     : BSD3
-- Maintainer  : jlagarespo@protonmail.com
-- Stability   : stable
-- Portability : portable (pure haskell)
--
--
-- = Parse
--
-- This module provides an assortment of functions that allow you to parse a string according to
-- some "format string", a specification of how said input string should look. This format string is
-- composed of /literals/ (which are expected to be substrings of the input) and /fields/. Fields
-- look like this: @{}@. The reason the two braces were chosen, is to be consistent with
-- <https://pypi.org/project/parse/ Python's parse library>, despite this version not allowing types
-- to be specified in the format string. Fields match anything in the input string until the next
-- literal is found.
--
-- Safe variants of each function are provided (namely ones that return 'Maybe' and 'Either String',
-- instead of calling 'error'.)

module Parse where

import Data.List.Split (splitOn)

import Parse.Internal.Parse

----------------------------------------------------------------------------------------------------

-- |Parse a string according to the supplied format, and return a tuple with each parsed field.
-- __Warning__: This function will call 'error' when the input fails to fit the format. Consider
-- using the provided safe variants instead.
parse :: ParseTuple a => String -> String -> a
parse format str =
  case parseTuple format str of
    Left err -> error err
    Right x  -> x

-- |Safe variant of @parse@ which returns a @Maybe@ type instead of failing with an error.
parseMaybe :: ParseTuple a => String -> String -> Maybe a
parseMaybe format str =
  case parseTuple format str of
    Left _  -> Nothing
    Right x -> Just x

-- |Safe variant of @parse@ which returns an @Either@ type instead of failing with an error. The
-- @Left@ (error) constructor carries a @String@ that contains information about the error.
parseEither :: ParseTuple a => String -> String -> Either String a
parseEither = parseTuple

----------------------------------------------------------------------------------------------------

-- |Parse a string according to the supplied format, and return a list with each parsed field.
-- __Warning__: This function will call 'error' when the input fails to fit the format. Consider
-- using the provided safe variants instead.
parseList :: String -> String -> [String]
parseList format str =
  case parseListEither format str of
    Left err -> error err
    Right x  -> x

-- |Safe variant of @parseList@ which returns a @Maybe@ type instead of failing with an error.
parseListMaybe :: String -> String -> Maybe [String]
parseListMaybe format str =
  case parseListEither format str of
    Left _  -> Nothing
    Right x -> Just x

-- |Safe variant of @parseList@ which returns an @Either@ type instead of failing with an
-- error. The @Left@ (error) constructor carries a @String@ that contains information about the
-- error.
parseListEither :: String -> String -> Either String [String]
parseListEither format = parseParts (splitOn "{}" format)
