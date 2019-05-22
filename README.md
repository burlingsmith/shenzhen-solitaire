# Shenzhen Solitaire

Shenzhen Solitaire (from Zachtronics' _SHENZHEN I/O_ and _SHENZHEN SOLITAIRE_), written in Elm.

Written for my Functional Programming project at the University of Chicago, Spring 2019.


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

### 3rd-Party Dependencies

**[Random.List (3.1.0)](https://package.elm-lang.org/packages/elm-community/random-extra/latest/).** The Random.List module is
part of the elm-community/random-extra library, and is used by my project to shuffle the game deck before it is initially
dealt.


### Personal Style Guide

For unspecified cases, style rules default to the [Official Elm Style Guide](https://elm-lang.org/docs/style-guide).
