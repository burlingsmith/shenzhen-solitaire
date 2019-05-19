module Field exposing
    ( Field, Point, Dims, NodeTuple
    , new, fromList
    , set, get, clear
    , numRows, numCols, contains
    , compose
    )
{-| A uniform grid of nodes to attach Collage graphics to -}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Structures
import Dict exposing (Dict)

----{ Graphics
import Collage exposing (Collage)
import Collage.Layout


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

{-| Evenly-spaced grid of nodes -}
type alias Field msg data =
    { grid    : Grid msg data  -- field of nodes
    , dims    : Dims           -- row/col counts (not indexes)
    , spacing : Float          -- row/col pixel spacings
    }

type alias Grid msg data  -- if refactor, would actually be
    = Dict Int            -- Grid (Node msg data)
        (Dict Int         -- for more generic 2D grid
            (Maybe (Node msg data)))

{-| Positioned collage element -}
type alias Node msg data =
    { position : Point        -- node's position within the field
    , content  : Collage msg  -- element centered on the node
    , data     : data         -- any additional data stored with the node
    }

{-| Tuple containing the elements of a node -}
type alias NodeTuple msg data = (Point, Collage msg, data)

{-| Dimensions in (x, y) format -}
type alias Dims = (Int, Int)

{-| Position within a grid -}
type alias Point = (Int, Int)


------------------------------------------------------------------------------
-- Utility
------------------------------------------------------------------------------

{-| Return a known-to-exist value from a dictionary, sans preceding 'Just' -}
forceGet : Dict comparable v -> comparable -> v
forceGet dict key =
    case Dict.get key dict of
        Just value ->
            value
        Nothing ->
            Debug.todo "forceGet: bad key"


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| Generate an empty field -}
new : Dims -> Float -> Field msg data
new (r, c) spacing =
    let
        column =
            List.range 1 (max 1 c)
            |> List.map (\x -> (x, Nothing))
            |> Dict.fromList
        grid =
            List.range 1 (max 1 r)
            |> List.map (\x -> (x, column))
            |> Dict.fromList
    in
        { grid = grid
        , dims = (r, c)
        , spacing = spacing
        }

fromList : Dims -> Float -> List (NodeTuple msg data) -> Field msg data
fromList dims spacing list =
    let
        foldingFxn (pos, content, data) field = set field pos content data
    in
        List.foldl foldingFxn (new dims spacing) list


------------------------------------------------------------------------------
-- Modification
------------------------------------------------------------------------------

{-| Set a node's contents and data within a field, if the node is valid -}
set : Field msg data -> Point -> Collage msg -> data -> Field msg data
set field pos content data =
    if contains field pos then
        let
            node = { position = pos, content = content, data = data }
        in
            { field | grid = set_ field.grid pos (Just node) }
    else
        field

set_ : Grid msg data -> Point -> Maybe (Node msg data) -> Grid msg data
set_ grid (r, c) node =
    forceGet grid r
    |> (\row -> Dict.insert c node row)
    |> (\col -> Dict.insert r col grid)

{-| Retrieve the contents and data from a node within a field, if the node
exists

-}
get : Field msg data -> Point -> Maybe (Collage msg, data)
get field (r, c) =
    if contains field (r, c) then
        case forceGet (forceGet field.grid r) c of
            Just nd ->
                Just (nd.content, nd.data)
            Nothing ->
                Nothing
    else
        Nothing

{-| Clear the contents and data from a node within a field, if the node exists

-}
clear : Field msg data -> Point -> Field msg data
clear field pos =
    if contains field pos then
        { field | grid = set_ field.grid pos Nothing }
    else
        field


------------------------------------------------------------------------------
-- Analysis
------------------------------------------------------------------------------

{-| Determine the number of rows within field -}
numRows : Field msg data -> Int
numRows field =
    field.dims |> Tuple.first

{-| Determine the number of columns within a field -}
numCols : Field msg data -> Int
numCols field =
    field.dims |> Tuple.second

{-| Determine whether or not a point is contained within a field -}
contains : Field msg data -> Point -> Bool
contains field (checkRow, checkCol) =
    if (checkRow <= 0 || checkCol <= 0) then
        False
    else
        let
            (r, c) = field.dims
        in
            (checkRow <= r && checkCol <= c)


------------------------------------------------------------------------------
-- Composition
------------------------------------------------------------------------------

{-| Flatten a field into a single collage message -}
compose : Field msg data -> Collage msg
compose field =
    composeRow field.grid field.spacing

composeRow : Grid msg data -> Float -> Collage msg
composeRow row spacerSize =
    Dict.values row
    |> List.map (\x -> composeCol x spacerSize)
    |> Collage.Layout.vertical

composeCol : Dict Int (Maybe (Node msg data)) -> Float -> Collage msg
composeCol col spacerSize =
    Dict.values col
    |> List.map (\x -> composeSingle x spacerSize)
    |> Collage.Layout.horizontal

composeSingle : Maybe (Node msg data) -> Float -> Collage msg
composeSingle node spacerSize =
    let
        spacer = Collage.Layout.spacer spacerSize spacerSize
    in
        case node of
            Nothing ->
                spacer
            Just nd ->
                Collage.Layout.stack [ nd.content, spacer ]
