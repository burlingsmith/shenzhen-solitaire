module Grid exposing
    ( Grid, Index, Dims
    , repeat
    , set, foldl, map, binSort
    , get, size
    )
{-| A two-dimensional grid in Elm. -}

------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

import Array exposing (Array)
import Dict exposing (Dict)


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

{-| Grid dimensions in a (row, column) tuple, where a 1x1 grid would be
(1, 1).

-}
type alias Dims = (Int, Int)


{-| Position of a cell within a grid formatted as a (row, column) tuple,
where the upper-leftmost entry is at (0, 0).

-}
type alias Index = (Int, Int)


{-| A two-dimensional grid.

-}
type Grid a =
    Grid_
        { dims : Dims
        , grid : Array (Array a)
        }


------------------------------------------------------------------------------
-- Utility
------------------------------------------------------------------------------

{-| Determine whether or not an index is possible in any grid (i.e. is
greater that or equal to (0, 0) on both axes).

-}
realIndex : Dims -> Bool
realIndex (r, c) =
    (r >= 0 && c >= 0)


{-| Determine if an index exists within a particular grid.

-}
validIndex : Grid a -> Dims -> Bool
validIndex grid (r, c) =
    if (realIndex (r, c)) then
        let
            rc = rowCount grid
            cc = colCount grid
        in
            (r < rc) && (c < cc)
    else
        False


{-| Return an array element at the given index or crash.

-}
forceGetArray : Int -> Array a -> a
forceGetArray index array =
    case Array.get index array of
        Just value ->
            value
        Nothing ->
            Debug.todo "forceGetArray: bad index"


{-| Return a dictionary value for the given key or crash.

-}
forceGetDict : comparable -> Dict comparable a -> a
forceGetDict key dict =
    case Dict.get key dict of
        Just value ->
            value
        Nothing ->
            Debug.todo "forceGetDict: bad key"


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| Generate a grid with each cell set to a given value. Returns Nothing if
the dimensions are invalid.

-}
repeat : Dims -> a -> Maybe (Grid a)
repeat (r, c) value =
    if (realIndex (r, c)) then
        let
            row = Array.repeat c value
            grid = Array.repeat r row
            newGrid = Grid_ { dims = (r, c), grid = grid }
        in
            Just newGrid
    else
        Nothing


------------------------------------------------------------------------------
-- Modification
------------------------------------------------------------------------------

{-| Set a grid entry to the given value. Returns the unmodified grid if the
index is invalid.

-}
set : Index -> a -> Grid a -> Grid a
set (r, c) value (Grid_ grid) =
    if (validIndex (Grid_ grid) (r, c)) then
        let
            oldRow = forceGetArray r grid.grid
            newRow = Array.set c value oldRow
            newGrid = Array.set r newRow grid.grid
        in
            Grid_ { grid | grid = newGrid }
    else
        (Grid_ grid)


{-| Fold a grid top to bottom, from the left of each row.

-}
foldl : (elem -> acc -> acc) -> acc -> Grid elem -> acc
foldl foldFxn acc (Grid_ src) =
    let
        rows = Array.toList src.grid
    in
        foldl_ foldFxn acc rows

foldl_ : (elem -> acc -> acc) -> acc -> List (Array elem) -> acc
foldl_ foldFxn acc rows =
    case rows of
        [] ->
            acc
        head::tail ->
            let
                newAcc = (Array.foldl foldFxn acc head)
            in
                foldl_ foldFxn newAcc tail


{-| Transform every element in a grid by a given function.

-}
map : (a -> b) -> Grid a -> Grid b
map mapFxn (Grid_ grid) =
    let
        newGrid = Array.map (Array.map mapFxn) grid.grid
    in
        Grid_ { dims = grid.dims, grid = newGrid }


{-| Place every element in a grid in a dictionary of lists, where the keys
are determined by some sorting function.

-}
binSort : (a -> comparable) -> Grid a -> Dict comparable (List a)
binSort sortFxn grid =
    let
        addToBin elem bins =
            let
                hash = sortFxn elem
            in
                case Dict.get hash bins of
                    Just value ->
                        Dict.insert hash (elem::value) bins
                    Nothing ->
                        Dict.insert hash [elem] bins
    in
        foldl addToBin Dict.empty grid


------------------------------------------------------------------------------
-- Analysis
------------------------------------------------------------------------------

{-| Return a grid entry, if the index is valid.

-}
get : Index -> Grid a -> Maybe a
get (r, c) (Grid_ grid) =
    if (validIndex (Grid_ grid) (r, c)) then
        let
            row = forceGetArray r grid.grid
        in
            Array.get c row
    else
        Nothing


{-| Return the number of rows and columns in a grid.

-}
size : Grid a -> Dims
size (Grid_ grid) =
    grid.dims


{-| Return the number of rows in a grid.

-}
rowCount : Grid a -> Int
rowCount grid =
    size grid |> Tuple.first


{-| Return the number of columns in a grid.

-}
colCount : Grid a -> Int
colCount grid =
    size grid |> Tuple.second
