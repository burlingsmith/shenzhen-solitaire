# Shenzhen Solitaire

Shenzhen Solitaire - from Zachtronics' _SHENZHEN I/O_ and _SHENZHEN SOLITAIRE_ - written in Elm for my Functional Programming
project at the University of Chicago, Spring 2019.

Code last updated for Elm 0.19.


## Game

### Controls

- Cards are moved by clicking first the card you wish to move and then the location you wish to move it to.
- `ESC` and `SPACE` pause and unpause the game
- `R` starts a new game (this counts as a loss unless the game has either been won or is still in the setup phase).

### Rules

Short version:
1. You win by removing all cards from the bottom eight slots.  Dragon cards must end in the wild slots, the rose must end in
the rose slot, and numbered cards must go in the discard slots, in sequential order (as in standard Solitaire).
2. The three wild slots in the upper left can hold one card at a time each, with no further restrictions.
3. If all four dragon cards of any given suit are exposed, and a wild slot is open, press the corresponding button to send them
all to that single slot. The slot will no longer be available to store arbitrary cards.
4. Cards of different suits can be moved onto other cards in the bottom slots, as in normal solitaire.

Long version:
- [Rules for Shenzhen Solitaire](https://shenzhen-io.fandom.com/wiki/Shenzhen_Solitaire)
- [Rules for standard Solitaire](https://bicyclecards.com/how-to-play/solitaire/)


## Code

### Modules

- **Clock (1.0.0) -** Contains a simple record storing milliseconds, seconds, and so on as distinct values, as well as several
constants for units of time designed to improve readability.

- **Extended.List (1.0.0) -** Expands upon the operations defined in Elm's core List library.

- **Field (1.0.0) -** An API for working with collages in a straighforward fashion. Fields are grids of collage messages and
metadata, spaced evenly by some pixel value. Rendering and event processing is simplified for collages in the field.

- **Grid (1.0.0) -** A two-dimensional array in Elm.

- **Shenzhen.Board (1.0.0) -** Model for the Shenzhen Solitaire board.

- **Shenzhen.Card (1.0.0) -** Model for a single Shenzhen Solitaire card.

- **Shenzhen.Deck (1.0.0) -** Model for stacked Shenzhen Solitaire cards.

### Dependencies

- **[Collage (2.0.1)](https://package.elm-lang.org/packages/timjs/elm-collage/latest/Collage) -** Graphics library.

- **[Random.List (3.1.0)](https://package.elm-lang.org/packages/elm-community/random-extra/latest/) -** Randomization functions
for lists.


## Personal Style Guide

For unspecified cases, style rules default to the [Official Elm Style Guide](https://elm-lang.org/docs/style-guide).

### Line Length

- Lines are not to exceed 79 characters in length

### Organization

### Headers

- Section headers consist of three lines, as shown below. Section titles are to use '&' instead of 'and', and are capitalized
in accordance with Chicago Manual of Style title rules. They are always preceded by exactly two blank lines and are always
followed by exactly one blank line. The top and bottom lines are 79 dashes. These titles should be broad but informative.

- Subheaders consist of four dashes and an open curly brace. They are to be preceeded by two empty lines and one blank line,
save in the case of imports, in which case they are preceded by one blank line and followed by no blank lines. These titles
should be more specific and offer context or grouping. Only the first word is capitalized.

### Sample

```Elm
module Example exposing (..)
{-| Example -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Graphics
import Collage
import Collage.Layout

----{ Randomness
import Random.List as RList


------------------------------------------------------------------------------
--
------------------------------------------------------------------------------


```


## Notes

- Project uses semantic versioning
