module Main exposing (main)
{-| Shenzhen Solitaire in Elm -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Core
import Browser
import Html exposing (Html)
import Html.Attributes

----{ Structures
import Shenzhen.Board as Board exposing (Board, Stack, CardInfo)
import Shenzhen.Card as Card exposing (State(..))

----{ Events
import Browser.Events
import Json.Decode as Decode exposing (Decoder)

----{ Randomness
import Random

----{ Time
import Time exposing (Posix)
import Clock exposing (Clock)  -- Clock.toStringHMS


------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------

tickInterval : Int
tickInterval = Clock.second // 5


------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------

{-| -}
type alias Flags = ()

{-| Initializer -}
init : Flags -> (Model, Cmd Msg)
init () =
    (initModel, Cmd.none)


{-| Shenzhen Solitaire in Elm -}
main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


------------------------------------------------------------------------------
-- Model
------------------------------------------------------------------------------

{-| -}
type alias Model =
    { status : GameState    -- Gamestate
    , board  : Board        -- Current state of the game board
    , held   : Maybe Stack  -- Any held cards
    , record : GameHistory  -- Prior win/loss count
    , clock  : Clock        -- Duration the current round has been running
    }


{-| -}
type alias GameHistory =
    { wins   : Int
    , losses : Int
    }


{-| -}
type GameState
    = Inactive
    | Active
    | Paused
    | Won
    | Lost


{-| -}
initModel : Model
initModel =
    { status = Inactive
    , board = Board.empty
    , held = Nothing
    , record = { wins = 0, losses = 0 }
    , clock = Clock.fromInt 0
    }


{-| Add a loss to the game history -}
addLoss : GameHistory -> GameHistory
addLoss record =
    { record | losses = record.losses + 1 }


{-| Add a win to the game history -}
addWin : GameHistory -> GameHistory
addWin record =
    { record | wins = record.wins + 1 }

{-| -}
setState : GameState -> Model -> Model
setState newState model =
    { model | status = newState }


{-| -}
setBoard : Model -> Board -> Model
setBoard model board =
    { model | board = board }


------------------------------------------------------------------------------
-- Controller
------------------------------------------------------------------------------

type Msg
    = BoardMsg Board.Msg
    | BoardGen Board
    | NewGame GameState
    | Tick Posix
    | TogglePause
    | Nil
    | DebugLoadBoard Board


----{ Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onKeyDown (keyDecoder model)
        , Time.every (toFloat tickInterval) Tick
        ]


keyDecoder : Model -> Decoder Msg
keyDecoder model =
    let
        decoder key =
            if (key == "Escape" || key == " ") then
                TogglePause
            else if (key == "r" || key == "R") then
                NewGame model.status
            else if (key == "1") then
                DebugLoadBoard Board.testBoardWin
            else if (key == "2") then
                DebugLoadBoard Board.testBoardDragons
            else if (key == "3") then
                Debug.todo "debug action"
            else if (key == "4") then
                Debug.todo "debug action"
            else if (key == "5") then
                Debug.todo "debug action"
            else if (key == "6") then
                Debug.todo "debug action"
            else if (key == "7") then
                Debug.todo "debug action"
            else if (key == "8") then
                Debug.todo "debug action"
            else if (key == "9") then
                Debug.todo "debug action"
            else if (key == "0") then
                Debug.todo "debug action"
            else
                Nil
    in
        Decode.map decoder (Decode.field "key" Decode.string)


----{ Messages

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        BoardMsg (Board.CardClick cardInfo) ->
            handleCardClick model cardInfo
        BoardMsg (Board.ButtonPress button) ->
            handleButtonPress model button
        BoardGen board ->
            handleBoardGen model board
        DebugLoadBoard board ->
            handleDebugLoadBoard model board
        NewGame status ->
            handleNewGame model status
        Tick posix ->
            handleTick model posix
        TogglePause ->
            handleTogglePause model
        _ ->
            (model, Cmd.none)


{-| Shenzhen.Board.CardClick < Shenzhen.Board.CardInfo > -}
handleCardClick : Model -> CardInfo -> (Model, Cmd Msg)
handleCardClick model cardInfo =
    let
        state = Card.Highlighted
        zone = cardInfo.zone
        index = cardInfo.stackIndex
        depth = cardInfo.cardDepth
        board = model.board
    in
        let
            newModel =
                if (Board.holdingCards board) then
                    Board.attemptDrop board zone index
                    |> setBoard model
                else
                    Board.attemptHold board cardInfo
                    |> setBoard model
        in
            (newModel, Cmd.none)


{-| -}
handleButtonPress : Model -> Board.Button -> (Model, Cmd Msg)
handleButtonPress model button =
    let
        newBoard =
            case button of
                Board.Black ->
                    Board.attemptDragon model.board Card.Black
                Board.Green ->
                    Board.attemptDragon model.board Card.Green
                Board.Red ->
                    Board.attemptDragon model.board Card.Red
    in
        Tuple.pair { model | board = newBoard } Cmd.none


{-| ... -}
handleBoardGen : Model -> Board -> (Model, Cmd Msg)
handleBoardGen model board =
    let
        newModel = setState Active { model | board = board }
    in
        (newModel, Cmd.none)


{-| DebugLoadBoard < Shenzhen.Board.Board > -}
handleDebugLoadBoard model board =
    let
        newModel = setState Active { initModel | board = board }
    in
        (newModel, Cmd.none)


{-| NewGame < GameState > -}
handleNewGame : Model -> GameState -> (Model, Cmd Msg)
handleNewGame model status =
    let
        cmd =
            Random.generate BoardGen (Board.dealGen Board.fullDeck)
        newModel =
            case status of
                Won ->
                    { model | record = addWin model.record }
                Inactive ->
                    model
                _ ->
                    { model | record = addLoss model.record }
    in
        (newModel, cmd)


{-| Tick < Time.Posix > -}
handleTick : Model -> Posix -> (Model, Cmd Msg)
handleTick model _ =
    case model.status of
        Active ->
            if Board.winState model.board then
                (setState Won model, Cmd.none)
            else
                let
                    newClock = Clock.advance model.clock tickInterval
                in
                    --Board.scan
                    Tuple.pair { model | clock = newClock } Cmd.none
        Inactive ->
            update (NewGame Inactive) model
        _ ->
            (model, Cmd.none)


{-| TogglePause -}
handleTogglePause : Model -> (Model, Cmd Msg)
handleTogglePause model =
    case model.status of
        Active ->
            Tuple.pair { model | status = Paused } Cmd.none
        Paused ->
            Tuple.pair { model | status = Active } Cmd.none
        _ ->
            (model, Cmd.none)


------------------------------------------------------------------------------
-- View
------------------------------------------------------------------------------

{-| -}
view : Model -> Html Msg
view model =
    let
        status = model.status
        board = model.board
        record = model.record
        clock = model.clock
    in
        case status of
            Inactive ->
                Board.render board
                |> Html.map BoardMsg
            Active ->
                Board.render board
                |> Html.map BoardMsg
            Paused ->
                Html.div [ Html.Attributes.align "center" ]
                    [ Html.h1 [] [ Html.text "Game Paused" ]
                    , Html.h2 [] [ Html.text ("Round Duration: " ++ Clock.toStringHMS clock) ]
                    , Html.h2 [] [ Html.text <| ("Wins: " ++ String.fromInt model.record.wins) ++ " // Losses: " ++ (String.fromInt model.record.losses) ]
                    , Html.strong [] [ Html.text "Rules:" ]
                    , Html.div [] [ Html.text "Shenzhen Solitaire is played in a similar manner to normal Solitaire, with slight variations." ]
                    , Html.div [] [ Html.text "First, there are only three suits, and cards only range from 1 to 9 (inclusive)." ]
                    , Html.div [] [ Html.text "Second, there is a rose card, which goes into the leftmost of the upper-right slots." ]
                    , Html.div [] [ Html.text "Third, there are dragon cards, which are discarded all at once by pressing the correseponding button when all four of a suit are uncovered." ]
                    , Html.div [] [ Html.text "Fourth, there are wild slots in the upper left, which can hold any single card (unless dragons have been discarded into them)." ]
                    , Html.br [] []
                    , Html.strong [] [ Html.text "Controls:" ]
                    , Html.div [] [ Html.text "Left click to move cards." ]
                    , Html.div [] [ Html.text "Use 'R' to start a new game." ]
                    , Html.div [] [ Html.text "Press 'SPACE' or 'ESC' to pause the game." ]
                    , Html.div [] [ Html.text "Use '1' through '0' for debug actions." ]
                    ]
            Won ->
                Html.div [ Html.Attributes.align "center" ]
                    [ Html.h1 [] [ Html.text "Congratulations!" ]
                    , Html.h2 [] [ Html.text "You've won!" ]
                    , Html.div [] [ Html.text "Press 'R' for a new game." ]
                    ]
            Lost ->
                Html.div [ Html.Attributes.align "center" ]
                    [ Html.h1 [] [ Html.text "Game Over!" ]
                    , Html.h2 [] [ Html.text "Sorry :/" ]
                    , Html.div [] [ Html.text "Press 'R' for a new game." ]
                    ]
