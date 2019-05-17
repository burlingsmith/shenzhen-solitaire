module Menu exposing (..)
{-| A generic menu screen in Elm

TODO:
  - Render a menu
  - Implement customizable graphics rules
  - Allow complex positioning of the menu
  - Allow scaling of the menu
  - Include style attributes for each entry, with contextual responses (hover,
    click down, release, etc.)
  - Add menu header

-}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

import Dict
import Html exposing (Html)
import Html.Events
import Html.Attributes

import Utils


------------------------------------------------------------------------------
-- Types & Type Aliases
------------------------------------------------------------------------------

{-| Determine how the window is sized -}
type Sizing
    = Relative (Float, Float)  -- horizontal and vertical dimensions (percent)
    | Absolute (Float, Float)  -- horizontal and vertical dimensions (pixel)

{-| A single menu entry -}
type Entry msg data =
    Entry_
        { label  : String       -- text displayed for the entry in a menu
        , action : msg          -- message produced upon entry selection
        , data   : Maybe data   -- additional entry information
        }

{-| A collection of menu entries -}
type Menu msg data =
    Menu_
        { entries  : List (Entry msg data)
        , length   : Int
        , sizing   : Sizing
        }


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| -}
fromList : List (String, msg, dat) -> Menu msg dat
fromList rawList =
    Debug.todo "implement"


------------------------------------------------------------------------------
-- Entry Modification
------------------------------------------------------------------------------

{-| Set an entry's label -}
setLabel : String -> Entry msg dat -> Entry msg dat
setLabel newLabel (Entry_ entry) =
    Entry_ { entry | label = newLabel }

{-| Set an entry's action -}
setAction : msg -> Entry msg dat -> Entry msg dat
setAction newAction (Entry_ entry) =
    Entry_ { entry | action = newAction }

{-| Set an entry's data -}
setData : dat -> Entry msg dat -> Entry msg dat
setData newData (Entry_ entry) =
    Entry_ { entry | data = Just newData }


------------------------------------------------------------------------------
-- Menu Modification
------------------------------------------------------------------------------

{-| Add a menu entry by index -}
insertEntry : Menu msg dat -> Int -> Entry msg dat -> Menu msg dat
insertEntry (Menu_ menu) offset newEntry =
    let
        newEntries = Utils.listInsert menu.entries offset newEntry
    in
        Menu_
            { menu
            | entries = newEntries
            , length = menu.length + 1
            }

{-| Add an entry to the end of a menu -}
appendEntry : Menu msg dat -> Entry msg dat -> Menu msg dat
appendEntry (Menu_ menu) newEntry =
    let
        newEntries = Utils.listAppend menu.entries newEntry
    in
        Menu_
            { menu
            | entries = newEntries
            , length = menu.length + 1
            }


------------------------------------------------------------------------------
--
------------------------------------------------------------------------------

{-| Determine the number of entries in a menu -}
getLength : Menu msg dat -> Int
getLength (Menu_ menu) =
    menu.length

{-| Retrieve a menu entry by index -}
getEntry : Menu msg dat -> Int -> Maybe (Entry msg dat)
getEntry (Menu_ menu) index =
    menu.entries |> List.drop index |> List.head

{-| Determine how a menu is sized -}
getSizing : Menu msg dat -> Sizing
getSizing (Menu_ menu) =
    menu.sizing


------------------------------------------------------------------------------
-- Conversion
------------------------------------------------------------------------------

{-| -}
asEntry : String -> msg -> Maybe dat -> Entry msg dat
asEntry label action data =
    Entry_
        { label = label
        , action = action
        , data = data
        }

{-| -}
asTuple : Entry msg dat -> (String, msg, Maybe dat)
asTuple (Entry_ entry) =
    (entry.label, entry.action, entry.data)


------------------------------------------------------------------------------
-- Rendering
------------------------------------------------------------------------------

{-| -}
entryToHtml : Entry msg dat -> Html msg
entryToHtml (Entry_ entry) =
    let
        label = Html.text entry.label
    in
        -- temp implementation
        Html.div
            -- Attributes
            [ Html.Events.onClick entry.action
            , Html.Attributes.style "height" "90px"
            , Html.Attributes.style "width" "270px"
            , Html.Attributes.style "backgroundColor" "blue"
            ]
            -- Content
            [ label ]

{-| -}
toHtml : Menu msg dat -> Html msg
toHtml (Menu_ menu) =
    Debug.todo "implement"
