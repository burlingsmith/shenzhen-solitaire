module Main exposing (main)
{-| -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Core
import Html exposing (Html)
import Html.Events
import Time exposing (Posix)
import Browser
import Browser.Events
import Json.Decode as Decode exposing (Decoder)
import Random

----{ Local
import Menu
import Clock exposing (Clock)
import Deck exposing (Stack)
import Board exposing (Board)


------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------

{-| Configuration flags -}
type alias Flags = ()

{-| Configure the session -}
init : Flags -> (Model, Cmd Msg)
init () =
    (initModel, Cmd.none)

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
type GameState
    = Inactive  -- The game is awaiting a reset
    | Active    -- The user is currently playing a game
    | Paused    -- The user has paused the game
    | Won       -- The user has won a game
    | Lost      -- The user has lost a game

{-| -}
type alias Model =
    { wouldBeAction : String
    , timeElapsed : Clock
    , gameState : GameState
    , wins : Int
    , losses : Int
    , deck : Stack  -- temp
    , board : Board
    }

{-| Initial model -}
initModel : Model
initModel =
    { wouldBeAction = "Initialized model"  -- temp field
    , timeElapsed = Clock.fromInt 0
    , gameState = Inactive
    , wins = 0
    , losses = 0
    , deck = []  -- temp field
    , board = Board.init
    }

{-| Reset the model after a win -}
winModel : Model -> Model
winModel model =
    let
        wins = model.wins + 1
    in
        { initModel | wins = wins }

{-| Reset the model after a loss -}
lossModel : Model -> Model
lossModel model =
    let
        losses = model.losses + 1
    in
        { initModel | losses = losses }


------------------------------------------------------------------------------
-- Update
------------------------------------------------------------------------------

{-| Event messages -}
type Msg
    = NewGame
    | Tick
    | TogglePause
    | Deal Stack
    | Nil


----{ Decoders

{-| Determine which key was pressed -}
keyDecoder : Decoder Msg
keyDecoder =
    Decode.map keyDecoder_ (Decode.field "key" Decode.string)

keyDecoder_ : String -> Msg
keyDecoder_ key =
    if (key == "Escape" || key == " ") then
        TogglePause
    else if (key == "r" || key == "R") then
        NewGame
    else
        Nil


----{ Subscriptions

{-| Generate event messages -}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onKeyDown keyDecoder
        , Time.every (toFloat Clock.second) (\_ -> Tick)
        ]


----{ Controller

tmpFxn : Stack -> String
tmpFxn stack =
    case stack of
        [] ->
            "Empty"
        card::_ ->
            case card.value of
                Deck.Dragon ->
                    "Dragon"
                Deck.Flower ->
                    "Flower"
                Deck.Num n ->
                    n |> String.fromInt

{-| Update the model in response to event messages -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewGame ->
            handleNewGame model
        Deal cards ->
            handleDeal model cards
        TogglePause ->
            handleTogglePause model
        Tick ->
            handleTick model
        _ ->
            (model, Cmd.none)


----{ Message Handlers

{-| 'NewGame' message -}
handleNewGame : Model -> (Model, Cmd Msg)
handleNewGame model =
    case model.gameState of
        Won ->
            (winModel model, Cmd.none)
        Lost ->
            (lossModel model, Cmd.none)
        _ ->
            (initModel, Cmd.none)

handleDeal : Model -> Stack -> (Model, Cmd Msg)
handleDeal model cards =
    let
        newBoard = Board.deal cards
    in
        Debug.todo "implement"

{-| 'TogglePause' message -}
handleTogglePause : Model -> (Model, Cmd Msg)
handleTogglePause model =
    let
        newGS = handleTogglePause_ model.gameState
        newModel = { model | gameState = newGS }
    in
        (newModel, Cmd.none)

handleTogglePause_ : GameState -> GameState
handleTogglePause_ oldGS =
    case oldGS of
        Won     -> Inactive
        Lost    -> Inactive
        Paused  -> Active
        _       -> Paused

{-| 'Tick < Time.Posix >' message -}
handleTick : Model -> (Model, Cmd Msg)
handleTick model =  -- placeholder
    case model.gameState of
        Inactive ->
            (model, Random.generate Deal (Deck.new |> Deck.shuffle))
        Paused ->
            -- temp
            ({model | wouldBeAction = tmpFxn model.deck}, Cmd.none)
        _ ->
            let
                newTime = Clock.advance model.timeElapsed Clock.second
                newModel = { model | timeElapsed = newTime }
            in
                (newModel, Cmd.none)


------------------------------------------------------------------------------
-- View
------------------------------------------------------------------------------

{-| Produce a string of the time elapsed in the current game.

    pGameClock 607 == "00:10:07"
-}
pGameClock : Clock -> String
pGameClock elapsedTime =
    let
        maxTime = 99 * Clock.hour + 59 * (Clock.minute + Clock.second)
    in
        if (elapsedTime.abs > maxTime) then
            "99:59:59"
        else
            let
                f x = x |> String.fromInt |> String.padLeft 2 '0'
                hours = f elapsedTime.h
                minutes = f elapsedTime.min
                seconds = f elapsedTime.sec
            in
                String.concat [ hours, ":", minutes, ":", seconds ]

rGameClock : Clock -> Html Msg
rGameClock elapsedTime =
    let
        clockStr = pGameClock elapsedTime
    in
        Html.div []
            [ Html.div [ Html.Events.onClick NewGame ] [ Html.text clockStr ]
            ]

{-| Render the model -}
view : Model -> Html Msg
view model =
    case model.gameState of
        Paused ->
            viewMenu model
        Won ->
            Debug.todo "endgame view (win)"
        Lost ->
            Debug.todo "endgame view (loss)"
        _ ->
            viewBoard model

{-| Render the board -}
viewBoard : Model -> Html Msg
viewBoard model =
    Html.div []
        [ Html.text model.wouldBeAction
        , rGameClock model.timeElapsed
        ]

{-| Render the pause menu -}
viewMenu : Model -> Html Msg
viewMenu model =  -- todo
    Html.text "pause menu is open"
