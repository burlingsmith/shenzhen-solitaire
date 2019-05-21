module Field exposing
    ( Field, Node
    , new, fromList
    , set, setSpacing, clear
    , get, getSpacing, size, nodePos, nodeContent, nodeData
    , qRender, render
    )
{-| A uniform grid of nodes to attach Collage graphics to -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Structures
import Grid exposing (Grid, Index, Dims)
import Dict exposing (Dict)

----{ Graphics
import Collage exposing (Collage)
import Collage.Layout


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

{-| -}
type Field msg data =
    Field_
        { grid    : Grid (Node msg data)  -- field of nodes
        , spacing : Float                 -- row/col pixel spacings
        }

{-| Positioned collage element -}
type Node msg data
    = E
    | N { position : Index, content : Collage msg, data : data }

{-| Tuple containing the elements of a node -}
type alias NodeTup msg data = (Index, Collage msg, data)

{-| -}
type alias Precedence = Int

{-| -}
type alias Evaluator msg data = (Node msg data -> Precedence)


------------------------------------------------------------------------------
-- Utility
------------------------------------------------------------------------------

{-| -}
toNode : Index -> Collage msg -> data -> Node msg data
toNode pos msg dat =
    N { position = pos, content = msg, data = dat }

{-| -}
getRow : Node msg data -> Maybe Int
getRow node =
    case nodePos node of
        Just (r, _) ->
            Just r
        _ ->
            Nothing

{-| -}
getCol : Node msg data -> Maybe Int
getCol node =
    case nodePos node of
        Just (_, c) ->
            Just c
        _ ->
            Nothing

{-| Convert field coordinates to grid coordinates -}
posToIndex : (Int, Int) -> Index
posToIndex (r, c) =
    (r - 1, c - 1)


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| -}
new : Dims -> Float -> Maybe (Field msg data)
new dims spacing =
    case Grid.repeat dims E of
        Just grid ->
            let
                field = Field_ { grid = grid, spacing = spacing }
            in
                Just field
        Nothing ->
            Nothing

{-| -}
fromList : Dims -> Float -> List (NodeTup msg data) -> Maybe (Field msg data)
fromList dims spacing nodeTuples =
    let
        blankGrid = new dims spacing
    in
        case blankGrid of
            Just grid ->
                Just (List.foldl set grid nodeTuples)
            Nothing ->
                Nothing


------------------------------------------------------------------------------
-- Modification
------------------------------------------------------------------------------

{-| -}
set : NodeTup msg data -> Field msg data -> Field msg data
set (pos, msg, dat) (Field_ field) =
    let
        node = toNode pos msg dat
    in
        Field_ { field | grid = Grid.set (posToIndex pos) node field.grid }

{-| -}
setSpacing : Float -> Field msg data -> Field msg data
setSpacing newSpacing (Field_ field) =
    Field_ { field | spacing = newSpacing }

{-| -}
clear : Field msg data -> Index -> Field msg data
clear (Field_ field) pos =
    Field_ { field | grid = (Grid.set (posToIndex pos) E field.grid) }


------------------------------------------------------------------------------
-- Analysis
------------------------------------------------------------------------------

{-| Retrieve the contents and data from a node within a field, if the node
exists

-}
get : Field msg data -> Index -> Maybe (Collage msg, data)
get (Field_ field) pos =
    case (Grid.get (posToIndex pos) field.grid) of
        Just (N record) ->
            Just (record.content, record.data)
        _ ->
            Nothing

{-| -}
getSpacing : Field msg data -> Float
getSpacing (Field_ field) =
    field.spacing

{-| -}
size : Field msg data -> Dims
size (Field_ field) =
    Grid.size field.grid

{-| -}
nodePos : Node msg data -> Maybe Index
nodePos node =
    case node of
        E ->
            Nothing
        N record ->
            Just record.position

{-| -}
nodeContent : Node msg data -> Maybe (Collage msg)
nodeContent node =
    case node of
        E ->
            Nothing
        N record ->
            Just record.content

{-| -}
nodeData : Node msg data -> Maybe data
nodeData node =
    case node of
        E ->
            Nothing
        N record ->
            Just record.data


------------------------------------------------------------------------------
-- Composition
------------------------------------------------------------------------------

{-| -}
qRender : Field msg data -> Collage msg
qRender field =
    let
        pFxn = (\_ -> 1)
    in
        render pFxn field

{-| Lower precedence goes on top -}
render : Evaluator msg data -> Field msg data -> Collage msg
render eval (Field_ field) =
    Grid.binSort eval field.grid
    |> Dict.map (\_ nodeList -> List.map (renderNode field.spacing) nodeList)
    |> Dict.map (\_ collageList -> Collage.Layout.stack collageList)
    |> Dict.values
    |> Collage.Layout.stack

{-| -}
renderTup : Float -> NodeTup msg data -> Collage msg
renderTup spacing (pos, msg, dat) =
    renderNode spacing (toNode pos msg dat)

{-| -}
renderNode : Float -> Node msg data -> Collage msg
renderNode spacing node =
    case node of
        E ->
            Collage.Layout.empty
        N record ->
            Collage.shift (getShift record.position spacing) record.content

{-| Calculate where to reposition an element -}
getShift : Index -> Float -> (Float, Float)
getShift (row, col) spacing =
    let
        shiftFor x = spacing * (toFloat x)
    in
        (shiftFor col, shiftFor (0 - row))
