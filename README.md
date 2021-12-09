# parse
Haskell, while notorious for its extremely powerful [parser combinators
library](https://hackage.haskell.org/package/parsec), lacks a quick-and-dirty way to parse
simple-formatted strings in a one-liner. This is especially frustrating for [Advent of
Code](https://adventofcode.com/), where the input to [some
puzzles](https://adventofcode.com/2021/day/5), which is in other languages fairly painless to parse,
requires some overly convoluted, hacky and noncompact solution.

Envious of Python's [parse](https://pypi.org/project/parse/) package, I decided to write my own,
very stripped down version, in Haskell. This package provides a way to create a sort of template for
how strings should look, and then parse them accodringly. While inspired by Python format strings,
the type of each field is not specified in the string itself, and as a matter of fact, if the
compiler can't guess them by their use, they must be specified explicitly (like in the example.)

Examples:
```hs
parse "It's {}, I love it!" "It's spam, I love it!" :: String
 == "spam"

parse "{} + {} = {}" "2.1568743 + 7.196057 = 9.3529313" :: (String, String, String)
 == ("2.1568743","7.196057","9.3529313")
```

A safe variant of `parse` is also provided, that returns `Maybe` instead of throwing an error:
```hs
parse "{} * {} = {}" "2 + 3 = 5" :: (String, String, String)
*** Exception: No candidates for "" in "2 + 3 = 5".

-- Whereas:
parseMaybe "{} * {} = {}" "2 + 3 = 5" :: Maybe (String, String, String)
 == Nothing
```

You can also parse lists quite easily:
```hs
map read $ parseList "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}" "1, 2, 3, 5, 7, 11, 13, 17, 19, 23" :: [Int]
 == [1,2,3,5,7,11,13,17,19,23]
```
(Note: You're still parsing a fixed amount of values, but now you can, as shown in the example, map
stuff to it.)

It should be noted that this package lacks most of the features supplied by
[parse](https://pypi.org/project/parse/), instead providing only basic parsing functionality. This
may or may not change in the future.
