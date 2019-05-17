module Board exposing (..)
{-| A Shenzen board -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

import Deck exposing (Stack)
import Array exposing (Array)


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

-- 3 buttons
-- 3 wildcard slots
-- 1 rose slot
-- 3 suit slots
-- 8 stack slots

{-| -}
type SlotSpec
    = WildActive
    | WildSpent
    | Flower
    | Discard
    | Stack

{-| -}
type alias Slot =
    { spec     : SlotSpec
    , contents : Stack
    , size     : Int
    }

{-| [3 wild | 1 rose | 3 discard | 8 stack] -}
type alias Board = Array Slot  -- 18 slots


------------------------------------------------------------------------------
--
------------------------------------------------------------------------------


------------------------------------------------------------------------------
--
------------------------------------------------------------------------------

{-| -}
toSlot : SlotSpec -> Stack -> Slot
toSlot spec stack =
    Debug.todo "implement"

{-| -}
init : Board
init =
    Debug.todo "implement"

{-| Deal a deck out onto a table (does not shuffle the deck) -}
deal : Stack -> Board
deal deck =
    Debug.todo "implement"

{-| Automatically move cards up if possible, and detect dragons -}
sweep : Board -> Board
sweep board =
    Debug.todo "implement"
