# TODO
* More features that [parse](https://pypi.org/project/parse/) provides:
  - Searching a string for a pattern.
  - Parse function that allows for named fileds ("{field_name}") and returns a map in the form of
	FieldName -> Value. Of course that wouldn't play well with polymorphism.
* Find out why template-haskell 2.16.0.0 works just fine, but 2.18.0.0 breaks GHC lol.
* Allow braces to be escaped in the format string.
* More test coverage.
* `Data.Text` support.

## DONE
### 2021-12-13 (or 14? it was midnight.)
* Better deal with the beggining and end of the string (example: `parse "{} spam" "spam spam spam"
  :: String` behaves unexpectedly.)

In the process I significantly improved how the `parseParts` function looks. Before it was really
hacky, now it's much nicer.

* Significantly improve the docs.

#### UPDATE (2021-12-15):
I was incredibly stupid. That whole "fix" completely broke when parsing more than 2 fields. That's
why you write proper unit tests... (I didn't.)

Anyway, the parsing system has now been reworked. It is about 10x nicer and more elegant. For
details, check `Parse.Internal.Parse`.

### 2021-12-09: Read problems
Solved by working around the issue; now we only return tuples of strings, and the user gets to
`read` them themselves =)

* Write a string wrapper type that implements `read` in the way you'd expect, and that's as
  unobtrusive as humanly possible.
* Parse function that returns a tuple of strings.

Relevant part from the README:
* Since parse automatically applies `read` to all the fields, the parsed types must all have an
  instance of `Read`. This also means that strings are not parsed as you might expect. Unlike
  Python's parse library, the default behaviour is to parse strings as if they were Haskell strings
  (that is, `Char` lists). Thus, this parses successfully: `parse "{}" "\"hello, world\"" :: Solo
  String` (and so does this: `parse "{}" "['h','e','l','l','o',',',' ','w','o','r','l','d']" :: Solo
  String`), but this doesn't: `parse "{}" "hello, world" :: Solo String`.

  For now you can workaround the issue by calling `parseList` directly.

I've also killed two birds with one stone, since now 1-tuples are no longer required (we can return
single strings directly.)

Relevant part from the README:
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
