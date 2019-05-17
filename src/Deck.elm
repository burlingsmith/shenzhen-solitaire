module Deck exposing (..)
{-| Rules for moving around shenzen cards in the stacks -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Core
import List exposing (map)

----{ Random
import Random
import Random.List


------------------------------------------------------------------------------
-- Types & Type Aliases
------------------------------------------------------------------------------

{-| Card value (either 1-9, Dragon, or Flower) -}
type CardFace = Num Int | Dragon | Flower

{-| Card suit -}
type Suit = Black | Green | Red | Special

{-| Cards are either face-up or face-down -}
type Orientation = Up | Down

{-| A single card in a game of Shenzen Solitaire -}
type alias Card =
    { value  : CardFace
    , suit   : Suit
    , facing : Orientation
    }

{-| A collection of cards -}
type alias Stack = List Card


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| Create a card from the composite values -}
asCard : CardFace -> Suit -> Orientation -> Card
asCard face suit dir =
    { value = face
    , suit = suit
    , facing = dir
    }

{-| Generate a full, sorted deck of Shenzen Solitaire cards -}
new : Stack
new =
    let
        faces  =
            [ Num 1, Num 2, Num 3, Num 4, Num 5, Num 6, Num 7, Num 8, Num 9
            , Dragon, Dragon, Dragon, Dragon
            ]
        black = map (\x -> asCard x Black Down) faces
        red   = map (\x -> asCard x Red   Down) faces
        green = map (\x -> asCard x Green Down) faces
    in
        (asCard Flower Special Down)::(black ++ red ++ green)


------------------------------------------------------------------------------
--
------------------------------------------------------------------------------

{-| Randomize a collection of cards -}
shuffle : Stack -> Random.Generator Stack
shuffle deck =
    Random.List.shuffle deck


------------------------------------------------------------------------------
--
------------------------------------------------------------------------------

{-| Remove the top card from a deck -}
draw : Stack -> Maybe (Card, Stack)
draw deck =
    case deck of
        head::tail -> Just (head, tail)
        _ -> Nothing


------------------------------------------------------------------------------
-- Rulesets
------------------------------------------------------------------------------

{-| Determine if two cards are different colors -}
diffColor : Card -> Card -> Bool
diffColor card1 card2 =
    case (card1.suit, card2.suit) of
        (Green, Green) -> False
        (Red, Red) -> False
        (Black, Black) -> False
        _ -> True

{-| Deremine if card1's face value is one lower than card2's -}
oneLower : Card -> Card -> Bool
oneLower card1 card2 =
    case (card1.value, card2.value) of
        (Num x, Num y) ->
            (x == y - 1)
        _ ->
            False

{-| Determine if card1 is the next in sequence after card2 -}
nextInSequence : Card -> Card -> Bool
nextInSequence card1 card2 =
    if (diffColor card1 card2) then
        False
    else
        (oneLower card2 card1)

{-| -}
canGrab : Int -> Stack -> Bool
canGrab depth stack =
    canGrab_ depth Nothing stack

canGrab_ : Int -> Maybe Card -> Stack -> Bool
canGrab_ depth lastCard stack =
    if (depth <= 0) then
        True
    else
        case stack of
            [] ->
                False
            head::tail ->
                case lastCard of
                    Nothing ->
                        canGrab_ (depth - 1) (Just head) tail
                    Just card ->
                        if (nextInSequence head card) then
                            canGrab_ (depth - 1) (Just head) tail
                        else
                            False


{-|  -}
grab : Int -> Stack -> (Stack, Stack)
grab depth stack =
    let
        (removed, remaining) = grab_ depth ([], stack)
    in
        (List.reverse removed, remaining)

grab_ : Int -> (Stack, Stack) -> (Stack, Stack)
grab_ depth (curTaken, curLeft) =
    case (depth, curLeft) of
        (0, _) ->
            (curTaken, curLeft)
        (_, []) ->
            (curTaken, curLeft)
        (n, head::tail) ->
            grab_ (n - 1) (head::curTaken, tail)
