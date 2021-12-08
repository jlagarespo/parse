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
parse "{}, {}, {}, {}, {}" "1, 2, 3, 4, 5" :: (Int, Int, Int, Int, Int)
 == (1, 2, 3, 4, 5)

parse "{} + {} = {}" "2.1568743 + 7.196057 = 9.3529313" :: (Double, Double, Double)
 == (2.1568743,7.196057,9.3529313)
```

A safe variant of `parse` is also provided, that returns `Maybe` instead of throwing an error:
```hs
parse "{} * {} = {}" "2 + 3 = 5" :: (Int, Int, Int)
*** Exception: No candidates for "" in "2 + 3 = 5".

-- Whereas:
safeParse "{} * {} = {}" "2 + 3 = 5" :: Maybe (Int, Int, Int)
 == Nothing
```

Parse automatically calls `read` on each field, so if you provide a `Read` instance for them, it can
properly parse your custom types.

## Gotchas
* This package's implementation is hacky. That is really the best way to describe it. It uses
  template haskell to generate versions of the parse function for each n-tuple (up to 62-tuple,
  which is the maximum GHC allows.)

  Haskell, for whatever reason, doesn't allow 1-tuples to exist. To workaround this issue, the
  [OneTuple](https://hackage.haskell.org/package/OneTuple) package was created, which this package
  uses to parse single values like so:
  ```hs
  parse "It took {} years." "It took 7500000 years." :: Solo Int
   == Solo 7500000
  ```

  Despite the inconvenient syntax, it shouldn't too big of an issue.

* Since parse automatically applies `read` to all the fields, the parsed types must all have an
  instance of `Read`. This also means that strings are not parsed as you might expect. Unlike
  Python's parse library, the default behaviour is to parse strings as if they were Haskell strings
  (that is, `Char` lists). Thus, this parses successfully: `parse "{}" "\"hello, world\"" :: Solo
  String` (and so does this: `parse "{}" "['h','e','l','l','o',',',' ','w','o','r','l','d']" :: Solo
  String`), but this doesn't: `parse "{}" "hello, world" :: Solo String`.

  For now you can workaround the issue by calling `parseList` directly.

* It should be noted that this package lacks most of the features supplied by
  [parse](https://pypi.org/project/parse/), instead providing only basic parsing functionality. This
  may or may not change in the future.
