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
import Color

----{ Stuff what is being tested
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
    Field.compose model
    |> Collage.Render.svg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ClickedPoint pt ->
            clickPoint model pt
        _ ->
            Debug.todo "implement"

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


------------------------------------------------------------------------------
-- Testing
------------------------------------------------------------------------------

type Msg
    = ClickedPoint (Int, Int)  -- row and column of the point clicked
    | MouseEnter (Int, Int)
    | MouseLeave (Int, Int)
    | Nil

type Status = Blank | Light

type alias Model = Field Msg Status

blankPoint : (Int, Int) -> Collage Msg
blankPoint pt =
    Collage.circle 5
    |> Collage.filled (Collage.uniform Color.red)
    |> Collage.Events.onClick (ClickedPoint pt)

lightPoint : (Int, Int) -> Collage Msg
lightPoint pt =
    Collage.circle 7
    |> Collage.filled (Collage.uniform Color.green)
    |> Collage.Events.onClick (ClickedPoint pt)

initModel : Model
initModel =
    let
        lf pt = (pt, lightPoint pt, Light)
        bf pt = (pt, blankPoint pt, Blank)
        points =
            [ lf (1, 1)
            , lf (1, 7)
            , lf (7, 1)
            , lf (7, 7)
            , bf (4, 3)
            , bf (5, 2)
            , bf (5, 4)
            , bf (4, 5)
            , bf (5, 6)
            ]
    in
        Field.fromList (7, 7) 15 points

clickPoint : Model -> (Int, Int) -> (Model, Cmd Msg)
clickPoint model pt =
    case Field.get model pt of
        Nothing ->
            (model, Cmd.none)
        Just (_, status) ->
            case status of
                Blank ->
                    (Field.clear model pt, Cmd.none)
                Light ->
                    (Field.set model pt (blankPoint pt) Blank, Cmd.none)













--- node precidnce
--- overlap
