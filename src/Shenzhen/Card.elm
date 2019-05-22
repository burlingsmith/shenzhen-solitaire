module Shenzhen.Card exposing (..)
{-| -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Graphics
import Color exposing (Color)
import Collage exposing (Collage, uniform, thick, solid)
import Collage.Text exposing (Text)

----{ Exporting
import Html exposing (Html)


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

{-| Available Shenzhen card suits -}
type Suit = Black | Green | Red | Wild

{-| Possible Shenzhen card face values -}
type Face = Num Int | Dragon | Rose

{-| A Shenzhen card -}
type Card =
    Card_
        { suit  : Suit
        , value : Face
        }


------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------

{-| Unscaled dimensions of a card in pixels.

Standard playing card dimensions:
- 2.5 x 3.5 inches (poker size)
- 2.25 x 3.5 inches (B8 size)

Both sizing schemes typically have a 0.25 inch corner radius.

-}
cardDims : { width : Float, height : Float, cornerRadius : Float }
cardDims =
    { width = 225
    , height = 350
    , cornerRadius = 25
    }

{-| Font size used on cards. -}
fontSize : Int
fontSize = 42

{-| Background color for cards. -}
backgroundColor : Color
backgroundColor = Color.rgb 210 210 200

{-| Border color for cards. -}
borderColor : Color
borderColor = Color.black

{-| RGB colors for the various Shenzhen card suits. -}
suitColors : { black : Color, green : Color, red : Color }
suitColors =
    { black = Color.black
    , green = Color.rgb 59 127 99
    , red = Color.rgb 175 50 25
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

{-| Convert suit vallues to corresponding colors -}
suitToColor : Suit -> Color
suitToColor suit =
    case suit of
        Black ->
            suitColors.black
        Green ->
            suitColors.green
        _ ->
            suitColors.red

{-| -}
blank : Collage msg
blank =
    let
        w = cardDims.width
        h = cardDims.height
        r = cardDims.cornerRadius
        fillStyle = uniform backgroundColor
        borderStyle = solid thick (uniform borderColor)
        style = (fillStyle, borderStyle)
    in
        Collage.styled style (Collage.roundedRectangle w h r)

{-| -}
toCollage : Card -> Collage msg
toCollage (Card_ card) =
    let
        num =
            Collage.Text.fromString (faceToString card.value)
            |> Collage.Text.size fontSize
            |> Collage.Text.weight Collage.Text.SemiBold
            |> Collage.Text.color (suitToColor card.suit)
            |> Collage.rendered
        topNum =
            Collage.shift (-80, 135) num
        botNum =
            (Collage.shift (80, -135) num) |> Collage.rotate (degrees 180)
    in
        Collage.group [ topNum, botNum, blank ]
