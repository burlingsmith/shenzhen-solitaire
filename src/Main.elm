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
    , board = Debug.todo "Board.new"
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


------------------------------------------------------------------------------
-- Controller
------------------------------------------------------------------------------

type Msg
    = Tick Posix
    | TogglePause
    | NewGame GameState
    | Deal Stack
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


{-| Deal < Shenzhen.Deck.Stack > -}
handleDeal : Model -> Stack -> (Model, Cmd Msg)
handleDeal model deck =
    Tuple.pair { model | board = Board.deal deck } Cmd.none


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
    Debug.todo "implement"
