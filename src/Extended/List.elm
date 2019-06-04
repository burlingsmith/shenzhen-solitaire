module Extended.List exposing
    ( append, delete, find, ruleFind, remove, replace
    , dealSplit, nWaySplit
    )
{-| The Extended List module provides several functions absent from Elm's core
List library.

# Single-List Operations
@docs append, find, ruleFind, replace, delete, remove

# Multi-List Operations
@docs dealSplit, nWaySplit

-}


------------------------------------------------------------------------------
-- Single-List Operations
------------------------------------------------------------------------------

{-| Place an item at the end of a list.

Runs in linear time.

    append 3 [1,2] == [1, 2, 3]

    append 1 [] == [1]

-}
append : a -> List a -> List a
append item list =
    case list of
        [] ->
            [item]
        head::tail ->
            head::(append item tail)


{-| Remove the first occurence of an item from a list.

Runs in linear time.

-}
delete : a -> List a -> List a
delete target list =
    case list of
        [] ->
            []
        head::tail ->
            if head == target then
                tail
            else
                head::(delete target tail)


{-| Return the first occurence of an item from a list.

-}
find : a -> List a -> Maybe a
find target list =
    case list of
        [] ->
            Nothing
        head::tail ->
            if head == target then
                Just head
            else
                find target tail


{-| Return the first occurence of an item obeying a rule from a list.

-}
ruleFind : (a -> Bool) -> List a -> Maybe a
ruleFind rule list =
    List.head (List.filter rule list)


{-| Remove the first occurence of an item from a list and return it.

-}
remove : a -> List a -> (Maybe a, List a)
remove target list =
    let
        dList = delete target list
    in
        if List.length list > List.length dList then
            (Just target, dList)
        else
            (Nothing, list)


{-| -}
replace : a -> a -> List a -> List a
replace target replacement list =
    case list of
        [] ->
            []
        head::tail ->
            if head == target then
                replacement::tail
            else
                head::(replace target replacement tail)


{-| -}
ruleReplace : (a -> Bool) -> a -> List a -> List a
ruleReplace rule replacement list =
    case list of
        [] ->
            []
        head::tail ->
            if (rule head) then
                replacement::tail
            else
                head::(ruleReplace rule replacement tail)


------------------------------------------------------------------------------
-- Multi-List Operations
------------------------------------------------------------------------------

{-| Split a list into a list of exactly `n` lists, as evenly distributed as
possible. List order will be as though the items in the first list were placed
into each list sequentially, i.e. as though they were dealt out one at a
time.  Non-positive values of `n` will always return the empty list.

    dealSplit 3 [1, 2, 3] == [[1], [2], [3]]

    dealSplit 3 [1, 2, 3, 4] == [[1, 4], [2], [3]]

    dealSplit 3 [1, 2, 3, 4, 5] == [[1, 4], [2, 5], [3]]

    dealSplit 3 [1, 2, 3, 4, 5, 6] == [[1, 4], [2, 5], [3, 6]]

    dealSplit 3 [1, 2] == [[1], [2], []]

    dealSplit 3 [] == [[], [], []]

    dealSplit 2 [1, 2, 3] == [[1, 3], [2]]

    dealSplit 1 [1, 2, 3] == [[1, 2, 3]]

    dealSplit 0 [1, 2, 3] == []

    dealSplit -1 [1, 2, 3] == []

-}
dealSplit : Int -> List a -> List (List a)
dealSplit n list =
    if n <= 0 then
        []
    else
        let
            template = List.repeat n []

            singleDeal src dst acc =
                case (src, dst) of
                    (_, []) ->
                        (src, List.reverse acc)
                    ([], dstHead::dstTail) ->
                        singleDeal [] dstTail (dstHead::acc)
                    (srcHead::srcTail, dstHead::dstTail) ->
                        singleDeal srcTail dstTail ((srcHead::dstHead)::acc)

            iterativeDeal (src, dst) =
                case (singleDeal src dst []) of
                    ([], allDealt) ->
                        allDealt |> List.map List.reverse
                    (unDealt, dealtSoFar) ->
                        iterativeDeal (singleDeal unDealt dealtSoFar [])
        in
            iterativeDeal (list, template)


{-| Split a list into a list of exactly `n` lists, as evenly distributed as
possible. List order is preserved. Non-positive values of `n` will always
return the empty list.

    nWaySplit 3 [1, 2, 3] == [[1], [2], [3]]

    nWaySplit 3 [1, 2, 3, 4] == [[1, 2], [3], [4]]

    nWaySplit 3 [1, 2] == [[1], [2], []]

    nWaySplit 3 [] == [[], [], []]

    nWaySplit 2 [1, 2, 3] == [[1, 2], [3]]

    nWaySplit 1 [1, 2, 3] == [[1, 2, 3]]

    nWaySplit 0 [1, 2, 3] == []

    nWaySplit -1 [1, 2, 3] == []

-}
nWaySplit : Int -> List a -> List (List a)
nWaySplit n list =
    if n <= 0 then
        []
    else
        let
            splitByCount countList valueList =
                case countList of
                    [] ->
                        []
                    count::remCounts ->
                        let
                            subList = List.take count valueList
                            remVals = List.drop count valueList
                        in
                            subList::(splitByCount remCounts remVals)
        in
            let
                countPer =
                    toFloat (List.length list) / (toFloat n)
                minCountPer =
                    floor countPer
                leftoverCount =
                    (List.length list) - (n * minCountPer)
                baseCounts =
                    List.repeat n minCountPer
                recount index value =
                    if (leftoverCount - index > 0) then
                        value + 1
                    else
                        value
                finalCounts =
                    List.indexedMap recount baseCounts
            in
                splitByCount finalCounts list
