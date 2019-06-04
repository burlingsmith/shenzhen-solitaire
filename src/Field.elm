module Field exposing
    ( Field, Node
    , toNode
    , new, fromList
    , set, setSpacing, clear
    , get, getSpacing, size, nodePos, nodeContent, nodeData, getRow, getCol
    , qRender, render
    )
{-| A uniform grid of nodes to attach Collage graphics to. -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Structures
import Grid exposing (Grid, Index, Dims)
import Dict exposing (Dict)

----{ Graphics
import Collage exposing (Collage)
import Collage.Layout exposing (Anchor)


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

{-| A collection of evenly spaced collage images and associated data.

-}
type Field msg data =
    Field_
        { grid    : Grid (Node msg data)  -- field of nodes
        , spacing : Float                 -- row/col pixel spacings
        }


{-| Positioned collage element and associated data.

-}
type Node msg data
    = E
    | N
        { position : Index       -- Position of the image within the field
        , content : Collage msg  -- Image to place in the field
        , anchor : Anchor msg    -- Location the image will be anchored by
        , data : data            -- Any additional data paired with the image
        }


{-| Value used to determine rendering order. Lower value layers will be
rendered on top of greater value layers.

-}
type alias Precedence = Int


{-| Function prototype for functions used to determine precedence.

-}
type alias Evaluator msg data = (Node msg data -> Precedence)


------------------------------------------------------------------------------
-- Utility
------------------------------------------------------------------------------

{-| Create a node from the constituent elements.

-}
toNode : Index -> Collage msg -> data -> Anchor msg -> Node msg data
toNode pos msg dat anchor =
    N
        { position = pos
        , content = msg
        , anchor = anchor
        , data = dat
        }


{-| Determine a node's row.

-}
getRow : Node msg data -> Maybe Int
getRow node =
    case nodePos node of
        Just (r, _) ->
            Just r
        _ ->
            Nothing


{-| Determine a node's column.

-}
getCol : Node msg data -> Maybe Int
getCol node =
    case nodePos node of
        Just (_, c) ->
            Just c
        _ ->
            Nothing


{-| Convert field coordinates to grid coordinates.

-}
posToIndex : (Int, Int) -> Index
posToIndex (r, c) =
    (r - 1, c - 1)


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| Create a new, empty field with given dimensions and spacing.

-}
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


{-| Generate a field from a list of nodes.

-}
fromList : Dims -> Float -> List (Node msg data) -> Maybe (Field msg data)
fromList dims spacing nodes =
    let
        blankGrid = new dims spacing
    in
        case blankGrid of
            Just grid ->
                Just (List.foldl set grid nodes)
            Nothing ->
                Nothing


------------------------------------------------------------------------------
-- Modification
------------------------------------------------------------------------------

{-| Set a given node's data in a field. Returns the unaltered field if the
node's position is invalid.

-}
set : Node msg data -> Field msg data -> Field msg data
set node (Field_ field) =
    case node of
        E ->
            (Field_ field)
        N record ->
            let
                grid = field.grid
                index = (posToIndex record.position)
            in
                Field_ { field | grid = Grid.set index node grid }


{-| Set the number of pixels between nodes in a field.

-}
setSpacing : Float -> Field msg data -> Field msg data
setSpacing newSpacing (Field_ field) =
    Field_ { field | spacing = newSpacing }


{-| Remove all collage images and data from a field.

-}
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


{-| Get the number of pixels between nodes in a field.

-}
getSpacing : Field msg data -> Float
getSpacing (Field_ field) =
    field.spacing


{-| Get the number of rows and columns in a field.

-}
size : Field msg data -> Dims
size (Field_ field) =
    Grid.size field.grid


{-| Get a node's row and column.

-}
nodePos : Node msg data -> Maybe Index
nodePos node =
    case node of
        E ->
            Nothing
        N record ->
            Just record.position


{-| Get a node's collage message.

-}
nodeContent : Node msg data -> Maybe (Collage msg)
nodeContent node =
    case node of
        E ->
            Nothing
        N record ->
            Just record.content


{-| Get a node's associated data.

-}
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

{-| Render a field with all nodes set to the same precedence level.

-}
qRender : Field msg data -> Collage msg
qRender field =
    let
        pFxn = (\_ -> 1)
    in
        render pFxn field


{-| Render a field with each node's precedence level calculated by a given
function.

-}
render : Evaluator msg data -> Field msg data -> Collage msg
render eval (Field_ field) =
    Grid.binSort eval field.grid
    |> Dict.map (\_ nodeList -> List.map (renderNode field.spacing) nodeList)
    |> Dict.map (\_ collageList -> Collage.Layout.stack collageList)
    |> Dict.values
    |> Collage.Layout.stack


{-| Render a single node.

-}
renderNode : Float -> Node msg data -> Collage msg
renderNode spacing node =
    case node of
        E ->
            Collage.Layout.empty
        N record ->
            let
                image = Collage.Layout.align record.anchor record.content
            in
                Collage.shift (getShift record.position spacing) image


{-| Convert grid position to screen position.

-}
getShift : Index -> Float -> (Float, Float)
getShift (row, col) spacing =
    let
        shiftFor x = spacing * (toFloat x)
    in
        (shiftFor col, shiftFor (0 - row))
