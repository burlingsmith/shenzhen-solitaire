module Shenzhen.Card exposing
    ( Card, Suit(..), Face(..), State(..)
    , new
    , setSuit, setFace, setState
    , getSuit, getFace, getState
    , sameSuit, sameValue, sameCard, nextNumber, nextMajor, nextMinor
    , toCollage
    , toString
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
-- Constants: Size and Position
------------------------------------------------------------------------------

{-| Unscaled card width in pixels. -}
width : Float
width = 225

{-| Unscaled card height in pixels. -}
height : Float
height = 350

{-| Unscaled card corner radius in pixels. -}
cornerRadius : Float
cornerRadius = 25

{-| Absolute value for the horizontal offset of the corner images in pixels -}
cornerOffsetX : Float
cornerOffsetX = 80

{-| Absolute value for the vertical offset of the corner images in pixels -}
cornerOffsetY : Float
cornerOffsetY = 135


------------------------------------------------------------------------------
-- Constants: Text
------------------------------------------------------------------------------

{-| Unscaled font size for text on the cards -}
fontSize : Int
fontSize = 42

{-| Font weight for text on the cardsd -}
fontWeight : Collage.Text.Weight
fontWeight = Collage.Text.SemiBold


------------------------------------------------------------------------------
-- Constants: Color
------------------------------------------------------------------------------

{-| Border color for faded cards -}
bcFaded : Color
bcFaded = Color.grey

{-| Border color for normal cards -}
bcNormal : Color
bcNormal = Color.black

{-| Border color for highlighted cards -}
bcHighlighted : Color
bcHighlighted = Color.blue

{-| Fill color for faded cards -}
fadedFill : Color
fadedFill = Color.lightGrey

{-| Fill color for normal cards -}
normalFill : Color
normalFill = Color.white

{-| Fill color for highlighted cards -}
highlightedFill : Color
highlightedFill = Color.lightBlue

{-| Color for the text on black suit cards -}
blackSuitC : Color
blackSuitC = Color.black

{-| Color for the text on green suit cards -}
greenSuitC : Color
greenSuitC = Color.green

{-| Color for the text on red suit cards -}
redSuitC : Color
redSuitC = Color.darkRed

{-| Color for the text on wild suit cards (i.e. the Rose card) -}
wildSuitC : Color
wildSuitC = Color.darkRed

{-| Color for the text on cards without suits -}
noSuitC : Color
noSuitC = Color.white


------------------------------------------------------------------------------
-- Model
------------------------------------------------------------------------------

{-| A Shenzhen card -}
type Card =
    Card
        { suit  : Suit
        , value : Face
        , state : State
        }

{-| Available Shenzhen card suits. -}
type Suit = Black | Green | Red | Wild | None

{-| Possible Shenzhen card face values. -}
type Face = Num Int | Dragon | Rose | Blank

{-| Card's focus state. -}
type State = Faded | Normal | Highlighted


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| Create a card from its constituent elements -}
from : Suit -> Face -> State -> Card
from suit face state =
    Card
        { suit = suit
        , value = face
        , state = state
        }


{-| Create a new card from a suit and face. -}
new : Suit -> Face -> Card
new suit face =
    from suit face Normal


{-| -}
makeNextMinor : Card -> Maybe (Card, Card)
makeNextMinor card =
    case getFace card of
        Num x ->
            if x <= 1 || x > 9 then
                Nothing
            else
                let
                    num = Num (x - 1)
                in
                    case getSuit card of
                        Black ->
                            Just (new Green num, new Red num)
                        Green ->
                            Just (new Black num, new Red num)
                        Red ->
                            Just (new Black num, new Green num)
                        _ ->
                            Nothing
        _ ->
            Nothing


{-| -}
makeNextMajor : Card -> Maybe Card
makeNextMajor card =
    case getFace card of
        Num x ->
            if x < 1 || x >= 9 then
                Nothing
            else
                Just (setFace (Num (x + 1)) card)
        _ ->
            Nothing


------------------------------------------------------------------------------
-- Modification
------------------------------------------------------------------------------

{-| Set a card's suit. -}
setSuit : Suit -> Card -> Card
setSuit newSuit (Card card) =
    Card { card | suit = newSuit }


{-| Set a card's value. -}
setFace : Face -> Card -> Card
setFace newFace (Card card) =
    Card { card | value = newFace }


{-| Set a card's state. -}
setState : State -> Card -> Card
setState newState (Card card) =
    Card { card | state = newState }


------------------------------------------------------------------------------
-- Analysis
------------------------------------------------------------------------------

{-| Get a card's suit. -}
getSuit : Card -> Suit
getSuit (Card card) =
    card.suit


{-| Get a card's value. -}
getFace : Card -> Face
getFace (Card card) =
    card.value


{-| Get a card's state. -}
getState : Card -> State
getState (Card card) =
    card.state


------------------------------------------------------------------------------
-- Comparison
------------------------------------------------------------------------------

{-| State if two cards share the same suit -}
sameSuit : Card -> Card -> Bool
sameSuit card1 card2 =
    (getSuit card1 == getSuit card2)


{-| -}
sameValue : Card -> Card -> Bool
sameValue card1 card2 =
    case (getFace card1, getFace card2) of
        (Dragon, Dragon) ->
            True
        (Rose, Rose) ->
            True
        (Blank, Blank) ->
            True
        (Num x, Num y) ->
            x == y
        _ ->
            False


{-| -}
sameCard : Card -> Card -> Bool
sameCard card1 card2 =
    (sameValue card1 card2) && (sameSuit card1 card2)


{-| State if card1's value comes immediately after card2's -}
nextNumber : Card -> Card -> Bool
nextNumber card1 card2 =
    case (getFace card1, getFace card2) of
        (Num x, Num y) ->
            (x == y + 1)
        _ ->
            False


{-| State if card1 can be placed on a stack after card2 -}
nextMinor : Card -> Card -> Bool
nextMinor card1 card2 =
    (not (sameSuit card1 card2)) && (nextNumber card2 card1)


{-| State if card1 can be discarded on top of card2 -}
nextMajor : Card -> Card -> Bool
nextMajor card1 card2 =
    (sameSuit card1 card2) && (nextNumber card1 card2)


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


{-| Convert suit values to corresponding colors -}
suitToColor : Suit -> Color
suitToColor suit =
    case suit of
        Black ->
            blackSuitC
        Green ->
            greenSuitC
        Red ->
            redSuitC
        Wild ->
            wildSuitC
        None ->
            noSuitC


{-| Convert a card to a collage message -}
toCollage : Card -> Collage msg
toCollage (Card card) =
    let
        (fc, bc) =
            case card.state of
                Faded ->
                    (fadedFill, bcFaded)
                Normal ->
                    (normalFill, bcNormal)
                Highlighted ->
                    (highlightedFill, bcHighlighted)

        backing =
            let
                style = Tuple.pair (uniform fc) (solid thick (uniform bc))
            in
                Collage.roundedRectangle width height cornerRadius
                |> Collage.styled style

        num =
            Collage.Text.fromString (faceToString card.value)
            |> Collage.Text.size fontSize
            |> Collage.Text.weight fontWeight
            |> Collage.Text.color (suitToColor card.suit)
            |> Collage.rendered

        topNum =
            Collage.shift (0 - cornerOffsetX, cornerOffsetY) num

        botNum =
            (Collage.shift (cornerOffsetX, 0 - cornerOffsetY) num)
            |> Collage.rotate (degrees 180)
    in
        Collage.group [ topNum, botNum, backing ]


------------------------------------------------------------------------------
-- Debug
------------------------------------------------------------------------------

{-| Present a card's suit and value as a string -}
toString : Card -> String
toString (Card card) =
    let
        suit =
            case card.suit of
                Black ->
                    "Black"
                Green ->
                    "Green"
                Red ->
                    "Red"
                Wild ->
                    "Wild"
                None ->
                    "(No Suit)"
        value =
            case card.value of
                Dragon ->
                    "Dragon"
                Rose ->
                    "Rose"
                Num x ->
                    String.fromInt x
                Blank ->
                    "Blank"
    in
        suit ++ " " ++ value
