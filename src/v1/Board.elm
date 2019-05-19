module Board exposing (..)
{-| A Shenzen board -}


----- so the board will have slots
----- these will have anchor nodes for collages
-----

------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

import Collage
import Collage.Layout

import Html exposing (Html)


------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------

----{ Config

{-| Horizontal distance between adjacent  -}
spacerWidth : Float
spacerWidth = 10

{-| Vertical distance between card slots -}


----{ Definitions



------------------------------------------------------------------------------
-- Model
------------------------------------------------------------------------------

{-| -}
type alias Board = ()


------------------------------------------------------------------------------
-- Structure
------------------------------------------------------------------------------

{-| -}
spacer : Collage Msg
spacer =
    let
        width = 10
        height = 0
    in
        Collage.Layout.spacer


------------------------------------------------------------------------------
-- Export
------------------------------------------------------------------------------

{-| -}
type Msg = Nil

{-| -}
toCollage : Board -> Collage Msg
toCollage board =
    Debug.todo "implement"

{-| -}
toHtml : Board -> Html Msg
toHtml board =
    Debug.todo "implement"


------------------------------------------------------------------------------
-- Update
------------------------------------------------------------------------------

{-| -}
update : Msg -> Board -> (Model, Cmd Msg)
update msg model =
    Debug.todo "implement"
