module Shenzhen.Board exposing (..)
{-| Playing field for Shenzhen solitaire -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Configuration
import Config

----{ Structures
import Shenzhen.Deck as Deck exposing (Stack)
import Shenzhen.Card as Card exposing (Card)
import Extended.List as XList
import Array exposing (Array)

----{ Graphics
import Field exposing (Field)
import Collage exposing (Collage)
import Collage.Text
import Color exposing (Color)
import Collage.Layout

----{ Interactivity
import Collage.Events

----{ Output
import Html exposing (Html)
import Collage.Render


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| -}
type StackClass = Wild | Game | Discard | Rose | Held

{-| A Shenzhen board configuration, consisting of 3 wildcard slots, 8
interactive slots, 3 discard slots, 1 rose slot, and 3 dragon-collapsing
buttons.

-}
type alias Board =
    { wildZones    : Array Stack
    , gameZones    : Array Stack
    , discardZones : Array Stack
    , roseZone     : Array Stack
    , held         : Maybe Stack
    , buttons      : Array Button
    }

{-| -}
type alias CardInfo =
    { stackClass : StackClass  -- Zone type the card is in
    , stackIndex : Int         -- Specific zone the card is in
    , cardHeight : Int         -- Number of other cards beneath this card
    , card       : Card        -- Actual card
    }

type Msg
    = CardClick CardInfo
    | CardEnter CardInfo
    | CardLeave CardInfo
    | ButtonClick Button
    | Nil

type Button = Black | Green | Red


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| -}
empty : Board
empty =
    let
        nEmpty n = Array.repeat n Deck.empty
    in
        { wildZones = nEmpty 3
        , gameZones = nEmpty 8
        , discardZones = nEmpty 3
        , roseZone = nEmpty 1
        , held = Nothing
        , buttons = [ Black, Green, Red ] |> Array.fromList
        }

{-| -}
deal : Stack -> Board
deal stack =
    { empty | gameZones = XList.dealSplit 8 stack |> Array.fromList }


------------------------------------------------------------------------------
-- Update
------------------------------------------------------------------------------

update : Msg -> Board -> (Board, Cmd Msg)
update board msg =
    Debug.todo "implement"


------------------------------------------------------------------------------
-- View
------------------------------------------------------------------------------

{-| Get the card info from a single stack -}
getStackInfo : StackClass -> Int -> Stack -> List CardInfo
getStackInfo class index stack =
    if List.isEmpty stack then
        let
            emptyCard =
                { stackClass = class
                , stackIndex = index
                , cardHeight = 0
                , card = Card.new Card.None Card.Blank
                }
        in
            [ emptyCard ]
    else
        let
            genCardInfo n card =
                { stackClass = class
                , stackIndex = index
                , cardHeight = n
                , card = card
                }
        in
            List.indexedMap genCardInfo (List.reverse stack)


{-| Get the card info from all stacks in a zone -}
getZoneInfo : StackClass -> Array Stack -> List CardInfo
getZoneInfo class stacks =
    Array.indexedMap (getStackInfo class) stacks
    |> Array.toList
    |> List.concat


{-| Get the card info of all stacks in every zone -}
getCardInfo : Board -> List CardInfo
getCardInfo board =
    let
        allCards =
            [ getZoneInfo Wild board.wildZones
            , getZoneInfo Game board.gameZones
            , getZoneInfo Discard board.discardZones
            , getZoneInfo Rose board.roseZone
            ]
    in
        List.concat allCards

calcFieldPos : CardInfo -> (Int, Int)
calcFieldPos cardInfo =
    let
        rowOffset =
            if (cardInfo.stackClass == Game) then
                let
                    base = Config.layout.rowSpacing
                    bonus = cardInfo.cardHeight * Config.layout.stackOffset
                in
                    base + bonus
            else
                0
        colOffset =
            let
                base =
                    case cardInfo.stackClass of
                        Wild ->
                            0
                        Rose ->
                            4 * Config.layout.stackSpacing
                        Discard ->
                            5 * Config.layout.stackSpacing
                        Game ->
                            0
                        Held ->
                            Debug.todo "render held cards on mouse"
                bonus =
                    cardInfo.stackIndex * Config.layout.stackSpacing
            in
                base + bonus
    in
        (rowOffset + 1, colOffset + 1)

{-| Insert a card into a field -}
fInsertCard : CardInfo -> Field Msg CardInfo -> Field Msg CardInfo
fInsertCard cardInfo field =
    let
        fieldPos =
            calcFieldPos cardInfo
        eventImage =
            Card.toCollage cardInfo.card
            |> Collage.Events.onClick (CardClick cardInfo)
            |> Collage.Events.onMouseEnter (\_ -> CardEnter cardInfo)
            |> Collage.Events.onMouseLeave (\_ -> CardLeave cardInfo)
        anchor =
            Collage.Layout.base
        node =
            Field.toNode fieldPos eventImage cardInfo anchor
    in
        Field.set node field

toField : Board -> Field Msg CardInfo
toField board =
    let
        blankField = Field.new Config.dims.fieldDims Config.layout.baseUnit
    in
        case blankField of
            Nothing ->
                Debug.todo "toField: bad dims"
            Just field ->
                List.foldl fInsertCard field (getCardInfo board)

render : Board -> Html Msg
render board =
    let
        pFxn node =
            case Field.getRow node of
                Nothing ->
                    0
                Just rowNum ->
                    0 - rowNum
    in
        Field.render pFxn (toField board)
        |> Collage.scale Config.dims.globalScale
        |> Collage.Render.svg
