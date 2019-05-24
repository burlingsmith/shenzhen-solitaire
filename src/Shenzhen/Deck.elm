module Shenzhen.Deck exposing (..)
{-| -}

------------------------------------------------------------------------------
-- Dependencies
------------------------------------------------------------------------------

----{ Structures
import Shenzhen.Card as Card exposing (Card)

----{ Randomness
import Random
import Random.List


------------------------------------------------------------------------------
-- Representation
------------------------------------------------------------------------------

{-| A stack of cards -}
type alias Stack = List Card


------------------------------------------------------------------------------
-- Creation
------------------------------------------------------------------------------

{-| Generate an empty stack. -}
empty : Stack
empty =
    []


{-| Generate a full, sorted deck of Shenzhen Solitaire cards -}
full : Stack
full =
    let
        values =
            [ Card.Num 1
            , Card.Num 2
            , Card.Num 3
            , Card.Num 4
            , Card.Num 5
            , Card.Num 6
            , Card.Num 7
            , Card.Num 8
            , Card.Num 9
            , Card.Dragon
            , Card.Dragon
            , Card.Dragon
            , Card.Dragon
            ]
        blacks =
            List.map (\x -> Card.new Card.Black x) values
        greens =
            List.map (\x -> Card.new Card.Green x) values
        reds =
            List.map (\x -> Card.new Card.Red x) values
    in
        (Card.new Card.Wild Card.Rose)::(blacks ++ greens ++ reds)


------------------------------------------------------------------------------
-- Generation
------------------------------------------------------------------------------

{-| -}
shuffle : Stack -> Random.Generator Stack
shuffle deck =
    Random.List.shuffle deck


------------------------------------------------------------------------------
-- Analysis
------------------------------------------------------------------------------

{-| Return the highest index where grabbing from a stack is still possible -}
takeLimit : Stack -> Int
takeLimit stack =
    let
        scan lastCard remaining acc =
            case remaining of
                [] ->
                    acc
                head::tail ->
                    case lastCard of
                        Nothing ->
                            scan (Just head) tail (acc + 1)
                        Just card ->
                            let
                                test1 = Card.next card head
                                test2 = not (Card.sameSuit head card)
                            in
                                if (test1 && test2) then
                                    scan (Just head) tail (acc + 1)
                                else
                                    acc
    in
        scan Nothing stack 0


------------------------------------------------------------------------------
-- Modification
------------------------------------------------------------------------------

{-| Draw from the top of a stack -}
draw : Stack -> { took : Maybe Card, left : Stack }
draw stack =
    { took = List.head stack, left = List.drop 1 stack }


{-| Take a substack, if valid -}
take : Int -> Stack -> { took : Stack, left : Stack }
take depth stack =
    if (takeLimit stack) <= depth then
        { took = List.take depth stack, left = List.drop depth stack }
    else
        { took = [], left = stack }


{-| -}
forceTake : Int -> Stack -> { took : Stack, left : Stack }
forceTake depth stack =
    Debug.todo "implement"


{-| -}
place : Int
place = 0  -- implement


{-| -}
forcePlace : Int
forcePlace = 0  -- implement


{-| -}
shift : Stack -> Stack -> Int -> (Stack, Stack)
shift to from count =
    Debug.todo "implement"
