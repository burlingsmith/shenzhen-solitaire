module Shenzhen.Button exposing (..)
{-| -}

type State = Inactive | Normal | Pressed | Hover

type Role = CollapseBlack | Collapse

type alias Button =
    { role  : Role
    , state : State
    }
