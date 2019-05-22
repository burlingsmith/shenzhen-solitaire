module Extended.List exposing (nWaySplit, dealSplit)
{-| Extensions to Elm's core List library -}


-----------------------------------------------------------------------------
-- Operations
------------------------------------------------------------------------------

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
