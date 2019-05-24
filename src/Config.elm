module Config exposing (color, dims, layout, text)
{-| -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

import Color exposing (Color)


------------------------------------------------------------------------------
-- Unit Aliases
------------------------------------------------------------------------------

type alias FontSize = Int
type alias Pixels = Float


------------------------------------------------------------------------------
-- Color Scheme
------------------------------------------------------------------------------

type alias ColorConfig =
    { boardBack  : Color
    , cardBack   : Color
    , cardBorder : Color
    , cardBlack  : Color
    , cardGreen  : Color
    , cardRed    : Color
    , cardWild   : Color
    }

color : ColorConfig
color =
    { boardBack  = Color.white
    , cardBack   = Color.rgb 210 210 200
    , cardBorder = Color.black
    , cardBlack  = Color.black
    , cardGreen  = Color.darkGreen
    , cardRed    = Color.darkRed
    , cardWild   = Color.darkRed
    }


------------------------------------------------------------------------------
-- Fonts & Text
------------------------------------------------------------------------------

type alias TextConfig =
    { small  : FontSize
    , medium : FontSize
    , large  : FontSize
    }

text : TextConfig
text =
    { small  = 12
    , medium = 24
    , large  = 42
    }


------------------------------------------------------------------------------
-- Size & Scale
------------------------------------------------------------------------------

type alias DimsConfig =
    { globalScale  : Float       -- Global scaling factor
    , buttonRadius : Pixels      -- Unscaled button radius
    , cardWidth    : Pixels      -- Unscaled card width
    , cardHeight   : Pixels      -- Unscaled card height
    , cornerRadius : Pixels      -- Unscaled card corner radius
    , fieldDims    : (Int, Int)  -- (row, column) values for the field
    }

dims : DimsConfig
dims =
    { globalScale  = 0.5
    , buttonRadius = 35
    , cardWidth    = 225
    , cardHeight   = 350
    , cornerRadius = 25
    , fieldDims    = (54, 96)
    }


------------------------------------------------------------------------------
-- Spacing & Position
------------------------------------------------------------------------------

type alias LayoutConfig =
    { baseUnit     : Pixels  -- Pixel count used for the underlying grid
    , stackOffset  : Int     -- Vertical offset for stacked cards
    , stackSpacing : Int     -- Horizontal spacing between stacks' centers
    , rowSpacing   : Int     -- Vertical spacing between top and bottom rows
    }

layout : LayoutConfig
layout =
    { baseUnit     = 25
    , stackOffset  = 3
    , stackSpacing = 10
    , rowSpacing   = 20
    }
