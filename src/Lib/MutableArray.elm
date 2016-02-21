module Lib.MutableArray
    ( MutableArray
    , initialize
    , length
    , get, set
    , map
    , repeat
    ) where

import Native.MutableArray
import Basics exposing (..)
import Maybe exposing (..)


import ElmTest exposing (..)


type MutableArray a = MutableArray


initialize : Int -> (Int -> a) -> MutableArray a
initialize =
  Native.MutableArray.initialize

repeat : Int -> a -> MutableArray a
repeat n e =
  initialize n (always e)


map : (a -> b) -> MutableArray a -> MutableArray b
map =
  Native.MutableArray.map


get : Int -> MutableArray a -> Maybe a
get i array =
  if 0 <= i && i < Native.MutableArray.length array then
    Just (Native.MutableArray.get i array)
  else
    Nothing


set : Int -> a -> MutableArray a -> MutableArray a
set =
  Native.MutableArray.set


length : MutableArray a -> Int
length =
  Native.MutableArray.length


tests : Test
tests =

    suite ""
        [
          test ""
            (assertEqual
                -- (repeat 5 0)
                -- (repeat 5 0)
                ((repeat 5 0)
                  |> set 0 0
                  |> set 1 1
                  |> set 2 2
                  |> set 3 3
                  |> set 4 4
                  |> set 5 5
                  |> set 6 6
                  |> set 7 7
                  |> get 7
                )
                (Just 7)
            )
        ]

-- main : Graphics.Element.Element
-- main =
--     elementRunner tests
