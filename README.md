# parse
Haskell, while notorious for its extremely powerful [parser combinators
library](https://hackage.haskell.org/package/parsec), lacks a quick-and-dirty way to parse
simple-formatted strings in a one-liner. This is especially frustrating for [Advent of
Code](https://adventofcode.com/), where the input to [some
puzzles](https://adventofcode.com/2021/day/5), which is in other languages fairly painless to parse,
requires some overly convoluted, hacky and noncompact solution.

Envious of Python's [parse](https://pypi.org/project/parse/) package, I decided to write my own,
very stripped down version, in Haskell. This package provides a way to create a "template" for how
strings should look, and parse them accodringly. While inspired by Python format strings, the
content of each field is returned as a string. If you so desire, you can `read` them manually.

Examples:
```hs
>>> parse "It's {}, I love it!" "It's spam, I love it!" :: String
"spam"

>>> parse "{} + {} = {}" "2.1568743 + 7.196057 = 9.3529313" :: (String, String, String)
("2.1568743","7.196057","9.3529313")
```

You can also return the parsed fields as a list, instead of a tuple (for long lists, or ones you
intend to use as a `Functor`.)
```hs
>>> map read $ parseList "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}" "2, 3, 5, 7, 11, 13, 17, 19, 23, 29" :: [Int]
[2,3,5,7,11,13,17,19,23,29]
```

Safe versions of each function are provided alongside them.

It should be noted that this package lacks most of the features supplied by
[parse](https://pypi.org/project/parse/), instead providing only basic parsing functionality. This
may or may not change in the future.
