module Main where

import Test.Tasty
import Test.Tasty.HUnit

import Parse

spam :: TestTree
spam =
  testGroup "Spam"
  [ -- Success
    testCase "parse" $
    parse "It's {}, I love it!" "It's spam, I love it!" @?= "spam"
  , testCase "parseMaybe" $
    parseMaybe "It's {}, I love it!" "It's spam, I love it!" @?= Just "spam"
  , testCase "parseEither" $
    parseEither "It's {}, I love it!" "It's spam, I love it!" @?= Right "spam"
  , testCase "parseList" $
    parseList "It's {}, I love it!" "It's spam, I love it!" @?= ["spam"]
  , testCase "parseListMaybe" $
    parseListMaybe "It's {}, I love it!" "It's spam, I love it!" @?= Just ["spam"]
  , testCase "parseListEither" $
    parseListEither "It's {}, I love it!" "It's spam, I love it!" @?= Right ["spam"]

    -- Failures
  -- , testCase "bad parse" $
  -- parse "It's {}, I love it!" "It's spam, I hate it!" @?= ???
  , testCase "bad parseMaybe" $
    parseMaybe "It's {}, I love it!" "It's spam, I hate it!" @?= (Nothing :: Maybe String)
  , testCase "bad parseEither" $ parseEither "It's {}, I love it!" "It's spam, I hate it!" @?=
    (Left "No candidates for \"It's \" in \"It's spam, I hate it!\"." :: Either String String)
  -- , testCase "bad parseList" $
  --   parseList "It's {}, I love it!" "It's spam, I hate it!" @?= ???
  , testCase "bad parseListMaybe" $
    parseListMaybe "It's {}, I love it!" "It's spam, I hate it!" @?= Nothing
  , testCase "bad parseListEither" $
    parseListEither "It's {}, I love it!" "It's spam, I hate it!" @?=
    Left "No candidates for \"It's \" in \"It's spam, I hate it!\"." ]

main :: IO ()
main = defaultMain $ testGroup "Tests" [ spam ]
