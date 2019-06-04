module Shenzhen.Board exposing (..)
{-| Playing field for Shenzhen solitaire -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Configuration
import Config

----{ Structures
import Shenzhen.Deck as Deck
import Shenzhen.Card as Card exposing (Card)
import Extended.List as XList
import Array exposing (Array)

----{ Graphics
import Field exposing (Field)
import Collage exposing (Collage)
import Collage.Text
import Color exposing (Color)
import Collage.Layout
import Random

----{ Interactivity
import Collage.Events

----{ Output
import Html exposing (Html)
import Collage.Render


------------------------------------------------------------------------------
-- Stack Wrapper
------------------------------------------------------------------------------

{-| Collection of cards and associated positional information -}
type Stack =
    Stack
        { stack : Deck.Stack  -- Actual stack
        , zone  : Zone        -- Zone the stack belongs to
        , index : Int         -- Index withing the zone array
        }


{-| Possible zone classifications for stacks on a board -}
type Zone
    = Wild
    | Game
    | Discard
    | Rose
    | Held


----{ Creation

{-| Create a stack from its constituent elements -}
toStack : Zone -> Int -> Deck.Stack -> Stack
toStack zone index stack =
    Stack
        { stack = stack
        , zone = zone
        , index = index
        }


{-| Create a stack with no cards -}
emptyStack : Zone -> Int -> Stack
emptyStack zone index =
    toStack zone index Deck.empty


{-| Create a stack from a full, ordered deck of Shenzhen Solitaire cards -}
fullDeck : Stack
fullDeck =
    toStack Held 0 Deck.full


----{ Modification

{-| Set a stack's internal representation -}
setStack : Stack -> Deck.Stack -> Stack
setStack (Stack stack) newStack =
    Stack { stack | stack = newStack }


{-| Set a stack's zone -}
setZone : Zone -> Stack -> Stack
setZone newZone (Stack stack) =
    Stack { stack | zone = newZone }


{-| Set a stack's zone index -}
setIndex : Int -> Stack -> Stack
setIndex newIndex (Stack stack) =
    Stack { stack | index = newIndex }


----{ Analysis

{-| Get a stack's internal representation -}
getStack : Stack -> Deck.Stack
getStack (Stack stack) =
    stack.stack


{-| Get a stack's zone -}
getZone : Stack -> Zone
getZone (Stack stack) =
    stack.zone


{-| Get a stack's index -}
getIndex : Stack -> Int
getIndex (Stack stack) =
    stack.index


{-| -}
getSize : Stack -> Int
getSize (Stack stack) =
    Deck.length stack.stack


{-| State if a stack contains any cards -}
isEmpty : Stack -> Bool
isEmpty (Stack stack) =
    Deck.isEmpty stack.stack


------------------------------------------------------------------------------
-- CardInfo
------------------------------------------------------------------------------


{-| Information to identify and locate a card on a Shenzhen board -}
type alias CardInfo =
    { zone       : Zone  -- Zone type the card is in
    , stackIndex : Int   -- Specific zone the card is in
    , cardHeight : Int   -- Number of other cards beneath this card
    , cardDepth  : Int   -- Number of other cards above this card
    , card       : Card  -- Actual card
    }


{-| -}
setState : CardInfo -> Card.State -> CardInfo
setState cardInfo newState =
    { cardInfo | card = (Card.setState newState cardInfo.card) }


------------------------------------------------------------------------------
-- Board
------------------------------------------------------------------------------

{-| Standard Shenzhen board -}
type alias Board =
    { wildZones    : Array Stack     -- zones for holding or dragon discarding
    , gameZones    : Array Stack     -- zones where you shift cards about
    , discardZones : Array Stack     -- zones where you discard cards in order
    , roseZone     : Array Stack     -- zone for the rose card
    , held         : Maybe CardInfo  -- currently selected cards
    , buttons      : Array Button    -- buttons to discard dragons
    }


{-| Supported interactions -}
type Msg
    = CardClick CardInfo
    | CardEnter CardInfo
    | CardLeave CardInfo
    | ButtonPress Button
    | WonGame
    | Nil


type Button = Black | Green | Red


------------------------------------------------------------------------------
-- Board
------------------------------------------------------------------------------

----{ Creation

{-| -}
empty : Board
empty =
    let
        nEmpty n zone =
            Array.repeat n Deck.empty
            |> Array.indexedMap (toStack zone)
    in
        { wildZones = nEmpty 3 Wild
        , gameZones = nEmpty 8 Game
        , discardZones = nEmpty 3 Discard
        , roseZone = nEmpty 1 Rose
        , held = Nothing
        , buttons = [ Black, Green, Red ] |> Array.fromList
        }


{-| -}
deal : Stack -> Board
deal stack =
    let
        deckStacks =
            getStack stack
            |> Deck.dealSplit 8
            |> Array.fromList
            |> Array.indexedMap (toStack Game)
    in
        { empty | gameZones = deckStacks }


----{ Generation

{-| -}
dealGen : Stack -> Random.Generator Board
dealGen (Stack stack) =
    let
        mapForm = \x -> deal (toStack stack.zone stack.index x)
    in
        Random.map mapForm (Deck.shuffle stack.stack)


----{ Modification

{-| Set -}
setBoardZone : Board -> Zone -> Array Stack -> Board
setBoardZone board zone newZone =
    case zone of
        Wild ->
            { board | wildZones = newZone }
        Game ->
            { board | gameZones = newZone }
        Discard ->
            { board | discardZones = newZone }
        Rose ->
            { board | roseZone = newZone }
        Held ->
            Debug.todo "(error) fetchZone: cannot fetch Held zone"


{-| -}
setHeld : Board -> Maybe CardInfo -> Board
setHeld board cardInfo =
    case cardInfo of
        Just ci ->
            { board | held = cardInfo }
            |> paintState Card.Highlighted ci
        Nothing ->
            { board | held = cardInfo }


{-| -}
holdingOnly : Board -> Card -> Bool
holdingOnly board targetCard =
    case board.held of
        Just cardInfo ->
            if (cardInfo.cardDepth == 0) then
                Card.sameCard cardInfo.card targetCard
            else
                False
        _ ->
            False


{-| -}
forceGet : Int -> Array a -> a
forceGet index array =
    case Array.get index array of
        Just item ->
            item
        Nothing ->
            Debug.todo "(error) forceGet: bad index"


{-| -}
top : Stack -> Maybe Deck.Card
top stack =
    Deck.top (getStack stack)


{-| -}
topCI : Stack -> Maybe CardInfo
topCI stack =
    case top stack of
        Nothing ->
            Nothing
        Just card ->
            Just
                { zone = getZone stack
                , stackIndex = getIndex stack
                , cardHeight = Deck.getHeight card
                , cardDepth = Deck.getDepth card
                , card = Deck.getCard (card)
                }


{-| -}
topScan : Board -> List CardInfo
topScan board =
    let
        foldFxn stack listCI =
            (topCI stack)::listCI
        unfilteredCI =
            Array.append (fetchZone Wild board) (fetchZone Game board)
            |> Array.foldl foldFxn []

    in
        unfilteredCI
        |> List.filterMap (\x -> x)


{-| -}
dragonAtTop : Stack -> Card.Suit -> Bool
dragonAtTop stack color =
    case top stack of
        Nothing ->
            False
        Just card ->
            Card.sameCard (Card.new color Card.Dragon) (Deck.getCard card)


{-| -}
attemptDragon : Board -> Card.Suit -> Board
attemptDragon board color =
    let
        validDest =
            let
                evalIndex n =
                    fetchZone Wild board
                    |> forceGet n
                    |> \x -> isEmpty x || dragonAtTop x color
            in
                if evalIndex 0 then
                    Just 0
                else if evalIndex 1 then
                    Just 1
                else if evalIndex 2 then
                    Just 2
                else
                    Nothing

        openCards =
            let
                eval ci = Card.sameCard ci.card (Card.new color Card.Dragon)
            in
                List.filter eval (topScan board)
    in
        case validDest of
            Nothing ->
                board
            Just index ->
                case openCards of
                    c1::c2::c3::c4::[] ->
                        let
                            f ci b = drop b ci Wild index
                        in
                            List.foldl f board openCards
                    _ ->
                        board


----{ Grabbing Cards

{-| Hold a substack if it obeys the rules -}
attemptHold : Board -> CardInfo -> Board
attemptHold board cardInfo =
    if (validInfo board cardInfo) then
        case cardInfo.zone of
            Wild ->
                case fetchStack board cardInfo.zone cardInfo.stackIndex of
                    Just stack ->
                        if ((getSize stack) > 1) then
                            board
                        else
                            setHeld board (Just cardInfo)
                    Nothing ->
                        board
            Game ->
                if (minorContinuous board cardInfo) then
                    case (getHeld board) of
                        Nothing ->
                            setHeld board (Just cardInfo)
                        Just ci ->
                            setHeld board (Just cardInfo)
                            |> paintState Card.Highlighted cardInfo
                            |> paintState Card.Normal ci
                else
                    board
            _ ->
                board
    else
        board


----{ Dropping Cards

{-| -}
setBoardStack : Board -> Zone -> Int -> Stack -> Board
setBoardStack board zoneID index newStack =
    fetchZone zoneID board
    |> Array.set index newStack
    |> setBoardZone board zoneID


{-| -}
rmStackHL : Zone -> Int -> Board -> Board
rmStackHL zoneID index board =
    case fetchStack board zoneID index of
        Nothing ->
            board
        Just stack ->
            getStack stack
            |> Deck.setStackState Card.Normal
            |> setStack stack
            |> setBoardStack board zoneID index


{-| -}
append : Board -> Zone -> Int -> Stack -> Board
append board zoneID index stack =
    case fetchStack board zoneID index of
        Nothing ->
            board
        Just dst ->
            setStack dst (Deck.forceMerge (getStack stack) (getStack dst))
            |> setBoardStack board zoneID index
            |> rmStackHL zoneID index


{-| Checks that it's not the same stack and that the src/dst exist -}
drop : Board -> CardInfo -> Zone -> Int -> Board
drop board cardInfo zoneID index =
    let
        cZone = cardInfo.zone
        cIndex = cardInfo.stackIndex
        cDepth = cardInfo.cardDepth
    in
        if (cZone == zoneID && cIndex == index) then
            board
        else
            let
                srcStack = fetchStack board cZone cIndex
                dstStack = fetchStack board zoneID index
            in
                case (srcStack, dstStack) of
                    (Just src, Just dst) ->
                        let
                            (taken, left) =
                                Deck.forceSplit (getStack src) (cDepth + 1)
                            takenStack =
                                toStack zoneID index taken
                        in
                            setStack src left
                            |> setBoardStack board cZone cIndex
                            |> \b -> append b zoneID index takenStack
                    _ ->
                        board


{-| -}
wildDrop : Board -> Int -> Board
wildDrop board index =
    if (1 == numHeld board) then
        case (fetchStack board Wild index) of
            Nothing ->
                board
            Just stack ->
                if (isEmpty stack) then
                    case board.held of
                        Nothing ->
                            board
                        Just ci ->
                            drop board ci Wild index
                else
                    board
    else
        board


{-| -}
gameDrop : Board -> Int -> Board
gameDrop board index =
    case board.held of
        Nothing ->
            board
        Just ci ->
            let
                newBoard = drop board ci Game index
                checkDepth = ci.cardDepth + 2
            in
                if (minorContinuousB newBoard index checkDepth) then
                    newBoard
                else
                    case (fetchStack board Game index) of
                        Just stack ->
                            if (isEmpty stack) then
                                newBoard
                            else
                                board
                        _ ->
                            board


{-| -}
discardDrop : Board -> Int -> Board
discardDrop board index =
    if (1 == numHeld board) then
        case board.held of
            Nothing ->
                board
            Just ci ->
                let
                    newBoard = drop board ci Discard index
                in
                    if majorContinuous newBoard index then
                        case fetchStack board Discard index of
                            Just stack ->
                                if (isEmpty stack) then
                                    case Card.getFace (ci.card) of
                                        Card.Num 1 ->
                                            newBoard
                                        _ ->
                                            board
                                else
                                    newBoard
                            _ ->
                                board
                    else
                        board
    else
        board


{-| -}
roseDrop : Board -> Int -> Board
roseDrop board _ =
    if (holdingOnly board (Card.new Card.Wild Card.Rose)) then
        case board.held of
            Nothing ->
                board
            Just ci ->
                drop board ci Rose 0
    else
        board


{-| Place held cards on a stack, checking for continuity and self-placing.

-}
attemptDrop : Board -> Zone -> Int -> Board
attemptDrop board targetZone targetStackIndex =
    case board.held of
        Nothing ->
            board
        Just cardInfo ->
            let
                dropFxn =
                    case targetZone of
                        Game ->
                            gameDrop
                        Wild ->
                            wildDrop  -- ad caveat for dragon cards
                        Discard ->
                            discardDrop
                        Rose ->
                            roseDrop
                        _ ->
                            \b i -> b
            in
                dropFxn board targetStackIndex
                |> forgetHeld


----{ Scan Operations

winState : Board -> Bool
winState board =
    let
        helper nList =
            case nList of
                [] ->
                    True
                head::tail ->
                    if (isEmpty head) then
                        helper tail
                    else
                        False
    in
        fetchZone Game board
        |> Array.toList
        |> helper


----{ Fetch Analysis

{-| Retrieve a particular zone from a board -}
fetchZone : Zone -> Board -> Array Stack
fetchZone zone board =
    case zone of
        Wild ->
            board.wildZones
        Game ->
            board.gameZones
        Discard ->
            board.discardZones
        Rose ->
            board.roseZone
        Held ->
            Debug.todo "(error) fetchZone: cannot fetch Held zone"


{-| -}
getHeld : Board -> Maybe CardInfo
getHeld board =
    board.held


{-| -}
fetchStack : Board -> Zone -> Int -> Maybe Stack
fetchStack board zoneID index =
    let
        zone = fetchZone zoneID board
    in
        Array.get index zone


----{ Numeric Analysis

{-| Count the number of cards currently held -}
numHeld : Board -> Int
numHeld board =
    case board.held of
        Nothing ->
            0
        Just cardInfo ->
            1 + cardInfo.cardDepth


----{ Boolean Analysis

{-| State if any cards are being held -}
holdingCards : Board -> Bool
holdingCards board =
    case board.held of
        Nothing ->
            False
        _ ->
            True


{-| -}
validInfo : Board -> CardInfo -> Bool
validInfo board cardInfo =
    True
--    case infoStack board cardInfo of
--        Just stack ->
--            Debug.todo "blep"
--        Nothing ->
--            False


{-| -}
infoStack : Board -> CardInfo -> Maybe Stack
infoStack board cardInfo =
    fetchStack board cardInfo.zone cardInfo.stackIndex


{-| Determine if the substack up to and including the given card.

-}
minorContinuous : Board -> CardInfo -> Bool
minorContinuous board cardInfo =
    case infoStack board cardInfo of
        Just bStack ->
            let
                dStack = getStack bStack
            in
                Deck.minorContinuous dStack (cardInfo.cardDepth + 1)
        _ ->
            False


{-| Determine if the substack up to and including the given card.

-}
minorContinuousB : Board -> Int -> Int -> Bool
minorContinuousB board index depth =
    case fetchStack board Game index of
        Just bStack ->
            let
                dStack = getStack bStack
            in
                Deck.minorContinuous dStack depth
        _ ->
            False


{-| Determine if a discard pile is major continuous -}
majorContinuous : Board -> Int -> Bool
majorContinuous board index =
    case fetchStack board Discard index of
        Just bStack ->
            let
                dStack = getStack bStack
            in
                Deck.majorContinuous dStack (Deck.length dStack)
        _ ->
            False


{-| Determine if two cards are in the same stack.

-}
sameStack : CardInfo -> CardInfo -> Bool
sameStack cardInfo1 cardInfo2 =
    inStack cardInfo1 cardInfo2.zone cardInfo2.stackIndex


{-| Determine if a card is in a particular stack.

-}
inStack : CardInfo -> Zone -> Int -> Bool
inStack cardInfo stackZone stackIndex =
    if (cardInfo.zone == stackZone) then
        if (cardInfo.stackIndex == stackIndex) then
            True
        else
            False
    else
        False


{-| Clear a board's held card info -}
forgetHeld : Board -> Board
forgetHeld board =
    case board.held of
        Nothing ->
            board
        Just ci ->
            { board | held = Nothing }
            |> paintState Card.Normal ci


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------




------------------------------------------------------------------------------
-- Render
------------------------------------------------------------------------------

----{ Board Examination

{-| Get the card info from a single stack -}
getStackInfo : Stack -> List CardInfo
getStackInfo stack =
    if (isEmpty stack) then
        let
            emptyCard =
                { zone = getZone stack
                , stackIndex = getIndex stack
                , cardHeight = 0
                , cardDepth = 0
                , card =
                    Card.new Card.None Card.Blank
                    |> Card.setState Card.Faded
                }
        in
            [ emptyCard ]
    else
        let
            genCardInfo card =
                { zone = getZone stack
                , stackIndex = getIndex stack
                , cardHeight = Deck.getHeight card
                , cardDepth = Deck.getDepth card
                , card = Deck.getCard card
                }
            discardException listCI =
                case getZone stack of
                    Discard ->
                        List.take 1 listCI
                    _ ->
                        listCI
        in
            (getStack stack) |> Deck.toList |> List.map genCardInfo
            |> discardException


{-| Get the card info from all stacks in a zone -}
getZoneInfo : Array Stack -> List CardInfo
getZoneInfo stacks =
    Array.map getStackInfo stacks |> Array.toList |> List.concat


{-| Get the card info of all stacks in every zone -}
getCardInfo : Board -> List CardInfo
getCardInfo board =
    let
        allCards =
            [ getZoneInfo board.wildZones
            , getZoneInfo board.gameZones
            , getZoneInfo board.discardZones
            , getZoneInfo board.roseZone
            ]
    in
        List.concat allCards


{-| Calculate a card's position in a rendering field -}
calcFieldPos : CardInfo -> (Int, Int)
calcFieldPos cardInfo =
    let
        rowOffset =
            if (cardInfo.zone == Game) then
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
                    case cardInfo.zone of
                        Wild ->
                            0
                        Rose ->
                            4 * Config.layout.stackSpacing
                        Discard ->
                            5 * Config.layout.stackSpacing
                        Game ->
                            0
                        _ ->
                            Debug.todo "(error) calcFieldPos: bad zone"
                bonus =
                    cardInfo.stackIndex * Config.layout.stackSpacing
            in
                base + bonus
    in
        (rowOffset + 1, colOffset + 1)


----{ Field Setup

{-| Place a single card in a rendering field -}
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


{-| -}
collageButton : Button -> Collage msg
collageButton button =
    let
        color =
            case button of
                Black ->
                    Color.black
                Green ->
                    Color.green
                Red ->
                    Color.darkRed
        style =
            Collage.solid Collage.thick (Collage.uniform Color.black)
            |> Tuple.pair (Collage.uniform Color.white)
        text =
            case button of
                Black ->
                    "B"
                Green ->
                    "G"
                Red ->
                    "R"
        collageText =
            Collage.Text.fromString text
            |> Collage.Text.size 32
            |> Collage.Text.weight Collage.Text.SemiBold
            |> Collage.Text.color color
            |> Collage.rendered
    in
        Collage.group
            [ collageText, Collage.circle 32 |> Collage.styled style ]


dummyCard : CardInfo
dummyCard =
    { zone = Discard
    , stackIndex = 0
    , cardHeight = 0
    , cardDepth = 0
    , card = Card.new Card.None Card.Blank
    }


{-| Place a single button in a rendering field -}
fInsertButton : Button -> Int -> Field Msg CardInfo -> Field Msg CardInfo
fInsertButton button index field =
    let
        colOffset = 3 * Config.layout.stackSpacing
        rowOffset = index * Config.layout.stackOffset
    in
        let
            fieldPos =
                (rowOffset + 1, colOffset)
            eventImage =
                collageButton button
                |> Collage.Events.onClick (ButtonPress button)
            anchor =
                Collage.Layout.base
            node =
                Field.toNode fieldPos eventImage dummyCard anchor
        in
            Field.set node field


{-| Place the elements a board in a rendering field -}
toField : Board -> Field Msg CardInfo
toField board =
    let
        blankField = Field.new Config.dims.fieldDims Config.layout.baseUnit
    in
        case blankField of
            Nothing ->
                Debug.todo "(error) toField: bad dims"
            Just field ->
                List.foldl fInsertCard field (getCardInfo board)
                |> fInsertButton Black 0
                |> fInsertButton Green 1
                |> fInsertButton Red 2



----{ Export

{-| Export a visualization of the board in HTML format -}
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


------------------------------------------------------------------------------
-- CardInfo
------------------------------------------------------------------------------

{-| -}
paintState : Card.State -> CardInfo -> Board -> Board
paintState state cardInfo board =
    let
        zoneTag = cardInfo.zone
        index = cardInfo.stackIndex
        depth = cardInfo.cardDepth
        zoneArray = fetchZone zoneTag board
    in
        case Array.get index zoneArray of
            Nothing ->
                board
            Just (Stack stack) ->
                let
                    newStack =
                        Deck.setGroupState state depth (stack.stack)
                        |> \x -> { stack | stack = x }
                        |> Stack
                    newZone =
                        Array.set index newStack zoneArray
                in
                    setBoardZone board zoneTag newZone


------------------------------------------------------------------------------
-- Demo & Debug
------------------------------------------------------------------------------

{-| Generate a card (deck wrapped) from a string -}
qGenC : String -> Deck.Card
qGenC cardStr =
    if (String.length cardStr == 2) then
        let
            suit =
                case (String.slice 0 1 cardStr) of
                    "B" ->
                        Card.Black
                    "G" ->
                        Card.Green
                    "R" ->
                        Card.Red
                    "W" ->
                        Card.Wild
                    "N" ->
                        Card.None
                    _ ->
                        Debug.todo "(error) qGenC: invalid suit"
            face =
                case (String.slice 1 2 cardStr) of
                    "1" ->
                        Card.Num 1
                    "2" ->
                        Card.Num 2
                    "3" ->
                        Card.Num 3
                    "4" ->
                        Card.Num 4
                    "5" ->
                        Card.Num 5
                    "6" ->
                        Card.Num 6
                    "7" ->
                        Card.Num 7
                    "8" ->
                        Card.Num 8
                    "9" ->
                        Card.Num 9
                    "d" ->
                        Card.Dragon
                    "r" ->
                        Card.Rose
                    "b" ->
                        Card.Blank
                    _ ->
                        Debug.todo "(error) qGenC: invalid face value"
        in
            Deck.asCard suit face
    else
        Debug.todo "(error) qGenC: invalid string length"


{-| Generate a stack from a string -}
qGenS : String -> Deck.Stack
qGenS stackStr =
    if (stackStr == "") then
        Deck.empty
    else
        let
            cardStr = String.slice 0 2 stackStr
        in
            String.dropLeft 2 stackStr
            |> qGenS
            |> Deck.prepend (qGenC cardStr)


{-| A test board for a winning setup -}
testBoardWin : Board
testBoardWin =
    let
        wildZones =
            Array.fromList
                [ qGenS "GdGdGdGd" |> toStack Wild 0
                , qGenS "BdBdBdBd" |> toStack Wild 1
                , qGenS "RdRdRdRd" |> toStack Wild 2
                ]
        gameZones =
            Array.fromList
                [ qGenS "R9" |> toStack Game 0
                , qGenS "R2" |> toStack Game 1
                , qGenS "R3" |> toStack Game 2
                , qGenS "R4" |> toStack Game 3
                , qGenS "R5" |> toStack Game 4
                , qGenS "R6" |> toStack Game 5
                , qGenS "R7" |> toStack Game 6
                , qGenS "R8" |> toStack Game 7
                ]
        discardZones =
            Array.fromList
                [ qGenS "B9B8B7B6B5B4B3B2B1" |> toStack Discard 0
                , qGenS "G9G8G7G6G5G4G3G2G1" |> toStack Discard 1
                , qGenS "R1" |> toStack Discard 2
                ]
        roseZone =
            Array.fromList [ qGenS "Wr" |> toStack Rose 0 ]
        held =
            Nothing
        buttons =
            Array.fromList [ Black, Green, Red ]
    in
        { wildZones = wildZones
        , gameZones = gameZones
        , discardZones = discardZones
        , roseZone = roseZone
        , held = held
        , buttons = buttons
        }


{-| A test board for dragon-card operations -}
testBoardDragons : Board
testBoardDragons =
    let
        wildZones =
            Array.fromList
                [ qGenS "Gd" |> toStack Wild 0
                , qGenS "" |> toStack Wild 1
                , qGenS "Rd" |> toStack Wild 2
                ]
        gameZones =
            Array.fromList
                [ qGenS "GdR9" |> toStack Game 0
                , qGenS "GdR2" |> toStack Game 1
                , qGenS "GdBdR3" |> toStack Game 2
                , qGenS "BdR4" |> toStack Game 3
                , qGenS "BdBdR5" |> toStack Game 4
                , qGenS "RdR6" |> toStack Game 5
                , qGenS "RdR7" |> toStack Game 6
                , qGenS "RdR8" |> toStack Game 7
                ]
        discardZones =
            Array.fromList
                [ qGenS "B9B8B7B6B5B4B3B2B1" |> toStack Discard 0
                , qGenS "G9G8G7G6G5G4G3G2G1" |> toStack Discard 1
                , qGenS "R1" |> toStack Discard 2
                ]
        roseZone =
            Array.fromList [ qGenS "Wr" |> toStack Rose 0 ]
        held =
            Nothing
        buttons =
            Array.fromList [ Black, Green, Red ]
    in
        { wildZones = wildZones
        , gameZones = gameZones
        , discardZones = discardZones
        , roseZone = roseZone
        , held = held
        , buttons = buttons
        }
