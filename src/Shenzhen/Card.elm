module Shenzhen.Card exposing
    ( Card, Suit(..), Face(..)
    , new
    , sameSuit, next, nextDiscard, nextStack
    , blank, toCollage
    )
{-| -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Config
import Config

----{ Graphics
import Color exposing (Color)
import Collage exposing (Collage, uniform, thick, solid)
import Collage.Text exposing (Text)

----{ Exporting
import Html exposing (Html)


------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Model
------------------------------------------------------------------------------

{-| A Shenzhen card -}
type Card =
    Card_
        { suit  : Suit
        , value : Face
        }

{-| Available Shenzhen card suits -}
type Suit = Black | Green | Red | Wild | None

{-| Possible Shenzhen card face values -}
type Face = Num Int | Dragon | Rose | Blank


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| -}
new : Suit -> Face -> Card
new suit face =
    Card_
        { suit = suit
        , value = face
        }


------------------------------------------------------------------------------
-- Analysis
------------------------------------------------------------------------------

{-| Determine if two cards share the same suit -}
sameSuit : Card -> Card -> Bool
sameSuit (Card_ card1) (Card_ card2) =
    (card1.suit == card2.suit)

{-| Determine if card1's value comes immediately after card2's -}
next : Card -> Card -> Bool
next (Card_ card1) (Card_ card2) =
    case (card1.value, card2.value) of
        (Num x, Num y) ->
            (x + 1 == y)
        _ ->
            False

{-| Determine if card1 can be discarded on top of card2 -}
nextDiscard : Card -> Card -> Bool
nextDiscard card1 card2 =
    (sameSuit card1 card2) && (next card1 card2)

{-| Determine if card1 can be placed on a stack after card2 -}
nextStack : Card -> Card -> Bool
nextStack card1 card2 =
    (not (sameSuit card1 card2)) && (next card2 card1)


------------------------------------------------------------------------------
-- Composition
------------------------------------------------------------------------------

{-| Convert face values to string representations -}
faceToString : Face -> String
faceToString face =
    case face of
        Num n ->
            String.fromInt n
        Dragon ->
            "D"
        Rose ->
            "R"
        Blank ->
            ""

{-| Convert suit vallues to corresponding colors -}
suitToColor : Suit -> Color
suitToColor suit =
    case suit of
        Black ->
            Config.color.cardBlack
        Green ->
            Config.color.cardGreen
        Red ->
            Config.color.cardRed
        Wild ->
            Config.color.cardWild
        None ->
            Config.color.cardBack

{-| -}
blank : Collage msg
blank =
    let
        w = Config.dims.cardWidth
        h = Config.dims.cardHeight
        r = Config.dims.cornerRadius
        fillStyle = uniform Config.color.cardBack
        borderStyle = solid thick (uniform Config.color.cardBorder)
        style = (fillStyle, borderStyle)
    in
        Collage.styled style (Collage.roundedRectangle w h r)

{-| -}
toCollage : Card -> Collage msg
toCollage (Card_ card) =
    let
        num =
            Collage.Text.fromString (faceToString card.value)
            |> Collage.Text.size (Config.text.large)
            |> Collage.Text.weight Collage.Text.SemiBold
            |> Collage.Text.color (suitToColor card.suit)
            |> Collage.rendered
        topNum =
            Collage.shift (-80, 135) num
        botNum =
            (Collage.shift (80, -135) num) |> Collage.rotate (degrees 180)
    in
        Collage.group [ topNum, botNum, blank ]
