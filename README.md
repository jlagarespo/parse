# parse
Haskell, while notorious for its extremely powerful [parser combinators
library](https://hackage.haskell.org/package/parsec), lacks a quick-and-dirty way to parse
simple-formatted strings in a one-liner. This is especially frustrating for [Advent of
Code](https://adventofcode.com/), where the input to [some
puzzles](https://adventofcode.com/2021/day/5), which is in other languages fairly painless to parse,
requires some overly convoluted and hacky solution, not to mention it being noncompact.

Envious of Python's [parse](https://pypi.org/project/parse/) package, I decided to write my own,
very stripped down version, in Haskell. This package provides a way to create a sort of template for
how strings should look, and then parse them accodringly. While inspired by Python format strings,
it does not provide a way to `read` strings to arbitrary types; the parsed result is itself a list
of strings. It is expected that the user will handle any further conversions themselves (for example
`read`ing the output strings into `Integer`s.)

Examples:
```hs
parse "It's {}, I love it!" "It's spam, I love it!" == ["spam"]
parse "Bring me a {}" "Bring me a shrubbery" == ["shrubbery"]
parse "The {} who {} {}" "The knights who say Ni!" == ["knights","say","Ni!"]
parse "Bring out the holy {}" "Bring out the holy hand grenade" == ["hand grenade"]
```

It should be noted that this package lacks most of the features
[parse](https://pypi.org/project/parse/) provides, instead providing only basic parsing
functionality.
