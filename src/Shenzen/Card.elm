module Shenzen.Card exposing (..)
{-| -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

import Html exposing (Html)

----{ Graphics
import Collage exposing (Collage)
import Collage.Text exposing (Text)
import Color exposing (Color)


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

{-| -}
type Suit = Black | Green | Red

{-| -}
type Face = Num Int | Dragon | Rose

{-| -}
type Card =
    Card_
        { suit  : Suit
        , value : Face
        }


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
-- Composition
------------------------------------------------------------------------------

{-| -}
faceToString : Face -> String
faceToString face =
    case face of
        Num n ->
            String.fromInt n
        Dragon ->
            "D"
        Rose ->
            "R"

{-| -}
suitToColor : Suit -> Color
suitToColor suit =
    case suit of
        Black ->
            Color.black
        Red ->
            Color.red
        Green ->
            Color.green

{-| -}
backing : Collage msg
backing =
    let
        width = 225
        height = 350
        radius = 25
        fillStyle = Collage.uniform Color.white
        borderColor = Collage.uniform Color.black
        borderStyle = Collage.solid Collage.thick borderColor
    in
        let
            cStyle = (fillStyle, borderStyle)
        in
            Collage.roundedRectangle width height radius
            |> Collage.styled cStyle

{-| -}
toCollage : Card -> Collage msg
toCollage (Card_ card) =
    let
        num =
            Collage.Text.fromString (faceToString card.value)
            |> Collage.Text.size 42
            |> Collage.Text.weight Collage.Text.SemiBold
            |> Collage.Text.color (suitToColor card.suit)
            |> Collage.rendered
        topNum =
            Collage.shift (-80, 135) num
        botNum =
            (Collage.shift (80, -135) num) |> Collage.rotate (degrees 180)
    in
        Collage.group [ topNum, botNum, backing ]
