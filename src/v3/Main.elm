module Main exposing (..)
{-| Module for debugging only -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Random shit
import Html exposing (Html)
import Html.Events
import Time exposing (Posix)
import Browser
import Browser.Events
import Json.Decode as Decode exposing (Decoder)
import Random
import Platform.Sub
import Collage exposing (Collage)
import Collage.Render
import Collage.Events
import Collage.Layout
import Color

----{ Stuff what is being tested
import Shenzen.Card as Card exposing (Card, Suit, Face)
import Field exposing (Field)

------------------------------------------------------------------------------
-- Boilerplate
------------------------------------------------------------------------------

type alias Flags = ()

main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

init : Flags -> (Model, Cmd Msg)
init () =
    (initModel, Cmd.none)

view : Model -> Html Msg
view model =
    Field.render pFxn model
    |> Collage.Layout.center
    |> Collage.Render.svg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


------------------------------------------------------------------------------
-- Testing
------------------------------------------------------------------------------

type Msg = ClickedCard

type alias Data = Int

type alias Index = (Int, Int)

type alias Model = Field Msg Data

pFxn : Field.Node Msg Data -> Int
pFxn node =
    case Field.nodeData node of
        Nothing ->
            0
        Just faceValue ->
            faceValue

initModel : Model
initModel =
    let
        f pos suit val =
            let
                card =
                    Card.new suit (Card.Num val)
                    |> Card.toCollage
                    |> Collage.scale 0.5
            in
                (pos, card, val)
        cards =
            [ f (1, 1) Card.Red 1
            , f (1, 2) Card.Red 2
            , f (1, 3) Card.Red 3
            , f (2, 1) Card.Black 4
            , f (2, 2) Card.Black 5
            , f (2, 3) Card.Black 6
            , f (3, 1) Card.Green 7
            , f (3, 2) Card.Green 8
            , f (3, 3) Card.Green 9
            ]
    in
        case Field.fromList (3, 3) 100 cards of
            Just model ->
                model
            Nothing ->
                Debug.todo "initModel: field generation failed"


---- have msgs in modules that you can call like (CardModule.SomeMsg Params) ?
    -----
