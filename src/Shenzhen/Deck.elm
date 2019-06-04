module Shenzhen.Deck exposing
    ( Stack, Card, ContinuityCheck
    , asCard, setCard, getCard, getHeight, getDepth, getUnder, getAbove
    , empty, full, fromList
    , shuffle
    , append, prepend, reverse, dealSplit, nWaySplit
    , length, isEmpty, top
    , minorContinuous, majorContinuous, ruledSplit, ruledMerge, forceSplit, forceMerge
    , toList
    , debugStack1, debugStack2, debugStack3, cardSummary, stackSummary
    , setGroupState, setStackState
    )
{-| Last updated for Elm 0.19.

This module offers abstractions for stacks of Shenzhen Solitaire cards and
associated operations.

-}


------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

import Shenzhen.Card as Card exposing (Suit(..), Face(..))

import Extended.List as XList

import Random
import Random.List


------------------------------------------------------------------------------
-- Card Wrapper
------------------------------------------------------------------------------

{-| The Shenzhen.Deck module opaquely wraps the Shenzhen.Card.Card type and
adds stack-specific data: the number of cards above/below a given card, as
well as the cards immediately adjacent to said card.

-}
type Card =
    Card
        { card   : Card.Card   -- Actual card
        , height : Int         -- Number of cards beneath this one
        , depth  : Int         -- Number of cards above this one
        , under  : Maybe Card  -- Card immediately above this one
        , above  : Maybe Card  -- Card immediately under this one
        }


{-| Create a card from a suit and value. -}
asCard : Suit -> Face -> Card
asCard suit face =
    Card
        { card = Card.new suit face
        , height = 0
        , depth = 0
        , under = Nothing
        , above = Nothing
        }


{-| Create a Card from a Card.Card. -}
fromCard : Card.Card -> Card
fromCard card =
    Card
        { card = card
        , height = 0
        , depth = 0
        , under = Nothing
        , above = Nothing
        }


{-| Set the unwrapped card within a wrapped one. -}
setCard : Card.Card -> Card -> Card
setCard newCard (Card card) =
    Card { card | card = newCard }


{-| Set a card's state. -}
setCardState : Card.State -> Card -> Card
setCardState newState (Card card) =
    Card { card | card = (Card.setState newState card.card) }


{-| Set the number of cards under the given card. -}
setHeight : Int -> Card -> Card
setHeight newHeight (Card card) =
    Card { card | height = newHeight }


{-| Set the number of cards above the given card. -}
setDepth : Int -> Card -> Card
setDepth newDepth (Card card) =
    Card { card | depth = newDepth }


{-| Set the card immediately under the given card. -}
setUnder : Maybe Card -> Card -> Card
setUnder newUnder (Card card) =
    Card { card | under = newUnder }


{-| Set the card immediately above the given card. -}
setAbove : Maybe Card -> Card -> Card
setAbove newAbove (Card card) =
    Card { card | above = newAbove }


{-| Get the unwrapped Card type from a wrapped one -}
getCard : Card -> Card.Card
getCard (Card card) =
    card.card


{-| Get the number of cards under the given card. -}
getHeight : Card -> Int
getHeight (Card card) =
    card.height


{-| Get the number of cards above the given card. -}
getDepth : Card -> Int
getDepth (Card card) =
    card.depth


{-| Get the card immediately under the given card. -}
getUnder : Card -> Maybe Card
getUnder (Card card) =
    card.under


{-| Get the card immediately above the given card. -}
getAbove : Card -> Maybe Card
getAbove (Card card) =
    card.above


------------------------------------------------------------------------------
-- Stacks
------------------------------------------------------------------------------

{-| Stacks are represented as a list of cards, with the first element
possessing the greatest height. They are kept opaque in order to guaruntee
valid metadata, taken that burden of the user. See `toList` for an equivalent
to transparent manipulation.

-}
type Stack = Stack (List Card)


------------------------------------------------------------------------------
-- Utility
------------------------------------------------------------------------------

{-| Fill in and update a stack's metadata. -}
validate : List Card -> List Card
validate stack =
    let
        pass f1 count f2 prev cards =
            case cards of
                [] ->
                    []
                head::tail ->
                    let
                        card = head |> f1 count |> f2 prev
                    in
                        card::(pass f1 (count + 1) f2 (Just card) tail)
    in
        stack
        |> (pass setDepth 0 setUnder Nothing)
        |> List.reverse
        |> (pass setHeight 0 setAbove Nothing)
        |> List.reverse


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| Generate an empty stack. -}
empty : Stack
empty =
    Stack []


{-| Generate a full, sorted deck of Shenzhen Solitaire cards -}
full : Stack
full =
    let
        values =
            [ Num 1, Num 2, Num 3, Num 4, Num 5, Num 6, Num 7, Num 8, Num 9
            , Dragon, Dragon, Dragon, Dragon
            ]
        blacks =
            List.map (asCard Black) values
        greens =
            List.map (asCard Green) values
        reds =
            List.map (asCard Red) values
    in
        (asCard Wild Rose)::(blacks ++ greens ++ reds)
        |> validate
        |> Stack


{-| Generate a stack from a list of cards. -}
fromList : List Card.Card -> Stack
fromList cards =
    Stack (validate (List.map fromCard cards))


------------------------------------------------------------------------------
-- Random Generation
------------------------------------------------------------------------------

{-| Creates a random generator for the random rearrangement of a stack. -}
shuffle : Stack -> Random.Generator Stack
shuffle (Stack stack) =
    Random.map Stack (Random.List.shuffle stack)


------------------------------------------------------------------------------
-- Modification
------------------------------------------------------------------------------

{-| Place a card at the bottom of a stack-}
append : Card -> Stack -> Stack
append card (Stack stack) =
    Stack (validate (XList.append card stack))


{-| Place a card at the top of a stack. -}
prepend : Card -> Stack -> Stack
prepend card (Stack stack) =
    Stack (validate (card::stack))


{-| Reverse the ordering of a stack. -}
reverse : Stack -> Stack
reverse (Stack stack) =
    Stack (validate (List.reverse stack))


{-| Set the state of cards in a stack up to and including a given depth.

-}
setGroupState : Card.State -> Int -> Stack -> Stack
setGroupState state depth (Stack stack) =
    let
        helper cards =
            case cards of
                [] ->
                    []
                head::tail ->
                    if (getDepth head) <= depth then
                        (setCardState state head)::(helper tail)
                    else
                        cards
    in
        Stack (helper stack)


{-| Set the state of all cards in a stack.

-}
setStackState : Card.State -> Stack -> Stack
setStackState state (Stack stack) =
    let
        helper cards =
            case cards of
                [] ->
                    []
                head::tail ->
                    (setCardState state head)::(helper tail)
    in
        Stack (helper stack)


{-| Deal cards out from one stack into n other stacks.

-}
dealSplit : Int -> Stack -> List Stack
dealSplit n (Stack stack) =
    XList.dealSplit n stack
    |> List.map validate
    |> List.map Stack


{-| Divide a stack into n other stacks.

-}
nWaySplit : Int -> Stack -> List Stack
nWaySplit n (Stack stack) =
    XList.nWaySplit n stack
    |> List.map validate
    |> List.map Stack


------------------------------------------------------------------------------
-- Analysis
------------------------------------------------------------------------------

{-| -}
length : Stack -> Int
length (Stack stack) =
    List.length stack


{-| -}
isEmpty : Stack -> Bool
isEmpty (Stack stack) =
    List.isEmpty stack


{-| -}
sameValue : Card -> Card -> Bool
sameValue card1 card2 =
    let
        c1 = getCard card1
        c2 = getCard card2
    in
        Card.sameValue c1 c2


{-| -}
sameSuit : Card -> Card -> Bool
sameSuit card1 card2 =
    let
        c1 = getCard card1
        c2 = getCard card2
    in
        Card.sameSuit c1 c2


{-| -}
sameCard : Card -> Card -> Bool
sameCard card1 card2 =
    (sameValue card1 card2) && (sameSuit card1 card2)


{-| -}
top : Stack -> Maybe Card
top (Stack stack) =
    List.head stack


------------------------------------------------------------------------------
-- Continuity
------------------------------------------------------------------------------

{-| There are two types of continuity in Shenzhen Solitaire stacks. Minor
continuity is when a run of cards increment in value and alternate in suit.
Major continuity is when a run of cards decrement in value and all possess the
same suit.

-}
type alias ContinuityCheck = (Stack -> Int -> Bool)


mContinuous : (Card.Card -> Card.Card -> Bool) -> ContinuityCheck
mContinuous compare (Stack stack) depth =
    let
        singleCheck card =
            case (getUnder card) of
                Nothing ->
                    True
                Just lastCard ->
                    compare (getCard lastCard) (getCard card)

        recursor cards =
            case cards of
                [] ->
                    False
                head::tail ->
                    if (singleCheck head) then
                        if (1 + getDepth head == depth) then
                            True
                        else
                            recursor tail
                    else
                        False
    in
        recursor stack


{-| Determine if a stack follows the rules for general stacking, up to a
particular depth.

This continuity check will fail if the requested depth exceeds that possible
in the given stack. The empty list is considered discontinuous.

Note that the provided depth in this case is the total number of cards to
evaluate, which will end up being one numeric value higher than the depth of
the last card evaluated.

-}
minorContinuous : ContinuityCheck
minorContinuous stack depth =
    mContinuous Card.nextMinor stack depth


{-| Determine if a stack follows the rules for discarding, up to a particular
depth (i.e. values descend one-by-one as you go up the stack, and the suit is
constant).

This continuity check will fail if the requested depth exceeds that possible
in the given stack. The empty list is considered discontinuous.

Note that the provided depth in this case is the total number of cards to
evaluate, which will end up being one numeric value higher than the depth of
the last card evaluated.

-}
majorContinuous : ContinuityCheck
majorContinuous stack depth =
    mContinuous Card.nextMajor stack depth


{-| Split a stack. -}
forceSplit : Stack -> Int -> (Stack, Stack)
forceSplit (Stack stack) depth =
    let
        taken = validate (List.take depth stack)
        left = validate (List.drop depth stack)
    in
        (Stack taken, Stack left)


{-| Attempt to split a stack in accordance with the rules of Shenzhen
Solitaire.

-}
ruledSplit : ContinuityCheck -> Stack -> Int -> (Maybe Stack, Stack)
ruledSplit continuous stack depth =
    let
        (taken, left) = forceSplit stack depth
    in
        if (continuous taken (length taken)) then
            (Just taken, left)
        else
            (Nothing, stack)


{-| Merge two stacks. -}
forceMerge : Stack -> Stack -> Stack
forceMerge (Stack addition) (Stack base) =
    Stack (validate (addition ++ base))


{-| Attempt to merge two stacks in accordance with the rules of Shenzhen
Solitaire.

-}
ruledMerge : ContinuityCheck -> Stack -> Stack -> (Stack, Maybe Stack)
ruledMerge continuous addition base =
    let
        merged = forceMerge addition base
    in
        if (continuous merged (length addition)) then
            (merged, Nothing)
        else
            (addition, Just base)


------------------------------------------------------------------------------
-- Conversion
------------------------------------------------------------------------------

{-| Convert a stack to a list of cards. -}
toList : Stack -> List Card
toList (Stack cards) =
    cards


------------------------------------------------------------------------------
-- Debug
------------------------------------------------------------------------------

debugStack1 : Stack
debugStack1 =
    let
        cards =
            [ asCard Black (Num 1)
            , asCard Green (Num 2)
            , asCard Red (Num 3)
            ]
    in
        Stack (validate cards)

debugStack2 : Stack
debugStack2 =
    let
        cards =
            [ asCard Red (Num 6)
            , asCard Green (Num 5)
            , asCard Black (Num 4)
            ]
    in
        Stack (validate cards)

debugStack3 : Stack
debugStack3 =
    let
        cards =
            [ asCard Red (Num 1)
            , asCard Red (Num 2)
            , asCard Red (Num 3)
            ]
    in
        Stack (validate cards)

{-| Summarize a single card's data. -}
cardSummary : Card -> String
cardSummary (Card card) =
    let
        miniSummary c1 =
            case c1 of
                Nothing ->
                    "N/A"
                Just (Card c2) ->
                    Card.toString c2.card

        cardStr = Card.toString card.card
        height = " [ Height = " ++ String.fromInt card.height
        depth  = " | Depth = " ++ String.fromInt card.depth
        under  = " | Under = " ++ miniSummary card.under
        above  = " | Above = " ++ miniSummary card.above
    in
        cardStr ++ height ++ depth ++ under ++ above ++ " ]"


{-| Summarize an entire stack's data. -}
stackSummary : Stack -> List String
stackSummary (Stack stack) =
    List.map cardSummary stack
