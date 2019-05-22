module Clock exposing
    ( Clock
    , millisecond, second, minute, hour, day
    , fromInt
    , advance
    )
{-| -}


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

{-| Represent the components of a duration seperately -}
type alias Clock =
    { ms   : Int  -- milliseconds
    , sec  : Int  -- seconds
    , min  : Int  -- minutes
    , hour : Int  -- hours
    , day  : Int  -- days
    , abs  : Int  -- total number of milliseconds
    }


------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------

{-| The smallest unit of time supported by Elm -}
millisecond : Int
millisecond = 1

{-| One-thousand milliseconds -}
second : Int
second = 1000

{-| Sixty seconds -}
minute : Int
minute = 60000

{-| Sixty minutes -}
hour : Int
hour = 3600000

{-| Twenty-four hours -}
day : Int
day = 86400000


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| Represent a number of milliseconds as a clock -}
fromInt : Int -> Clock
fromInt abs =
    let
        getClockValue a b = (modBy a abs) // b
    in
        { ms = modBy second abs
        , sec = getClockValue minute second
        , min = getClockValue hour minute
        , hour = getClockValue day hour
        , day = abs // day
        , abs = abs
        }


------------------------------------------------------------------------------
-- Modification
------------------------------------------------------------------------------

{-| Advance a clock by a given number of milliseconds -}
advance : Clock -> Int -> Clock
advance clock time =
    fromInt (clock.abs + time)
