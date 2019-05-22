module Shenzhen.Board exposing (..)
{-| Playing field for Shenzhen solitaire -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Structures
import Array exposing (Array)
import Shenzhen.Deck as Deck exposing (Stack)
import Shenzhen.Card as Card exposing (Card)
import Extended.List as XList

----{ Graphics
import Field exposing (Field)

----{
import Html exposing (Html)


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| A Shenzhen board configuration, consisting of 3 wildcard slots, 8
interactive slots, 3 discard slots, 1 rose slot, and 3 dragon-collapsing
buttons.

-}
type alias Board =
    { wildZones    : Array Stack  -- add metadata for zone names?
    , gameZones    : Array Stack
    , discardZones : Array Stack
    , roseZone     : Stack
    --, addButtonsHerePlzKThx
    }


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| -}
deal : Stack -> Board
deal stack =
    let
        stacks = XList.dealSplit 8 stack |> Array.fromList
    in
        { wildZones = Array.repeat 3 Deck.empty
        , gameZones = stacks
        , discardZones = Array.repeat 3 Deck.empty
        , roseZone = Deck.empty
        }


------------------------------------------------------------------------------
-- Rendering
------------------------------------------------------------------------------

package : Card -> msg -> data -> Field.NodeTup msg data
package _ _ =
    Debug.todo "implement a thing to bundle events, etc. for field to use"

render : Board -> Html msg
render board =
    Debug.todo "implement (and add events)"

