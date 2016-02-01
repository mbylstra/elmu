-- module MutableEnumDict
--     ( MutableEnumDict
--     , empty
--     -- , fromList
--     ) where

import Native.MutableEnumDict
-- import Basics exposing (..)
-- import Maybe exposing (..)
-- import List


import ElmTest exposing (..)


type MutableEnumDict a = MutableEnumDict


empty : MutableEnumDict keyType valueType
empty =
  Native.MutableEnumDict.empty

fromList : List (keyType, valueType) -> MutableEnumDict keyType valueType
fromList list =
  Native.MutableEnumDict.fromList list

get : keyType -> MutableEnumDict keyType valueType -> valueType
get key dict =
  Native.MutableEnumDict.get key dict

-- empty : MutableEnumDict keyType valueType
-- empty =
--   Native.MutableEnumDict.empty

-- initialize : Int -> (Int -> a) -> MutableEnumDict a
-- initialize =
--   Native.MutableEnumDict.initialize
--
-- repeat : Int -> a -> MutableEnumDict a
-- repeat n e =
--   initialize n (always e)
--
--
-- map : (a -> b) -> MutableEnumDict a -> MutableEnumDict b
-- map =
--   Native.MutableEnumDict.map
--
--
--
--
-- set : Int -> a -> MutableEnumDict a -> MutableEnumDict a
-- set =
--   Native.MutableEnumDict.set
--
--
-- length : MutableEnumDict a -> Int
-- length =
--   Native.MutableEnumDict.length


type TestEnum = Alpha | Beta | Gamma


tests : Test
tests =

    suite ""
        [
          test ""
            (assertEqual
                -- (repeat 5 0)
                -- (repeat 5 0)
                ( empty
                )
                empty
            )
        , test ""
            (assertEqual
                -- (repeat 5 0)
                -- (repeat 5 0)
                ( fromList [(Alpha, 1), (Beta, 2)]
                )
                ( fromList [(Alpha, 1), (Beta, 2)]
                )
            )
        , test ""
            (assertEqual
                -- (repeat 5 0)
                -- (repeat 5 0)
                ( get Alpha (fromList [(Alpha, 1)])
                )
                1
            )
        ]

-- main : Graphics.Element.Element
main =
    elementRunner tests
