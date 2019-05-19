module Grid exposing (Grid)
{-| A two-dimensional grid in Elm -}

------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

import Dict exposing (Dict)


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

{-| Grid dimensions -}
type alias Dimensions =
    { rows : Int
    , cols : Int
    }

{-| A two-dimensional grid -}
type alias Grid a =
    Grid_
        { dims : Dimensions
        , grid : Dict Int (Dict Int (Maybe a))
        }
