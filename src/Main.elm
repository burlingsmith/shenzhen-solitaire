module Main exposing (main)
{-| Shenzhen Solitaire in Elm -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Core
import Browser
import Html exposing (Html)

----{ Structures
import Shenzhen.Board as Board exposing (Board)
import Shenzhen.Deck as Deck exposing (Stack)

----{ Events
import Browser.Events
import Json.Decode as Decode exposing (Decoder)

----{ Randomness
import Random

----{ Time
import Time exposing (Posix)
import Clock exposing (Clock)


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


------------------------------------------------------------------------------
-- Controller
------------------------------------------------------------------------------

type Msg
    = BoardMsg Board.Msg
    | Deal Stack
    | NewGame GameState
    | Tick Posix
    | TogglePause
    | Nil


----{ Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onKeyDown (keyDecoder model)
        , Time.every (toFloat Clock.second) Tick
        ]


keyDecoder : Model -> Decoder Msg
keyDecoder model =
    let
        decoder key =
            if (key == "Escape" || key == " ") then
                TogglePause
            else if (key == "r" || key == "R") then
                NewGame model.status
            else
                Nil
    in
        Decode.map decoder (Decode.field "key" Decode.string)


----{ Messages

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        BoardMsg boardMsg ->
            handleBoardMsg model boardMsg
        Deal deck ->
            handleDeal model deck
        NewGame status ->
            handleNewGame model status
        Tick posix ->
            handleTick model posix
        TogglePause ->
            handleTogglePause model
        _ ->
            (model, Cmd.none)

{-| Board.CardClick -}
handleBoardMsg : Model -> Board.Msg -> (Model, Cmd Msg)
handleBoardMsg model boardMsg =
    let
        (newBoard, cmd) = Board.update boardMsg model.board
    in
        Debug.todo "implement"

{-| Deal < Shenzhen.Deck.Stack > -}
handleDeal : Model -> Stack -> (Model, Cmd Msg)
handleDeal model deck =
    let
        newModel =
            { model | board = Board.deal deck }
            |> setState Active
    in
        (newModel, Cmd.none)


{-| NewGame < GameState > -}
handleNewGame : Model -> GameState -> (Model, Cmd Msg)
handleNewGame model status =
    let
        newModel =
            case status of
                Won ->
                    { model | record = addWin model.record }
                Inactive ->
                    model
                _ ->
                    { model | record = addLoss model.record }
        dealCmd =
            Random.generate Deal (Deck.shuffle Deck.full)
    in
        (newModel, dealCmd)


{-| Tick < Time.Posix > -}
handleTick : Model -> Posix -> (Model, Cmd Msg)
handleTick model _ =
    case model.status of
        Active ->
            let
                newClock = Clock.advance model.clock Clock.second
            in
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
                --Debug.todo "render blank board w/ clock"
                Board.render board
                |> Html.map BoardMsg
            Active ->
                --Debug.todo "render active board w/ clock"
                Board.render board
                |> Html.map BoardMsg
            Paused ->
                --Debug.todo "render pause menu"
                Html.text "Implement paused view"
            Won ->
                --Debug.todo "render won game screen"
                Html.text "Implement won view"
            Lost ->
                --Debug.todo "render lost game screen"
                Html.text "Implement lost view"
