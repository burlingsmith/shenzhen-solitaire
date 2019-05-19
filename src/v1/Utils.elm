module Utils exposing
    ( listInsert
    , listAppend
    )
{-| -}


------------------------------------------------------------------------------
-- Lists
------------------------------------------------------------------------------

{-| Place an item at the given index within a list, pushing other items
further back in the list. If the index given is too large, the item will be
placed at the end of the list. Indexes less than zero will place the item at
the front of the list.

    listInsert [1, 2, 3] 0 -1 == [-1, 1, 2, 3]

    listInsert [1, 2, 3] 1 -1 == [1, -1, 2, 3]

    listInsert [1, 2, 3] -1 0 == [0, 1, 2, 3]

    listInsert [] 0 1 == [1]

    listInsert [1, 2, 3] -1 10 == [1, 2, 3, 10]

 -}
listInsert : List a -> Int -> a -> List a
listInsert list index item =
    case list of
        [] ->
            [item]
        head::tail ->
            if (index <= 0) then
                item::list
            else
                head::(listInsert tail (index - 1) item)

{-| Place an item at the end of a given list. Slightly more efficient than
using listInsert for the same task.

    listAppend [1, 2, 3] 4 == [1, 2, 3, 4]

    listAppend [1, 2, 3, 4] -1 == [1, 2, 3, 4, -1]

    listAppend [] 7 == [7]

-}
listAppend : List a -> a -> List a
listAppend list item =
    case list of
        [] ->
            [item]
        head::tail ->
            head::(listAppend tail item)
